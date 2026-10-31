import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/orders_models.dart';
import '../state/receipt_cubit.dart';
import 'order_format.dart';
import 'reorder_flow.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DesignOverlay(
      image: 'design/05_after_order_04.png',
      child: BarqScreen(
        body: BlocBuilder<ReceiptCubit, ReceiptState>(
          builder: (context, state) {
            final receipt = state.receipt;
            final order = state.order;
            final error = state.error;
            if (receipt == null || order == null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BarqHeader(title: l10n.receiptTitle, back: true),
                  Expanded(
                    child: state.loading
                        ? const BarqLoadingView()
                        : BarqMessageView(
                            title: error ?? l10n.commonRetry,
                            icon: BarqIcons.alert,
                            actionLabel: l10n.commonRetry,
                            onAction: context.read<ReceiptCubit>().load,
                          ),
                  ),
                ],
              );
            }
            return _body(context, state, receipt, order);
          },
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    ReceiptState state,
    Receipt receipt,
    Order order,
  ) {
    final l10n = AppLocalizations.of(context);
    final config = ConfigScope.of(context).config;
    final delivered = stageOf(config, order.statusKey) == OrderStage.delivered;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final store = order.vendorName;
    final reorderError = state.reorderError;
    final actions = context.read<AppDependencies>().vendorActions;
    // A dashed divider cannot live in BarqFillScroll, which measures its
    // children first, so the list and the buttons are separate.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              BarqHeader(
                title: l10n.receiptTitle,
                back: true,
                trailing: BarqIconButton(
                  icon: BarqIcons.share,
                  onPressed: () => actions.share(
                    l10n.receiptShareText(
                      receipt.code,
                      receipt.total.formatted,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  BarqSpacing.page,
                  BarqSpacing.section,
                  BarqSpacing.page,
                  0,
                ),
                child: BarqCard(
                  child: BarqGap(
                    gap: BarqSpacing.sm,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const BarqWordmark(size: 38),
                          if (delivered)
                            BarqPill(
                              l10n.receiptPaidCash,
                              tone: BarqPillTone.success,
                            )
                          else
                            OrderStatusPill(order.statusKey),
                        ],
                      ),
                      Text(
                        '${receipt.code}'
                        ' · ${formatDayAndTime(context, receipt.completedAt ?? receipt.createdAt)}',
                        style: BarqText.xs,
                      ),
                      if (store != null) Text(store, style: BarqText.tBold),
                      const BarqDivider(dashed: true),
                      for (final item in receipt.items)
                        BarqSummaryRow('${item.name} × ${item.qty}', ''),
                      const BarqDivider(dashed: true),
                      for (final line in receipt.lines)
                        BarqSummaryRow(
                          arabic ? line.labelAr : line.labelEn,
                          line.amount.formatted,
                        ),
                      BarqSummaryRow(
                        l10n.receiptTotal,
                        receipt.total.formatted,
                        total: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: BarqSpacing.stateBottom),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              BarqSpacing.page,
              BarqSpacing.section,
              BarqSpacing.page,
              0,
            ),
            child: BarqGap(
              gap: BarqSpacing.md,
              children: [
                if (reorderError != null)
                  BarqNote(
                    reorderError,
                    icon: BarqIcons.alert,
                    tone: BarqNoteTone.danger,
                  ),
                if (order.vendorId != null && order.isTerminal)
                  BarqButton(
                    label: l10n.receiptReorder,
                    icon: BarqIcons.refresh,
                    loading: state.reordering,
                    onPressed: () => reorderToCart(
                      context,
                      context.read<ReceiptCubit>().reorder,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
