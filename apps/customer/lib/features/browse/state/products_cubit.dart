import 'dart:async';

import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cart/state/shop_scope_cubit.dart';
import '../data/browse_models.dart';
import '../data/browse_repository.dart';

class ProductsState {
  const ProductsState({
    this.loading = true,
    this.categories = const [],
    this.selectedCategory,
    this.items = const [],
    this.nextPage,
    this.loadingMore = false,
    this.moreFailed = false,
    this.error,
  });

  final bool loading;
  final List<Category> categories;

  /// Null is the "all" chip.
  final int? selectedCategory;
  final List<Product> items;
  final int? nextPage;
  final bool loadingMore;
  final bool moreFailed;
  final String? error;

  ProductsState copyWith({
    bool? loading,
    List<Category>? categories,
    List<Product>? items,
    int? nextPage,
    bool? loadingMore,
    bool? moreFailed,
  }) => ProductsState(
    loading: loading ?? this.loading,
    categories: categories ?? this.categories,
    selectedCategory: selectedCategory,
    items: items ?? this.items,
    nextPage: nextPage,
    loadingMore: loadingMore ?? this.loadingMore,
    moreFailed: moreFailed ?? this.moreFailed,
  );
}

/// A filtered product list with paging: the category tab and the store page.
class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(
    this._repository, {
    int? categoryId,
    this.vendorId,
    ShopScopeCubit? scope,
  }) : _scopeVendorId = scope?.state.filterVendorId,
       super(ProductsState(selectedCategory: categoryId)) {
    _scope = scope?.stream
        .map((s) => s.filterVendorId)
        .distinct()
        .listen(_scopeTo);
  }

  final BrowseRepository _repository;

  /// The store page's own store. Never changes.
  final int? vendorId;
  StreamSubscription<int?>? _scope;

  /// The cart's store on the categories tab, or null for every store.
  int? _scopeVendorId;

  /// Answers of an older chip are ignored.
  int _request = 0;

  /// A request can end after the user left the screen.
  @override
  void emit(ProductsState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> load() async {
    final selected = state.selectedCategory;
    final request = ++_request;
    emit(ProductsState(selectedCategory: selected));
    try {
      final categories = await _repository.categories(vendorId: vendorId);
      final page = await _page(selected, 1);
      if (request != _request) return;
      emit(
        ProductsState(
          loading: false,
          categories: categories,
          selectedCategory: selected,
          items: page.items,
          nextPage: page.nextPage,
        ),
      );
    } on ApiException catch (e) {
      if (request != _request) return;
      emit(
        ProductsState(
          loading: false,
          selectedCategory: selected,
          error: e.messageAr,
        ),
      );
    }
  }

  /// Swaps the products without a spinner: this runs right after a tap on "+".
  Future<void> _scopeTo(int? vendorId) async {
    _scopeVendorId = vendorId;
    if (state.loading || state.error != null) return load();
    final categories = state.categories;
    final selected = state.selectedCategory;
    final request = ++_request;
    try {
      final page = await _page(selected, 1);
      if (request != _request) return;
      emit(
        ProductsState(
          loading: false,
          categories: categories,
          selectedCategory: selected,
          items: page.items,
          nextPage: page.nextPage,
        ),
      );
    } on ApiException catch (e) {
      if (request != _request) return;
      emit(
        ProductsState(
          loading: false,
          categories: categories,
          selectedCategory: selected,
          error: e.messageAr,
        ),
      );
    }
  }

  Future<void> select(int? categoryId) async {
    if (categoryId == state.selectedCategory) return;
    final categories = state.categories;
    final request = ++_request;
    emit(ProductsState(categories: categories, selectedCategory: categoryId));
    try {
      final page = await _page(categoryId, 1);
      if (request != _request) return;
      emit(
        ProductsState(
          loading: false,
          categories: categories,
          selectedCategory: categoryId,
          items: page.items,
          nextPage: page.nextPage,
        ),
      );
    } on ApiException catch (e) {
      if (request != _request) return;
      emit(
        ProductsState(
          loading: false,
          categories: categories,
          selectedCategory: categoryId,
          error: e.messageAr,
        ),
      );
    }
  }

  Future<void> loadMore() async {
    final next = state.nextPage;
    if (next == null || state.loadingMore || state.loading) return;
    final request = _request;
    emit(state.copyWith(nextPage: next, loadingMore: true, moreFailed: false));
    try {
      final page = await _page(state.selectedCategory, next);
      if (request != _request) return;
      emit(
        state.copyWith(
          items: [...state.items, ...page.items],
          nextPage: page.nextPage,
          loadingMore: false,
        ),
      );
    } on ApiException {
      if (request != _request) return;
      emit(
        state.copyWith(nextPage: next, loadingMore: false, moreFailed: true),
      );
    }
  }

  Future<Paged<Product>> _page(int? categoryId, int page) =>
      _repository.products(
        categoryId: categoryId,
        vendorId: vendorId ?? _scopeVendorId,
        page: page,
      );

  @override
  Future<void> close() {
    _scope?.cancel();
    return super.close();
  }
}
