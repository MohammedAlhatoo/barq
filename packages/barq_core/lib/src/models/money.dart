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
  ///
  /// [minorUnits] is `currency.minor_units`: how many minor units make one
  /// major unit (100 agorot in a shekel), not a number of decimals.
  Money savedAgainst(
    Money other, {
    required String symbol,
    required int minorUnits,
  }) {
    final saved = other.amount - amount;
    final major = (saved / minorUnits).toStringAsFixed(_decimals(minorUnits));
    return Money(amount: saved, formatted: '$major $symbol');
  }

  /// log10 of [minorUnits]: 100 is 2 decimals, 1 is none. Whole numbers only,
  /// because a double log10 of 1000 comes out just under 3.
  static int _decimals(int minorUnits) {
    var decimals = 0;
    for (var unit = minorUnits; unit >= 10; unit ~/= 10) {
      decimals++;
    }
    return decimals;
  }
}
