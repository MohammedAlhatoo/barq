/// Refresh periods from the server. Null means the server did not send it.
class PollingConfig {
  const PollingConfig({
    this.trackingSeconds,
    this.eventsSeconds,
    this.availableOrdersSeconds,
    this.notificationsSeconds,
    this.configSeconds,
  });

  factory PollingConfig.fromJson(Map<String, dynamic> json) => PollingConfig(
    trackingSeconds: json['tracking_seconds'] as int?,
    eventsSeconds: json['events_seconds'] as int?,
    availableOrdersSeconds: json['available_orders_seconds'] as int?,
    notificationsSeconds: json['notifications_seconds'] as int?,
    configSeconds: json['config_seconds'] as int?,
  );

  final int? trackingSeconds;
  final int? eventsSeconds;
  final int? availableOrdersSeconds;
  final int? notificationsSeconds;
  final int? configSeconds;
}
