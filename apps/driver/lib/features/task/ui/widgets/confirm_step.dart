import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../jobs/data/job_models.dart';

/// Asks `next_action.confirm` when the server sets it. True means go ahead.
Future<bool> confirmStep(BuildContext context, NextAction next) async {
  final question = next.confirm;
  if (question == null) return true;
  final l10n = AppLocalizations.of(context);
  final p = BarqPalette.of(context);
  final answer = await showBarqSheet<bool>(
    context,
    children: [
      Text(question, style: BarqText.h2.copyWith(color: p.text)),
      Builder(
        builder: (sheet) => BarqButton(
          label: next.label,
          onPressed: () => closeBarqSheet(sheet, true),
        ),
      ),
      Builder(
        builder: (sheet) => BarqButton(
          label: l10n.commonCancel,
          variant: BarqButtonVariant.white,
          onPressed: () => closeBarqSheet(sheet, false),
        ),
      ),
    ],
  );
  return answer ?? false;
}
