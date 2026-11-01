import 'package:barq_core/barq_core.dart';

import '../../browse/data/browse_models.dart';
import '../../cart/data/cart_models.dart';
import 'list_parser.dart';

/// One item of the list and what was found for it. [product] null with empty
/// [alternatives] is "مش لاقي X".
class MatchedItem {
  const MatchedItem({
    required this.item,
    this.product,
    this.alternatives = const [],
    this.capped = false,
  });

  final ParsedItem item;
  final Product? product;
  final List<Product> alternatives;

  /// The quantity was more than the cart allows.
  final bool capped;

  int get qty => item.qty;

  MatchedItem withQty(int qty) => MatchedItem(
    item: ParsedItem(name: item.name, qty: qty, rounded: item.rounded),
    product: product,
    alternatives: alternatives,
    capped: true,
  );

  /// The customer picked one of the suggestions.
  MatchedItem choose(Product choice) =>
      MatchedItem(item: item, product: choice, capped: capped);

  /// The cart's shape. The price is for display, the server prices it again.
  CartLine? get line {
    final found = product;
    if (found == null) return null;
    return CartLine(
      productId: found.id,
      name: found.name,
      imageUrl: found.imageUrl,
      categoryIcon: found.categoryIcon,
      unitPrice: found.price,
      qty: qty,
    );
  }
}

/// A store the assistant offers. [total] is the server's total with delivery,
/// null if its quote failed.
class StoreOption {
  const StoreOption({required this.store, this.total, this.distanceKm});

  final BasketStore store;
  final Money? total;
  final double? distanceKm;
}
