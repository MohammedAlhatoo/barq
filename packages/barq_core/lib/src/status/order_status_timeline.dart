import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/widgets.dart';

import '../config/config_scope.dart';

/// Vertical order progress. [keys] picks the rows; labels come from the config.
class OrderStatusTimeline extends StatelessWidget {
  const OrderStatusTimeline({
    super.key,
    required this.keys,
    required this.current,
    this.currentTrailing,
  });

  /// One of the lists in [OrderTimelines].
  final List<String> keys;

  /// The order's status key.
  final String current;

  /// Shown at the end of the current row, such as a "الآن" pill.
  final Widget? currentTrailing;

  @override
  Widget build(BuildContext context) {
    final config = ConfigScope.of(context).config;
    final rows = config.timeline(keys, current);
    return BarqTimeline(
      items: [for (final row in rows) (icon: row.barqIcon, label: row.label)],
      current: config.timelineIndex(rows, current),
      currentTrailing: currentTrailing,
    );
  }
}
