import 'package:barq_customer/features/auth/data/location_repository.dart';
import 'package:barq_customer/features/auth/ui/otp_screen.dart';
import 'package:barq_customer/features/auth/ui/phone_screen.dart';
import 'package:barq_customer/features/auth/ui/welcome_screen.dart';
import 'package:barq_customer/features/system/ui/no_internet_view.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_app.dart';

const _config = Reply(configJson);
const _sendOtp = Reply(ticketJson);
const _address = Reply({
  'id': 7,
  'label': 'موقعي',
  'lat': 31.45,
  'lng': 34.39,
  'details': null,
  'is_default': true,
}, status: 201);

Future<void> _openLogin(WidgetTester tester, TestApp app) async {
  await app.pump(tester);
  await tester.tap(find.text('تخطّي'));
  await app.settle(tester);
}

Future<void> _enterPhoneAndCode(WidgetTester tester, TestApp app) async {
  await tester.enterText(find.byType(TextField), '0599123456');
  await tester.pump();
  await tester.tap(find.text('إرسال الرمز'));
  await app.settle(tester);
  expect(find.byType(OtpScreen), findsOneWidget);
  await tester.enterText(find.byType(TextField), '1234');
  await app.settle(tester);
}

void main() {
  testWidgets('new user: onboarding, phone, code, welcome, home', (
    tester,
  ) async {
    final app = await TestApp.create({
      'GET /app/config': _config,
      'POST /auth/send-otp': _sendOtp,
      'POST /auth/verify-otp': Reply(sessionJson(isNew: true)),
      'POST /addresses': _address,
      'PUT /me': const Reply({'id': 1, 'name': 'سارة'}),
    });
    await app.pump(tester);

    expect(find.text('تسوّق احتياجاتك اليومية بسهولة'), findsOneWidget);
    await tester.tap(find.text('التالي'));
    await app.settle(tester);
    expect(find.text('قارن الأسعار ووفّر في كل طلب'), findsOneWidget);
    await tester.tap(find.text('التالي'));
    await app.settle(tester);
    expect(find.text('تخطّي'), findsNothing);
    await tester.tap(find.text('ابدأ الآن'));
    await app.settle(tester);
    expect(find.byType(PhoneScreen), findsOneWidget);

    await _enterPhoneAndCode(tester, app);
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(app.server.bodies['POST /auth/send-otp'], {
      'phone': '+970599123456',
    });
    expect(app.server.bodies['POST /auth/verify-otp'], {
      'phone': '+970599123456',
      'code': '1234',
    });
    expect(app.deps.auth.token, 'test-token');

    await tester.tap(find.text('تحديد موقعي'));
    await app.settle(tester);
    expect(find.text('داخل منطقة الخدمة'), findsOneWidget);

    final start = find.text('ابدأ التسوّق');
    await tester.enterText(find.byType(TextField), 'سارة');
    await tester.pump();
    await tester.ensureVisible(start);
    await tester.pump();
    await tester.tap(start);
    await app.settle(tester);

    expect(find.byType(BarqNavBar), findsOneWidget);
    expect(app.server.bodies['PUT /me'], {'name': 'سارة', 'locale': 'ar'});
  });

  testWidgets('returning user goes straight to home', (tester) async {
    final app = await TestApp.create({
      'GET /app/config': _config,
      'POST /auth/send-otp': _sendOtp,
      'POST /auth/verify-otp': Reply(sessionJson(isNew: false, name: 'سارة')),
    });
    await _openLogin(tester, app);
    await _enterPhoneAndCode(tester, app);
    expect(find.byType(BarqNavBar), findsOneWidget);
  });

  testWidgets('saved token opens home; empty name opens welcome', (
    tester,
  ) async {
    var app = await TestApp.create(
      {
        'GET /app/config': _config,
        'GET /me': const Reply({'name': 'سارة'}),
      },
      secure: {'barq_token': 'saved'},
    );
    await app.pump(tester);
    expect(find.byType(BarqNavBar), findsOneWidget);

    app = await TestApp.create(
      {
        'GET /app/config': _config,
        'GET /me': const Reply({'name': null}),
      },
      secure: {'barq_token': 'saved'},
    );
    await tester.pumpWidget(const SizedBox());
    await app.pump(tester);
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets('wrong code shows the server message and stays', (tester) async {
    final app = await TestApp.create({
      'GET /app/config': _config,
      'POST /auth/send-otp': _sendOtp,
      'POST /auth/verify-otp': const Reply(
        null,
        status: 422,
        error: 'otp_invalid',
      ),
    });
    await _openLogin(tester, app);
    await _enterPhoneAndCode(tester, app);

    expect(find.byType(OtpScreen), findsOneWidget);
    expect(find.text('رسالة السيرفر'), findsOneWidget);
    expect(app.deps.auth.isLoggedIn, isFalse);
  });

  testWidgets('send-otp failure stays on the phone screen', (tester) async {
    final app = await TestApp.create({
      'GET /app/config': _config,
      'POST /auth/send-otp': const Reply(
        null,
        status: 429,
        error: 'too_many_requests',
      ),
    });
    await _openLogin(tester, app);
    await tester.enterText(find.byType(TextField), '0599123456');
    await tester.pump();
    await tester.tap(find.text('إرسال الرمز'));
    await app.settle(tester);

    expect(find.byType(PhoneScreen), findsOneWidget);
    expect(find.text('رسالة السيرفر'), findsOneWidget);
  });

  testWidgets('the resend link appears when expires_in runs out', (
    tester,
  ) async {
    final app = await TestApp.create({
      'GET /app/config': _config,
      'POST /auth/send-otp': _sendOtp,
    });
    await _openLogin(tester, app);
    await tester.enterText(find.byType(TextField), '0599123456');
    await tester.pump();
    await tester.tap(find.text('إرسال الرمز'));
    await app.settle(tester);

    expect(find.textContaining('00:5'), findsOneWidget);
    await tester.pump(const Duration(seconds: 61));
    await tester.pump();
    expect(find.text('إعادة الإرسال'), findsOneWidget);

    await tester.tap(find.text('إعادة الإرسال'));
    await app.settle(tester);
    expect(find.text('إعادة الإرسال'), findsNothing);
    expect(app.server.calls.where((c) => c == 'POST /auth/send-otp').length, 2);
  });

  group('welcome location', () {
    Future<TestApp> openWelcome(WidgetTester tester, Reply address) async {
      final app = await TestApp.create(
        {
          'GET /app/config': _config,
          'GET /me': const Reply({'name': null}),
          'POST /addresses': address,
          'PUT /addresses/7': _address,
        },
        secure: {'barq_token': 'saved'},
      );
      await app.pump(tester);
      return app;
    }

    testWidgets('out of zone shows the server message and the red pill', (
      tester,
    ) async {
      final app = await openWelcome(
        tester,
        const Reply(null, status: 422, error: 'out_of_zone'),
      );
      await tester.tap(find.text('تحديد موقعي'));
      await app.settle(tester);

      expect(find.text('خارج منطقة الخدمة'), findsOneWidget);
      expect(find.text('رسالة السيرفر'), findsOneWidget);
    });

    testWidgets('location permission denied shows a message', (tester) async {
      final app = await openWelcome(tester, _address);
      app.location.failure = const LocationException(LocationProblem.denied);
      await tester.tap(find.text('تحديد موقعي'));
      await app.settle(tester);

      expect(find.textContaining('اسمح لبرق'), findsOneWidget);
      expect(app.server.calls, isNot(contains('POST /addresses')));
    });

    testWidgets('a second tap edits the same address', (tester) async {
      final app = await openWelcome(tester, _address);
      await tester.tap(find.text('تحديد موقعي'));
      await app.settle(tester);
      await tester.tap(find.text('تحديد موقعي'));
      await app.settle(tester);

      expect(app.server.calls.where((c) => c == 'POST /addresses').length, 1);
      expect(app.server.calls, contains('PUT /addresses/7'));
    });

    testWidgets('the start button waits for a name, not for a location', (
      tester,
    ) async {
      await openWelcome(tester, _address);
      BarqButton startButton() => tester.widget<BarqButton>(
        find.widgetWithText(BarqButton, 'ابدأ التسوّق'),
      );
      expect(startButton().onPressed, isNull);
      await tester.enterText(find.byType(TextField), 'سارة');
      await tester.pump();
      expect(startButton().onPressed, isNotNull);
    });
  });

  testWidgets('splash without a network shows no internet, retry recovers', (
    tester,
  ) async {
    final app = await TestApp.create({});
    app.server.replies['GET /app/config'] = _config;
    app.server.offline = true;
    await app.pump(tester);
    expect(find.byType(NoInternetView), findsOneWidget);

    app.server.offline = false;
    await tester.tap(find.text('إعادة المحاولة'));
    await app.settle(tester);
    expect(find.text('تسوّق احتياجاتك اليومية بسهولة'), findsOneWidget);
  });

  testWidgets('English switch changes the texts and the direction', (
    tester,
  ) async {
    final app = await TestApp.create({'GET /app/config': _config});
    await app.pump(tester);
    await tester.tap(find.text('EN'));
    await app.settle(tester);

    expect(find.text('Shop your daily needs with ease'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('Skip'))),
      TextDirection.ltr,
    );
  });
}
