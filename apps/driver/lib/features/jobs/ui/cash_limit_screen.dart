import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../state/cash_limit_cubit.dart';

/// Shown when the server refuses an order with `cash_limit_reached`. The API
/// has no office location or hours, so the design's office row and button are
/// hidden, and support is the way forward.
class CashLimitScreen extends StatelessWidget {
  const CashLimitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = BarqPalette.of(context);
    final cubit = context.read<CashLimitCubit>();
    final config = ConfigScope.of(context);
    final phone = config.isLoaded ? config.config.supportPhone : null;
    return BlocBuilder<CashLimitCubit, CashLimitState>(
      builder: (context, state) {
        final cash = state.cash;
        if (cash == null) {
          return BarqScreen(
            body: Column(
              children: [
                const BarqHeader(back: true),
                Expanded(
                  child: state.loading
                      ? const BarqStatePageSkeleton(art: 110)
                      : BarqMessageView(
                          title: state.error ?? '',
                          icon: BarqIcons.alert,
                          actionLabel: l10n.commonRetry,
                          onAction: cubit.load,
                        ),
                ),
              ],
            ),
          );
        }
        return DesignOverlay(
          image: 'design/09_driver_delivery_07.png',
          child: BarqScreen(
            body: BarqStateView(
              blobGradient: BarqBlob.yellowGlow,
              illustration: const BarqIconCard(
                icon: BarqIcons.cash,
                size: 140,
                angle: -6,
                radius: 44,
                gradient: BarqGradients.cash,
                iconColor: BarqColors.ink,
              ),
              title: l10n.cashLimitTitle,
              message: l10n.cashLimitBody(cash.cashOnHand.formatted),
              actions: [
                BarqCard(
                  child: BarqGap(
                    gap: BarqSpacing.sm,
                    children: [
                      BarqSummaryRow(
                        l10n.cashLimitCollected,
                        cash.cashOnHand.formatted,
                      ),
                      BarqProgressBar(
                        value: cash.usedShare,
                        gradient: BarqGradients.cashLimit,
                      ),
                      Text(
                        l10n.cashLimitMax(cash.maxCash.formatted),
                        style: BarqText.xs.copyWith(color: p.textMuted),
                      ),
                    ],
                  ),
                ),
                if (phone != null)
                  BarqButton(
                    label: l10n.cashLimitSupport,
                    icon: BarqIcons.phone,
                    onPressed: () => context
                        .read<AppDependencies>()
                        .deviceActions
                        .call(phone),
                  ),
                BarqButton(
                  label: l10n.commonBack,
                  variant: BarqButtonVariant.white,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
