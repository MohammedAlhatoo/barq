import 'dart:io';

import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../api/api_exception.dart';

/// Sends a file to `POST /uploads` and returns its `upload_id`.
class UploadService {
  UploadService({required this._api});

  /// The 10240 KB limit from UploadRequest in openapi.json.
  static const maxBytes = 10240 * 1024;

  final ApiClient _api;

  /// [purpose] examples: `proof_photo`, `avatar`.
  Future<int> upload(File file, {required String purpose}) async {
    if (await file.length() > maxBytes) {
      throw const ApiException(
        status: 422,
        code: 'file_too_large',
        messageAr: 'حجم الملف أكبر من 10 ميجابايت.',
      );
    }
    final form = FormData.fromMap({
      'purpose': purpose,
      'file': await MultipartFile.fromFile(file.path),
    });
    final data = await _api.post('/uploads', body: form) as Map;
    return data['upload_id'] as int;
  }
}
