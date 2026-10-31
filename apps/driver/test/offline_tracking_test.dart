import 'package:barq_core/barq_core.dart';
import 'package:barq_driver/features/jobs/data/jobs_repository.dart';
import 'package:barq_driver/features/jobs/data/location_tracker.dart';
import 'package:barq_driver/features/profile/data/profile_repository.dart';
import 'package:barq_driver/features/profile/state/driver_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_app.dart';

const _current = 'GET /driver/orders/current';

class _Rig {
  _Rig(this.server, this.cubit, this.tracker, this.jobs);

  final FakeServer server;
  final DriverCubit cubit;
  final LocationTracker tracker;
  final ApiJobsRepository jobs;
}

/// Starts online, or offline, with or without a job.
Future<_Rig> _rig({required bool online, required bool job}) async {
  FlutterSecureStorage.setMockInitialValues({});
  final server = FakeServer({
    'GET /driver/me': Reply(driverJson(online: online)),
    'PUT /driver/status': Reply(driverJson()),
    'POST /driver/location': const Reply({}),
    _current: Reply(job ? jobJson(status: 'on_the_way', mine: true) : null),
  });
  final auth = AuthStore();
  final api = ApiClient(
    authStore: auth,
    appVersion: '1.0.0',
    dio: Dio()..httpClientAdapter = server,
  );
  final jobs = ApiJobsRepository(api);
  final tracker = LocationTracker(
    api: api,
    source: FakeLocationSource(),
    minIntervalSeconds: () => 3,
  );
  final cubit = DriverCubit(
    repository: ApiProfileRepository(api),
    jobs: jobs,
    tracker: tracker,
    jobCheckEvery: () => jobCheckEvery,
    auth: auth,
  );
  addTearDown(cubit.close);
  await cubit.load();
  return _Rig(server, cubit, tracker, jobs);
}

Future<void> _wait() => Future<void>.delayed(const Duration(milliseconds: 200));

void main() {
  test('going offline with no job stops the tracking', () async {
    final rig = await _rig(online: true, job: false);
    expect(rig.tracker.isTracking, isTrue);
    await rig.cubit.setOnline(false);
    expect(rig.tracker.isTracking, isFalse);
  });

  test('going offline with an active job keeps tracking', () async {
    final rig = await _rig(online: true, job: true);
    await rig.cubit.setOnline(false);
    expect(rig.cubit.state.isOnline, isFalse);
    expect(rig.tracker.isTracking, isTrue);
  });

  test(
    'tracking stops when the job ends while offline, as on cancel',
    () async {
      final rig = await _rig(online: true, job: true);
      await rig.cubit.setOnline(false);
      rig.server.replies[_current] = const Reply(null);
      await _wait();
      expect(rig.tracker.isTracking, isFalse);
    },
  );

  test('a failed check does not stop the tracking', () async {
    final rig = await _rig(online: true, job: true);
    await rig.cubit.setOnline(false);
    rig.server.offline = true;
    await _wait();
    expect(rig.tracker.isTracking, isTrue);
  });

  test('reopening the app offline resumes tracking for the job', () async {
    final rig = await _rig(online: false, job: true);
    expect(rig.tracker.isTracking, isTrue);
  });

  test('reopening the app offline with no job does not track', () async {
    final rig = await _rig(online: false, job: false);
    expect(rig.tracker.isTracking, isFalse);
  });

  test('logout stops everything, even with a job', () async {
    final rig = await _rig(online: true, job: true);
    await rig.cubit.setOnline(false);
    await rig.cubit.reset();
    expect(rig.tracker.isTracking, isFalse);
  });
}
