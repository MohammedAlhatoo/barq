import 'dart:async';

import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cart/state/cart_cubit.dart';
import '../data/orders_models.dart';
import '../data/orders_repository.dart';

enum OrdersTab { current, past }

class OrdersState {
  const OrdersState({
    this.loading = true,
    this.error,
    this.tab = OrdersTab.current,
    this.current = const [],
    this.currentTotal,
    this.past = const [],
    this.reorderingId,
    this.reorderError,
  });

  final bool loading;
  final String? error;
  final OrdersTab tab;
  final List<OrderSummary> current;
  final int? currentTotal;

  /// Completed orders, then cancelled ones.
  final List<OrderSummary> past;
  final int? reorderingId;
  final String? reorderError;

  OrdersState copyWith({
    OrdersTab? tab,
    List<OrderSummary>? current,
    int? currentTotal,
    List<OrderSummary>? past,
    int? reorderingId,
    String? reorderError,
  }) => OrdersState(
    loading: false,
    tab: tab ?? this.tab,
    current: current ?? this.current,
    currentTotal: currentTotal ?? this.currentTotal,
    past: past ?? this.past,
    reorderingId: reorderingId,
    reorderError: reorderError,
  );
}

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit({required this._repository, required this._cart})
    : super(const OrdersState()) {
    _changes = _repository.changes.listen((_) => load());
  }

  /// The past tab reads these in order, page by page.
  static const _pastScopes = ['completed', 'cancelled'];

  final OrdersRepository _repository;
  final CartCubit _cart;
  late final StreamSubscription<void> _changes;
  int? _currentNext;
  int _pastScope = 0;
  int? _pastNext = 1;
  bool _loadingMore = false;

  /// A request can end after the user left the screen.
  @override
  void emit(OrdersState state) {
    if (!isClosed) super.emit(state);
  }

  /// Keeps the list on screen while it reloads.
  Future<void> load() async {
    try {
      final current = await _repository.orders(scope: 'active');
      _currentNext = current.nextPage;
      _pastScope = 0;
      _pastNext = 1;
      final past = await _nextPast();
      emit(
        state.copyWith(
          current: current.items,
          currentTotal: current.total,
          past: past,
        ),
      );
    } on ApiException catch (e) {
      if (state.loading || (state.current.isEmpty && state.past.isEmpty)) {
        emit(OrdersState(loading: false, error: e.messageAr, tab: state.tab));
      }
    }
  }

  void selectTab(OrdersTab tab) => emit(state.copyWith(tab: tab));

  /// One page of past orders. When the completed list ends it moves on to the
  /// cancelled list, so a short page never hides the rest.
  Future<List<OrderSummary>> _nextPast() async {
    final items = <OrderSummary>[];
    while (items.isEmpty && _pastScope < _pastScopes.length) {
      final page = await _repository.orders(
        scope: _pastScopes[_pastScope],
        page: _pastNext ?? 1,
      );
      items.addAll(page.items);
      _pastNext = page.nextPage;
      if (_pastNext == null) {
        _pastScope++;
        _pastNext = 1;
      }
    }
    return items;
  }

  Future<void> loadMore() async {
    if (_loadingMore) return;
    _loadingMore = true;
    try {
      if (state.tab == OrdersTab.current) {
        final next = _currentNext;
        if (next != null) {
          final page = await _repository.orders(scope: 'active', page: next);
          _currentNext = page.nextPage;
          emit(state.copyWith(current: [...state.current, ...page.items]));
        }
      } else {
        final items = await _nextPast();
        if (items.isNotEmpty) {
          emit(state.copyWith(past: [...state.past, ...items]));
        }
      }
    } on ApiException {
      // The list stays as it is; scrolling again tries again.
    }
    _loadingMore = false;
  }

  /// A row has no items or store, so the order is loaded first. Answers how
  /// many items the store no longer has, or null if it failed.
  Future<int?> reorder(int orderId) async {
    if (state.reorderingId != null) return null;
    emit(state.copyWith(reorderingId: orderId));
    try {
      final order = await _repository.order(orderId);
      final vendorId = order.vendorId;
      if (vendorId == null) {
        emit(state.copyWith());
        return null;
      }
      final missing = await _cart.rebuildFromOrder(
        vendorId: vendorId,
        items: order.items,
      );
      emit(state.copyWith());
      return missing;
    } on ApiException catch (e) {
      emit(state.copyWith(reorderError: e.messageAr));
      return null;
    }
  }

  @override
  Future<void> close() async {
    await _changes.cancel();
    return super.close();
  }
}
