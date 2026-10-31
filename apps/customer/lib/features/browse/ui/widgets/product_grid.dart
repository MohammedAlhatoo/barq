import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';

import '../../data/browse_models.dart';
import 'product_card.dart';

/// Two columns of product tiles, for a CustomScrollView.
class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key, required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: BarqSpacing.page),
    sliver: SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: BarqSpacing.gap,
        mainAxisSpacing: BarqSpacing.gap,
        mainAxisExtent: BarqSizes.productTile,
      ),
      itemCount: products.length,
      itemBuilder: (_, index) => ProductCard(product: products[index]),
    ),
  );
}
