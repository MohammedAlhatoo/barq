import 'package:barq_core/barq_core.dart';

class Driver {
  const Driver({
    required this.name,
    required this.phone,
    required this.vehicleType,
    required this.locale,
    required this.isOnline,
    required this.ratingAverage,
    required this.ratingCount,
    required this.cashOnHand,
    required this.maxCash,
    this.avatarUrl,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    final rating = json['rating'] as Map;
    return Driver(
      name: json['name'] as String,
      phone: json['phone'] as String,
      vehicleType: json['vehicle_type'] as String,
      locale: json['locale'] as String,
      isOnline: json['is_online'] as bool,
      ratingAverage: (rating['average'] as num).toDouble(),
      ratingCount: rating['count'] as int,
      cashOnHand: Money.fromJson((json['cash_on_hand'] as Map).cast()),
      maxCash: Money.fromJson((json['max_cash'] as Map).cast()),
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  final String name;
  final String phone;
  final String vehicleType;
  final String locale;
  final bool isOnline;
  final double ratingAverage;
  final int ratingCount;
  final Money cashOnHand;
  final Money maxCash;
  final String? avatarUrl;

  String get initial =>
      name.isEmpty ? '' : String.fromCharCode(name.runes.first);
}
