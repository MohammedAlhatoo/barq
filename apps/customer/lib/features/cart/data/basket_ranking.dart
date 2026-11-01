import 'package:barq_core/barq_core.dart';

import '../../auth/data/auth_models.dart';
import '../../browse/data/browse_repository.dart';
import 'cart_models.dart';
import 'cart_repository.dart';

/// How stores of a comparison are picked and ordered: the compare screen and
/// the assistant give the same answer because both use this class.
class BasketRanking {
  BasketRanking({required this._browse, required this._cart});

  /// How many stores are priced. Each is a quote request.
  static const comparedStores = 3;

  final BrowseRepository _browse;
  final CartRepository _cart;

  /// Vendor id → km. `POST /baskets/compare` has no distance, so it comes from
  /// `GET /vendors`. Empty if that fails: the comparison still works.
  Future<Map<int, double>> distances(SavedAddress address) async {
    try {
      final vendors = await _browse.vendors(lat: address.lat, lng: address.lng);
      return {for (final vendor in vendors) vendor.id: ?vendor.distanceKm};
    } on ApiException {
      return const {};
    }
  }

  /// [stores] from the nearest. A store with no distance comes last, and the
  /// server's order decides a tie.
  List<BasketStore> nearest(
    List<BasketStore> stores,
    Map<int, double> distances,
  ) {
    double distanceOf(BasketStore store) =>
        distances[store.vendorId] ?? double.infinity;
    return [...stores]..sort((a, b) {
      final order = distanceOf(a).compareTo(distanceOf(b));
      // Dart's sort may swap equals.
      return order != 0
          ? order
          : stores.indexOf(a).compareTo(stores.indexOf(b));
    });
  }

  /// A failed quote only loses that store's total: the screen then shows its
  /// items price. [wanted] carries quantities and choices that differ from the
  /// comparison's own lines, which have no choices.
  Future<Map<int, Money>> quote(
    List<BasketStore> stores,
    SavedAddress address, {
    List<CartLine>? wanted,
  }) async {
    Future<Quote> quoteOf(BasketStore store) => wanted == null
        ? _cart.quoteStore(store: store, addressId: address.id)
        : _cart.quoteCart(
            vendorId: store.vendorId,
            lines: store.linesFor(wanted),
            addressId: address.id,
          );
    final answers = await Future.wait([
      for (final store in stores)
        quoteOf(store)
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
  List<BasketStore> rank(
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
}
