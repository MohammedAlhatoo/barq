import 'package:geolocator/geolocator.dart';

enum LocationProblem { serviceOff, denied }

class LocationException implements Exception {
  const LocationException(this.problem);

  final LocationProblem problem;
}

abstract class LocationRepository {
  /// Asks for permission if needed. Throws [LocationException].
  Future<({double lat, double lng})> current();
}

class GeolocatorLocationRepository implements LocationRepository {
  @override
  Future<({double lat, double lng})> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(LocationProblem.serviceOff);
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationException(LocationProblem.denied);
    }
    final position = await Geolocator.getCurrentPosition();
    return (lat: position.latitude, lng: position.longitude);
  }
}
