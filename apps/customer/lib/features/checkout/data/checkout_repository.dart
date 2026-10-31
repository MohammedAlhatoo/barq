import 'package:barq_core/barq_core.dart';

import '../../cart/data/cart_models.dart';
import 'checkout_models.dart';

abstract class CheckoutRepository {
  Future<OrderQuote> quote({
    required Cart cart,
    required int addressId,
    required Substitution substitution,
    String? coupon,
  });

  /// Throws when the code cannot be used. The discount comes from [quote].
  Future<void> validateCoupon({required String code, required int vendorId});

  /// Creates the order and answers its id.
  Future<int> placeOrder({
    required String quoteToken,
    required String note,
    required Substitution substitution,
    required String idempotencyKey,
  });
}

class ApiCheckoutRepository implements CheckoutRepository {
  ApiCheckoutRepository(this._api);

  final ApiClient _api;

  @override
  Future<OrderQuote> quote({
    required Cart cart,
    required int addressId,
    required Substitution substitution,
    String? coupon,
  }) async {
    final data = await _api.post(
      '/orders/quote',
      body: {
        'vendor_id': cart.vendorId,
        'cart': [for (final line in cart.lines) line.quoteJson],
        'dropoff_address_id': addressId,
        'fields': {'substitutions': substitution.apiValue},
        'coupon': ?coupon,
      },
    );
    return OrderQuote.fromJson((data as Map).cast<String, dynamic>());
  }

  @override
  Future<void> validateCoupon({required String code, required int vendorId}) =>
      _api.post(
        '/coupons/validate',
        body: {'code': code, 'vendor_id': vendorId},
      );

  @override
  Future<int> placeOrder({
    required String quoteToken,
    required String note,
    required Substitution substitution,
    required String idempotencyKey,
  }) async {
    final data = await _api.post(
      '/orders',
      body: {
        'quote_token': quoteToken,
        if (note.isNotEmpty) 'note': note,
        'fields': {'substitutions': substitution.apiValue},
      },
      idempotencyKey: idempotencyKey,
    );
    return (data as Map)['id'] as int;
  }
}
