import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../offer/data/offer_models.dart';
import '../../offer/data/offer_repository.dart';

class OrderWaitingState {
  const OrderWaitingState({
    this.loading = true,
    this.error,
    this.order,
    this.openOffer = false,
    this.advancing = false,
    this.advanceError,
  });

  final bool loading;
  final String? error;
  final OrderInfo? order;

  /// An offer is waiting for an answer, or it has expired.
  final bool openOffer;
  final bool advancing;
  final String? advanceError;
}

/// Follows a new order until the store prices it. Phase 6 replaces this with
/// the full "waiting for the store" screen.
class OrderWaitingCubit extends Cubit<OrderWaitingState> {
  OrderWaitingCubit({
    required this._repository,
    required this._orderId,
    required int pollSeconds,
  }) : super(const OrderWaitingState()) {
    _poller = Poller(
      tick: () async {
        await refresh();
        return null;
      },
      defaultSeconds: pollSeconds,
    );
  }

  final OfferRepository _repository;
  final int _orderId;
  late final Poller _poller;

  /// A request can end after the user left the screen.
  @override
  void emit(OrderWaitingState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> start() async {
    await refresh();
    if (!isClosed) _poller.start();
  }

  Future<void> refresh() async {
    try {
      final order = await _repository.order(_orderId);
      final offer = await _repository.offer(_orderId);
      emit(
        OrderWaitingState(
          loading: false,
          order: order,
          openOffer: offer != null && (offer.isOpen || offer.isExpired),
        ),
      );
      if (order.isTerminal) _poller.stop();
    } on ApiException catch (e) {
      // A failed poll keeps what is on screen.
      if (state.order == null) {
        emit(OrderWaitingState(loading: false, error: e.messageAr));
      }
    }
  }

  Future<void> advanceInSandbox() async {
    emit(
      OrderWaitingState(
        loading: false,
        order: state.order,
        openOffer: state.openOffer,
        advancing: true,
      ),
    );
    try {
      await _repository.advanceInSandbox(_orderId);
      await refresh();
    } on ApiException catch (e) {
      emit(
        OrderWaitingState(
          loading: false,
          order: state.order,
          openOffer: state.openOffer,
          advanceError: e.messageAr,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _poller.stop();
    return super.close();
  }
}
