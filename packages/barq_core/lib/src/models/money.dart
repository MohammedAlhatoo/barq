/// A price from the server. Always display [formatted], never calculate.
class Money {
  const Money({required this.amount, required this.formatted});

  factory Money.fromJson(Map<String, dynamic> json) => Money(
    amount: json['amount'] as int,
    formatted: json['formatted'] as String,
  );

  final int amount;
  final String formatted;

  /// The one sanctioned price calculation: how much two server totals differ
  /// ("وفّر ₪X"). Decided by the team as an exception to "never calculate".
  /// It changes nothing that is charged. Only the display uses it.
  Money savedAgainst(
    Money other, {
    required String symbol,
    required int minorUnits,
  }) {
    final saved = other.amount - amount;
    var scale = 1;
    for (var i = 0; i < minorUnits; i++) {
      scale *= 10;
    }
    return Money(
      amount: saved,
      formatted: '${(saved / scale).toStringAsFixed(minorUnits)} $symbol',
    );
  }
}
