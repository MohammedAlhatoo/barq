import 'package:barq_customer/features/system/state/system_cubit.dart';
import 'package:barq_customer/features/system/ui/maintenance_view.dart';
import 'package:barq_customer/features/system/ui/no_internet_view.dart';
import 'package:barq_customer/features/system/ui/session_expired_view.dart';
import 'package:barq_customer/features/system/ui/update_required_view.dart';
import 'package:barq_customer/features/auth/ui/phone_screen.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_app.dart';

const _config = Reply(configJson);

Map<String, Reply> _home() => {
  'GET /app/config': _config,
  'GET /me': const Reply({'name': 'سارة'}),
};

const _logged = {'barq_token': 'saved'};

void main() {
  testWidgets('401 during a session shows session expired, then login', (
    tester,
  ) async {
    final app = await TestApp.create(_home(), secure: _logged);
    await app.pump(tester);
    expect(find.byType(BarqNavBar), findsOneWidget);

    app.server.replies['GET /me'] = const Reply(
      null,
      status: 401,
      error: 'unauthenticated',
    );
    await tester.runAsync(
      () => app.deps.authRepository.currentName().then((_) {}, onError: (_) {}),
    );
    await app.settle(tester);
    expect(find.byType(SessionExpiredView), findsOneWidget);
    expect(app.deps.auth.isLoggedIn, isFalse);

    await tester.tap(find.text('تسجيل الدخول'));
    await app.settle(tester);
    expect(find.byType(SessionExpiredView), findsNothing);
    expect(find.byType(PhoneScreen), findsOneWidget);
  });

  testWidgets(
    'maintenance from any request covers the app; refresh clears it',
    (tester) async {
      final app = await TestApp.create(_home(), secure: _logged);
      await app.pump(tester);

      app.server.replies['GET /me'] = const Reply(
        null,
        status: 503,
        error: 'maintenance',
      );
      await tester.runAsync(
        () =>
            app.deps.authRepository.currentName().then((_) {}, onError: (_) {}),
      );
      await app.settle(tester);
      expect(find.byType(MaintenanceView), findsOneWidget);
      expect(find.textContaining('0592525487'), findsOneWidget);

      await tester.tap(find.text('تحديث الصفحة'));
      await app.settle(tester);
      expect(find.byType(MaintenanceView), findsNothing);
      expect(find.byType(BarqNavBar), findsOneWidget);
    },
  );

  testWidgets('maintenance at startup restarts the splash once it ends', (
    tester,
  ) async {
    final app = await TestApp.create({
      'GET /app/config': const Reply(
        null,
        status: 503,
        error: 'project_frozen',
      ),
    });
    await app.pump(tester);
    expect(find.byType(MaintenanceView), findsOneWidget);

    app.server.replies['GET /app/config'] = _config;
    await tester.tap(find.text('تحديث الصفحة'));
    await app.settle(tester);
    expect(find.text('تسوّق احتياجاتك اليومية بسهولة'), findsOneWidget);
  });

  testWidgets('426 from the server shows forced update and stays', (
    tester,
  ) async {
    final app = await TestApp.create({
      'GET /app/config': const Reply(
        null,
        status: 426,
        error: 'app_update_required',
      ),
    });
    await app.pump(tester);
    expect(find.byType(UpdateRequiredView), findsOneWidget);

    await tester.tap(find.text('تحديث الآن'));
    await app.settle(tester);
    expect(find.byType(UpdateRequiredView), findsOneWidget);
  });

  testWidgets('an older app than min_app_version shows forced update', (
    tester,
  ) async {
    final app = await TestApp.create({
      'GET /app/config': Reply({...configJson, 'min_app_version': '2.4'}),
    });
    await app.pump(tester);
    expect(find.byType(UpdateRequiredView), findsOneWidget);
    expect(find.text('نسخة 2.4'), findsOneWidget);
  });

  testWidgets('losing the network covers the app, its return uncovers it', (
    tester,
  ) async {
    final app = await TestApp.create(_home(), secure: _logged);
    await app.pump(tester);

    app.network.controller.add(false);
    await app.settle(tester);
    expect(find.byType(NoInternetView), findsOneWidget);

    app.network.controller.add(true);
    await app.settle(tester);
    expect(find.byType(NoInternetView), findsNothing);
    expect(find.byType(BarqNavBar), findsOneWidget);
  });

  testWidgets('retry stays on no internet while the device is offline', (
    tester,
  ) async {
    final app = await TestApp.create(_home(), secure: _logged);
    await app.pump(tester);
    app.network.online = false;
    app.network.controller.add(false);
    await app.settle(tester);

    await tester.tap(find.text('إعادة المحاولة'));
    await app.settle(tester);
    expect(find.byType(NoInternetView), findsOneWidget);
  });

  testWidgets('tabs and the cart button open their screens', (tester) async {
    final app = await TestApp.create(_home(), secure: _logged);
    await app.pump(tester);

    await tester.tap(find.text('طلباتي').last);
    await app.settle(tester);
    expect(tester.widget<BarqNavBar>(find.byType(BarqNavBar)).currentIndex, 2);

    tester.widget<BarqNavBar>(find.byType(BarqNavBar)).onFab!();
    await app.settle(tester);
    expect(find.text('السلة'), findsOneWidget);
  });

  for (final size in [phone, smallPhone]) {
    testWidgets('no overflow on the system screens at $size', (tester) async {
      for (final issue in SystemIssue.values) {
        final app = await TestApp.create({
          'GET /app/config': _config,
        }, initial: issue);
        await app.pump(tester, size: size);
        expect(tester.takeException(), isNull, reason: '$issue');
        await tester.pumpWidget(const BarqDivider());
      }
    });

    testWidgets('no overflow on the login flow at $size', (tester) async {
      final app = await TestApp.create({
        'GET /app/config': _config,
        'GET /me': const Reply({'name': null}),
      }, secure: _logged);
      await app.pump(tester, size: size);
      expect(tester.takeException(), isNull);
    });
  }
}
