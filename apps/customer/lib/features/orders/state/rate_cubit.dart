import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/orders_models.dart';
import '../data/orders_repository.dart';

class RateState {
  const RateState({
    this.loading = true,
    this.error,
    this.order,
    this.driverStars = 0,
    this.storeStars = 0,
    this.sending = false,
    this.sendError,
    this.done = false,
  });

  final bool loading;
  final String? error;
  final Order? order;
  final int driverStars;
  final int storeStars;
  final bool sending;
  final String? sendError;
  final bool done;

  /// The server requires the driver's stars; the store's are optional.
  bool get canSend => driverStars > 0 && !sending;

  RateState copyWith({
    int? driverStars,
    int? storeStars,
    bool sending = false,
    String? sendError,
    bool done = false,
  }) => RateState(
    loading: false,
    order: order,
    driverStars: driverStars ?? this.driverStars,
    storeStars: storeStars ?? this.storeStars,
    sending: sending,
    sendError: sendError,
    done: done,
  );
}

class RateCubit extends Cubit<RateState> {
  RateCubit({required this._repository, required this._orderId})
    : super(const RateState());

  final OrdersRepository _repository;
  final int _orderId;

  /// A request can end after the user left the screen.
  @override
  void emit(RateState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> load() async {
    emit(const RateState());
    try {
      final order = await _repository.order(_orderId);
      emit(RateState(loading: false, order: order));
    } on ApiException catch (e) {
      emit(RateState(loading: false, error: e.messageAr));
    }
  }

  void setDriverStars(int stars) => emit(state.copyWith(driverStars: stars));
  void setStoreStars(int stars) => emit(state.copyWith(storeStars: stars));

  Future<void> send(String comment) async {
    if (!state.canSend) return;
    emit(state.copyWith(sending: true));
    try {
      await _repository.rate(
        _orderId,
        stars: state.driverStars,
        vendorStars: state.storeStars > 0 ? state.storeStars : null,
        comment: comment.trim().isEmpty ? null : comment.trim(),
      );
      emit(state.copyWith(done: true));
    } on ApiException catch (e) {
      emit(state.copyWith(sendError: e.userMessage));
    }
  }
}
