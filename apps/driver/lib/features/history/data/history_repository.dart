import 'package:barq_core/barq_core.dart';

/// `OrderSummary`. It has no store name and no fare, unlike the design.
class HistoryOrder {
  const HistoryOrder({
    required this.id,
    required this.code,
    required this.statusKey,
    required this.createdAt,
    required this.total,
    this.completedAt,
    this.dropoffLabel,
  });

  factory HistoryOrder.fromJson(Map<String, dynamic> json) {
    final completed = json['completed_at'] as String?;
    return HistoryOrder(
      id: json['id'] as int,
      code: json['code'] as String,
      statusKey: (json['status'] as Map)['key'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      total: Money.fromJson((json['total'] as Map).cast()),
      completedAt: completed == null ? null : DateTime.parse(completed),
      dropoffLabel: (json['dropoff'] as Map)['label'] as String?,
    );
  }

  final int id;
  final String code;
  final String statusKey;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Money total;
  final String? dropoffLabel;

  /// The end of the normal timeline. Any other finished order was cancelled.
  bool get isDelivered => statusKey == OrderTimelines.tracking.last;
}

abstract class HistoryRepository {
  Future<Paged<HistoryOrder>> history({int? page});
}

class ApiHistoryRepository implements HistoryRepository {
  ApiHistoryRepository(this._api);

  final ApiClient _api;

  @override
  Future<Paged<HistoryOrder>> history({int? page}) async {
    final result = await _api.getPaged(
      '/driver/orders/history',
      query: {'page': ?page},
    );
    return Paged(
      items: [
        for (final item in result.items)
          HistoryOrder.fromJson((item as Map).cast()),
      ],
      nextPage: result.nextPage,
      total: result.total,
    );
  }
}
