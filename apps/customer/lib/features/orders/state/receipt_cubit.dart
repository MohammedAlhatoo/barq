import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cart/state/cart_cubit.dart';
import '../data/orders_models.dart';
import '../data/orders_repository.dart';

class ReceiptState {
  const ReceiptState({
    this.loading = true,
    this.error,
    this.receipt,
    this.order,
    this.reordering = false,
    this.reorderError,
  });

  final bool loading;
  final String? error;
  final Receipt? receipt;

  /// Has the store and what reordering needs, which the receipt does not.
  final Order? order;
  final bool reordering;
  final String? reorderError;
}

class ReceiptCubit extends Cubit<ReceiptState> {
  ReceiptCubit({
    required this._repository,
    required this._cart,
    required this._orderId,
  }) : super(const ReceiptState());

  final OrdersRepository _repository;
  final CartCubit _cart;
  final int _orderId;

  /// A request can end after the user left the screen.
  @override
  void emit(ReceiptState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> load() async {
    emit(const ReceiptState());
    try {
      final receipt = await _repository.receipt(_orderId);
      final order = await _repository.order(_orderId);
      emit(ReceiptState(loading: false, receipt: receipt, order: order));
    } on ApiException catch (e) {
      emit(ReceiptState(loading: false, error: e.messageAr));
    }
  }

  /// Answers how many items the store no longer has, or null if it failed.
  Future<int?> reorder() async {
    final order = state.order;
    final vendorId = order?.vendorId;
    if (order == null || vendorId == null || state.reordering) return null;
    emit(
      ReceiptState(
        loading: false,
        receipt: state.receipt,
        order: order,
        reordering: true,
      ),
    );
    int? missing;
    String? error;
    try {
      missing = await _cart.rebuildFromOrder(
        vendorId: vendorId,
        items: order.items,
      );
    } on ApiException catch (e) {
      error = e.messageAr;
    }
    emit(
      ReceiptState(
        loading: false,
        receipt: state.receipt,
        order: order,
        reorderError: error,
      ),
    );
    return missing;
  }
}
