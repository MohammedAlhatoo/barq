import 'dart:io';

import 'package:barq_core/barq_core.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// The camera refused, usually a denied permission.
class CameraFailure implements Exception {
  const CameraFailure();
}

/// Takes a proof photo and sends it. The gallery is not offered on purpose:
/// the photo must be taken at the place.
abstract class ProofPhotos {
  /// Null when the driver closed the camera without a photo.
  Future<File?> take();

  /// Returns the `upload_id`.
  Future<int> upload(File photo);
}

class CameraProofPhotos implements ProofPhotos {
  CameraProofPhotos(this._uploads);

  static const _quality = 70;
  static const _purpose = 'proof_photo';

  final UploadService _uploads;
  final _picker = ImagePicker();

  @override
  Future<File?> take() async {
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: _quality,
      );
      return photo == null ? null : File(photo.path);
    } on PlatformException {
      throw const CameraFailure();
    }
  }

  @override
  Future<int> upload(File photo) => _uploads.upload(photo, purpose: _purpose);
}
