/// A price from the server. Always display [formatted], never calculate.
class Money {
  const Money({required this.amount, required this.formatted});

  factory Money.fromJson(Map<String, dynamic> json) => Money(
    amount: json['amount'] as int,
    formatted: json['formatted'] as String,
  );

  final int amount;
  final String formatted;
}
