import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../cart/state/shop_scope_cubit.dart';

/// The bar with the cart's store and "كل المتاجر". Hidden while the cart is empty.
class ShopScopeBar extends StatelessWidget {
  const ShopScopeBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<ShopScopeCubit, ShopScope>(
      builder: (context, scope) {
        if (scope.vendorId == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            BarqSpacing.page,
            BarqSpacing.gap,
            BarqSpacing.page,
            0,
          ),
          child: BarqScopeBar(
            text: l10n.scopeShoppingFrom(
              scope.vendorName ?? l10n.scopeCartStore,
            ),
            action: scope.showAll ? l10n.scopeOnlyMine : l10n.scopeAllStores,
            onAction: context.read<ShopScopeCubit>().toggleAll,
          ),
        );
      },
    );
  }
}
