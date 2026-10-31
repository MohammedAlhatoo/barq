import 'package:barq_core/barq_core.dart';

import '../../offer/data/offer_models.dart';

Money _money(Object? json) =>
    Money.fromJson((json as Map).cast<String, dynamic>());

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;

/// Which screen shows an order. Worked out from the config's `step`, so a new
/// status falls in the right place without a code change.
enum OrderStage { waiting, tracking, delivered, cancelled }

OrderStage stageOf(AppConfig config, String statusKey) {
  final status = config.status(statusKey);
  if (statusKey == OrderTimelines.tracking.last) return OrderStage.delivered;
  if (status.isTerminal) return OrderStage.cancelled;
  final firstStep = config.status(OrderTimelines.tracking.first).step;
  return firstStep > 0 && status.step >= firstStep
      ? OrderStage.tracking
      : OrderStage.waiting;
}

class MapPoint {
  const MapPoint({required this.lat, required this.lng});

  factory MapPoint.fromJson(Map<String, dynamic> json) => MapPoint(
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
  );

  final double lat;
  final double lng;
}

/// The fields of `GET /orders/{id}` that the order screens use.
/// `delivery_code` is left out on purpose: delivery is confirmed by photo.
class Order {
  const Order({
    required this.id,
    required this.code,
    required this.statusKey,
    required this.isTerminal,
    required this.completedAt,
    required this.vendorId,
    required this.vendorName,
    required this.items,
    required this.total,
    required this.discount,
    required this.driverName,
    required this.actions,
    required this.rated,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as Map;
    final vendor = json['vendor'];
    final driver = json['driver'];
    final price = json['price'] as Map;
    return Order(
      id: json['id'] as int,
      code: json['code'] as String,
      statusKey: status['key'] as String,
      isTerminal: status['is_terminal'] as bool,
      completedAt: _date(json['completed_at']),
      vendorId: vendor is Map ? vendor['id'] as int : null,
      vendorName: vendor is Map ? vendor['name'] as String : null,
      items: [
        for (final item in json['items'] as List)
          (name: (item as Map)['name'] as String, qty: item['qty'] as int),
      ],
      total: _money(price['total']),
      discount: _money(price['discount']),
      driverName: driver is Map ? driver['name'] as String : null,
      actions: (json['available_actions'] as List)
          .map((e) => OrderAction.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      rated: json['rating'] != null,
    );
  }

  final int id;
  final String code;
  final String statusKey;
  final bool isTerminal;
  final DateTime? completedAt;
  final int? vendorId;
  final String? vendorName;
  final List<({String name, int qty})> items;
  final Money total;
  final Money discount;
  final String? driverName;
  final List<OrderAction> actions;

  /// The customer has rated this order.
  final bool rated;

  OrderAction? action(String name) {
    for (final action in actions) {
      if (action.action == name) return action;
    }
    return null;
  }
}

/// A row of `GET /orders`. The schema has no store name.
class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.code,
    required this.statusKey,
    required this.isTerminal,
    required this.createdAt,
    required this.itemsCount,
    required this.total,
    required this.rated,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as Map;
    return OrderSummary(
      id: json['id'] as int,
      code: json['code'] as String,
      statusKey: status['key'] as String,
      isTerminal: status['is_terminal'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      itemsCount: json['items_count'] as int?,
      total: _money(json['total']),
      rated: json['rated'] as bool?,
    );
  }

  final int id;
  final String code;
  final String statusKey;
  final bool isTerminal;
  final DateTime createdAt;
  final int? itemsCount;
  final Money total;
  final bool? rated;
}

/// One page of `GET /orders/{id}/events`.
class OrderEvents {
  const OrderEvents({
    required this.hasNews,
    required this.nextSince,
    required this.nextPollSeconds,
  });

  final bool hasNews;

  /// Sent as `since` on the next request.
  final int nextSince;
  final int? nextPollSeconds;
}

class Tracking {
  const Tracking({
    required this.statusKey,
    required this.driverName,
    required this.driverPhone,
    required this.vehicleType,
    required this.ratingAverage,
    required this.driverLocation,
    required this.pickup,
    required this.dropoff,
    required this.etaMinutes,
    required this.pathTail,
    required this.nextPollSeconds,
  });

  factory Tracking.fromJson(Map<String, dynamic> json) {
    final driver = json['driver'];
    final location = driver is Map ? driver['location'] : null;
    return Tracking(
      statusKey: (json['status'] as Map)['key'] as String,
      driverName: driver is Map ? driver['name'] as String : null,
      driverPhone: driver is Map ? driver['phone'] as String : null,
      vehicleType: driver is Map ? driver['vehicle_type'] as String : null,
      ratingAverage: driver is Map
          ? ((driver['rating'] as Map)['average'] as num).toDouble()
          : null,
      driverLocation: location is Map
          ? MapPoint.fromJson(location.cast<String, dynamic>())
          : null,
      pickup: MapPoint.fromJson(
        (json['pickup'] as Map).cast<String, dynamic>(),
      ),
      dropoff: MapPoint.fromJson(
        (json['dropoff'] as Map).cast<String, dynamic>(),
      ),
      etaMinutes: json['eta_minutes'] as int?,
      pathTail: [
        for (final point in json['path_tail'] as List)
          MapPoint.fromJson((point as Map).cast<String, dynamic>()),
      ],
      nextPollSeconds: json['next_poll_seconds'] as int,
    );
  }

  final String statusKey;
  final String? driverName;
  final String? driverPhone;
  final String? vehicleType;
  final double? ratingAverage;
  final MapPoint? driverLocation;
  final MapPoint pickup;
  final MapPoint dropoff;
  final int? etaMinutes;
  final List<MapPoint> pathTail;
  final int nextPollSeconds;
}

class ReceiptLine {
  const ReceiptLine({
    required this.labelAr,
    required this.labelEn,
    required this.amount,
  });

  factory ReceiptLine.fromJson(Map<String, dynamic> json) {
    final label = json['label'] as Map;
    return ReceiptLine(
      labelAr: label['ar'] as String,
      labelEn: label['en'] as String,
      amount: _money(json['amount']),
    );
  }

  final String labelAr;
  final String labelEn;
  final Money amount;
}

class Receipt {
  const Receipt({
    required this.code,
    required this.createdAt,
    required this.completedAt,
    required this.paymentStatus,
    required this.items,
    required this.lines,
    required this.total,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) => Receipt(
    code: json['code'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    completedAt: _date(json['completed_at']),
    paymentStatus: (json['payment'] as Map)['status'] as String,
    items: [
      for (final item in json['items'] as List)
        (name: (item as Map)['name'] as String, qty: item['qty'] as int),
    ],
    lines: [
      for (final line in json['lines'] as List)
        ReceiptLine.fromJson((line as Map).cast<String, dynamic>()),
    ],
    total: _money(json['total']),
  );

  final String code;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String paymentStatus;
  final List<({String name, int qty})> items;
  final List<ReceiptLine> lines;
  final Money total;
}

class ShareLink {
  const ShareLink({required this.url, required this.expiresAt});

  factory ShareLink.fromJson(Map<String, dynamic> json) => ShareLink(
    url: json['url'] as String,
    expiresAt: _date(json['expires_at']),
  );

  final String url;
  final DateTime? expiresAt;
}

class CancelReason {
  const CancelReason({required this.key, required this.label});

  factory CancelReason.fromJson(Map<String, dynamic> json) =>
      CancelReason(key: json['key'] as String, label: json['label'] as String);

  final String key;
  final String label;
}

/// The order a notification or a push message is about. FCM sends every value
/// as text, so the number may arrive as a string.
int? orderIdOf(Map<String, dynamic> data) =>
    int.tryParse('${data['order_id']}');

class AppNotification {
  const AppNotification({
    required this.id,
    required this.event,
    required this.title,
    required this.body,
    required this.data,
    required this.readAt,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as int,
        event: json['event'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        data: (json['data'] as Map).cast<String, dynamic>(),
        readAt: _date(json['read_at']),
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  final int id;
  final String event;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime createdAt;
}
