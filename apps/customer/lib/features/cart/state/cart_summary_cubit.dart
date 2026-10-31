import 'dart:async';

import 'package:barq_core/barq_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../browse/data/browse_repository.dart';
import '../data/cart_models.dart';
import '../data/cart_repository.dart';

class CartSummaryState {
  const CartSummaryState({this.vendorName, this.quote});

  final String? vendorName;

  /// The server's price of this cart. Null while unknown: the app never adds
  /// prices up by itself.
  final Quote? quote;
}

/// The store name and the server's prices on the cart screen. They come from
/// the same quote as the compare screen, so both show the same numbers. With
/// no address or a failed quote the screen shows "at checkout" instead.
class CartSummaryCubit extends Cubit<CartSummaryState> {
  CartSummaryCubit({required this._browse, required this._cart})
    : super(const CartSummaryState());

  static const _debounce = Duration(milliseconds: 400);

  final BrowseRepository _browse;
  final CartRepository _cart;
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
      if (vendorId == null) return;
      if (vendorId != _namedVendor) {
        final vendor = await _browse.vendor(vendorId);
        if (request != _request || isClosed) return;
        _namedVendor = vendorId;
        emit(CartSummaryState(vendorName: vendor.name));
      }
      final address = await _browse.defaultAddress();
      if (address == null) return;
      final quote = await _cart.quoteCart(
        vendorId: vendorId,
        lines: cart.lines,
        addressId: address.id,
      );
      if (request != _request || isClosed) return;
      emit(CartSummaryState(vendorName: state.vendorName, quote: quote));
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
