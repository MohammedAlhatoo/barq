import 'package:barq_ui/barq_ui.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/data/auth_models.dart';

/// The server stores the label as plain text, so the icon comes from comparing
/// it with this language's names. A name saved in the other language gets the
/// plain pin.
String addressIcon(AppLocalizations l10n, SavedAddress address) =>
    switch (address.label) {
      final label? when label == l10n.addressHome => BarqIcons.home,
      final label? when label == l10n.addressWork => BarqIcons.store,
      _ => BarqIcons.pin,
    };

String addressTitle(AppLocalizations l10n, SavedAddress address) {
  final label = address.label ?? '';
  return label.isEmpty ? l10n.addressUnnamed : label;
}
