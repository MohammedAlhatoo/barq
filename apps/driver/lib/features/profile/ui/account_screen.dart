import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../app/locale_cubit.dart';
import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/driver_models.dart';
import '../state/driver_cubit.dart';
import '../state/settings_cubit.dart';
import 'settings_sheet.dart';
import 'vehicle_label.dart';

/// The API has no job count or zone name, so the design's "326 مهمة" and
/// "المنطقة الوسطى" pills are hidden.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  static const _avatar = 84.0;

  Future<void> _openSettings(BuildContext context, Driver driver) async {
    final deps = context.read<AppDependencies>();
    final cubit = SettingsCubit(
      repository: deps.profileRepository,
      driver: deps.driver,
      localeCubit: deps.locale,
      vehicleType: driver.vehicleType,
      locale: context.read<LocaleCubit>().state.languageCode,
    );
    await showSettingsSheet(context, cubit);
    await cubit.close();
  }

  Future<void> _logout(BuildContext context) async {
    final deps = context.read<AppDependencies>();
    await deps.driver.reset();
    try {
      await deps.authRepository.logout();
    } on ApiException catch (e) {
      debugPrint('Logout not confirmed by the server: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = BarqPalette.of(context);
    final config = ConfigScope.of(context);
    final support = config.isLoaded ? config.config.supportPhone : null;
    final language = Localizations.localeOf(context).languageCode == 'ar'
        ? l10n.languageArabic
        : l10n.languageEnglish;
    return BlocBuilder<DriverCubit, DriverState>(
      builder: (context, state) {
        final driver = state.driver;
        return DesignOverlay(
          image: 'design/09_driver_delivery_04.png',
          child: ListView(
            padding: const EdgeInsets.only(bottom: BarqSpacing.navClearance),
            children: [
              BarqHeader(large: true, title: l10n.navAccount),
              if (driver == null)
                state.error == null
                    ? const BarqLoadingView()
                    : BarqMessageView(
                        title: state.error!,
                        icon: BarqIcons.alert,
                        actionLabel: l10n.commonRetry,
                        onAction: context.read<DriverCubit>().load,
                      )
              else ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    BarqSpacing.page,
                    14,
                    BarqSpacing.page,
                    0,
                  ),
                  child: BarqCard(
                    padding: const EdgeInsets.all(BarqSpacing.page),
                    child: BarqGap(
                      gap: 14,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        BarqAvatar(
                          driver.initial,
                          size: _avatar,
                          imageUrl: driver.avatarUrl,
                        ),
                        Column(
                          children: [
                            Text(
                              driver.name,
                              style: BarqText.h2.copyWith(color: p.text),
                            ),
                            Text(
                              driver.phone,
                              textDirection: TextDirection.ltr,
                              style: BarqText.xs.copyWith(color: p.textMuted),
                            ),
                          ],
                        ),
                        BarqPill(
                          l10n.accountRating(
                            driver.ratingAverage.toString(),
                            driver.ratingCount,
                          ),
                          icon: BarqIcons.star,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    BarqSpacing.page,
                    BarqSpacing.gap,
                    BarqSpacing.page,
                    0,
                  ),
                  child: BarqCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: BarqSpacing.section,
                      vertical: BarqSpacing.xxs,
                    ),
                    child: Column(
                      children: [
                        BarqListTile(
                          title: l10n.accountVehicle,
                          leading: const BarqIconTile(BarqIcons.bike),
                          value: vehicleLabel(l10n, driver.vehicleType),
                          onTap: () => _openSettings(context, driver),
                        ),
                        BarqListTile(
                          title: l10n.settingsLanguage,
                          leading: const BarqIconTile(BarqIcons.globe),
                          value: language,
                          onTap: () => _openSettings(context, driver),
                        ),
                        BarqListTile(
                          title: l10n.accountNotifications,
                          leading: const BarqIconTile(BarqIcons.bell),
                          onTap: () => context.push(Routes.notifications),
                        ),
                        if (support != null)
                          BarqListTile(
                            title: l10n.accountSupport,
                            leading: const BarqIconTile(BarqIcons.help),
                            onTap: () => context
                                .read<AppDependencies>()
                                .deviceActions
                                .call(support),
                          ),
                        BarqListTile(
                          title: l10n.accountLogout,
                          titleColor: BarqColors.darkDangerIcon,
                          leading: const BarqIconTile(
                            BarqIcons.logout,
                            tone: BarqTileTone.red,
                          ),
                          showChevron: false,
                          showDivider: false,
                          onTap: () => _logout(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
