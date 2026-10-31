import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

class NoInternetView extends StatelessWidget {
  const NoInternetView({super.key, this.onRetry, this.loading = false});

  final VoidCallback? onRetry;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BarqScreen(
      body: BarqStateView(
        blobGradient: BarqBlob.grey,
        illustration: const BarqIconCard(
          icon: BarqIcons.wifioff,
          circle: true,
          iconColor: BarqColors.ink,
        ),
        title: l10n.offlineTitle,
        message: l10n.offlineBody,
        actions: [
          BarqButton(
            label: l10n.commonRetry,
            icon: BarqIcons.refresh,
            variant: BarqButtonVariant.dark,
            loading: loading,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
