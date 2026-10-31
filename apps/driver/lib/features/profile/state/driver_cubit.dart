import 'dart:async';

import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

/// The logged-in driver, shared by every tab. Also ties the location service
/// to the online switch: it runs only while the driver is online.
class DriverCubit extends Cubit<DriverState> {
  DriverCubit({
    required this._repository,
    required this._tracker,
    required AuthStore auth,
  }) : super(const DriverState()) {
    _sessionExpired = auth.sessionExpired.listen((_) => reset());
  }

  final ProfileRepository _repository;
  final LocationTracker _tracker;
  late final StreamSubscription<void> _sessionExpired;

  Future<void> load() async {
    emit(DriverState(driver: state.driver));
    try {
      final driver = await _repository.me();
      if (driver.isOnline) _tracker.start();
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
      await _tracker.stop();
      emit(DriverState(driver: driver, loading: false));
    } on ApiException catch (e) {
      _emitFailure(message: e.userMessage);
    }
  }

  /// Logout or an ended session: nothing may keep sending.
  Future<void> reset() async {
    await _tracker.stop();
    emit(const DriverState());
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
    await _sessionExpired.cancel();
    await _tracker.stop();
    return super.close();
  }
}
