import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/di.dart';
import '../../data/orders_models.dart';

/// The driver, the store, the home and the road the driver has just driven.
/// The camera fits them once and stays where the user moves it.
class TrackingMap extends StatelessWidget {
  const TrackingMap({
    super.key,
    required this.tracking,
    required this.bottomInset,
  });

  final Tracking tracking;

  /// How much of the map the sheet covers.
  final double bottomInset;

  static const _maxZoom = 17.0;
  static const _edge = 60.0;
  static const _lineWidth = 6.0;
  static const _storePin = 40.0;

  LatLng _point(MapPoint point) => LatLng(point.lat, point.lng);

  Marker _marker(MapPoint point, Widget pin, double size) =>
      Marker(point: _point(point), width: size, height: size, child: pin);

  @override
  Widget build(BuildContext context) {
    final tiles = context.read<AppDependencies>().mapTileUrl;
    final driver = tracking.driverLocation;
    final path = [
      for (final point in tracking.pathTail) _point(point),
      if (driver != null) _point(driver),
    ];
    return BarqMapBackground(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCameraFit: CameraFit.coordinates(
              coordinates: [
                _point(tracking.pickup),
                _point(tracking.dropoff),
                if (driver != null) _point(driver),
              ],
              maxZoom: _maxZoom,
              padding: EdgeInsets.fromLTRB(
                _edge,
                _edge * 2,
                _edge,
                bottomInset + _edge,
              ),
            ),
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            if (tiles != null)
              TileLayer(
                urlTemplate: tiles,
                userAgentPackageName: 'com.barq.barq_customer',
              ),
            if (path.length > 1)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: path,
                    color: BarqColors.primary,
                    strokeWidth: _lineWidth,
                    pattern: const StrokePattern.dotted(),
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                _marker(
                  tracking.pickup,
                  const BarqMapPin(
                    icon: BarqIcons.store,
                    style: BarqPinStyle.white,
                    size: _storePin,
                  ),
                  _storePin,
                ),
                _marker(
                  tracking.dropoff,
                  const BarqMapPin(icon: BarqIcons.home),
                  BarqSizes.mapPin,
                ),
                if (driver != null)
                  _marker(
                    driver,
                    const BarqMapPin(
                      icon: BarqIcons.bike,
                      style: BarqPinStyle.dark,
                    ),
                    BarqSizes.mapPin,
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
