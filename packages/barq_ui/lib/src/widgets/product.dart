import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../foundation/barq_assets.dart';
import '../foundation/barq_theme.dart';
import '../foundation/barq_tokens.dart';
import 'buttons.dart';
import 'indicators.dart';
import 'layout.dart';
import 'surfaces.dart';

/// A picture from the server. [fallback] is only for an item with no [url]:
/// loading shows a small spinner, and a broken link a neutral icon.
class BarqNetworkImage extends StatelessWidget {
  const BarqNetworkImage(
      {super.key, required this.url, required this.fallback});

  final String? url;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    final link = url;
    if (link == null || link.isEmpty) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(BarqRadius.productGlass),
      child: Image.network(
        link,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : const Center(
                child: SizedBox.square(
                  dimension: BarqSizes.iconM,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: BarqColors.primary),
                ),
              ),
        errorBuilder: (context, error, stack) => const Center(
          child: BarqIcon('package',
              size: BarqSizes.iconL, color: BarqColors.placeholder),
        ),
      ),
    );
  }
}

/// A block with a product tile color: product picture, store hero, the top of
/// the best-basket card.
class BarqTileBackground extends StatelessWidget {
  const BarqTileBackground(
      {super.key,
      required this.child,
      this.tile = BarqTileColor.pink,
      this.height,
      this.radius = BarqRadius.productTile,
      this.padding = EdgeInsets.zero});

  final Widget child;
  final BarqTileColor tile;
  final double? height;
  final double radius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        padding: padding,
        decoration: BoxDecoration(
            gradient: tile.gradient,
            borderRadius: BorderRadius.circular(radius)),
        child: child,
      );
}

/// Colored rounded square holding a product picture (list rows, cart, receipt).
/// [image] is usually `Image.network(product.imageUrl)` or a [BarqIllustration].
class BarqThumb extends StatelessWidget {
  const BarqThumb(
      {super.key,
      required this.image,
      this.size = 70,
      this.tile = BarqTileColor.pink,
      this.radius = 18,
      this.color});

  final Widget image;
  final double size;
  final BarqTileColor tile;
  final double radius;

  /// Solid color instead of the tile gradient (e.g. white thumb inside a tinted row).
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * .1),
        decoration: BoxDecoration(
          gradient: color == null ? tile.gradient : null,
          color: color,
          borderRadius: BorderRadius.circular(radius),
        ),
        clipBehavior: Clip.antiAlias,
        child: image,
      );
}

/// .pc — product tile for grids / horizontal lists: colored background,
/// big picture, glass footer with name + price and the orange "+" button.
class BarqProductTile extends StatelessWidget {
  const BarqProductTile({
    super.key,
    required this.name,
    required this.price,
    required this.image,
    this.tile = BarqTileColor.pink,
    this.compareAtPrice,
    this.unit,
    this.vendorName,
    this.vendorMuted = false,
    this.showStore = true,
    this.badge,
    this.topBadge,
    this.isFavorite,
    this.onFavorite,
    this.onAdd,
    this.onTap,
    this.quantityInCart = 0,
    this.soldOut = false,
    this.soldOutLabel = 'نفدت الكمية',
    this.width,
    this.height = 186,
    this.large = false,
  });

  final String name;

  /// Formatted price, e.g. "₪6".
  final String price;
  final Widget image;
  final BarqTileColor tile;

  /// Formatted compare-at price (struck through), e.g. "₪8".
  final String? compareAtPrice;

  /// e.g. "/ كغ"
  final String? unit;

  /// The store selling it, under the name.
  final String? vendorName;

  /// Greys the store name: not the store the user is shopping from.
  final bool vendorMuted;

  /// Whether to show the store line under the product name.
  final bool showStore;

  /// Discount badge text, e.g. "−25%" (green pill, top-left).
  final String? badge;

  /// Dark promo pill, e.g. "عرض اليوم −20%" (featured card).
  final String? topBadge;

  /// null = hide the heart.
  final bool? isFavorite;
  final VoidCallback? onFavorite;
  final VoidCallback? onAdd;
  final VoidCallback? onTap;

  /// > 0 shows the quantity in a black circle instead of "+".
  final int quantityInCart;
  final bool soldOut;
  final String soldOutLabel;
  final double? width;
  final double height;

  /// Featured size (home "عرض اليوم" card): bigger name + plus.
  final bool large;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            gradient: tile.gradient,
            borderRadius: BorderRadius.circular(BarqRadius.productTile)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              left: large ? 30 : 16,
              right: large ? 30 : 16,
              top: large ? 30 : 8,
              // The footer is taller with the store line.
              bottom: (showStore && vendorName != null) ? 88 : 70,
              child: Opacity(
                opacity: soldOut ? .45 : 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(BarqRadius.productGlass),
                  child: image,
                ),
              ),
            ),
            if (isFavorite != null)
              PositionedDirectional(
                top: 12,
                start: 12,
                child: GestureDetector(
                  onTap: onFavorite,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                        color: Color(0xB3FFFFFF), shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: BarqIcon(
                      isFavorite!
                          ? BarqIconsInternal.heartFilled
                          : BarqIconsInternal.heart,
                      size: BarqSizes.iconM,
                      color: isFavorite! ? BarqColors.dotRed : BarqColors.ink,
                    ),
                  ),
                ),
              ),
            if (badge != null)
              PositionedDirectional(
                  top: 12,
                  end: 12,
                  child: BarqPill(badge!, tone: BarqPillTone.successSolid)),
            if (topBadge != null)
              PositionedDirectional(
                  top: 18,
                  end: 16,
                  child: BarqPill(topBadge!, tone: BarqPillTone.dark)),
            if (soldOut)
              Positioned.fill(
                bottom: 60,
                child: Center(
                    child: BarqPill(soldOutLabel, tone: BarqPillTone.dark)),
              ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: _GlassFooter(
                child: Opacity(
                  opacity: soldOut ? .6 : 1,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: BarqText.h3
                                    .copyWith(fontSize: large ? 16 : 15)),
                            if (showStore && vendorName != null)
                              Text(vendorName!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: BarqText.xs.copyWith(
                                      color: vendorMuted
                                          ? BarqColors.placeholder
                                          : BarqColors.ink)),
                            BarqPrice(price,
                                compareAt: compareAtPrice,
                                unit: unit,
                                color: soldOut
                                    ? BarqColors.placeholder
                                    : BarqColors.ink),
                          ],
                        ),
                      ),
                      if (!soldOut && onAdd != null)
                        BarqPlusButton(
                            onPressed: onAdd,
                            small: !large,
                            count: quantityInCart),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassFooter extends StatelessWidget {
  const _GlassFooter({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(BarqRadius.productGlass),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0x8CFFFFFF),
              borderRadius: BorderRadius.circular(BarqRadius.productGlass),
              border: Border.all(color: const Color(0xBFFFFFFF)),
            ),
            child: child,
          ),
        ),
      );
}

/// Product/list row inside a white card: thumb · title/subtitle/price · trailing
/// (plus button, qty stepper, price…). Used in search results, store page, cart,
/// offer screen, driver order items.
class BarqProductRow extends StatelessWidget {
  const BarqProductRow({
    super.key,
    required this.thumb,
    required this.title,
    this.subtitle,
    this.price,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.all(10),
    this.titleStyle,
    this.extra,
  });

  /// Usually a [BarqThumb].
  final Widget thumb;
  final String title;
  final String? subtitle;

  /// Usually a [BarqPrice].
  final Widget? price;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final TextStyle? titleStyle;

  /// Extra line under the title (e.g. "البديل: صدر دجاج", status pill).
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    return BarqCard(
      padding: padding,
      onTap: onTap,
      child: Row(
        children: [
          thumb,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: (titleStyle ?? BarqText.h3.copyWith(fontSize: 15))
                        .copyWith(color: p.text)),
                if (subtitle != null)
                  Text(subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: BarqText.xs.copyWith(color: p.textMuted)),
                if (extra != null)
                  Padding(
                      padding: const EdgeInsets.only(top: 4), child: extra!),
                if (price != null)
                  Padding(
                      padding: const EdgeInsets.only(top: 4), child: price!),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

/// A horizontal section with a header title and a horizontally scrolling list of items.
class BarqHorizontalSection extends StatelessWidget {
  const BarqHorizontalSection({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    required this.items,
    this.loading = false,
    this.error,
    this.onRetry,
    this.height = BarqSizes.productTile,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;
  final List<Widget> items;
  final bool loading;
  final String? error;
  final VoidCallback? onRetry;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && !loading && error == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        BarqSectionHeader(title, action: action, onAction: onAction),
        const SizedBox(height: BarqSpacing.gap),
        SizedBox(
          height: height,
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(color: BarqColors.primary),
                )
              : error != null
                  ? Center(
                      child: Text(error!,
                          style:
                              BarqText.body.copyWith(color: BarqColors.danger)),
                    )
                  : items.isEmpty
                      ? const SizedBox.shrink()
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: BarqSpacing.page),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: BarqSpacing.gap),
                          itemBuilder: (_, index) => items[index],
                        ),
        ),
      ],
    );
  }
}
