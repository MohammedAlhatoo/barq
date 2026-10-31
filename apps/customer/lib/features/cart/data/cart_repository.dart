import 'package:barq_core/barq_core.dart';

import 'cart_models.dart';

abstract class CartRepository {
  Future<BasketComparison> compare({
    required List<CartLine> lines,
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
}
