import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../cart/state/shop_scope_cubit.dart';
import '../data/browse_models.dart';
import '../state/search_cubit.dart';
import 'widgets/load_more_listener.dart';
import 'widgets/product_row_card.dart';
import 'widgets/shop_scope_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _useRecent(String word) {
    _controller.text = word;
    context.read<SearchCubit>().search(word);
  }

  void _clear() {
    _controller.clear();
    context.read<SearchCubit>().changed('');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<SearchCubit>();
    return DesignOverlay(
      image: 'design/02_browse_03.png',
      child: BarqScreen(
        body: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BarqHeader(
                large: true,
                titleWidget: Row(
                  children: [
                    BarqIconButton(
                      icon: BarqIcons.back,
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: BarqSpacing.md),
                    Expanded(
                      child: BarqSearchBar(
                        hint: l10n.searchHint,
                        controller: _controller,
                        active: true,
                        autofocus: true,
                        onChanged: cubit.changed,
                        onSubmitted: (text) {
                          cubit.search(text.trim());
                          cubit.remember(text);
                        },
                        onClear: _clear,
                      ),
                    ),
                  ],
                ),
                bottom: state.recent.isEmpty
                    ? null
                    : _RecentSearches(words: state.recent, onTap: _useRecent),
              ),
              const ShopScopeBar(),
              Expanded(child: _Results(state: state)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  const _RecentSearches({required this.words, required this.onTap});

  final List<String> words;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: BarqSpacing.sm,
    runSpacing: BarqSpacing.sm,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Text(AppLocalizations.of(context).searchRecent, style: BarqText.xs),
      for (final word in words)
        GestureDetector(
          onTap: () => onTap(word),
          child: BarqPill(word, tone: BarqPillTone.white),
        ),
    ],
  );
}

class _Results extends StatelessWidget {
  const _Results({required this.state});

  final SearchState state;

  String? _subtitle(AppLocalizations l10n, Product product) {
    final vendor = state.vendors[product.vendorId];
    if (vendor == null) return null;
    return _storeLine(l10n, vendor);
  }

  String _storeLine(AppLocalizations l10n, Vendor vendor) {
    final km = vendor.distanceKm;
    if (km == null) return vendor.name;
    return '${vendor.name} · ${l10n.distanceKm(km.toStringAsFixed(1))}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<SearchCubit>();
    final error = state.error;
    if (state.query.isEmpty) return const SizedBox.shrink();
    if (state.loading) return const BarqLoadingView();
    if (error != null && state.items.isEmpty) {
      return BarqMessageView(
        title: error,
        icon: BarqIcons.alert,
        actionLabel: l10n.commonRetry,
        onAction: () => cubit.search(state.query),
      );
    }
    // A store match is off topic while the list is limited to one store.
    final scoped = context.select<ShopScopeCubit, bool>(
      (scope) => scope.state.filterVendorId != null,
    );
    final vendors = scoped ? const <Vendor>[] : state.matchingVendors;
    if (state.items.isEmpty && vendors.isEmpty) {
      return BarqMessageView(
        title: l10n.searchNoResults,
        message: l10n.searchNoResultsBody,
        icon: BarqIcons.search,
      );
    }
    return LoadMoreListener(
      onLoadMore: cubit.loadMore,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          BarqSpacing.page,
          BarqSpacing.section,
          BarqSpacing.page,
          BarqSpacing.formBottom,
        ),
        children: [
          BarqGap(
            gap: BarqSpacing.md,
            children: [
              Text(l10n.searchCount(state.total), style: BarqText.xs),
              for (final (index, vendor) in vendors.indexed)
                BarqStaggerItem(
                  group: 'search-vendors-${state.query}',
                  index: index,
                  child: BarqProductRow(
                    thumb: const BarqIconTile(
                      BarqIcons.store,
                      tone: BarqTileTone.neutral,
                    ),
                    title: vendor.name,
                    subtitle: vendor.isOpen
                        ? l10n.vendorOpen
                        : l10n.vendorClosed,
                    onTap: () => context.push(Routes.vendorOf(vendor.id)),
                  ),
                ),
              for (final (index, product) in state.items.indexed)
                BarqStaggerItem(
                  group: 'search-products-${state.query}',
                  index: index,
                  child: ProductRowCard(
                    product: product,
                    subtitle: _subtitle(l10n, product),
                  ),
                ),
              if (state.loadingMore) const BarqLoadingView(),
            ],
          ),
        ],
      ),
    );
  }
}
