import 'package:barq_core/barq_core.dart';

import 'cart_models.dart';

abstract class CartRepository {
  Future<BasketComparison> compare({
    required List<CartLine> lines,
    required int addressId,
  });

  /// The server's price of the cart as it is, from its own store.
  Future<Quote> quoteCart({
    required int vendorId,
    required List<CartLine> lines,
    required int addressId,
  });

  /// The server's price of the same items at another [store].
  Future<Quote> quoteStore({
    required BasketStore store,
    required int addressId,
  });
}

class ApiCartRepository implements CartRepository {
  ApiCartRepository(this._api);

  final ApiClient _api;

  @override
  Future<BasketComparison> compare({
    required List<CartLine> lines,
    required int addressId,
  }) async {
    // Two lines can be one product with different choices. The server wants
    // each product once.
    final quantities = <int, int>{};
    for (final line in lines) {
      quantities[line.productId] = (quantities[line.productId] ?? 0) + line.qty;
    }
    final data = await _api.post(
      '/baskets/compare',
      body: {
        'cart': [
          for (final entry in quantities.entries)
            {'product_id': entry.key, 'qty': entry.value},
        ],
        'dropoff_address_id': addressId,
      },
    );
    return BasketComparison.fromJson((data as Map).cast<String, dynamic>());
  }

  @override
  Future<Quote> quoteCart({
    required int vendorId,
    required List<CartLine> lines,
    required int addressId,
  }) => _quote(vendorId, addressId, [for (final line in lines) line.quoteJson]);

  @override
  Future<Quote> quoteStore({
    required BasketStore store,
    required int addressId,
  }) => _quote(store.vendorId, addressId, [
    // Each store sells the product under its own id.
    for (final line in store.lines)
      {'product_id': line.storeProductId, 'qty': line.qty},
  ]);

  Future<Quote> _quote(
    int vendorId,
    int addressId,
    List<Map<String, Object?>> cart,
  ) async {
    final data = await _api.post(
      '/orders/quote',
      body: {
        'vendor_id': vendorId,
        'cart': cart,
        'dropoff_address_id': addressId,
      },
    );
    return Quote.fromJson((data as Map).cast<String, dynamic>());
  }
}
