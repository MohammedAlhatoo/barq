import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../browse/ui/widgets/product_art.dart';
import '../data/cart_models.dart';
import '../state/cart_cubit.dart';
import '../state/cart_summary_cubit.dart';
import 'widgets/empty_cart_view.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _confirmClear(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cart = context.read<CartCubit>();
    final clear = await showBarqSheet<bool>(
      context,
      children: [
        Text(l10n.cartClearTitle, style: BarqText.h2),
        Text(l10n.cartClearBody, style: BarqText.body),
        BarqButton(
          label: l10n.cartClearConfirm,
          variant: BarqButtonVariant.red,
          onPressed: () => closeBarqSheet(context, true),
        ),
        BarqButton(
          label: l10n.commonKeepCart,
          variant: BarqButtonVariant.light,
          onPressed: () => closeBarqSheet(context, false),
        ),
      ],
    );
    if (clear == true) cart.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<CartCubit, Cart>(
      listener: (context, cart) =>
          context.read<CartSummaryCubit>().refresh(cart),
      builder: (context, cart) {
        if (cart.isEmpty) return const EmptyCartView();
        final compare = ConfigScope.of(context).config
            .hasModule('basket_compare');
        return DesignOverlay(
          image: 'design/03_checkout_01.png',
          child: BarqScreen(
            bottomSheet: const _CartSheet(),
            body: ListView(
              padding: const EdgeInsets.only(
                bottom: BarqSpacing.cartSheetClearance,
              ),
              children: [
                BarqHeader(
                  title: l10n.cartTitle,
                  back: true,
                  trailing: BarqIconButton(
                    icon: BarqIcons.trash,
                    onPressed: () => _confirmClear(context),
                  ),
                  bottom: _CartStore(count: cart.count),
                ),
                BarqGap(
                  gap: BarqSpacing.sm,
                  padding: const EdgeInsets.fromLTRB(
                    BarqSpacing.page,
                    BarqSpacing.gap,
                    BarqSpacing.page,
                    0,
                  ),
                  children: [
                    for (final (index, line) in cart.lines.indexed)
                      BarqStaggerItem(
                        group: 'cart-lines',
                        index: index,
                        child: _CartLineRow(line: line),
                      ),
                    if (compare) const _CompareCard(),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CartStore extends StatelessWidget {
  const _CartStore({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final name = context.select<CartSummaryCubit, String?>(
      (summary) => summary.state.vendorName,
    );
    return Row(
      children: [
        if (name != null) ...[
          Flexible(
            child: BarqPill(
              name,
              tone: BarqPillTone.white,
              icon: BarqIcons.store,
              iconColor: BarqColors.primary,
            ),
          ),
          const SizedBox(width: BarqSpacing.sm),
        ],
        Text(AppLocalizations.of(context).cartCount(count), style: BarqText.xs),
      ],
    );
  }
}

class _CartLineRow extends StatelessWidget {
  const _CartLineRow({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context) {
    final config = context.read<AppDependencies>().config;
    return BarqProductRow(
      thumb: BarqThumb(
        size: BarqSizes.cartThumb,
        radius: BarqRadius.iconTile,
        tile: ProductArt.tileOf(line.categoryIcon),
        image: ProductArt(
          imageUrl: line.imageUrl,
          categoryIcon: line.categoryIcon,
        ),
      ),
      title: line.name,
      subtitle: line.optionsLabel,
      // The price of one piece: only the server may multiply.
      price: BarqPrice(line.unitPrice.formatted),
      trailing: BarqQtyStepper(
        value: line.qty,
        max: config.isLoaded ? config.config.cartMaxQty : 99,
        trashAtOne: true,
        onChanged: (qty) => context.read<CartCubit>().setQty(line.key, qty),
      ),
    );
  }
}

class _CompareCard extends StatelessWidget {
  const _CompareCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BarqCard(
      color: BarqColors.ink,
      // The address may have changed there, and the total depends on it.
      onTap: () async {
        final summary = context.read<CartSummaryCubit>();
        final cart = context.read<CartCubit>();
        await context.push(Routes.compare);
        summary.refresh(cart.state);
      },
      child: Row(
        children: [
          const BarqIconTile(BarqIcons.percent, tone: BarqTileTone.darkOrange),
          const SizedBox(width: BarqSpacing.gap),
          Expanded(
            child: BarqGap(
              gap: 0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.cartCompareTitle,
                  style: BarqText.h3.copyWith(color: BarqColors.white),
                ),
                Text(
                  l10n.cartCompareBody,
                  style: BarqText.xs.copyWith(color: BarqColors.onDarkMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: BarqSpacing.sm),
          const BarqIconButton(
            icon: BarqIcons.chev,
            size: BarqSizes.compareArrow,
            background: BarqColors.white,
            iconColor: BarqColors.ink,
          ),
        ],
      ),
    );
  }
}

class _CartSheet extends StatelessWidget {
  const _CartSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final quote = context.select<CartSummaryCubit, Quote?>(
      (summary) => summary.state.quote,
    );
    return BarqSheet(
      showGrab: false,
      gap: BarqSpacing.gap,
      children: [
        if (quote == null) ...[
          BarqSummaryRow(l10n.cartTotal, l10n.cartAtCheckout),
          BarqSummaryRow(l10n.cartDelivery, l10n.cartAtCheckout),
        ] else ...[
          BarqSummaryRow(l10n.cartTotal, quote.itemsTotal.formatted),
          BarqSummaryRow(
            l10n.cartWithDelivery,
            quote.total.formatted,
            total: true,
          ),
        ],
        BarqButton(
          label: quote == null
              ? l10n.cartContinue
              : l10n.cartContinueTotal(quote.total.formatted),
          onPressed: () => context.push(Routes.checkout),
        ),
      ],
    );
  }
}
