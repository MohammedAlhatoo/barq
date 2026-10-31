import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../data/cart_models.dart';
import '../../state/cart_cubit.dart';
import '../../state/compare_cubit.dart';
import 'missing_pill.dart';

/// No store has the whole cart: pick one to continue with what it has.
class NoFullStoreView extends StatelessWidget {
  const NoFullStoreView({
    super.key,
    required this.comparison,
    required this.state,
  });

  final BasketComparison comparison;
  final CompareState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = state.selected;
    return DesignOverlay(
      image: 'design/03_checkout_03.png',
      child: BarqScreen(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  BarqHeader(title: l10n.compareTitle, back: true),
                  BarqBasketArt(label: l10n.noStoreBadge),
                  BarqGap(
                    gap: BarqSpacing.xs,
                    padding: const EdgeInsets.symmetric(
                      horizontal: BarqSpacing.page,
                    ),
                    children: [
                      Text(
                        l10n.noStoreTitle,
                        textAlign: TextAlign.center,
                        style: BarqText.h1,
                      ),
                      Text(
                        l10n.noStoreBody(comparison.zoneName),
                        textAlign: TextAlign.center,
                        style: BarqText.t,
                      ),
                    ],
                  ),
                  BarqGap(
                    gap: BarqSpacing.md,
                    padding: const EdgeInsets.all(BarqSpacing.page),
                    children: [
                      for (final store in comparison.stores)
                        _StoreCard(store: store, selected: store == selected),
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
                if (selected != null)
                  BarqButton(
                    label: l10n.noStoreContinue(selected.vendorName),
                    onPressed: () {
                      context.read<CartCubit>().switchStore(selected);
                      context.pop();
                    },
                  ),
                BarqButton(
                  label: l10n.noStoreEdit,
                  variant: BarqButtonVariant.white,
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({required this.store, required this.selected});

  final BasketStore store;
  final bool selected;

  @override
  Widget build(BuildContext context) => BarqCard(
    padding: const EdgeInsets.all(BarqSpacing.gap),
    borderColor: selected ? BarqColors.primary : null,
    borderWidth: 2,
    onTap: () => context.read<CompareCubit>().select(store.vendorId),
    child: Row(
      children: [
        const BarqIllustration(
          BarqIllustrations.storefront,
          width: BarqSizes.storeLogo,
          height: BarqSizes.storeLogo,
        ),
        const SizedBox(width: BarqSpacing.gap),
        Expanded(
          child: BarqGap(
            gap: BarqSpacing.xxs,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(store.vendorName, style: BarqText.h3),
              MissingPill(
                store: store,
                tone: selected ? BarqPillTone.orange : BarqPillTone.danger,
              ),
            ],
          ),
        ),
        const SizedBox(width: BarqSpacing.sm),
        Text(store.itemsTotal.formatted, style: BarqText.h3),
      ],
    ),
  );
}
