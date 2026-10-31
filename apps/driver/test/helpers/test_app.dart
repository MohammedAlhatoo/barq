import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:barq_core/barq_core.dart';
import 'package:barq_driver/app/app.dart';
import 'package:barq_driver/app/di.dart';
import 'package:barq_driver/app/locale_cubit.dart';
import 'package:barq_driver/features/auth/data/auth_repository.dart';
import 'package:barq_driver/features/earnings/data/earnings_repository.dart';
import 'package:barq_driver/features/history/data/history_repository.dart';
import 'package:barq_driver/features/jobs/data/device_actions.dart';
import 'package:barq_driver/features/jobs/data/jobs_repository.dart';
import 'package:barq_driver/features/jobs/data/location_source.dart';
import 'package:barq_driver/features/jobs/data/location_tracker.dart';
import 'package:barq_driver/features/notifications/data/notifications_repository.dart';
import 'package:barq_driver/features/profile/data/profile_repository.dart';
import 'package:barq_driver/features/profile/state/driver_cubit.dart';
import 'package:barq_driver/features/system/state/system_cubit.dart';
import 'package:barq_driver/features/task/data/proof_photo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One server answer. [error] makes it the standard failure shape.
class Reply {
  const Reply(this.data, {this.status = 200, this.error, this.details});

  final Object? data;
  final int status;
  final String? error;
  final Map<String, Object?>? details;
}

/// Plays the server: maps "POST /driver/location" to a [Reply].
class FakeServer implements HttpClientAdapter {
  FakeServer(this.replies);

  final Map<String, Reply> replies;
  final List<String> calls = [];
  final Map<String, Object?> bodies = {};
  final Map<String, Map<String, dynamic>> headers = {};
  final Map<String, Map<String, dynamic>> queries = {};

  /// True makes every request fail like a dead connection.
  bool offline = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (offline) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
      );
    }
    final key = '${options.method} ${Uri.parse(options.path).path}'
        .replaceFirst('/api/v1', '');
    calls.add(key);
    bodies[key] = options.data;
    headers[key] = options.headers;
    queries[key] = options.queryParameters;
    final reply = replies[key] ?? const Reply(null, status: 500, error: 'x');
    final code = reply.error;
    final body = code == null
        ? {'success': true, 'message': 'ok', 'data': reply.data}
        : {
            'success': false,
            'message': 'failed',
            'error': {
              'code': code,
              'details': reply.details,
              'hint': {'ar': 'رسالة السيرفر', 'en': 'server message'},
            },
          };
    return ResponseBody.fromString(
      jsonEncode(body),
      reply.status,
      headers: {
        'content-type': ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class FakeNetwork extends NetworkMonitor {
  final controller = StreamController<bool>.broadcast();

  @override
  Future<bool> isOnline() async => true;

  @override
  Stream<bool> get onlineChanges => controller.stream;
}

class FakeLocationSource implements LocationSource {
  final controller = StreamController<LocationPoint>.broadcast();
  LocationFailure? failure;

  static final point = LocationPoint(
    lat: 31.5,
    lng: 34.46,
    recordedAt: DateTime.utc(2026),
    accuracy: 8,
  );

  @override
  Future<LocationPoint> current() async {
    final problem = failure;
    if (problem != null) throw problem;
    return point;
  }

  @override
  Stream<LocationPoint> watch({required int intervalSeconds}) =>
      controller.stream;
}

/// A camera that always works, and an upload through the fake server.
class FakeProofPhotos implements ProofPhotos {
  FakeProofPhotos(this._api);

  final ApiClient _api;

  /// True is a driver who closes the camera without a photo.
  bool closesCamera = false;

  @override
  Future<File?> take() async {
    if (closesCamera) return null;
    final file = File('${Directory.systemTemp.path}/barq_proof_test.png');
    await file.writeAsBytes(_onePixelPng);
    return file;
  }

  @override
  Future<int> upload(File photo) async {
    final data = await _api.post('/uploads') as Map;
    return data['upload_id'] as int;
  }
}

final _onePixelPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGA'
  'WjR9awAAAABJRU5ErkJggg==',
);

class FakeDeviceActions implements DeviceActions {
  final List<String> called = [];
  final List<String> navigated = [];

  @override
  Future<void> call(String phone) async => called.add(phone);

  @override
  Future<void> navigate(double lat, double lng) async =>
      navigated.add('$lat,$lng');
}

const configJson = {
  'project': {'support_phone': '0592525487'},
  'delivery_confirmation': 'photo',
  'payment_methods': ['cash_on_delivery'],
  'statuses': [
    {
      'key': 'accepted',
      'label': 'تم القبول',
      'color': '#3B82F6',
      'icon': 'x',
      'step': 20,
      'is_terminal': false,
    },
    {
      'key': 'picked_up',
      'label': 'تم الاستلام',
      'color': '#8B5CF6',
      'icon': 'x',
      'step': 30,
      'is_terminal': false,
    },
    {
      'key': 'on_the_way',
      'label': 'في الطريق',
      'color': '#0EA5E9',
      'icon': 'x',
      'step': 40,
      'is_terminal': false,
    },
    {
      'key': 'arrived',
      'label': 'السائق وصل',
      'color': '#14B8A6',
      'icon': 'x',
      'step': 50,
      'is_terminal': false,
    },
    {
      'key': 'delivered',
      'label': 'تم التوصيل',
      'color': '#10B981',
      'icon': 'x',
      'step': 60,
      'is_terminal': true,
    },
  ],
  'polling': {'available_orders_seconds': 10, 'tracking_seconds': 30},
  'driver': {
    'radius_km': 10,
    'location_min_interval_seconds': 3,
    'online_requires_location_minutes': 5,
  },
  'currency': {'code': 'ILS', 'symbol': '₪', 'minor_units': 100},
  'min_app_version': '1.0.0',
  'modules': <String>[],
  'terms_url': 'https://example.com/terms',
};

Map<String, Object> money(String formatted, [int amount = 0]) => {
  'amount': amount,
  'formatted': formatted,
};

Map<String, Object?> driverJson({bool online = false}) => {
  'id': 1,
  'name': 'أبو خالد',
  'phone': '0599100001',
  'avatar_url': null,
  'vehicle_type': 'motorcycle',
  'locale': 'ar',
  'is_online': online,
  'rating': {'average': 4.9, 'count': 12},
  'cash_on_hand': money('420.00 ₪', 42000),
  'max_cash': money('500.00 ₪', 50000),
};

final earningsJson = {
  'orders': 7,
  'earnings': money('86.00 ₪'),
  'series': <Object>[],
};

final cashJson = {
  'cash_on_hand': money('500.00 ₪', 50000),
  'max_cash': money('500.00 ₪', 50000),
  'remaining': money('0.00 ₪'),
  'unsettled_orders': 3,
  'settlements': <Object>[],
};

Map<String, Object?> nextActionJson({
  String action = 'transition',
  String to = 'picked_up',
  String label = 'استلمت الطلب',
  List<String> requires = const [],
  String? confirm,
  int? geofence,
}) => {
  'action': action,
  'to': to,
  'label': label,
  'style': 'primary',
  'requires': requires,
  'geofence_meters': geofence,
  'confirm': confirm,
  'fields': <String>[],
};

Map<String, Object?> jobJson({
  int id = 42,
  String status = 'pending',
  Map<String, Object?>? next,
  bool mine = false,
}) => {
  'id': id,
  'code': 'BR-000$id',
  'status': {'key': status, 'label': status},
  'is_mine': mine,
  'distance_km': 1.2,
  'distance_to_pickup_km': 0.6,
  'pickup': {
    'label': 'ميني ماركت النور',
    'details': 'شارع صلاح الدين',
    'lat': 31.45,
    'lng': 34.39,
    'address_id': null,
  },
  'dropoff': {
    'label': 'النصيرات',
    'details': 'قرب مسجد الهدى',
    'lat': 31.44,
    'lng': 34.4,
    'address_id': 5,
  },
  'payment': {
    'method': 'cash',
    'status': 'cash_on_delivery',
    'collect': money('51.00 ₪', 5100),
  },
  'delivery_fee': money('7.00 ₪', 700),
  'earning': money('9.00 ₪', 900),
  'items_count': 4,
  'items': mine
      ? [
          {'id': 1, 'name': 'بندورة بلدية', 'qty': 2, 'note': null},
          {'id': 2, 'name': 'حليب طازج', 'qty': 2, 'note': null},
          {'id': 3, 'name': 'خبز', 'qty': 1, 'note': null},
        ]
      : <Object>[],
  'customer': mine ? {'name': 'محمد أحمد', 'phone': '0599000000'} : null,
  'vendor': {
    'id': 3,
    'name': 'ميني ماركت النور',
    'phone': '0590000001',
    'logo_url': null,
    'location': {'lat': 31.45, 'lng': 34.39},
    'prep_minutes': 15,
  },
  'next_action': next,
  'actions': <Object>[],
};

/// What a logged-in, offline driver with nothing going on gets.
Map<String, Reply> quietServer() => {
  'GET /app/config': const Reply(configJson),
  'GET /driver/me': Reply(driverJson()),
  'GET /driver/earnings': Reply(earningsJson),
  'GET /driver/orders/available': const Reply(<Object>[]),
  'GET /driver/orders/current': const Reply(null),
  'GET /driver/cash': Reply(cashJson),
};

const logged = {'barq_token': 'saved'};

/// Short, so a test sees the job end without waiting.
const jobCheckEvery = Duration(milliseconds: 20);

/// A full app with real repositories on top of [FakeServer].
class TestApp {
  TestApp._(this.deps, this.server, this.location, this.actions, this.photos);

  final AppDependencies deps;
  final FakeServer server;
  final FakeLocationSource location;
  final FakeDeviceActions actions;
  final FakeProofPhotos photos;

  static Future<TestApp> create(
    Map<String, Reply> replies, {
    Map<String, String> secure = const {},
  }) async {
    FlutterSecureStorage.setMockInitialValues(Map.of(secure));
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final server = FakeServer(replies);
    final auth = AuthStore();
    await auth.load();
    final locale = LocaleCubit(prefs);
    final api = ApiClient(
      authStore: auth,
      appVersion: appVersion,
      language: () => locale.state.languageCode,
      dio: Dio()..httpClientAdapter = server,
    );
    final config = ConfigStore(api: api, app: BarqAppKind.driver);
    final location = FakeLocationSource();
    final tracker = LocationTracker(
      api: api,
      source: location,
      minIntervalSeconds: () => null,
    );
    final profile = ApiProfileRepository(api);
    final jobs = ApiJobsRepository(api);
    final actions = FakeDeviceActions();
    final photos = FakeProofPhotos(api);
    final deps = AppDependencies(
      auth: auth,
      api: api,
      config: config,
      locale: locale,
      system: SystemCubit(
        api: api,
        auth: auth,
        config: config,
        network: FakeNetwork(),
        appVersion: appVersion,
      ),
      authRepository: ApiAuthRepository(api, auth),
      profileRepository: profile,
      jobsRepository: jobs,
      earningsRepository: ApiEarningsRepository(api),
      historyRepository: ApiHistoryRepository(api),
      notificationsRepository: ApiNotificationsRepository(api),
      proofPhotos: photos,
      deviceActions: actions,
      tracker: tracker,
      driver: DriverCubit(
        repository: profile,
        jobs: jobs,
        tracker: tracker,
        jobCheckEvery: () => jobCheckEvery,
        auth: auth,
      ),
    );
    return TestApp._(deps, server, location, actions, photos);
  }

  /// Dio works with real timers, so waits run outside the fake clock.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  /// Stops before the first request ends, to see the splash.
  Future<void> pumpFirstFrame(WidgetTester tester) async {
    await tester.pumpWidget(BarqDriverApp(deps: deps));
    await tester.pump();
  }

  Future<void> pump(WidgetTester tester, {Size size = phone}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(BarqDriverApp(deps: deps));
    await settle(tester);
  }
}

const phone = Size(390, 844);
