import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/locale_cubit.dart';
import '../data/profile_repository.dart';
import 'driver_cubit.dart';

class SettingsState {
  const SettingsState({
    required this.vehicleType,
    required this.locale,
    this.saving = false,
    this.error,
    this.saved = false,
  });

  final String vehicleType;
  final String locale;
  final bool saving;
  final String? error;
  final bool saved;

  SettingsState copyWith({String? vehicleType, String? locale}) =>
      SettingsState(
        vehicleType: vehicleType ?? this.vehicleType,
        locale: locale ?? this.locale,
      );
}

/// The vehicle and language sheet. The plate number is not here: the API
/// does not accept it.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required this._repository,
    required this._driver,
    required LocaleCubit localeCubit,
    required String vehicleType,
    required String locale,
  }) : _locale = localeCubit,
       super(SettingsState(vehicleType: vehicleType, locale: locale));

  final ProfileRepository _repository;
  final DriverCubit _driver;
  final LocaleCubit _locale;

  void chooseVehicle(String vehicleType) =>
      emit(state.copyWith(vehicleType: vehicleType));

  void chooseLocale(String locale) => emit(state.copyWith(locale: locale));

  Future<void> save() async {
    if (state.saving) return;
    emit(
      SettingsState(
        vehicleType: state.vehicleType,
        locale: state.locale,
        saving: true,
      ),
    );
    try {
      final driver = await _repository.update(
        vehicleType: state.vehicleType,
        locale: state.locale,
      );
      _driver.replace(driver);
      await _locale.change(state.locale);
      emit(
        SettingsState(
          vehicleType: state.vehicleType,
          locale: state.locale,
          saved: true,
        ),
      );
    } on ApiException catch (e) {
      emit(
        SettingsState(
          vehicleType: state.vehicleType,
          locale: state.locale,
          error: e.userMessage,
        ),
      );
    }
  }
}
