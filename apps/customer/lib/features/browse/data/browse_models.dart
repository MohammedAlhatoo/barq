import 'package:barq_core/barq_core.dart';

/// The fields of the `Category` schema that the app shows.
class Category {
  const Category({required this.id, required this.name, required this.icon});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] as int,
    name: json['name'] as String,
    icon: json['icon'] as String?,
  );

  final int id;
  final String name;

  /// A name such as "apple" or "milk". Picks the picture of a product that
  /// has no image.
  final String? icon;
}

class ProductChoice {
  const ProductChoice({
    required this.key,
    required this.label,
    required this.price,
  });

  factory ProductChoice.fromJson(Map<String, dynamic> json) => ProductChoice(
    key: json['key'] as String,
    label: json['label'] as String,
    price: Money.fromJson((json['price'] as Map).cast<String, dynamic>()),
  );

  final String key;
  final String label;

  /// What this choice adds to the product price.
  final Money price;
}

class ProductOption {
  const ProductOption({
    required this.key,
    required this.label,
    required this.isMulti,
    required this.isRequired,
    required this.choices,
  });

  factory ProductOption.fromJson(Map<String, dynamic> json) => ProductOption(
    key: json['key'] as String,
    label: json['label'] as String,
    isMulti: json['type'] == 'multi',
    isRequired: json['required'] as bool,
    choices: (json['choices'] as List)
        .map((e) => ProductChoice.fromJson((e as Map).cast<String, dynamic>()))
        .toList(),
  );

  final String key;
  final String label;
  final bool isMulti;
  final bool isRequired;
  final List<ProductChoice> choices;
}

/// The fields of the `Product` schema that the app shows.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.compareAtPrice,
    required this.inStock,
    required this.stock,
    required this.categoryId,
    required this.vendorId,
    required this.options,
    this.categoryIcon,
    this.vendorName,
  });

  factory Product.fromJson(
    Map<String, dynamic> json, {
    String? categoryIcon,
    String? vendorName,
  }) {
    final compareAt = json['compare_at_price'];
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      price: Money.fromJson((json['price'] as Map).cast<String, dynamic>()),
      compareAtPrice: compareAt is Map
          ? Money.fromJson(compareAt.cast<String, dynamic>())
          : null,
      inStock: json['in_stock'] as bool,
      stock: json['stock'] as int?,
      categoryId: json['category_id'] as int?,
      vendorId: json['vendor_id'] as int?,
      options: ((json['options'] as List?) ?? const [])
          .map(
            (e) => ProductOption.fromJson((e as Map).cast<String, dynamic>()),
          )
          .toList(),
      categoryIcon: categoryIcon,
      vendorName: vendorName,
    );
  }

  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final Money price;
  final Money? compareAtPrice;
  final bool inStock;

  /// Null means the store does not count this product.
  final int? stock;
  final int? categoryId;
  final int? vendorId;
  final List<ProductOption> options;

  /// The icon of the product's category. Not in the API's product: the
  /// repository adds it.
  final String? categoryIcon;

  /// Not in the API's product either: the repository adds it.
  final String? vendorName;

  /// Such a product can only be added from its details screen.
  bool get needsChoice => options.any((option) => option.isRequired);
}

/// The fields of the `Vendor` schema that the app shows.
class Vendor {
  const Vendor({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.category,
    required this.phone,
    required this.address,
    required this.distanceKm,
    required this.isOpen,
    required this.prepMinutes,
    required this.ratingAverage,
    required this.ratingCount,
  });

  factory Vendor.fromJson(Map<String, dynamic> json, {double? knownDistance}) {
    final rating = json['rating'];
    return Vendor(
      id: json['id'] as int,
      name: json['name'] as String,
      logoUrl: json['logo_url'] as String?,
      category: json['category'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? knownDistance,
      isOpen: json['is_open_now'] as bool,
      prepMinutes: json['prep_minutes'] as int?,
      ratingAverage: rating is Map ? rating['average'] as num? : null,
      ratingCount: rating is Map ? rating['count'] as int? ?? 0 : 0,
    );
  }

  final int id;
  final String name;
  final String? logoUrl;

  /// A key such as "grocery".
  final String? category;
  final String? phone;
  final String? address;

  /// Only known when the request sent lat and lng.
  final double? distanceKm;
  final bool isOpen;
  final int? prepMinutes;
  final num? ratingAverage;
  final int ratingCount;
}
