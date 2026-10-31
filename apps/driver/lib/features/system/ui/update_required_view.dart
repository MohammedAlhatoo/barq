import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

/// The API has no store link yet, so the button only asks the server again.
class UpdateRequiredView extends StatelessWidget {
  const UpdateRequiredView({super.key, this.onCheck, this.loading = false});

  final VoidCallback? onCheck;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final config = ConfigScope.of(context);
    final version = config.isLoaded ? config.config.minAppVersion : null;
    return BarqScreen(
      background: BarqScreenBackground.orange,
      body: Stack(
        children: [
          const Positioned.fill(child: BarqDecorCircles(showBottom: false)),
          BarqStateView(
            onOrange: true,
            illustration: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BarqLogoTile(),
                if (version != null) ...[
                  const SizedBox(height: BarqSpacing.xs),
                  BarqPill(
                    l10n.updateVersion(version),
                    tone: BarqPillTone.dark,
                  ),
                ],
              ],
            ),
            title: l10n.updateTitle,
            message: l10n.updateBody,
            actions: [
              BarqButton(
                label: l10n.updateNow,
                variant: BarqButtonVariant.white,
                labelColor: BarqColors.primaryText,
                loading: loading,
                onPressed: onCheck,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
