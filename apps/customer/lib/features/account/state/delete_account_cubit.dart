import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/account_repository.dart';

class DeleteAccountState {
  const DeleteAccountState({
    this.understood = false,
    this.deleting = false,
    this.error,
  });

  /// The second confirmation: the button stays off until this is ticked.
  final bool understood;
  final bool deleting;

  /// The server's reason, such as an order that is still running.
  final String? error;
}

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  DeleteAccountCubit(this._repository) : super(const DeleteAccountState());

  final AccountRepository _repository;

  /// A request can end after the user left the screen.
  @override
  void emit(DeleteAccountState state) {
    if (!isClosed) super.emit(state);
  }

  void understoodChanged(bool value) =>
      emit(DeleteAccountState(understood: value));

  /// On success the login screen opens by itself.
  Future<void> delete() async {
    if (!state.understood || state.deleting) return;
    emit(const DeleteAccountState(understood: true, deleting: true));
    try {
      await _repository.deleteAccount();
    } on ApiException catch (e) {
      emit(DeleteAccountState(understood: true, error: e.messageAr));
    }
  }
}
