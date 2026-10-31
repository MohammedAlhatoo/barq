/// Driver settings from `GET /app/config?app=driver`.
class DriverConfig {
  const DriverConfig({
    required this.radiusKm,
    required this.locationMinIntervalSeconds,
    required this.onlineRequiresLocationMinutes,
  });

  factory DriverConfig.fromJson(Map<String, dynamic> json) => DriverConfig(
    radiusKm: (json['radius_km'] as num).toDouble(),
    locationMinIntervalSeconds: json['location_min_interval_seconds'] as int,
    onlineRequiresLocationMinutes:
        json['online_requires_location_minutes'] as int,
  );

  final double radiusKm;
  final int locationMinIntervalSeconds;
  final int onlineRequiresLocationMinutes;
}
