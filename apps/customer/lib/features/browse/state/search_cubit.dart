import 'dart:async';

import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../cart/state/shop_scope_cubit.dart';
import '../data/browse_models.dart';
import '../data/browse_repository.dart';
import '../data/user_location.dart';

class SearchState {
  const SearchState({
    this.query = '',
    this.loading = false,
    this.items = const [],
    this.total = 0,
    this.nextPage,
    this.loadingMore = false,
    this.recent = const [],
    this.vendors = const {},
    this.error,
  });

  final String query;
  final bool loading;
  final List<Product> items;
  final int total;
  final int? nextPage;
  final bool loadingMore;
  final List<String> recent;

  /// Every store by id, to name the store on each result.
  final Map<int, Vendor> vendors;
  final String? error;

  /// The API searches products only, so stores are matched here.
  List<Vendor> get matchingVendors => query.isEmpty
      ? const []
      : vendors.values.where((v) => v.name.contains(query)).toList();

  SearchState copyWith({
    String? query,
    bool? loading,
    List<Product>? items,
    int? total,
    int? nextPage,
    bool? loadingMore,
    List<String>? recent,
    Map<int, Vendor>? vendors,
    String? error,
  }) => SearchState(
    query: query ?? this.query,
    loading: loading ?? this.loading,
    items: items ?? this.items,
    total: total ?? this.total,
    nextPage: nextPage,
    loadingMore: loadingMore ?? this.loadingMore,
    recent: recent ?? this.recent,
    vendors: vendors ?? this.vendors,
    error: error,
  );
}

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(
    this._repository,
    this._prefs,
    this._location,
    ShopScopeCubit scope,
  ) : _vendorId = scope.state.filterVendorId,
      super(SearchState(recent: _prefs.getStringList(_recentKey) ?? const [])) {
    _scope = scope.stream
        .map((s) => s.filterVendorId)
        .distinct()
        .listen(_scopeTo);
  }

  static const _recentKey = 'barq_recent_searches';
  static const _recentCount = 3;
  static const _debounce = Duration(milliseconds: 400);

  final BrowseRepository _repository;
  final SharedPreferences _prefs;
  final UserLocation _location;
  Timer? _timer;
  late final StreamSubscription<int?> _scope;

  /// The cart's store, or null for every store.
  int? _vendorId;

  /// Answers of an older word are ignored.
  int _request = 0;

  Future<void> loadVendors() async {
    try {
      final location = await _location.current();
      final vendors = await _repository.vendors(
        lat: location?.lat,
        lng: location?.lng,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          nextPage: state.nextPage,
          error: state.error,
          vendors: {for (final vendor in vendors) vendor.id: vendor},
        ),
      );
    } on ApiException {
      // Results still show, only without the store name.
    }
  }

  void _scopeTo(int? vendorId) {
    _vendorId = vendorId;
    if (state.query.isNotEmpty) search(state.query);
  }

  void changed(String text) {
    _timer?.cancel();
    final query = text.trim();
    if (query.isEmpty) {
      _request++;
      emit(SearchState(recent: state.recent, vendors: state.vendors));
      return;
    }
    _timer = Timer(_debounce, () => search(query));
  }

  Future<void> search(String query) async {
    final request = ++_request;
    emit(
      SearchState(
        query: query,
        loading: true,
        recent: state.recent,
        vendors: state.vendors,
      ),
    );
    try {
      final page = await _repository.products(
        query: query,
        vendorId: _vendorId,
      );
      if (request != _request || isClosed) return;
      emit(
        state.copyWith(
          loading: false,
          items: page.items,
          total: page.total ?? page.items.length,
          nextPage: page.nextPage,
        ),
      );
    } on ApiException catch (e) {
      if (request != _request || isClosed) return;
      emit(state.copyWith(loading: false, error: e.messageAr));
    }
  }

  Future<void> loadMore() async {
    final next = state.nextPage;
    if (next == null || state.loadingMore || state.loading) return;
    final request = _request;
    emit(state.copyWith(nextPage: next, loadingMore: true));
    try {
      final page = await _repository.products(
        query: state.query,
        vendorId: _vendorId,
        page: next,
      );
      if (request != _request || isClosed) return;
      emit(
        state.copyWith(
          items: [...state.items, ...page.items],
          nextPage: page.nextPage,
          loadingMore: false,
        ),
      );
    } on ApiException catch (e) {
      if (request != _request || isClosed) return;
      emit(
        state.copyWith(nextPage: next, loadingMore: false, error: e.messageAr),
      );
    }
  }

  /// Saved when the user commits to a word, not on every typed letter.
  Future<void> remember(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;
    final recent = [
      query,
      ...state.recent.where((word) => word != query),
    ].take(_recentCount).toList();
    await _prefs.setStringList(_recentKey, recent);
    if (isClosed) return;
    emit(
      state.copyWith(
        nextPage: state.nextPage,
        error: state.error,
        recent: recent,
      ),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _scope.cancel();
    return super.close();
  }
}
