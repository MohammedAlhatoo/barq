import 'dart:convert';
import 'dart:typed_data';

import 'package:barq_core/barq_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Answers requests from a function and remembers the last one.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.reply);

  final ResponseBody Function(RequestOptions options) reply;
  RequestOptions? last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return reply(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int status, Object body, {String? etag}) =>
    ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        if (etag != null) 'etag': [etag],
      },
    );

ApiClient _client(AuthStore auth, _FakeAdapter adapter) {
  final dio = Dio()..httpClientAdapter = adapter;
  return ApiClient(authStore: auth, appVersion: '1.0.0', dio: dio);
}

Map<String, dynamic> _status(
  String key,
  int step, {
  bool terminal = false,
  String color = '#F59E0B',
}) => {
  'key': key,
  'label': 'label $key',
  'color': color,
  'icon': 'not_a_barq_icon',
  'step': step,
  'is_terminal': terminal,
};

final _configJson = <String, dynamic>{
  'delivery_confirmation': 'photo',
  'payment_methods': ['cash_on_delivery'],
  'statuses': [
    _status('awaiting_vendor', 5),
    _status('pending', 10),
    _status('accepted', 20),
    _status('on_the_way', 40),
    _status('delivered', 60, terminal: true),
    _status('cancelled', 90, terminal: true),
  ],
  'polling': {'tracking_seconds': 30, 'events_seconds': 5},
  'driver': null,
  'currency': {'code': 'ILS', 'symbol': '₪', 'minor_units': 2},
  'min_app_version': '1.0.0',
  'modules': ['coupons'],
};

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });

  group('ApiClient', () {
    test('returns data and sends the shared headers', () async {
      final auth = AuthStore();
      await auth.save('abc');
      final adapter = _FakeAdapter(
        (_) => _json(200, {
          'success': true,
          'data': {'x': 1},
        }),
      );

      final data = await _client(auth, adapter).get('/thing');

      expect(data, {'x': 1});
      final headers = adapter.last!.headers;
      expect(headers['Authorization'], 'Bearer abc');
      expect(headers['Accept-Language'], 'ar');
      expect(headers['X-App-Version'], '1.0.0');
      expect(headers.containsKey('X-Project-Key'), isTrue);
    });

    test('sends Idempotency-Key on post', () async {
      final adapter = _FakeAdapter((_) => _json(201, {'data': {}}));
      await _client(
        AuthStore(),
        adapter,
      ).post('/orders', body: {}, idempotencyKey: 'k1');
      expect(adapter.last!.headers['Idempotency-Key'], 'k1');
    });

    test('reads a page from meta', () async {
      final adapter = _FakeAdapter(
        (_) => _json(200, {
          'data': [1, 2],
          'meta': {'page': 1, 'per_page': 2, 'last_page': 3, 'total': 6},
        }),
      );
      final page = await _client(AuthStore(), adapter).getPaged('/list');
      expect(page.items, [1, 2]);
      expect(page.nextPage, 2);
      expect(page.total, 6);
    });

    test('turns the error shape into ApiException with hint.ar', () async {
      final adapter = _FakeAdapter(
        (_) => _json(422, {
          'success': false,
          'message': 'fallback',
          'error': {
            'code': 'out_of_zone',
            'details': {'zone': 1},
            'hint': {'ar': 'خارج المنطقة', 'en': 'Out of zone'},
          },
        }),
      );
      await expectLater(
        _client(AuthStore(), adapter).get('/x'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.status, 'status', 422)
              .having((e) => e.code, 'code', 'out_of_zone')
              .having((e) => e.messageAr, 'messageAr', 'خارج المنطقة')
              .having((e) => e.details, 'details', {'zone': 1}),
        ),
      );
    });

    test('falls back to message when there is no hint', () async {
      final adapter = _FakeAdapter(
        (_) => _json(404, {
          'message': 'غير موجود',
          'error': {'code': 'not_found', 'details': null},
        }),
      );
      await expectLater(
        _client(AuthStore(), adapter).get('/x'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.messageAr,
            'messageAr',
            'غير موجود',
          ),
        ),
      );
    });

    test('marks a timeout as a network error', () async {
      final adapter = _FakeAdapter(
        (options) => throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
        ),
      );
      await expectLater(
        _client(AuthStore(), adapter).get('/x'),
        throwsA(
          isA<ApiException>().having((e) => e.isNetwork, 'isNetwork', true),
        ),
      );
    });
  });

  group('AuthStore', () {
    ResponseBody unauthenticated(RequestOptions _) => _json(401, {
      'message': 'unauthenticated',
      'error': {'code': 'unauthenticated', 'details': null},
    });

    test('load restores the saved token', () async {
      await AuthStore().save('abc');
      final auth = AuthStore();
      await auth.load();
      expect(auth.token, 'abc');
      expect(auth.isLoggedIn, isTrue);
    });

    test('401 clears the token and fires sessionExpired', () async {
      final auth = AuthStore();
      await auth.save('abc');
      final expired = expectLater(auth.sessionExpired, emits(null));

      await expectLater(
        _client(auth, _FakeAdapter(unauthenticated)).get('/me'),
        throwsA(isA<ApiException>()),
      );

      await expired;
      expect(auth.token, isNull);
    });

    test('401 without a token does not fire sessionExpired', () async {
      final auth = AuthStore();
      var fired = false;
      auth.sessionExpired.listen((_) => fired = true);

      await expectLater(
        _client(auth, _FakeAdapter(unauthenticated)).post('/driver/login'),
        throwsA(isA<ApiException>()),
      );

      await Future<void>.delayed(Duration.zero);
      expect(fired, isFalse);
    });
  });

  group('AppConfig', () {
    final config = AppConfig.fromJson(_configJson);

    test('reads the fields', () {
      expect(config.deliveryConfirmation, 'photo');
      expect(config.currencySymbol, '₪');
      expect(config.polling.eventsSeconds, 5);
      expect(config.driver, isNull);
      expect(config.hasModule('coupons'), isTrue);
      expect(config.hasModule('other'), isFalse);
    });

    test('parses hex colors and survives unknown keys and icons', () {
      expect(config.status('pending').color, const Color(0xFFF59E0B));
      expect(config.status('pending').barqIcon, 'clock');
      expect(config.status('new_status').label, 'new_status');
    });

    test('maps server icon names to barq_ui icons', () {
      StatusInfo icon(String name) =>
          StatusInfo.fromJson({..._status('x', 1), 'icon': name});
      expect(icon('store').barqIcon, 'store');
      expect(icon('chef-hat').barqIcon, 'package');
      expect(icon('map-pin').barqIcon, 'pin');
    });

    group('timeline', () {
      const keys = ['awaiting_vendor', 'pending', 'on_the_way', 'delivered'];
      int index(String current) =>
          config.timelineIndex(config.timeline(keys, current), current);

      test('shows the given keys in order', () {
        expect(config.timeline(keys, 'pending').map((s) => s.key), keys);
        expect(index('pending'), 1);
      });

      test('a status without a row stays on the row before it', () {
        expect(index('accepted'), 1);
      });

      test('cancelled replaces the last row', () {
        expect(config.timeline(keys, 'cancelled').map((s) => s.key), [
          'awaiting_vendor',
          'pending',
          'on_the_way',
          'cancelled',
        ]);
        expect(index('cancelled'), 3);
      });

      test('the lists hold the five keys of each screen', () {
        expect(OrderTimelines.waiting, hasLength(5));
        expect(OrderTimelines.tracking, hasLength(5));
      });
    });
  });

  group('ConfigStore', () {
    ConfigStore store(_FakeAdapter adapter) => ConfigStore(
      api: _client(AuthStore(), adapter),
      app: BarqAppKind.customer,
    );

    test('caches the config and sends the ETag next time', () async {
      final first = _FakeAdapter(
        (_) => _json(200, {'data': _configJson}, etag: '"v3"'),
      );
      await store(first).load();
      expect(first.last!.queryParameters['app'], 'user');

      final second = _FakeAdapter((_) => ResponseBody.fromString('', 304));
      final cached = store(second);
      await cached.load();

      expect(second.last!.headers['If-None-Match'], '"v3"');
      expect(cached.config.currencySymbol, '₪');
    });

    test('offline with a cache keeps working', () async {
      await store(_FakeAdapter((_) => _json(200, {'data': _configJson})))
          .load();
      final offline = store(
        _FakeAdapter(
          (options) => throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
          ),
        ),
      );

      await offline.load();

      expect(offline.isLoaded, isTrue);
    });

    test('maintenance still throws when a cache exists', () async {
      await store(_FakeAdapter((_) => _json(200, {'data': _configJson})))
          .load();
      final down = store(
        _FakeAdapter(
          (_) => _json(503, {
            'message': 'صيانة',
            'error': {'code': 'maintenance', 'details': null},
          }),
        ),
      );

      await expectLater(
        down.load(),
        throwsA(
          isA<ApiException>().having((e) => e.code, 'code', 'maintenance'),
        ),
      );
    });
  });

  test('Money reads amount and formatted', () {
    final money = Money.fromJson({'amount': 890, 'formatted': '8.90 ₪'});
    expect(money.amount, 890);
    expect(money.formatted, '8.90 ₪');
  });

  group('Poller', () {
    testWidgets('uses next_poll_seconds and enforces the minimum', (
      tester,
    ) async {
      final next = <int?>[20, 1, null];
      var ticks = 0;
      final poller = Poller(
        defaultSeconds: 10,
        tick: () async {
          ticks++;
          return next.removeAt(0);
        },
      )..start();

      await tester.pump(const Duration(seconds: 9));
      expect(ticks, 0);
      await tester.pump(const Duration(seconds: 1));
      expect(ticks, 1);
      await tester.pump(const Duration(seconds: 20));
      expect(ticks, 2);
      await tester.pump(const Duration(seconds: 4));
      expect(ticks, 2);
      await tester.pump(const Duration(seconds: 1));
      expect(ticks, 3);

      poller.stop();
      await tester.pump(const Duration(seconds: 60));
      expect(ticks, 3);
    });

    testWidgets('keeps going after a failed tick', (tester) async {
      var ticks = 0;
      final poller = Poller(
        defaultSeconds: 5,
        tick: () async {
          ticks++;
          throw const ApiException(status: 0, code: 'x', messageAr: 'x');
        },
      )..start();

      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(seconds: 5));
      expect(ticks, 2);
      poller.stop();
    });

    testWidgets('pauses in the background and ticks on return', (tester) async {
      var ticks = 0;
      final poller = Poller(
        defaultSeconds: 5,
        tick: () async {
          ticks++;
          return null;
        },
      )..start();

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      await tester.pump(const Duration(seconds: 30));
      expect(ticks, 0);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(ticks, 1);
      poller.stop();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    });
  });

  testWidgets('status widgets show server labels', (tester) async {
    final store = ConfigStore(
      api: _client(
        AuthStore(),
        _FakeAdapter((_) => _json(200, {'data': _configJson})),
      ),
      app: BarqAppKind.customer,
    );
    await tester.runAsync(store.load);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConfigScope(
            store: store,
            child: const Column(
              children: [
                OrderStatusPill('on_the_way'),
                OrderStatusTimeline(
                  keys: ['accepted', 'on_the_way', 'delivered'],
                  current: 'accepted',
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('label on_the_way'), findsNWidgets(2));
    expect(find.text('label accepted'), findsOneWidget);
    expect(find.text('label cancelled'), findsNothing);
  });
}
