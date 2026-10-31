import 'package:barq_core/barq_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_models.dart';

abstract class AuthRepository {
  Future<OtpTicket> sendOtp(String phone);
  Future<AuthSession> verifyOtp({required String phone, required String code});

  /// The saved name, or null if the user never gave one.
  Future<String?> currentName();
  Future<void> updateProfile({required String name, required String locale});
  Future<SavedAddress> addAddress({
    required String label,
    required double lat,
    required double lng,
  });
  Future<SavedAddress> updateAddress({
    required int id,
    required String label,
    required double lat,
    required double lng,
  });
  Future<bool> notificationsEnabled();
  Future<void> setNotificationsEnabled(bool enabled);
}

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._api, this._prefs);

  static const _notificationsKey = 'barq_notifications_enabled';

  final ApiClient _api;
  final SharedPreferences _prefs;

  @override
  Future<OtpTicket> sendOtp(String phone) async {
    final data = await _api.post('/auth/send-otp', body: {'phone': phone});
    return OtpTicket.fromJson((data as Map).cast<String, dynamic>());
  }

  @override
  Future<AuthSession> verifyOtp({
    required String phone,
    required String code,
  }) async {
    final data = await _api.post(
      '/auth/verify-otp',
      body: {'phone': phone, 'code': code},
    );
    return AuthSession.fromJson((data as Map).cast<String, dynamic>());
  }

  @override
  Future<String?> currentName() async {
    final data = await _api.get('/me');
    return (data as Map)['name'] as String?;
  }

  @override
  Future<void> updateProfile({
    required String name,
    required String locale,
  }) async {
    await _api.put('/me', body: {'name': name, 'locale': locale});
  }

  @override
  Future<SavedAddress> addAddress({
    required String label,
    required double lat,
    required double lng,
  }) async {
    final data = await _api.post(
      '/addresses',
      body: _addressBody(label, lat, lng),
    );
    return SavedAddress.fromJson((data as Map).cast<String, dynamic>());
  }

  @override
  Future<SavedAddress> updateAddress({
    required int id,
    required String label,
    required double lat,
    required double lng,
  }) async {
    final data = await _api.put(
      '/addresses/$id',
      body: _addressBody(label, lat, lng),
    );
    return SavedAddress.fromJson((data as Map).cast<String, dynamic>());
  }

  Map<String, dynamic> _addressBody(String label, double lat, double lng) => {
    'label': label,
    'lat': lat,
    'lng': lng,
    'is_default': true,
  };

  @override
  Future<bool> notificationsEnabled() async =>
      _prefs.getBool(_notificationsKey) ?? true;

  @override
  Future<void> setNotificationsEnabled(bool enabled) =>
      _prefs.setBool(_notificationsKey, enabled);
}
