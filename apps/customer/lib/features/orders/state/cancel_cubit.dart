import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/orders_models.dart';
import '../data/orders_repository.dart';

class CancelState {
  const CancelState({
    this.loading = true,
    this.loadError,
    this.reasons = const [],
    this.selected,
    this.sending = false,
    this.sendError,
    this.done = false,
  });

  final bool loading;
  final String? loadError;
  final List<CancelReason> reasons;
  final String? selected;
  final bool sending;
  final String? sendError;
  final bool done;

  CancelState copyWith({
    String? selected,
    bool sending = false,
    String? sendError,
    bool done = false,
  }) => CancelState(
    loading: false,
    reasons: reasons,
    selected: selected ?? this.selected,
    sending: sending,
    sendError: sendError,
    done: done,
  );
}

class CancelCubit extends Cubit<CancelState> {
  CancelCubit({required this._repository, required this._orderId})
    : super(const CancelState());

  final OrdersRepository _repository;
  final int _orderId;

  /// A request can end after the sheet was closed.
  @override
  void emit(CancelState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> load() async {
    emit(const CancelState());
    try {
      final reasons = await _repository.cancelReasons();
      emit(
        CancelState(
          loading: false,
          reasons: reasons,
          selected: reasons.isEmpty ? null : reasons.first.key,
        ),
      );
    } on ApiException catch (e) {
      emit(CancelState(loading: false, loadError: e.messageAr));
    }
  }

  void select(String key) => emit(state.copyWith(selected: key));

  Future<void> confirm() async {
    final reason = state.selected;
    if (reason == null || state.sending) return;
    emit(state.copyWith(sending: true));
    try {
      await _repository.cancel(_orderId, reason: reason);
      emit(state.copyWith(done: true));
    } on ApiException catch (e) {
      emit(state.copyWith(sendError: e.userMessage));
    }
  }
}
