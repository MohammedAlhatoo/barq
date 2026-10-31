import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/data/auth_models.dart';
import '../../browse/data/browse_repository.dart';
import '../data/cart_models.dart';
import '../data/cart_repository.dart';

enum CompareStatus { loading, ready, outOfZone, noAddress, failed }

class CompareState {
  const CompareState({
    this.status = CompareStatus.loading,
    this.comparison,
    this.ranked = const [],
    this.totals = const {},
    this.bestVendorId,
    this.selectedVendorId,
    this.cartVendorId,
    this.cartVendorName,
    this.cartTotal,
    this.cartIsCheapest = false,
    this.error,
    this.errorCode,
  });

  final CompareStatus status;
  final BasketComparison? comparison;

  /// The nearest complete stores other than the cart's, cheapest first.
  final List<BasketStore> ranked;

  /// Vendor id → the server's total with delivery. A store is missing here if
  /// it was not quoted or its quote failed.
  final Map<int, Money> totals;

  /// The store marked "الأوفر": cheaper than the cart, by the server's totals.
  final int? bestVendorId;
  final int? selectedVendorId;

  /// The first row, "سلتك الحالية".
  final int? cartVendorId;
  final String? cartVendorName;

  /// The server's total with delivery. Null if that quote failed.
  final Money? cartTotal;

  /// True once other stores were priced and none beats the cart.
  final bool cartIsCheapest;
  final String? error;

  /// Shown on the out-of-zone screen, like "422 out_of_zone".
  final String? errorCode;

  /// The other store picked. Null means staying with the cart as it is.
  BasketStore? get selected => selectedVendorId == cartVendorId
      ? null
      : comparison?.storeOf(selectedVendorId);
}

class CompareCubit extends Cubit<CompareState> {
  CompareCubit({
    required this._browse,
    required this._cart,
    required this._current,
    this._address,
  }) : super(const CompareState());

  final BrowseRepository _browse;
  final CartRepository _cart;
  final Cart _current;

  /// Checkout's chosen address. Null compares for the default one.
  SavedAddress? _address;

  /// How many stores the cart is compared with. Each is a quote request.
  static const _comparedStores = 3;

  /// A request can end after the user left the screen.
  @override
  void emit(CompareState state) {
    if (!isClosed) super.emit(state);
  }

  void useDefaultAddress() => _address = null;

  Future<void> load() async {
    emit(const CompareState());
    try {
      final address = _address ?? await _browse.defaultAddress();
      if (address == null) {
        emit(const CompareState(status: CompareStatus.noAddress));
        return;
      }
      final comparison = await _cart.compare(
        lines: _current.lines,
        addressId: address.id,
      );
      final vendorId = _current.vendorId;
      final cartQuote = await _quoteCart(address);
      final compared = await _nearestComplete(comparison, address);
      final totals = await _quote(compared, address);
      final ranked = _rank(compared, comparison.stores, totals);
      final cheapest = ranked.isNotEmpty ? totals[ranked.first.vendorId] : null;
      final cartTotal = cartQuote?.total;
      final beatsCart =
          cheapest != null &&
          (cartTotal == null || cheapest.amount < cartTotal.amount);
      final best = beatsCart ? ranked.first.vendorId : null;
      emit(
        CompareState(
          status: CompareStatus.ready,
          comparison: comparison,
          ranked: ranked,
          totals: totals,
          bestVendorId: best,
          selectedVendorId: best ?? _startingChoice(comparison),
          cartVendorId: vendorId,
          cartVendorName: await _vendorName(comparison),
          cartTotal: cartTotal,
          cartIsCheapest: cheapest != null && !beatsCart,
        ),
      );
    } on ApiException catch (e) {
      emit(
        CompareState(
          status: e.code == 'out_of_zone'
              ? CompareStatus.outOfZone
              : CompareStatus.failed,
          error: e.messageAr,
          errorCode: '${e.status} ${e.code}',
        ),
      );
    }
  }

  /// The cart, unless no store is complete: that screen needs a store to offer.
  int? _startingChoice(BasketComparison comparison) {
    final vendorId = _current.vendorId;
    if (comparison.cheapestVendorId != null) return vendorId;
    for (final store in comparison.stores) {
      if (store.vendorId != vendorId) return store.vendorId;
    }
    return vendorId;
  }

  /// A failed quote keeps the screen: the row then says delivery comes later.
  Future<Quote?> _quoteCart(SavedAddress address) async {
    final vendorId = _current.vendorId;
    if (vendorId == null) return null;
    try {
      return await _cart.quoteCart(
        vendorId: vendorId,
        lines: _current.lines,
        addressId: address.id,
      );
    } on ApiException {
      return null;
    }
  }

  /// The cart's store may be outside the comparison, so it has its own lookup.
  Future<String?> _vendorName(BasketComparison comparison) async {
    final vendorId = _current.vendorId;
    final known = comparison.storeOf(vendorId)?.vendorName;
    if (known != null || vendorId == null) return known;
    try {
      return (await _browse.vendor(vendorId)).name;
    } on ApiException {
      return null;
    }
  }

  /// The nearest complete stores. `POST /baskets/compare` has no distance, so
  /// it comes from `GET /vendors`. Without it the server's order decides.
  Future<List<BasketStore>> _nearestComplete(
    BasketComparison comparison,
    SavedAddress address,
  ) async {
    final complete = comparison.stores
        .where((s) => s.complete && s.vendorId != _current.vendorId)
        .toList();
    var distances = <int, double>{};
    try {
      final vendors = await _browse.vendors(lat: address.lat, lng: address.lng);
      distances = {for (final vendor in vendors) vendor.id: ?vendor.distanceKm};
    } on ApiException {
      // The comparison still works.
    }
    double distanceOf(BasketStore store) =>
        distances[store.vendorId] ?? double.infinity;
    final byDistance = [...complete]
      ..sort((a, b) {
        final order = distanceOf(a).compareTo(distanceOf(b));
        // Dart's sort may swap equals: keep the server's order for a tie.
        return order != 0
            ? order
            : complete.indexOf(a).compareTo(complete.indexOf(b));
      });
    return byDistance.take(_comparedStores).toList();
  }

  /// A failed quote only loses that store's total: the screen then shows its
  /// items price.
  Future<Map<int, Money>> _quote(
    List<BasketStore> stores,
    SavedAddress address,
  ) async {
    final answers = await Future.wait([
      for (final store in stores)
        _cart
            .quoteStore(store: store, addressId: address.id)
            .then<Money?>((quote) => quote.total)
            .catchError((Object _) => null, test: (e) => e is ApiException),
    ]);
    return {
      for (final (index, store) in stores.indexed)
        store.vendorId: ?answers[index],
    };
  }

  /// Quoted stores from the lowest total, then the others from the cheapest
  /// items, which is the order [all] came in. Sorting only compares the
  /// server's numbers, it calculates nothing.
  List<BasketStore> _rank(
    List<BasketStore> compared,
    List<BasketStore> all,
    Map<int, Money> totals,
  ) {
    final inServerOrder = all.where(compared.contains).toList();
    final quoted =
        inServerOrder.where((s) => totals.containsKey(s.vendorId)).toList()
          ..sort((a, b) {
            final byTotal = totals[a.vendorId]!.amount.compareTo(
              totals[b.vendorId]!.amount,
            );
            return byTotal != 0
                ? byTotal
                : all.indexOf(a).compareTo(all.indexOf(b));
          });
    return [
      ...quoted,
      ...inServerOrder.where((s) => !totals.containsKey(s.vendorId)),
    ];
  }

  void select(int vendorId) => emit(
    CompareState(
      status: state.status,
      comparison: state.comparison,
      ranked: state.ranked,
      totals: state.totals,
      bestVendorId: state.bestVendorId,
      selectedVendorId: vendorId,
      cartVendorId: state.cartVendorId,
      cartVendorName: state.cartVendorName,
      cartTotal: state.cartTotal,
      cartIsCheapest: state.cartIsCheapest,
    ),
  );
}
