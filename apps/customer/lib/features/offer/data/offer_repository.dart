import 'package:barq_core/barq_core.dart';

import 'offer_models.dart';

abstract class OfferRepository {
  Future<OrderInfo> order(int orderId);

  /// Null while the store has not priced the order yet.
  Future<Offer?> offer(int orderId);
  Future<void> approve(
    int orderId, {
    required int offerId,
    required String idempotencyKey,
  });
  Future<void> reject(int orderId);

  /// Sandbox only: does the store's next step, as no store app exists yet.
  Future<void> advanceInSandbox(int orderId);
}

class ApiOfferRepository implements OfferRepository {
  ApiOfferRepository(this._api);

  final ApiClient _api;

  @override
  Future<OrderInfo> order(int orderId) async {
    final data = await _api.get('/orders/$orderId');
    return OrderInfo.fromJson((data as Map).cast<String, dynamic>());
  }

  @override
  Future<Offer?> offer(int orderId) async {
    try {
      final data = await _api.get('/orders/$orderId/offer');
      return Offer.fromJson((data as Map).cast<String, dynamic>());
    } on ApiException catch (e) {
      if (e.status == 404) return null;
      rethrow;
    }
  }

  /// `offer_id` is the offer the user saw. If the price changed since, the
  /// server answers 409 `offer_changed`.
  @override
  Future<void> approve(
    int orderId, {
    required int offerId,
    required String idempotencyKey,
  }) => _api.post(
    '/orders/$orderId/offer/approve',
    body: {'offer_id': offerId},
    idempotencyKey: idempotencyKey,
  );

  @override
  Future<void> reject(int orderId) =>
      _api.post('/orders/$orderId/offer/reject');

  @override
  Future<void> advanceInSandbox(int orderId) =>
      _api.post('/sandbox/orders/$orderId/advance');
}
