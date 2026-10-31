import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../app/di.dart';
import '../../../l10n/generated/app_localizations.dart';

String _locale(BuildContext context) =>
    Localizations.localeOf(context).languageCode;

/// "الإثنين 26 أكتوبر"
String formatDay(BuildContext context, DateTime date) =>
    DateFormat('EEEE d MMMM', _locale(context)).format(date.toLocal());

/// "4:41 م"
String formatTime(BuildContext context, DateTime date) =>
    DateFormat.jm(_locale(context)).format(date.toLocal());

/// "الأربعاء 28 أكتوبر 2026 · 4:41 م"
String formatDayAndTime(BuildContext context, DateTime date) =>
    '${DateFormat('EEEE d MMMM y', _locale(context)).format(date.toLocal())}'
    ' · ${formatTime(context, date)}';

/// "منذ 3 د"
String formatAgo(BuildContext context, DateTime date) {
  final l10n = AppLocalizations.of(context);
  final passed = DateTime.now().difference(date);
  if (passed.inMinutes < 1) return l10n.timeNow;
  if (passed.inHours < 1) return l10n.timeMinutes(passed.inMinutes);
  if (passed.inDays < 1) return l10n.timeHours(passed.inHours);
  return l10n.timeDays(passed.inDays);
}

/// `vehicle_type` is a key, so its name is translated here.
String vehicleName(AppLocalizations l10n, String? type) => switch (type) {
  'motorcycle' => l10n.vehicleMotorcycle,
  'car' => l10n.vehicleCar,
  'bicycle' => l10n.vehicleBicycle,
  'van' => l10n.vehicleVan,
  'tuk_tuk' => l10n.vehicleTukTuk,
  'on_foot' => l10n.vehicleOnFoot,
  _ => type ?? '',
};

/// Opens the dialer, or shows the number when the phone can't call.
Future<void> callOrShow(BuildContext context, String phone) async {
  final l10n = AppLocalizations.of(context);
  final called = await context.read<AppDependencies>().vendorActions.call(
    phone,
  );
  if (called || !context.mounted) return;
  await showBarqSheet<void>(
    context,
    children: [
      Text(l10n.vendorCallFailed, style: BarqText.h2),
      Text(phone, style: BarqText.body),
      BarqButton(
        label: l10n.commonOk,
        onPressed: () => closeBarqSheet<void>(context),
      ),
    ],
  );
}
