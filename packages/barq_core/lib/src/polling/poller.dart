import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';

/// Calls [tick] repeatedly while the app is open.
///
/// - [tick] may return next_poll_seconds; otherwise the default is used.
/// - A new tick never starts before the previous one ends.
/// - Stops in the background and ticks once on return to the app.
class Poller {
  Poller({required this._tick, required this._defaultSeconds});

  /// The API forbids polling faster than this.
  static const minSeconds = 5;

  final Future<int?> Function() _tick;
  final int _defaultSeconds;
  AppLifecycleListener? _lifecycle;
  Timer? _timer;
  bool _started = false;
  bool _inBackground = false;
  bool _ticking = false;

  /// Starts waiting. The screen makes its own first request.
  void start() {
    if (_started) return;
    _started = true;
    _lifecycle = AppLifecycleListener(
      onHide: _onBackground,
      onShow: _onForeground,
    );
    _schedule(_defaultSeconds);
  }

  void stop() {
    _started = false;
    _timer?.cancel();
    _lifecycle?.dispose();
    _lifecycle = null;
  }

  void dispose() => stop();

  void _onBackground() {
    _inBackground = true;
    _timer?.cancel();
  }

  void _onForeground() {
    _inBackground = false;
    _run();
  }

  bool get _canRun => _started && !_inBackground;

  void _schedule(int seconds) {
    _timer?.cancel();
    if (!_canRun) return;
    _timer = Timer(Duration(seconds: max(seconds, minSeconds)), _run);
  }

  Future<void> _run() async {
    if (!_canRun || _ticking) return;
    _ticking = true;
    int? nextSeconds;
    try {
      nextSeconds = await _tick();
    } on Object catch (e) {
      debugPrint('Poller tick failed: $e');
    }
    _ticking = false;
    _schedule(nextSeconds ?? _defaultSeconds);
  }
}
