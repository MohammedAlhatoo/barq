import 'dart:async';

import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum SystemIssue { offline, updateRequired, maintenance, sessionExpired }

class SystemState {
  const SystemState({this.issue, this.checking = false});

  /// The problem covering the app. Null means everything is fine.
  final SystemIssue? issue;

  /// True while "إعادة المحاولة" is asking the server.
  final bool checking;
}

/// Watches for problems that stop the whole app, whichever screen is open.
class SystemCubit extends Cubit<SystemState> {
  SystemCubit({
    required ApiClient api,
    required AuthStore auth,
    required this._config,
    required this._network,
    required this._appVersion,
    SystemIssue? initial,
  }) : super(SystemState(issue: initial)) {
    _subscriptions.addAll([
      api.systemErrors.listen(_onServerError),
      auth.sessionExpired.listen((_) => report(SystemIssue.sessionExpired)),
      _network.onlineChanges.listen(_onOnlineChanged),
    ]);
  }

  final ConfigStore _config;
  final NetworkMonitor _network;
  final String _appVersion;
  final List<StreamSubscription<Object?>> _subscriptions = [];

  void report(SystemIssue issue) {
    // A forced update stays until the app is updated.
    if (state.issue == SystemIssue.updateRequired) return;
    emit(SystemState(issue: issue));
  }

  void clear() => emit(const SystemState());

  /// Clears the issue only if the server and the network agree.
  Future<void> retry() async {
    if (state.checking) return;
    final issue = state.issue;
    emit(SystemState(issue: issue, checking: true));
    if (!await _network.isOnline()) {
      emit(SystemState(issue: issue));
      return;
    }
    try {
      await _config.load();
      final mustUpdate =
          _config.isLoaded && _config.config.requiresUpdate(_appVersion);
      emit(mustUpdate ? SystemState(issue: issue) : const SystemState());
    } on ApiException {
      emit(SystemState(issue: state.issue));
    }
  }

  void _onServerError(ApiException error) => report(
    error.isUpdateRequired
        ? SystemIssue.updateRequired
        : SystemIssue.maintenance,
  );

  void _onOnlineChanged(bool online) {
    if (!online) {
      if (state.issue == null) report(SystemIssue.offline);
    } else if (state.issue == SystemIssue.offline) {
      clear();
    }
  }

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    return super.close();
  }
}
