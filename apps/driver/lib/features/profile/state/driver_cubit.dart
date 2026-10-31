import 'dart:async';

import 'package:barq_core/barq_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../jobs/data/jobs_repository.dart';
import '../../jobs/data/location_source.dart';
import '../../jobs/data/location_tracker.dart';
import '../data/driver_models.dart';
import '../data/profile_repository.dart';

class DriverState {
  const DriverState({
    this.driver,
    this.loading = true,
    this.error,
    this.switching = false,
    this.switchError,
    this.locationProblem,
  });

  final Driver? driver;
  final bool loading;
  final String? error;

  /// True while going online or offline.
  final bool switching;
  final String? switchError;
  final LocationProblem? locationProblem;

  bool get isOnline => driver?.isOnline ?? false;
}

/// The logged-in driver, shared by every tab. Also runs the location service:
/// while online, and while an active job lasts even if the driver goes offline,
/// because the customer is still following the order.
class DriverCubit extends Cubit<DriverState> {
  DriverCubit({
    required this._repository,
    required this._jobs,
    required this._tracker,
    required this._jobCheckEvery,
    required AuthStore auth,
  }) : super(const DriverState()) {
    _sessionExpired = auth.sessionExpired.listen((_) => reset());
    _jobChanges = _jobs.changes.listen((_) => _checkJob());
  }

  final ProfileRepository _repository;
  final JobsRepository _jobs;
  final LocationTracker _tracker;
  final Duration Function() _jobCheckEvery;
  late final StreamSubscription<void> _sessionExpired;
  late final StreamSubscription<void> _jobChanges;

  /// Not a Poller: this must keep running in the background, where a customer
  /// can cancel the order.
  Timer? _jobCheck;

  Future<void> load() async {
    emit(DriverState(driver: state.driver));
    try {
      final driver = await _repository.me();
      if (driver.isOnline) {
        _tracker.start();
      } else {
        await _trackWhileOnJob();
      }
      emit(DriverState(driver: driver, loading: false));
    } on ApiException catch (e) {
      emit(
        DriverState(driver: state.driver, loading: false, error: e.userMessage),
      );
    }
  }

  void replace(Driver driver) =>
      emit(DriverState(driver: driver, loading: false));

  Future<void> setOnline(bool online) => online ? _goOnline() : _goOffline();

  Future<void> _goOnline() async {
    if (state.switching) return;
    _emitSwitching();
    try {
      await _tracker.sendNow();
      final driver = await _repository.setOnline(true);
      _stopJobCheck();
      _tracker.start();
      emit(DriverState(driver: driver, loading: false));
    } on LocationFailure catch (e) {
      _emitFailure(locationProblem: e.problem);
    } on ApiException catch (e) {
      _emitFailure(message: e.userMessage);
    }
  }

  Future<void> _goOffline() async {
    if (state.switching) return;
    _emitSwitching();
    try {
      final driver = await _repository.setOnline(false);
      await _trackWhileOnJob();
      emit(DriverState(driver: driver, loading: false));
    } on ApiException catch (e) {
      _emitFailure(message: e.userMessage);
    }
  }

  /// Logout or an ended session: nothing may keep sending.
  Future<void> reset() async {
    _stopJobCheck();
    await _tracker.stop();
    emit(const DriverState());
  }

  /// An offline driver with a job keeps sending until the job ends.
  Future<void> _trackWhileOnJob() async {
    if (await _hasJob()) {
      _tracker.start();
      _jobCheck ??= Timer.periodic(_jobCheckEvery(), (_) => _checkJob());
    } else {
      _stopJobCheck();
      await _tracker.stop();
    }
  }

  /// Delivered or cancelled: only matters while offline.
  Future<void> _checkJob() async {
    if (state.isOnline || _jobCheck == null) return;
    if (!await _hasJob()) {
      _stopJobCheck();
      await _tracker.stop();
    }
  }

  /// With no answer the job may still be running, so it counts as a yes.
  Future<bool> _hasJob() async {
    try {
      return await _jobs.current() != null;
    } on ApiException catch (e) {
      debugPrint('Current job not checked: $e');
      return true;
    }
  }

  void _stopJobCheck() {
    _jobCheck?.cancel();
    _jobCheck = null;
  }

  void _emitSwitching() =>
      emit(DriverState(driver: state.driver, loading: false, switching: true));

  void _emitFailure({String? message, LocationProblem? locationProblem}) =>
      emit(
        DriverState(
          driver: state.driver,
          loading: false,
          switchError: message,
          locationProblem: locationProblem,
        ),
      );

  @override
  Future<void> close() async {
    _stopJobCheck();
    await _sessionExpired.cancel();
    await _jobChanges.cancel();
    await _tracker.stop();
    return super.close();
  }
}
