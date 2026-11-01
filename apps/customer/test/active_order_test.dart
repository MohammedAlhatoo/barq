import 'package:barq_customer/app/router.dart';
import 'package:barq_customer/features/offer/ui/offer_screen.dart';
import 'package:barq_customer/features/orders/ui/order_waiting_screen.dart';
import 'package:barq_customer/features/orders/ui/tracking_screen.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers/test_app.dart';

const _steps = {
  'awaiting_pricing': 0,
  'priced': 2,
  'pending': 10,
  'accepted': 20,
  'on_the_way': 40,
  'arrived': 50,
  'delivered': 60,
  'picked_up': 30,
  'cancelled': 90,
};

const _offerHint = 'وصلك عرض السعر';
const _waitingHint = 'رح نخبرك بكل جديد';
const _trackingHint = 'تابع طلبك على الخريطة';

Map<String, Object?> _status(String key) => {
  'key': key,
  'label': 'حالة $key',
  'color': '#F59E0B',
  'icon': 'bike',
  'step': _steps[key],
  'is_terminal': key == 'delivered' || key == 'cancelled',
};

final _config = <String, Object?>{
  ...configJson,
  'statuses': [for (final key in _steps.keys) _status(key)],
  'polling': {'events_seconds': 5, 'notifications_seconds': 10},
};

Map<String, Object?> _money(int amount) => {
  'amount': amount,
  'formatted': '${(amount / 100).toStringAsFixed(2)} ₪',
};

Map<String, Object?> _summary(int id, String status, {int day = 26}) => {
  'id': id,
  'code': 'BR-$id',
  'status': _status(status),
  'created_at': '2026-10-${day}T10:00:00+00:00',
  'completed_at': null,
  'items_count': 4,
  'total': _money(5100),
  'rated': false,
};

Reply _active(List<Object> orders, {int? total}) => Reply(
  orders,
  meta: {
    'page': 1,
    'per_page': 15,
    'total': total ?? orders.length,
    'last_page': 1,
  },
);

Map<String, Object?> _order(int id, String status) => {
  'id': id,
  'code': 'BR-$id',
  'status': _status(status),
  'created_at': '2026-10-26T10:00:00+00:00',
  'completed_at': null,
  'items': [
    {'id': 1, 'name': 'حليب', 'qty': 2},
  ],
  'price': {
    'breakdown': <Object>[],
    'discount': _money(0),
    'total': _money(2650),
  },
  'driver': null,
  'available_actions': <Object>[],
  'vendor': {'id': 16, 'name': 'سوبرماركت النور'},
  'rating': null,
};

Map<String, Object?> _offer(int orderId, {String status = 'sent'}) {
  final now = DateTime.now();
  return {
    'id': 48,
    'order_id': orderId,
    'status': status,
    'items': <Object>[],
    'items_total': _money(9300),
    'delivery_fee': _money(700),
    'total': _money(10000),
    'note': null,
    'expires_at': now.add(const Duration(minutes: 30)).toIso8601String(),
    'created_at': now.subtract(const Duration(minutes: 30)).toIso8601String(),
  };
}

const _noOffer = Reply(null, status: 404, error: 'not_found');

Map<String, Reply> _replies(Reply active) => {
  'GET /app/config': Reply(_config),
  'GET /orders': active,
  'GET /notifications': const Reply([], meta: {'unread': 0}),
  'GET /addresses': const Reply([]),
  'GET /vendors': const Reply(
    [],
    meta: {'page': 1, 'per_page': 15, 'total': 0, 'last_page': 1},
  ),
  'GET /categories': const Reply([]),
  'GET /products': const Reply(
    [],
    meta: {'page': 1, 'per_page': 15, 'total': 0, 'last_page': 1},
  ),
  'GET /me': const Reply({'name': 'محمد'}),
};

Future<TestApp> _open(
  WidgetTester tester,
  Map<String, Reply> replies, {
  Size size = phone,
}) async {
  final app = await TestApp.create(replies, secure: {'barq_token': 'saved'});
  await app.pump(tester, size: size);
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go(Routes.home);
  await app.settle(tester);
  return app;
}

/// Closes the screens, so their polling stops.
void _test(String name, Future<void> Function(WidgetTester) body) =>
    testWidgets(name, (tester) async {
      await body(tester);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

/// The phone leaves the app and comes back.
void _background(WidgetTester tester) {
  for (final state in [
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
  }
}

void _resume(WidgetTester tester) {
  for (final state in [
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
  }
}

int _calls(TestApp app) =>
    app.server.calls.where((call) => call == 'GET /orders').length;

void main() {
  group('the bar', () {
    _test('stays hidden with no running order', (tester) async {
      final app = await _open(tester, _replies(_active([])));

      expect(find.byType(BarqActiveOrderBar), findsNothing);
      expect(app.server.lastQueryOf('GET /orders')!['scope'], 'active');
    });

    _test('stays hidden when the list fails', (tester) async {
      await _open(tester, _replies(const Reply(null, status: 500, error: 'x')));

      expect(find.byType(BarqActiveOrderBar), findsNothing);
    });

    _test('shows the code, the status and a hint', (tester) async {
      await _open(tester, _replies(_active([_summary(7, 'pending')])));

      expect(find.byType(BarqActiveOrderBar), findsOneWidget);
      expect(find.text('BR-7'), findsOneWidget);
      expect(find.text('حالة pending'), findsOneWidget);
      expect(find.text(_waitingHint), findsOneWidget);
      expect(find.textContaining('+'), findsNothing);
    });

    _test('says tracking once a driver has the order', (tester) async {
      await _open(tester, _replies(_active([_summary(7, 'on_the_way')])));

      expect(find.text(_trackingHint), findsOneWidget);
    });

    _test('shows the latest order and +N', (tester) async {
      await _open(
        tester,
        _replies(
          _active([
            _summary(5, 'pending', day: 20),
            _summary(9, 'accepted', day: 28),
            _summary(7, 'pending', day: 26),
          ], total: 4),
        ),
      );

      expect(find.text('BR-9'), findsOneWidget);
      expect(find.text('BR-5'), findsNothing);
      expect(find.text('+3'), findsOneWidget);
    });

    _test('fits a small phone with a long status', (tester) async {
      await _open(
        tester,
        _replies(
          _active([
            _summary(1234567890, 'awaiting_pricing'),
            _summary(2, 'pending'),
          ]),
        ),
        size: smallPhone,
      );

      expect(find.byType(BarqActiveOrderBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    _test('leaves the retry button of a failed home free', (tester) async {
      await _open(tester, {
        ..._replies(_active([_summary(7, 'pending')])),
        'GET /products': const Reply(null, status: 500, error: 'x'),
      }, size: smallPhone);

      final retry = tester.getRect(find.text('إعادة المحاولة'));
      final bar = tester.getRect(find.byType(BarqActiveOrderBar));
      expect(retry.bottom, lessThan(bar.top));
    });

    _test('stands clear of the nav bar and the cart button', (tester) async {
      await _open(tester, _replies(_active([_summary(7, 'pending')])));

      final bar = tester.getRect(find.byType(BarqActiveOrderBar));
      final nav = tester.getRect(find.byType(BarqNavBar));
      const fabRise = 36;
      expect(bar.bottom, lessThan(nav.top - fabRise));
    });
  });

  group('offer', () {
    _test('an open offer shows its message', (tester) async {
      await _open(tester, {
        ..._replies(_active([_summary(7, 'priced')])),
        'GET /orders/7/offer': Reply(_offer(7)),
      });

      expect(find.text(_offerHint), findsOneWidget);
      final bar = tester.widget<BarqActiveOrderBar>(
        find.byType(BarqActiveOrderBar),
      );
      expect(bar.highlighted, isTrue);
    });

    _test('an expired offer does not', (tester) async {
      await _open(tester, {
        ..._replies(_active([_summary(7, 'priced')])),
        'GET /orders/7/offer': Reply(_offer(7, status: 'expired')),
      });

      expect(find.text('BR-7'), findsOneWidget);
      expect(find.text(_offerHint), findsNothing);
      expect(find.text(_waitingHint), findsOneWidget);
    });

    _test('goes before a newer order, as it has a deadline', (tester) async {
      await _open(tester, {
        ..._replies(
          _active([
            _summary(9, 'pending', day: 28),
            _summary(5, 'priced', day: 20),
          ]),
        ),
        'GET /orders/5/offer': Reply(_offer(5)),
      });

      expect(find.text('BR-5'), findsOneWidget);
      expect(find.text(_offerHint), findsOneWidget);
      expect(find.text('+1'), findsOneWidget);
    });

    _test('appears by polling, with no action from the customer', (
      tester,
    ) async {
      final app = await _open(tester, {
        ..._replies(_active([_summary(7, 'awaiting_pricing')])),
        'GET /orders/7/offer': Reply(_offer(7)),
      });
      expect(find.text(_offerHint), findsNothing);

      app.server.replies['GET /orders'] = _active([_summary(7, 'priced')]);
      await tester.pump(const Duration(seconds: 10));
      await app.settle(tester);

      expect(find.text(_offerHint), findsOneWidget);
    });
  });

  group('refresh', () {
    _test('checks again when the app resumes', (tester) async {
      final app = await _open(tester, _replies(_active([])));
      expect(find.byType(BarqActiveOrderBar), findsNothing);

      _background(tester);
      app.server.replies['GET /orders'] = _active([_summary(7, 'pending')]);
      final before = _calls(app);
      await tester.pump(const Duration(seconds: 30));
      await app.settle(tester);
      expect(_calls(app), before, reason: 'no polling in the background');

      _resume(tester);
      await app.settle(tester);

      expect(_calls(app), greaterThan(before));
      expect(find.text('BR-7'), findsOneWidget);
    });

    _test('hides when the last order ends', (tester) async {
      final app = await _open(
        tester,
        _replies(_active([_summary(7, 'pending')])),
      );
      expect(find.byType(BarqActiveOrderBar), findsOneWidget);

      app.server.replies['GET /orders'] = _active([]);
      app.deps.ordersRepository.ordersChanged();
      await app.settle(tester);

      expect(find.byType(BarqActiveOrderBar), findsNothing);
    });

    _test('a failed check keeps the bar', (tester) async {
      final app = await _open(
        tester,
        _replies(_active([_summary(7, 'pending')])),
      );

      app.server.replies['GET /orders'] = const Reply(
        null,
        status: 500,
        error: 'x',
      );
      app.deps.ordersRepository.ordersChanged();
      await app.settle(tester);

      expect(find.text('BR-7'), findsOneWidget);
    });
  });

  group('tapping', () {
    _test('opens the waiting screen', (tester) async {
      final app = await _open(tester, {
        ..._replies(_active([_summary(7, 'pending')])),
        'GET /orders/7': Reply(_order(7, 'pending')),
        'GET /orders/7/offer': _noOffer,
        'GET /orders/7/events': const Reply([], meta: {'next_since': 1}),
      });

      await tester.tap(find.byType(BarqActiveOrderBar));
      await app.settle(tester);

      expect(find.byType(OrderWaitingScreen), findsOneWidget);
    });

    _test('opens tracking', (tester) async {
      final app = await _open(tester, {
        ..._replies(_active([_summary(7, 'accepted')])),
        'GET /orders/7': Reply(_order(7, 'accepted')),
        'GET /orders/7/offer': _noOffer,
        'GET /orders/7/events': const Reply([], meta: {'next_since': 1}),
        'GET /orders/7/tracking': Reply({
          'order_id': 7,
          'status': _status('accepted'),
          'driver': null,
          'pickup': {'lat': 31.4486, 'lng': 34.3925},
          'dropoff': {'lat': 31.45, 'lng': 34.39},
          'eta_minutes': 12,
          'path_tail': <Object>[],
          'next_poll_seconds': 30,
        }),
      });

      await tester.tap(find.byType(BarqActiveOrderBar));
      await app.settle(tester);

      expect(find.byType(TrackingScreen), findsOneWidget);
    });

    _test('opens the offer', (tester) async {
      final app = await _open(tester, {
        ..._replies(_active([_summary(7, 'priced')])),
        'GET /orders/7': Reply(_order(7, 'priced')),
        'GET /orders/7/offer': Reply(_offer(7)),
        'GET /orders/7/events': const Reply([], meta: {'next_since': 1}),
      });

      await tester.tap(find.byType(BarqActiveOrderBar));
      await app.settle(tester);

      expect(find.byType(OfferScreen), findsOneWidget);
    });

    _test('reads the list again on the way back', (tester) async {
      final app = await _open(tester, {
        ..._replies(_active([_summary(7, 'pending')])),
        'GET /orders/7': Reply(_order(7, 'pending')),
        'GET /orders/7/offer': _noOffer,
        'GET /orders/7/events': const Reply([], meta: {'next_since': 1}),
      });
      await tester.tap(find.byType(BarqActiveOrderBar));
      await app.settle(tester);

      app.server.replies['GET /orders'] = _active([]);
      final router = GoRouter.of(
        tester.element(find.byType(OrderWaitingScreen)),
      );
      router.pop();
      await app.settle(tester);

      expect(find.byType(BarqActiveOrderBar), findsNothing);
    });
  });
}
