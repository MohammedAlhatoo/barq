import 'package:barq_core/barq_core.dart';

/// A store or a home on the job.
class JobPlace {
  const JobPlace({this.label, this.details, this.lat, this.lng});

  factory JobPlace.fromJson(Map<String, dynamic> json) => JobPlace(
    label: json['label'] as String?,
    details: json['details'] as String?,
    lat: (json['lat'] as num?)?.toDouble(),
    lng: (json['lng'] as num?)?.toDouble(),
  );

  final String? label;
  final String? details;
  final double? lat;
  final double? lng;

  bool get hasLocation => lat != null && lng != null;
}

/// The next step, decided by the server. The app never picks a step itself.
class NextAction {
  const NextAction({
    required this.action,
    required this.to,
    required this.label,
    required this.style,
    required this.requires,
    this.geofenceMeters,
    this.confirm,
  });

  factory NextAction.fromJson(Map<String, dynamic> json) => NextAction(
    action: json['action'] as String,
    to: json['to'] as String,
    label: json['label'] as String,
    style: json['style'] as String,
    requires: (json['requires'] as List).cast<String>(),
    geofenceMeters: json['geofence_meters'] as int?,
    confirm: json['confirm'] as String?,
  );

  static const deliverAction = 'deliver';

  final String action;
  final String to;
  final String label;
  final String style;
  final List<String> requires;
  final int? geofenceMeters;
  final String? confirm;

  bool get isDeliver => action == deliverAction;

  bool get needsPhoto => requires.any((item) => item.contains('photo'));

  /// True when [e] means "too far from the place". openapi.json names no code
  /// for this, so the first run on the sandbox must confirm it.
  bool isTooFar(ApiException e) =>
      geofenceMeters != null &&
      e.status == 422 &&
      (e.code == 'out_of_zone' || distanceIn(e) != null);

  /// How far the driver is, when the server says so.
  static int? distanceIn(ApiException e) {
    for (final entry in (e.details ?? const {}).entries) {
      final value = entry.value;
      if (entry.key.contains('distance') && value is num) return value.round();
    }
    return null;
  }
}

class JobItem {
  const JobItem({required this.name, required this.qty});

  factory JobItem.fromJson(Map<String, dynamic> json) =>
      JobItem(name: json['name'] as String, qty: json['qty'] as int);

  final String name;
  final int qty;
}

/// `DriverOrder` from the API. Customer details arrive only after accepting.
class Job {
  const Job({
    required this.id,
    required this.code,
    required this.statusKey,
    required this.pickup,
    required this.dropoff,
    required this.collect,
    required this.earning,
    this.distanceKm,
    this.distanceToPickupKm,
    this.itemsCount,
    this.items = const [],
    this.customerName,
    this.customerPhone,
    this.vendorName,
    this.vendorPhone,
    this.nextAction,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map?;
    final vendor = json['vendor'] as Map?;
    final next = json['next_action'] as Map?;
    return Job(
      id: json['id'] as int,
      code: json['code'] as String,
      statusKey: (json['status'] as Map)['key'] as String,
      pickup: JobPlace.fromJson((json['pickup'] as Map).cast()),
      dropoff: JobPlace.fromJson((json['dropoff'] as Map).cast()),
      collect: Money.fromJson(
        ((json['payment'] as Map)['collect'] as Map).cast(),
      ),
      earning: Money.fromJson((json['earning'] as Map).cast()),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      distanceToPickupKm: (json['distance_to_pickup_km'] as num?)?.toDouble(),
      itemsCount: json['items_count'] as int?,
      items: [
        for (final item in json['items'] as List? ?? const [])
          JobItem.fromJson((item as Map).cast()),
      ],
      customerName: customer?['name'] as String?,
      customerPhone: customer?['phone'] as String?,
      vendorName: vendor?['name'] as String?,
      vendorPhone: vendor?['phone'] as String?,
      nextAction: next == null ? null : NextAction.fromJson(next.cast()),
    );
  }

  final int id;
  final String code;
  final String statusKey;
  final JobPlace pickup;
  final JobPlace dropoff;
  final Money collect;
  final Money earning;
  final double? distanceKm;
  final double? distanceToPickupKm;
  final int? itemsCount;
  final List<JobItem> items;
  final String? customerName;
  final String? customerPhone;
  final String? vendorName;
  final String? vendorPhone;
  final NextAction? nextAction;

  String get storeName => vendorName ?? pickup.label ?? '';

  /// True until the order leaves the store: the first row of the timeline.
  bool get isHeadingToStore => statusKey == OrderTimelines.tracking.first;
}
