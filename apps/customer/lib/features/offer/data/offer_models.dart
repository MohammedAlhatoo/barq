import 'package:barq_core/barq_core.dart';

import '../../checkout/data/checkout_models.dart';

class OfferSubstitute {
  const OfferSubstitute({required this.name, required this.unitPrice});

  factory OfferSubstitute.fromJson(Map<String, dynamic> json) =>
      OfferSubstitute(
        name: json['name'] as String,
        unitPrice: Money.fromJson(
          (json['unit_price'] as Map).cast<String, dynamic>(),
        ),
      );

  final String name;
  final Money unitPrice;
}

class OfferItem {
  const OfferItem({
    required this.name,
    required this.qty,
    required this.unitPrice,
    required this.available,
    required this.substitute,
    required this.lineTotal,
  });

  factory OfferItem.fromJson(Map<String, dynamic> json) {
    final substitute = json['substitute'];
    return OfferItem(
      name: json['name'] as String,
      qty: json['qty'] as int,
      unitPrice: Money.fromJson(
        (json['unit_price'] as Map).cast<String, dynamic>(),
      ),
      available: json['available'] as bool,
      substitute: substitute is Map
          ? OfferSubstitute.fromJson(substitute.cast<String, dynamic>())
          : null,
      lineTotal: Money.fromJson(
        (json['line_total'] as Map).cast<String, dynamic>(),
      ),
    );
  }

  final String name;
  final int qty;
  final Money unitPrice;
  final bool available;
  final OfferSubstitute? substitute;
  final Money lineTotal;
}

/// The `Offer` schema: the store's final prices for a weighed order.
class Offer {
  const Offer({
    required this.id,
    required this.status,
    required this.items,
    required this.itemsTotal,
    required this.deliveryFee,
    required this.total,
    required this.note,
    required this.expiresAt,
    required this.createdAt,
  });

  factory Offer.fromJson(Map<String, dynamic> json) => Offer(
    id: json['id'] as int,
    status: json['status'] as String,
    items: (json['items'] as List)
        .map((e) => OfferItem.fromJson((e as Map).cast<String, dynamic>()))
        .toList(),
    itemsTotal: Money.fromJson(
      (json['items_total'] as Map).cast<String, dynamic>(),
    ),
    deliveryFee: Money.fromJson(
      (json['delivery_fee'] as Map).cast<String, dynamic>(),
    ),
    total: Money.fromJson((json['total'] as Map).cast<String, dynamic>()),
    note: json['note'] as String?,
    expiresAt: DateTime.tryParse(json['expires_at'] as String? ?? ''),
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  final int id;

  /// sent · approved · rejected · expired · superseded.
  final String status;
  final List<OfferItem> items;
  final Money itemsTotal;
  final Money deliveryFee;
  final Money total;
  final String? note;
  final DateTime? expiresAt;
  final DateTime createdAt;

  bool get isOpen => status == 'sent';
  bool get isExpired => status == 'expired';

  /// How long the customer has to answer, as the server set it.
  int? get minutesToAnswer => expiresAt?.difference(createdAt).inMinutes;
}

/// An entry of the order's `available_actions`.
class OrderAction {
  const OrderAction({
    required this.action,
    required this.label,
    required this.confirm,
  });

  factory OrderAction.fromJson(Map<String, dynamic> json) => OrderAction(
    action: json['action'] as String,
    label: json['label'] as String,
    confirm: json['confirm'] as String?,
  );

  final String action;
  final String label;
  final String? confirm;
}

/// The fields of `GET /orders/{id}` that the offer and waiting screens use.
class OrderInfo {
  const OrderInfo({
    required this.id,
    required this.code,
    required this.statusKey,
    required this.isTerminal,
    required this.vendorId,
    required this.vendorName,
    required this.items,
    required this.total,
    required this.discount,
    required this.actions,
  });

  factory OrderInfo.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as Map;
    final vendor = json['vendor'];
    final price = json['price'] as Map;
    final discounts = (price['breakdown'] as List)
        .map((e) => PriceLine.fromJson((e as Map).cast<String, dynamic>()))
        .where((line) => line.kind == 'discount');
    return OrderInfo(
      id: json['id'] as int,
      code: json['code'] as String,
      statusKey: status['key'] as String,
      isTerminal: status['is_terminal'] as bool,
      vendorId: vendor is Map ? vendor['id'] as int : null,
      vendorName: vendor is Map ? vendor['name'] as String : null,
      items: [
        for (final item in json['items'] as List)
          (name: (item as Map)['name'] as String, qty: item['qty'] as int),
      ],
      total: Money.fromJson((price['total'] as Map).cast<String, dynamic>()),
      discount: discounts.isEmpty ? null : discounts.first,
      actions: (json['available_actions'] as List)
          .map((e) => OrderAction.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }

  final int id;
  final String code;
  final String statusKey;
  final bool isTerminal;
  final int? vendorId;
  final String? vendorName;
  final List<({String name, int qty})> items;
  final Money total;

  /// An offer has no discount row, though its total includes the coupon.
  final PriceLine? discount;
  final List<OrderAction> actions;

  OrderAction? get cancelAction {
    for (final action in actions) {
      if (action.action == 'cancel') return action;
    }
    return null;
  }
}
