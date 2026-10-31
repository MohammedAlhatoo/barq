import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:barq_core/barq_core.dart';
import 'package:barq_customer/app/app.dart';
import 'package:barq_customer/app/di.dart';
import 'package:barq_customer/app/locale_cubit.dart';
import 'package:barq_customer/features/auth/data/auth_repository.dart';
import 'package:barq_customer/features/auth/data/location_repository.dart';
import 'package:barq_customer/features/system/state/system_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One server answer. [error] makes it the standard failure shape.
class Reply {
  const Reply(this.data, {this.status = 200, this.error});

  final Object? data;
  final int status;
  final String? error;
}

/// Plays the server: maps "POST /auth/send-otp" to a [Reply].
class FakeServer implements HttpClientAdapter {
  FakeServer(this.replies);

  final Map<String, Reply> replies;
  final List<String> calls = [];
  final Map<String, Object?> bodies = {};

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
    final reply = replies[key] ?? const Reply(null, status: 500, error: 'x');
    final code = reply.error;
    final body = code == null
        ? {'success': true, 'message': 'ok', 'data': reply.data}
        : {
            'success': false,
            'message': 'failed',
            'error': {
              'code': code,
              'details': null,
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
  bool online = true;

  @override
  Future<bool> isOnline() async => online;

  @override
  Stream<bool> get onlineChanges => controller.stream;
}

class FakeLocation implements LocationRepository {
  LocationException? failure;

  @override
  Future<({double lat, double lng})> current() async {
    final problem = failure;
    if (problem != null) throw problem;
    return (lat: 31.45, lng: 34.39);
  }
}

const configJson = {
  'project': {'support_phone': '0592525487'},
  'delivery_confirmation': 'photo',
  'payment_methods': ['cash_on_delivery'],
  'statuses': <Object>[],
  'polling': <String, Object>{},
  'currency': {'symbol': '₪'},
  'min_app_version': '1.0.0',
  'modules': <String>[],
  'terms_url': 'https://example.com/terms',
};

const ticketJson = {'phone': '+970599123456', 'expires_in': 60, 'length': 4};

Map<String, Object?> sessionJson({required bool isNew, String? name}) => {
  'token': 'test-token',
  'token_type': 'Bearer',
  'is_new_user': isNew,
  'user': {'name': name},
};

/// A full app with real repositories on top of [FakeServer].
class TestApp {
  TestApp._(this.deps, this.server, this.network, this.location);

  final AppDependencies deps;
  final FakeServer server;
  final FakeNetwork network;
  final FakeLocation location;

  static Future<TestApp> create(
    Map<String, Reply> replies, {
    Map<String, String> secure = const {},
    Map<String, Object> prefs = const {},
    SystemIssue? initial,
  }) async {
    FlutterSecureStorage.setMockInitialValues(Map.of(secure));
    SharedPreferences.setMockInitialValues(prefs);
    final sharedPrefs = await SharedPreferences.getInstance();

    final server = FakeServer(replies);
    final dio = Dio()..httpClientAdapter = server;
    final auth = AuthStore();
    await auth.load();
    final locale = LocaleCubit(sharedPrefs);
    final api = ApiClient(
      authStore: auth,
      appVersion: appVersion,
      language: () => locale.state.languageCode,
      dio: dio,
    );
    final config = ConfigStore(api: api, app: BarqAppKind.customer);
    final network = FakeNetwork();
    final location = FakeLocation();
    final deps = AppDependencies(
      auth: auth,
      api: api,
      config: config,
      push: PushService(api: api, app: BarqAppKind.customer),
      locale: locale,
      system: SystemCubit(
        api: api,
        auth: auth,
        config: config,
        network: network,
        appVersion: appVersion,
        initial: initial,
      ),
      authRepository: ApiAuthRepository(api, sharedPrefs),
      locationRepository: location,
    );
    return TestApp._(deps, server, network, location);
  }

  /// Dio works with real timers, so waits run outside the fake clock.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 15)),
      );
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  Future<void> pump(WidgetTester tester, {Size size = phone}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(BarqCustomerApp(deps: deps));
    await settle(tester);
  }
}

const phone = Size(390, 844);
const smallPhone = Size(360, 640);
