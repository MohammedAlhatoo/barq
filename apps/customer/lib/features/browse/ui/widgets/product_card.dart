import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../cart/state/cart_cubit.dart';
import '../../../cart/ui/add_to_cart.dart';
import '../../data/browse_models.dart';
import 'product_art.dart';

/// A product tile for grids and the home carousel.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.large = false,
    this.topBadge,
  });

  final Product product;
  final bool large;
  final String? topBadge;

  @override
  Widget build(BuildContext context) {
    final qty = context.select<CartCubit, int>(
      (cart) => cart.state.qtyOf(product.id),
    );
    return BarqProductTile(
      name: product.name,
      price: product.price.formatted,
      compareAtPrice: product.compareAtPrice?.formatted,
      image: ProductArt(
        imageUrl: product.imageUrl,
        categoryIcon: product.categoryIcon,
      ),
      tile: ProductArt.tileOf(product.categoryIcon),
      topBadge: topBadge,
      large: large,
      height: large ? BarqSizes.featuredTile : BarqSizes.productTile,
      soldOut: !product.inStock,
      soldOutLabel: AppLocalizations.of(context).soldOut,
      quantityInCart: qty,
      onTap: () => context.push(Routes.productOf(product.id)),
      onAdd: () => addToCart(context, product),
    );
  }
}
