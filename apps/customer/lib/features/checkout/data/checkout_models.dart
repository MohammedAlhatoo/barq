import 'package:barq_core/barq_core.dart';

import '../../cart/data/cart_models.dart';

/// The choices of `fields.substitutions`: what to do if a product runs out.
enum Substitution {
  callMe('call_me'),
  similar('similar'),
  skip('skip');

  const Substitution(this.apiValue);

  final String apiValue;
}

/// One row of the server's price breakdown.
class PriceLine {
  const PriceLine({
    required this.key,
    required this.kind,
    required this.label,
    required this.price,
  });

  factory PriceLine.fromJson(Map<String, dynamic> json) => PriceLine(
    key: json['key'] as String,
    kind: json['kind'] as String,
    label: json['label'] as String,
    price: Money.fromJson(json),
  );

  final String key;
  final String kind;
  final String label;
  final Money price;
}

/// Answer of `POST /orders/quote`, with everything checkout shows.
class OrderQuote {
  const OrderQuote({
    required this.token,
    required this.expiresIn,
    required this.distanceKm,
    required this.breakdown,
    required this.itemsTotal,
    required this.discount,
    required this.total,
  });

  factory OrderQuote.fromJson(Map<String, dynamic> json) => OrderQuote(
    token: json['quote_token'] as String,
    expiresIn: json['expires_in'] as int,
    distanceKm: (json['distance_km'] as num).toDouble(),
    breakdown: (json['breakdown'] as List)
        .map((e) => PriceLine.fromJson((e as Map).cast<String, dynamic>()))
        .toList(),
    itemsTotal: Money.fromJson(
      (json['items_total'] as Map).cast<String, dynamic>(),
    ),
    discount: Money.fromJson((json['discount'] as Map).cast<String, dynamic>()),
    total: Money.fromJson((json['total'] as Map).cast<String, dynamic>()),
  );

  final String token;

  /// Seconds this price stays reserved.
  final int expiresIn;
  final double distanceKm;
  final List<PriceLine> breakdown;
  final Money itemsTotal;
  final Money discount;
  final Money total;
}

/// One thing that costs something else in the new quote. [line] is set for a
/// product, and is null for a row of the breakdown such as delivery.
class PriceChange {
  const PriceChange({
    required this.title,
    required this.before,
    required this.after,
    this.line,
  });

  final String title;
  final Money before;
  final Money after;
  final CartLine? line;
}

/// What the "price expired" sheet shows after a new quote.
class Repricing {
  const Repricing({
    required this.oldTotal,
    required this.newTotal,
    required this.changes,
    required this.minutes,
  });

  final Money oldTotal;
  final Money newTotal;
  final List<PriceChange> changes;

  /// How long the old price was reserved.
  final int minutes;
}
