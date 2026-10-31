import 'dart:async';

import 'package:barq_core/barq_core.dart';
import 'package:flutter/foundation.dart';

import 'location_source.dart';

/// Sends the driver's location while online.
///
/// Every reading waits in [_waiting] until a send succeeds, so a dead network
/// loses nothing: the points leave later as `points[]`. The server's minimum
/// time between requests decides how often a send may happen.
class LocationTracker {
  LocationTracker({
    required this._api,
    required this._source,
    required this._minIntervalSeconds,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  /// From the API: `points[]` takes at most 100.
  static const maxBatch = 100;

  /// About 80 minutes of readings at 3 seconds. Beyond it the oldest go.
  static const maxWaiting = 1600;
  static const _defaultIntervalSeconds = 3;

  final ApiClient _api;
  final LocationSource _source;
  final int? Function() _minIntervalSeconds;
  final DateTime Function() _now;
  final List<LocationPoint> _waiting = [];
  StreamSubscription<LocationPoint>? _watching;
  DateTime? _lastSend;
  bool _sending = false;

  int get _intervalSeconds => _minIntervalSeconds() ?? _defaultIntervalSeconds;

  bool get isTracking => _watching != null;
  int get waitingCount => _waiting.length;

  /// The server needs a fresh location before the driver can go online.
  Future<void> sendNow() async {
    final point = await _source.current();
    await _api.post('/driver/location', body: point.toJson());
    _lastSend = _now();
  }

  void start() {
    if (isTracking) return;
    _watching = _source
        .watch(intervalSeconds: _intervalSeconds)
        .listen(
          add,
          onError: (Object e) => debugPrint('Location stream failed: $e'),
        );
  }

  Future<void> stop() async {
    await _watching?.cancel();
    _watching = null;
    _lastSend = null;
    await _flush();
    _waiting.clear();
  }

  /// One reading from the stream.
  void add(LocationPoint point) {
    _waiting.add(point);
    if (_waiting.length > maxWaiting) _waiting.removeAt(0);
    if (_canSend) _flush();
  }

  bool get _canSend {
    final last = _lastSend;
    return last == null ||
        _now().difference(last).inSeconds >= _intervalSeconds;
  }

  Future<void> _flush() async {
    if (_sending || _waiting.isEmpty) return;
    _sending = true;
    final count = _waiting.length < maxBatch ? _waiting.length : maxBatch;
    final batch = _waiting.take(count).toList();
    _lastSend = _now();
    try {
      await _api.post('/driver/location', body: _bodyOf(batch));
      _waiting.removeRange(0, count);
    } on ApiException catch (e) {
      // A refused batch would block everything behind it, forever.
      if (e.code == 'validation_failed') _waiting.removeRange(0, count);
      debugPrint('Location not sent, $count points: $e');
    } finally {
      _sending = false;
    }
  }

  Map<String, Object?> _bodyOf(List<LocationPoint> batch) => batch.length == 1
      ? batch.single.toJson()
      : {
          'points': [for (final point in batch) point.toJson()],
        };
}
