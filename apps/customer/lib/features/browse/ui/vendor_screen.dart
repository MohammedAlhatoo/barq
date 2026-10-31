import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../cart/data/cart_models.dart';
import '../../cart/state/cart_cubit.dart';
import '../data/browse_models.dart';
import '../state/products_cubit.dart';
import '../state/vendor_cubit.dart';
import 'widgets/category_chips.dart';
import 'widgets/load_more_listener.dart';
import 'widgets/product_row_card.dart';

class VendorScreen extends StatelessWidget {
  const VendorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DesignOverlay(
      image: 'design/02_browse_04.png',
      child: BlocBuilder<VendorCubit, VendorState>(
        builder: (context, state) {
          final vendor = state.vendor;
          final error = state.error;
          if (vendor != null) return _VendorView(vendor: vendor);
          return BarqScreen(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const BarqHeader(back: true),
                Expanded(
                  child: error == null
                      ? const BarqLoadingView()
                      : BarqMessageView(
                          title: error,
                          icon: BarqIcons.alert,
                          actionLabel: l10n.commonRetry,
                          onAction: context.read<VendorCubit>().load,
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _VendorView extends StatelessWidget {
  const _VendorView({required this.vendor});

  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ProductsCubit>();
    return BlocBuilder<CartCubit, Cart>(
      builder: (context, cart) => BarqScreen(
        bottomSheet: cart.isEmpty ? null : const _CartBar(),
        body: BlocBuilder<ProductsCubit, ProductsState>(
          builder: (context, state) {
            final error = state.error;
            return LoadMoreListener(
              onLoadMore: cubit.loadMore,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _VendorHero(vendor: vendor)),
                  SliverPadding(
                    padding: const EdgeInsets.only(top: BarqSpacing.sm),
                    sliver: SliverToBoxAdapter(
                      child: CategoryChips(
                        categories: state.categories,
                        selected: state.selectedCategory,
                        onSelected: cubit.select,
                      ),
                    ),
                  ),
                  if (state.loading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: BarqLoadingView(),
                    )
                  else if (error != null)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: BarqMessageView(
                        title: error,
                        icon: BarqIcons.alert,
                        actionLabel: l10n.commonRetry,
                        onAction: cubit.load,
                      ),
                    )
                  else if (state.items.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: BarqMessageView(title: l10n.browseEmpty),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        BarqSpacing.page,
                        BarqSpacing.sm,
                        BarqSpacing.page,
                        0,
                      ),
                      sliver: SliverList.separated(
                        itemCount: state.items.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: BarqSpacing.md),
                        itemBuilder: (_, index) => ProductRowCard(
                          product: state.items[index],
                          // `products_when_closed` is false: no orders then.
                          canOrder: vendor.isOpen,
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: BarqSpacing.cartBarClearance,
                      ),
                      child: state.loadingMore ? const BarqLoadingView() : null,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _VendorHero extends StatelessWidget {
  const _VendorHero({required this.vendor});

  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final average = vendor.ratingAverage;
    final km = vendor.distanceKm;
    final prep = vendor.prepMinutes;
    return Stack(
      children: [
        const Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: BarqTileBackground(
            tile: BarqTileColor.peach,
            height: BarqSizes.storeHero,
            radius: 0,
            child: BarqIllustrationArea(
              height: BarqSizes.storeHero,
              blobSize: BarqSizes.storeHeroBlob,
              child: BarqIllustration(
                BarqIllustrations.storefront,
                width: BarqSizes.storeHeroBlob,
              ),
            ),
          ),
        ),
        const BarqHeader(back: true),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            BarqSpacing.page,
            BarqSizes.storeHeroCardTop,
            BarqSpacing.page,
            0,
          ),
          child: BarqCard(
            child: BarqGap(
              gap: BarqSpacing.md,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(vendor.name, style: BarqText.h2)),
                    BarqPill(
                      vendor.isOpen ? l10n.vendorOpen : l10n.vendorClosed,
                      tone: vendor.isOpen
                          ? BarqPillTone.success
                          : BarqPillTone.danger,
                    ),
                  ],
                ),
                BarqMetaRow(
                  items: [
                    if (average != null && vendor.ratingCount > 0)
                      (
                        icon: BarqIcons.star,
                        text: '$average (${vendor.ratingCount})',
                        iconColor: BarqColors.star,
                      ),
                    if (prep != null)
                      (
                        icon: BarqIcons.clock,
                        text: l10n.vendorPrep(prep),
                        iconColor: null,
                      ),
                    if (km != null)
                      (
                        icon: BarqIcons.pin,
                        text: l10n.distanceKm(km.toStringAsFixed(1)),
                        iconColor: null,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CartBar extends StatelessWidget {
  const _CartBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final count = context.select<CartCubit, int>((cart) => cart.state.count);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        BarqSpacing.page,
        0,
        BarqSpacing.page,
        BarqSpacing.lg,
      ),
      child: BarqButton(
        label: l10n.viewCart,
        variant: BarqButtonVariant.dark,
        leading: const BarqIconTile(
          BarqIcons.bag,
          tone: BarqTileTone.darkOrange,
          size: BarqSizes.cartBarIcon,
          radius: BarqRadius.pill,
        ),
        trailing: Text(
          l10n.cartCount(count),
          style: BarqText.xs.copyWith(color: BarqColors.onDarkMuted),
        ),
        onPressed: () => context.push(Routes.cart),
      ),
    );
  }
}
