import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:barq_core/barq_core.dart';
import 'package:barq_customer/app/app.dart';
import 'package:barq_customer/app/di.dart';
import 'package:barq_customer/app/locale_cubit.dart';
import 'package:barq_customer/features/account/data/account_repository.dart';
import 'package:barq_customer/features/account/data/avatar_picker.dart';
import 'package:barq_customer/features/account/data/local_session.dart';
import 'package:barq_customer/features/auth/data/auth_repository.dart';
import 'package:barq_customer/features/auth/data/location_repository.dart';
import 'package:barq_customer/features/browse/data/browse_repository.dart';
import 'package:barq_customer/features/browse/data/user_location.dart';
import 'package:barq_customer/features/browse/data/vendor_actions.dart';
import 'package:barq_customer/features/cart/data/cart_repository.dart';
import 'package:barq_customer/features/cart/state/cart_cubit.dart';
import 'package:barq_customer/features/cart/state/shop_scope_cubit.dart';
import 'package:barq_customer/features/checkout/data/checkout_repository.dart';
import 'package:barq_customer/features/notifications/state/unread_cubit.dart';
import 'package:barq_customer/features/offer/data/offer_repository.dart';
import 'package:barq_customer/features/orders/data/orders_repository.dart';
import 'package:barq_customer/features/system/state/system_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One server answer. [error] makes it the standard failure shape.
class Reply {
  const Reply(
    this.data, {
    this.status = 200,
    this.error,
    this.meta,
    this.details,
  });

  final Object? data;
  final int status;
  final String? error;
  final Map<String, Object>? meta;
  final Map<String, Object?>? details;
}

/// Plays the server: maps "POST /auth/send-otp" to a [Reply].
class FakeServer implements HttpClientAdapter {
  FakeServer(this.replies);

  final Map<String, Reply> replies;
  final List<String> calls = [];
  final Map<String, Object?> bodies = {};
  final Map<String, Map<String, dynamic>> queries = {};
  final Map<String, Map<String, dynamic>> headers = {};

  /// For a request whose answer depends on its body. Wins over [replies].
  final Map<String, Reply Function(Object? body)> handlers = {};

  /// True makes every request fail like a dead connection.
  bool offline = false;

  /// The next this many POSTs reach the server, but their answer never returns.
  int lostAnswers = 0;

  Map<String, dynamic>? lastQueryOf(String key) => queries[key];

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
    final lost = lostAnswers > 0 && options.method == 'POST';
    final key = '${options.method} ${Uri.parse(options.path).path}'
        .replaceFirst('/api/v1', '');
    calls.add(key);
    bodies[key] = options.data;
    queries[key] = options.queryParameters;
    headers[key] = options.headers;
    if (lost) {
      lostAnswers--;
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'answer lost',
      );
    }
    final reply =
        handlers[key]?.call(options.data) ??
        replies[key] ??
        const Reply(null, status: 500, error: 'x');
    final code = reply.error;
    final body = code == null
        ? {
            'success': true,
            'message': 'ok',
            'data': reply.data,
            'meta': ?reply.meta,
          }
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
  bool online = true;

  @override
  Future<bool> isOnline() async => online;

  @override
  Stream<bool> get onlineChanges => controller.stream;
}

class FakeLocation implements LocationRepository {
  LocationException? failure;

  /// True is a phone that never gets a GPS fix.
  bool hang = false;

  @override
  Future<({double lat, double lng})> current() async {
    if (hang) return Completer<({double lat, double lng})>().future;
    final problem = failure;
    if (problem != null) throw problem;
    return (lat: 31.45, lng: 34.39);
  }
}

class FakeVendorActions implements VendorActions {
  final List<String> shared = [];
  final List<String> called = [];
  bool canCall = true;

  @override
  Future<void> share(String text) async => shared.add(text);

  @override
  Future<bool> call(String phone) async {
    called.add(phone);
    return canCall;
  }
}

class FakeAvatarPicker implements AvatarPicker {
  File? file;

  @override
  Future<File?> pick() async => file;
}

const configJson = {
  'project': {'support_phone': '0592525487'},
  'delivery_confirmation': 'photo',
  'payment_methods': ['cash_on_delivery'],
  'statuses': <Object>[],
  'polling': <String, Object>{},
  'currency': {'code': 'ILS', 'symbol': '₪', 'minor_units': 100},
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
    final browse = ApiBrowseRepository(api);
    final cart = CartCubit(prefs: sharedPrefs, config: config, browse: browse);
    final orders = ApiOrdersRepository(api);
    final deps = AppDependencies(
      auth: auth,
      api: api,
      config: config,
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
      browseRepository: browse,
      userLocation: UserLocation(browse, location),
      vendorActions: FakeVendorActions(),
      cartRepository: ApiCartRepository(api),
      cart: cart,
      scope: ShopScopeCubit(cart: cart, browse: browse),
      checkoutRepository: ApiCheckoutRepository(api),
      offerRepository: ApiOfferRepository(api),
      ordersRepository: orders,
      unread: UnreadCubit(repository: orders, pollSeconds: () => null),
      accountRepository: ApiAccountRepository(
        api,
        UploadService(api: api),
        LocalSession(auth: auth, cart: cart, prefs: sharedPrefs),
      ),
      avatarPicker: FakeAvatarPicker(),
      prefs: sharedPrefs,
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
