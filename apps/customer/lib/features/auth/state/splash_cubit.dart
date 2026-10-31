import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../system/state/system_cubit.dart';
import '../data/auth_repository.dart';

enum SplashStatus { loading, goHome, goWelcome, goOnboarding, offline, failed }

class SplashState {
  const SplashState(this.status, {this.message});

  final SplashStatus status;

  /// Set for [SplashStatus.failed].
  final String? message;

  bool get isStopped =>
      status == SplashStatus.offline || status == SplashStatus.failed;
}

/// Loads the config, then decides where the app starts.
class SplashCubit extends Cubit<SplashState> {
  SplashCubit({
    required this._config,
    required this._auth,
    required this._repository,
    required this._system,
    required this._appVersion,
  }) : super(const SplashState(SplashStatus.loading));

  final ConfigStore _config;
  final AuthStore _auth;
  final AuthRepository _repository;
  final SystemCubit _system;
  final String _appVersion;

  Future<void> start() async {
    emit(const SplashState(SplashStatus.loading));
    try {
      await _config.load();
    } on ApiException catch (e) {
      emit(
        e.isNetwork
            ? const SplashState(SplashStatus.offline)
            : SplashState(SplashStatus.failed, message: e.messageAr),
      );
      return;
    }
    if (_config.config.requiresUpdate(_appVersion)) {
      _system.report(SystemIssue.updateRequired);
      emit(const SplashState(SplashStatus.failed));
      return;
    }
    emit(SplashState(await _destination()));
  }

  Future<SplashStatus> _destination() async {
    if (!_auth.isLoggedIn) return SplashStatus.goOnboarding;
    try {
      final name = await _repository.currentName();
      final hasName = name != null && name.trim().isNotEmpty;
      return hasName ? SplashStatus.goHome : SplashStatus.goWelcome;
    } on ApiException catch (e) {
      // 401 shows "انتهت الجلسة" by itself. Otherwise the token is still good.
      return e.status == 401 ? SplashStatus.failed : SplashStatus.goHome;
    }
  }
}
