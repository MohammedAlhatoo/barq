import 'package:barq_core/barq_core.dart';

class DriverNotification {
  const DriverNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.data,
    required this.createdAt,
    this.readAt,
  });

  factory DriverNotification.fromJson(Map<String, dynamic> json) {
    final read = json['read_at'] as String?;
    return DriverNotification(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      data: (json['data'] as Map).cast(),
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: read == null ? null : DateTime.parse(read),
    );
  }

  final int id;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime? readAt;

  bool get isUnread => readAt == null;
}

/// The order a notification is about, if any.
int? orderIdOf(Map<String, dynamic> data) =>
    int.tryParse('${data['order_id']}');

abstract class NotificationsRepository {
  Future<Paged<DriverNotification>> list({int? page});
  Future<void> readAll();
  Future<void> opened(int id);
}

class ApiNotificationsRepository implements NotificationsRepository {
  ApiNotificationsRepository(this._api);

  final ApiClient _api;

  @override
  Future<Paged<DriverNotification>> list({int? page}) async {
    final result = await _api.getPaged(
      '/driver/notifications',
      query: {'page': ?page},
    );
    return Paged(
      items: [
        for (final item in result.items)
          DriverNotification.fromJson((item as Map).cast()),
      ],
      nextPage: result.nextPage,
      total: result.total,
    );
  }

  @override
  Future<void> readAll() => _api.post('/driver/notifications/read-all');

  @override
  Future<void> opened(int id) => _api.post('/driver/notifications/$id/opened');
}
