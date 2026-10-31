import 'dart:io';

import 'package:dio/dio.dart';

/// Every failed request becomes this. Screens show [messageAr].
class ApiException implements Exception {
  const ApiException({
    required this.status,
    required this.code,
    required this.messageAr,
    this.details,
  });

  /// Reads the server error shape:
  /// `{ message, error: { code, details, hint: { ar, en } } }`.
  factory ApiException.fromDio(DioException e) {
    if (_isConnectionProblem(e)) {
      return const ApiException(
        status: 0,
        code: networkCode,
        messageAr: 'تعذر الاتصال بالإنترنت. تأكد من الشبكة وحاول مرة أخرى.',
      );
    }
    final response = e.response;
    final body = response?.data;
    if (body is Map && body['error'] is Map) {
      final error = body['error'] as Map;
      final hint = error['hint'];
      final details = error['details'];
      return ApiException(
        status: response?.statusCode ?? 0,
        code: error['code'] as String? ?? unknownCode,
        messageAr:
            (hint is Map ? hint['ar'] as String? : null) ??
            body['message'] as String? ??
            _genericMessage,
        details: details is Map ? details.cast<String, dynamic>() : null,
      );
    }
    return ApiException(
      status: response?.statusCode ?? 0,
      code: unknownCode,
      messageAr: _genericMessage,
    );
  }

  static const networkCode = 'network_error';
  static const unknownCode = 'unknown_error';
  static const _genericMessage = 'حدث خطأ غير متوقع. حاول مرة أخرى.';

  /// 401, 404, 409, 422, 426, 503… and 0 when no response arrived.
  final int status;

  /// Server code such as already_taken, out_of_zone, quote_expired.
  final String code;

  /// Ready to show to the user.
  final String messageAr;
  final Map<String, dynamic>? details;

  /// True for no internet or a timeout.
  bool get isNetwork => code == networkCode;

  /// The server refuses this app version: show "تحديث إجباري".
  bool get isUpdateRequired => code == 'app_update_required';

  /// The whole service is stopped: show "صيانة".
  bool get isMaintenance => code == 'maintenance' || code == 'project_frozen';

  static bool _isConnectionProblem(DioException e) => switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.connectionError => true,
    DioExceptionType.unknown => e.error is SocketException,
    _ => false,
  };

  @override
  String toString() => 'ApiException($status, $code): $messageAr';
}
