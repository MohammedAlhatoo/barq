import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../browse/ui/widgets/product_art.dart';
import '../../data/checkout_models.dart';

/// "انتهت صلاحية السعر". The new quote is already on the screen behind it, so
/// closing the sheet is the same as going on with the new price.
class QuoteExpiredSheet extends StatelessWidget {
  const QuoteExpiredSheet({super.key, required this.repricing});

  final Repricing repricing;

  /// True when the user wants to go back to the cart.
  static Future<bool?> show(BuildContext context, Repricing repricing) =>
      showBarqSheet<bool>(
        context,
        children: [QuoteExpiredSheet(repricing: repricing)],
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final changes = repricing.changes;
    return BarqGap(
      gap: BarqSpacing.gap,
      children: [
        Row(
          children: [
            const BarqIconTile(BarqIcons.clock, tone: BarqTileTone.yellow),
            const SizedBox(width: BarqSpacing.gap),
            Expanded(
              child: BarqGap(
                gap: 0,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.quoteExpiredTitle, style: BarqText.h2),
                  Text(
                    l10n.quoteExpiredPassed(repricing.minutes),
                    style: BarqText.xs,
                  ),
                ],
              ),
            ),
          ],
        ),
        Text(
          changes.isEmpty ? l10n.quoteExpiredSame : l10n.quoteExpiredChanged,
          style: BarqText.body,
        ),
        for (final change in changes) _ChangeRow(change: change),
        BarqSummaryRow(
          l10n.quoteExpiredNewTotal,
          repricing.newTotal.formatted,
          total: true,
          valueWidget: changes.isEmpty
              ? null
              : BarqPrice(
                  repricing.newTotal.formatted,
                  compareAt: repricing.oldTotal.formatted,
                  style: BarqText.h2,
                ),
        ),
        BarqButton(
          label: l10n.quoteExpiredContinue,
          onPressed: () => closeBarqSheet(context, false),
        ),
        BarqButton(
          label: l10n.quoteExpiredReview,
          variant: BarqButtonVariant.light,
          onPressed: () => closeBarqSheet(context, true),
        ),
      ],
    );
  }
}

class _ChangeRow extends StatelessWidget {
  const _ChangeRow({required this.change});

  final PriceChange change;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final line = change.line;
    return BarqCard(
      color: BarqColors.primaryTint2,
      shadow: const [],
      padding: const EdgeInsets.symmetric(
        horizontal: BarqSpacing.gap,
        vertical: BarqSpacing.md,
      ),
      child: Row(
        children: [
          if (line != null) ...[
            BarqThumb(
              size: BarqSizes.cartThumb,
              radius: BarqRadius.iconTile,
              tile: ProductArt.tileOf(line.categoryIcon),
              image: ProductArt(
                imageUrl: line.imageUrl,
                categoryIcon: line.categoryIcon,
              ),
            ),
            const SizedBox(width: BarqSpacing.gap),
          ],
          Expanded(
            child: BarqGap(
              gap: 0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line == null
                      ? change.title
                      : l10n.lineWithQty(change.title, line.qty),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: BarqText.h3,
                ),
                Row(
                  children: [
                    Text(
                      change.before.formatted,
                      style: BarqText.strike.copyWith(color: BarqColors.muted),
                    ),
                    const SizedBox(width: BarqSpacing.xs),
                    const BarqIcon(BarqIcons.arrow, size: BarqSizes.iconS),
                    const SizedBox(width: BarqSpacing.xs),
                    Text(change.after.formatted, style: BarqText.tBold),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
