import 'package:barq_core/barq_core.dart';
import 'package:flutter/foundation.dart';

abstract class AuthRepository {
  /// Keeps the token on success. Throws [ApiException] on a wrong password.
  Future<void> login({required String phone, required String password});

  /// Always forgets the token, even if the server could not be reached.
  Future<void> logout();
}

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._api, this._auth);

  static const _deviceName = 'Barq Captain';

  final ApiClient _api;
  final AuthStore _auth;

  @override
  Future<void> login({required String phone, required String password}) async {
    final data = await _api.post(
      '/driver/auth/login',
      body: {'phone': phone, 'password': password, 'device_name': _deviceName},
    );
    await _auth.save((data as Map)['token'] as String);
  }

  @override
  Future<void> logout() async {
    // The phone stops receiving this driver's notifications first, while the
    // token still works.
    try {
      await _api.put('/driver/me/fcm-token', body: {'token': null});
    } on ApiException catch (e) {
      debugPrint('FCM token not removed: ${e.code}');
    }
    try {
      await _api.post('/driver/auth/logout');
    } finally {
      await _auth.clear();
    }
  }
}
