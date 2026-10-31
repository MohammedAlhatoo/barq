import 'package:barq_driver/features/earnings/ui/earnings_screen.dart';
import 'package:barq_driver/features/history/ui/history_screen.dart';
import 'package:barq_driver/features/jobs/ui/jobs_screen.dart';
import 'package:barq_driver/features/notifications/ui/notifications_screen.dart';
import 'package:barq_driver/features/profile/ui/account_screen.dart';
import 'package:barq_driver/features/task/ui/deliver_screen.dart';
import 'package:barq_driver/features/task/ui/photo_screen.dart';
import 'package:barq_driver/features/task/ui/task_screen.dart';
import 'package:barq_driver/features/task/ui/too_far_screen.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_app.dart';

const _transition = 'POST /driver/orders/42/transition';
const _deliver = 'POST /driver/orders/42/deliver';
const _current = 'GET /driver/orders/current';

const _pickupConfirm = 'متأكد إنك استلمت الطلب؟';

Map<String, Object?> _pickup() => jobJson(
  status: 'accepted',
  mine: true,
  next: nextActionJson(
    requires: ['photo'],
    confirm: _pickupConfirm,
    geofence: 100,
  ),
);

Map<String, Object?> _atDoor() => jobJson(
  status: 'arrived',
  mine: true,
  next: nextActionJson(
    action: 'deliver',
    to: 'delivered',
    label: 'تم التسليم',
    requires: ['photo'],
    confirm: 'تأكد من استلام الزبون للطلب',
  ),
);

Map<String, Reply> _server(Map<String, Object?> job) => {
  ...quietServer(),
  'GET /driver/me': Reply(driverJson(online: true)),
  _current: Reply(job),
  'POST /uploads': const Reply({'upload_id': 77}, status: 201),
};

Future<void> _openTask(WidgetTester tester, TestApp app) async {
  final bar = tester.getRect(find.byType(BarqNavBar));
  await tester.tapAt(Offset(bar.center.dx, bar.top + 20));
  await app.settle(tester);
}

Future<void> _shoot(WidgetTester tester, TestApp app) async {
  await tester.tap(find.byType(BarqShutterButton));
  await app.settle(tester);
}

void main() {
  group('photo at the store', () {
    testWidgets('needs a photo, then confirm, then sends upload_ids', (
      tester,
    ) async {
      final r = _server(_pickup());
      r[_transition] = Reply(
        jobJson(
          status: 'picked_up',
          mine: true,
          next: nextActionJson(to: 'on_the_way', label: 'انطلقت'),
        ),
      );
      final app = await TestApp.create(r, secure: logged);
      await app.pump(tester);
      await _openTask(tester, app);

      await tester.tap(find.text('استلمت الطلب'));
      await app.settle(tester);
      expect(find.byType(PhotoScreen), findsOneWidget);
      final button = find.widgetWithText(BarqButton, 'استلمت الطلب');
      expect(tester.widget<BarqButton>(button).onPressed, isNull);

      await _shoot(tester, app);
      expect(tester.widget<BarqButton>(button).onPressed, isNotNull);

      await tester.tap(button);
      await app.settle(tester);
      expect(find.text(_pickupConfirm), findsOneWidget);
      await tester.tap(find.text('استلمت الطلب').last);
      await app.settle(tester);

      final body = app.server.bodies[_transition]! as Map;
      expect(body['to'], 'picked_up');
      expect(body['upload_ids'], [77]);
      expect(find.byType(PhotoScreen), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('closing the camera keeps the button off', (tester) async {
      final app = await TestApp.create(_server(_pickup()), secure: logged);
      app.photos.closesCamera = true;
      await app.pump(tester);
      await _openTask(tester, app);
      await tester.tap(find.text('استلمت الطلب'));
      await app.settle(tester);
      await _shoot(tester, app);
      final button = find.widgetWithText(BarqButton, 'استلمت الطلب');
      expect(tester.widget<BarqButton>(button).onPressed, isNull);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('too far opens the screen; retry never uploads twice', (
      tester,
    ) async {
      final r = _server(_pickup());
      r['POST /driver/location'] = const Reply({});
      r[_transition] = const Reply(
        null,
        status: 422,
        error: 'out_of_zone',
        details: {'distance_meters': 420},
      );
      final app = await TestApp.create(r, secure: logged);
      await app.pump(tester);
      await _openTask(tester, app);
      await tester.tap(find.text('استلمت الطلب'));
      await app.settle(tester);
      await _shoot(tester, app);
      await tester.tap(find.widgetWithText(BarqButton, 'استلمت الطلب'));
      await app.settle(tester);
      await tester.tap(find.text('استلمت الطلب').last);
      await app.settle(tester);

      expect(find.byType(TooFarScreen), findsOneWidget);
      expect(find.text('أنت بعيد عن المتجر'), findsOneWidget);
      expect(find.text('على بعد 420 م من الموقع'), findsOneWidget);
      expect(find.textContaining('ضمن 100 متر'), findsOneWidget);

      await tester.tap(find.text('افتح الملاحة'));
      await app.settle(tester);
      expect(app.actions.navigated, ['31.45,34.39']);

      await tester.tap(find.text('حاول مرة أخرى'));
      await app.settle(tester);
      expect(app.server.calls, contains('POST /driver/location'));
      expect(app.server.calls.where((c) => c == 'POST /uploads'), hasLength(1));
      expect(app.server.calls.where((c) => c == _transition), hasLength(2));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('a refusal about something else stays a note', (tester) async {
      final r = _server(_pickup());
      r[_transition] = const Reply(
        null,
        status: 422,
        error: 'validation_failed',
        details: {
          'fields': {
            'upload_ids': ['الصورة مطلوبة'],
          },
        },
      );
      final app = await TestApp.create(r, secure: logged);
      await app.pump(tester);
      await _openTask(tester, app);
      await tester.tap(find.text('استلمت الطلب'));
      await app.settle(tester);
      await _shoot(tester, app);
      await tester.tap(find.widgetWithText(BarqButton, 'استلمت الطلب'));
      await app.settle(tester);
      await tester.tap(find.text('استلمت الطلب').last);
      await app.settle(tester);
      expect(find.byType(TooFarScreen), findsNothing);
      expect(find.text('الصورة مطلوبة'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('delivery at the door', () {
    testWidgets('shows the cash, sends no code, and ends on the jobs', (
      tester,
    ) async {
      final r = _server(_atDoor());
      r[_deliver] = Reply(jobJson(status: 'delivered', mine: true));
      final app = await TestApp.create(r, secure: logged);
      await app.pump(tester);
      await _openTask(tester, app);

      await tester.tap(find.text('تم التسليم'));
      await app.settle(tester);
      expect(find.byType(DeliverScreen), findsOneWidget);
      expect(find.text('51.00 ₪'), findsOneWidget);
      final button = find.widgetWithText(BarqButton, 'تم التسليم');
      expect(tester.widget<BarqButton>(button).onPressed, isNull);

      await tester.ensureVisible(find.text('التقاط الصورة'));
      await tester.pump();
      await tester.tap(find.text('التقاط الصورة'));
      await app.settle(tester);
      expect(find.text('تم التقاط الصورة'), findsOneWidget);

      r[_current] = const Reply(null);
      app.server.calls.clear();
      await tester.ensureVisible(button);
      await tester.pump();
      await tester.tap(button);
      await app.settle(tester);
      expect(find.text('تأكد من استلام الزبون للطلب'), findsOneWidget);
      await tester.tap(find.text('تم التسليم').last);
      await app.settle(tester);

      final body = app.server.bodies[_deliver]! as Map;
      expect(body['upload_ids'], [77]);
      expect(body.containsKey('otp'), isFalse);
      expect(app.server.headers[_deliver]?['Idempotency-Key'], isNotNull);
      expect(find.byType(TaskScreen), findsNothing);
      expect(find.byType(JobsScreen), findsOneWidget);
      expect(app.server.calls, contains('GET /driver/earnings'));
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('tabs', () {
    Future<TestApp> open(
      WidgetTester tester,
      Map<String, Reply> extra,
      String tab,
    ) async {
      final app = await TestApp.create({
        ...quietServer(),
        'GET /driver/orders/history': const Reply(<Object>[]),
        ...extra,
      }, secure: logged);
      await app.pump(tester);
      await tester.tap(find.text(tab));
      await app.settle(tester);
      return app;
    }

    testWidgets('earnings ask the chosen period and show the cash', (
      tester,
    ) async {
      final app = await open(tester, {}, 'الأرباح');
      expect(find.byType(EarningsScreen), findsOneWidget);
      expect(app.server.queries['GET /driver/earnings']?['period'], 'week');
      expect(find.text('500.00 ₪'), findsOneWidget);

      await tester.tap(find.text('الشهر'));
      await app.settle(tester);
      expect(app.server.queries['GET /driver/earnings']?['period'], 'month');
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('history filters in the app', (tester) async {
      Map<String, Object?> order(int id, String status) => {
        'id': id,
        'code': 'BR-$id',
        'status': {'key': status},
        'created_at': '2026-10-31T10:00:00+00:00',
        'completed_at': null,
        'dropoff': {'label': 'مكان $id'},
        'total': money('51.00 ₪'),
      };
      final app = await open(tester, {
        'GET /driver/orders/history': Reply([
          order(1, 'delivered'),
          order(2, 'cancelled'),
        ]),
      }, 'السجل');
      expect(find.byType(HistoryScreen), findsOneWidget);
      expect(find.text('مكان 1'), findsOneWidget);
      expect(find.text('مكان 2'), findsOneWidget);

      await tester.ensureVisible(find.text('ملغاة'));
      await tester.pump();
      await tester.tap(find.text('ملغاة'));
      await app.settle(tester);
      expect(find.text('مكان 1'), findsNothing);
      expect(find.text('مكان 2'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('history shows the empty state', (tester) async {
      final app = await open(tester, {}, 'السجل');
      expect(find.text('ما في مهام هون'), findsOneWidget);
      expect(app.server.calls, contains('GET /driver/orders/history'));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('settings save only vehicle and locale, then the language', (
      tester,
    ) async {
      final app = await open(tester, {
        'PUT /driver/me': Reply({...driverJson(), 'vehicle_type': 'car'}),
      }, 'حسابي');
      expect(find.byType(AccountScreen), findsOneWidget);
      expect(find.text('دراجة نارية'), findsOneWidget);

      await tester.tap(find.text('المركبة'));
      await app.settle(tester);
      await tester.tap(find.text('سيارة'));
      await tester.pump();
      await tester.tap(find.text('English'));
      await tester.pump();
      await tester.tap(find.text('حفظ'));
      await app.settle(tester);

      final body = app.server.bodies['PUT /driver/me']! as Map;
      expect(body.keys.toSet(), {'vehicle_type', 'locale'});
      expect(body['vehicle_type'], 'car');
      expect(body['locale'], 'en');
      expect(find.text('Car'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('logout ends the session and opens the login', (tester) async {
      final app = await open(tester, {
        'POST /driver/auth/logout': const Reply(null),
      }, 'حسابي');
      await tester.tap(find.text('تسجيل الخروج'));
      await app.settle(tester);
      expect(app.deps.auth.isLoggedIn, isFalse);
      expect(find.text('سجّل دخولك كسائق'), findsOneWidget);
    });

    testWidgets('notifications list, read all and report a tap', (
      tester,
    ) async {
      final item = {
        'id': 5,
        'event': 'order.new',
        'title': 'طلب جديد قريب منك',
        'body': 'ميني ماركت النور',
        'data': <String, Object>{},
        'read_at': null,
        'opened_at': null,
        'created_at': '2026-10-31T10:00:00+00:00',
      };
      final app = await open(tester, {
        'GET /driver/notifications': Reply([item]),
        'POST /driver/notifications/5/opened': const Reply(<String, Object>{}),
        'POST /driver/notifications/read-all': const Reply({'marked': 1}),
      }, 'حسابي');
      await tester.tap(find.text('الإشعارات'));
      await app.settle(tester);
      expect(find.byType(NotificationsScreen), findsOneWidget);

      await tester.tap(find.text('طلب جديد قريب منك'));
      await app.settle(tester);
      expect(app.server.calls, contains('POST /driver/notifications/5/opened'));

      await tester.tap(find.text('قراءة الكل'));
      await app.settle(tester);
      expect(app.server.calls, contains('POST /driver/notifications/read-all'));
      await tester.pumpWidget(const SizedBox());
    });
  });

  testWidgets('the splash is the dark Captain one, not the orange customer', (
    tester,
  ) async {
    final app = await TestApp.create(quietServer());
    tester.view.physicalSize = phone;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const SizedBox());
    await app.pumpFirstFrame(tester);
    expect(find.byType(BarqCaptainSplash), findsOneWidget);
    expect(find.byType(BarqSplashContent), findsNothing);
    await app.settle(tester);
  });
}
