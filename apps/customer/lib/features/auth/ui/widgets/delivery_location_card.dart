import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../state/welcome_cubit.dart';

/// Map preview + the chosen location. The API has no place names for a point,
/// so the card shows the address label and its coordinates.
class DeliveryLocationCard extends StatelessWidget {
  const DeliveryLocationCard({super.key, required this.state});

  final WelcomeState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final address = state.address;
    return BarqGap(
      gap: 0,
      children: [
        BarqFieldLabel(l10n.welcomeLocationLabel),
        BarqCard(
          padding: EdgeInsets.zero,
          clip: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: BarqSizes.welcomeMap,
                child: BarqMapBackground(
                  children: [
                    Center(
                      child: BarqIllustration(
                        BarqIllustrations.pin3d,
                        width: BarqSizes.welcomePin,
                        height: BarqSizes.welcomePin,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: BarqSpacing.section,
                  vertical: BarqSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: BarqGap(
                        gap: 0,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address?.label ?? l10n.welcomeNoLocation,
                            style: BarqText.h3,
                          ),
                          if (address != null)
                            // Coordinates always read left to right.
                            Text(
                              '\u2066${address.lat.toStringAsFixed(4)}, '
                              '${address.lng.toStringAsFixed(4)}\u2069',
                              style: BarqText.xs,
                            ),
                        ],
                      ),
                    ),
                    if (state.outOfZone)
                      BarqPill(
                        l10n.welcomeOutOfZone,
                        tone: BarqPillTone.danger,
                        icon: BarqIcons.x,
                      )
                    else if (address != null)
                      BarqPill(
                        l10n.welcomeInZone,
                        tone: BarqPillTone.success,
                        icon: BarqIcons.check,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
