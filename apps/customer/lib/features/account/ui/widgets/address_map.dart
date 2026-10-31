import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/di.dart';

/// The map of the address form. The pin stays in the middle and the map moves
/// under it, so the address is always the map's center.
class AddressMap extends StatefulWidget {
  const AddressMap({
    super.key,
    required this.lat,
    required this.lng,
    required this.moves,
    required this.hint,
    required this.credit,
    required this.onMoved,
  });

  final double lat;
  final double lng;

  /// A new value makes the map jump to [lat] and [lng].
  final int moves;
  final String hint;

  /// OpenStreetMap asks every map that uses its tiles to show this.
  final String credit;
  final void Function(double lat, double lng) onMoved;

  @override
  State<AddressMap> createState() => _AddressMapState();
}

class _AddressMapState extends State<AddressMap> {
  static const _zoom = 16.0;

  final _controller = MapController();

  @override
  void didUpdateWidget(AddressMap old) {
    super.didUpdateWidget(old);
    if (widget.moves != old.moves) {
      _controller.move(LatLng(widget.lat, widget.lng), _zoom);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tiles = context.read<AppDependencies>().mapTileUrl;
    return BarqMapBackground(
      children: [
        FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCenter: LatLng(widget.lat, widget.lng),
            initialZoom: _zoom,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            onPositionChanged: (camera, hasGesture) {
              if (hasGesture) {
                widget.onMoved(camera.center.latitude, camera.center.longitude);
              }
            },
          ),
          children: [
            if (tiles != null)
              TileLayer(
                urlTemplate: tiles,
                userAgentPackageName: 'com.barq.barq_customer',
              ),
          ],
        ),
        BarqMapCenterPin(hint: widget.hint),
        Align(
          alignment: AlignmentDirectional.bottomEnd,
          child: Padding(
            padding: const EdgeInsets.all(BarqSpacing.xs),
            child: Text(widget.credit, style: BarqText.xs),
          ),
        ),
      ],
    );
  }
}
