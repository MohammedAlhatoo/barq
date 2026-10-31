import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/cart_models.dart';
import '../state/cart_cubit.dart';
import '../state/compare_cubit.dart';
import 'widgets/missing_pill.dart';
import 'widgets/no_full_store_view.dart';
import 'widgets/out_of_zone_view.dart';

/// Every result of `POST /baskets/compare`: the stores, no store with the whole
/// cart, out of zone, no address, or a failure.
class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompareCubit, CompareState>(
      builder: (context, state) {
        final comparison = state.comparison;
        return switch (state.status) {
          CompareStatus.outOfZone => OutOfZoneView(code: state.errorCode),
          CompareStatus.ready
              when comparison != null &&
                  comparison.stores.isNotEmpty &&
                  comparison.cheapestVendorId == null =>
            NoFullStoreView(comparison: comparison, state: state),
          CompareStatus.ready
              when comparison != null && comparison.stores.isNotEmpty =>
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
        // The addresses screen itself comes in phase 4.
        onAction: () => context.go(Routes.account),
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

  void _choose(BuildContext context, BasketStore store) {
    context.read<CartCubit>().switchStore(store);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<CompareCubit>();
    final best = comparison.storeOf(comparison.cheapestVendorId);
    final others = comparison.stores.where((s) => s != best).toList();
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
                      if (best != null)
                        _BestCard(
                          store: best,
                          onTap: () => cubit.select(best.vendorId),
                        ),
                      if (others.isNotEmpty)
                        Text(l10n.compareOthers, style: BarqText.h3),
                      for (final store in others)
                        _StoreRow(
                          store: store,
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
                BarqNote(l10n.compareNote),
                if (selected != null)
                  BarqButton(
                    label: selected == best
                        ? l10n.comparePickBest(selected.itemsTotal.formatted)
                        : l10n.comparePick(
                            selected.vendorName,
                            selected.itemsTotal.formatted,
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
  const _BestCard({required this.store, required this.onTap});

  final BasketStore store;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                      store.itemsTotal.formatted,
                      style: BarqText.h1.copyWith(
                        color: BarqColors.successText,
                      ),
                    ),
                    Text(l10n.compareForItems, style: BarqText.xs),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(BarqSpacing.gap),
            child: BarqMetaRow(
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
          ),
        ],
      ),
    );
  }
}

class _StoreRow extends StatelessWidget {
  const _StoreRow({
    required this.store,
    required this.selected,
    required this.onTap,
  });

  final BasketStore store;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Opacity(
      opacity: store.complete ? 1 : BarqSizes.incompleteStoreOpacity,
      child: BarqCard(
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
                  if (store.complete)
                    Text(
                      l10n.compareAvailable(
                        store.availableCount,
                        store.lines.length,
                      ),
                      style: BarqText.xs,
                    )
                  else
                    MissingPill(store: store),
                ],
              ),
            ),
            const SizedBox(width: BarqSpacing.sm),
            Text(store.itemsTotal.formatted, style: BarqText.h3),
          ],
        ),
      ),
    );
  }
}
