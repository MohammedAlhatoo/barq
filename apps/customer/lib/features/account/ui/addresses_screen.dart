import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_models.dart';
import '../state/addresses_cubit.dart';
import 'widgets/address_label.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DesignOverlay(
      image: 'design/06_account_04.png',
      child: BarqScreen(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BarqHeader(title: l10n.addressesTitle, back: true),
            Expanded(
              child: BlocBuilder<AddressesCubit, AddressesState>(
                builder: (context, state) {
                  final error = state.error;
                  if (state.loading) {
                    return const BarqSkeletonPage(
                      padding: EdgeInsets.fromLTRB(
                        BarqSpacing.page,
                        18,
                        BarqSpacing.page,
                        0,
                      ),
                      children: [
                        BarqSkeletonList(
                          item: BarqAddressCardSkeleton(),
                          count: 3,
                          gap: BarqSpacing.gap,
                        ),
                        BarqButtonSkeleton(),
                      ],
                    );
                  }
                  if (error != null) {
                    return BarqMessageView(
                      title: error,
                      icon: BarqIcons.alert,
                      actionLabel: l10n.commonRetry,
                      onAction: context.read<AddressesCubit>().load,
                    );
                  }
                  if (state.addresses.isEmpty) {
                    return BarqMessageView(
                      title: l10n.addressesEmpty,
                      message: l10n.addressesEmptyBody,
                      icon: BarqIcons.pin,
                      actionLabel: l10n.addressesAdd,
                      onAction: () => context.push(Routes.addressNew),
                    );
                  }
                  return _AddressList(state: state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressList extends StatelessWidget {
  const _AddressList({required this.state});

  final AddressesState state;

  Future<void> _confirmDelete(
    BuildContext context,
    SavedAddress address,
  ) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<AddressesCubit>();
    final delete = await showBarqSheet<bool>(
      context,
      children: [
        Text(l10n.addressDeleteTitle, style: BarqText.h2),
        Text(l10n.addressDeleteBody, style: BarqText.body),
        BarqButton(
          label: l10n.addressDeleteConfirm,
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
    if (delete == true) await cubit.delete(address.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final deleteError = state.deleteError;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        BarqSpacing.page,
        18,
        BarqSpacing.page,
        BarqSpacing.formBottom,
      ),
      children: [
        BarqGap(
          children: [
            if (deleteError != null)
              BarqNote(
                deleteError,
                icon: BarqIcons.alert,
                tone: BarqNoteTone.danger,
              ),
            for (final (index, address) in state.addresses.indexed)
              BarqStaggerItem(
                group: 'addresses',
                index: index,
                child: BarqAddressCard(
                  icon: addressIcon(l10n, address),
                  title: addressTitle(l10n, address),
                  subtitle: address.details,
                  badge: address.isDefault ? l10n.addressesDefault : null,
                  selected: address.isDefault,
                  onEdit: () =>
                      context.push(Routes.addressEdit, extra: address),
                  onDelete: () => _confirmDelete(context, address),
                ),
              ),
            BarqButton(
              label: l10n.addressesAdd,
              icon: BarqIcons.plus,
              variant: BarqButtonVariant.outlineDashed,
              onPressed: () => context.push(Routes.addressNew),
            ),
          ],
        ),
      ],
    );
  }
}
