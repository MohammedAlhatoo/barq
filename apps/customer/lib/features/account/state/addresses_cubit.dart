import 'dart:async';

import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/data/auth_models.dart';
import '../data/account_repository.dart';

class AddressesState {
  const AddressesState({
    this.loading = true,
    this.addresses = const [],
    this.error,
    this.deleteError,
  });

  final bool loading;
  final List<SavedAddress> addresses;
  final String? error;
  final String? deleteError;
}

/// The list on the addresses screen and in the picker sheet.
class AddressesCubit extends Cubit<AddressesState> {
  AddressesCubit(this._repository) : super(const AddressesState()) {
    _changes = _repository.changes.listen((_) => _refresh());
  }

  final AccountRepository _repository;
  late final StreamSubscription<void> _changes;

  /// Answers of an older load are ignored.
  int _request = 0;

  /// A request can end after the user left the screen.
  @override
  void emit(AddressesState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> load() async {
    emit(const AddressesState());
    await _refresh();
  }

  /// The server decides what is left and which address is the default, so the
  /// list always comes back from it.
  Future<void> _refresh() async {
    final request = ++_request;
    try {
      final addresses = await _repository.addresses();
      if (request != _request) return;
      emit(AddressesState(loading: false, addresses: addresses));
    } on ApiException catch (e) {
      if (request != _request) return;
      emit(AddressesState(loading: false, error: e.messageAr));
    }
  }

  Future<void> delete(int id) async {
    try {
      await _repository.deleteAddress(id);
    } on ApiException catch (e) {
      emit(
        AddressesState(
          loading: false,
          addresses: state.addresses,
          deleteError: e.messageAr,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _changes.cancel();
    return super.close();
  }
}
