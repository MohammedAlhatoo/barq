import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../l10n/generated/app_localizations.dart';

class OutOfZoneView extends StatelessWidget {
  const OutOfZoneView({super.key, this.code});

  /// Like "422 out_of_zone".
  final String? code;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DesignOverlay(
      image: 'design/07_states_01.png',
      child: BarqScreen(
        body: BarqStateView(
          illustration: const BarqOutOfZoneArt(),
          title: l10n.outOfZoneTitle,
          message: l10n.outOfZoneBody,
          code: code,
          actions: [
            BarqButton(
              label: l10n.outOfZoneChange,
              // The addresses screen itself comes in phase 4.
              onPressed: () => context.go(Routes.account),
            ),
          ],
        ),
      ),
    );
  }
}
