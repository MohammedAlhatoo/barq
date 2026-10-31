import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../state/settings_cubit.dart';
import 'vehicle_label.dart';

/// Opened on top of the account screen, so it takes the cubit as a value.
Future<void> showSettingsSheet(BuildContext context, SettingsCubit cubit) =>
    showBarqSheet<void>(
      context,
      children: [
        BlocProvider.value(value: cubit, child: const _SettingsForm()),
      ],
    );

class _SettingsForm extends StatelessWidget {
  const _SettingsForm();

  static const _chip = 42.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = BarqPalette.of(context);
    final cubit = context.read<SettingsCubit>();
    return BlocConsumer<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) => current.saved,
      listener: (context, _) => closeBarqSheet<void>(context),
      builder: (context, state) => BarqGap(
        gap: 14,
        children: [
          Text(
            l10n.settingsVehicle,
            style: BarqText.h2.copyWith(color: p.text),
          ),
          Wrap(
            spacing: BarqSpacing.sm,
            runSpacing: BarqSpacing.sm,
            children: [
              for (final type in vehicleTypes)
                BarqChip(
                  label: vehicleLabel(l10n, type),
                  height: _chip,
                  selected: state.vehicleType == type,
                  onTap: () => cubit.chooseVehicle(type),
                ),
            ],
          ),
          Text(
            l10n.settingsLanguage,
            style: BarqText.h2.copyWith(color: p.text),
          ),
          BarqSegmented<String>(
            value: state.locale,
            onChanged: cubit.chooseLocale,
            options: [
              (value: 'ar', label: l10n.languageArabic),
              (value: 'en', label: l10n.languageEnglish),
            ],
          ),
          if (state.error != null)
            BarqNote(
              state.error!,
              icon: BarqIcons.alert,
              tone: BarqNoteTone.danger,
            ),
          BarqButton(
            label: l10n.settingsSave,
            loading: state.saving,
            onPressed: cubit.save,
          ),
        ],
      ),
    );
  }
}
