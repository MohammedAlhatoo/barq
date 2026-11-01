import 'dart:convert';

import 'package:barq_core/barq_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../browse/data/browse_models.dart';
import '../../browse/data/browse_repository.dart';
import '../data/cart_models.dart';

enum AddResult { added, otherStore, limitReached }

/// The app-wide cart. Lives in [AppDependencies] and saves itself on every
/// change, so it comes back after the app is closed.
class CartCubit extends Cubit<Cart> {
  CartCubit({
    required SharedPreferences prefs,
    required this._config,
    required this._browse,
  }) : _prefs = prefs,
       super(_read(prefs));

  static const _key = 'barq_cart';

  final SharedPreferences _prefs;
  final ConfigStore _config;
  final BrowseRepository _browse;

  static Cart _read(SharedPreferences prefs) {
    final saved = prefs.getString(_key);
    if (saved == null) return const Cart();
    try {
      return Cart.fromJson(jsonDecode(saved) as Map<String, dynamic>);
    } on FormatException catch (e) {
      debugPrint('Saved cart ignored: $e');
    } on TypeError catch (e) {
      debugPrint('Saved cart ignored: $e');
    }
    return const Cart();
  }

  int get maxLines => _config.isLoaded ? _config.config.cartMaxLines : 50;
  int get maxQty => _config.isLoaded ? _config.config.cartMaxQty : 99;

  @override
  void onChange(Change<Cart> change) {
    super.onChange(change);
    _prefs.setString(_key, jsonEncode(change.nextState.toJson()));
  }

  AddResult add(
    Product product, {
    int qty = 1,
    Map<String, Object> options = const {},
    String? optionsLabel,
  }) {
    if (!state.isEmpty && state.vendorId != product.vendorId) {
      return AddResult.otherStore;
    }
    final line = CartLine(
      productId: product.id,
      name: product.name,
      imageUrl: product.imageUrl,
      categoryIcon: product.categoryIcon,
      unitPrice: product.price,
      qty: qty,
      options: options,
      optionsLabel: optionsLabel,
    );
    final index = state.lines.indexWhere((l) => l.key == line.key);
    if (index >= 0) {
      final total = state.lines[index].qty + qty;
      if (total > maxQty) return AddResult.limitReached;
      final lines = [...state.lines];
      lines[index] = lines[index].copyWith(qty: total);
      emit(Cart(vendorId: state.vendorId, lines: lines));
      return AddResult.added;
    }
    if (state.count >= maxLines || qty > maxQty) {
      return AddResult.limitReached;
    }
    emit(Cart(vendorId: product.vendorId, lines: [...state.lines, line]));
    return AddResult.added;
  }

  /// Empties the cart of the other store, then adds [product].
  void replaceWith(
    Product product, {
    int qty = 1,
    Map<String, Object> options = const {},
    String? optionsLabel,
  }) {
    clear();
    add(product, qty: qty, options: options, optionsLabel: optionsLabel);
  }

  /// 0 removes the line.
  void setQty(String key, int qty) {
    final lines = [
      for (final line in state.lines)
        if (line.key != key)
          line
        else if (qty > 0)
          line.copyWith(qty: qty > maxQty ? maxQty : qty),
    ];
    emit(
      lines.isEmpty
          ? const Cart()
          : Cart(vendorId: state.vendorId, lines: lines),
    );
  }

  void clear() => emit(const Cart());

  /// Shows the prices the server gave in a new quote, by product id.
  void updatePrices(Map<int, Money> prices) => emit(
    Cart(
      vendorId: state.vendorId,
      lines: [
        for (final line in state.lines)
          line.copyWith(unitPrice: prices[line.productId]),
      ],
    ),
  );

  /// Moves the cart to [store], keeping only what it has, at its prices.
  void switchStore(BasketStore store) => fillFrom(store, state.lines);

  /// Replaces the cart with what [store] has of [wanted], at its prices.
  void fillFrom(BasketStore store, List<CartLine> wanted) {
    final lines = <CartLine>[];
    for (final line in wanted) {
      for (final offer in store.lines) {
        if (offer.productId == line.productId && offer.available) {
          lines.add(
            line.copyWith(
              productId: offer.storeProductId,
              unitPrice: offer.unitPrice,
            ),
          );
        }
      }
    }
    emit(Cart(vendorId: store.vendorId, lines: lines));
  }

  /// Fills the cart again from an old order ("اطلب نفس السلة"). An order item
  /// has only a name and a quantity, and no reorder endpoint exists, so each
  /// product is found again by its exact name in the same store. Returns how
  /// many items that store no longer has.
  Future<int> rebuildFromOrder({
    required int vendorId,
    required List<({String name, int qty})> items,
  }) async {
    final lines = <CartLine>[];
    for (final item in items) {
      final found = await _browse.products(
        vendorId: vendorId,
        query: item.name,
      );
      for (final product in found.items) {
        if (product.name == item.name && product.inStock) {
          lines.add(
            CartLine(
              productId: product.id,
              name: product.name,
              imageUrl: product.imageUrl,
              categoryIcon: product.categoryIcon,
              unitPrice: product.price,
              qty: item.qty,
            ),
          );
          break;
        }
      }
    }
    emit(lines.isEmpty ? const Cart() : Cart(vendorId: vendorId, lines: lines));
    return items.length - lines.length;
  }
}
