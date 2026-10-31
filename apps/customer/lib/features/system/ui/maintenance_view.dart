import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

class MaintenanceView extends StatelessWidget {
  const MaintenanceView({super.key, this.onRefresh, this.loading = false});

  final VoidCallback? onRefresh;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final config = ConfigScope.of(context);
    final phone = config.isLoaded ? config.config.supportPhone : null;
    return DesignOverlay(
      image: 'design/07_states_05.png',
      child: BarqScreen(
        body: BarqStateView(
          blobGradient: BarqBlob.yellow,
          illustration: const BarqIconCard(
            icon: BarqIcons.wrench,
            angle: 8,
            radius: 50,
            iconColor: BarqColors.ink,
          ),
          title: l10n.maintenanceTitle,
          message: l10n.maintenanceBody,
          code: 'maintenance · project_frozen',
          actions: [
            BarqButton(
              label: l10n.maintenanceRefresh,
              icon: BarqIcons.refresh,
              variant: BarqButtonVariant.light,
              loading: loading,
              onPressed: onRefresh,
            ),
          ],
          footer: phone == null
              ? null
              : Text(
                  // Keeps the phone digits in LTR order.
                  '${l10n.maintenanceContact}\u2066$phone\u2069',
                  textAlign: TextAlign.center,
                  style: BarqText.xs,
                ),
        ),
      ),
    );
  }
}
