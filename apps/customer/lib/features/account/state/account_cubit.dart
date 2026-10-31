import 'dart:async';

import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/account_models.dart';
import '../data/account_repository.dart';

class AccountState {
  const AccountState({
    this.loading = true,
    this.profile,
    this.orders,
    this.addresses,
    this.unread,
    this.error,
    this.loggingOut = false,
    this.logoutError,
  });

  final bool loading;
  final Profile? profile;

  /// The numbers on the card. Null hides them.
  final int? orders;
  final int? addresses;
  final int? unread;
  final String? error;
  final bool loggingOut;
  final String? logoutError;
}

class AccountCubit extends Cubit<AccountState> {
  AccountCubit(this._repository) : super(const AccountState()) {
    _changes = _repository.changes.listen((_) => _refresh());
  }

  final AccountRepository _repository;
  late final StreamSubscription<void> _changes;

  /// Answers of an older load are ignored.
  int _request = 0;

  /// A request can end after the user left the screen.
  @override
  void emit(AccountState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> load() async {
    emit(const AccountState());
    await _refresh();
  }

  /// Keeps the current content on screen while it loads.
  Future<void> _refresh() async {
    final request = ++_request;
    try {
      final profile = await _repository.profile();
      final results = await Future.wait([
        _repository.ordersCount(),
        _repository.unreadNotifications(),
      ]);
      final addresses = await _addressCount();
      if (request != _request) return;
      emit(
        AccountState(
          loading: false,
          profile: profile,
          orders: results[0],
          unread: results[1],
          addresses: addresses,
        ),
      );
    } on ApiException catch (e) {
      if (request != _request) return;
      emit(AccountState(loading: false, error: e.messageAr));
    }
  }

  Future<int?> _addressCount() async {
    try {
      return (await _repository.addresses()).length;
    } on ApiException {
      return null;
    }
  }

  /// On success the login screen opens by itself.
  Future<void> logout() async {
    if (state.loggingOut) return;
    emit(_withLogout(loggingOut: true));
    try {
      await _repository.logout();
    } on ApiException catch (e) {
      emit(_withLogout(logoutError: e.messageAr));
    }
  }

  AccountState _withLogout({bool loggingOut = false, String? logoutError}) =>
      AccountState(
        loading: state.loading,
        profile: state.profile,
        orders: state.orders,
        addresses: state.addresses,
        unread: state.unread,
        error: state.error,
        loggingOut: loggingOut,
        logoutError: logoutError,
      );

  @override
  Future<void> close() {
    _changes.cancel();
    return super.close();
  }
}
