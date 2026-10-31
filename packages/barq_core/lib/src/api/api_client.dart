import 'package:dio/dio.dart';

import '../auth/auth_store.dart';
import 'api_exception.dart';
import 'barq_env.dart';
import 'paged.dart';

/// The only way the apps talk to the server.
///
/// Adds the shared headers, returns `data` from the response, and turns every
/// failure into [ApiException].
class ApiClient {
  ApiClient({
    required this._authStore,
    required this._appVersion,
    String Function()? language,
    Dio? dio,
  }) : _language = language ?? (() => 'ar'),
       _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 15),
               receiveTimeout: const Duration(seconds: 30),
             ),
           ) {
    _dio.options.baseUrl = BarqEnv.baseUrl;
    _dio.interceptors.add(InterceptorsWrapper(onRequest: _addHeaders));
  }

  final Dio _dio;
  final AuthStore _authStore;
  final String _appVersion;
  final String Function() _language;

  /// Current language code, used to keep one config cache per language.
  String get language => _language();

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final response = await _send('GET', path, query: query);
    return _dataOf(response);
  }

  Future<dynamic> post(
    String path, {
    Object? body,
    String? idempotencyKey,
  }) async {
    final response = await _send(
      'POST',
      path,
      body: body,
      headers: {'Idempotency-Key': ?idempotencyKey},
    );
    return _dataOf(response);
  }

  Future<dynamic> put(String path, {Object? body}) async {
    final response = await _send('PUT', path, body: body);
    return _dataOf(response);
  }

  Future<dynamic> delete(String path) async {
    final response = await _send('DELETE', path);
    return _dataOf(response);
  }

  Future<Paged<dynamic>> getPaged(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final response = await _send('GET', path, query: query);
    final body = response.data as Map;
    final meta = body['meta'];
    return Paged.fromMeta(
      body['data'] as List<dynamic>,
      meta is Map ? meta.cast<String, dynamic>() : null,
    );
  }

  /// GET with `If-None-Match`. A 304 is a normal answer here, not an error.
  Future<({int status, dynamic data, String? etag})> getWithEtag(
    String path, {
    Map<String, dynamic>? query,
    String? etag,
  }) async {
    final response = await _send(
      'GET',
      path,
      query: query,
      headers: {'If-None-Match': ?etag},
      acceptNotModified: true,
    );
    return (
      status: response.statusCode ?? 0,
      data: _dataOf(response),
      etag: response.headers.value('etag'),
    );
  }

  void _addHeaders(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _authStore.token;
    options.headers.addAll({
      'Accept': 'application/json',
      'X-Project-Key': BarqEnv.projectKey,
      'Accept-Language': language,
      'X-App-Version': _appVersion,
      if (BarqEnv.devMember.isNotEmpty) 'X-Dev-Member': BarqEnv.devMember,
      if (token != null) 'Authorization': 'Bearer $token',
    });
    handler.next(options);
  }

  Future<Response<dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    Map<String, dynamic>? headers,
    bool acceptNotModified = false,
  }) async {
    try {
      return await _dio.request<dynamic>(
        path,
        data: body,
        queryParameters: query,
        options: Options(
          method: method,
          headers: headers,
          validateStatus: (status) =>
              status != null &&
              (status >= 200 && status < 300 ||
                  acceptNotModified && status == 304),
        ),
      );
    } on DioException catch (e) {
      final exception = ApiException.fromDio(e);
      if (exception.status == 401) await _authStore.expireSession();
      throw exception;
    }
  }

  dynamic _dataOf(Response<dynamic> response) {
    final body = response.data;
    return body is Map ? body['data'] : null;
  }
}
