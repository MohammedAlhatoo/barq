import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/widgets.dart';

import '../config/config_scope.dart';

/// Order status chip. Label and color come from the server config.
class OrderStatusPill extends StatelessWidget {
  const OrderStatusPill(this.statusKey, {super.key});

  final String statusKey;

  @override
  Widget build(BuildContext context) {
    final status = ConfigScope.of(context).config.status(statusKey);
    return BarqPill(status.label, color: status.color);
  }
}
