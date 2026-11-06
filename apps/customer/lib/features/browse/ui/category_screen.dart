import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/browse_models.dart';
import '../state/products_cubit.dart';
import 'widgets/category_chips.dart';
import 'widgets/load_more_listener.dart';
import 'widgets/product_grid.dart';
import 'widgets/shop_scope_bar.dart';

/// The categories tab. Also opens on one category from the home chips, and
/// then has a back button.
class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key, this.fromHome = false});

  final bool fromHome;

  String _title(AppLocalizations l10n, ProductsState state) {
    for (final Category category in state.categories) {
      if (category.id == state.selectedCategory) return category.name;
    }
    return l10n.navCategories;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ProductsCubit>();
    return DesignOverlay(
      image: 'design/02_browse_02.png',
      child: BarqScreen(
        body: BlocBuilder<ProductsCubit, ProductsState>(
          builder: (context, state) {
            final error = state.error;
            return LoadMoreListener(
              onLoadMore: cubit.loadMore,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: BarqHeader(
                      title: _title(l10n, state),
                      back: fromHome,
                      onBack: fromHome ? () => context.go(Routes.home) : null,
                      trailing: BarqIconButton(
                        icon: BarqIcons.search,
                        onPressed: () => context.push(Routes.search),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: ShopScopeBar()),
                  SliverPadding(
                    padding: const EdgeInsets.only(
                      top: BarqSpacing.xs,
                      bottom: BarqSpacing.sm,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: CategoryChips(
                        categories: state.categories,
                        selected: state.selectedCategory,
                        onSelected: cubit.select,
                      ),
                    ),
                  ),
                  if (state.loading)
                    const BarqProductGridSkeleton()
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
                    ProductGrid(products: state.items),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: BarqSpacing.navClearance,
                      ),
                      child: state.loadingMore
                          ? const BarqProductPairSkeleton()
                          : state.moreFailed
                          ? BarqMessageView(
                              title: l10n.commonRetry,
                              icon: BarqIcons.refresh,
                              actionLabel: l10n.commonRetry,
                              onAction: cubit.loadMore,
                            )
                          : null,
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
