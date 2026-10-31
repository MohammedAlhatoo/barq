import 'dart:async';

import 'package:barq_core/barq_core.dart';

import 'job_models.dart';

abstract class JobsRepository {
  /// Fires after anything that changes the lists, earnings or cash.
  Stream<void> get changes;

  Future<List<Job>> available();
  Future<Job?> current();
  Future<Job> job(int id);
  Future<Job> accept(int id);

  /// Hides the order from this driver only. It does not cancel it.
  Future<void> reject(int id);
  Future<Job> transition(int id, {required String to, List<int>? uploadIds});

  /// Ends the job. `delivery_confirmation = photo`: no code from the customer.
  Future<Job> deliver(int id, {required List<int> uploadIds});
}

class ApiJobsRepository implements JobsRepository {
  ApiJobsRepository(this._api);

  final ApiClient _api;
  final _changes = StreamController<void>.broadcast();

  @override
  Stream<void> get changes => _changes.stream;

  Job _job(dynamic data) => Job.fromJson((data as Map).cast());

  @override
  Future<List<Job>> available() async {
    final data = await _api.get('/driver/orders/available') as List;
    return data.map(_job).toList();
  }

  @override
  Future<Job?> current() async {
    final data = await _api.get('/driver/orders/current');
    return data == null ? null : _job(data);
  }

  @override
  Future<Job> job(int id) async => _job(await _api.get('/driver/orders/$id'));

  @override
  Future<Job> accept(int id) async {
    final job = _job(
      await _api.post(
        '/driver/orders/$id/accept',
        idempotencyKey: newIdempotencyKey(),
      ),
    );
    _changes.add(null);
    return job;
  }

  @override
  Future<void> reject(int id) => _api.post('/driver/orders/$id/reject');

  @override
  Future<Job> transition(
    int id, {
    required String to,
    List<int>? uploadIds,
  }) async => _job(
    await _api.post(
      '/driver/orders/$id/transition',
      body: {'to': to, 'upload_ids': ?uploadIds},
      idempotencyKey: newIdempotencyKey(),
    ),
  );

  @override
  Future<Job> deliver(int id, {required List<int> uploadIds}) async {
    final job = _job(
      await _api.post(
        '/driver/orders/$id/deliver',
        body: {'upload_ids': uploadIds},
        idempotencyKey: newIdempotencyKey(),
      ),
    );
    _changes.add(null);
    return job;
  }
}
