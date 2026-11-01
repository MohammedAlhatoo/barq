import 'dart:async';

import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../offer/data/offer_repository.dart';
import '../data/orders_models.dart';
import '../data/orders_repository.dart';

class ActiveOrderState {
  const ActiveOrderState({
    this.order,
    this.others = 0,
    this.offerWaiting = false,
  });

  /// Null hides the bar.
  final OrderSummary? order;

  /// How many other orders are running.
  final int others;

  /// The order has an open offer for the customer to answer.
  final bool offerWaiting;
}

/// The running order on the home bar. The [Poller] also checks once when the
/// app comes back from the background.
class ActiveOrderCubit extends Cubit<ActiveOrderState> {
  ActiveOrderCubit({
    required this._orders,
    required this._offers,
    required int pollSeconds,
  }) : super(const ActiveOrderState()) {
    _poller = Poller(
      tick: () async {
        await refresh();
        return null;
      },
      defaultSeconds: pollSeconds,
    );
    _changes = _orders.changes.listen((_) => refresh());
  }

  final OrdersRepository _orders;
  final OfferRepository _offers;
  late final Poller _poller;
  late final StreamSubscription<void> _changes;

  /// A request can end after the user left the screen.
  @override
  void emit(ActiveOrderState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> start() async {
    await refresh();
    if (!isClosed) _poller.start();
  }

  Future<void> refresh() async {
    try {
      final page = await _orders.orders(scope: 'active');
      // The API does not promise an order for this list.
      final newestFirst = [...page.items]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (newestFirst.isEmpty) {
        emit(const ActiveOrderState());
        return;
      }
      final withOffer = await _newestWithOpenOffer(newestFirst);
      emit(
        ActiveOrderState(
          order: withOffer ?? newestFirst.first,
          others: (page.total ?? newestFirst.length) - 1,
          offerWaiting: withOffer != null,
        ),
      );
    } on ApiException {
      // The bar is a hint: a failed check keeps what is on screen.
    }
  }

  /// An offer has a deadline, so it goes before a newer order. An expired one
  /// keeps its status, which is why the offer itself is asked.
  Future<OrderSummary?> _newestWithOpenOffer(List<OrderSummary> orders) async {
    for (final order in orders) {
      if (order.statusKey != OrderTimelines.offerWaiting) continue;
      final offer = await _offers.offer(order.id);
      if (offer != null && offer.isOpen) return order;
    }
    return null;
  }

  @override
  Future<void> close() async {
    _poller.stop();
    await _changes.cancel();
    return super.close();
  }
}
