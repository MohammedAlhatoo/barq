import 'package:barq_customer/app/router.dart';
import 'package:barq_customer/features/assistant/data/product_matcher.dart';
import 'package:barq_customer/features/assistant/ui/assistant_screen.dart';
import 'package:barq_customer/features/browse/data/browse_models.dart';
import 'package:barq_customer/features/cart/data/cart_models.dart';
import 'package:barq_customer/features/checkout/ui/checkout_screen.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers/test_app.dart';

final _config = <String, Object?>{
  ...configJson,
  'modules': ['basket_compare'],
};

Map<String, Object?> _money(int amount) => {
  'amount': amount,
  'formatted': '${amount ~/ 100}.00 ₪',
};

Map<String, Object?> _product(
  int id,
  String name, {
  bool inStock = true,
  List<Object> options = const [],
}) => {
  'id': id,
  'name': name,
  'description': null,
  'image_url': null,
  'price': _money(600),
  'compare_at_price': null,
  'in_stock': inStock,
  'stock': 10,
  'category_id': 9,
  'vendor_id': 7,
  'options': options,
  'fields': <String, Object>{},
};

final _catalog = {
  'بندورة': [_product(1, 'بندورة ١ كغ'), _product(11, 'بندورة ١ كغ')],
  'حليب': [_product(2, 'حليب ١ لتر'), _product(12, 'شوكولا بالحليب')],
  'خيار': [_product(3, 'خيار ١ كغ')],
  'أرز': [_product(4, 'أرز ١ كغ')],
};

/// [missingMilk] makes the store sell the tomatoes only.
Map<String, Object?> _store(int id, String name, {bool missingMilk = false}) =>
    {
      'vendor': {'id': id, 'name': name, 'logo_url': null, 'open_now': true},
      'cheapest': false,
      'complete': !missingMilk,
      'missing_count': missingMilk ? 1 : 0,
      'items_total': _money(1000),
      'lines': [
        {
          'product_id': 1,
          'store_product_id': id * 100 + 1,
          'name': 'بندورة ١ كغ',
          'qty': 2,
          'unit_price': _money(500),
          'available': true,
          'reason': null,
        },
        {
          'product_id': 2,
          'store_product_id': missingMilk ? null : id * 100 + 2,
          'name': 'حليب ١ لتر',
          'qty': 1,
          'unit_price': missingMilk ? null : _money(700),
          'available': !missingMilk,
          'reason': missingMilk ? 'not_sold' : null,
        },
      ],
    };

Map<String, Object?> _comparison(List<Map<String, Object?>> stores) => {
  'zone': {'id': 9, 'name': 'النصيرات'},
  'cheapest_vendor_id': stores.any((s) => s['complete'] == true)
      ? (stores.first['vendor']! as Map)['id']
      : null,
  'stores': stores,
};

Map<String, Object?> _vendor(int id, String name, double km) => {
  'id': id,
  'name': name,
  'distance_km': km,
  'is_open_now': true,
  'rating': {'average': 4.8, 'count': 3},
};

/// The total of `POST /orders/quote`, by vendor. 500 for a vendor not listed.
Map<int, int> _totals = {};

Map<String, Object?> _quote(int total) => {
  'quote_token': 'qt_1',
  'expires_in': 600,
  'distance_km': 1.8,
  'breakdown': [
    {'key': 'items_total', 'kind': 'items', 'label': 'x', ..._money(total)},
  ],
  'items_total': _money(total - 700),
  'discount': _money(0),
  'total': _money(total),
};

Map<String, Reply> _server({Reply? compare, Reply? addresses}) => {
  'GET /app/config': Reply(_config),
  'GET /me': const Reply({'name': 'محمد'}),
  'GET /categories': const Reply(<Object>[]),
  'GET /vendors': Reply([
    _vendor(30, 'سوبرماركت الرحمة', 2.5),
    _vendor(31, 'ماركت الندى', 1.2),
    _vendor(32, 'بقالة النخيل', 3.4),
    _vendor(33, 'بقالة بعيدة', 9),
  ]),
  'GET /addresses':
      addresses ??
      const Reply([
        {
          'id': 42,
          'label': 'البيت',
          'lat': 31.45,
          'lng': 34.39,
          'details': null,
          'is_default': true,
        },
      ]),
  'POST /baskets/compare':
      compare ??
      Reply(
        _comparison([
          _store(33, 'بقالة بعيدة'),
          _store(30, 'سوبرماركت الرحمة'),
          _store(31, 'ماركت الندى'),
          _store(32, 'بقالة النخيل'),
        ]),
      ),
  'GET /orders': const Reply(<Object>[]),
};

Future<TestApp> _open(
  WidgetTester tester, {
  Map<String, Reply>? replies,
  Map<String, Object> prefs = const {},
}) async {
  _totals = {30: 2900, 31: 3100, 32: 2600, 33: 1000};
  final app = await TestApp.create(
    replies ?? _server(),
    secure: {'barq_token': 'saved'},
    prefs: prefs,
  );
  final server = app.server;
  server.handlers['GET /products'] = (_) => Reply(
    _catalog[server.queries['GET /products']?['q']] ??
        (server.queries['GET /products']?['q'] == null
            ? [_product(1, 'بندورة ١ كغ')]
            : const <Object>[]),
  );
  server.handlers['POST /orders/quote'] = (body) {
    final vendor = (body! as Map)['vendor_id'] as int;
    final total = _totals[vendor];
    return total == null
        ? const Reply(null, status: 422, error: 'vendor_closed')
        : Reply(_quote(total), status: 201);
  };
  await app.pump(tester);
  GoRouter.of(tester.element(find.byType(Scaffold).first))
      .push(Routes.assistant);
  await app.settle(tester);
  return app;
}

Future<void> _send(WidgetTester tester, TestApp app, String text) async {
  await tester.enterText(find.byType(TextField).last, text);
  await tester.tap(
    find.byWidgetPredicate(
      (w) => w is BarqIconButton && w.icon == BarqIcons.arrow,
    ),
  );
  await app.settle(tester);
}

Future<void> _tap(WidgetTester tester, TestApp app, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.pump();
  await tester.tap(find.text(text));
  await app.settle(tester);
}

Future<void> _compare(WidgetTester tester, TestApp app, String list) async {
  await _send(tester, app, list);
  await _tap(tester, app, 'تمام، قارن المتاجر');
}

const _list = 'كيلوين بندورة ولتر حليب';

/// An open confirmation bubble: the product's name, and its quantity in a stepper.
void _expectLine(WidgetTester tester, String name, int qty) {
  final row = find.ancestor(of: find.text(name), matching: find.byType(Row));
  final stepper = find.descendant(
    of: row.first,
    matching: find.byType(BarqQtyStepper),
  );
  expect(tester.widget<BarqQtyStepper>(stepper).value, qty, reason: name);
}

void main() {
  group('ProductMatcher', () {
    Product product(int id, String name, {bool inStock = true}) =>
        Product.fromJson(_product(id, name, inStock: inStock));

    test('the name closest to the term wins', () {
      final best = ProductMatcher.bestOf('حليب', [
        product(1, 'شوكولا بالحليب'),
        product(2, 'علبة حليب كبيرة'),
        product(3, 'حليب ١ لتر'),
      ]);
      expect(best!.id, 3);
    });

    test('the same name wins over a longer one', () {
      final best = ProductMatcher.bestOf('حليب ١ لتر', [
        product(1, 'حليب ١ لتر كامل الدسم'),
        product(2, 'حليب ١ لتر'),
      ]);
      expect(best!.id, 2);
    });

    test('a tie keeps the first of the server', () {
      final best = ProductMatcher.bestOf('بندورة', [
        product(1, 'بندورة ١ كغ'),
        product(2, 'بندورة ١ كغ'),
      ]);
      expect(best!.id, 1);
    });

    test('no products is no match', () {
      expect(ProductMatcher.bestOf('حليب', const []), isNull);
    });

    test('other spellings are tried, because the search is exact', () {
      expect(ProductMatcher.searchTerms('بندوره'), contains('بندورة'));
      expect(ProductMatcher.searchTerms('بندورا'), contains('بندورة'));
      expect(ProductMatcher.searchTerms('ارز'), contains('أرز'));
      expect(ProductMatcher.searchTerms('رز'), contains('أرز'));
      expect(ProductMatcher.searchTerms('طماطم'), contains('بندورة'));
      expect(ProductMatcher.searchTerms('موزة'), contains('موز'));
      expect(ProductMatcher.searchTerms('حليب'), ['حليب']);
    });
  });

  group('home', () {
    testWidgets('the banner opens the assistant', (tester) async {
      final app = await TestApp.create(
        _server(),
        secure: {'barq_token': 'saved'},
      );
      app.server.replies['GET /products'] = Reply([_product(1, 'بندورة')]);
      await app.pump(tester);

      await tester.tap(find.text('اطلب بسرعة مع مساعد برق'));
      await app.settle(tester);

      expect(find.byType(AssistantScreen), findsOneWidget);
      expect(find.textContaining('أهلًا! أنا مساعد برق'), findsOneWidget);
      for (final chip in const [
        'خضار وفواكه',
        'طلبات الفطور',
        'أعد آخر طلب',
        'اكتب قائمتك',
      ]) {
        expect(find.text(chip), findsOneWidget);
      }
    });

    testWidgets('no banner without the basket_compare module', (tester) async {
      final replies = _server()
        ..['GET /app/config'] = const Reply(configJson)
        ..['GET /products'] = Reply([_product(1, 'بندورة')]);
      final app = await TestApp.create(
        replies,
        secure: {'barq_token': 'saved'},
      );
      await app.pump(tester);
      expect(find.text('اطلب بسرعة مع مساعد برق'), findsNothing);
    });
  });

  group('the list', () {
    testWidgets('shows what was found with its quantity', (tester) async {
      final app = await _open(tester);
      await _send(tester, app, _list);

      expect(find.text(_list), findsOneWidget);
      _expectLine(tester, 'بندورة ١ كغ', 2);
      _expectLine(tester, 'حليب ١ لتر', 1);
      expect(app.server.calls, isNot(contains('POST /baskets/compare')));
    });

    testWidgets('tells the user about a rounded quantity', (tester) async {
      final app = await _open(tester);
      await _send(tester, app, 'نص كيلو خيار');

      _expectLine(tester, 'خيار ١ كغ', 1);
      expect(find.text('الخيار بتنباع بالكيلو، حطيتلك كيلو'), findsOneWidget);
    });

    testWidgets('another spelling still finds the product', (tester) async {
      final app = await _open(tester);
      await _send(tester, app, 'كيلو رز');
      _expectLine(tester, 'أرز ١ كغ', 1);
    });

    testWidgets('says what it could not find', (tester) async {
      final app = await _open(tester);
      await _send(tester, app, 'لتر حليب وكيلو كمبيوتر');

      _expectLine(tester, 'حليب ١ لتر', 1);
      expect(find.text('مش لاقي كمبيوتر'), findsOneWidget);
    });

    testWidgets('finding nothing has no compare button', (tester) async {
      final app = await _open(tester);
      await _send(tester, app, 'كمبيوتر');

      expect(find.text('ما لقيت ولا صنف من قائمتك:'), findsOneWidget);
      expect(find.text('تمام، قارن المتاجر'), findsNothing);
    });

    testWidgets('a chip takes an alternative', (tester) async {
      final app = await _open(tester);
      await _send(tester, app, 'بندورة بلدية حمرا');

      expect(find.text('مش لاقي بندورة بلدية حمرا. يمكن بدك:'), findsOneWidget);
      await _tap(tester, app, 'بندورة ١ كغ');

      _expectLine(tester, 'بندورة ١ كغ', 1);
      expect(find.text('تمام، قارن المتاجر'), findsOneWidget);
    });

    testWidgets('a product out of stock or with choices is not matched', (
      tester,
    ) async {
      final app = await _open(tester);
      _catalog['موز'] = [
        _product(5, 'موز ١ كغ', inStock: false),
        _product(
          6,
          'موز بلدي',
          options: [
            {
              'key': 'size',
              'label': 'الحجم',
              'type': 'single',
              'required': true,
              'choices': <Object>[],
            },
          ],
        ),
      ];
      addTearDown(() => _catalog.remove('موز'));
      await _send(tester, app, 'كيلو موز');
      expect(find.text('مش لاقي موز'), findsOneWidget);
    });

    testWidgets('text with no item asks again', (tester) async {
      final app = await _open(tester);
      await _send(tester, app, '2 كيلو');

      expect(find.textContaining('ما فهمت القائمة'), findsOneWidget);
      expect(app.server.calls, isNot(contains('GET /products?q')));
    });

    testWidgets('a failed search shows the server and can retry', (
      tester,
    ) async {
      final app = await _open(tester);
      final working = app.server.handlers['GET /products']!;
      app.server.handlers['GET /products'] = (_) =>
          const Reply(null, status: 500, error: 'server_error');
      await _send(tester, app, 'لتر حليب');
      expect(find.text('رسالة السيرفر'), findsOneWidget);

      app.server.handlers['GET /products'] = working;
      await _tap(tester, app, 'إعادة المحاولة');
      _expectLine(tester, 'حليب ١ لتر', 1);
    });
  });

  group('the stores', () {
    testWidgets('the nearest three, ranked by the total with delivery', (
      tester,
    ) async {
      final app = await _open(tester);
      await _compare(tester, app, _list);

      // بقالة بعيدة has the cheapest items, but it is the farthest store.
      expect(find.text('بقالة بعيدة'), findsNothing);
      expect(find.text('أوفر متجر لقائمتك: بقالة النخيل'), findsOneWidget);
      expect(find.text('الأوفر'), findsOneWidget);
      expect(find.text('26.00 ₪'), findsOneWidget);
      expect(find.text('3.4 كم'), findsOneWidget);
      expect(find.text('29.00 ₪'), findsOneWidget);
      expect(find.text('2.5 كم'), findsOneWidget);
      expect(find.text('31.00 ₪'), findsOneWidget);
      expect(find.text('1.2 كم'), findsOneWidget);
      expect(find.text('شامل التوصيل'), findsNWidgets(3));
      expect(find.text('أكمل الطلب · 26.00 ₪'), findsOneWidget);
      final body =
          app.server.bodies['POST /baskets/compare']! as Map<String, dynamic>;
      expect(body['dropoff_address_id'], 42);
      expect(body['cart'], [
        {'product_id': 1, 'qty': 2},
        {'product_id': 2, 'qty': 1},
      ]);
    });

    testWidgets('the same product twice is one line', (tester) async {
      final app = await _open(tester);
      await _compare(tester, app, 'كيلو بندورة وكيلوين بندورة');
      final body =
          app.server.bodies['POST /baskets/compare']! as Map<String, dynamic>;
      expect(body['cart'], [
        {'product_id': 1, 'qty': 3},
      ]);
    });

    testWidgets('continue fills the cart and opens checkout', (tester) async {
      final app = await _open(tester);
      await _compare(tester, app, _list);
      await _tap(tester, app, 'أكمل الطلب · 26.00 ₪');

      final cart = app.deps.cart.state;
      expect(cart.vendorId, 32);
      expect(cart.lines.map((line) => line.productId), [3201, 3202]);
      expect(cart.lines.map((line) => line.qty), [2, 1]);
      expect(find.byType(CheckoutScreen), findsOneWidget);
    });

    testWidgets('picking an alternative changes the order', (tester) async {
      final app = await _open(tester);
      await _compare(tester, app, _list);
      await _tap(tester, app, 'ماركت الندى');
      await _tap(tester, app, 'أكمل الطلب · 31.00 ₪');

      expect(app.deps.cart.state.vendorId, 31);
    });

    testWidgets('asks before replacing a cart', (tester) async {
      final app = await _open(tester);
      app.deps.cart.fillFrom(
        BasketStore.fromJson(_store(30, 'سوبرماركت الرحمة')),
        [
          CartLine.fromJson({
            'product_id': 1,
            'name': 'بندورة',
            'image_url': null,
            'category_icon': null,
            'unit_price': _money(600),
            'qty': 1,
            'options': <String, Object>{},
          }),
        ],
      );
      await _compare(tester, app, _list);
      await _tap(tester, app, 'أكمل الطلب · 26.00 ₪');

      expect(find.text('استبدال السلة؟'), findsOneWidget);
      await _tap(tester, app, 'إبقاء السلة');
      expect(app.deps.cart.state.vendorId, 30);
      expect(find.byType(CheckoutScreen), findsNothing);

      await _tap(tester, app, 'أكمل الطلب · 26.00 ₪');
      await _tap(tester, app, 'استبدال السلة');
      expect(app.deps.cart.state.vendorId, 32);
      expect(find.byType(CheckoutScreen), findsOneWidget);
    });

    testWidgets('stores with missing items say what is missing', (
      tester,
    ) async {
      final app = await _open(
        tester,
        replies: _server(
          compare: Reply(
            _comparison([_store(30, 'سوبرماركت الرحمة', missingMilk: true)]),
          ),
        ),
      );
      await _compare(tester, app, _list);

      expect(find.textContaining('ما في متجر عنده كل القائمة'), findsOneWidget);
      expect(find.text('ناقص 1 · حليب ١ لتر'), findsOneWidget);
      expect(find.text('الأوفر'), findsNothing);
      // Only what the store has is priced.
      final quote =
          app.server.bodies['POST /orders/quote']! as Map<String, dynamic>;
      expect(quote['cart'], [
        {'product_id': 3001, 'qty': 2},
      ]);

      await _tap(tester, app, 'أكمل الطلب · 29.00 ₪');
      expect(app.deps.cart.state.lines.single.productId, 3001);
    });

    testWidgets('a store with missing items follows the complete ones', (
      tester,
    ) async {
      final app = await _open(
        tester,
        replies: _server(
          compare: Reply(
            _comparison([
              _store(30, 'سوبرماركت الرحمة'),
              _store(31, 'ماركت الندى', missingMilk: true),
            ]),
          ),
        ),
      );
      _totals[31] = 1500;
      await _compare(tester, app, _list);

      expect(find.text('أوفر متجر لقائمتك: سوبرماركت الرحمة'), findsOneWidget);
      expect(find.text('أكمل الطلب · 29.00 ₪'), findsOneWidget);
      expect(find.text('ناقص 1 · حليب ١ لتر'), findsOneWidget);
    });

    testWidgets('a failed quote shows the items price', (tester) async {
      final app = await _open(tester);
      _totals.remove(32);
      await _compare(tester, app, _list);

      expect(find.text('أوفر متجر لقائمتك: سوبرماركت الرحمة'), findsOneWidget);
      expect(find.text('التوصيل يُحسب لاحقًا'), findsOneWidget);
      expect(find.text('10.00 ₪'), findsOneWidget);
    });

    testWidgets('out of zone offers another address', (tester) async {
      final app = await _open(
        tester,
        replies: _server(
          compare: const Reply(null, status: 422, error: 'out_of_zone'),
        ),
      );
      await _compare(tester, app, _list);

      expect(find.textContaining('خارج مناطق خدمة برق'), findsOneWidget);
      expect(find.text('تغيير العنوان'), findsOneWidget);
    });

    testWidgets('no address offers to add one', (tester) async {
      final app = await _open(
        tester,
        replies: _server(addresses: const Reply(<Object>[])),
      );
      await _compare(tester, app, _list);

      expect(find.text('إضافة عنوان'), findsOneWidget);
      expect(app.server.calls, isNot(contains('POST /baskets/compare')));
    });

    testWidgets('no store at all', (tester) async {
      final app = await _open(
        tester,
        replies: _server(compare: Reply(_comparison([]))),
      );
      await _compare(tester, app, _list);
      expect(find.textContaining('ما في متجر بيوصّلك'), findsOneWidget);
    });

    testWidgets('a failed comparison can be retried', (tester) async {
      final app = await _open(
        tester,
        replies: _server(
          compare: const Reply(null, status: 500, error: 'server_error'),
        ),
      );
      await _compare(tester, app, _list);
      expect(find.text('رسالة السيرفر'), findsOneWidget);

      app.server.replies['POST /baskets/compare'] = Reply(
        _comparison([_store(30, 'سوبرماركت الرحمة')]),
      );
      await _tap(tester, app, 'إعادة المحاولة');
      expect(find.text('أوفر متجر لقائمتك: سوبرماركت الرحمة'), findsOneWidget);
    });
  });

  group('quantities', () {
    Map<String, Object?> weights({bool required = true}) => {
      'key': 'weight',
      'label': 'الوزن',
      'type': 'single',
      'required': required,
      'choices': [
        {'key': 'half', 'label': '٥٠٠ غ', 'price': _money(0)},
        {'key': 'kilo', 'label': '١ كغ', 'price': _money(300)},
      ],
    };

    tearDown(() => _catalog.remove('جبنة'));

    testWidgets('a choice that matches the weight is used', (tester) async {
      final app = await _open(tester);
      _catalog['جبنة'] = [
        _product(1, 'جبنة بيضاء', options: [weights()]),
      ];
      await _send(tester, app, 'نص كيلو جبنة');

      _expectLine(tester, 'جبنة بيضاء · ٥٠٠ غ', 1);
      expect(find.textContaining('بتنباع'), findsNothing);
      await _tap(tester, app, 'تمام، قارن المتاجر');

      final quote =
          app.server.bodies['POST /orders/quote']! as Map<String, dynamic>;
      expect((quote['cart'] as List).first, {
        'product_id': (quote['vendor_id'] as int) * 100 + 1,
        'qty': 1,
        'options': {'weight': 'half'},
      });
      await _tap(tester, app, 'أكمل الطلب · 26.00 ₪');
      expect(app.deps.cart.state.lines.first.options, {'weight': 'half'});
      expect(app.deps.cart.state.lines.first.optionsLabel, '٥٠٠ غ');
    });

    testWidgets('a kilo and a half is three of 500 g', (tester) async {
      final app = await _open(tester);
      _catalog['جبنة'] = [
        _product(1, 'جبنة بيضاء', options: [weights()]),
      ];
      await _send(tester, app, 'كيلو ونص جبنة');
      _expectLine(tester, 'جبنة بيضاء · ٥٠٠ غ', 3);
    });

    testWidgets('a required choice with no fit is not matched', (tester) async {
      final app = await _open(tester);
      _catalog['جبنة'] = [
        _product(1, 'جبنة بيضاء', options: [weights()]),
      ];
      await _send(tester, app, 'ربع كيلو جبنة');
      expect(find.text('مش لاقي جبنة'), findsOneWidget);
    });

    testWidgets('an optional choice with no fit rounds up', (tester) async {
      final app = await _open(tester);
      _catalog['جبنة'] = [
        _product(1, 'جبنة ١ كغ', options: [weights(required: false)]),
      ];
      await _send(tester, app, 'ربع كيلو جبنة');
      _expectLine(tester, 'جبنة ١ كغ', 1);
      expect(find.text('الجبنة بتنباع بالكيلو، حطيتلك كيلو'), findsOneWidget);
    });

    testWidgets('كيلو ونص rounds up to the next kilo', (tester) async {
      final app = await _open(tester);
      await _send(tester, app, 'كيلو ونص بندورة');
      _expectLine(tester, 'بندورة ١ كغ', 2);
      expect(
        find.text('البندورة بتنباع بالكيلو، حطيتلك كيلوين'),
        findsOneWidget,
      );
    });

    testWidgets('half a litre is sold by the litre', (tester) async {
      final app = await _open(tester);
      await _send(tester, app, 'نص لتر حليب');
      expect(find.text('الحليب بتنباع باللتر، حطيتلك لتر'), findsOneWidget);
    });

    testWidgets('the pack in the name makes the amount exact', (tester) async {
      final app = await _open(tester);
      _catalog['جبنة'] = [_product(1, 'جبنة ٥٠٠ غ')];
      await _send(tester, app, 'كيلو جبنة');

      _expectLine(tester, 'جبنة ٥٠٠ غ', 2);
      expect(find.textContaining('قرّبت'), findsNothing);
      expect(find.textContaining('بتنباع'), findsNothing);
    });

    testWidgets('a pack that is not a kilo is never called one', (
      tester,
    ) async {
      final app = await _open(tester);
      _catalog['جبنة'] = [_product(1, 'جبنة ٥٠٠ غ')];
      await _send(tester, app, 'كيلو ونص وربع جبنة');

      expect(find.textContaining('بالكيلو'), findsNothing);
    });

    testWidgets('a tray of 30 covers a dozen', (tester) async {
      final app = await _open(tester);
      _catalog['جبنة'] = [_product(1, 'جبنة (طبق ٣٠)')];
      await _send(tester, app, 'دزينة جبنة');

      _expectLine(tester, 'جبنة (طبق ٣٠)', 1);
      expect(find.textContaining('قرّبت كمية'), findsOneWidget);
    });

    testWidgets('quantities can be edited before comparing', (tester) async {
      final app = await _open(tester);
      await _send(tester, app, 'نص كيلو بندورة');
      expect(find.textContaining('بتنباع'), findsOneWidget);

      await tester.tap(
        find
            .descendant(
              of: find.byType(BarqQtyStepper),
              matching: find.byType(GestureDetector),
            )
            .first,
      );
      await app.settle(tester);

      _expectLine(tester, 'بندورة ١ كغ', 2);
      expect(find.textContaining('بتنباع'), findsNothing);
      await _tap(tester, app, 'تمام، قارن المتاجر');
      final body =
          app.server.bodies['POST /baskets/compare']! as Map<String, dynamic>;
      expect(body['cart'], [
        {'product_id': 1, 'qty': 2},
      ]);
      // A sent list is only for reading.
      expect(find.byType(BarqQtyStepper), findsNothing);
      expect(find.text('بندورة ١ كغ × 2'), findsOneWidget);
    });
  });

  group('English', () {
    testWidgets('plurals search with the singular first', (tester) async {
      expect(ProductMatcher.searchTerms('cucumbers').first, 'cucumber');
      expect(ProductMatcher.searchTerms('tomatoes').first, 'tomato');
      expect(ProductMatcher.searchTerms('Eggs').first, 'Egg');
      expect(ProductMatcher.searchTerms('berries').first, 'berry');
      expect(ProductMatcher.searchTerms('glass'), ['glass']);
    });

    testWidgets('replies follow the app language', (tester) async {
      _catalog['tomato'] = [_product(21, 'Tomatoes 1 kg')];
      _catalog['milk'] = [_product(22, 'Milk 1L')];
      addTearDown(() {
        _catalog.remove('tomato');
        _catalog.remove('milk');
      });
      final app = await _open(tester, prefs: {'barq_language': 'en'});
      await _send(tester, app, 'half a kilo of tomatoes and 2 liter milk');

      _expectLine(tester, 'Tomatoes 1 kg', 1);
      _expectLine(tester, 'Milk 1L', 2);
      expect(find.text('Here is what I found:'), findsOneWidget);
      expect(
        find.text('tomatoes: sold by the kilo, so I added 1 kg.'),
        findsOneWidget,
      );
    });
  });

  group('suggestions', () {
    testWidgets('a preset runs as a list', (tester) async {
      final app = await _open(tester);
      await _tap(tester, app, 'خضار وفواكه');

      _expectLine(tester, 'بندورة ١ كغ', 1);
      _expectLine(tester, 'خيار ١ كغ', 1);
    });

    testWidgets('اكتب قائمتك shows how to write it', (tester) async {
      final app = await _open(tester);
      await _tap(tester, app, 'اكتب قائمتك');
      expect(find.textContaining('اكتب كل صنف مع كميته'), findsOneWidget);
    });

    testWidgets('the last order takes the same way', (tester) async {
      final replies = _server()
        ..['GET /orders'] = Reply([
          {
            'id': 5,
            'code': 'BQ-5',
            'status': {'key': 'delivered', 'is_terminal': true},
            'created_at': '2026-10-30T10:00:00+00:00',
            'items_count': 2,
            'total': _money(2000),
            'rated': false,
          },
        ])
        ..['GET /orders/5'] = Reply({
          'id': 5,
          'code': 'BQ-5',
          'status': {'key': 'delivered', 'is_terminal': true},
          'vendor': {'id': 7, 'name': 'ميني ماركت النور'},
          'items': [
            {'name': 'بندورة', 'qty': 3},
            {'name': 'حليب', 'qty': 2},
          ],
          'price': {'total': _money(2000), 'discount': _money(0)},
          'driver': null,
          'available_actions': <Object>[],
          'rating': null,
        });
      final app = await _open(tester, replies: replies);
      await _tap(tester, app, 'أعد آخر طلب');

      _expectLine(tester, 'بندورة ١ كغ', 3);
      _expectLine(tester, 'حليب ١ لتر', 2);
    });

    testWidgets('no last order', (tester) async {
      final app = await _open(tester);
      await _tap(tester, app, 'أعد آخر طلب');
      expect(find.textContaining('لسا ما عندك طلبات'), findsOneWidget);
    });
  });
}
