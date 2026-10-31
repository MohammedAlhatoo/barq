import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../system/state/system_cubit.dart';

enum SplashStatus { loading, goJobs, goLogin, offline, failed }

class SplashState {
  const SplashState(this.status, {this.message});

  final SplashStatus status;

  /// Set for [SplashStatus.failed].
  final String? message;

  bool get isStopped =>
      status == SplashStatus.offline || status == SplashStatus.failed;
}

/// Loads the config, then opens the jobs or the login.
class SplashCubit extends Cubit<SplashState> {
  SplashCubit({
    required this._config,
    required this._auth,
    required this._system,
    required this._appVersion,
  }) : super(const SplashState(SplashStatus.loading));

  final ConfigStore _config;
  final AuthStore _auth;
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
    emit(
      SplashState(
        _auth.isLoggedIn ? SplashStatus.goJobs : SplashStatus.goLogin,
      ),
    );
  }
}
