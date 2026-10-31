import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/widgets.dart';

import '../config/config_scope.dart';

/// Vertical order progress. Rows and their order come from the server config.
class OrderStatusTimeline extends StatelessWidget {
  const OrderStatusTimeline({
    super.key,
    required this.current,
    this.currentTrailing,
  });

  /// The order's status key.
  final String current;

  /// Shown at the end of the current row, such as a "الآن" pill.
  final Widget? currentTrailing;

  @override
  Widget build(BuildContext context) {
    final rows = ConfigScope.of(context).config.timeline(current);
    return BarqTimeline(
      items: [for (final row in rows) (icon: row.barqIcon, label: row.label)],
      current: rows.indexWhere((row) => row.key == current),
      currentTrailing: currentTrailing,
    );
  }
}
