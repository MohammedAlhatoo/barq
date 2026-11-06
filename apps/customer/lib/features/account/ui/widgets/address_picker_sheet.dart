import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../app/router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/data/auth_models.dart';
import '../../state/addresses_cubit.dart';
import 'address_label.dart';

/// Picks a delivery address from anywhere: the compare and checkout screens
/// use it.
class AddressPickerSheet extends StatelessWidget {
  const AddressPickerSheet({super.key, this.selectedId});

  /// The address marked as chosen. Null marks the default one.
  final int? selectedId;

  /// The chosen address, or a new one the user just added. Null means nothing
  /// was chosen.
  static Future<SavedAddress?> show(
    BuildContext context, {
    int? selectedId,
  }) async {
    final repository = context.read<AppDependencies>().accountRepository;
    final choice = await showBarqSheet<_Choice>(
      context,
      children: [
        // The sheet opens on the root navigator, above this screen's providers.
        BlocProvider(
          create: (_) => AddressesCubit(repository)..load(),
          child: AddressPickerSheet(selectedId: selectedId),
        ),
      ],
    );
    if (choice == null) return null;
    if (!choice.addNew) return choice.address;
    if (!context.mounted) return null;
    return context.push<SavedAddress>(Routes.addressNew);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<AddressesCubit, AddressesState>(
      builder: (context, state) {
        final error = state.error;
        return BarqGap(
          children: [
            Text(l10n.addressPickerTitle, style: BarqText.h2),
            if (state.loading)
              const BarqSkeleton(
                child: BarqSkeletonList(
                  item: BarqAddressCardSkeleton(radio: true),
                  count: 2,
                  gap: BarqSpacing.gap,
                ),
              )
            else if (error != null)
              BarqMessageView(
                title: error,
                icon: BarqIcons.alert,
                actionLabel: l10n.commonRetry,
                onAction: context.read<AddressesCubit>().load,
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: BarqSizes.addressPickerList,
                ),
                child: SingleChildScrollView(
                  child: BarqGap(
                    children: [
                      for (final (index, address) in state.addresses.indexed)
                        BarqStaggerItem(
                          group: 'address-picker',
                          index: index,
                          child: _Row(
                            address: address,
                            selected: selectedId == null
                                ? address.isDefault
                                : address.id == selectedId,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            BarqButton(
              label: l10n.addressesAdd,
              icon: BarqIcons.plus,
              variant: BarqButtonVariant.outlineDashed,
              onPressed: () =>
                  closeBarqSheet(context, const _Choice(addNew: true)),
            ),
          ],
        );
      },
    );
  }
}

class _Choice {
  const _Choice({this.address, this.addNew = false});

  final SavedAddress? address;
  final bool addNew;
}

class _Row extends StatelessWidget {
  const _Row({required this.address, required this.selected});

  final SavedAddress address;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BarqAddressCard(
      icon: addressIcon(l10n, address),
      title: addressTitle(l10n, address),
      subtitle: address.details,
      selected: selected,
      trailing: BarqRadio(selected: selected),
      onTap: () => closeBarqSheet(context, _Choice(address: address)),
    );
  }
}
