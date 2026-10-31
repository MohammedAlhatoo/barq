import 'dart:async';

import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cart/state/shop_scope_cubit.dart';
import '../data/browse_models.dart';
import '../data/browse_repository.dart';
import '../data/user_location.dart';

class HomeState {
  const HomeState({
    this.loading = true,
    this.categories = const [],
    this.products = const [],
    this.vendors = const [],
    this.name,
    this.error,
  });

  final bool loading;
  final List<Category> categories;
  final List<Product> products;

  /// In the server's order: open first, then nearest.
  final List<Vendor> vendors;
  final String? name;
  final String? error;
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(
    this._repository,
    this._location,
    this._shop,
    Stream<void> accountChanges,
  ) : super(const HomeState()) {
    _scope = _shop.stream.listen((_) => _scopeChanged());
    _account = accountChanges.listen((_) => load());
  }

  final BrowseRepository _repository;
  final UserLocation _location;
  final ShopScopeCubit _shop;
  late final StreamSubscription<ShopScope> _scope;

  /// A new default address changes the nearest stores, and a new name changes
  /// the greeting. Home stays alive behind the tabs, so it must hear about it.
  late final StreamSubscription<void> _account;

  /// The nearest open store, or null when no location is known.
  int? _nearest;

  /// The store whose products are showing. Null is every store.
  int? _shown;

  /// Answers of an older scope are ignored.
  int _request = 0;

  /// A request can end after the user left the screen.
  @override
  void emit(HomeState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> load() async {
    final request = ++_request;
    emit(const HomeState());
    try {
      final categories = await _repository.categories();
      final vendors = await _vendors();
      _nearest = _nearestOf(vendors);
      final page = await _products();
      final name = await _name();
      if (request != _request) return;
      emit(
        HomeState(
          loading: false,
          categories: categories,
          products: page.items,
          vendors: vendors,
          name: name,
        ),
      );
    } on ApiException catch (e) {
      if (request != _request) return;
      emit(HomeState(loading: false, error: e.messageAr));
    }
  }

  /// With an empty cart Home starts from the nearest store. With items it
  /// follows the cart, or every store after "كل المتاجر".
  int? get _target =>
      _shop.state.vendorId == null ? _nearest : _shop.state.filterVendorId;

  static int? _nearestOf(List<Vendor> vendors) {
    for (final vendor in vendors) {
      if (vendor.isOpen && vendor.distanceKm != null) return vendor.id;
    }
    return null;
  }

  /// An empty nearest store must not leave Home with nothing to show.
  Future<Paged<Product>> _products() async {
    final target = _target;
    _shown = target;
    final page = await _repository.products(vendorId: target);
    final fromNearest = target != null && _shop.state.vendorId == null;
    if (page.items.isNotEmpty || !fromNearest) return page;
    return _repository.products();
  }

  /// Swaps the products without a spinner: this runs right after a tap on "+".
  Future<void> _scopeChanged() async {
    if (_target == _shown) return;
    if (state.loading || state.error != null) return load();
    final request = ++_request;
    try {
      final page = await _products();
      if (request != _request) return;
      emit(
        HomeState(
          loading: false,
          categories: state.categories,
          products: page.items,
          vendors: state.vendors,
          name: state.name,
        ),
      );
    } on ApiException catch (e) {
      if (request != _request) return;
      emit(HomeState(loading: false, error: e.messageAr));
    }
  }

  @override
  Future<void> close() {
    _scope.cancel();
    _account.cancel();
    return super.close();
  }

  /// Sends the user's location so the nearest stores come first. The products
  /// still show if this part fails.
  Future<List<Vendor>> _vendors() async {
    try {
      final location = await _location.current();
      return await _repository.vendors(lat: location?.lat, lng: location?.lng);
    } on ApiException {
      return const [];
    }
  }

  /// The greeting is not worth failing the whole screen for.
  Future<String?> _name() async {
    try {
      return await _repository.currentName();
    } on ApiException {
      return null;
    }
  }
}
