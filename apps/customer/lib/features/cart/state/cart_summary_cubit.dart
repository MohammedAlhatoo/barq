import 'dart:async';

import 'package:barq_core/barq_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../browse/data/browse_repository.dart';
import '../data/cart_models.dart';
import '../data/cart_repository.dart';

class CartSummaryState {
  const CartSummaryState({this.vendorName, this.total});

  final String? vendorName;

  /// The server's total for this cart. Null while unknown: the app never adds
  /// prices up by itself.
  final Money? total;
}

/// The store name and the server's total on the cart screen. The total comes
/// from `POST /baskets/compare`, which only knows stores that deliver to the
/// user's address. Without it the screen shows "at checkout" instead.
class CartSummaryCubit extends Cubit<CartSummaryState> {
  CartSummaryCubit({
    required this._browse,
    required this._cart,
    required this._compareEnabled,
  }) : super(const CartSummaryState());

  static const _debounce = Duration(milliseconds: 400);

  final BrowseRepository _browse;
  final CartRepository _cart;
  final bool _compareEnabled;
  Timer? _timer;
  int _request = 0;
  int? _namedVendor;

  /// Called on every cart change. Waits for quick taps on the stepper to end.
  void refresh(Cart cart) {
    _timer?.cancel();
    _request++;
    final name = cart.vendorId == _namedVendor ? state.vendorName : null;
    emit(CartSummaryState(vendorName: name));
    if (cart.isEmpty) return;
    _timer = Timer(_debounce, () => _load(cart, _request));
  }

  Future<void> _load(Cart cart, int request) async {
    try {
      final vendorId = cart.vendorId;
      if (vendorId != null && vendorId != _namedVendor) {
        final vendor = await _browse.vendor(vendorId);
        if (request != _request || isClosed) return;
        _namedVendor = vendorId;
        emit(CartSummaryState(vendorName: vendor.name));
      }
      if (!_compareEnabled || cart.hasOptions) return;
      final address = await _browse.defaultAddress();
      if (address == null) return;
      final comparison = await _cart.compare(
        lines: cart.lines,
        addressId: address.id,
      );
      if (request != _request || isClosed) return;
      final store = comparison.storeOf(vendorId);
      if (store == null || !store.complete) return;
      emit(
        CartSummaryState(vendorName: state.vendorName, total: store.itemsTotal),
      );
    } on ApiException catch (e) {
      // The cart stays usable: the total simply waits for checkout.
      debugPrint('Cart total not loaded: ${e.code}');
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
