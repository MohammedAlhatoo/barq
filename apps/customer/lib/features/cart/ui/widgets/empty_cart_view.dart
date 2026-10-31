import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../l10n/generated/app_localizations.dart';

class EmptyCartView extends StatelessWidget {
  const EmptyCartView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DesignOverlay(
      image: 'design/07_states_02.png',
      child: BarqScreen(
        body: BarqStateView(
          blobGradient: BarqBlob.green,
          illustration: const BarqEmptyCartArt(),
          title: l10n.cartEmptyTitle,
          message: l10n.cartEmptyBody,
          actions: [
            BarqButton(
              label: l10n.cartBrowse,
              onPressed: () => context.go(Routes.home),
            ),
          ],
        ),
      ),
    );
  }
}
