import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';

/// "سلتك الحالية": the cart as it is now, so other stores have something to be
/// compared with.
class CurrentCartRow extends StatelessWidget {
  const CurrentCartRow({
    super.key,
    required this.name,
    required this.total,
    this.selected = false,
    this.isCheapest = false,
    this.onTap,
  });

  final String? name;

  /// The server's total with delivery. Null if the quote failed.
  final Money? total;
  final bool selected;
  final bool isCheapest;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = name;
    final price = total;
    return BarqCard(
      padding: const EdgeInsets.all(BarqSpacing.gap),
      borderColor: selected ? BarqColors.primary : null,
      borderWidth: 2,
      onTap: onTap,
      child: Row(
        children: [
          const BarqIconTile(BarqIcons.bag),
          const SizedBox(width: BarqSpacing.gap),
          Expanded(
            child: BarqGap(
              gap: BarqSpacing.xxs,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.compareCurrentCart, style: BarqText.h3),
                if (store != null) Text(store, style: BarqText.xs),
                // A pill would cut this long sentence off.
                if (isCheapest)
                  Text(
                    l10n.compareCurrentIsBest,
                    style: BarqText.xs.copyWith(color: BarqColors.successText),
                  ),
              ],
            ),
          ),
          const SizedBox(width: BarqSpacing.sm),
          BarqGap(
            gap: 0,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (price != null) Text(price.formatted, style: BarqText.h3),
              Text(
                price == null
                    ? l10n.compareDeliveryLater
                    : l10n.compareWithDelivery,
                style: BarqText.xs,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
