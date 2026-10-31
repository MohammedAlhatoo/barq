import 'dart:async';

import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../browse/data/browse_repository.dart';
import '../data/cart_models.dart';
import 'cart_cubit.dart';

class ShopScope {
  const ShopScope({this.vendorId, this.vendorName, this.showAll = false});

  /// The cart's store. Null when the cart is empty.
  final int? vendorId;
  final String? vendorName;

  /// The user tapped "كل المتاجر".
  final bool showAll;

  /// The store the browse screens filter by. Null shows every store.
  int? get filterVendorId => showAll ? null : vendorId;
}

/// Decides what the browse screens show: the cart's store by default, and
/// everything when the cart is empty or the user asks for all stores.
class ShopScopeCubit extends Cubit<ShopScope> {
  ShopScopeCubit({required CartCubit cart, required this._browse})
    : super(ShopScope(vendorId: _storeOf(cart.state))) {
    _cart = cart.stream.listen(_cartChanged);
  }

  final BrowseRepository _browse;
  late final StreamSubscription<Cart> _cart;

  static int? _storeOf(Cart cart) => cart.isEmpty ? null : cart.vendorId;

  /// A new store starts filtered again, even after "كل المتاجر".
  void _cartChanged(Cart cart) {
    final vendorId = _storeOf(cart);
    if (vendorId == state.vendorId) return;
    emit(ShopScope(vendorId: vendorId));
    loadName();
  }

  /// Also called once after login, for a cart saved from an earlier session.
  Future<void> loadName() async {
    final vendorId = state.vendorId;
    if (vendorId == null || state.vendorName != null) return;
    try {
      final vendor = await _browse.vendor(vendorId);
      if (isClosed || state.vendorId != vendorId) return;
      emit(
        ShopScope(
          vendorId: vendorId,
          vendorName: vendor.name,
          showAll: state.showAll,
        ),
      );
    } on ApiException {
      // The bar then says "your cart's store" instead of the name.
    }
  }

  void toggleAll() => emit(
    ShopScope(
      vendorId: state.vendorId,
      vendorName: state.vendorName,
      showAll: !state.showAll,
    ),
  );

  @override
  Future<void> close() {
    _cart.cancel();
    return super.close();
  }
}
