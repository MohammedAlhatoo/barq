import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../notifications/state/unread_cubit.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/browse_models.dart';
import '../state/home_cubit.dart';
import 'widgets/category_chips.dart';
import 'widgets/product_card.dart';
import 'widgets/shop_scope_bar.dart';
import 'widgets/vendor_meta.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// The rest are one tap away, on "كل المتاجر".
  static const _vendorCount = 10;

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
                  if (ConfigScope.of(context).config
                      .hasModule('basket_compare'))
                    const SliverToBoxAdapter(child: _AssistantBanner()),
                  SliverToBoxAdapter(
                    child: _SectionTitle(
                      title: l10n.homeBestSellers,
                      onSeeAll: () => context.go(Routes.categories),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _Products(products: state.products),
                  ),
                  if (state.vendors.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: _SectionTitle(
                        title: state.vendors.any((v) => v.distanceKm != null)
                            ? l10n.homeNearStores
                            : l10n.homeStores,
                        onSeeAll: () => context.push(Routes.vendors),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _Vendors(
                        vendors: state.vendors.take(_vendorCount).toList(),
                      ),
                    ),
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
      trailing: BarqIconButton(
        icon: BarqIcons.bell,
        showDot: context.watch<UnreadCubit>().state > 0,
        onPressed: () => context.push(Routes.notifications),
      ),
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

class _AssistantBanner extends StatelessWidget {
  const _AssistantBanner();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        BarqSpacing.page,
        BarqSpacing.sm,
        BarqSpacing.page,
        0,
      ),
      child: BarqAssistantBanner(
        title: l10n.homeAssistantTitle,
        subtitle: l10n.homeAssistantBody,
        onTap: () => context.push(Routes.assistant),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.onSeeAll});

  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(
      top: BarqSpacing.section,
      bottom: BarqSpacing.gap,
    ),
    child: BarqSectionHeader(
      title,
      action: AppLocalizations.of(context).homeSeeAll,
      onAction: onSeeAll,
    ),
  );
}

class _Products extends StatelessWidget {
  const _Products({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: BarqSizes.productTile,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: BarqSpacing.page),
      itemCount: products.length,
      separatorBuilder: (_, _) => const SizedBox(width: BarqSpacing.gap),
      itemBuilder: (_, index) => SizedBox(
        width: BarqSizes.homeProductTile,
        child: ProductCard(product: products[index]),
      ),
    ),
  );
}

/// Kept in the order the server sent: open first, then nearest.
class _Vendors extends StatelessWidget {
  const _Vendors({required this.vendors});

  final List<Vendor> vendors;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: BarqSizes.homeVendorCardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: BarqSpacing.page),
        clipBehavior: Clip.none,
        itemCount: vendors.length,
        separatorBuilder: (_, _) => const SizedBox(width: BarqSpacing.gap),
        itemBuilder: (context, index) {
          final vendor = vendors[index];
          return SizedBox(
            width: BarqSizes.homeVendorCard,
            child: BarqVendorCard(
              logo: VendorLogo(url: vendor.logoUrl),
              name: vendor.name,
              meta: vendorMeta(l10n, vendor),
              onTap: () => context.push(Routes.vendorOf(vendor.id)),
            ),
          );
        },
      ),
    );
  }
}
