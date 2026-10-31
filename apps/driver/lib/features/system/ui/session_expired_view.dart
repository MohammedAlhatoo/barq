import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

class SessionExpiredView extends StatelessWidget {
  const SessionExpiredView({super.key, required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BarqScreen(
      body: BarqStateView(
        illustration: const BarqIconCard(
          icon: BarqIcons.lock,
          circle: true,
          gradient: BarqGradients.orange,
        ),
        title: l10n.sessionTitle,
        message: l10n.sessionBody,
        actions: [BarqButton(label: l10n.sessionLogin, onPressed: onLogin)],
      ),
    );
  }
}
