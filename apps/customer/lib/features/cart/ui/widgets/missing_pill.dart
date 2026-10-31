import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../data/cart_models.dart';

/// "ناقص 2 · بيض بلدي، حليب", or the reason when only quantities are short.
class MissingPill extends StatelessWidget {
  const MissingPill({
    super.key,
    required this.store,
    this.tone = BarqPillTone.danger,
  });

  final BasketStore store;
  final BarqPillTone tone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final missing = store.missingLines;
    final onlyStock = missing.every((l) => l.reason == 'not_enough_stock');
    final detail = onlyStock
        ? l10n.compareNotEnough
        : missing.map((line) => line.name).join('، ');
    return BarqPill(
      l10n.compareMissing(store.missingCount, detail),
      tone: tone,
    );
  }
}
