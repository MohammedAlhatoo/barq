import 'dart:async';

/// Counts down to a moment set by the server. It reads the clock on every tick,
/// so it stays right after the app was in the background.
class Countdown {
  Countdown({required this._onTick, required this._onDone});

  final void Function(int secondsLeft) _onTick;
  final void Function() _onDone;
  Timer? _timer;

  void start(int seconds) {
    stop();
    final end = DateTime.now().add(Duration(seconds: seconds));
    _onTick(seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final left = end.difference(DateTime.now()).inSeconds;
      if (left > 0) {
        _onTick(left);
      } else {
        stop();
        _onTick(0);
        _onDone();
      }
    });
  }

  void stop() => _timer?.cancel();
}

/// "07:12". Minutes keep counting past 60, because the server sets the length.
String formatCountdown(int seconds) {
  final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
  final rest = (seconds % 60).toString().padLeft(2, '0');
  return '$minutes:$rest';
}
