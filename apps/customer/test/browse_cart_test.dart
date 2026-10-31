import 'package:barq_customer/app/router.dart';
import 'package:barq_customer/features/browse/data/browse_models.dart';
import 'package:barq_customer/features/cart/data/cart_models.dart';
import 'package:barq_customer/features/cart/state/cart_cubit.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers/test_app.dart';

final _config = <String, Object?>{
  ...configJson,
  'modules': ['basket_compare'],
  'modules_config': {
    'catalog': {
      'cart': {'max_lines': 2, 'max_qty': 3},
    },
  },
};

Map<String, Object?> _money(int amount) => {
  'amount': amount,
  'formatted': '${amount / 100} ₪',
};

Map<String, Object?> _product(
  int id,
  String name, {
  int vendor = 7,
  int price = 600,
  bool inStock = true,
  List<Object> options = const [],
  int? stock = 10,
}) => {
  'id': id,
  'name': name,
  'description': 'وصف $name',
  'image_url': null,
  'price': _money(price),
  'compare_at_price': null,
  'in_stock': inStock,
  'stock': stock,
  'category_id': 9,
  'vendor_id': vendor,
  'options': options,
  'fields': <String, Object>{},
};

const _vendorJson = {
  'id': 7,
  'name': 'ميني ماركت النور',
  'distance_km': null,
  'is_open_now': true,
  'prep_minutes': 15,
  'rating': {'average': 4.8, 'count': 320},
};

const _categories = [
  {'id': 9, 'name': 'خضار وفواكه', 'icon': 'apple'},
  {'id': 10, 'name': 'ألبان', 'icon': 'milk'},
];

const _address = {
  'id': 42,
  'label': 'موقعي',
  'lat': 31.45,
  'lng': 34.39,
  'details': null,
  'is_default': true,
};

Map<String, Object?> _store(
  int id,
  String name,
  int total, {
  bool complete = true,
  bool cheapest = false,
  String? missing,
}) => {
  'vendor': {'id': id, 'name': name, 'logo_url': null, 'open_now': true},
  'cheapest': cheapest,
  'complete': complete,
  'missing_count': complete ? 0 : 1,
  'items_total': _money(total),
  'lines': [
    {
      'product_id': 1,
      'store_product_id': id * 100,
      'name': 'بندورة',
      'qty': 1,
      'unit_price': _money(total),
      'total': _money(total),
      'available': true,
      'reason': null,
    },
    if (!complete)
      {
        'product_id': 2,
        'store_product_id': null,
        'name': 'حليب',
        'qty': 1,
        'unit_price': null,
        'total': null,
        'available': false,
        'reason': missing,
      },
  ],
};

Map<String, Reply> _server({Reply? compare, Reply? products}) => {
  'GET /app/config': Reply(_config),
  'GET /me': const Reply({'name': 'محمد أحمد'}),
  'GET /categories': const Reply(_categories),
  'GET /products':
      products ??
      Reply([
        _product(1, 'بندورة'),
        _product(2, 'حليب'),
        _product(3, 'خيار'),
        _product(4, 'موز', inStock: false),
      ]),
  'GET /products/1': Reply(_product(1, 'بندورة')),
  'GET /vendors': const Reply([_vendorJson]),
  'GET /vendors/7': const Reply(_vendorJson),
  'GET /addresses': const Reply([_address]),
  'POST /baskets/compare':
      compare ??
      Reply({
        'zone': {'id': 9, 'name': 'النصيرات'},
        'items': <Object>[],
        'cheapest_vendor_id': 8,
        'stores': [
          _store(8, 'بقالة البركة', 4400, cheapest: true),
          _store(7, 'ميني ماركت النور', 5300),
          _store(9, 'ماركت السلام', 4100, complete: false, missing: 'not_sold'),
        ],
      }),
};

Future<TestApp> _open(
  WidgetTester tester, {
  Map<String, Reply>? replies,
  Map<String, Object> prefs = const {},
  Size size = phone,
}) async {
  final app = await TestApp.create(
    replies ?? _server(),
    secure: {'barq_token': 'saved'},
    prefs: prefs,
  );
  await app.pump(tester, size: size);
  return app;
}

/// The router's current screen, reached the way a screen pushes it.
Future<void> _go(WidgetTester tester, TestApp app, String path) async {
  GoRouter.of(tester.element(find.byType(Scaffold).first)).push(path);
  await app.settle(tester);
}

void _addToCart(TestApp app, {int id = 1, int vendor = 7}) {
  final added = app.deps.cart.add(
    Product.fromJson(_product(id, id == 1 ? 'بندورة' : 'حليب', vendor: vendor)),
  );
  expect(added, AddResult.added);
}

void main() {
  group('CartCubit', () {
    Product item(int id, {int vendor = 7}) =>
        Product.fromJson(_product(id, 'منتج $id', vendor: vendor));

    testWidgets('limits come from config, and one store only', (tester) async {
      final app = await _open(tester);
      final cart = app.deps.cart;

      expect(cart.add(item(1)), AddResult.added);
      expect(cart.add(item(1), qty: 2), AddResult.added);
      expect(cart.state.lines.single.qty, 3);
      expect(cart.add(item(1)), AddResult.limitReached);
      expect(cart.add(item(2)), AddResult.added);
      expect(cart.add(item(3)), AddResult.limitReached);
      expect(cart.add(item(4, vendor: 8)), AddResult.otherStore);

      cart.replaceWith(item(4, vendor: 8));
      expect(cart.state.vendorId, 8);
      expect(cart.state.count, 1);
    });

    testWidgets('the same product with other choices is another line', (
      tester,
    ) async {
      final app = await _open(tester);
      final cart = app.deps.cart;
      cart.add(item(1), options: {'size': 'small'});
      cart.add(item(1), options: {'size': 'big'});
      expect(cart.state.count, 2);
      expect(cart.state.hasOptions, isTrue);
    });

    testWidgets('qty 0 removes a line, and the last one forgets the store', (
      tester,
    ) async {
      final app = await _open(tester);
      final cart = app.deps.cart..add(item(1));
      cart.setQty(cart.state.lines.single.key, 0);
      expect(cart.state.isEmpty, isTrue);
      expect(cart.state.vendorId, isNull);
    });

    testWidgets('the cart comes back after a restart', (tester) async {
      final first = await _open(tester);
      first.deps.cart.add(item(1), qty: 2);
      final saved = first.deps.prefs.getString('barq_cart')!;

      final second = await TestApp.create(
        _server(),
        prefs: {'barq_cart': saved},
      );
      expect(second.deps.cart.state.lines.single.qty, 2);
      expect(second.deps.cart.state.vendorId, 7);
    });

    testWidgets('a broken saved cart is ignored', (tester) async {
      final app = await TestApp.create(
        _server(),
        prefs: {'barq_cart': '{not json'},
      );
      expect(app.deps.cart.state.isEmpty, isTrue);
    });

    testWidgets('switchStore keeps what the store has, at its prices', (
      tester,
    ) async {
      final app = await _open(tester);
      final cart = app.deps.cart
        ..add(item(1))
        ..add(item(2));
      final store = BasketStore.fromJson(
        _store(9, 'ماركت', 4100, complete: false, missing: 'not_sold'),
      );

      cart.switchStore(store);

      expect(cart.state.vendorId, 9);
      expect(cart.state.lines.single.productId, 900);
      expect(cart.state.lines.single.unitPrice.amount, 4100);
    });

    testWidgets('rebuildFromOrder finds products by exact name', (
      tester,
    ) async {
      final app = await _open(tester);
      final late = await tester.runAsync(
        () => app.deps.cart.rebuildFromOrder(
          vendorId: 7,
          items: [(name: 'بندورة', qty: 2), (name: 'غير موجود', qty: 1)],
        ),
      );
      expect(late, 1);
      expect(app.deps.cart.state.vendorId, 7);
      expect(app.deps.cart.state.lines.single.qty, 2);
    });
  });

  group('browse', () {
    testWidgets('home shows the data, and + updates the cart badge', (
      tester,
    ) async {
      final app = await _open(tester);

      expect(find.text('محمد أحمد'), findsOneWidget);
      expect(find.text('خضار وفواكه'), findsOneWidget);
      expect(find.text('بندورة'), findsOneWidget);
      expect(find.text('6.0 ₪'), findsWidgets);
      expect(find.text('الأكثر طلبًا'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byType(BarqPlusButton).first);
      await tester.pump();

      expect(app.deps.cart.state.count, 1);
      expect(tester.widget<BarqNavBar>(find.byType(BarqNavBar)).fabBadge, 1);
    });

    testWidgets('home shows the server error, and retry works', (tester) async {
      final replies = _server();
      replies['GET /products'] = const Reply(
        null,
        status: 500,
        error: 'server_error',
      );
      final app = await _open(tester, replies: replies);
      expect(find.text('رسالة السيرفر'), findsOneWidget);

      replies['GET /products'] = Reply([_product(1, 'بندورة')]);
      await tester.tap(find.text('إعادة المحاولة'));
      await app.settle(tester);
      expect(find.text('بندورة'), findsOneWidget);
    });

    testWidgets('home has an empty state', (tester) async {
      await _open(tester, replies: _server(products: const Reply(<Object>[])));
      expect(find.text('لا توجد منتجات هنا بعد'), findsOneWidget);
    });

    testWidgets('a home chip opens the tab on that category', (tester) async {
      final app = await _open(tester);
      await tester.tap(find.text('خضار وفواكه'));
      await app.settle(tester);

      expect(app.server.queries['GET /products']!['category'], 9);
      expect(find.widgetWithText(BarqHeader, 'خضار وفواكه'), findsOneWidget);
    });

    testWidgets('the categories tab loads the next page near the end', (
      tester,
    ) async {
      final replies = _server(
        products: Reply(
          [for (var i = 1; i <= 8; i++) _product(i, 'منتج $i')],
          meta: const {'page': 1, 'per_page': 20, 'total': 16, 'last_page': 2},
        ),
      );
      final app = await _open(tester, replies: replies);
      await tester.tap(find.text('الأقسام'));
      await app.settle(tester);
      expect(app.server.queries['GET /products']!['page'], 1);

      await tester.drag(
        find.byType(CustomScrollView).last,
        const Offset(0, -600),
      );
      await app.settle(tester);
      expect(app.server.queries['GET /products']!['page'], 2);
      expect(tester.takeException(), isNull);
    });

    testWidgets('search waits 400ms, sends one request, and remembers', (
      tester,
    ) async {
      final app = await _open(tester);
      await _go(tester, app, Routes.search);
      final field = find.byType(TextField);
      final before = app.server.calls.where((c) => c == 'GET /products').length;

      await tester.enterText(field, 'ب');
      await tester.pump(const Duration(milliseconds: 200));
      await tester.enterText(field, 'بندورة');
      await tester.pump(const Duration(milliseconds: 399));
      expect(
        app.server.calls.where((c) => c == 'GET /products').length,
        before,
      );

      await app.settle(tester);
      expect(
        app.server.calls.where((c) => c == 'GET /products').length,
        before + 1,
      );
      expect(app.server.queries['GET /products']!['q'], 'بندورة');
      expect(find.text('4 نتيجة'), findsOneWidget);

      await tester.testTextInput.receiveAction(TextInputAction.search);
      await app.settle(tester);
      expect(app.deps.prefs.getStringList('barq_recent_searches'), ['بندورة']);
    });

    testWidgets('search has a no-results state', (tester) async {
      final app = await _open(
        tester,
        replies: _server(products: const Reply(<Object>[])),
      );
      await _go(tester, app, Routes.search);
      await tester.enterText(find.byType(TextField), 'زعتر');
      await app.settle(tester);
      expect(find.text('لا نتائج'), findsOneWidget);
    });

    testWidgets('the store page shows the store and its products', (
      tester,
    ) async {
      final app = await _open(tester);
      await _go(tester, app, Routes.vendorOf(7));

      expect(find.text('ميني ماركت النور'), findsOneWidget);
      expect(find.text('مفتوح'), findsOneWidget);
      expect(find.text('4.8 (320)'), findsOneWidget);
      expect(app.server.queries['GET /products']!['vendor'], 7);
      expect(find.text('عرض السلة'), findsNothing);

      await tester.tap(find.byType(BarqPlusButton).first);
      await tester.pump();
      expect(find.text('عرض السلة'), findsOneWidget);
      expect(find.byType(BarqQtyStepper), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a closed store hides the add buttons', (tester) async {
      final replies = _server();
      replies['GET /vendors/7'] = Reply(<String, Object?>{
        ..._vendorJson,
        'is_open_now': false,
      });
      final app = await _open(tester, replies: replies);
      await _go(tester, app, Routes.vendorOf(7));
      expect(find.text('مغلق'), findsOneWidget);
      expect(find.byType(BarqPlusButton), findsNothing);
    });

    testWidgets('details add to the cart and go back', (tester) async {
      final app = await _open(tester);
      await _go(tester, app, Routes.productOf(1));
      expect(find.text('أضف للسلة · 6.0 ₪'), findsOneWidget);

      await tester.tap(find.text('أضف للسلة · 6.0 ₪'));
      await app.settle(tester);

      expect(app.deps.cart.state.lines.single.qty, 1);
      expect(find.byType(BarqNavBar), findsOneWidget);
    });

    testWidgets('with two pieces the button stops showing a price', (
      tester,
    ) async {
      final app = await _open(tester);
      await _go(tester, app, Routes.productOf(1));
      tester.widget<BarqQtyStepper>(find.byType(BarqQtyStepper)).onChanged(2);
      await app.settle(tester);
      expect(find.text('أضف للسلة'), findsOneWidget);
    });

    testWidgets('required options: first chosen, sent to the cart', (
      tester,
    ) async {
      final replies = _server();
      replies['GET /products/1'] = Reply(
        _product(
          1,
          'لحم',
          options: [
            {
              'key': 'size',
              'label': 'الحجم',
              'type': 'single',
              'required': true,
              'choices': [
                {'key': 'one', 'label': '1 كغ', 'price': _money(0)},
                {'key': 'two', 'label': '2 كغ', 'price': _money(5500)},
              ],
            },
          ],
        ),
      );
      final app = await _open(tester, replies: replies);
      await _go(tester, app, Routes.productOf(1));
      expect(find.text('+55.0 ₪'), findsOneWidget);

      await tester.tap(find.text('2 كغ'));
      await tester.pump();
      expect(find.text('أضف للسلة'), findsOneWidget);

      await tester.tap(find.text('أضف للسلة'));
      await app.settle(tester);
      expect(app.deps.cart.state.lines.single.options, {'size': 'two'});
      expect(app.deps.cart.state.lines.single.optionsLabel, '2 كغ');
    });

    testWidgets('a product of another store asks before emptying', (
      tester,
    ) async {
      final app = await _open(tester);
      _addToCart(app, vendor: 8);
      await _go(tester, app, Routes.productOf(1));

      await tester.tap(find.textContaining('أضف للسلة'));
      await tester.pumpAndSettle();
      expect(find.text('تفريغ السلة؟'), findsOneWidget);

      await tester.tap(find.text('إبقاء السلة'));
      await tester.pumpAndSettle();
      expect(app.deps.cart.state.vendorId, 8);

      await tester.tap(find.textContaining('أضف للسلة'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('تفريغ وإضافة'));
      await app.settle(tester);
      expect(app.deps.cart.state.vendorId, 7);
    });
  });

  group('cart', () {
    testWidgets('an empty cart shows its state and goes home', (tester) async {
      final app = await _open(tester);
      await _go(tester, app, Routes.cart);
      expect(find.text('سلتك فارغة'), findsOneWidget);

      await tester.tap(find.text('تصفّح المتاجر'));
      await app.settle(tester);
      expect(find.text('الأكثر طلبًا'), findsOneWidget);
    });

    testWidgets('the total comes from the server, never added up', (
      tester,
    ) async {
      final app = await _open(tester);
      _addToCart(app);
      _addToCart(app, id: 2);
      await _go(tester, app, Routes.cart);

      expect(find.text('ميني ماركت النور'), findsOneWidget);
      expect(find.text('53.0 ₪'), findsOneWidget);
      expect(find.text('متابعة الطلب · 53.0 ₪'), findsOneWidget);
      final body = app.server.bodies['POST /baskets/compare']! as Map;
      expect(body['dropoff_address_id'], 42);
      expect(body['cart'], [
        {'product_id': 1, 'qty': 1},
        {'product_id': 2, 'qty': 1},
      ]);
    });

    testWidgets('a store out of the comparison shows no total', (tester) async {
      final app = await _open(tester);
      _addToCart(app, vendor: 77);
      final replies = app.server.replies;
      replies['GET /vendors/77'] = Reply(<String, Object?>{
        ..._vendorJson,
        'id': 77,
      });
      await _go(tester, app, Routes.cart);

      expect(find.text('متابعة الطلب'), findsOneWidget);
      expect(find.text('يُحسب عند تأكيد الطلب'), findsNWidgets(2));
    });

    testWidgets('the cart stays usable when the server fails', (tester) async {
      final app = await _open(
        tester,
        replies: _server(
          compare: const Reply(null, status: 500, error: 'server_error'),
        ),
      );
      _addToCart(app);
      await _go(tester, app, Routes.cart);
      expect(find.text('متابعة الطلب'), findsOneWidget);
      expect(find.text('بندورة'), findsOneWidget);
    });

    testWidgets('a line goes with the stepper, then the empty state shows', (
      tester,
    ) async {
      final app = await _open(tester);
      _addToCart(app);
      await _go(tester, app, Routes.cart);

      final stepper = tester.widget<BarqQtyStepper>(
        find.byType(BarqQtyStepper),
      );
      stepper.onChanged(0);
      await app.settle(tester);
      expect(find.text('سلتك فارغة'), findsOneWidget);
    });

    testWidgets('the trash button asks, then empties', (tester) async {
      final app = await _open(tester);
      _addToCart(app);
      await _go(tester, app, Routes.cart);

      await tester.tap(find.byType(BarqIconButton).at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('إفراغ السلة'));
      await tester.pumpAndSettle();
      expect(app.deps.cart.state.isEmpty, isTrue);
    });

    testWidgets('the cart page does not overflow on a small phone', (
      tester,
    ) async {
      final app = await _open(tester, size: smallPhone);
      _addToCart(app);
      await _go(tester, app, Routes.cart);
      expect(tester.takeException(), isNull);
    });
  });

  group('compare', () {
    testWidgets('the best store is first, and choosing moves the cart', (
      tester,
    ) async {
      final app = await _open(tester);
      _addToCart(app);
      await _go(tester, app, Routes.cart);
      await _go(tester, app, Routes.compare);

      expect(find.text('متاجر منطقتك: النصيرات'), findsOneWidget);
      expect(find.text('الأوفر'), findsOneWidget);
      expect(find.text('ناقص 1 · حليب'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('اختيار الأوفر · 44.0 ₪'));
      await app.settle(tester);
      expect(app.deps.cart.state.vendorId, 8);
      expect(app.deps.cart.state.lines.single.productId, 800);
    });

    testWidgets('tapping another store changes the button', (tester) async {
      final app = await _open(tester);
      _addToCart(app);
      await _go(tester, app, Routes.compare);

      await tester.tap(find.text('ميني ماركت النور'));
      await tester.pump();
      expect(find.text('اختيار ميني ماركت النور · 53.0 ₪'), findsOneWidget);
    });

    testWidgets('no complete store: its own screen', (tester) async {
      final app = await _open(
        tester,
        replies: _server(
          compare: Reply({
            'zone': {'id': 9, 'name': 'النصيرات'},
            'items': <Object>[],
            'cheapest_vendor_id': null,
            'stores': [
              _store(
                8,
                'بقالة البركة',
                2500,
                complete: false,
                missing: 'not_sold',
              ),
              _store(
                9,
                'ماركت السلام',
                1900,
                complete: false,
                missing: 'not_enough_stock',
              ),
            ],
          }),
        ),
      );
      _addToCart(app);
      await _go(tester, app, Routes.compare);

      expect(find.text('ما في متجر عنده كل سلتك'), findsOneWidget);
      expect(find.text('ناقص 1 · الكمية غير كافية'), findsOneWidget);
      expect(find.text('أكمل من بقالة البركة'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('out_of_zone opens the out-of-zone screen', (tester) async {
      final app = await _open(
        tester,
        replies: _server(
          compare: const Reply(null, status: 422, error: 'out_of_zone'),
        ),
      );
      _addToCart(app);
      await _go(tester, app, Routes.compare);
      expect(find.text('لا نوصل لهذا العنوان بعد'), findsOneWidget);
      expect(find.text('422 out_of_zone'), findsOneWidget);
    });

    testWidgets('no address asks for one', (tester) async {
      final replies = _server();
      replies['GET /addresses'] = const Reply(<Object>[]);
      final app = await _open(tester, replies: replies);
      _addToCart(app);
      await _go(tester, app, Routes.compare);
      expect(find.text('ما عندك عنوان توصيل'), findsOneWidget);
    });

    testWidgets('no store delivers: an empty state', (tester) async {
      final app = await _open(
        tester,
        replies: _server(
          compare: const Reply({
            'zone': {'id': 9, 'name': 'النصيرات'},
            'items': <Object>[],
            'cheapest_vendor_id': null,
            'stores': <Object>[],
          }),
        ),
      );
      _addToCart(app);
      await _go(tester, app, Routes.compare);
      expect(find.text('ما في متاجر بتوصّل لعنوانك حاليًا'), findsOneWidget);
    });

    testWidgets('a failure shows the server message and retries', (
      tester,
    ) async {
      final replies = _server(
        compare: const Reply(null, status: 500, error: 'server_error'),
      );
      final app = await _open(tester, replies: replies);
      _addToCart(app);
      await _go(tester, app, Routes.compare);
      expect(find.text('رسالة السيرفر'), findsOneWidget);

      replies['POST /baskets/compare'] = _server()['POST /baskets/compare']!;
      await tester.tap(find.text('إعادة المحاولة'));
      await app.settle(tester);
      expect(find.text('الأوفر'), findsOneWidget);
    });
  });

  test('a saved line keeps every field', () {
    final line = CartLine.fromJson(
      CartLine(
        productId: 1,
        name: 'لحم',
        imageUrl: null,
        categoryIcon: 'apple',
        unitPrice: Product.fromJson(_product(1, 'لحم')).price,
        qty: 2,
        options: const {'size': 'one'},
        optionsLabel: '1 كغ',
      ).toJson(),
    );
    expect(line.key, '1|{"size":"one"}');
    expect(line.unitPrice.formatted, '6.0 ₪');
    expect(line.optionsLabel, '1 كغ');
    expect(line.categoryIcon, 'apple');
  });
}
