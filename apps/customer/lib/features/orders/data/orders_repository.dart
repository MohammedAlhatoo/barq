import 'dart:async';

import 'package:barq_core/barq_core.dart';

import 'orders_models.dart';

abstract class OrdersRepository {
  /// Fires when an order changed, so the orders tab, which stays alive behind
  /// the other tabs, loads again.
  Stream<void> get changes;
  void ordersChanged();

  Future<Order> order(int orderId);
  Future<OrderEvents> events(int orderId, {required int since});
  Future<Tracking> tracking(int orderId);

  /// [scope] is active, completed or cancelled.
  Future<Paged<OrderSummary>> orders({required String scope, int page = 1});
  Future<List<CancelReason>> cancelReasons();
  Future<void> cancel(int orderId, {required String reason});
  Future<void> rate(
    int orderId, {
    required int stars,
    int? vendorStars,
    String? comment,
  });
  Future<Receipt> receipt(int orderId);
  Future<ShareLink> createShareLink(int orderId);
  Future<void> stopShareLink(int orderId);
  Future<Paged<AppNotification>> notifications({int page = 1});
  Future<int> unreadNotifications();
  Future<void> readAllNotifications();
  Future<void> notificationOpened(int id);
}

class ApiOrdersRepository implements OrdersRepository {
  ApiOrdersRepository(this._api);

  final ApiClient _api;
  final _changes = StreamController<void>.broadcast();

  @override
  Stream<void> get changes => _changes.stream;

  @override
  void ordersChanged() => _changes.add(null);

  @override
  Future<Order> order(int orderId) async {
    final data = await _api.get('/orders/$orderId');
    return Order.fromJson((data as Map).cast<String, dynamic>());
  }

  @override
  Future<OrderEvents> events(int orderId, {required int since}) async {
    final page = await _api.getPaged(
      '/orders/$orderId/events',
      query: {'since': since},
    );
    return OrderEvents(
      hasNews: page.items.isNotEmpty,
      nextSince: page.meta?['next_since'] as int? ?? since,
      nextPollSeconds: page.meta?['next_poll_seconds'] as int?,
    );
  }

  @override
  Future<Tracking> tracking(int orderId) async {
    final data = await _api.get('/orders/$orderId/tracking');
    return Tracking.fromJson((data as Map).cast<String, dynamic>());
  }

  @override
  Future<Paged<OrderSummary>> orders({
    required String scope,
    int page = 1,
  }) async {
    final result = await _api.getPaged(
      '/orders',
      query: {'scope': scope, 'page': page},
    );
    return Paged(
      items: result.items
          .map((e) => OrderSummary.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      nextPage: result.nextPage,
      total: result.total,
    );
  }

  @override
  Future<List<CancelReason>> cancelReasons() async {
    final data = await _api.get('/cancel-reasons');
    return (data as List)
        .map((e) => CancelReason.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  @override
  Future<void> cancel(int orderId, {required String reason}) async {
    await _api.post('/orders/$orderId/cancel', body: {'reason': reason});
    ordersChanged();
  }

  @override
  Future<void> rate(
    int orderId, {
    required int stars,
    int? vendorStars,
    String? comment,
  }) async {
    await _api.post(
      '/orders/$orderId/rate',
      body: {'stars': stars, 'vendor_stars': ?vendorStars, 'comment': ?comment},
    );
    ordersChanged();
  }

  @override
  Future<Receipt> receipt(int orderId) async {
    final data = await _api.get('/orders/$orderId/receipt');
    return Receipt.fromJson((data as Map).cast<String, dynamic>());
  }

  @override
  Future<ShareLink> createShareLink(int orderId) async {
    final data = await _api.post('/orders/$orderId/share-link');
    return ShareLink.fromJson((data as Map).cast<String, dynamic>());
  }

  @override
  Future<void> stopShareLink(int orderId) =>
      _api.delete('/orders/$orderId/share-link');

  @override
  Future<Paged<AppNotification>> notifications({int page = 1}) async {
    final result = await _api.getPaged('/notifications', query: {'page': page});
    return Paged(
      items: result.items
          .map(
            (e) => AppNotification.fromJson((e as Map).cast<String, dynamic>()),
          )
          .toList(),
      nextPage: result.nextPage,
      total: result.total,
    );
  }

  @override
  Future<int> unreadNotifications() async {
    final page = await _api.getPaged(
      '/notifications',
      query: {'unread': 1, 'per_page': 1},
    );
    return page.meta?['unread'] as int? ?? page.total ?? 0;
  }

  @override
  Future<void> readAllNotifications() => _api.post('/notifications/read-all');

  @override
  Future<void> notificationOpened(int id) =>
      _api.post('/notifications/$id/opened');
}
