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
  /// Sorted by step, one row per step (the current status wins its step).
  /// Only one final status shows: the current one if the order has finished,
  /// otherwise the final status with the highest step.
  List<StatusInfo> timeline(String currentKey) {
    final sorted = [...statuses]..sort((a, b) => a.step.compareTo(b.step));
    final rows = <int, StatusInfo>{};
    for (final status in sorted) {
      if (status.isTerminal) continue;
      if (status.key == currentKey || !rows.containsKey(status.step)) {
        rows[status.step] = status;
      }
    }

    final finals = sorted.where((s) => s.isTerminal).toList();
    if (finals.isNotEmpty) {
      var shown = finals.first;
      for (final status in finals) {
        if (status.key == currentKey) {
          shown = status;
          break;
        }
        if (status.step > shown.step) shown = status;
      }
      rows[shown.step] = shown;
    }
    return rows.values.toList()..sort((a, b) => a.step.compareTo(b.step));
  }
}
