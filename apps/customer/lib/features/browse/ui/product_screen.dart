import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../cart/ui/add_to_cart.dart';
import '../data/browse_models.dart';
import '../state/product_cubit.dart';
import 'widgets/product_art.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DesignOverlay(
      image: 'design/02_browse_05.png',
      child: BarqScreen(
        body: BlocBuilder<ProductCubit, ProductState>(
          builder: (context, state) {
            final product = state.product;
            final error = state.error;
            if (product != null) {
              return _ProductView(product: product, state: state);
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BarqHeader(title: l10n.productTitle, back: true),
                Expanded(
                  child: error == null
                      ? const BarqLoadingView()
                      : BarqMessageView(
                          title: error,
                          icon: BarqIcons.alert,
                          actionLabel: l10n.commonRetry,
                          onAction: context.read<ProductCubit>().load,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProductView extends StatelessWidget {
  const _ProductView({required this.product, required this.state});

  final Product product;
  final ProductState state;

  Future<void> _add(BuildContext context) async {
    final added = await addToCart(
      context,
      product,
      qty: state.qty,
      options: state.optionsPayload,
      optionsLabel: state.optionsLabel,
      fromDetails: true,
    );
    if (added && context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ProductCubit>();
    final config = context.read<AppDependencies>().config;
    final cartMax = config.isLoaded ? config.config.cartMaxQty : 99;
    final stock = product.stock;
    final description = product.description;
    return BarqFillScroll(
      footer: Padding(
        padding: const EdgeInsets.fromLTRB(
          BarqSpacing.page,
          BarqSpacing.section,
          BarqSpacing.page,
          BarqSpacing.stateBottom,
        ),
        child: BarqButton(
          label: state.showsPrice
              ? l10n.addToCartPrice(product.price.formatted)
              : l10n.addToCart,
          onPressed: state.canAdd ? () => _add(context) : null,
        ),
      ),
      children: [
        BarqHeader(
          title: l10n.productTitle,
          back: true,
          trailing: BarqIconButton(
            icon: BarqIcons.bag,
            onPressed: () => context.push(Routes.cart),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            BarqSpacing.page,
            BarqSpacing.section,
            BarqSpacing.page,
            0,
          ),
          child: BarqGap(
            children: [
              BarqTileBackground(
                tile: ProductArt.tileOf(product.categoryIcon),
                height: BarqSizes.productHero,
                padding: const EdgeInsets.all(BarqSpacing.lg),
                child: Center(
                  child: ProductArt(
                    imageUrl: product.imageUrl,
                    categoryIcon: product.categoryIcon,
                  ),
                ),
              ),
              Text(product.name, style: BarqText.h1),
              Row(
                children: [
                  Expanded(
                    child: BarqPrice(
                      product.price.formatted,
                      compareAt: product.compareAtPrice?.formatted,
                      style: BarqText.h1,
                    ),
                  ),
                  if (product.inStock)
                    BarqQtyStepper(
                      value: state.qty,
                      min: 1,
                      max: stock != null && stock < cartMax ? stock : cartMax,
                      large: true,
                      onChanged: cubit.qtyChanged,
                    ),
                ],
              ),
              _StoreRow(vendor: state.vendor, inStock: product.inStock),
              for (final option in product.options)
                _OptionPicker(option: option, state: state),
              if (description != null && description.isNotEmpty)
                BarqGap(
                  gap: BarqSpacing.xxs,
                  children: [
                    Text(l10n.productDescription, style: BarqText.h3),
                    Text(description, style: BarqText.body),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StoreRow extends StatelessWidget {
  const _StoreRow({required this.vendor, required this.inStock});

  final Vendor? vendor;
  final bool inStock;

  String? _details(AppLocalizations l10n, Vendor store) {
    final prep = store.prepMinutes;
    final km = store.distanceKm;
    final parts = [
      if (prep != null) l10n.vendorPrep(prep),
      if (km != null) l10n.distanceKm(km.toStringAsFixed(1)),
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = vendor;
    final details = store == null ? null : _details(l10n, store);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: store == null
          ? null
          : () => context.push(Routes.vendorOf(store.id)),
      child: Row(
        children: [
          const BarqIconTile(BarqIcons.store, tone: BarqTileTone.neutral),
          const SizedBox(width: BarqSpacing.gap),
          Expanded(
            child: BarqGap(
              gap: 0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (store != null) Text(store.name, style: BarqText.h3),
                if (details != null) Text(details, style: BarqText.xs),
              ],
            ),
          ),
          BarqPill(
            inStock ? l10n.productAvailable : l10n.productUnavailable,
            tone: inStock ? BarqPillTone.success : BarqPillTone.danger,
          ),
        ],
      ),
    );
  }
}

class _OptionPicker extends StatelessWidget {
  const _OptionPicker({required this.option, required this.state});

  final ProductOption option;
  final ProductState state;

  /// The server's number decides the sign: an extra cost gets a plus.
  String? _extra(ProductChoice choice) {
    final amount = choice.price.amount;
    if (amount == 0) return null;
    return amount > 0 ? '+${choice.price.formatted}' : choice.price.formatted;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ProductCubit>();
    return BarqGap(
      gap: BarqSpacing.sm,
      children: [
        Text.rich(
          TextSpan(
            text: option.label,
            style: BarqText.h3,
            children: [
              if (option.isRequired)
                TextSpan(text: ' ${l10n.productRequired}', style: BarqText.xs),
            ],
          ),
        ),
        Wrap(
          spacing: BarqSpacing.sm,
          runSpacing: BarqSpacing.sm,
          children: [
            for (final choice in option.choices)
              BarqChip(
                label: choice.label,
                trailingText: _extra(choice),
                height: BarqSizes.optionChip,
                selected: state.isSelected(option, choice),
                onTap: () => cubit.toggle(option, choice),
              ),
          ],
        ),
      ],
    );
  }
}
