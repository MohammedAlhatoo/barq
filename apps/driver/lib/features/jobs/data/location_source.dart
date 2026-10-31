import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Why the app cannot read the location.
enum LocationProblem { denied, serviceOff, unavailable }

class LocationFailure implements Exception {
  const LocationFailure(this.problem);

  final LocationProblem problem;
}

/// One reading, in the shape of `POST /driver/location`.
class LocationPoint {
  const LocationPoint({
    required this.lat,
    required this.lng,
    required this.recordedAt,
    this.accuracy,
    this.speed,
    this.heading,
  });

  static const _maxAccuracy = 10000;
  static const _maxSpeed = 300.0;
  static const _maxHeading = 360;

  final double lat;
  final double lng;
  final DateTime recordedAt;
  final double? accuracy;
  final double? speed;
  final double? heading;

  /// Android answers -1 for "unknown", and the server refuses negative values.
  Map<String, Object?> toJson() {
    final accuracy = this.accuracy;
    final speed = this.speed;
    final heading = this.heading;
    return {
      'lat': lat,
      'lng': lng,
      'recorded_at': recordedAt.toUtc().toIso8601String(),
      if (accuracy != null && accuracy >= 0)
        'accuracy': accuracy.round().clamp(0, _maxAccuracy),
      if (speed != null && speed >= 0) 'speed': speed.clamp(0, _maxSpeed),
      if (heading != null && heading >= 0)
        'heading': heading.round().clamp(0, _maxHeading),
    };
  }
}

abstract class LocationSource {
  /// One reading now. Throws [LocationFailure].
  Future<LocationPoint> current();

  /// Keeps reading until cancelled, also in the background.
  Stream<LocationPoint> watch({required int intervalSeconds});
}

class GeolocatorLocationSource implements LocationSource {
  GeolocatorLocationSource({required this._notification});

  static const _timeout = Duration(seconds: 15);

  /// Title and text of the Android notification that keeps the service alive.
  final ({String title, String text}) Function() _notification;

  LocationPoint _point(Position position) => LocationPoint(
    lat: position.latitude,
    lng: position.longitude,
    recordedAt: position.timestamp,
    accuracy: position.accuracy,
    speed: position.speed,
    heading: position.heading,
  );

  Future<void> _ensureAllowed() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationFailure(LocationProblem.serviceOff);
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationFailure(LocationProblem.denied);
    }
  }

  @override
  Future<LocationPoint> current() async {
    await _ensureAllowed();
    try {
      return _point(
        await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: _timeout,
          ),
        ),
      );
    } on TimeoutException {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return _point(last);
      throw const LocationFailure(LocationProblem.unavailable);
    }
  }

  @override
  Stream<LocationPoint> watch({required int intervalSeconds}) =>
      Geolocator.getPositionStream(locationSettings: _settings(intervalSeconds))
          .map(_point);

  LocationSettings _settings(int intervalSeconds) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final notification = _notification();
        return AndroidSettings(
          accuracy: LocationAccuracy.high,
          intervalDuration: Duration(seconds: intervalSeconds),
          foregroundNotificationConfig: ForegroundNotificationConfig(
            notificationTitle: notification.title,
            notificationText: notification.text,
            enableWakeLock: true,
          ),
        );
      case TargetPlatform.iOS:
        return AppleSettings(
          accuracy: LocationAccuracy.high,
          allowBackgroundLocationUpdates: true,
          pauseLocationUpdatesAutomatically: false,
          showBackgroundLocationIndicator: true,
        );
      default:
        return const LocationSettings(accuracy: LocationAccuracy.high);
    }
  }
}
