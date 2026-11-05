import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../data/history_repository.dart';
import '../state/history_cubit.dart';

/// `OrderSummary` has no store name, fare or cancel reason, so a row shows the
/// place, the time, the code and the cash instead.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static const _loadMoreThreshold = 300.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = BarqPalette.of(context);
    final cubit = context.read<HistoryCubit>();
    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        final today = state.today;
        final shown = state.shown;
        return DesignOverlay(
          image: 'design/09_driver_delivery_03.png',
          child: RefreshIndicator(
            onRefresh: cubit.load,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.extentAfter < _loadMoreThreshold) {
                  cubit.loadMore();
                }
                return false;
              },
              child: ListView(
                padding: const EdgeInsets.only(
                  bottom: BarqSpacing.navClearance,
                ),
                children: [
                  BarqHeader(
                    large: true,
                    title: l10n.historyTitle,
                    bottom: BarqChipsRow(
                      children: [
                        for (final (filter, label) in [
                          (HistoryFilter.all, l10n.historyAll),
                          (HistoryFilter.delivered, l10n.historyDelivered),
                          (HistoryFilter.cancelled, l10n.historyCancelled),
                        ])
                          BarqChip(
                            label: label,
                            selected: state.filter == filter,
                            height: BarqSizes.optionChip,
                            onTap: () => cubit.choose(filter),
                          ),
                      ],
                    ),
                  ),
                  if (today != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        BarqSpacing.page,
                        BarqSpacing.section,
                        BarqSpacing.page,
                        0,
                      ),
                      child: Text(
                        l10n.historyToday(
                          today.orders,
                          today.earnings.formatted,
                        ),
                        style: BarqText.xs.copyWith(color: p.textMuted),
                      ),
                    ),
                  const SizedBox(height: BarqSpacing.sm),
                  if (state.loading)
                    const BarqLoadingView()
                  else if (state.error != null)
                    BarqMessageView(
                      title: state.error!,
                      icon: BarqIcons.alert,
                      actionLabel: l10n.commonRetry,
                      onAction: cubit.load,
                    )
                  else if (shown.isEmpty)
                    BarqMessageView(
                      title: l10n.historyEmptyTitle,
                      message: l10n.historyEmptyBody,
                      icon: BarqIcons.history,
                    )
                  else
                    BarqGap(
                      gap: BarqSpacing.md,
                      padding: const EdgeInsets.symmetric(
                        horizontal: BarqSpacing.page,
                      ),
                      children: [
                        for (final (index, order) in shown.indexed)
                          BarqStaggerItem(
                            group: 'history',
                            index: index,
                            child: _OrderRow(order: order),
                          ),
                        if (state.loadingMore) const BarqLoadingView(),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order});

  final HistoryOrder order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = BarqPalette.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final format = DateFormat.jm(locale)..useNativeDigits = false;
    final time = format.format(
      (order.completedAt ?? order.createdAt).toLocal(),
    );
    return BarqCard(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: BarqSpacing.gap,
      ),
      child: Row(
        children: [
          BarqIconTile(
            order.isDelivered ? BarqIcons.check : BarqIcons.x,
            tone: order.isDelivered ? BarqTileTone.green : BarqTileTone.red,
          ),
          const SizedBox(width: BarqSpacing.gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.dropoffLabel ?? order.code,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: BarqText.h3.copyWith(color: p.text),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '$time · '),
                      TextSpan(text: order.code),
                      if (order.isDelivered)
                        TextSpan(
                          text: ' · ${l10n.historyCash(order.total.formatted)}',
                        ),
                    ],
                  ),
                  style: BarqText.xs.copyWith(color: p.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
