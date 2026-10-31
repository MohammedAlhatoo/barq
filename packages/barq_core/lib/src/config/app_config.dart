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
    required this.supportPhone,
    required this.termsUrl,
    this.cartMaxLines = 50,
    this.cartMaxQty = 99,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    final driver = json['driver'];
    final project = json['project'];
    final modules = json['modules_config'];
    final catalog = modules is Map ? modules['catalog'] : null;
    final cart = catalog is Map ? catalog['cart'] : null;
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
      supportPhone: project is Map ? project['support_phone'] as String? : null,
      termsUrl: json['terms_url'] as String?,
      cartMaxLines: cart is Map ? cart['max_lines'] as int? ?? 50 : 50,
      cartMaxQty: cart is Map ? cart['max_qty'] as int? ?? 99 : 99,
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
  final String? supportPhone;
  final String? termsUrl;

  /// From `modules_config.catalog.cart`.
  final int cartMaxLines;
  final int cartMaxQty;

  StatusInfo status(String key) {
    for (final status in statuses) {
      if (status.key == key) return status;
    }
    return StatusInfo.unknown(key);
  }

  bool hasModule(String module) => modules.contains(module);

  /// True when [appVersion] (like "1.0.0") is older than [minAppVersion].
  bool requiresUpdate(String appVersion) {
    final minimum = minAppVersion;
    if (minimum == null) return false;
    final current = _versionParts(appVersion);
    final required = _versionParts(minimum);
    for (var i = 0; i < 3; i++) {
      if (current[i] != required[i]) return current[i] < required[i];
    }
    return false;
  }

  /// Always three numbers: "1.2" becomes [1, 2, 0].
  static List<int> _versionParts(String version) {
    final parts = version.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    return [...parts, 0, 0, 0].take(3).toList();
  }

  /// The rows of the status timeline for an order now at [currentKey].
  ///
  /// [keys] are the screen's rows, from OrderTimelines. A finished order whose
  /// status is not in [keys] (cancelled) replaces the last row, so it never
  /// looks like it reached the normal end.
  List<StatusInfo> timeline(List<String> keys, String currentKey) {
    final rows = [for (final key in keys) status(key)];
    final current = status(currentKey);
    if (current.isTerminal && !keys.contains(currentKey)) {
      rows[rows.length - 1] = current;
    }
    return rows;
  }

  /// The row to highlight: the last row the order has reached. A status with
  /// no row of its own stays on the row before it. -1 means none reached yet.
  int timelineIndex(List<StatusInfo> rows, String currentKey) {
    final step = status(currentKey).step;
    return rows.lastIndexWhere((row) => row.step <= step);
  }
}
