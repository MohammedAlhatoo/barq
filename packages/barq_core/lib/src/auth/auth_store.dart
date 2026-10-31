import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keeps the login token in secure storage and in memory.
class AuthStore extends ChangeNotifier {
  AuthStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'barq_token';

  final FlutterSecureStorage _storage;
  final _sessionExpired = StreamController<void>.broadcast();
  String? _token;

  String? get token => _token;
  bool get isLoggedIn => _token != null;

  /// Fires when a logged-in request gets 401. The app shows "انتهت الجلسة".
  Stream<void> get sessionExpired => _sessionExpired.stream;

  /// Call once at startup, before the first request.
  Future<void> load() async {
    _token = await _storage.read(key: _tokenKey);
    notifyListeners();
  }

  Future<void> save(String token) async {
    _token = token;
    await _storage.write(key: _tokenKey, value: token);
    notifyListeners();
  }

  Future<void> clear() async {
    _token = null;
    await _storage.delete(key: _tokenKey);
    notifyListeners();
  }

  /// Called by ApiClient on 401. Without a token there is no session to end,
  /// so a failed login attempt stays a normal error on its own screen.
  Future<void> expireSession() async {
    if (!isLoggedIn) return;
    await clear();
    _sessionExpired.add(null);
  }

  @override
  void dispose() {
    _sessionExpired.close();
    super.dispose();
  }
}
