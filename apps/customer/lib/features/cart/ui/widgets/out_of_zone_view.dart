import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';

class OutOfZoneView extends StatelessWidget {
  const OutOfZoneView({
    super.key,
    this.code,
    required this.onChangeAddress,
    this.onCompare,
  });

  /// Like "422 out_of_zone".
  final String? code;
  final VoidCallback onChangeAddress;

  /// Set when the address is served but the cart's store does not reach it, so
  /// other stores can take the cart.
  final VoidCallback? onCompare;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final compare = onCompare;
    return DesignOverlay(
      image: 'design/07_states_01.png',
      child: BarqScreen(
        body: BarqStateView(
          illustration: const BarqOutOfZoneArt(),
          title: l10n.outOfZoneTitle,
          message: compare == null
              ? l10n.outOfZoneBody
              : l10n.outOfZoneStoreBody,
          code: code,
          actions: [
            if (compare != null)
              BarqButton(label: l10n.outOfZoneCompare, onPressed: compare),
            BarqButton(
              label: l10n.outOfZoneChange,
              variant: compare == null
                  ? BarqButtonVariant.primary
                  : BarqButtonVariant.white,
              onPressed: onChangeAddress,
            ),
          ],
        ),
      ),
    );
  }
}
