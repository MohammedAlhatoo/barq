import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../browse/ui/widgets/load_more_listener.dart';
import '../data/orders_models.dart';
import '../state/orders_cubit.dart';
import 'order_format.dart';
import 'reorder_flow.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  /// Leaves room for the nav bar.
  static const _listBottom = 120.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DesignOverlay(
      image: 'design/05_after_order_03.png',
      child: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          final cubit = context.read<OrdersCubit>();
          final total = state.currentTotal;
          final error = state.error;
          final reorderError = state.reorderError;
          final items = state.tab == OrdersTab.current
              ? state.current
              : state.past;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BarqHeader(
                title: l10n.navOrders,
                large: true,
                bottom: BarqSegmented<OrdersTab>(
                  white: true,
                  value: state.tab,
                  onChanged: cubit.selectTab,
                  options: [
                    (
                      value: OrdersTab.current,
                      label: total == null || total == 0
                          ? l10n.ordersTabCurrent
                          : l10n.ordersTabCurrentCount(total),
                    ),
                    (value: OrdersTab.past, label: l10n.ordersTabPast),
                  ],
                ),
              ),
              if (reorderError != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    BarqSpacing.page,
                    BarqSpacing.md,
                    BarqSpacing.page,
                    0,
                  ),
                  child: BarqNote(
                    reorderError,
                    icon: BarqIcons.alert,
                    tone: BarqNoteTone.danger,
                  ),
                ),
              Expanded(
                child: state.loading
                    ? const BarqLoadingView()
                    : error != null
                    ? BarqMessageView(
                        title: error,
                        icon: BarqIcons.alert,
                        actionLabel: l10n.commonRetry,
                        onAction: cubit.load,
                      )
                    : items.isEmpty
                    ? BarqMessageView(
                        title: state.tab == OrdersTab.current
                            ? l10n.ordersEmptyCurrent
                            : l10n.ordersEmptyPast,
                        icon: BarqIcons.receipt,
                      )
                    : RefreshIndicator(
                        color: BarqColors.primary,
                        onRefresh: cubit.load,
                        child: LoadMoreListener(
                          onLoadMore: cubit.loadMore,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(
                              BarqSpacing.page,
                              BarqSpacing.section,
                              BarqSpacing.page,
                              _listBottom,
                            ),
                            itemCount: items.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: BarqSpacing.gap),
                            itemBuilder: (context, index) =>
                                state.tab == OrdersTab.current
                                ? _CurrentCard(order: items[index])
                                : _PastCard(order: items[index]),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CurrentCard extends StatelessWidget {
  const _CurrentCard({required this.order});

  final OrderSummary order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BarqCard(
      borderColor: BarqColors.primaryBorder,
      child: BarqGap(
        gap: BarqSpacing.gap,
        children: [
          Row(
            children: [
              const BarqIllustration(
                BarqIllustrations.storefront,
                width: BarqSizes.iconTile,
                height: BarqSizes.iconTile,
              ),
              const SizedBox(width: BarqSpacing.gap),
              Expanded(
                child: BarqGap(
                  gap: 0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.code, style: BarqText.h3),
                    Text(
                      l10n.ordersItems(
                        order.itemsCount ?? 0,
                        order.total.formatted,
                      ),
                      style: BarqText.xs,
                    ),
                  ],
                ),
              ),
              OrderStatusPill(order.statusKey),
            ],
          ),
          OrderStatusProgress(
            keys: OrderTimelines.tracking,
            current: order.statusKey,
          ),
          BarqButton(
            label: l10n.ordersFollow,
            icon: BarqIcons.map,
            onPressed: () => context.push(Routes.orderOf(order.id)),
          ),
        ],
      ),
    );
  }
}

class _PastCard extends StatelessWidget {
  const _PastCard({required this.order});

  final OrderSummary order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final config = ConfigScope.of(context).config;
    final delivered = stageOf(config, order.statusKey) == OrderStage.delivered;
    final cubit = context.read<OrdersCubit>();
    return GestureDetector(
      onTap: () => context.push(Routes.receiptOf(order.id)),
      child: BarqCard(
        child: Row(
          children: [
            const BarqIconTile(BarqIcons.receipt, tone: BarqTileTone.neutral),
            const SizedBox(width: BarqSpacing.gap),
            Expanded(
              child: BarqGap(
                gap: 0,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.code, style: BarqText.h3),
                  Text(
                    '${formatDay(context, order.createdAt)}'
                    ' · ${order.total.formatted}',
                    style: BarqText.xs,
                  ),
                ],
              ),
            ),
            BarqGap(
              gap: BarqSpacing.xs,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                OrderStatusPill(order.statusKey),
                if (delivered)
                  BarqLink(
                    l10n.ordersReorder,
                    onPressed: () =>
                        reorderToCart(context, () => cubit.reorder(order.id)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
