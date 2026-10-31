// Talks to the real sandbox with the real repositories. Skips without a
// pk_test key and a driver login. The login is never written in a file:
// flutter test test/live_driver_test.dart --dart-define-from-file=../../keys.json
//   --dart-define=BARQ_LIVE_PHONE=... --dart-define=BARQ_LIVE_PASSWORD=...
// Then delete build/test_cache: the compiler keeps the defines there.
import 'package:barq_core/barq_core.dart';
import 'package:barq_driver/features/auth/data/auth_repository.dart';
import 'package:barq_driver/features/earnings/data/earnings_repository.dart';
import 'package:barq_driver/features/history/data/history_repository.dart';
import 'package:barq_driver/features/jobs/data/jobs_repository.dart';
import 'package:barq_driver/features/jobs/data/location_source.dart';
import 'package:barq_driver/features/jobs/data/location_tracker.dart';
import 'package:barq_driver/features/notifications/data/notifications_repository.dart';
import 'package:barq_driver/features/profile/data/profile_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

const _phone = String.fromEnvironment('BARQ_LIVE_PHONE');
const _password = String.fromEnvironment('BARQ_LIVE_PASSWORD');

bool get _canRun =>
    BarqEnv.projectKey.startsWith('pk_test_') && _phone.isNotEmpty;

class _FixedLocation implements LocationSource {
  @override
  Future<LocationPoint> current() async =>
      LocationPoint(lat: 31.5065, lng: 34.4629, recordedAt: DateTime.now());

  @override
  Stream<LocationPoint> watch({required int intervalSeconds}) =>
      const Stream.empty();
}

void main() {
  test(
    'login, location, online, lists, earnings, cash, offline, logout',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      final auth = AuthStore();
      final api = ApiClient(authStore: auth, appVersion: '1.0.0');
      final authRepository = ApiAuthRepository(api, auth);
      final profile = ApiProfileRepository(api);
      final jobs = ApiJobsRepository(api);
      final earnings = ApiEarningsRepository(api);
      final tracker = LocationTracker(
        api: api,
        source: _FixedLocation(),
        minIntervalSeconds: () => 3,
      );

      await authRepository.login(phone: _phone, password: _password);
      expect(auth.isLoggedIn, isTrue);

      final me = await profile.me();
      expect(me.name, isNotEmpty);

      await tracker.sendNow();
      final online = await profile.setOnline(true);
      expect(online.isOnline, isTrue);

      final available = await jobs.available();
      expect(available.every((job) => job.nextAction != null), isTrue);
      await jobs.current();

      final today = await earnings.earnings(EarningsPeriod.week);
      expect(today.series, isNotEmpty);
      final cash = await earnings.cash();
      expect(cash.maxCash.amount, greaterThan(0));

      final kept = await profile.update(
        vehicleType: me.vehicleType,
        locale: me.locale,
      );
      expect(kept.vehicleType, me.vehicleType);
      await ApiHistoryRepository(api).history();
      final notifications = ApiNotificationsRepository(api);
      await notifications.list();
      await notifications.readAll();

      final offline = await profile.setOnline(false);
      expect(offline.isOnline, isFalse);
      await authRepository.logout();
      expect(auth.isLoggedIn, isFalse);
    },
    skip: _canRun ? false : 'Needs a pk_test key and a driver login',
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
