import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/browse_models.dart';
import '../state/home_cubit.dart';
import 'widgets/category_chips.dart';
import 'widgets/product_card.dart';
import 'widgets/product_grid.dart';
import 'widgets/shop_scope_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// How many products the carousel shows before the grid starts.
  static const _featuredCount = 3;

  @override
  Widget build(BuildContext context) {
    return DesignOverlay(
      image: 'design/02_browse_01.png',
      child: BarqScreen(
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            final l10n = AppLocalizations.of(context);
            final error = state.error;
            final Widget? message = state.loading
                ? const BarqLoadingView()
                : error != null
                ? BarqMessageView(
                    title: error,
                    icon: BarqIcons.alert,
                    actionLabel: l10n.commonRetry,
                    onAction: context.read<HomeCubit>().load,
                  )
                : state.products.isEmpty
                ? BarqMessageView(title: l10n.browseEmpty)
                : null;
            final featured = state.products.take(_featuredCount).toList();
            final rest = state.products.skip(_featuredCount).toList();
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _HomeHeader(name: state.name)),
                const SliverToBoxAdapter(child: ShopScopeBar()),
                if (message != null)
                  SliverFillRemaining(hasScrollBody: false, child: message)
                else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: BarqSpacing.sm),
                      child: CategoryChips(
                        categories: state.categories,
                        selected: null,
                        onSelected: (id) => context.go(
                          id == null
                              ? Routes.categories
                              : Routes.categoryOf(id),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: _Featured(products: featured)),
                  if (state.vendors.isNotEmpty)
                    SliverToBoxAdapter(child: _Vendors(vendors: state.vendors)),
                  if (rest.isNotEmpty) ...[
                    SliverPadding(
                      padding: const EdgeInsets.only(
                        top: BarqSpacing.section,
                        bottom: BarqSpacing.gap,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: BarqSectionHeader(
                          l10n.homeBestSellers,
                          action: l10n.homeSeeAll,
                          onAction: () => context.go(Routes.categories),
                        ),
                      ),
                    ),
                    ProductGrid(products: rest),
                  ],
                  const SliverPadding(
                    padding: EdgeInsets.only(bottom: BarqSpacing.navClearance),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fullName = name?.trim() ?? '';
    final greeting = DateTime.now().hour < 12
        ? l10n.homeMorning
        : l10n.homeEvening;
    return BarqHeader(
      large: true,
      titleWidget: Row(
        children: [
          BarqAvatar(
            fullName.isEmpty ? '' : fullName.characters.first,
            border: 3,
          ),
          const SizedBox(width: BarqSpacing.md),
          Expanded(
            child: BarqGap(
              gap: 0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: BarqText.xs),
                Text(
                  fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: BarqText.h3,
                ),
              ],
            ),
          ),
        ],
      ),
      // Opens the notifications screen in phase 6.
      trailing: const BarqIconButton(icon: BarqIcons.bell),
      bottom: Row(
        children: [
          Expanded(
            child: BarqSearchBar(
              hint: l10n.searchHint,
              onTap: () => context.push(Routes.search),
            ),
          ),
          const SizedBox(width: BarqSpacing.md),
          BarqIconButton(
            icon: BarqIcons.sliders,
            size: BarqSizes.search,
            onPressed: () => context.push(Routes.search),
          ),
        ],
      ),
    );
  }
}

/// Not in the design: the way from home to a store. Kept in the order the
/// server sent, which is open first, then nearest.
class _Vendors extends StatelessWidget {
  const _Vendors({required this.vendors});

  final List<Vendor> vendors;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final located = vendors.any((vendor) => vendor.distanceKm != null);
    return Padding(
      padding: const EdgeInsets.only(top: BarqSpacing.section),
      child: BarqGap(
        gap: BarqSpacing.xs,
        children: [
          BarqSectionHeader(located ? l10n.homeNearStores : l10n.homeStores),
          BarqChipsRow(
            children: [
              for (final vendor in vendors) _VendorCard(vendor: vendor),
            ],
          ),
        ],
      ),
    );
  }
}

class _VendorCard extends StatelessWidget {
  const _VendorCard({required this.vendor});

  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final km = vendor.distanceKm;
    return SizedBox(
      width: BarqSizes.homeVendorCard,
      child: BarqCard(
        padding: const EdgeInsets.all(BarqSpacing.gap),
        onTap: () => context.push(Routes.vendorOf(vendor.id)),
        child: BarqGap(
          gap: BarqSpacing.xxs,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vendor.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: BarqText.h3,
            ),
            Text(
              km != null
                  ? l10n.distanceKm(km.toStringAsFixed(1))
                  : vendor.isOpen
                  ? l10n.vendorOpen
                  : l10n.vendorClosed,
              style: BarqText.xs,
            ),
          ],
        ),
      ),
    );
  }
}

class _Featured extends StatefulWidget {
  const _Featured({required this.products});

  final List<Product> products;

  @override
  State<_Featured> createState() => _FeaturedState();
}

class _FeaturedState extends State<_Featured> {
  final _controller = PageController(
    viewportFraction: BarqSizes.featuredViewport,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deal = AppLocalizations.of(context).homeDeal;
    return Padding(
      padding: const EdgeInsets.only(top: BarqSpacing.sm),
      child: SizedBox(
        height: BarqSizes.featuredTile,
        child: PageView.builder(
          controller: _controller,
          itemCount: widget.products.length,
          itemBuilder: (_, index) {
            final product = widget.products[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: BarqSpacing.xs),
              child: ProductCard(
                product: product,
                large: true,
                topBadge: product.compareAtPrice == null ? null : deal,
              ),
            );
          },
        ),
      ),
    );
  }
}
