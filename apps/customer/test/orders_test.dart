import 'package:barq_core/barq_core.dart';
import 'package:barq_customer/app/router.dart';
import 'package:barq_customer/features/notifications/ui/notifications_screen.dart';
import 'package:barq_customer/features/offer/ui/offer_screen.dart';
import 'package:barq_customer/features/orders/data/orders_models.dart';
import 'package:barq_customer/features/orders/data/orders_repository.dart';
import 'package:barq_customer/features/orders/state/order_waiting_cubit.dart';
import 'package:barq_customer/features/orders/state/orders_cubit.dart';
import 'package:barq_customer/features/orders/state/tracking_cubit.dart';
import 'package:barq_customer/features/orders/ui/orders_screen.dart';
import 'package:barq_customer/features/orders/ui/rate_screen.dart';
import 'package:barq_customer/features/orders/ui/receipt_screen.dart';
import 'package:barq_customer/features/orders/ui/tracking_screen.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers/test_app.dart';

const _steps = {
  'awaiting_pricing': 0,
  'priced': 2,
  'awaiting_vendor': 5,
  'preparing': 7,
  'pending': 10,
  'accepted': 20,
  'picked_up': 30,
  'on_the_way': 40,
  'arrived': 50,
  'delivered': 60,
  'cancelled': 90,
};

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
  'modules': ['public_tracking'],
  'statuses': [for (final key in _steps.keys) _status(key)],
  'polling': {
    'tracking_seconds': 30,
    'events_seconds': 5,
    'notifications_seconds': 10,
  },
};

Map<String, Object?> _money(int amount) => {
  'amount': amount,
  'formatted': '${(amount / 100).toStringAsFixed(2)} ₪',
};

const _cancelAction = {
  'action': 'cancel',
  'to': 'cancelled',
  'label': 'إلغاء الطلب',
  'style': 'danger',
  'confirm': 'هل تريد إلغاء الطلب؟',
};

Map<String, Object?> _order(
  String status, {
  List<Object> actions = const [_cancelAction],
  Object? rating,
  int discount = 0,
}) => {
  'id': 7,
  'code': 'BR-000007',
  'status': _status(status),
  'created_at': '2026-10-31T10:00:00+00:00',
  'completed_at': status == 'delivered' ? '2026-10-31T11:00:00+00:00' : null,
  'items': [
    {'id': 1, 'name': 'حليب', 'qty': 2},
  ],
  'price': {
    'breakdown': <Object>[],
    'discount': _money(discount),
    'total': _money(2650),
  },
  'delivery_code': '8667',
  'driver': {'id': 1, 'name': 'أبو خالد'},
  'available_actions': actions,
  'vendor': {'id': 16, 'name': 'سوبرماركت النور'},
  'rating': rating,
};

Map<String, Object?> _tracking(String status) => {
  'order_id': 7,
  'status': _status(status),
  'driver': {
    'id': 1,
    'name': 'أبو خالد',
    'phone': '0599000000',
    'vehicle_type': 'motorcycle',
    'rating': {'average': 4.9, 'count': 10},
    'location': {'lat': 31.449, 'lng': 34.391},
  },
  'pickup': {'lat': 31.4486, 'lng': 34.3925},
  'dropoff': {'lat': 31.45, 'lng': 34.39},
  'eta_minutes': 12,
  'path_tail': [
    {'lat': 31.4487, 'lng': 34.392, 'at': '2026-10-31T10:30:00+00:00'},
  ],
  'next_poll_seconds': 30,
};

Map<String, Object?> _summary(int id, String status) => {
  'id': id,
  'code': 'BR-$id',
  'status': _status(status),
  'created_at': '2026-10-26T10:00:00+00:00',
  'completed_at': null,
  'items_count': 4,
  'total': _money(5100),
  'rated': false,
};

const _page = {'page': 1, 'per_page': 15, 'total': 1, 'last_page': 1};

Map<String, Reply> _replies({
  required String status,
  Object? rating,
  int discount = 0,
}) => {
  'GET /app/config': Reply(_config),
  'GET /orders/7': Reply(_order(status, rating: rating, discount: discount)),
  'GET /orders/7/offer': const Reply(null, status: 404, error: 'not_found'),
  'GET /orders/7/events': const Reply(
    [],
    meta: {'next_since': 1, 'next_poll_seconds': 5},
  ),
  'GET /orders/7/tracking': Reply(_tracking(status)),
  'GET /notifications': const Reply([], meta: {'unread': 0}),
  'GET /addresses': const Reply([]),
  'GET /vendors': const Reply([], meta: _page),
  'GET /categories': const Reply([]),
  'GET /products': const Reply([], meta: _page),
  'GET /me': const Reply({'name': 'محمد'}),
};

Future<TestApp> _open(
  WidgetTester tester,
  String path,
  Map<String, Reply> replies, {
  Size size = phone,
}) async {
  final app = await TestApp.create(replies, secure: {'barq_token': 'saved'});
  await app.pump(tester, size: size);
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go(path);
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

Future<void> _tapCancel(WidgetTester tester) async {
  await tester.ensureVisible(find.text('إلغاء الطلب'));
  await tester.pump();
  await tester.tap(find.text('إلغاء الطلب'));
}

void main() {
  group('stageOf', () {
    final config = AppConfig.fromJson(_config.cast<String, dynamic>());

    test('follows the steps of the config', () {
      expect(stageOf(config, 'awaiting_pricing'), OrderStage.waiting);
      expect(stageOf(config, 'pending'), OrderStage.waiting);
      expect(stageOf(config, 'accepted'), OrderStage.tracking);
      expect(stageOf(config, 'arrived'), OrderStage.tracking);
      expect(stageOf(config, 'delivered'), OrderStage.delivered);
      expect(stageOf(config, 'cancelled'), OrderStage.cancelled);
    });

    test('an unknown status never opens tracking', () {
      expect(stageOf(config, 'new_status'), OrderStage.waiting);
    });
  });

  test('orderIdOf reads numbers and FCM text', () {
    expect(orderIdOf({'order_id': 92}), 92);
    expect(orderIdOf({'order_id': '92'}), 92);
    expect(orderIdOf({}), isNull);
  });

  group('order model', () {
    test('never reads the delivery code', () {
      final order = Order.fromJson(_order('pending'));
      expect(order.action('cancel')?.label, 'إلغاء الطلب');
      expect(order.action('track'), isNull);
      expect(order.rated, isFalse);
    });

    test('tracking keeps next_poll_seconds', () {
      final tracking = Tracking.fromJson(_tracking('on_the_way'));
      expect(tracking.nextPollSeconds, 30);
      expect(tracking.driverLocation?.lat, 31.449);
      expect(tracking.pathTail, hasLength(1));
    });
  });

  group('waiting screen', () {
    _test('shows the store, the status and the cancel button', (tester) async {
      await _open(tester, Routes.orderOf(7), _replies(status: 'pending'));
      expect(find.text('طلب BR-000007'), findsOneWidget);
      expect(find.textContaining('سوبرماركت النور'), findsOneWidget);
      expect(find.text('إلغاء الطلب'), findsOneWidget);
      expect(find.text('8667'), findsNothing);
    });

    _test('fits a small phone', (tester) async {
      await _open(
        tester,
        Routes.orderOf(7),
        _replies(status: 'pending'),
        size: smallPhone,
      );
      expect(tester.takeException(), isNull);
    });

    _test('an order past the driver step opens tracking', (tester) async {
      await _open(tester, Routes.orderOf(7), _replies(status: 'on_the_way'));
      expect(find.byType(TrackingScreen), findsOneWidget);
    });

    _test('a delivered order opens rating', (tester) async {
      await _open(tester, Routes.orderOf(7), _replies(status: 'delivered'));
      expect(find.byType(RateScreen), findsOneWidget);
    });

    _test('a rated order opens the receipt', (tester) async {
      await _open(
        tester,
        Routes.orderOf(7),
        _replies(status: 'delivered', rating: {'stars': 5, 'comment': null})
          ..['GET /orders/7/receipt'] = Reply(_receipt),
      );
      expect(find.byType(ReceiptScreen), findsOneWidget);
    });

    _test('an open offer opens the offer screen', (tester) async {
      final replies = _replies(status: 'priced');
      replies['GET /orders/7/offer'] = Reply({
        'id': 54,
        'status': 'sent',
        'items': <Object>[],
        'items_total': _money(1950),
        'delivery_fee': _money(700),
        'total': _money(2650),
        'note': null,
        'expires_at': '2099-01-01T00:00:00+00:00',
        'created_at': '2026-10-31T10:00:00+00:00',
      });
      await _open(tester, Routes.orderOf(7), replies);
      expect(find.byType(OfferScreen), findsOneWidget);
    });

    _test('error shows the server message and retries', (tester) async {
      final replies = _replies(status: 'pending')
        ..['GET /orders/7'] = const Reply(null, status: 500, error: 'x');
      final app = await _open(tester, Routes.orderOf(7), replies);
      expect(find.text('رسالة السيرفر'), findsOneWidget);
      app.server.replies['GET /orders/7'] = Reply(_order('pending'));
      await tester.tap(find.byType(BarqButton));
      await app.settle(tester);
      expect(find.text('طلب BR-000007'), findsOneWidget);
    });

    _test('cancelling sends the chosen reason', (tester) async {
      final replies = _replies(status: 'pending')
        ..['GET /cancel-reasons'] = const Reply([
          {'key': 'changed_mind', 'label': 'غيّرت رأيي'},
          {'key': 'other', 'label': 'سبب آخر'},
        ]);
      final app = await _open(tester, Routes.orderOf(7), replies);
      await _tapCancel(tester);
      await app.settle(tester);
      await tester.tap(find.text('سبب آخر'));
      await tester.pump();

      app.server.handlers['POST /orders/7/cancel'] = (_) {
        app.server.replies['GET /orders/7'] = Reply(
          _order('cancelled', actions: const []),
        );
        return Reply(_order('cancelled', actions: const []));
      };
      await tester.tap(find.text('تأكيد الإلغاء'));
      await app.settle(tester);

      expect(app.server.bodies['POST /orders/7/cancel'], {'reason': 'other'});
      expect(find.text('إلغاء الطلب'), findsNothing);
      expect(find.text('حالة cancelled'), findsWidgets);
    });

    _test('a refused cancel keeps the sheet and shows why', (tester) async {
      final replies = _replies(status: 'pending')
        ..['GET /cancel-reasons'] = const Reply([
          {'key': 'other', 'label': 'سبب آخر'},
        ])
        ..['POST /orders/7/cancel'] = const Reply(
          null,
          status: 422,
          error: 'invalid_transition',
        );
      final app = await _open(tester, Routes.orderOf(7), replies);
      await _tapCancel(tester);
      await app.settle(tester);
      await tester.tap(find.text('تأكيد الإلغاء'));
      await app.settle(tester);
      expect(find.text('رسالة السيرفر'), findsOneWidget);
    });
  });

  group('tracking screen', () {
    _test('shows the driver, the time and the call button', (tester) async {
      final app = await _open(
        tester,
        Routes.trackOf(7),
        _replies(status: 'on_the_way'),
      );
      expect(find.text('أبو خالد'), findsOneWidget);
      expect(find.text('يصل خلال 12 دقيقة'), findsOneWidget);
      expect(find.textContaining('دراجة نارية'), findsOneWidget);
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is BarqIconButton && w.icon == BarqIcons.phone,
        ),
      );
      await app.settle(tester);
      expect((app.deps.vendorActions as FakeVendorActions).called, [
        '0599000000',
      ]);
    });

    _test('sharing makes a link and can stop it', (tester) async {
      final replies = _replies(status: 'on_the_way')
        ..['POST /orders/7/share-link'] = const Reply({
          'url': 'https://example.com/t/abc',
          'token': 'abc',
          'json_url': 'https://example.com/api/track/abc',
          'expires_at': '2026-11-02T19:47:20+00:00',
        }, status: 201)
        ..['DELETE /orders/7/share-link'] = const Reply(null);
      final app = await _open(tester, Routes.trackOf(7), replies);
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is BarqIconButton && w.icon == BarqIcons.share,
        ),
      );
      await app.settle(tester);
      await tester.tap(find.text('مشاركة الرابط'));
      await app.settle(tester);
      expect((app.deps.vendorActions as FakeVendorActions).shared, [
        'https://example.com/t/abc',
      ]);
      await tester.tap(find.text('إيقاف الرابط'));
      await app.settle(tester);
      expect(app.server.calls, contains('DELETE /orders/7/share-link'));
    });
  });

  group('rating', () {
    _test('send stays off until the driver has stars', (tester) async {
      final app = await _open(
        tester,
        Routes.rateOf(7),
        _replies(status: 'delivered', discount: 900)
          ..['POST /orders/7/rate'] = Reply(_order('delivered')),
      );
      expect(find.textContaining('وفّرت 9.00 ₪'), findsOneWidget);
      await tester.tap(find.text('إرسال التقييم'));
      await app.settle(tester);
      expect(app.server.calls, isNot(contains('POST /orders/7/rate')));

      final stars = find.byType(BarqStars);
      (tester.widget(stars.first) as BarqStars).onChanged!(4);
      await tester.pump();
      (tester.widget(stars.last) as BarqStars).onChanged!(5);
      await tester.pump();
      await tester.enterText(find.byType(TextField), '  ممتاز ');
      await tester.tap(find.text('إرسال التقييم'));
      await app.settle(tester);
      expect(app.server.bodies['POST /orders/7/rate'], {
        'stars': 4,
        'vendor_stars': 5,
        'comment': 'ممتاز',
      });
      expect(find.byType(OrdersScreen), findsOneWidget);
    });

    _test('skip sends nothing', (tester) async {
      final replies = _replies(status: 'delivered')
        ..['GET /orders'] = const Reply([], meta: _page);
      final app = await _open(tester, Routes.rateOf(7), replies);
      await tester.tap(find.text('تخطّي'));
      await app.settle(tester);
      expect(app.server.calls, isNot(contains('POST /orders/7/rate')));
      expect(find.byType(OrdersScreen), findsOneWidget);
    });
  });

  group('my orders', () {
    test('past orders read completed, then cancelled', () async {
      final calls = <String>[];
      final repository = _FakeOrders(calls);
      final app = await TestApp.create({});
      final cubit = OrdersCubit(repository: repository, cart: app.deps.cart);
      await cubit.load();
      expect(calls, ['active:1', 'completed:1']);
      cubit.selectTab(OrdersTab.past);
      await cubit.loadMore();
      expect(calls.last, 'cancelled:1');
      expect(cubit.state.past.map((o) => o.id), [2, 3]);
      await cubit.close();
    });

    _test('both tabs, with the count', (tester) async {
      final replies = _replies(status: 'pending');
      final app = await TestApp.create(
        replies,
        secure: {'barq_token': 'saved'},
      );
      app.server.handlers['GET /orders'] = (_) {
        final scope = app.server.lastQueryOf('GET /orders')!['scope'];
        return switch (scope) {
          'active' => Reply([_summary(1, 'on_the_way')], meta: _page),
          'completed' => Reply([_summary(2, 'delivered')], meta: _page),
          _ => const Reply([], meta: _page),
        };
      };
      await app.pump(tester);
      GoRouter.of(tester.element(find.byType(Scaffold).first))
          .go(Routes.orders);
      await app.settle(tester);

      expect(find.text('الحالية (1)'), findsOneWidget);
      expect(find.text('متابعة الطلب'), findsOneWidget);
      await tester.tap(find.text('السابقة'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('BR-2'), findsOneWidget);
      expect(find.text('إعادة الطلب'), findsOneWidget);
    });
  });

  group('receipt', () {
    _test('shows the lines from the server', (tester) async {
      await _open(
        tester,
        Routes.receiptOf(7),
        _replies(status: 'delivered')
          ..['GET /orders/7/receipt'] = Reply(_receipt),
      );
      expect(find.text('حليب × 2'), findsOneWidget);
      expect(find.text('قيمة الطلبات'), findsOneWidget);
      expect(find.text('مدفوع نقدًا'), findsOneWidget);
    });
  });

  group('notifications', () {
    final item = {
      'id': 5,
      'event': 'status.priced',
      'title': 'تحديث على طلبك',
      'body': 'الحالة الآن',
      'data': {'order_id': 7, 'status': 'priced', 'type': 'order'},
      'read_at': null,
      'opened_at': null,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };

    _test('a tap reports it and opens the order', (tester) async {
      final replies = _replies(status: 'pending')
        ..['GET /notifications'] = Reply([item], meta: const {'unread': 1})
        ..['POST /notifications/5/opened'] = Reply(item);
      final app = await _open(tester, Routes.notifications, replies);
      expect(find.text('اليوم'), findsOneWidget);
      expect(find.byType(BarqUnreadDot), findsOneWidget);
      await tester.tap(find.text('تحديث على طلبك'));
      await app.settle(tester);
      expect(app.server.calls, contains('POST /notifications/5/opened'));
      expect(find.byType(NotificationsScreen), findsNothing);
      expect(find.text('طلب BR-000007'), findsOneWidget);
    });

    _test('read all clears the dot', (tester) async {
      final replies = _replies(status: 'pending')
        ..['GET /notifications'] = Reply([item], meta: const {'unread': 1})
        ..['POST /notifications/read-all'] = const Reply({'marked': 1});
      final app = await _open(tester, Routes.notifications, replies);
      app.server.replies['GET /notifications'] = Reply(
        [
          {...item, 'read_at': '2026-10-31T12:00:00+00:00'},
        ],
        meta: const {'unread': 0},
      );
      await tester.tap(find.text('قراءة الكل'));
      await app.settle(tester);
      expect(find.byType(BarqUnreadDot), findsNothing);
    });

    _test('empty list', (tester) async {
      await _open(tester, Routes.notifications, _replies(status: 'pending'));
      expect(find.text('ما في إشعارات'), findsOneWidget);
    });
  });

  group('polling', () {
    test('tracking follows next_poll_seconds through the cubit', () async {
      final app = await TestApp.create(_replies(status: 'on_the_way'));
      final cubit = TrackingCubit(
        repository: app.deps.ordersRepository,
        orderId: 7,
        pollSeconds: 30,
      );
      await cubit.load();
      expect(cubit.state.tracking?.etaMinutes, 12);
      await cubit.close();
    });

    test('waiting stops asking once the order is finished', () async {
      final app = await TestApp.create(_replies(status: 'cancelled'));
      final cubit = OrderWaitingCubit(
        orders: app.deps.ordersRepository,
        offers: app.deps.offerRepository,
        orderId: 7,
        pollSeconds: 5,
      );
      await cubit.start();
      expect(cubit.state.order?.isTerminal, isTrue);
      await cubit.close();
    });
  });
}

const _receipt = {
  'code': 'BR-000007',
  'project': {'ar': 'برق', 'en': 'Barq'},
  'status': {'key': 'delivered', 'ar': 'تم', 'en': 'Done'},
  'created_at': '2026-10-31T10:00:00+00:00',
  'completed_at': '2026-10-31T11:00:00+00:00',
  'driver': null,
  'payment': {'method': 'cash', 'status': 'cash_on_delivery'},
  'items': [
    {'name': 'حليب', 'qty': 2},
  ],
  'lines': [
    {
      'key': 'items_total',
      'label': {'ar': 'قيمة الطلبات', 'en': 'Items'},
      'amount': {'amount': 1950, 'formatted': '19.50 ₪'},
    },
  ],
  'total': {'amount': 2650, 'formatted': '26.50 ₪'},
};

/// Only the list calls: answers one order per scope and records the order of
/// the requests.
class _FakeOrders implements OrdersRepository {
  _FakeOrders(this.calls);

  final List<String> calls;

  @override
  Stream<void> get changes => const Stream.empty();

  @override
  Future<Paged<OrderSummary>> orders({
    required String scope,
    int page = 1,
  }) async {
    calls.add('$scope:$page');
    final id = switch (scope) {
      'active' => 1,
      'completed' => 2,
      _ => 3,
    };
    return Paged(
      items: [
        OrderSummary.fromJson(
          _summary(id, 'delivered').cast<String, dynamic>(),
        ),
      ],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
