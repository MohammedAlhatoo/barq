import 'dart:async';

import 'package:barq_core/barq_core.dart';
import 'package:flutter/foundation.dart';

import '../../auth/data/location_repository.dart';
import 'browse_repository.dart';

/// The point "nearest" is measured from: the default delivery address, or the
/// phone's GPS for a user with no address. Null means neither is available,
/// and the screens then show every store.
class UserLocation {
  UserLocation(this._browse, this._device);

  /// Home waits for this, so a phone with no GPS fix must not stall it.
  static const _gpsTimeout = Duration(seconds: 8);

  final BrowseRepository _browse;
  final LocationRepository _device;

  /// GPS is tried once per session: a denied permission must not ask again on
  /// every screen.
  Future<({double lat, double lng})?>? _gps;

  Future<({double lat, double lng})?> current() async {
    try {
      final address = await _browse.defaultAddress();
      if (address != null) return (lat: address.lat, lng: address.lng);
    } on ApiException catch (e) {
      debugPrint('No address for nearest: ${e.code}');
    }
    return _gps ??= _readGps();
  }

  Future<({double lat, double lng})?> _readGps() async {
    try {
      return await _device.current().timeout(_gpsTimeout);
    } on Exception catch (e) {
      debugPrint('No GPS for nearest: $e');
      return null;
    }
  }
}
