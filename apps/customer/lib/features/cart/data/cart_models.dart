import 'dart:convert';

import 'package:barq_core/barq_core.dart';

/// One product in the cart. Prices and names are for display: the server
/// prices the order again from `product_id`, `qty` and `options`.
class CartLine {
  const CartLine({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.categoryIcon,
    required this.unitPrice,
    required this.qty,
    this.options = const {},
    this.optionsLabel,
  });

  factory CartLine.fromJson(Map<String, dynamic> json) => CartLine(
    productId: json['product_id'] as int,
    name: json['name'] as String,
    imageUrl: json['image_url'] as String?,
    categoryIcon: json['category_icon'] as String?,
    unitPrice: Money.fromJson(
      (json['unit_price'] as Map).cast<String, dynamic>(),
    ),
    qty: json['qty'] as int,
    options: (json['options'] as Map).cast<String, Object>(),
    optionsLabel: json['options_label'] as String?,
  );

  final int productId;
  final String name;
  final String? imageUrl;
  final String? categoryIcon;
  final Money unitPrice;
  final int qty;

  /// Option key → choice key, or a list of keys for a multi option. The shape
  /// `POST /orders/quote` takes.
  final Map<String, Object> options;

  /// The chosen labels, for display ("1 كغ").
  final String? optionsLabel;

  /// The same product with other choices is another line.
  String get key => '$productId|${jsonEncode(options)}';

  CartLine copyWith({int? productId, Money? unitPrice, int? qty}) => CartLine(
    productId: productId ?? this.productId,
    name: name,
    imageUrl: imageUrl,
    categoryIcon: categoryIcon,
    unitPrice: unitPrice ?? this.unitPrice,
    qty: qty ?? this.qty,
    options: options,
    optionsLabel: optionsLabel,
  );

  /// One entry of `cart` in `POST /orders/quote`.
  Map<String, Object?> get quoteJson => {
    'product_id': productId,
    'qty': qty,
    if (options.isNotEmpty) 'options': options,
  };

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'name': name,
    'image_url': imageUrl,
    'category_icon': categoryIcon,
    'unit_price': {
      'amount': unitPrice.amount,
      'formatted': unitPrice.formatted,
    },
    'qty': qty,
    'options': options,
    'options_label': optionsLabel,
  };
}

/// The cart holds products of one store only.
class Cart {
  const Cart({this.vendorId, this.lines = const []});

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
    vendorId: json['vendor_id'] as int?,
    lines: (json['lines'] as List)
        .map((e) => CartLine.fromJson((e as Map).cast<String, dynamic>()))
        .toList(),
  );

  final int? vendorId;
  final List<CartLine> lines;

  bool get isEmpty => lines.isEmpty;

  /// The number on the cart button.
  int get count => lines.length;

  int qtyOf(int productId) => lines
      .where((line) => line.productId == productId)
      .fold(0, (sum, line) => sum + line.qty);

  Map<String, dynamic> toJson() => {
    'vendor_id': vendorId,
    'lines': [for (final line in lines) line.toJson()],
  };
}

/// The fields of `POST /orders/quote` that the cart and compare screens show.
class Quote {
  const Quote({required this.itemsTotal, required this.total});

  factory Quote.fromJson(Map<String, dynamic> json) => Quote(
    itemsTotal: Money.fromJson(
      (json['items_total'] as Map).cast<String, dynamic>(),
    ),
    total: Money.fromJson((json['total'] as Map).cast<String, dynamic>()),
  );

  final Money itemsTotal;

  /// Items plus delivery.
  final Money total;
}

class BasketLine {
  const BasketLine({
    required this.productId,
    required this.storeProductId,
    required this.name,
    required this.qty,
    required this.unitPrice,
    required this.available,
    required this.reason,
  });

  factory BasketLine.fromJson(Map<String, dynamic> json) {
    final unitPrice = json['unit_price'];
    return BasketLine(
      productId: json['product_id'] as int,
      storeProductId: json['store_product_id'] as int?,
      name: json['name'] as String,
      qty: json['qty'] as int,
      unitPrice: unitPrice is Map
          ? Money.fromJson(unitPrice.cast<String, dynamic>())
          : null,
      available: json['available'] as bool,
      reason: json['reason'] as String?,
    );
  }

  /// The product as it is in the cart.
  final int productId;

  /// The same product in this store.
  final int? storeProductId;
  final String name;
  final int qty;
  final Money? unitPrice;
  final bool available;

  /// `not_sold` or `not_enough_stock`.
  final String? reason;
}

class BasketStore {
  const BasketStore({
    required this.vendorId,
    required this.vendorName,
    required this.complete,
    required this.missingCount,
    required this.itemsTotal,
    required this.lines,
  });

  factory BasketStore.fromJson(Map<String, dynamic> json) {
    final vendor = json['vendor'] as Map;
    return BasketStore(
      vendorId: vendor['id'] as int,
      vendorName: vendor['name'] as String,
      complete: json['complete'] as bool,
      missingCount: json['missing_count'] as int,
      itemsTotal: Money.fromJson(
        (json['items_total'] as Map).cast<String, dynamic>(),
      ),
      lines: (json['lines'] as List)
          .map((e) => BasketLine.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }

  final int vendorId;
  final String vendorName;
  final bool complete;
  final int missingCount;
  final Money itemsTotal;
  final List<BasketLine> lines;

  int get availableCount => lines.where((line) => line.available).length;
  List<BasketLine> get missingLines =>
      lines.where((line) => !line.available).toList();

  /// What this store has of [wanted], under its own ids and at its prices.
  List<CartLine> linesFor(List<CartLine> wanted) => [
    for (final line in wanted)
      for (final offer in lines)
        if (offer.productId == line.productId && offer.available)
          line.copyWith(
            productId: offer.storeProductId,
            unitPrice: offer.unitPrice,
          ),
  ];
}

/// Answer of `POST /baskets/compare`.
class BasketComparison {
  const BasketComparison({
    required this.zoneName,
    required this.cheapestVendorId,
    required this.stores,
  });

  factory BasketComparison.fromJson(Map<String, dynamic> json) =>
      BasketComparison(
        zoneName: (json['zone'] as Map)['name'] as String,
        cheapestVendorId: json['cheapest_vendor_id'] as int?,
        stores: (json['stores'] as List)
            .map(
              (e) => BasketStore.fromJson((e as Map).cast<String, dynamic>()),
            )
            .toList(),
      );

  final String zoneName;

  /// Null when no store has the whole cart.
  final int? cheapestVendorId;
  final List<BasketStore> stores;

  BasketStore? storeOf(int? vendorId) {
    for (final store in stores) {
      if (store.vendorId == vendorId) return store;
    }
    return null;
  }
}
