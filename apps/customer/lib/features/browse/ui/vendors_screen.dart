import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/browse_models.dart';
import '../state/vendors_cubit.dart';
import 'widgets/load_more_listener.dart';
import 'widgets/vendor_meta.dart';

/// "كل المتاجر". No design exists for it, so there is no DesignOverlay: it
/// follows the other lists.
class VendorsScreen extends StatelessWidget {
  const VendorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<VendorsCubit>();
    return BarqScreen(
      body: BlocBuilder<VendorsCubit, VendorsState>(
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BarqHeader(title: l10n.vendorsTitle, back: true),
            Padding(
              padding: const EdgeInsets.only(top: BarqSpacing.xs),
              child: BarqChipsRow(
                children: [
                  BarqChip(
                    label: l10n.homeAll,
                    selected: !state.openOnly,
                    onTap: () => cubit.select(openOnly: false),
                  ),
                  BarqChip(
                    label: l10n.vendorsOpenNow,
                    selected: state.openOnly,
                    onTap: () => cubit.select(openOnly: true),
                  ),
                ],
              ),
            ),
            Expanded(child: _VendorsBody(state: state)),
          ],
        ),
      ),
    );
  }
}

class _VendorsBody extends StatelessWidget {
  const _VendorsBody({required this.state});

  final VendorsState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<VendorsCubit>();
    final error = state.error;
    if (state.loading) return const BarqLoadingView();
    if (error != null) {
      return BarqMessageView(
        title: error,
        icon: BarqIcons.alert,
        actionLabel: l10n.commonRetry,
        onAction: cubit.load,
      );
    }
    if (state.items.isEmpty) {
      return BarqMessageView(title: l10n.vendorsEmpty, icon: BarqIcons.store);
    }
    final hasFooter = state.loadingMore || state.moreFailed;
    return LoadMoreListener(
      onLoadMore: cubit.loadMore,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          BarqSpacing.page,
          BarqSpacing.sm,
          BarqSpacing.page,
          BarqSpacing.formBottom,
        ),
        itemCount: state.items.length + (hasFooter ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: BarqSpacing.md),
        itemBuilder: (_, index) {
          if (index < state.items.length) {
            return _VendorRow(vendor: state.items[index]);
          }
          return state.loadingMore
              ? const BarqLoadingView()
              : BarqMessageView(
                  title: l10n.commonRetry,
                  icon: BarqIcons.refresh,
                  actionLabel: l10n.commonRetry,
                  onAction: cubit.loadMore,
                );
        },
      ),
    );
  }
}

class _VendorRow extends StatelessWidget {
  const _VendorRow({required this.vendor});

  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final category = vendor.category;
    return BarqVendorRow(
      logo: VendorLogo(url: vendor.logoUrl),
      name: vendor.name,
      subtitle: category == null ? null : vendorCategory(l10n, category),
      meta: vendorMeta(l10n, vendor),
      trailing: BarqPill(
        vendor.isOpen ? l10n.vendorOpen : l10n.vendorClosed,
        tone: vendor.isOpen ? BarqPillTone.success : BarqPillTone.danger,
      ),
      onTap: () => context.push(Routes.vendorOf(vendor.id)),
    );
  }
}
