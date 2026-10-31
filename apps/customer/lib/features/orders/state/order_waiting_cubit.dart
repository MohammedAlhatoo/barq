import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../offer/data/offer_repository.dart';
import '../data/orders_models.dart';
import '../data/orders_repository.dart';

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
  final Order? order;

  /// An offer is waiting for an answer, or it has expired.
  final bool openOffer;
  final bool advancing;
  final String? advanceError;
}

/// Loads the order once, then asks only for what happened since. The whole
/// order is loaded again when something new happened.
class OrderWaitingCubit extends Cubit<OrderWaitingState> {
  OrderWaitingCubit({
    required this._orders,
    required this._offers,
    required this._orderId,
    required int pollSeconds,
  }) : super(const OrderWaitingState()) {
    _poller = Poller(tick: _checkEvents, defaultSeconds: pollSeconds);
  }

  final OrdersRepository _orders;
  final OfferRepository _offers;
  final int _orderId;
  late final Poller _poller;
  int _since = 0;

  /// A request can end after the user left the screen.
  @override
  void emit(OrderWaitingState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> start() async {
    await refresh();
    if (!isClosed && state.order?.isTerminal != true) _poller.start();
  }

  Future<int?> _checkEvents() async {
    final events = await _orders.events(_orderId, since: _since);
    _since = events.nextSince;
    if (events.hasNews) await refresh();
    return events.nextPollSeconds;
  }

  Future<void> refresh() async {
    try {
      final order = await _orders.order(_orderId);
      final offer = await _offers.offer(_orderId);
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
      await _offers.advanceInSandbox(_orderId);
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
