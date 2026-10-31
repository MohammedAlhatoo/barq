// Calls the real server. Needs a real key, so it skips without one:
// flutter test test/live_api_test.dart --dart-define-from-file=../../keys.json
import 'package:barq_core/barq_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool get _hasRealKey =>
    RegExp(r'^pk_[a-z]+_[A-Za-z0-9]+$').hasMatch(BarqEnv.projectKey);

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });

  test('GET /app/config returns a usable config', () async {
    final api = ApiClient(authStore: AuthStore(), appVersion: '1.0.0');
    final store = ConfigStore(api: api, app: BarqAppKind.customer);

    await store.load();

    final config = store.config;
    expect(config.deliveryConfirmation, 'photo');
    expect(config.statuses, isNotEmpty);
    expect(config.polling.trackingSeconds, isNotNull);
    expect(config.polling.eventsSeconds, isNotNull);
    expect(config.polling.availableOrdersSeconds, isNotNull);
    expect(config.polling.notificationsSeconds, isNotNull);
    expect(config.polling.configSeconds, isNotNull);
  }, skip: _hasRealKey ? false : 'needs a real BARQ_PROJECT_KEY');

  test('a wrong key gives ApiException(invalid_project_key)', () async {
    final dio = Dio();
    final api = ApiClient(
      authStore: AuthStore(),
      appVersion: '1.0.0',
      dio: dio,
    );
    // Runs after ApiClient adds its headers, so it replaces the real key.
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['X-Project-Key'] = 'pk_test_wrong';
          handler.next(options);
        },
      ),
    );

    await expectLater(
      api.get('/app/config'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.code,
          'code',
          'invalid_project_key',
        ),
      ),
    );
  });
}
