import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';

/// First slide: the basket with the delivery time pill.
class ShopArt extends StatelessWidget {
  const ShopArt({super.key});

  @override
  Widget build(BuildContext context) {
    return BarqIllustrationArea(
      height: BarqSizes.onboardingArt,
      blobSize: BarqSizes.onboardingBlob,
      blobTop: BarqSizes.onboardingBlobTop,
      overlays: [
        PositionedDirectional(
          top: BarqSizes.onboardingPillTop,
          start: BarqSpacing.lg,
          child: BarqPill(
            AppLocalizations.of(context).onboardingShopPill,
            tone: BarqPillTone.white,
            icon: BarqIcons.clock,
            iconColor: BarqColors.primary,
          ),
        ),
      ],
      child: const Padding(
        padding: EdgeInsets.only(top: BarqSizes.onboardingImageTop),
        child: BarqIllustration(
          BarqIllustrations.basket,
          width: BarqSizes.onboardingImage,
          height: BarqSizes.onboardingImage,
        ),
      ),
    );
  }
}

/// Second slide: three stores with the cheapest one highlighted. The prices
/// are a sample from the design, not real data.
class CompareArt extends StatelessWidget {
  const CompareArt({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BarqIllustrationArea(
      height: BarqSizes.onboardingArt,
      blobSize: BarqSizes.onboardingBlob,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: BarqSpacing.page),
        child: BarqGap(
          children: [
            _StoreRow(
              name: l10n.onboardingCompareStoreA,
              items: l10n.onboardingCompareItems,
              price: l10n.onboardingComparePriceA,
            ),
            BarqCard(
              borderColor: BarqColors.success,
              borderWidth: 2,
              child: Row(
                children: [
                  const BarqIllustration(
                    BarqIllustrations.basket,
                    width: BarqSizes.compareImage,
                    height: BarqSizes.compareImage,
                  ),
                  const SizedBox(width: BarqSpacing.gap),
                  Expanded(
                    child: BarqGap(
                      gap: BarqSpacing.xxs,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.onboardingCompareStoreB, style: BarqText.h3),
                        BarqPill(
                          l10n.onboardingCompareBest,
                          tone: BarqPillTone.success,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    l10n.onboardingComparePriceB,
                    style: BarqText.h2.copyWith(color: BarqColors.success),
                  ),
                ],
              ),
            ),
            _StoreRow(
              name: l10n.onboardingCompareStoreC,
              items: l10n.onboardingCompareItems,
              price: l10n.onboardingComparePriceC,
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreRow extends StatelessWidget {
  const _StoreRow({
    required this.name,
    required this.items,
    required this.price,
  });

  final String name;
  final String items;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: BarqSpacing.sm),
      child: BarqCard(
        glass: true,
        padding: const EdgeInsets.all(BarqSpacing.gap),
        child: Row(
          children: [
            const BarqIllustration(
              BarqIllustrations.storefront,
              width: BarqSizes.compareImage,
              height: BarqSizes.compareImage,
            ),
            const SizedBox(width: BarqSpacing.gap),
            Expanded(
              child: BarqGap(
                gap: 0,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: BarqText.h3),
                  Text(items, style: BarqText.xs),
                ],
              ),
            ),
            Text(price, style: BarqText.h3),
          ],
        ),
      ),
    );
  }
}

/// Third slide: the scooter with the live tracking pill.
class DeliveryArt extends StatelessWidget {
  const DeliveryArt({super.key});

  @override
  Widget build(BuildContext context) {
    return BarqIllustrationArea(
      height: BarqSizes.onboardingArt,
      blobSize: BarqSizes.onboardingBlob,
      blobTop: BarqSizes.onboardingBlobTop,
      overlays: [
        PositionedDirectional(
          top: BarqSizes.onboardingPillTop,
          end: BarqSpacing.lg,
          child: BarqPill(
            AppLocalizations.of(context).onboardingDeliveryPill,
            tone: BarqPillTone.white,
            icon: BarqIcons.pin,
            iconColor: BarqColors.primary,
          ),
        ),
      ],
      child: const Padding(
        padding: EdgeInsets.only(top: BarqSizes.onboardingImageTop),
        child: BarqIllustration(
          BarqIllustrations.scooter,
          width: BarqSizes.onboardingScooterWidth,
          height: BarqSizes.onboardingScooterHeight,
        ),
      ),
    );
  }
}
