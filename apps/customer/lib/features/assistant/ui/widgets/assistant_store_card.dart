import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../data/assistant_models.dart';

/// One store of the assistant's answer: its total, distance and what it misses.
class AssistantStoreCard extends StatelessWidget {
  const AssistantStoreCard({
    super.key,
    required this.option,
    required this.best,
    required this.selected,
    required this.onTap,
  });

  final StoreOption option;

  /// Shows the "الأوفر" pill.
  final bool best;
  final bool selected;

  /// Null once a newer message came.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = option.store;
    final total = option.total;
    final km = option.distanceKm;
    return BarqCard(
      padding: const EdgeInsets.all(BarqSpacing.gap),
      borderColor: selected
          ? (best ? BarqColors.success : BarqColors.primary)
          : null,
      borderWidth: 2,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const BarqIconTile(BarqIcons.store, tone: BarqTileTone.neutral),
              const SizedBox(width: BarqSpacing.gap),
              Expanded(
                child: BarqGap(
                  gap: BarqSpacing.xxs,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (best)
                      BarqPill(
                        l10n.compareBest,
                        tone: BarqPillTone.successSolid,
                      ),
                    Text(store.vendorName, style: BarqText.h3),
                  ],
                ),
              ),
              const SizedBox(width: BarqSpacing.sm),
              Text((total ?? store.itemsTotal).formatted, style: BarqText.h3),
            ],
          ),
          const SizedBox(height: BarqSpacing.xs),
          Row(
            children: [
              if (km != null)
                BarqMetaRow(
                  items: [
                    (
                      icon: BarqIcons.pin,
                      text: l10n.distanceKm(km.toStringAsFixed(1)),
                      iconColor: null,
                    ),
                  ],
                ),
              const SizedBox(width: BarqSpacing.sm),
              Expanded(
                child: Text(
                  total == null
                      ? l10n.compareDeliveryLater
                      : l10n.compareWithDelivery,
                  textAlign: TextAlign.end,
                  style: BarqText.xs,
                ),
              ),
            ],
          ),
          if (!store.complete) ...[
            const SizedBox(height: BarqSpacing.sm),
            BarqNote(
              l10n.compareMissing(
                store.missingCount,
                store.missingLines.map((line) => line.name).join('، '),
              ),
              icon: BarqIcons.alert,
              tone: BarqNoteTone.warning,
            ),
          ],
        ],
      ),
    );
  }
}
