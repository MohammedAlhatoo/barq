import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/countdown.dart';
import '../../cart/state/cart_cubit.dart';
import '../data/offer_models.dart';
import '../data/offer_repository.dart';

class OfferState {
  const OfferState({
    this.loading = true,
    this.error,
    this.order,
    this.offer,
    this.secondsLeft = 0,
    this.approving = false,
    this.rejecting = false,
    this.reordering = false,
    this.actionError,
    this.actionRefused = false,
    this.answered = false,
  });

  final bool loading;

  /// The server's reason when the screen could not load.
  final String? error;
  final OrderInfo? order;

  /// Null while the store has not priced the order yet.
  final Offer? offer;
  final int secondsLeft;
  final bool approving;
  final bool rejecting;
  final bool reordering;

  /// The server's reason when approving, rejecting or reordering failed.
  final String? actionError;

  /// The server refused the step (`invalid_transition`). Its message is only a
  /// hint for developers, so the screen shows its own.
  final bool actionRefused;

  /// The offer is closed and not expired: the order screen takes over.
  final bool answered;

  bool get busy => approving || rejecting || reordering;

  OfferState copyWith({
    int? secondsLeft,
    bool approving = false,
    bool rejecting = false,
    bool reordering = false,
    String? actionError,
    bool actionRefused = false,
  }) => OfferState(
    loading: false,
    order: order,
    offer: offer,
    secondsLeft: secondsLeft ?? this.secondsLeft,
    approving: approving,
    rejecting: rejecting,
    reordering: reordering,
    actionError: actionError,
    actionRefused: actionRefused,
  );
}

class OfferCubit extends Cubit<OfferState> {
  OfferCubit({
    required this._repository,
    required this._cart,
    required this._orderId,
  }) : super(const OfferState());

  final OfferRepository _repository;
  final CartCubit _cart;
  final int _orderId;
  late final _countdown = Countdown(
    onTick: (left) => emit(_keepBusy(left)),
    onDone: load,
  );

  /// Kept across retries, so approving twice after a lost answer counts once.
  String? _approveKey;

  /// A request can end after the user left the screen.
  @override
  void emit(OfferState state) {
    if (!isClosed) super.emit(state);
  }

  OfferState _keepBusy(int left) => state.copyWith(
    secondsLeft: left,
    approving: state.approving,
    rejecting: state.rejecting,
    reordering: state.reordering,
    actionError: state.actionError,
    actionRefused: state.actionRefused,
  );

  /// Also asks again when the time is up: the server decides it has expired.
  Future<void> load() async {
    try {
      final order = await _repository.order(_orderId);
      final offer = await _repository.offer(_orderId);
      final closed = offer != null && !offer.isOpen && !offer.isExpired;
      emit(
        OfferState(
          loading: false,
          order: order,
          offer: offer,
          answered: closed,
        ),
      );
      if (offer == null || !offer.isOpen) return;
      final end = offer.expiresAt;
      if (end == null) return;
      final left = end.difference(DateTime.now()).inSeconds;
      if (left > 0) _countdown.start(left);
    } on ApiException catch (e) {
      emit(OfferState(loading: false, error: e.messageAr));
    }
  }

  Future<void> approve() async {
    final offer = state.offer;
    if (offer == null || state.busy) return;
    emit(state.copyWith(approving: true));
    try {
      await _repository.approve(
        _orderId,
        offerId: offer.id,
        idempotencyKey: _approveKey ??= newIdempotencyKey(),
      );
      _countdown.stop();
      await load();
    } on ApiException catch (e) {
      await _failed(e);
    }
  }

  Future<void> reject() async {
    if (state.busy) return;
    emit(state.copyWith(rejecting: true));
    try {
      await _repository.reject(_orderId);
      _countdown.stop();
      await load();
    } on ApiException catch (e) {
      await _failed(e);
    }
  }

  Future<void> _failed(ApiException e) async {
    if (e.code == 'offer_expired') {
      await load();
    } else if (e.code == 'invalid_transition') {
      await load();
      emit(state.copyWith(actionRefused: true));
    } else {
      emit(state.copyWith(actionError: e.userMessage));
    }
  }

  /// "اطلب نفس السلة". Answers how many items the store no longer has, or null
  /// if it failed.
  Future<int?> reorder() async {
    final order = state.order;
    final vendorId = order?.vendorId;
    if (order == null || vendorId == null || state.busy) return null;
    emit(state.copyWith(reordering: true));
    try {
      final missing = await _cart.rebuildFromOrder(
        vendorId: vendorId,
        items: order.items,
      );
      emit(state.copyWith());
      return missing;
    } on ApiException catch (e) {
      emit(state.copyWith(actionError: e.messageAr));
      return null;
    }
  }

  @override
  Future<void> close() {
    _countdown.stop();
    return super.close();
  }
}
