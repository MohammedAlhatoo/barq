import 'package:barq_core/barq_core.dart';

import '../../browse/data/browse_models.dart';
import '../../cart/data/cart_models.dart';
import 'list_parser.dart';
import 'quantity_fit.dart';

/// One item of the list and what was found for it. [product] null with empty
/// [alternatives] is "مش لاقي X".
class MatchedItem {
  const MatchedItem({
    required this.item,
    required this.qty,
    this.product,
    this.alternatives = const [],
    this.options = const {},
    this.optionsLabel,
    this.note = QuantityNote.none,
    this.capped = false,
  });

  /// [product] with the quantity that fits it. [QuantityFit.of] must have
  /// accepted the product.
  factory MatchedItem.found(ParsedItem item, Product product) {
    final fit = QuantityFit.of(item, product)!;
    return MatchedItem(
      item: item,
      qty: fit.qty,
      product: product,
      options: fit.options,
      optionsLabel: fit.optionsLabel,
      note: fit.note,
    );
  }

  final ParsedItem item;

  /// What goes in the cart. The customer can change it.
  final int qty;
  final Product? product;
  final List<Product> alternatives;

  /// The choice that fits the amount, in the shape of [CartLine.options].
  final Map<String, Object> options;
  final String? optionsLabel;
  final QuantityNote note;

  /// The quantity was more than the cart allows.
  final bool capped;

  /// The product's name, with the choice if there is one.
  String? get title {
    final found = product;
    if (found == null) return null;
    final label = optionsLabel;
    return label == null ? found.name : '${found.name} · $label';
  }

  /// A quantity the customer set needs no explanation.
  MatchedItem withQty(int value, {bool capped = false}) => MatchedItem(
    item: item,
    qty: value,
    product: product,
    alternatives: alternatives,
    options: options,
    optionsLabel: optionsLabel,
    note: capped ? note : QuantityNote.none,
    capped: capped,
  );

  /// The customer picked one of the suggestions.
  MatchedItem choose(Product choice) => MatchedItem.found(item, choice);

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
      options: options,
      optionsLabel: optionsLabel,
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
