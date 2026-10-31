import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

/// Stands in for a screen that a later phase builds.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.design,
    this.back = false,
  });

  final String title;
  final String design;
  final bool back;

  @override
  Widget build(BuildContext context) {
    return DesignOverlay(
      image: design,
      child: BarqScreen(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BarqHeader(title: title, back: back),
            Expanded(
              child: Center(
                child: Text(
                  AppLocalizations.of(context).placeholderSoon,
                  style: BarqText.body,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
