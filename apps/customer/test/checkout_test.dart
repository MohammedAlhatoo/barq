import 'dart:convert';

import 'package:barq_customer/app/countdown.dart';
import 'package:barq_customer/app/router.dart';
import 'package:barq_customer/features/cart/ui/compare_screen.dart';
import 'package:barq_customer/features/cart/ui/widgets/empty_cart_view.dart';
import 'package:barq_customer/features/cart/ui/widgets/out_of_zone_view.dart';
import 'package:barq_customer/features/checkout/ui/checkout_screen.dart';
import 'package:barq_customer/features/offer/ui/offer_screen.dart';
import 'package:barq_customer/features/offer/ui/widgets/offer_expired_view.dart';
import 'package:barq_customer/features/orders/ui/order_waiting_screen.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers/test_app.dart';

Map<String, Object?> _status(String key, {bool terminal = false}) => {
  'key': key,
  'label': 'حالة $key',
  'color': '#F59E0B',
  'icon': 'receipt',
  'step': 0,
  'is_terminal': terminal,
};

final _config = <String, Object?>{
  ...configJson,
  'modules': ['coupons'],
  'statuses': [
    _status('awaiting_pricing'),
    _status('priced'),
    _status('awaiting_vendor'),
    _status('cancelled', terminal: true),
  ],
  'polling': {'tracking_seconds': 30},
};

Map<String, Object?> _money(int amount) => {
  'amount': amount,
  'formatted': '${(amount / 100).toStringAsFixed(2)} ₪',
};

const _address = {
  'id': 1,
  'label': 'البيت',
  'lat': 31.45,
  'lng': 34.39,
  'details': 'قرب مسجد الهدى',
  'is_default': true,
};

const _work = {
  'id': 2,
  'label': 'العمل',
  'lat': 31.41,
  'lng': 34.35,
  'details': null,
  'is_default': false,
};

Map<String, Object?> _quote({
  String token = 'qt_1',
  int expiresIn = 600,
  int items = 1300,
  int discount = 0,
  int total = 2000,
}) => {
  'quote_token': token,
  'expires_at': '2026-10-31T17:00:00+00:00',
  'expires_in': expiresIn,
  'distance_km': 1.8,
  'breakdown': [
    {
      'key': 'items_total',
      'kind': 'items',
      'label': 'قيمة الطلبات',
      ..._money(items),
    },
    {
      'key': 'delivery_fee',
      'kind': 'delivery',
      'label': 'رسوم التوصيل · النصيرات',
      ..._money(700),
    },
    if (discount > 0)
      {
        'key': 'coupon:WELCOME10',
        'kind': 'discount',
        'label': 'خصم الكوبون',
        'amount': discount,
        'formatted': '-${(discount / 100).toStringAsFixed(2)} ₪',
      },
  ],
  'items_total': _money(items),
  'delivery_fee': _money(700),
  'discount': _money(discount),
  'total': _money(total),
  'payment_method': 'cash',
  'config_version': 4,
};

Map<String, Object?> _order({
  String status = 'awaiting_pricing',
  bool terminal = false,
  bool cancel = true,
  bool discount = false,
}) => {
  'id': 55,
  'code': 'BR-000055',
  'status': _status(status, terminal: terminal),
  'vendor': {'id': 7, 'name': 'ملحمة الأصيل'},
  'items': [
    {'id': 1, 'name': 'حليب', 'qty': 2},
  ],
  'price': {
    'breakdown': [
      if (discount)
        {
          'key': 'coupon:X',
          'kind': 'discount',
          'label': 'خصم الكوبون',
          'amount': 460,
          'formatted': '-4.60 ₪',
        },
    ],
    'discount': _money(discount ? 460 : 0),
    'total': _money(2000),
  },
  'available_actions': [
    if (cancel)
      {
        'action': 'cancel',
        'to': 'cancelled',
        'label': 'رفض العرض',
        'style': 'danger',
        'confirm': 'هل تريد إلغاء الطلب؟',
      },
  ],
};

final _now = DateTime.now().toUtc();

Map<String, Object?> _offer({String status = 'sent'}) => {
  'id': 48,
  'order_id': 55,
  'status': status,
  'items': [
    {
      'id': 1,
      'name': 'لحم عجل',
      'qty': 1,
      'unit_price': _money(5500),
      'available': true,
      'substitute': null,
      'line_total': _money(5500),
      'note': null,
    },
    {
      'id': 2,
      'name': 'أفخاذ دجاج',
      'qty': 2,
      'unit_price': _money(1600),
      'available': false,
      'substitute': {'name': 'صدر دجاج', 'unit_price': _money(1900)},
      'line_total': _money(3800),
      'note': null,
    },
  ],
  'items_total': _money(9300),
  'delivery_fee': _money(700),
  'total': _money(10000),
  'note': 'الأفخاذ خلصت',
  'expires_at': _now.add(const Duration(minutes: 30)).toIso8601String(),
  'created_at': _now.subtract(const Duration(minutes: 30)).toIso8601String(),
};

final _cart = jsonEncode({
  'vendor_id': 7,
  'lines': [
    {
      'product_id': 96,
      'name': 'حليب',
      'image_url': null,
      'category_icon': 'milk',
      'unit_price': _money(650),
      'qty': 2,
      'options': <String, Object>{},
      'options_label': null,
    },
  ],
});

Map<String, Reply> _server({
  List<Object> addresses = const [_address, _work],
  Reply? quote,
}) => {
  'GET /app/config': Reply(_config),
  'GET /me': const Reply({'name': 'محمد'}),
  'GET /categories': const Reply(<Object>[]),
  'GET /products': const Reply(<Object>[]),
  'GET /vendors': const Reply(<Object>[]),
  'GET /addresses': Reply(addresses),
  'POST /orders/quote': quote ?? Reply(_quote(), status: 201),
  'POST /orders': Reply(_order(), status: 201),
  'GET /orders/55': Reply(_order()),
  'GET /orders/55/offer': const Reply(null, status: 404, error: 'not_found'),
  'PUT /me/fcm-token': const Reply(null),
};

Future<TestApp> _open(
  WidgetTester tester,
  String path, {
  Map<String, Reply>? replies,
  bool cart = true,
  Size size = phone,
}) async {
  final app = await TestApp.create(
    replies ?? _server(),
    secure: {'barq_token': 'saved'},
    prefs: {'barq_cart': ?(cart ? _cart : null)},
  );
  await app.pump(tester, size: size);
  GoRouter.of(tester.element(find.byType(Scaffold).first)).push(path);
  await app.settle(tester);
  return app;
}

/// Closes the screens, so their countdowns and polling stop.
void _test(String name, Future<void> Function(WidgetTester) body) =>
    testWidgets(name, (tester) async {
      await body(tester);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

Future<void> _tap(WidgetTester tester, TestApp app, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.pump();
  await tester.tap(find.text(text));
  await app.settle(tester);
}

Future<void> _confirm(WidgetTester tester, TestApp app) =>
    _tap(tester, app, 'تأكيد الطلب · 20.00 ₪');

int _count(TestApp app, String call) =>
    app.server.calls.where((c) => c == call).length;

Map<String, dynamic> _bodyOf(TestApp app, String call) =>
    (app.server.bodies[call]! as Map).cast<String, dynamic>();

void main() {
  group('countdown', () {
    test('formats minutes and seconds', () {
      expect(formatCountdown(432), '07:12');
      expect(formatCountdown(3599), '59:59');
      expect(formatCountdown(0), '00:00');
    });
  });

  group('checkout', () {
    _test('shows the server breakdown as it is', (tester) async {
      await _open(tester, Routes.checkout);
      expect(find.byType(CheckoutScreen), findsOneWidget);
      expect(find.text('قيمة الطلبات'), findsOneWidget);
      expect(find.text('رسوم التوصيل · النصيرات'), findsOneWidget);
      expect(find.text('20.00 ₪'), findsOneWidget);
      expect(find.textContaining(RegExp(r'^(10:00|09:\d\d)$')), findsOneWidget);
      expect(find.text('نقدًا عند الاستلام'), findsOneWidget);
      expect(find.text('قرب مسجد الهدى · 1.8 كم'), findsOneWidget);
    });

    _test('the quote carries the cart, address and choice', (tester) async {
      final app = await _open(tester, Routes.checkout);
      final body = _bodyOf(app, 'POST /orders/quote');
      expect(body['vendor_id'], 7);
      expect(body['dropoff_address_id'], 1);
      expect(body['fields'], {'substitutions': 'call_me'});
      expect(body['cart'], [
        {'product_id': 96, 'qty': 2},
      ]);
    });

    _test('an empty cart shows the empty view', (tester) async {
      await _open(tester, Routes.checkout, cart: false);
      expect(find.byType(EmptyCartView), findsOneWidget);
    });

    _test('no address asks for one', (tester) async {
      final app = await _open(
        tester,
        Routes.checkout,
        replies: _server(addresses: const []),
      );
      expect(find.text('ما عندك عنوان توصيل'), findsOneWidget);
      expect(app.server.calls, isNot(contains('POST /orders/quote')));
    });

    _test('out of zone offers another address', (tester) async {
      final app = await _open(
        tester,
        Routes.checkout,
        replies: _server(
          quote: const Reply(null, status: 422, error: 'out_of_zone'),
        ),
      );
      expect(find.byType(OutOfZoneView), findsOneWidget);

      app.server.replies['POST /orders/quote'] = Reply(_quote(), status: 201);
      await _tap(tester, app, 'تغيير العنوان');
      await tester.tap(find.text('العمل'));
      await app.settle(tester);
      expect(find.byType(OutOfZoneView), findsNothing);
      expect(_bodyOf(app, 'POST /orders/quote')['dropoff_address_id'], 2);
    });

    group('store outside the address zone', () {
      Reply comparison({required List<int> vendors}) => Reply({
        'zone': {'id': 1, 'name': 'النصيرات'},
        'cheapest_vendor_id': vendors.isEmpty ? null : vendors.first,
        'stores': [
          for (final id in vendors)
            {
              'vendor': {'id': id, 'name': 'متجر $id', 'open_now': true},
              'cheapest': true,
              'complete': true,
              'missing_count': 0,
              'items_total': _money(1300),
              'lines': <Object>[],
            },
        ],
      });

      Map<String, Reply> guarded(Reply compare) => {
        ..._server(),
        'GET /app/config': Reply({
          ..._config,
          'modules': ['coupons', 'basket_compare'],
        }),
        'POST /baskets/compare': compare,
      };

      _test('blocks checkout before any quote', (tester) async {
        final app = await _open(
          tester,
          Routes.checkout,
          replies: guarded(comparison(vendors: [16])),
        );
        expect(find.byType(OutOfZoneView), findsOneWidget);
        expect(find.textContaining('هذا المتجر ما بيوصّل'), findsOneWidget);
        expect(app.server.calls, isNot(contains('POST /orders/quote')));
      });

      _test('a store in the list goes on as usual', (tester) async {
        final app = await _open(
          tester,
          Routes.checkout,
          replies: guarded(comparison(vendors: [16, 7])),
        );
        expect(find.byType(OutOfZoneView), findsNothing);
        expect(app.server.calls, contains('POST /orders/quote'));
      });

      _test('a failed compare never lets the cart through', (tester) async {
        final app = await _open(
          tester,
          Routes.checkout,
          replies: guarded(const Reply(null, status: 500, error: 'x')),
        );
        expect(find.text('رسالة السيرفر'), findsOneWidget);
        expect(app.server.calls, isNot(contains('POST /orders/quote')));
      });

      _test('a new address is checked again', (tester) async {
        final app = await _open(
          tester,
          Routes.checkout,
          replies: guarded(comparison(vendors: [16])),
        );
        app.server.replies['POST /baskets/compare'] = comparison(vendors: [7]);
        await _tap(tester, app, 'تغيير العنوان');
        await tester.tap(find.text('العمل'));
        await app.settle(tester);
        expect(find.byType(OutOfZoneView), findsNothing);
        expect(_bodyOf(app, 'POST /baskets/compare')['dropoff_address_id'], 2);
        expect(_bodyOf(app, 'POST /orders/quote')['dropoff_address_id'], 2);
      });

      _test('the button compares for the chosen address', (tester) async {
        final app = await _open(
          tester,
          Routes.checkout,
          replies: guarded(comparison(vendors: [7])),
        );
        expect(find.byType(OutOfZoneView), findsNothing);

        app.server.replies['POST /baskets/compare'] = comparison(vendors: [16]);
        await tester.tap(find.text('تغيير'));
        await app.settle(tester);
        await tester.tap(find.text('العمل'));
        await app.settle(tester);
        expect(find.byType(OutOfZoneView), findsOneWidget);

        await _tap(tester, app, 'مقارنة السلة بالمتاجر القريبة');
        expect(find.byType(CompareScreen), findsOneWidget);
        expect(_bodyOf(app, 'POST /baskets/compare')['dropoff_address_id'], 2);
      });

      _test('with no compare module checkout does not ask', (tester) async {
        final app = await _open(tester, Routes.checkout);
        expect(find.byType(OutOfZoneView), findsNothing);
        expect(app.server.calls, isNot(contains('POST /baskets/compare')));
      });
    });

    _test('a failed quote shows the reason and can retry', (tester) async {
      final app = await _open(
        tester,
        Routes.checkout,
        replies: _server(
          quote: const Reply(null, status: 500, error: 'server_error'),
        ),
      );
      expect(find.text('رسالة السيرفر'), findsOneWidget);

      app.server.replies['POST /orders/quote'] = Reply(_quote(), status: 201);
      await _tap(tester, app, 'إعادة المحاولة');
      expect(find.text('قيمة الطلبات'), findsOneWidget);
    });

    _test('a coupon comes from the server, in green', (tester) async {
      final app = await _open(tester, Routes.checkout);
      app.server.replies['POST /coupons/validate'] = const Reply({});
      app.server.replies['POST /orders/quote'] = Reply(
        _quote(token: 'qt_c', discount: 460, total: 1540),
        status: 201,
      );
      await tester.enterText(find.byType(TextField).first, 'WELCOME10');
      await _tap(tester, app, 'تطبيق');

      expect(_bodyOf(app, 'POST /coupons/validate'), {
        'code': 'WELCOME10',
        'vendor_id': 7,
      });
      expect(_bodyOf(app, 'POST /orders/quote')['coupon'], 'WELCOME10');
      expect(find.text('تم تطبيقه'), findsOneWidget);
      final value = tester.widget<Text>(find.text('-4.60 ₪'));
      expect(value.style?.color, BarqColors.successText);

      app.server.replies['POST /orders/quote'] = Reply(_quote(), status: 201);
      await tester.enterText(find.byType(TextField).first, 'WELCOME1');
      await app.settle(tester);
      expect(find.text('تم تطبيقه'), findsNothing);
      expect(find.text('-4.60 ₪'), findsNothing);
      expect(_bodyOf(app, 'POST /orders/quote').containsKey('coupon'), isFalse);
    });

    _test('a refused coupon shows the field message', (tester) async {
      final app = await _open(tester, Routes.checkout);
      app.server.replies['POST /coupons/validate'] = const Reply(
        null,
        status: 422,
        error: 'validation_failed',
        details: {
          'fields': {
            'coupon': ['رمز الكوبون غير صالح'],
          },
        },
      );
      await tester.enterText(find.byType(TextField).first, 'NOPE');
      await _tap(tester, app, 'تطبيق');
      expect(find.text('رمز الكوبون غير صالح'), findsOneWidget);
      expect(find.text('تم تطبيقه'), findsNothing);
      expect(find.text('قيمة الطلبات'), findsOneWidget);
    });

    _test('a new substitution choice gets a new quote', (tester) async {
      final app = await _open(tester, Routes.checkout);
      app.server.replies['POST /orders/quote'] = Reply(
        _quote(token: 'qt_2'),
        status: 201,
      );
      await _tap(tester, app, 'بديل مشابه');
      expect(_bodyOf(app, 'POST /orders/quote')['fields'], {
        'substitutions': 'similar',
      });

      await _confirm(tester, app);
      final body = _bodyOf(app, 'POST /orders');
      expect(body['quote_token'], 'qt_2');
      expect(body['fields'], {'substitutions': 'similar'});
    });

    _test('confirming creates the order and empties the cart', (tester) async {
      final app = await _open(tester, Routes.checkout);
      var countChanged = false;
      final changes = app.deps.accountRepository.changes.listen(
        (_) => countChanged = true,
      );
      addTearDown(changes.cancel);
      await tester.enterText(find.byType(TextField).last, 'الباب الأخضر');
      await _confirm(tester, app);

      final body = _bodyOf(app, 'POST /orders');
      expect(body['quote_token'], 'qt_1');
      expect(body['note'], 'الباب الأخضر');
      expect(app.server.headers['POST /orders']!['Idempotency-Key'], isNotNull);
      expect(app.deps.cart.state.isEmpty, isTrue);
      expect(countChanged, isTrue);
      expect(find.byType(OrderWaitingScreen), findsOneWidget);
      expect(find.text('طلب BR-000055'), findsOneWidget);
      expect(find.text('حالة awaiting_pricing'), findsOneWidget);
    });

    _test('a retry after no internet repeats the exact request', (
      tester,
    ) async {
      final app = await _open(tester, Routes.checkout);
      app.server.lostAnswers = 1;
      await _confirm(tester, app);

      final key = app.server.headers['POST /orders']!['Idempotency-Key'];
      expect(find.byType(CheckoutScreen), findsOneWidget);
      expect(find.textContaining('تعذر الاتصال'), findsOneWidget);
      expect(app.deps.cart.state.isEmpty, isFalse);

      // Nothing may change the request while it is unanswered.
      expect(find.text('تغيير'), findsNothing);
      final quotes = _count(app, 'POST /orders/quote');
      await _tap(tester, app, 'احذفوه');
      expect(_count(app, 'POST /orders/quote'), quotes);

      await _confirm(tester, app);
      expect(app.server.headers['POST /orders']!['Idempotency-Key'], key);
      expect(find.byType(OrderWaitingScreen), findsOneWidget);
    });

    _test('a refused order takes a new key the next time', (tester) async {
      final app = await _open(tester, Routes.checkout);
      app.server.replies['POST /orders'] = const Reply(
        null,
        status: 422,
        error: 'vendor_closed',
      );
      await _confirm(tester, app);
      final first = app.server.headers['POST /orders']!['Idempotency-Key'];
      expect(find.text('رسالة السيرفر'), findsOneWidget);
      expect(find.text('تغيير'), findsOneWidget);

      await _confirm(tester, app);
      final second = app.server.headers['POST /orders']!['Idempotency-Key'];
      expect(second, isNot(first));
    });

    _test('quote_expired shows the new price and goes on with it', (
      tester,
    ) async {
      final app = await _open(tester, Routes.checkout);
      app.server.replies['POST /orders'] = const Reply(
        null,
        status: 410,
        error: 'quote_expired',
      );
      app.server.replies['POST /orders/quote'] = Reply(
        _quote(token: 'qt_new', items: 1500, total: 2200),
        status: 201,
      );
      app.server.replies['GET /products/96'] = Reply({
        'id': 96,
        'name': 'حليب',
        'image_url': null,
        'price': _money(750),
        'compare_at_price': null,
        'in_stock': true,
        'stock': 5,
        'category_id': 9,
        'vendor_id': 7,
        'options': <Object>[],
        'fields': <String, Object>{},
      });
      await _confirm(tester, app);

      expect(find.text('انتهت صلاحية السعر'), findsOneWidget);
      expect(find.text('مرّت 10 دقيقة على التسعيرة'), findsOneWidget);
      expect(find.text('حليب × 2'), findsOneWidget);
      expect(find.text('6.50 ₪'), findsOneWidget);
      expect(find.text('7.50 ₪'), findsOneWidget);
      expect(find.textContaining('20.00 ₪'), findsWidgets);
      expect(app.deps.cart.state.lines.single.unitPrice.formatted, '7.50 ₪');

      final firstKey = app.server.headers['POST /orders']!['Idempotency-Key'];
      await _tap(tester, app, 'متابعة بالسعر الجديد');
      app.server.replies['POST /orders'] = Reply(_order(), status: 201);
      await _tap(tester, app, 'تأكيد الطلب · 22.00 ₪');

      expect(_bodyOf(app, 'POST /orders')['quote_token'], 'qt_new');
      final key = app.server.headers['POST /orders']!['Idempotency-Key'];
      expect(key, isNot(firstKey));
      expect(find.byType(OrderWaitingScreen), findsOneWidget);
    });

    _test('review cart goes back to the cart', (tester) async {
      final app = await _open(tester, Routes.cart);
      await tester.tap(find.byType(BarqButton).last);
      await app.settle(tester);
      app.server.replies['POST /orders'] = const Reply(
        null,
        status: 410,
        error: 'quote_used',
      );
      await _confirm(tester, app);
      expect(find.text('الأسعار ما تغيّرت'), findsNothing);
      expect(find.textContaining('ما تغيّرت'), findsOneWidget);

      await _tap(tester, app, 'مراجعة السلة');
      expect(find.byType(CheckoutScreen), findsNothing);
      expect(find.text('سلتي'), findsOneWidget);
    });

    _test('the end of the countdown asks for a new price', (tester) async {
      final app = await _open(
        tester,
        Routes.checkout,
        replies: _server(quote: Reply(_quote(expiresIn: 1), status: 201)),
      );
      app.server.replies['POST /orders/quote'] = Reply(
        _quote(token: 'qt_2', total: 2100),
        status: 201,
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 1100)),
      );
      await tester.pump(const Duration(seconds: 2));
      await app.settle(tester);

      expect(find.text('انتهت صلاحية السعر'), findsOneWidget);
      expect(find.text('رسوم التوصيل · النصيرات'), findsOneWidget);
    });

    _test('fits a small phone, with the keyboard closed', (tester) async {
      final app = await _open(tester, Routes.checkout, size: smallPhone);
      await _confirm(tester, app);
      expect(tester.takeException(), isNull);
    });
  });

  group('waiting for the store', () {
    _test('opens the offer when the order is priced', (tester) async {
      final app = await _open(tester, Routes.orderOf(55));
      expect(find.byType(OrderWaitingScreen), findsOneWidget);
      expect(find.byType(OfferScreen), findsNothing);

      app.server.replies['GET /orders/55'] = Reply(_order(status: 'priced'));
      app.server.replies['GET /orders/55/offer'] = Reply(_offer());
      app.server.replies['GET /orders/55/events'] = const Reply(
        [
          {'id': 2, 'type': 'status.changed', 'payload': <String, Object>{}},
        ],
        meta: {'next_since': 2, 'next_poll_seconds': 5},
      );
      await tester.pump(const Duration(seconds: 6));
      await app.settle(tester);
      expect(find.byType(OfferScreen), findsOneWidget);
    });
  });

  group('offer', () {
    Map<String, Reply> priced({bool discount = false}) => {
      ..._server(),
      'GET /orders/55': Reply(_order(status: 'priced', discount: discount)),
      'GET /orders/55/offer': Reply(_offer()),
    };

    _test('404 only means it is not priced yet', (tester) async {
      await _open(tester, Routes.offerOf(55));
      expect(find.text('المتجر لسا ما سعّر طلبك'), findsOneWidget);
      expect(find.text('رسالة السيرفر'), findsNothing);
    });

    _test('shows the store prices and the time left', (tester) async {
      await _open(tester, Routes.offerOf(55), replies: priced());
      expect(find.text('لحم عجل × 1'), findsOneWidget);
      expect(find.text('55.00 ₪ للوحدة'), findsOneWidget);
      expect(find.text('غير متوفر'), findsOneWidget);
      expect(find.text('البديل: صدر دجاج · 19.00 ₪ للوحدة'), findsOneWidget);
      expect(find.text('ملاحظة المتجر: الأفخاذ خلصت'), findsOneWidget);
      expect(find.text('100.00 ₪'), findsOneWidget);
      expect(
        find.text('إذا لم توافق خلال 60 دقيقة، يُلغى الطلب تلقائيًا.'),
        findsOneWidget,
      );
      expect(find.textContaining(RegExp(r'^29:\d\d$')), findsOneWidget);
      expect(find.text('رفض العرض'), findsOneWidget);
    });

    _test('shows the coupon that the total includes', (tester) async {
      await _open(tester, Routes.offerOf(55), replies: priced(discount: true));
      expect(find.text('خصم الكوبون'), findsOneWidget);
      expect(find.text('-4.60 ₪'), findsOneWidget);
    });

    _test('approving sends the offer id once, then leaves', (tester) async {
      final app = await _open(tester, Routes.orderOf(55), replies: priced());
      expect(find.byType(OfferScreen), findsOneWidget);
      app.server.replies['POST /orders/55/offer/approve'] = Reply(_offer());
      app.server.handlers['POST /orders/55/offer/approve'] = (_) {
        app.server.replies['GET /orders/55'] = Reply(
          _order(status: 'awaiting_vendor'),
        );
        app.server.replies['GET /orders/55/offer'] = Reply(
          _offer(status: 'approved'),
        );
        return Reply(_offer(status: 'approved'));
      };
      await _tap(tester, app, 'الموافقة على العرض');

      expect(_bodyOf(app, 'POST /orders/55/offer/approve'), {'offer_id': 48});
      expect(
        app.server.headers['POST /orders/55/offer/approve']!['Idempotency-Key'],
        isNotNull,
      );
      expect(find.byType(OfferScreen), findsNothing);
      expect(find.text('حالة awaiting_vendor'), findsWidgets);
    });

    _test('a lost answer approves again with the same key', (tester) async {
      final app = await _open(tester, Routes.offerOf(55), replies: priced());
      app.server.replies['POST /orders/55/offer/approve'] = Reply(_offer());
      app.server.lostAnswers = 1;
      await _tap(tester, app, 'الموافقة على العرض');
      final key = app
          .server
          .headers['POST /orders/55/offer/approve']!['Idempotency-Key'];
      expect(find.textContaining('تعذر الاتصال'), findsOneWidget);

      await _tap(tester, app, 'الموافقة على العرض');
      expect(
        app.server.headers['POST /orders/55/offer/approve']!['Idempotency-Key'],
        key,
      );
    });

    _test('a refused step never shows the developer hint', (tester) async {
      final app = await _open(tester, Routes.offerOf(55), replies: priced());
      app.server.replies['POST /orders/55/offer/approve'] = const Reply(
        null,
        status: 422,
        error: 'invalid_transition',
      );
      await _tap(tester, app, 'الموافقة على العرض');
      expect(find.text('رسالة السيرفر'), findsNothing);
      expect(
        find.text(
          'ما قدرنا ننفّذ هاد الطلب. جرّب مرة ثانية أو تواصل مع الدعم.',
        ),
        findsOneWidget,
      );
      expect(find.byType(OfferScreen), findsOneWidget);
    });

    _test('rejecting asks first, with the server words', (tester) async {
      final app = await _open(tester, Routes.orderOf(55), replies: priced());
      await _tap(tester, app, 'رفض العرض');
      expect(find.text('هل تريد إلغاء الطلب؟'), findsOneWidget);
      expect(app.server.calls, isNot(contains('POST /orders/55/offer/reject')));

      app.server.handlers['POST /orders/55/offer/reject'] = (_) {
        app.server.replies['GET /orders/55'] = Reply(
          _order(status: 'cancelled', terminal: true, cancel: false),
        );
        app.server.replies['GET /orders/55/offer'] = Reply(
          _offer(status: 'rejected'),
        );
        return Reply(_offer(status: 'rejected'));
      };
      await tester.tap(find.text('رفض العرض').last);
      await app.settle(tester);
      expect(find.byType(OfferScreen), findsNothing);
      expect(find.text('حالة cancelled'), findsWidgets);
    });

    _test('offer_expired while approving shows the expired view', (
      tester,
    ) async {
      final app = await _open(tester, Routes.offerOf(55), replies: priced());
      app.server.handlers['POST /orders/55/offer/approve'] = (_) {
        app.server.replies['GET /orders/55/offer'] = Reply(
          _offer(status: 'expired'),
        );
        return const Reply(null, status: 409, error: 'offer_expired');
      };
      await _tap(tester, app, 'الموافقة على العرض');
      expect(find.byType(OfferExpiredView), findsOneWidget);
    });
  });

  group('offer expired', () {
    final expired = {
      ..._server(),
      'GET /orders/55': Reply(
        _order(status: 'cancelled', terminal: true, cancel: false),
      ),
      'GET /orders/55/offer': Reply(_offer(status: 'expired')),
      'GET /products': Reply(
        [
          {
            'id': 96,
            'name': 'حليب',
            'image_url': null,
            'price': _money(650),
            'compare_at_price': null,
            'in_stock': true,
            'stock': 5,
            'category_id': 9,
            'vendor_id': 7,
            'options': <Object>[],
            'fields': <String, Object>{},
          },
        ],
        meta: const {'total': 1},
      ),
    };

    _test('says what happened', (tester) async {
      await _open(tester, Routes.offerOf(55), replies: expired, cart: false);
      expect(find.text('انتهت صلاحية العرض'), findsOneWidget);
      expect(find.textContaining('خلال 60 دقيقة'), findsOneWidget);
      expect(find.text('طلب BR-000055'), findsOneWidget);
      expect(find.text('1 منتج · كان الإجمالي 20.00 ₪'), findsOneWidget);
      expect(find.text('حالة cancelled'), findsWidgets);
    });

    _test('order again fills the cart and opens it', (tester) async {
      final app = await _open(
        tester,
        Routes.offerOf(55),
        replies: expired,
        cart: false,
      );
      await _tap(tester, app, 'اطلب نفس السلة من جديد');
      expect(app.deps.cart.state.lines.single.qty, 2);
      expect(app.deps.cart.state.vendorId, 7);
      expect(find.text('سلتي'), findsOneWidget);
    });

    _test('order again asks before replacing a cart', (tester) async {
      final app = await _open(tester, Routes.offerOf(55), replies: expired);
      await _tap(tester, app, 'اطلب نفس السلة من جديد');
      expect(find.text('إعادة الطلب رح تستبدل سلتك الحالية.'), findsOneWidget);
      await _tap(tester, app, 'إبقاء السلة');
      expect(find.byType(OfferExpiredView), findsOneWidget);
    });

    _test('back to home', (tester) async {
      final app = await _open(
        tester,
        Routes.offerOf(55),
        replies: expired,
        cart: false,
      );
      await _tap(tester, app, 'العودة للرئيسية');
      expect(find.byType(OfferExpiredView), findsNothing);
    });
  });
}
