import 'dart:convert';
import 'dart:io';

import 'package:barq_customer/app/router.dart';
import 'package:barq_customer/features/account/ui/address_form_screen.dart';
import 'package:barq_customer/features/account/ui/widgets/address_picker_sheet.dart';
import 'package:barq_customer/features/browse/data/browse_models.dart';
import 'package:barq_customer/features/browse/state/search_cubit.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers/test_app.dart';

const _home = {
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
  'details': 'شارع البحر',
  'is_default': false,
};

const _family = {
  'id': 3,
  'label': 'بيت أهلي',
  'lat': 31.42,
  'lng': 34.36,
  'details': null,
  'is_default': false,
};

const _me = {
  'id': 5,
  'name': 'محمد أحمد',
  'phone': '+970599123456',
  'avatar_url': null,
  'locale': 'ar',
  'has_fcm_token': false,
  'created_at': '2026-01-01T00:00:00Z',
};

Map<String, Reply> _server({List<Object> addresses = const [_home, _work]}) => {
  'GET /app/config': const Reply(configJson),
  'GET /me': const Reply(_me),
  'PUT /me': const Reply(_me),
  'DELETE /me': const Reply(null),
  'GET /categories': const Reply(<Object>[]),
  'GET /products': const Reply(<Object>[]),
  'GET /vendors': const Reply(<Object>[]),
  'GET /addresses': Reply(addresses),
  'POST /addresses': const Reply(_home, status: 201),
  'PUT /addresses/1': const Reply(_home),
  'PUT /addresses/2': const Reply(_work),
  'PUT /addresses/3': const Reply(_family),
  'DELETE /addresses/2': const Reply(null),
  'GET /orders': const Reply(<Object>[], meta: {'total': 12}),
  'GET /notifications': const Reply(<Object>[], meta: {'total': 2}),
  'POST /auth/logout': const Reply(null),
  'POST /uploads': const Reply({'upload_id': 77}, status: 201),
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

Future<void> _push(
  WidgetTester tester,
  TestApp app,
  String path, {
  Object? extra,
}) async {
  GoRouter.of(tester.element(find.byType(Scaffold).first))
      .push<Object?>(path, extra: extra);
  await app.settle(tester);
}

Future<void> _openAccountTab(WidgetTester tester, TestApp app) async {
  await tester.tap(find.text('حسابي').last);
  await app.settle(tester);
}

Future<void> _tap(WidgetTester tester, TestApp app, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await app.settle(tester);
}

Product _tomato() => Product.fromJson({
  'id': 1,
  'name': 'بندورة',
  'description': null,
  'image_url': null,
  'price': {'amount': 600, 'formatted': '6.00 ₪'},
  'compare_at_price': null,
  'in_stock': true,
  'stock': 10,
  'category_id': 9,
  'vendor_id': 7,
  'options': <Object>[],
  'fields': <String, Object>{},
});

void main() {
  group('account', () {
    testWidgets('shows the server numbers and never a made-up saving', (
      tester,
    ) async {
      final app = await _open(tester);
      await _openAccountTab(tester, app);

      expect(find.text('محمد أحمد'), findsOneWidget);
      expect(find.text('059 912 3456'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('طلب'), findsOneWidget);
      expect(find.text('عناوين'), findsOneWidget);
      expect(find.text('2'), findsWidgets);
      expect(find.text('وفّرت'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a failed count hides that number, not the screen', (
      tester,
    ) async {
      final replies = _server();
      replies['GET /orders'] = const Reply(null, status: 500, error: 'x');
      final app = await _open(tester, replies: replies);
      await _openAccountTab(tester, app);

      expect(find.text('محمد أحمد'), findsOneWidget);
      expect(find.text('طلب'), findsNothing);
      expect(find.text('عناوين'), findsOneWidget);
    });

    testWidgets('a failed profile shows the error, and retry works', (
      tester,
    ) async {
      final replies = _server();
      replies['GET /me'] = const Reply(null, status: 500, error: 'x');
      final app = await _open(tester, replies: replies);
      await _openAccountTab(tester, app);

      expect(find.text('رسالة السيرفر'), findsWidgets);
      replies['GET /me'] = const Reply(_me);
      await _tap(tester, app, find.text('إعادة المحاولة').last);
      expect(find.text('059 912 3456'), findsOneWidget);
    });

    testWidgets('logout clears this phone and opens login', (tester) async {
      final app = await _open(
        tester,
        prefs: {
          SearchCubit.recentKey: ['بندورة'],
        },
      );
      app.deps.cart.add(_tomato());
      await _openAccountTab(tester, app);

      await _tap(tester, app, find.text('تسجيل الخروج'));
      expect(app.server.calls, isNot(contains('POST /auth/logout')));
      await _tap(tester, app, find.text('تسجيل الخروج').last);

      expect(app.server.calls, contains('POST /auth/logout'));
      expect(app.deps.auth.isLoggedIn, isFalse);
      expect(app.deps.cart.state.isEmpty, isTrue);
      expect(app.deps.prefs.getStringList(SearchCubit.recentKey), isNull);
      expect(find.text('أدخل رقم جوالك'), findsOneWidget);
    });

    testWidgets('a failed logout keeps the user in, with the reason', (
      tester,
    ) async {
      final replies = _server();
      replies['POST /auth/logout'] = const Reply(
        null,
        status: 500,
        error: 'server_error',
      );
      final app = await _open(tester, replies: replies);
      await _openAccountTab(tester, app);
      await _tap(tester, app, find.text('تسجيل الخروج'));
      await _tap(tester, app, find.text('تسجيل الخروج').last);

      expect(app.deps.auth.isLoggedIn, isTrue);
      expect(find.text('رسالة السيرفر'), findsOneWidget);
    });

    testWidgets('fits a small phone', (tester) async {
      final app = await _open(tester, size: smallPhone);
      await _openAccountTab(tester, app);
      expect(tester.takeException(), isNull);
    });
  });

  group('edit profile', () {
    testWidgets('saves the name and language, then applies the language', (
      tester,
    ) async {
      final app = await _open(tester);
      await _push(tester, app, Routes.accountEdit);

      expect(find.text('محمد أحمد'), findsOneWidget);
      expect(find.text('059 912 3456'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'سارة خالد');
      await tester.pump();
      await tester.tap(find.text('English'));
      await tester.pump();
      expect(app.deps.locale.state.languageCode, 'ar');

      await _tap(tester, app, find.text('حفظ التغييرات'));

      expect(app.server.bodies['PUT /me'], {
        'name': 'سارة خالد',
        'locale': 'en',
      });
      expect(app.deps.locale.state.languageCode, 'en');
    });

    testWidgets('a picked photo is uploaded once, even after a failed save', (
      tester,
    ) async {
      final replies = _server();
      replies['PUT /me'] = const Reply(null, status: 500, error: 'x');
      final app = await _open(tester, replies: replies);
      final dir = Directory.systemTemp.createTempSync('barq_avatar');
      addTearDown(() => dir.deleteSync(recursive: true));
      final file = File('${dir.path}/a.png')
        ..writeAsBytesSync(
          base64Decode(
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk'
            'YPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
          ),
        );
      (app.deps.avatarPicker as FakeAvatarPicker).file = file;
      await _push(tester, app, Routes.accountEdit);

      await _tap(tester, app, find.byType(BarqAvatar));
      await _tap(tester, app, find.text('حفظ التغييرات'));
      expect(find.text('رسالة السيرفر'), findsOneWidget);

      replies['PUT /me'] = const Reply(_me);
      await _tap(tester, app, find.text('حفظ التغييرات'));

      expect(
        app.server.calls.where((call) => call == 'POST /uploads'),
        hasLength(1),
      );
      expect((app.server.bodies['PUT /me']! as Map)['avatar_upload_id'], 77);
    });

    testWidgets('a name of one letter cannot be saved', (tester) async {
      final app = await _open(tester);
      await _push(tester, app, Routes.accountEdit);

      await tester.enterText(find.byType(TextField).first, 'م');
      await tester.pump();
      await _tap(tester, app, find.text('حفظ التغييرات'));

      expect(app.server.calls, isNot(contains('PUT /me')));
    });

    testWidgets('a failed load shows the error, and retry works', (
      tester,
    ) async {
      final replies = _server();
      replies['GET /me'] = const Reply(null, status: 500, error: 'x');
      final app = await _open(tester, replies: replies);
      await _push(tester, app, Routes.accountEdit);

      expect(find.text('رسالة السيرفر'), findsWidgets);
      replies['GET /me'] = const Reply(_me);
      await _tap(tester, app, find.text('إعادة المحاولة').last);
      expect(find.text('حفظ التغييرات'), findsOneWidget);
    });

    testWidgets('fits a small phone', (tester) async {
      final app = await _open(tester, size: smallPhone);
      await _push(tester, app, Routes.accountEdit);
      expect(tester.takeException(), isNull);
    });
  });

  group('delete account', () {
    testWidgets('the button works only after the box is ticked', (
      tester,
    ) async {
      final app = await _open(tester);
      app.deps.cart.add(_tomato());
      await _push(tester, app, Routes.accountDelete);

      await _tap(tester, app, find.text('حذف الحساب').last);
      expect(app.server.calls, isNot(contains('DELETE /me')));

      await _tap(tester, app, find.text('أفهم أن حذف الحساب نهائي'));
      await _tap(tester, app, find.text('حذف الحساب').last);

      expect(app.server.calls, contains('DELETE /me'));
      expect(app.deps.auth.isLoggedIn, isFalse);
      expect(app.deps.cart.state.isEmpty, isTrue);
      expect(find.text('أدخل رقم جوالك'), findsOneWidget);
    });

    testWidgets('a refusal shows the server reason and keeps the account', (
      tester,
    ) async {
      final replies = _server();
      replies['DELETE /me'] = const Reply(
        null,
        status: 409,
        error: 'active_orders',
      );
      final app = await _open(tester, replies: replies);
      await _push(tester, app, Routes.accountDelete);

      await _tap(tester, app, find.text('أفهم أن حذف الحساب نهائي'));
      await _tap(tester, app, find.text('حذف الحساب').last);

      expect(find.text('رسالة السيرفر'), findsOneWidget);
      expect(app.deps.auth.isLoggedIn, isTrue);
    });

    testWidgets('fits a small phone', (tester) async {
      final app = await _open(tester, size: smallPhone);
      await _push(tester, app, Routes.accountDelete);
      expect(tester.takeException(), isNull);
    });
  });

  group('addresses', () {
    testWidgets('the list marks the default from the server', (tester) async {
      final app = await _open(tester);
      await _push(tester, app, Routes.addresses);

      expect(find.text('البيت'), findsOneWidget);
      expect(find.text('قرب مسجد الهدى'), findsOneWidget);
      expect(find.text('العمل'), findsOneWidget);
      expect(find.text('الافتراضي'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty and error states', (tester) async {
      final replies = _server(addresses: const []);
      final app = await _open(tester, replies: replies);
      await _push(tester, app, Routes.addresses);
      expect(find.text('ما عندك عناوين محفوظة'), findsOneWidget);

      replies['GET /addresses'] = const Reply(null, status: 500, error: 'x');
      await _push(tester, app, Routes.addresses);
      expect(find.text('رسالة السيرفر'), findsOneWidget);
      replies['GET /addresses'] = const Reply([_home]);
      await _tap(tester, app, find.text('إعادة المحاولة').last);
      expect(find.text('البيت'), findsOneWidget);
    });

    testWidgets('delete asks first, then the list comes from the server', (
      tester,
    ) async {
      final replies = _server();
      final app = await _open(tester, replies: replies);
      await _push(tester, app, Routes.addresses);

      await _tap(tester, app, find.byTooltip('حذف').last);
      expect(app.server.calls, isNot(contains('DELETE /addresses/2')));

      replies['GET /addresses'] = const Reply([_home]);
      await _tap(tester, app, find.text('حذف العنوان'));

      expect(app.server.calls, contains('DELETE /addresses/2'));
      expect(find.text('العمل'), findsNothing);
    });

    testWidgets('a failed delete keeps the list and shows why', (tester) async {
      final replies = _server();
      replies['DELETE /addresses/2'] = const Reply(
        null,
        status: 500,
        error: 'x',
      );
      final app = await _open(tester, replies: replies);
      await _push(tester, app, Routes.addresses);

      await _tap(tester, app, find.byTooltip('حذف').last);
      await _tap(tester, app, find.text('حذف العنوان'));

      expect(find.text('العمل'), findsOneWidget);
      expect(find.text('رسالة السيرفر'), findsOneWidget);
    });

    testWidgets('a change reaches Home, which stays alive behind the tabs', (
      tester,
    ) async {
      final app = await _open(tester);
      final before = app.server.calls
          .where((call) => call == 'GET /vendors')
          .length;
      await tester.runAsync(() => app.deps.accountRepository.deleteAddress(2));
      await app.settle(tester);
      expect(
        app.server.calls.where((call) => call == 'GET /vendors').length,
        greaterThan(before),
      );
    });
  });

  group('address form', () {
    testWidgets('a new address sends everything the server needs', (
      tester,
    ) async {
      final app = await _open(tester);
      await _push(tester, app, Routes.addressNew);

      await tester.enterText(find.byType(TextField).last, 'عمارة الأمل');
      await tester.pump();
      await _tap(tester, app, find.text('حفظ العنوان'));

      expect(app.server.bodies['POST /addresses'], {
        'label': 'البيت',
        'lat': 31.45,
        'lng': 34.39,
        'details': 'عمارة الأمل',
        'is_default': true,
      });
      expect(find.byType(AddressFormScreen), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('«أخرى» uses the typed name', (tester) async {
      final app = await _open(tester);
      await _push(tester, app, Routes.addressNew);

      await _tap(tester, app, find.text('أخرى'));
      await tester.enterText(find.byType(TextField).first, 'بيت أهلي');
      await tester.pump();
      await _tap(tester, app, find.text('حفظ العنوان'));

      final body = app.server.bodies['POST /addresses']! as Map;
      expect(body['label'], 'بيت أهلي');
      expect(body['details'], isNull);
    });

    testWidgets('out_of_zone stays on the form with the server message', (
      tester,
    ) async {
      final replies = _server();
      replies['POST /addresses'] = const Reply(
        null,
        status: 422,
        error: 'out_of_zone',
      );
      final app = await _open(tester, replies: replies);
      await _push(tester, app, Routes.addressNew);
      expect(find.text('خارج الخدمة'), findsNothing);
      expect(find.text('داخل الخدمة'), findsNothing);

      await _tap(tester, app, find.text('حفظ العنوان'));

      expect(find.text('خارج الخدمة'), findsOneWidget);
      expect(find.text('رسالة السيرفر'), findsOneWidget);
      expect(find.byType(AddressFormScreen), findsOneWidget);
    });

    testWidgets('editing fills the form and sends PUT to that address', (
      tester,
    ) async {
      final app = await _open(tester);
      await _push(tester, app, Routes.addresses);
      await _tap(tester, app, find.byTooltip('تعديل').at(1));

      expect(find.text('شارع البحر'), findsOneWidget);
      expect(find.text('داخل الخدمة'), findsOneWidget);
      expect(find.text('اجعله العنوان الافتراضي'), findsOneWidget);

      await _tap(tester, app, find.text('حفظ العنوان'));

      expect(app.server.bodies['PUT /addresses/2'], {
        'label': 'العمل',
        'lat': 31.41,
        'lng': 34.35,
        'details': 'شارع البحر',
        'is_default': false,
      });
    });

    testWidgets('the default address has no switch to turn it off', (
      tester,
    ) async {
      final app = await _open(tester);
      await _push(tester, app, Routes.addresses);
      await _tap(tester, app, find.byTooltip('تعديل').first);
      expect(find.text('اجعله العنوان الافتراضي'), findsNothing);
    });

    testWidgets('a label that is not a chip opens on «أخرى» with its name', (
      tester,
    ) async {
      final app = await _open(tester, replies: _server(addresses: [_family]));
      await _push(tester, app, Routes.addresses);
      await _tap(tester, app, find.byTooltip('تعديل').first);
      expect(find.text('بيت أهلي'), findsOneWidget);
    });

    testWidgets('edit without an address goes back to the list', (
      tester,
    ) async {
      final app = await _open(tester);
      await _push(tester, app, Routes.addressEdit);
      expect(find.text('عناويني'), findsOneWidget);
    });

    testWidgets('fits a small phone, even with the keyboard open', (
      tester,
    ) async {
      final app = await _open(tester, size: smallPhone);
      await _push(tester, app, Routes.addressNew);
      await _tap(tester, app, find.text('أخرى'));
      expect(tester.takeException(), isNull);

      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('address picker', () {
    Future<SavedResult> openPicker(WidgetTester tester, TestApp app) async {
      final result = SavedResult();
      final context = tester.element(find.byType(Scaffold).first);
      AddressPickerSheet.show(context).then((address) {
        result.id = address?.id;
        result.done = true;
      });
      await app.settle(tester);
      return result;
    }

    testWidgets('returns the tapped address', (tester) async {
      final app = await _open(tester);
      final result = await openPicker(tester, app);

      expect(find.text('اختر عنوان التوصيل'), findsOneWidget);
      await _tap(tester, app, find.text('العمل'));

      expect(result.done, isTrue);
      expect(result.id, 2);
      expect(tester.takeException(), isNull);
    });

    testWidgets('adding a new one returns it', (tester) async {
      final app = await _open(tester);
      final result = await openPicker(tester, app);

      await _tap(tester, app, find.text('إضافة عنوان جديد'));
      expect(find.byType(AddressFormScreen), findsOneWidget);
      await _tap(tester, app, find.text('حفظ العنوان'));

      expect(result.done, isTrue);
      expect(result.id, 1);
    });

    testWidgets('closing it returns nothing', (tester) async {
      final app = await _open(tester);
      final result = await openPicker(tester, app);

      await tester.tapAt(const Offset(10, 10));
      await app.settle(tester);

      expect(result.done, isTrue);
      expect(result.id, isNull);
    });
  });
}

class SavedResult {
  int? id;
  bool done = false;
}
