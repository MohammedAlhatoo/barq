import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../data/browse_models.dart';

/// Rating, preparation time and distance, for every place that shows a store.
BarqVendorMeta vendorMeta(AppLocalizations l10n, Vendor vendor) {
  final average = vendor.ratingAverage;
  final prep = vendor.prepMinutes;
  final km = vendor.distanceKm;
  return [
    (
      icon: BarqIcons.star,
      // Zero ratings would read as a bad store, not a new one.
      text: average != null && vendor.ratingCount > 0
          ? '$average (${vendor.ratingCount})'
          : l10n.vendorNew,
      iconColor: BarqColors.star,
    ),
    if (prep != null)
      (icon: BarqIcons.clock, text: l10n.vendorPrep(prep), iconColor: null),
    if (km != null)
      (
        icon: BarqIcons.pin,
        text: l10n.distanceKm(km.toStringAsFixed(1)),
        iconColor: null,
      ),
  ];
}

/// The API sends a key such as "grocery". Unknown keys show as they came.
String vendorCategory(AppLocalizations l10n, String category) =>
    switch (category) {
      'grocery' => l10n.vendorCategoryGrocery,
      _ => category,
    };

/// The store's logo, or the storefront illustration when it has none.
class VendorLogo extends StatelessWidget {
  const VendorLogo({super.key, this.url});

  final String? url;

  @override
  Widget build(BuildContext context) => BarqNetworkImage(
    url: url,
    fallback: const BarqIllustration(BarqIllustrations.storefront),
  );
}
