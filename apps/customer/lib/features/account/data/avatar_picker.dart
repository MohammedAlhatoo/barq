import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// Behind a class, like VendorActions, so tests do not open the gallery.
abstract class AvatarPicker {
  /// Null when the user cancels or the gallery cannot open.
  Future<File?> pick();
}

class GalleryAvatarPicker implements AvatarPicker {
  /// Big enough for a profile picture, and keeps the upload small.
  static const _maxSide = 1024.0;

  @override
  Future<File?> pick() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: _maxSide,
        maxHeight: _maxSide,
      );
      return image == null ? null : File(image.path);
    } on PlatformException catch (e) {
      debugPrint('Gallery not opened: ${e.code}');
      return null;
    }
  }
}
