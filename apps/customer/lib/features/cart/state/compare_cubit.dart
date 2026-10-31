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
    this.error,
    this.errorCode,
  });

  final CompareStatus status;
  final BasketComparison? comparison;

  /// The nearest complete stores, best first.
  final List<BasketStore> ranked;

  /// Vendor id → the server's total with delivery. A store is missing here if
  /// it was not quoted or its quote failed.
  final Map<int, Money> totals;

  /// The store marked "الأوفر".
  final int? bestVendorId;
  final int? selectedVendorId;
  final String? error;

  /// Shown on the out-of-zone screen, like "422 out_of_zone".
  final String? errorCode;

  BasketStore? get selected => comparison?.storeOf(selectedVendorId);
}

class CompareCubit extends Cubit<CompareState> {
  CompareCubit({
    required this._browse,
    required this._cart,
    required this._lines,
  }) : super(const CompareState());

  final BrowseRepository _browse;
  final CartRepository _cart;
  final List<CartLine> _lines;

  /// How many stores the screen compares. Each one is a quote request.
  static const _comparedStores = 3;

  /// A request can end after the user left the screen.
  @override
  void emit(CompareState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> load() async {
    emit(const CompareState());
    try {
      final address = await _browse.defaultAddress();
      if (address == null) {
        emit(const CompareState(status: CompareStatus.noAddress));
        return;
      }
      final comparison = await _cart.compare(
        lines: _lines,
        addressId: address.id,
      );
      final stores = comparison.stores;
      final compared = await _nearestComplete(comparison, address);
      final totals = await _quote(compared, address);
      final ranked = _rank(compared, stores, totals);
      final best = ranked.isEmpty ? null : ranked.first.vendorId;
      emit(
        CompareState(
          status: CompareStatus.ready,
          comparison: comparison,
          ranked: ranked,
          totals: totals,
          bestVendorId: best,
          selectedVendorId:
              best ?? (stores.isEmpty ? null : stores.first.vendorId),
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

  /// The nearest complete stores. `POST /baskets/compare` has no distance, so
  /// it comes from `GET /vendors`. Without it the server's order decides.
  Future<List<BasketStore>> _nearestComplete(
    BasketComparison comparison,
    SavedAddress address,
  ) async {
    final complete = comparison.stores.where((s) => s.complete).toList();
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
            .quotedTotal(store: store, addressId: address.id)
            .then<Money?>((total) => total)
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
    ),
  );
}
