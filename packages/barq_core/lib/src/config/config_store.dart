import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../api/barq_env.dart';
import 'app_config.dart';

/// Loads `GET /app/config`, keeps it in a cache and shares it with the app.
class ConfigStore extends ChangeNotifier {
  ConfigStore({required this._api, required this._app});

  final ApiClient _api;
  final BarqAppKind _app;
  AppConfig? _config;

  bool get isLoaded => _config != null;

  /// Only read this after [load] has finished without an error.
  AppConfig get config => _config!;

  String get _serverAppName => _app == BarqAppKind.driver ? 'driver' : 'user';

  /// Labels depend on the language, so each language has its own cache.
  String get _cacheKey => 'barq_config_${_app.name}_${_api.language}';
  String get _etagKey => '${_cacheKey}_etag';

  /// Cache first, then the server. A 304 keeps the cache. With a cache, losing
  /// the network is not an error; maintenance and forced update still throw.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCache = _readCache(prefs);
    if (hasCache) notifyListeners();

    try {
      final result = await _api.getWithEtag(
        '/app/config',
        query: {'app': _serverAppName},
        etag: hasCache ? prefs.getString(_etagKey) : null,
      );
      if (result.status == 304) return;

      final data = (result.data as Map).cast<String, dynamic>();
      _config = AppConfig.fromJson(data);
      await prefs.setString(_cacheKey, jsonEncode(data));
      final etag = result.etag;
      if (etag == null) {
        await prefs.remove(_etagKey);
      } else {
        await prefs.setString(_etagKey, etag);
      }
      notifyListeners();
    } on ApiException catch (e) {
      if (!(e.isNetwork && hasCache)) rethrow;
    }
  }

  bool _readCache(SharedPreferences prefs) {
    final cached = prefs.getString(_cacheKey);
    if (cached == null) return false;
    try {
      _config = AppConfig.fromJson(jsonDecode(cached) as Map<String, dynamic>);
      return true;
    } on Object catch (e) {
      debugPrint('Ignoring unreadable config cache: $e');
      return false;
    }
  }
}
