import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../app/router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../cart/data/cart_models.dart';
import '../../../cart/state/cart_cubit.dart';
import '../../../cart/ui/add_to_cart.dart';
import '../../data/browse_models.dart';
import 'product_art.dart';

/// A product row for search results and the store page.
class ProductRowCard extends StatelessWidget {
  const ProductRowCard({
    super.key,
    required this.product,
    this.subtitle,
    this.canOrder = true,
  });

  final Product product;
  final String? subtitle;

  /// False hides the add button (a closed store).
  final bool canOrder;

  Widget? _trailing(BuildContext context, CartLine? line) {
    if (!product.inStock) {
      return BarqPill(
        AppLocalizations.of(context).soldOut,
        tone: BarqPillTone.dark,
      );
    }
    if (!canOrder) return null;
    if (line == null) {
      return BarqPlusButton(onPressed: () => addToCart(context, product));
    }
    final config = context.read<AppDependencies>().config;
    return BarqQtyStepper(
      value: line.qty,
      max: config.isLoaded ? config.config.cartMaxQty : 99,
      trashAtOne: true,
      onChanged: (qty) => context.read<CartCubit>().setQty(line.key, qty),
    );
  }

  @override
  Widget build(BuildContext context) {
    final line = context.select<CartCubit, CartLine?>((cart) {
      final lines = cart.state.lines.where((l) => l.productId == product.id);
      // A product with choices can have several lines: its page handles those.
      return lines.length == 1 ? lines.first : null;
    });
    return BarqProductRow(
      thumb: BarqThumb(
        size: BarqSizes.rowThumb,
        tile: ProductArt.tileOf(product.categoryIcon),
        image: ProductArt(
          imageUrl: product.imageUrl,
          categoryIcon: product.categoryIcon,
        ),
      ),
      title: product.name,
      subtitle: subtitle,
      price: BarqPrice(
        product.price.formatted,
        compareAt: product.compareAtPrice?.formatted,
      ),
      trailing: _trailing(context, line),
      onTap: () => context.push(Routes.productOf(product.id)),
    );
  }
}
