import 'package:barq_driver/features/auth/data/phone_number.dart';
import 'package:barq_driver/features/auth/ui/login_screen.dart';
import 'package:barq_driver/features/jobs/data/location_source.dart';
import 'package:barq_driver/features/jobs/ui/cash_limit_screen.dart';
import 'package:barq_driver/features/jobs/ui/jobs_screen.dart';
import 'package:barq_driver/features/jobs/ui/offer_screen.dart';
import 'package:barq_driver/features/task/ui/task_screen.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_app.dart';

const _accept = 'POST /driver/orders/42/accept';
const _transition = 'POST /driver/orders/42/transition';

Map<String, Reply> _online({List<Object> jobs = const []}) => {
  ...quietServer(),
  'GET /driver/me': Reply(driverJson(online: true)),
  'GET /driver/orders/available': Reply(jobs),
};

void main() {
  test('login numbers keep the 0 the server saved them with', () {
    expect(PhoneNumber.normalize('599100001'), '0599100001');
    expect(PhoneNumber.normalize('0599100001'), '0599100001');
    expect(PhoneNumber.isValid('59910'), isFalse);
  });

  testWidgets('without a token the app opens the login, in dark', (
    tester,
  ) async {
    final app = await TestApp.create(quietServer());
    await app.pump(tester);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(
      BarqPalette.of(tester.element(find.byType(LoginScreen))).isDark,
      isTrue,
    );
  });

  testWidgets('login sends the local number and opens the jobs', (
    tester,
  ) async {
    final app = await TestApp.create({
      ...quietServer(),
      'POST /driver/auth/login': const Reply({'token': 'new-token'}),
    });
    await app.pump(tester);
    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(0), '599100001');
    await tester.enterText(fields.at(1), 'secret');
    await tester.pump();
    await tester.tap(find.text('تسجيل الدخول'));
    await app.settle(tester);

    final body = app.server.bodies['POST /driver/auth/login']! as Map;
    expect(body['phone'], '0599100001');
    expect(body['password'], 'secret');
    expect(app.deps.auth.token, 'new-token');
    expect(find.byType(JobsScreen), findsOneWidget);
  });

  testWidgets('a wrong password shows the reason from details.fields', (
    tester,
  ) async {
    final app = await TestApp.create({
      ...quietServer(),
      'POST /driver/auth/login': const Reply(
        null,
        status: 422,
        error: 'validation_failed',
        details: {
          'fields': {
            'phone': ['بيانات الدخول غير صحيحة.'],
          },
        },
      ),
    });
    await app.pump(tester);
    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(0), '0599100001');
    await tester.enterText(fields.at(1), 'wrong');
    await tester.pump();
    await tester.tap(find.text('تسجيل الدخول'));
    await app.settle(tester);
    expect(find.text('بيانات الدخول غير صحيحة.'), findsOneWidget);
  });

  testWidgets('going online sends the location first, then starts tracking', (
    tester,
  ) async {
    final app = await TestApp.create({
      ...quietServer(),
      'POST /driver/location': const Reply({}),
      'PUT /driver/status': Reply(driverJson(online: true)),
    }, secure: logged);
    await app.pump(tester);
    expect(find.text('أنت غير متصل'), findsOneWidget);

    await tester.tap(find.byType(BarqPowerButton));
    await app.settle(tester);

    final location = app.server.calls.indexOf('POST /driver/location');
    final status = app.server.calls.indexOf('PUT /driver/status');
    expect(location, isNonNegative);
    expect(status, greaterThan(location));
    expect(app.deps.tracker.isTracking, isTrue);
    expect(find.text('متصل'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a denied location stays offline and says why', (tester) async {
    final app = await TestApp.create(quietServer(), secure: logged);
    app.location.failure = const LocationFailure(LocationProblem.denied);
    await app.pump(tester);
    await tester.tap(find.byType(BarqPowerButton));
    await app.settle(tester);
    expect(find.textContaining('اسمح للتطبيق'), findsOneWidget);
    expect(app.server.calls, isNot(contains('PUT /driver/status')));
    expect(app.deps.tracker.isTracking, isFalse);
  });

  testWidgets('the list shows server values and accepts into the task', (
    tester,
  ) async {
    final app = await TestApp.create({
      ..._online(jobs: [jobJson()]),
      _accept: Reply(jobJson(status: 'accepted', mine: true)),
      'GET /driver/orders/current': Reply(
        jobJson(
          status: 'accepted',
          mine: true,
          next: nextActionJson(confirm: 'متأكد إنك استلمت الطلب؟'),
        ),
      ),
    }, secure: logged);
    await app.pump(tester);

    expect(find.text('طلبات قريبة (1)'), findsOneWidget);
    expect(find.text('9.00 ₪'), findsOneWidget);
    expect(find.text('تحصيل 51.00 ₪'), findsOneWidget);

    await tester.tap(find.text('قبول'));
    await app.settle(tester);

    expect(app.server.headers[_accept]?['Idempotency-Key'], isNotNull);
    expect(find.byType(TaskScreen), findsOneWidget);
    expect(find.text('استلمت الطلب'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('already_taken stays on the list with the message', (
    tester,
  ) async {
    final app = await TestApp.create({
      ..._online(jobs: [jobJson()]),
      _accept: const Reply(null, status: 409, error: 'already_taken'),
    }, secure: logged);
    await app.pump(tester);
    await tester.tap(find.text('قبول'));
    await app.settle(tester);
    expect(find.text('سبقك سائق آخر لهذا الطلب'), findsOneWidget);
    expect(find.byType(TaskScreen), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('cash_limit_reached opens the cash screen with server money', (
    tester,
  ) async {
    final app = await TestApp.create({
      ..._online(jobs: [jobJson()]),
      _accept: const Reply(null, status: 422, error: 'cash_limit_reached'),
    }, secure: logged);
    await app.pump(tester);
    await tester.tap(find.text('قبول'));
    await app.settle(tester);
    expect(find.byType(CashLimitScreen), findsOneWidget);
    expect(find.textContaining('معك 500.00 ₪'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('تواصل مع الدعم'),
      100,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('تواصل مع الدعم'));
    await app.settle(tester);
    expect(app.actions.called, ['0592525487']);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('ignore hides the order and goes back', (tester) async {
    final app = await TestApp.create({
      ..._online(jobs: [jobJson()]),
      'GET /driver/orders/42': Reply(jobJson()),
      'POST /driver/orders/42/reject': const Reply(null),
    }, secure: logged);
    await app.pump(tester);
    await tester.tap(find.text('ميني ماركت النور'));
    await app.settle(tester);
    expect(find.byType(OfferScreen), findsOneWidget);
    expect(find.text('الاستلام · 0.6 كم منك'), findsOneWidget);

    await tester.tap(find.text('تجاهل'));
    await app.settle(tester);
    expect(app.server.calls, contains('POST /driver/orders/42/reject'));
    expect(find.byType(OfferScreen), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  group('current job', () {
    Map<String, Reply> task(Map<String, Object?> next) => {
      ..._online(),
      'GET /driver/orders/current': Reply(
        jobJson(status: 'accepted', mine: true, next: next),
      ),
    };

    Future<void> tapFab(WidgetTester tester, TestApp app) async {
      final bar = tester.getRect(find.byType(BarqNavBar));
      await tester.tapAt(Offset(bar.center.dx, bar.top + 20));
      await app.settle(tester);
    }

    testWidgets('the button comes from next_action and asks confirm first', (
      tester,
    ) async {
      final r = task(nextActionJson(confirm: 'متأكد إنك استلمت الطلب؟'));
      r[_transition] = Reply(
        jobJson(
          status: 'picked_up',
          mine: true,
          next: nextActionJson(to: 'on_the_way', label: 'انطلقت للزبون'),
        ),
      );
      final app = await TestApp.create(r, secure: logged);
      await app.pump(tester);
      await tapFab(tester, app);

      expect(find.text('تم القبول · توجّه للمتجر'), findsOneWidget);
      expect(find.text('بندورة بلدية × 2'), findsOneWidget);
      expect(find.text('+ 1 منتج آخر'), findsOneWidget);

      await tester.tap(find.text('استلمت الطلب'));
      await app.settle(tester);
      expect(find.text('متأكد إنك استلمت الطلب؟'), findsOneWidget);
      expect(app.server.calls, isNot(contains(_transition)));

      await tester.tap(find.text('استلمت الطلب').last);
      await app.settle(tester);
      expect((app.server.bodies[_transition]! as Map)['to'], 'picked_up');
      expect(app.server.headers[_transition]?['Idempotency-Key'], isNotNull);
      expect(find.text('انطلقت للزبون'), findsOneWidget);
      expect(find.text('في الطريق'), findsWidgets);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('cancelling the question sends nothing', (tester) async {
      final app = await TestApp.create(
        task(nextActionJson(confirm: 'متأكد؟')),
        secure: logged,
      );
      await app.pump(tester);
      await tapFab(tester, app);
      await tester.tap(find.text('استلمت الطلب'));
      await app.settle(tester);
      await tester.tap(find.text('إلغاء'));
      await app.settle(tester);
      expect(app.server.calls, isNot(contains(_transition)));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('invalid_transition reloads the job', (tester) async {
      final r = task(nextActionJson());
      r[_transition] = const Reply(
        null,
        status: 422,
        error: 'invalid_transition',
      );
      final app = await TestApp.create(r, secure: logged);
      await app.pump(tester);
      await tapFab(tester, app);
      app.server.calls.clear();
      await tester.tap(find.text('استلمت الطلب'));
      await app.settle(tester);
      expect(app.server.calls, contains('GET /driver/orders/current'));
      expect(find.text('رسالة السيرفر'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('navigate and call use the server coordinates and phone', (
      tester,
    ) async {
      final app = await TestApp.create(task(nextActionJson()), secure: logged);
      await app.pump(tester);
      await tapFab(tester, app);
      await tester.tap(find.byTooltip('الملاحة'));
      await tester.tap(find.byTooltip('اتصال'));
      await app.settle(tester);
      expect(app.actions.navigated, ['31.45,34.39']);
      expect(app.actions.called, ['0590000001']);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('no current job shows the empty state', (tester) async {
      final app = await TestApp.create(_online(), secure: logged);
      await app.pump(tester);
      await tapFab(tester, app);
      expect(find.text('ما عندك مهمة حالية'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  });
}
