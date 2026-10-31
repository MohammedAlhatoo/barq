import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';

/// The product's picture, or an illustration of its category when it has none.
class ProductArt extends StatelessWidget {
  const ProductArt({super.key, this.imageUrl, this.categoryIcon});

  final String? imageUrl;
  final String? categoryIcon;

  /// Category icon names from `GET /categories`.
  static String _illustration(String? icon) => switch (icon) {
    'apple' => BarqIllustrations.apple,
    'milk' => BarqIllustrations.milk,
    'croissant' => BarqIllustrations.bread,
    'wheat' => BarqIllustrations.rice,
    _ => BarqIllustrations.box,
  };

  /// The background color that goes with a category.
  static BarqTileColor tileOf(String? icon) => switch (icon) {
    'apple' => BarqTileColor.pink,
    'milk' => BarqTileColor.sky,
    'croissant' => BarqTileColor.peach,
    'wheat' => BarqTileColor.yellow,
    'spray-can' => BarqTileColor.mint,
    _ => BarqTileColor.cream,
  };

  @override
  Widget build(BuildContext context) => BarqNetworkImage(
    url: imageUrl,
    fallback: BarqIllustration(_illustration(categoryIcon)),
  );
}
