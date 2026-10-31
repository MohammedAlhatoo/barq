import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

/// Holds a tab until its own screen is built later in this phase.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) => BarqMessageView(
    title: AppLocalizations.of(context).comingSoon,
    icon: BarqIcons.clock,
  );
}
