import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../browse/ui/widgets/product_art.dart';
import '../../data/offer_models.dart';

/// One product of the offer. An offer item has no picture or category, so the
/// thumb is the general one.
class OfferItemRow extends StatelessWidget {
  const OfferItemRow({super.key, required this.item});

  final OfferItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final substitute = item.substitute;
    return BarqProductRow(
      thumb: BarqThumb(
        size: BarqSizes.cartThumb,
        radius: BarqRadius.iconTile,
        tile: ProductArt.tileOf(null),
        image: const ProductArt(),
      ),
      title: l10n.lineWithQty(item.name, item.qty),
      titleStyle: item.available ? null : BarqText.strike,
      subtitle: item.available
          ? l10n.offerUnitPrice(item.unitPrice.formatted)
          : null,
      extra: item.available
          ? null
          : BarqGap(
              gap: BarqSpacing.xxs,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BarqPill(l10n.offerUnavailable, tone: BarqPillTone.danger),
                if (substitute != null)
                  Row(
                    children: [
                      const BarqIcon(
                        BarqIcons.refresh,
                        size: BarqSizes.iconS,
                        color: BarqColors.successText,
                      ),
                      const SizedBox(width: BarqSpacing.xxs),
                      Expanded(
                        child: Text(
                          l10n.offerSubstitute(
                            substitute.name,
                            substitute.unitPrice.formatted,
                          ),
                          style: BarqText.xs.copyWith(
                            color: BarqColors.successText,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
      trailing: Text(item.lineTotal.formatted, style: BarqText.h3),
    );
  }
}
