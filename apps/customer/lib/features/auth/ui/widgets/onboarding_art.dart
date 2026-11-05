import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import 'onboarding_float.dart';

/// First slide: the app on a phone with the basket and the delivery time pill.
class ShopArt extends StatelessWidget {
  const ShopArt({super.key});

  @override
  Widget build(BuildContext context) {
    return BarqIllustrationArea(
      height: BarqSizes.onboardingArt,
      blobSize: BarqSizes.onboardingBlob,
      blobTop: BarqSizes.onboardingPhotoBlobTop,
      overlays: [
        PositionedDirectional(
          top: BarqSizes.onboardingPillTop,
          end: BarqSpacing.lg,
          child: BarqPill(
            AppLocalizations.of(context).onboardingShopPill,
            tone: BarqPillTone.white,
            icon: BarqIcons.clock,
            iconColor: BarqColors.primary,
          ),
        ),
      ],
      child: const _Layers([
        _ArtImage('assets/onboarding/shop_phone.webp'),
        OnboardingFloat(
          distance: 7,
          delay: .5,
          child: _ArtImage('assets/onboarding/shop_basket.webp'),
        ),
      ]),
    );
  }
}

/// Second slide: the price comparison on a phone. The picture is a sample
/// from the design, not real data.
class CompareArt extends StatelessWidget {
  const CompareArt({super.key});

  /// Where the savings badge sits in its picture.
  static const _badgeCenter = Alignment(-.55, -.43);

  @override
  Widget build(BuildContext context) {
    return const BarqIllustrationArea(
      height: BarqSizes.onboardingArt,
      blobSize: BarqSizes.onboardingBlob,
      blobTop: BarqSizes.onboardingPhotoBlobTop,
      child: _Layers([
        _ArtImage('assets/onboarding/compare_phone.webp'),
        OnboardingFloat(
          distance: 5,
          child: OnboardingPop(
            center: _badgeCenter,
            child: _ArtImage('assets/onboarding/compare_badge.webp'),
          ),
        ),
        OnboardingFloat(
          distance: 7,
          delay: .5,
          child: _ArtImage('assets/onboarding/compare_basket.webp'),
        ),
      ]),
    );
  }
}

/// Pictures of the same size on top of each other.
class _Layers extends StatelessWidget {
  const _Layers(this.layers);

  final List<Widget> layers;

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    clipBehavior: Clip.none,
    children: layers,
  );
}

class _ArtImage extends StatelessWidget {
  const _ArtImage(this.asset);

  final String asset;

  @override
  Widget build(BuildContext context) => Image.asset(
    asset,
    height: BarqSizes.onboardingPhotoHeight,
    excludeFromSemantics: true,
  );
}

/// Third slide: the delivery worker with the live tracking pill.
class DeliveryArt extends StatelessWidget {
  const DeliveryArt({super.key});

  static const _worker = 'assets/onboarding/delivery_worker.webp';

  @override
  Widget build(BuildContext context) {
    return BarqIllustrationArea(
      height: BarqSizes.onboardingArt,
      blobSize: BarqSizes.onboardingBlob,
      blobTop: BarqSizes.onboardingWorkerBlobTop,
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
      child: SizedBox(
        width: double.infinity,
        height: BarqSizes.onboardingArt,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            const PositionedDirectional(
              top: BarqSizes.onboardingSpeedLinesStartTop,
              end: BarqSpacing.md,
              child: BarqSpeedLines(alignment: CrossAxisAlignment.end),
            ),
            const PositionedDirectional(
              top: BarqSizes.onboardingSpeedLinesEndTop,
              start: BarqSpacing.md,
              child: BarqSpeedLines(),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: BarqSizes.onboardingImageTop,
              ),
              child: OnboardingFloat(
                distance: 5,
                child: Image.asset(
                  _worker,
                  height: BarqSizes.onboardingWorkerHeight,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
