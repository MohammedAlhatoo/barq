// One whole job on the real sandbox: a test customer orders, the driver takes
// it to delivery. Prints what openapi.json does not document: the `requires`
// values and the refusal when the driver is too far. Stores must be open
// (08:00 to 23:00). The driver login is never written in a file:
// flutter test test/live_job_test.dart --dart-define-from-file=../../keys.json
//   --dart-define=BARQ_LIVE_PHONE=... --dart-define=BARQ_LIVE_PASSWORD=...
// Then delete build/test_cache: the compiler keeps the defines there.
import 'dart:convert';
import 'dart:io';

import 'package:barq_core/barq_core.dart';
import 'package:barq_driver/features/auth/data/auth_repository.dart';
import 'package:barq_driver/features/jobs/data/jobs_repository.dart';
import 'package:barq_driver/features/profile/data/profile_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

const _phone = String.fromEnvironment('BARQ_LIVE_PHONE');
const _password = String.fromEnvironment('BARQ_LIVE_PASSWORD');

// A made-up number. In the sandbox the code is always 1234.
const _customerPhone = '0590000474';
const _sandboxCode = '1234';
const _dropoff = {'lat': 31.5065857, 'lng': 34.4629677, 'label': 'Test'};
const _farAway = {'lat': 31.30, 'lng': 34.25, 'accuracy': 10};
const _maxSteps = 8;

bool get _canRun =>
    BarqEnv.projectKey.startsWith('pk_test_') && _phone.isNotEmpty;

/// Logs in a test customer and leaves one order waiting for a driver.
Future<int> _placeOrder() async {
  final auth = AuthStore();
  final api = ApiClient(authStore: auth, appVersion: '1.0.0');
  await api.post('/auth/send-otp', body: {'phone': _customerPhone});
  final session = await api.post(
    '/auth/verify-otp',
    body: {'phone': _customerPhone, 'code': _sandboxCode},
  );
  await auth.save((session as Map)['token'] as String);

  final vendors = await api.get(
    '/vendors',
    query: {'lat': _dropoff['lat'], 'lng': _dropoff['lng']},
  ) as List;
  final vendor = vendors.cast<Map>().firstWhere(
    (v) => v['is_open_now'] == true,
    orElse: () => throw StateError('No open store. Run after 08:00.'),
  );
  final products =
      await api.get('/products', query: {'vendor': vendor['id']}) as List;
  final quote = await api.post(
    '/orders/quote',
    body: {
      'vendor_id': vendor['id'],
      'cart': [
        {'product_id': (products.first as Map)['id'], 'qty': 1},
      ],
      'dropoff': _dropoff,
      'payment_method': 'cash',
    },
  );
  final order = await api.post(
    '/orders',
    body: {'quote_token': (quote as Map)['quote_token']},
    idempotencyKey: newIdempotencyKey(),
  );
  final id = (order as Map)['id'] as int;

  for (var i = 0; i < _maxSteps; i++) {
    final now = await api.get('/orders/$id') as Map;
    final status = (now['status'] as Map)['key'];
    if (status == 'pending') return id;
    if (status == 'priced') {
      final offer = await api.get('/orders/$id/offer') as Map;
      await api.post(
        '/orders/$id/offer/approve',
        body: {'offer_id': offer['id']},
      );
    } else {
      await api.post('/sandbox/orders/$id/advance');
    }
  }
  throw StateError('Order $id never reached pending');
}

Future<File> _photo() async {
  final file = File('${Directory.systemTemp.path}/barq_live_proof.png');
  await file.writeAsBytes(
    base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGA'
      'WjR9awAAAABJRU5ErkJggg==',
    ),
  );
  return file;
}

void main() {
  test(
    'a whole job, from accept to delivery with photos',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      final orderId = await _placeOrder();

      final auth = AuthStore();
      final api = ApiClient(authStore: auth, appVersion: '1.0.0');
      final jobs = ApiJobsRepository(api);
      final uploads = UploadService(api: api);
      await ApiAuthRepository(
        api,
        auth,
      ).login(phone: _phone, password: _password);
      await api.post('/driver/sandbox/settle-cash');
      await api.post('/driver/location', body: _farAway);
      await ApiProfileRepository(api).setOnline(true);

      var job = await jobs.accept(orderId);
      final proof = await uploads.upload(
        await _photo(),
        purpose: 'proof_photo',
      );

      for (var i = 0; i < _maxSteps; i++) {
        final next = job.nextAction!;
        debugPrint(
          'STEP status=${job.statusKey} action=${next.action} to=${next.to} '
          'label=${next.label} style=${next.style} '
          'requires=${next.requires} geofence=${next.geofenceMeters} '
          'confirm=${next.confirm}',
        );
        if (next.isDeliver) break;
        try {
          job = await jobs.transition(
            job.id,
            to: next.to,
            uploadIds: next.needsPhoto ? [proof] : null,
          );
        } on ApiException catch (e) {
          debugPrint(
            'REFUSED status=${e.status} code=${e.code} '
            'details=${e.details} isTooFar=${next.isTooFar(e)}',
          );
          final place = job.isHeadingToStore ? job.pickup : job.dropoff;
          await Future<void>.delayed(const Duration(seconds: 4));
          await api.post(
            '/driver/location',
            body: {'lat': place.lat, 'lng': place.lng, 'accuracy': 5},
          );
          job = await jobs.transition(
            job.id,
            to: next.to,
            uploadIds: next.needsPhoto ? [proof] : null,
          );
        }
      }

      final done = await jobs.deliver(job.id, uploadIds: [proof]);
      expect(done.statusKey, OrderTimelines.tracking.last);
      await api.post('/driver/sandbox/settle-cash');
      await ApiProfileRepository(api).setOnline(false);
    },
    skip: _canRun ? false : 'Needs a pk_test key and a driver login',
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
