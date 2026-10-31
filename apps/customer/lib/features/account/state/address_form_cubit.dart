import 'dart:async';

import 'package:barq_core/barq_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/data/auth_models.dart';
import '../../auth/data/location_repository.dart';
import '../data/account_repository.dart';

enum AddressKind { home, work, other }

/// Only the server knows the service area, and it answers when the address is
/// saved. So a point that was not saved yet is [unknown].
enum AddressZone { unknown, inside, outside }

class AddressFormState {
  const AddressFormState({
    required this.lat,
    required this.lng,
    this.kind = AddressKind.home,
    this.customLabel = '',
    this.details = '',
    this.isDefault = true,
    this.zone = AddressZone.unknown,
    this.mapMoves = 0,
    this.locating = false,
    this.locationProblem,
    this.locationFailed = false,
    this.saving = false,
    this.error,
    this.saved,
  });

  /// The map's center, which is the address.
  final double lat;
  final double lng;
  final AddressKind kind;

  /// The name typed for [AddressKind.other].
  final String customLabel;
  final String details;
  final bool isDefault;
  final AddressZone zone;

  /// Goes up when the map must jump to [lat] and [lng].
  final int mapMoves;
  final bool locating;
  final LocationProblem? locationProblem;
  final bool locationFailed;
  final bool saving;
  final String? error;
  final SavedAddress? saved;

  AddressFormState copyWith({
    double? lat,
    double? lng,
    AddressKind? kind,
    String? customLabel,
    String? details,
    bool? isDefault,
    AddressZone? zone,
    int? mapMoves,
    bool? locating,
    LocationProblem? locationProblem,
    bool? locationFailed,
    bool? saving,
    String? error,
    SavedAddress? saved,
  }) => AddressFormState(
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    kind: kind ?? this.kind,
    customLabel: customLabel ?? this.customLabel,
    details: details ?? this.details,
    isDefault: isDefault ?? this.isDefault,
    zone: zone ?? this.zone,
    mapMoves: mapMoves ?? this.mapMoves,
    locating: locating ?? this.locating,
    locationProblem: locationProblem,
    locationFailed: locationFailed ?? false,
    saving: saving ?? this.saving,
    error: error,
    saved: saved ?? this.saved,
  );
}

class AddressFormCubit extends Cubit<AddressFormState> {
  AddressFormCubit({
    required this._repository,
    required this._location,
    required this._homeLabel,
    required this._workLabel,
    required this._otherLabel,
    this.existing,
  }) : super(
         _firstState(
           existing,
           homeLabel: _homeLabel,
           workLabel: _workLabel,
           otherLabel: _otherLabel,
         ),
       );

  /// Where the map opens with no address and no GPS: the middle of the area
  /// the sandbox serves. It only places the map; the server checks the point.
  static const startLat = 31.45;
  static const startLng = 34.39;

  /// The map stays usable while it waits, but a phone with no fix must not
  /// spin forever.
  static const _gpsTimeout = Duration(seconds: 8);

  final AccountRepository _repository;
  final LocationRepository _location;
  final String _homeLabel;
  final String _workLabel;
  final String _otherLabel;

  /// Null when adding a new address.
  final SavedAddress? existing;
  bool _userMoved = false;

  static AddressFormState _firstState(
    SavedAddress? address, {
    required String homeLabel,
    required String workLabel,
    required String otherLabel,
  }) {
    if (address == null) {
      return const AddressFormState(lat: startLat, lng: startLng);
    }
    final label = address.label ?? '';
    final kind = label == homeLabel
        ? AddressKind.home
        : label == workLabel
        ? AddressKind.work
        : AddressKind.other;
    return AddressFormState(
      lat: address.lat,
      lng: address.lng,
      kind: kind,
      customLabel: kind == AddressKind.other && label != otherLabel
          ? label
          : '',
      details: address.details ?? '',
      isDefault: address.isDefault,
      // The server already accepted this point.
      zone: AddressZone.inside,
    );
  }

  /// A request can end after the user left the screen.
  @override
  void emit(AddressFormState state) {
    if (!isClosed) super.emit(state);
  }

  void kindChanged(AddressKind kind) => emit(state.copyWith(kind: kind));

  void customLabelChanged(String label) =>
      emit(state.copyWith(customLabel: label));

  void detailsChanged(String details) => emit(state.copyWith(details: details));

  void defaultChanged(bool value) => emit(state.copyWith(isDefault: value));

  /// The user moved the map.
  void pointChanged(double lat, double lng) {
    _userMoved = true;
    emit(state.copyWith(lat: lat, lng: lng, zone: AddressZone.unknown));
  }

  /// A new address opens on the user's position when the phone knows it. The
  /// user did not ask for this, so a failure stays silent, and a late fix does
  /// not pull the map away from where the user already moved it.
  Future<void> start() async {
    if (existing != null) return;
    try {
      final point = await _location.current().timeout(_gpsTimeout);
      if (!_userMoved) _moveTo(point);
    } on Exception catch (e) {
      debugPrint('New address opens without GPS: $e');
    }
  }

  /// The locate button.
  Future<void> locate() async {
    if (state.locating) return;
    emit(state.copyWith(locating: true));
    try {
      final point = await _location.current().timeout(_gpsTimeout);
      emit(state.copyWith(locating: false));
      _moveTo(point);
    } on LocationException catch (e) {
      emit(state.copyWith(locating: false, locationProblem: e.problem));
    } on Exception catch (e) {
      debugPrint('Location failed: $e');
      emit(state.copyWith(locating: false, locationFailed: true));
    }
  }

  void _moveTo(({double lat, double lng}) point) => emit(
    state.copyWith(
      lat: point.lat,
      lng: point.lng,
      zone: AddressZone.unknown,
      mapMoves: state.mapMoves + 1,
    ),
  );

  String get _label => switch (state.kind) {
    AddressKind.home => _homeLabel,
    AddressKind.work => _workLabel,
    AddressKind.other =>
      state.customLabel.trim().isEmpty ? _otherLabel : state.customLabel.trim(),
  };

  Future<void> save() async {
    if (state.saving) return;
    emit(state.copyWith(saving: true));
    final details = state.details.trim();
    try {
      final saved = await _repository.saveAddress(
        id: existing?.id,
        label: _label,
        lat: state.lat,
        lng: state.lng,
        details: details.isEmpty ? null : details,
        isDefault: state.isDefault,
      );
      emit(
        state.copyWith(saving: false, zone: AddressZone.inside, saved: saved),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          saving: false,
          zone: e.code == 'out_of_zone' ? AddressZone.outside : null,
          error: e.messageAr,
        ),
      );
    }
  }
}
