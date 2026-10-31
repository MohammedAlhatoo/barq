import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../browse/data/browse_models.dart';
import '../state/cart_cubit.dart';

/// The one way screens add to the cart. Answers true if the product was added.
/// Asks before emptying a cart of another store, and sends a product with
/// required choices to its page.
Future<bool> addToCart(
  BuildContext context,
  Product product, {
  int qty = 1,
  Map<String, Object> options = const {},
  String? optionsLabel,
  bool fromDetails = false,
}) async {
  if (product.needsChoice && !fromDetails) {
    context.push(Routes.productOf(product.id));
    return false;
  }
  final l10n = AppLocalizations.of(context);
  final cart = context.read<CartCubit>();
  final result = cart.add(
    product,
    qty: qty,
    options: options,
    optionsLabel: optionsLabel,
  );
  switch (result) {
    case AddResult.added:
      return true;
    case AddResult.limitReached:
      await showBarqSheet<void>(
        context,
        children: [
          Text(l10n.cartLimitTitle, style: BarqText.h2),
          Text(l10n.cartLimitBody, style: BarqText.body),
          BarqButton(
            label: l10n.commonOk,
            onPressed: () => closeBarqSheet<void>(context),
          ),
        ],
      );
      return false;
    case AddResult.otherStore:
      final replace = await showBarqSheet<bool>(
        context,
        children: [
          Text(l10n.otherStoreTitle, style: BarqText.h2),
          Text(l10n.otherStoreBody, style: BarqText.body),
          BarqButton(
            label: l10n.otherStoreConfirm,
            onPressed: () => closeBarqSheet(context, true),
          ),
          BarqButton(
            label: l10n.commonKeepCart,
            variant: BarqButtonVariant.light,
            onPressed: () => closeBarqSheet(context, false),
          ),
        ],
      );
      if (replace != true) return false;
      cart.replaceWith(
        product,
        qty: qty,
        options: options,
        optionsLabel: optionsLabel,
      );
      return true;
  }
}
