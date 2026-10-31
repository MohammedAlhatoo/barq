import '../../../l10n/generated/app_localizations.dart';

/// The values `PUT /driver/me` accepts for `vehicle_type`.
const vehicleTypes = [
  'motorcycle',
  'car',
  'bicycle',
  'van',
  'tuk_tuk',
  'on_foot',
];

/// The API sends keys, not text to show.
String vehicleLabel(AppLocalizations l10n, String type) => switch (type) {
  'motorcycle' => l10n.vehicleMotorcycle,
  'car' => l10n.vehicleCar,
  'bicycle' => l10n.vehicleBicycle,
  'van' => l10n.vehicleVan,
  'tuk_tuk' => l10n.vehicleTukTuk,
  'on_foot' => l10n.vehicleOnFoot,
  _ => type,
};
