import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../cart/state/cart_cubit.dart';
import '../../../cart/state/shop_scope_cubit.dart';
import '../../../cart/ui/add_to_cart.dart';
import '../../data/browse_models.dart';
import 'product_art.dart';

/// A product tile for grids and the home row.
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final qty = context.select<CartCubit, int>(
      (cart) => cart.state.qtyOf(product.id),
    );
    final cartStore = context.select<ShopScopeCubit, int?>(
      (scope) => scope.state.vendorId,
    );
    return BarqProductTile(
      name: product.name,
      price: product.price.formatted,
      compareAtPrice: product.compareAtPrice?.formatted,
      vendorName: product.vendorName,
      vendorMuted: cartStore != null && cartStore != product.vendorId,
      image: ProductArt(
        imageUrl: product.imageUrl,
        categoryIcon: product.categoryIcon,
      ),
      tile: ProductArt.tileOf(product.categoryIcon),
      height: BarqSizes.productTile,
      soldOut: !product.inStock,
      soldOutLabel: AppLocalizations.of(context).soldOut,
      quantityInCart: qty,
      onTap: () => context.push(Routes.productOf(product.id)),
      onAdd: () => addToCart(context, product),
    );
  }
}
