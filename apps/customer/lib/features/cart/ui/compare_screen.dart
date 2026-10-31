import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../account/ui/widgets/address_picker_sheet.dart';
import '../data/cart_models.dart';
import '../state/cart_cubit.dart';
import '../state/compare_cubit.dart';
import 'widgets/current_cart_row.dart';
import 'widgets/no_full_store_view.dart';
import 'widgets/out_of_zone_view.dart';

/// Every result of `POST /baskets/compare`: the stores, no store with the whole
/// cart, out of zone, no address, or a failure.
class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  /// The comparison uses the default address, so the chosen one becomes it.
  /// If the server refuses, the reload shows out of zone again.
  Future<void> _changeAddress(BuildContext context) async {
    final cubit = context.read<CompareCubit>();
    final account = context.read<AppDependencies>().accountRepository;
    final address = await AddressPickerSheet.show(context);
    if (address == null) return;
    try {
      if (!address.isDefault) await account.makeDefault(address);
    } on ApiException catch (e) {
      debugPrint('Address not made default: ${e.code}');
    }
    cubit.useDefaultAddress();
    await cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompareCubit, CompareState>(
      builder: (context, state) {
        final comparison = state.comparison;
        return switch (state.status) {
          CompareStatus.outOfZone => OutOfZoneView(
            code: state.errorCode,
            onChangeAddress: () => _changeAddress(context),
          ),
          CompareStatus.ready
              when comparison != null &&
                  comparison.stores.isNotEmpty &&
                  comparison.cheapestVendorId == null =>
            NoFullStoreView(comparison: comparison, state: state),
          CompareStatus.ready
              when comparison != null &&
                  (comparison.stores.isNotEmpty || state.cartTotal != null) =>
            _StoresView(comparison: comparison, state: state),
          _ => _MessageScreen(state: state),
        };
      },
    );
  }
}

class _MessageScreen extends StatelessWidget {
  const _MessageScreen({required this.state});

  final CompareState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final Widget body = switch (state.status) {
      CompareStatus.loading => const BarqLoadingView(),
      CompareStatus.noAddress => BarqMessageView(
        title: l10n.noAddressTitle,
        message: l10n.noAddressBody,
        icon: BarqIcons.pin,
        actionLabel: l10n.noAddressAdd,
        onAction: () async {
          final cubit = context.read<CompareCubit>();
          await context.push(Routes.addressNew);
          await cubit.load();
        },
      ),
      CompareStatus.ready => BarqMessageView(
        title: l10n.noStoresTitle,
        icon: BarqIcons.store,
      ),
      _ => BarqMessageView(
        title: state.error ?? '',
        icon: BarqIcons.alert,
        actionLabel: l10n.commonRetry,
        onAction: context.read<CompareCubit>().load,
      ),
    };
    return DesignOverlay(
      image: 'design/03_checkout_02.png',
      child: BarqScreen(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BarqHeader(title: l10n.compareTitle, back: true),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _StoresView extends StatelessWidget {
  const _StoresView({required this.comparison, required this.state});

  final BasketComparison comparison;
  final CompareState state;

  /// The server's total, or the items price when there is no quote.
  String _shown(CompareState state, BasketStore store) =>
      (state.totals[store.vendorId] ?? store.itemsTotal).formatted;

  void _choose(BuildContext context, BasketStore store) {
    context.read<CartCubit>().switchStore(store);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<CompareCubit>();
    final best = comparison.storeOf(state.bestVendorId);
    final others = state.ranked.where((s) => s != best).toList();
    final bestTotal = best == null ? null : state.totals[best.vendorId];
    final cartTotal = state.cartTotal;
    final config = ConfigScope.of(context).config;
    final saved = bestTotal == null || cartTotal == null
        ? null
        : bestTotal.savedAgainst(
            cartTotal,
            symbol: config.currencySymbol,
            minorUnits: config.currencyMinorUnits,
          );
    final selected = state.selected;
    final count = context.read<CartCubit>().state.count;
    return DesignOverlay(
      image: 'design/03_checkout_02.png',
      child: BarqScreen(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  BarqHeader(
                    title: l10n.compareTitle,
                    back: true,
                    bottom: BarqGap(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BarqPill(
                          l10n.compareZone(comparison.zoneName),
                          tone: BarqPillTone.success,
                          icon: BarqIcons.pin,
                        ),
                        Text(l10n.compareBody(count), style: BarqText.t),
                      ],
                    ),
                  ),
                  BarqGap(
                    padding: const EdgeInsets.fromLTRB(
                      BarqSpacing.page,
                      BarqSpacing.section,
                      BarqSpacing.page,
                      BarqSpacing.section,
                    ),
                    children: [
                      CurrentCartRow(
                        name: state.cartVendorName,
                        total: cartTotal,
                        selected: state.selectedVendorId == state.cartVendorId,
                        isCheapest: state.cartIsCheapest,
                        onTap: () => cubit.select(state.cartVendorId!),
                      ),
                      if (best != null)
                        _BestCard(
                          store: best,
                          total: bestTotal,
                          saved: saved,
                          onTap: () => cubit.select(best.vendorId),
                        ),
                      if (others.isNotEmpty)
                        Text(l10n.compareOthers, style: BarqText.h3),
                      for (final store in others)
                        _StoreRow(
                          store: store,
                          total: state.totals[store.vendorId],
                          selected: selected == store,
                          onTap: () => cubit.select(store.vendorId),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            BarqGap(
              gap: BarqSpacing.md,
              padding: const EdgeInsets.fromLTRB(
                BarqSpacing.page,
                0,
                BarqSpacing.page,
                BarqSpacing.stateBottom,
              ),
              children: [
                if (selected == null)
                  BarqButton(
                    label: l10n.compareKeepCart,
                    onPressed: () => context.pop(),
                  )
                else
                  BarqButton(
                    label: selected == best
                        ? l10n.comparePickBest(_shown(state, selected))
                        : l10n.comparePick(
                            selected.vendorName,
                            _shown(state, selected),
                          ),
                    variant: selected == best
                        ? BarqButtonVariant.green
                        : BarqButtonVariant.primary,
                    onPressed: () => _choose(context, selected),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BestCard extends StatelessWidget {
  const _BestCard({
    required this.store,
    required this.total,
    required this.saved,
    required this.onTap,
  });

  final BasketStore store;
  final Money? total;

  /// Against the cart. Null if the cart has no total.
  final Money? saved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final amount = saved;
    return BarqCard(
      padding: EdgeInsets.zero,
      clip: true,
      borderColor: BarqColors.success,
      borderWidth: 2,
      shadow: BarqShadows.greenCard,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BarqTileBackground(
            tile: BarqTileColor.mint,
            radius: 0,
            padding: const EdgeInsets.all(BarqSpacing.section),
            child: Row(
              children: [
                const BarqIllustration(
                  BarqIllustrations.basket,
                  width: BarqSizes.compareBasket,
                  height: BarqSizes.compareBasket,
                ),
                const SizedBox(width: BarqSpacing.gap),
                Expanded(
                  child: BarqGap(
                    gap: BarqSpacing.xs,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BarqPill(
                        l10n.compareBest,
                        tone: BarqPillTone.successSolid,
                      ),
                      Text(store.vendorName, style: BarqText.h2),
                    ],
                  ),
                ),
                BarqGap(
                  gap: 0,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      (total ?? store.itemsTotal).formatted,
                      style: BarqText.h1.copyWith(
                        color: BarqColors.successText,
                      ),
                    ),
                    Text(
                      total == null
                          ? l10n.compareDeliveryLater
                          : l10n.compareWithDelivery,
                      style: BarqText.xs,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(BarqSpacing.gap),
            child: BarqGap(
              gap: BarqSpacing.xs,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BarqMetaRow(
                  items: [
                    (
                      icon: BarqIcons.check,
                      text: l10n.compareAvailable(
                        store.availableCount,
                        store.lines.length,
                      ),
                      iconColor: BarqColors.successText,
                    ),
                  ],
                ),
                if (amount != null)
                  Text(
                    l10n.compareSave(amount.formatted),
                    style: BarqText.tBold.copyWith(
                      color: BarqColors.successText,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreRow extends StatelessWidget {
  const _StoreRow({
    required this.store,
    required this.total,
    required this.selected,
    required this.onTap,
  });

  final BasketStore store;
  final Money? total;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BarqCard(
      padding: const EdgeInsets.all(BarqSpacing.gap),
      borderColor: selected ? BarqColors.primary : null,
      borderWidth: 2,
      onTap: onTap,
      child: Row(
        children: [
          const BarqIconTile(BarqIcons.store, tone: BarqTileTone.neutral),
          const SizedBox(width: BarqSpacing.gap),
          Expanded(
            child: BarqGap(
              gap: BarqSpacing.xxs,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(store.vendorName, style: BarqText.h3),
                Text(
                  l10n.compareAvailable(
                    store.availableCount,
                    store.lines.length,
                  ),
                  style: BarqText.xs,
                ),
              ],
            ),
          ),
          const SizedBox(width: BarqSpacing.sm),
          BarqGap(
            gap: 0,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text((total ?? store.itemsTotal).formatted, style: BarqText.h3),
              Text(
                total == null
                    ? l10n.compareDeliveryLater
                    : l10n.compareWithDelivery,
                style: BarqText.xs,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
