import 'package:barq_core/barq_core.dart';

class EarningsDay {
  const EarningsDay({
    required this.date,
    required this.orders,
    required this.earnings,
  });

  factory EarningsDay.fromJson(Map<String, dynamic> json) => EarningsDay(
    date: DateTime.parse(json['date'] as String),
    orders: json['orders'] as int,
    earnings: Money.fromJson((json['earnings'] as Map).cast()),
  );

  final DateTime date;
  final int orders;
  final Money earnings;
}

class Earnings {
  const Earnings({
    required this.orders,
    required this.earnings,
    this.series = const [],
  });

  factory Earnings.fromJson(Map<String, dynamic> json) => Earnings(
    orders: json['orders'] as int,
    earnings: Money.fromJson((json['earnings'] as Map).cast()),
    series: [
      for (final day in json['series'] as List)
        EarningsDay.fromJson((day as Map).cast()),
    ],
  );

  final int orders;
  final Money earnings;
  final List<EarningsDay> series;
}

class CashSummary {
  const CashSummary({
    required this.cashOnHand,
    required this.maxCash,
    required this.unsettledOrders,
    this.remaining,
  });

  factory CashSummary.fromJson(Map<String, dynamic> json) {
    final remaining = json['remaining'] as Map?;
    return CashSummary(
      cashOnHand: Money.fromJson((json['cash_on_hand'] as Map).cast()),
      maxCash: Money.fromJson((json['max_cash'] as Map).cast()),
      unsettledOrders: json['unsettled_orders'] as int,
      remaining: remaining == null ? null : Money.fromJson(remaining.cast()),
    );
  }

  final Money cashOnHand;
  final Money maxCash;
  final Money? remaining;
  final int unsettledOrders;

  /// How full the bar is. Display only.
  double get usedShare =>
      maxCash.amount == 0 ? 0 : cashOnHand.amount / maxCash.amount;
}
