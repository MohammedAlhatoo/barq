import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_models.dart';
import '../data/auth_repository.dart';
import '../data/location_repository.dart';

class WelcomeState {
  const WelcomeState({
    this.name = '',
    this.address,
    this.locating = false,
    this.locationProblem,
    this.outOfZone = false,
    this.locationError,
    this.notifications = true,
    this.saving = false,
    this.error,
    this.done = false,
  });

  final String name;

  /// The address the server accepted. Null until then.
  final SavedAddress? address;
  final bool locating;
  final LocationProblem? locationProblem;
  final bool outOfZone;

  /// Server message about the location, such as out_of_zone.
  final String? locationError;
  final bool notifications;
  final bool saving;
  final String? error;
  final bool done;

  /// `PUT /me` needs at least 2 letters.
  bool get canFinish => name.trim().length >= 2 && !saving;

  WelcomeState copyWith({
    String? name,
    SavedAddress? address,
    bool? locating,
    LocationProblem? locationProblem,
    bool? outOfZone,
    String? locationError,
    bool? notifications,
    bool? saving,
    String? error,
    bool? done,
  }) => WelcomeState(
    name: name ?? this.name,
    address: address ?? this.address,
    locating: locating ?? this.locating,
    locationProblem: locationProblem,
    outOfZone: outOfZone ?? this.outOfZone,
    locationError: locationError,
    notifications: notifications ?? this.notifications,
    saving: saving ?? this.saving,
    error: error,
    done: done ?? this.done,
  );
}

class WelcomeCubit extends Cubit<WelcomeState> {
  WelcomeCubit({required this._repository, required this._location})
    : super(const WelcomeState());

  final AuthRepository _repository;
  final LocationRepository _location;

  void nameChanged(String name) => emit(_keepMessages(name: name));

  void notificationsChanged(bool enabled) =>
      emit(_keepMessages(notifications: enabled));

  /// The server decides whether the point is in the service area, so the
  /// address is saved as soon as we have it. A second try edits the same one.
  Future<void> locate(String label) async {
    if (state.locating) return;
    emit(state.copyWith(locating: true));
    try {
      final point = await _location.current();
      final existing = state.address;
      final address = existing == null
          ? await _repository.addAddress(
              label: label,
              lat: point.lat,
              lng: point.lng,
            )
          : await _repository.updateAddress(
              id: existing.id,
              label: label,
              lat: point.lat,
              lng: point.lng,
            );
      emit(state.copyWith(address: address, locating: false, outOfZone: false));
    } on LocationException catch (e) {
      emit(state.copyWith(locating: false, locationProblem: e.problem));
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          locating: false,
          outOfZone: e.code == 'out_of_zone',
          locationError: e.messageAr,
        ),
      );
    }
  }

  Future<void> finish(String locale) async {
    if (!state.canFinish) return;
    emit(state.copyWith(saving: true));
    try {
      await _repository.updateProfile(name: state.name.trim(), locale: locale);
      await _repository.setNotificationsEnabled(state.notifications);
      emit(state.copyWith(saving: false, done: true));
    } on ApiException catch (e) {
      emit(state.copyWith(saving: false, error: e.messageAr));
    }
  }

  WelcomeState _keepMessages({String? name, bool? notifications}) =>
      WelcomeState(
        name: name ?? state.name,
        address: state.address,
        locating: state.locating,
        locationProblem: state.locationProblem,
        outOfZone: state.outOfZone,
        locationError: state.locationError,
        notifications: notifications ?? state.notifications,
        saving: state.saving,
        error: state.error,
      );
}
