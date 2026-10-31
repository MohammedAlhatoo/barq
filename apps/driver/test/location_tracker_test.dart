import 'package:barq_core/barq_core.dart';
import 'package:barq_driver/features/jobs/data/location_source.dart';
import 'package:barq_driver/features/jobs/data/location_tracker.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_app.dart';

const _send = 'POST /driver/location';

class _Rig {
  _Rig(this.server, this.tracker);

  final FakeServer server;
  final LocationTracker tracker;
  DateTime time = DateTime.utc(2026);

  void tick(int seconds) => time = time.add(Duration(seconds: seconds));

  /// Lets the request started by [LocationTracker.add] finish.
  Future<void> drain() => Future<void>.delayed(Duration.zero);
}

Future<_Rig> _rig() async {
  FlutterSecureStorage.setMockInitialValues({});
  final server = FakeServer({_send: const Reply({})});
  final api = ApiClient(
    authStore: AuthStore(),
    appVersion: '1.0.0',
    dio: Dio()..httpClientAdapter = server,
  );
  late final _Rig rig;
  rig = _Rig(
    server,
    LocationTracker(
      api: api,
      source: FakeLocationSource(),
      minIntervalSeconds: () => 3,
      now: () => rig.time,
    ),
  );
  return rig;
}

/// Longer than a fake request, even with every test file running at once.
Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 150));

void main() {
  final point = FakeLocationSource.point;

  test('one fresh point goes out in the single point shape', () async {
    final rig = await _rig();
    rig.tracker.add(point);
    await _settle();
    expect(rig.server.calls, [_send]);
    final body = rig.server.bodies[_send]! as Map;
    expect(body['lat'], 31.5);
    expect(body.containsKey('points'), isFalse);
    expect(rig.tracker.waitingCount, 0);
  });

  test('never sends faster than the minimum interval', () async {
    final rig = await _rig();
    rig.tracker.add(point);
    await _settle();
    rig.tick(1);
    rig.tracker.add(point);
    await _settle();
    expect(rig.server.calls, hasLength(1));
    expect(rig.tracker.waitingCount, 1);

    rig.tick(3);
    rig.tracker.add(point);
    await _settle();
    expect(rig.server.calls, hasLength(2));
    final body = rig.server.bodies[_send]! as Map;
    expect(body['points'] as List, hasLength(2));
    expect(rig.tracker.waitingCount, 0);
  });

  test('keeps points with no network, and sends them after', () async {
    final rig = await _rig();
    rig.server.offline = true;
    for (var i = 0; i < 5; i++) {
      rig.tick(3);
      rig.tracker.add(point);
      await _settle();
    }
    expect(rig.tracker.waitingCount, 5);

    rig.server.offline = false;
    rig.tick(3);
    rig.tracker.add(point);
    await _settle();
    final body = rig.server.bodies[_send]! as Map;
    expect(body['points'] as List, hasLength(6));
    expect(rig.tracker.waitingCount, 0);
  });

  test('sends at most 100 points in one request', () async {
    final rig = await _rig();
    rig.server.offline = true;
    for (var i = 0; i < 130; i++) {
      rig.tick(1);
      rig.tracker.add(point);
    }
    await _settle();
    rig.server.offline = false;
    rig.tick(3);
    rig.tracker.add(point);
    await _settle();
    final body = rig.server.bodies[_send]! as Map;
    expect(body['points'] as List, hasLength(LocationTracker.maxBatch));
    expect(rig.tracker.waitingCount, 31);
  });

  test('a batch the server refuses does not block the ones after', () async {
    final rig = await _rig();
    rig.server.replies[_send] = const Reply(
      null,
      status: 422,
      error: 'validation_failed',
    );
    rig.tracker.add(point);
    await _settle();
    expect(rig.tracker.waitingCount, 0);
  });

  test('leaves out the -1 Android sends for unknown values', () {
    final json = LocationPoint(
      lat: 1,
      lng: 2,
      recordedAt: DateTime.utc(2026),
      accuracy: 12.6,
      speed: -1,
      heading: -1,
    ).toJson();
    expect(json['accuracy'], 13);
    expect(json.containsKey('speed'), isFalse);
    expect(json.containsKey('heading'), isFalse);
  });
}
