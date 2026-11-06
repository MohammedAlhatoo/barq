import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/phone_number.dart';
import '../data/account_models.dart';
import '../state/account_cubit.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DesignOverlay(
      image: 'design/06_account_01.png',
      child: BarqScreen(
        body: BlocBuilder<AccountCubit, AccountState>(
          builder: (context, state) {
            final profile = state.profile;
            final error = state.error;
            final Widget? message = state.loading
                ? const BarqSkeletonPage(
                    padding: EdgeInsets.fromLTRB(
                      BarqSpacing.page,
                      BarqSpacing.gap,
                      BarqSpacing.page,
                      0,
                    ),
                    children: [
                      BarqProfileCardSkeleton(stats: 2),
                      BarqListCardSkeleton(rows: 5),
                    ],
                  )
                : profile == null
                ? BarqMessageView(
                    title: error ?? '',
                    icon: BarqIcons.alert,
                    actionLabel: l10n.commonRetry,
                    onAction: context.read<AccountCubit>().load,
                  )
                : null;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BarqHeader(title: l10n.accountTitle, large: true),
                Expanded(
                  child:
                      message ?? _AccountBody(profile: profile!, state: state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AccountBody extends StatelessWidget {
  const _AccountBody({required this.profile, required this.state});

  final Profile profile;
  final AccountState state;

  Future<void> _confirmLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<AccountCubit>();
    final logout = await showBarqSheet<bool>(
      context,
      children: [
        Text(l10n.accountLogout, style: BarqText.h2),
        Text(l10n.accountLogoutBody, style: BarqText.body),
        BarqButton(
          label: l10n.accountLogout,
          variant: BarqButtonVariant.red,
          onPressed: () => closeBarqSheet(context, true),
        ),
        BarqButton(
          label: l10n.commonCancel,
          variant: BarqButtonVariant.light,
          onPressed: () => closeBarqSheet(context, false),
        ),
      ],
    );
    if (logout == true) await cubit.logout();
  }

  Future<void> _callSupport(BuildContext context, String phone) async {
    final l10n = AppLocalizations.of(context);
    final actions = context.read<AppDependencies>().vendorActions;
    final called = await actions.call(phone);
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

  /// «وفّرت» from the design is left out: the API has no field for it, and the
  /// app must not work out money by itself.
  List<({String value, String label})> _stats(AppLocalizations l10n) {
    final orders = state.orders;
    final addresses = state.addresses;
    return [
      if (orders != null) (value: '$orders', label: l10n.accountOrders),
      if (addresses != null)
        (value: '$addresses', label: l10n.accountAddresses),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final config = ConfigScope.of(context);
    final support = config.isLoaded ? config.config.supportPhone : null;
    final logoutError = state.logoutError;
    final unread = state.unread ?? 0;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        BarqSpacing.page,
        BarqSpacing.gap,
        BarqSpacing.page,
        BarqSpacing.navClearance,
      ),
      children: [
        BarqProfileCard(
          initial: profile.initial,
          name: profile.name ?? l10n.accountNoName,
          phone: PhoneNumber.display(profile.phone),
          imageUrl: profile.avatarUrl,
          onEdit: () => context.push(Routes.accountEdit),
          stats: _stats(l10n),
        ),
        const SizedBox(height: BarqSpacing.gap),
        if (logoutError != null) ...[
          BarqNote(
            logoutError,
            icon: BarqIcons.alert,
            tone: BarqNoteTone.danger,
          ),
          const SizedBox(height: BarqSpacing.gap),
        ],
        BarqCard(
          padding: const EdgeInsets.symmetric(
            horizontal: BarqSpacing.section,
            vertical: BarqSpacing.xxs,
          ),
          child: Column(
            children: [
              BarqListTile(
                title: l10n.accountMyAddresses,
                leading: const BarqIconTile(BarqIcons.pin),
                onTap: () => context.push(Routes.addresses),
              ),
              BarqListTile(
                title: l10n.accountNotifications,
                leading: const BarqIconTile(BarqIcons.bell),
                badge: unread > 0
                    ? BarqPill('$unread', tone: BarqPillTone.orange)
                    : null,
                onTap: () => context.push(Routes.notifications),
              ),
              BarqListTile(
                title: l10n.accountLanguage,
                value: l10n.accountLanguageName,
                leading: const BarqIconTile(BarqIcons.globe),
                onTap: () => context.push(Routes.accountEdit),
              ),
              if (support != null)
                BarqListTile(
                  title: l10n.accountHelp,
                  leading: const BarqIconTile(BarqIcons.help),
                  onTap: () => _callSupport(context, support),
                ),
              BarqListTile(
                title: l10n.accountLogout,
                leading: state.loggingOut
                    ? const SizedBox.square(
                        dimension: BarqSizes.iconTile,
                        child: BarqLoadingView(),
                      )
                    : const BarqIconTile(
                        BarqIcons.logout,
                        tone: BarqTileTone.neutral,
                      ),
                showChevron: false,
                showDivider: false,
                onTap: state.loggingOut ? null : () => _confirmLogout(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
