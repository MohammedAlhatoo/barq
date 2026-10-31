import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/widgets.dart';

import '../config/config_scope.dart';

/// Horizontal order progress. [keys] picks the steps; labels come from the
/// config.
class OrderStatusProgress extends StatelessWidget {
  const OrderStatusProgress({
    super.key,
    required this.keys,
    required this.current,
    this.showLabels = false,
  });

  /// One of the lists in [OrderTimelines].
  final List<String> keys;

  /// The order's status key.
  final String current;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final config = ConfigScope.of(context).config;
    final rows = config.timeline(keys, current);
    return BarqStepProgress(
      count: rows.length,
      current: config.timelineIndex(rows, current),
      labels: showLabels ? [for (final row in rows) row.label] : null,
    );
  }
}
