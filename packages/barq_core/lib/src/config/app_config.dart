import 'driver_config.dart';
import 'polling_config.dart';
import 'status_info.dart';

/// The fields of `GET /app/config` that the apps use.
/// `project.colors` is ignored on purpose: colors come from barq_ui.
class AppConfig {
  const AppConfig({
    required this.deliveryConfirmation,
    required this.paymentMethods,
    required this.statuses,
    required this.polling,
    required this.driver,
    required this.currencySymbol,
    required this.minAppVersion,
    required this.modules,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    final driver = json['driver'];
    return AppConfig(
      deliveryConfirmation: json['delivery_confirmation'] as String,
      paymentMethods: (json['payment_methods'] as List).cast<String>(),
      statuses: (json['statuses'] as List)
          .map((e) => StatusInfo.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      polling: PollingConfig.fromJson(
        (json['polling'] as Map).cast<String, dynamic>(),
      ),
      driver: driver is Map
          ? DriverConfig.fromJson(driver.cast<String, dynamic>())
          : null,
      currencySymbol: (json['currency'] as Map)['symbol'] as String,
      minAppVersion: json['min_app_version'] as String?,
      modules: (json['modules'] as List).cast<String>(),
    );
  }

  final String deliveryConfirmation;
  final List<String> paymentMethods;
  final List<StatusInfo> statuses;
  final PollingConfig polling;
  final DriverConfig? driver;
  final String currencySymbol;
  final String? minAppVersion;
  final List<String> modules;

  StatusInfo status(String key) {
    for (final status in statuses) {
      if (status.key == key) return status;
    }
    return StatusInfo.unknown(key);
  }

  bool hasModule(String module) => modules.contains(module);

  /// The rows of the status timeline for an order now at [currentKey].
  ///
  /// Sorted by step. Only one final status shows: the current one if the order
  /// has finished, otherwise the first one (the normal end of an order; the
  /// server gives the cancelled status a later step).
  List<StatusInfo> timeline(String currentKey) {
    final sorted = [...statuses]..sort((a, b) => a.step.compareTo(b.step));
    final finals = sorted.where((s) => s.isTerminal).toList();
    final shownFinal = finals.any((s) => s.key == currentKey)
        ? finals.firstWhere((s) => s.key == currentKey)
        : finals.firstOrNull;
    return [
      for (final status in sorted)
        if (!status.isTerminal || status == shownFinal) status,
    ];
  }
}
