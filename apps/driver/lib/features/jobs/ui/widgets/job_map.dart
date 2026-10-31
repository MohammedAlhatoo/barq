import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/di.dart';
import '../../data/job_models.dart';

/// The store, the home and the line between them, dimmed for the dark theme.
/// Without coordinates it stays the drawn map from the design.
class JobMap extends StatelessWidget {
  const JobMap({
    super.key,
    required this.job,
    required this.bottomInset,
    this.fence,
    this.fenceMeters,
  });

  final Job job;

  /// How much of the map the sheet covers.
  final double bottomInset;

  /// Draws the allowed circle around this place.
  final JobPlace? fence;
  final int? fenceMeters;

  static const _maxZoom = 16.0;
  static const _edge = 60.0;
  static const _lineWidth = 6.0;
  static const _pin = 46.0;

  @override
  Widget build(BuildContext context) {
    final pickup = job.pickup;
    final dropoff = job.dropoff;
    if (!pickup.hasLocation || !dropoff.hasLocation) {
      return const BarqMapBackground(darken: true);
    }
    final tiles = context.read<AppDependencies>().mapTileUrl;
    final store = LatLng(pickup.lat!, pickup.lng!);
    final home = LatLng(dropoff.lat!, dropoff.lng!);
    final fence = this.fence;
    final fenceMeters = this.fenceMeters;
    return BarqMapBackground(
      darken: true,
      children: [
        FlutterMap(
          options: MapOptions(
            initialCameraFit: CameraFit.coordinates(
              coordinates: [store, home],
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
            if (tiles != null) ...[
              TileLayer(
                urlTemplate: tiles,
                userAgentPackageName: 'com.barq.barq_driver',
              ),
              const IgnorePointer(child: ColoredBox(color: BarqColors.mapDim)),
            ],
            if (fence != null && fence.hasLocation && fenceMeters != null)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: LatLng(fence.lat!, fence.lng!),
                    radius: fenceMeters.toDouble(),
                    useRadiusInMeter: true,
                    color: BarqColors.primary.withValues(alpha: 0.18),
                    borderColor: BarqColors.primary,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [store, home],
                  color: BarqColors.primary,
                  strokeWidth: _lineWidth,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: store,
                  width: _pin,
                  height: _pin,
                  child: const BarqMapPin(
                    icon: BarqIcons.store,
                    style: BarqPinStyle.white,
                    size: _pin,
                  ),
                ),
                Marker(
                  point: home,
                  width: _pin,
                  height: _pin,
                  child: const BarqMapPin(icon: BarqIcons.home, size: _pin),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
