import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/orders_models.dart';
import '../../state/active_order_cubit.dart';

/// The running order. Tapping opens `/orders/{id}`, which moves on to the
/// offer or tracking screen as the order's status says.
class ActiveOrderBar extends StatelessWidget {
  const ActiveOrderBar({super.key});

  String _hint(
    BuildContext context,
    ActiveOrderState state,
    OrderSummary order,
  ) {
    final l10n = AppLocalizations.of(context);
    if (state.offerWaiting) return l10n.activeOrderOffer;
    final config = ConfigScope.of(context).config;
    return stageOf(config, order.statusKey) == OrderStage.tracking
        ? l10n.activeOrderTracking
        : l10n.activeOrderWaiting;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActiveOrderCubit, ActiveOrderState>(
      builder: (context, state) {
        final order = state.order;
        if (order == null) return const SizedBox.shrink();
        return BarqActiveOrderBar(
          code: order.code,
          hint: _hint(context, state, order),
          status: OrderStatusPill(order.statusKey),
          more: state.others,
          highlighted: state.offerWaiting,
          onTap: () async {
            final cubit = context.read<ActiveOrderCubit>();
            await context.push(Routes.orderOf(order.id));
            await cubit.refresh();
          },
        );
      },
    );
  }
}
