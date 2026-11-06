import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../foundation/barq_theme.dart';
import '../foundation/barq_tokens.dart';

// Skeleton loading: the shape of a widget before its data arrives.
//
// Every skeleton here copies the padding, sizes and radius of the widget it
// stands for, so the screen keeps its layout when the data replaces it.
// Wrap a whole screen part in one [BarqSkeleton]: it runs one shimmer over
// all the bones inside it.

/// Runs a soft shimmer over the [BarqBone]s inside [child]. Without
/// animations (accessibility setting) the bones stay still.
class BarqSkeleton extends StatelessWidget {
  const BarqSkeleton({super.key, required this.child});

  final Widget child;

  static const _duration = Duration(milliseconds: 1400);

  @override
  Widget build(BuildContext context) {
    final still = ExcludeSemantics(child: IgnorePointer(child: child));
    if (MediaQuery.disableAnimationsOf(context)) return still;
    final p = BarqPalette.of(context);
    return Animate(
      onPlay: (controller) => controller.repeat(),
      effects: [
        ShimmerEffect(
          duration: _duration,
          color: p.isDark ? const Color(0x1FFFFFFF) : const Color(0xB3FFFFFF),
          size: 1.2,
        ),
      ],
      child: still,
    );
  }
}

/// A grey block. Use [circle] for avatars and round buttons.
class BarqBone extends StatelessWidget {
  const BarqBone({
    super.key,
    this.width,
    this.height,
    this.radius = 8,
    this.circle = false,
    this.color,
  });

  /// A round bone of [size].
  const BarqBone.circle(double size, {super.key, this.color})
      : width = size,
        height = size,
        radius = 0,
        circle = true;

  final double? width;
  final double? height;
  final double radius;
  final bool circle;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color ?? BarqPalette.of(context).progressOff,
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circle ? null : BorderRadius.circular(radius),
        ),
      );
}

/// One line of text in [style]. It takes the line's real height, so the
/// rows around it do not move, and draws a thinner bar in the middle.
class BarqTextBone extends StatelessWidget {
  const BarqTextBone(
    this.style, {
    super.key,
    this.width,
    this.widthFactor,
    this.color,
    this.center = false,
  });

  final TextStyle style;

  /// Centers the bar, for centered text.
  final bool center;

  /// A fixed width, or [widthFactor] of the space, or the full space.
  final double? width;
  final double? widthFactor;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final size = style.fontSize ?? 14;
    final line = size * (style.height ?? 1.2);
    final bar = BarqBone(height: size * .72, radius: size, color: color);
    return SizedBox(
      height: line,
      child: Align(
        alignment:
            center ? Alignment.center : AlignmentDirectional.centerStart,
        child: width != null
            ? SizedBox(width: width, child: bar)
            : FractionallySizedBox(widthFactor: widthFactor ?? 1, child: bar),
      ),
    );
  }
}

/// The empty frame of a [BarqCard]: same padding, radius, color and shadow.
class BarqCardBone extends StatelessWidget {
  const BarqCardBone({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = BarqRadius.card,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: p.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

/// A screen part that is still loading: it never scrolls, and anything past
/// the bottom is cut off. Use it inside an `Expanded` or a fixed height.
class BarqSkeletonPage extends StatelessWidget {
  const BarqSkeletonPage({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: BarqSpacing.page),
    this.gap = BarqSpacing.gap,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double gap;

  @override
  Widget build(BuildContext context) => BarqSkeleton(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: padding,
          child: BarqSkeletonColumn(gap: gap, children: children),
        ),
      );
}

/// [count] copies of [item] with [gap] between them, like the real list.
/// It does not scroll: put it in a [BarqSkeletonPage] or a scroll view.
class BarqSkeletonList extends StatelessWidget {
  const BarqSkeletonList({
    super.key,
    required this.item,
    this.count = 5,
    this.gap = BarqSpacing.md,
    this.padding = EdgeInsets.zero,
  });

  final Widget item;
  final int count;
  final double gap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding,
        child: BarqSkeletonColumn(
          gap: gap,
          children: [for (var i = 0; i < count; i++) item],
        ),
      );
}

/// A column with a fixed [gap], stretched to the full width.
class BarqSkeletonColumn extends StatelessWidget {
  const BarqSkeletonColumn({
    super.key,
    required this.children,
    this.gap = BarqSpacing.gap,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });

  final List<Widget> children;
  final double gap;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: gap),
            children[i],
          ],
        ],
      );
}

// ── Matching skeletons ─────────────────────────────────────────────────────

/// Stands for [BarqProductTile]: the tile, the picture inset by 8 with radius
/// 14, and the glass footer with the name, store line, price and plus button.
class BarqProductTileSkeleton extends StatelessWidget {
  const BarqProductTileSkeleton({
    super.key,
    this.width,
    this.height = BarqSizes.productTile,
    this.showStore = true,
    this.showAdd = true,
  });

  final double? width;
  final double height;
  final bool showStore;
  final bool showAdd;

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: p.progressOff.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(BarqRadius.productTile),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 8,
            right: 8,
            top: 8,
            bottom: showStore ? 88 : 70,
            child: const BarqBone(radius: BarqRadius.productImage),
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: BorderRadius.circular(BarqRadius.productGlass),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BarqTextBone(BarqText.h3.copyWith(fontSize: 15),
                            widthFactor: .85),
                        if (showStore)
                          const BarqTextBone(BarqText.xs, widthFactor: .55),
                        const BarqTextBone(BarqText.tBold, widthFactor: .4),
                      ],
                    ),
                  ),
                  if (showAdd) const BarqBone.circle(BarqSizes.plusSmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Two columns of [BarqProductTileSkeleton], for a CustomScrollView. Same
/// grid as the product grid: page padding, 12 gaps, tile height.
class BarqProductGridSkeleton extends StatelessWidget {
  const BarqProductGridSkeleton({
    super.key,
    this.count = 6,
    this.showStore = true,
  });

  final int count;
  final bool showStore;

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
          itemCount: count,
          itemBuilder: (_, __) => BarqSkeleton(
            child: BarqProductTileSkeleton(showStore: showStore),
          ),
        ),
      );
}

/// A horizontal strip of [count] items of [itemWidth], like the home rows.
class BarqHorizontalSkeleton extends StatelessWidget {
  const BarqHorizontalSkeleton({
    super.key,
    required this.height,
    required this.itemWidth,
    required this.item,
    this.count = 4,
  });

  final double height;
  final double itemWidth;
  final Widget item;
  final int count;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: BarqSpacing.page),
          clipBehavior: Clip.none,
          itemCount: count,
          separatorBuilder: (_, __) => const SizedBox(width: BarqSpacing.gap),
          itemBuilder: (_, __) => SizedBox(width: itemWidth, child: item),
        ),
      );
}

/// Stands for [BarqSectionHeader] with its "see all" link.
class BarqSectionHeaderSkeleton extends StatelessWidget {
  const BarqSectionHeaderSkeleton({super.key, this.action = true});

  final bool action;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: BarqSpacing.page),
        child: Row(
          children: [
            const Expanded(child: BarqTextBone(BarqText.h2, widthFactor: .45)),
            if (action) const BarqTextBone(BarqText.link, width: 54),
          ],
        ),
      );
}

/// Stands for [BarqChipsRow]: pill chips 44 high, 10 apart.
class BarqChipsSkeleton extends StatelessWidget {
  const BarqChipsSkeleton({
    super.key,
    this.widths = const [64, 92, 80, 104, 76],
    this.padding = const EdgeInsets.symmetric(
        horizontal: BarqSpacing.page, vertical: 8),
  });

  final List<double> widths;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding,
        child: SizedBox(
         height: BarqSizes.chip,
         child: ClipRect(
          child: OverflowBox(
            alignment: AlignmentDirectional.centerStart,
            maxWidth: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < widths.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  BarqBone(
                      width: widths[i],
                      height: BarqSizes.chip,
                      radius: BarqRadius.pill),
                ],
              ],
            ),
          ),
         ),
        ),
      );
}

/// Stands for [BarqProductRow] with a [BarqThumb]: card padding 10, thumb
/// radius 18, title, subtitle, price, and a plus button.
class BarqProductRowSkeleton extends StatelessWidget {
  const BarqProductRowSkeleton({
    super.key,
    this.thumb = BarqSizes.rowThumb,
    this.subtitle = true,
    this.price = true,
    this.trailing = true,
  });

  final double thumb;
  final bool subtitle;
  final bool price;
  final bool trailing;

  @override
  Widget build(BuildContext context) => BarqCardBone(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            BarqBone(width: thumb, height: thumb, radius: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  BarqTextBone(BarqText.h3.copyWith(fontSize: 15),
                      widthFactor: .7),
                  if (subtitle)
                    const BarqTextBone(BarqText.xs, widthFactor: .5),
                  if (price) ...[
                    const SizedBox(height: 4),
                    const BarqTextBone(BarqText.tBold, width: 48),
                  ],
                ],
              ),
            ),
            if (trailing) ...[
              const SizedBox(width: 8),
              const BarqBone.circle(BarqSizes.plus),
            ],
          ],
        ),
      );
}

/// Stands for [BarqVendorCard]: logo 46, two-line name, meta line.
class BarqVendorCardSkeleton extends StatelessWidget {
  const BarqVendorCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const BarqCardBone(
        padding: EdgeInsets.all(BarqSpacing.gap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                BarqBone(
                    width: BarqSizes.storeLogo,
                    height: BarqSizes.storeLogo,
                    radius: BarqRadius.productGlass),
                SizedBox(width: BarqSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BarqTextBone(BarqText.h3),
                      BarqTextBone(BarqText.h3, widthFactor: .6),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: BarqSpacing.sm),
            BarqMetaSkeleton(),
          ],
        ),
      );
}

/// Stands for [BarqVendorRow]: logo 62, name with the open pill, category,
/// meta line.
class BarqVendorRowSkeleton extends StatelessWidget {
  const BarqVendorRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const BarqCardBone(
        padding: EdgeInsets.all(BarqSpacing.gap),
        child: Row(
          children: [
            BarqBone(
                width: BarqSizes.vendorRowLogo,
                height: BarqSizes.vendorRowLogo,
                radius: BarqRadius.productGlass),
            SizedBox(width: BarqSpacing.gap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: BarqTextBone(BarqText.h3, widthFactor: .7)),
                      SizedBox(width: BarqSpacing.sm),
                      BarqPillBone(),
                    ],
                  ),
                  BarqTextBone(BarqText.xs, widthFactor: .4),
                  SizedBox(height: BarqSpacing.xs),
                  BarqMetaSkeleton(),
                ],
              ),
            ),
          ],
        ),
      );
}

/// Stands for [BarqMetaRow]: the details line of a store (rating · time ·
/// distance), text size 13, 14 apart.
class BarqMetaSkeleton extends StatelessWidget {
  const BarqMetaSkeleton({super.key});

  static const _style = TextStyle(fontSize: 13, height: 1.4);

  @override
  Widget build(BuildContext context) => const Row(
        children: [
          BarqTextBone(_style, width: 38),
          SizedBox(width: 14),
          BarqTextBone(_style, width: 52),
          SizedBox(width: 14),
          BarqTextBone(_style, width: 44),
        ],
      );
}

/// Stands for a [BarqPill].
class BarqPillBone extends StatelessWidget {
  const BarqPillBone({super.key, this.width = 52});

  final double width;

  @override
  Widget build(BuildContext context) =>
      BarqBone(width: width, height: 26, radius: BarqRadius.pill);
}

/// The common list row: an icon tile (46, radius 16), a title, and [lines]
/// small lines under it, inside a card. Used for orders, notifications,
/// history, and settings rows.
class BarqTileRowSkeleton extends StatelessWidget {
  const BarqTileRowSkeleton({
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.lines = 1,
    this.trailing,
    this.tile = BarqSizes.iconTile,
    this.card = true,
  });

  final EdgeInsetsGeometry padding;

  /// Small lines under the title.
  final int lines;

  /// What sits at the end, such as a [BarqPillBone].
  final Widget? trailing;
  final double tile;

  /// False draws the row alone, for rows inside one shared card.
  final bool card;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        BarqBone(width: tile, height: tile, radius: BarqRadius.iconTile),
        const SizedBox(width: BarqSpacing.gap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const BarqTextBone(BarqText.h3, widthFactor: .55),
              for (var i = 0; i < lines; i++)
                BarqTextBone(BarqText.xs, widthFactor: i == 0 ? .8 : .5),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: BarqSpacing.sm),
          trailing!,
        ],
      ],
    );
    return card
        ? BarqCardBone(padding: padding, child: row)
        : Padding(padding: padding, child: row);
  }
}

/// Stands for [BarqAddressCard]: icon tile, title, two detail lines, and the
/// edit and delete buttons (or a radio when [radio]).
class BarqAddressCardSkeleton extends StatelessWidget {
  const BarqAddressCardSkeleton({super.key, this.radio = false});

  final bool radio;

  @override
  Widget build(BuildContext context) => BarqCardBone(
        padding: const EdgeInsets.symmetric(
            horizontal: BarqSpacing.section, vertical: 14),
        child: Row(
          children: [
            const BarqBone(
                width: BarqSizes.iconTile,
                height: BarqSizes.iconTile,
                radius: BarqRadius.iconTile),
            const SizedBox(width: BarqSpacing.gap),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BarqTextBone(BarqText.h3, widthFactor: .45),
                  BarqTextBone(BarqText.xs, widthFactor: .9),
                  BarqTextBone(BarqText.xs, widthFactor: .6),
                ],
              ),
            ),
            const SizedBox(width: BarqSpacing.sm),
            if (radio)
              const BarqBone.circle(24)
            else ...[
              const BarqBone.circle(BarqSizes.addressAction),
              const SizedBox(width: BarqSpacing.xs),
              const BarqBone.circle(BarqSizes.addressAction),
            ],
          ],
        ),
      );
}

/// Stands for a card of totals or a receipt: an optional header row, then
/// [rows] lines of a label and an amount, and a bold total.
class BarqSummaryCardSkeleton extends StatelessWidget {
  const BarqSummaryCardSkeleton({
    super.key,
    this.rows = 3,
    this.header = false,
    this.total = true,
  });

  final int rows;
  final bool header;
  final bool total;

  @override
  Widget build(BuildContext context) => BarqCardBone(
        child: BarqSkeletonColumn(
          gap: BarqSpacing.sm,
          children: [
            if (header) ...[
              const Row(
                children: [
                  BarqBone(width: 76, height: 32, radius: 10),
                  Spacer(),
                  BarqPillBone(width: 70),
                ],
              ),
              const BarqTextBone(BarqText.xs, widthFactor: .5),
              const BarqBone(height: 1.5, radius: 1),
            ],
            for (var i = 0; i < rows; i++) _row(i.isEven ? .45 : .35, 44),
            if (total) ...[
              const BarqBone(height: 1.5, radius: 1),
              _row(.3, 60, style: BarqText.h3),
            ],
          ],
        ),
      );

  Widget _row(double label, double amount, {TextStyle style = BarqText.t}) =>
      Row(
        children: [
          Expanded(child: BarqTextBone(style, widthFactor: label)),
          BarqTextBone(style, width: amount),
        ],
      );
}

/// Stands for [BarqProfileCard] (customer account): the orange banner with
/// the avatar, name, phone, edit button and the stat boxes.
class BarqProfileCardSkeleton extends StatelessWidget {
  const BarqProfileCardSkeleton({super.key, this.stats = 3});

  final int stats;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: BarqPalette.of(context).progressOff.withValues(alpha: .6),
          borderRadius: BorderRadius.circular(BarqRadius.profileCard),
        ),
        child: BarqSkeletonColumn(
          children: [
            Row(
              children: [
                const BarqBone.circle(BarqSizes.profileAvatar),
                const SizedBox(width: BarqSpacing.gap),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BarqTextBone(BarqText.h2, widthFactor: .6),
                      BarqTextBone(BarqText.t, widthFactor: .45),
                    ],
                  ),
                ),
                BarqBone(
                    width: BarqSizes.iconButton,
                    height: BarqSizes.iconButton,
                    radius: BarqRadius.iconTile,
                    color: BarqPalette.of(context).card),
              ],
            ),
            if (stats > 0)
              Row(
                children: [
                  for (var i = 0; i < stats; i++) ...[
                    if (i > 0) const SizedBox(width: BarqSpacing.sm),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(BarqSpacing.md),
                        decoration: BoxDecoration(
                          color: BarqPalette.of(context).card,
                          borderRadius:
                              BorderRadius.circular(BarqRadius.profileStat),
                        ),
                        child: const Column(
                          children: [
                            BarqTextBone(BarqText.h2, width: 30),
                            BarqTextBone(BarqText.xs, width: 50),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      );
}

/// Stands for a card of settings rows ([BarqListTile] with an icon tile).
class BarqListCardSkeleton extends StatelessWidget {
  const BarqListCardSkeleton({super.key, this.rows = 4});

  final int rows;

  @override
  Widget build(BuildContext context) => BarqCardBone(
        padding: const EdgeInsets.symmetric(
            horizontal: BarqSpacing.section, vertical: BarqSpacing.xxs),
        child: Column(
          children: [
            for (var i = 0; i < rows; i++)
              const BarqTileRowSkeleton(
                card: false,
                lines: 0,
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
          ],
        ),
      );
}

/// Stands for a text field: the label line and a 58 high box.
class BarqInputSkeleton extends StatelessWidget {
  const BarqInputSkeleton({super.key, this.label = true});

  final bool label;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label) ...[
            const BarqTextBone(BarqText.t, widthFactor: .3),
            const SizedBox(height: BarqSpacing.sm),
          ],
          const BarqBone(height: BarqSizes.input, radius: BarqRadius.input),
        ],
      );
}

/// Stands for a full-width [BarqButton] (58 high, pill).
class BarqButtonSkeleton extends StatelessWidget {
  const BarqButtonSkeleton({super.key, this.height = BarqSizes.button});

  final double height;

  @override
  Widget build(BuildContext context) =>
      BarqBone(height: height, radius: BarqRadius.pill);
}

/// Stands for a block of text: a heading and [lines] body lines.
class BarqTextBlockSkeleton extends StatelessWidget {
  const BarqTextBlockSkeleton({
    super.key,
    this.title = BarqText.h1,
    this.lines = 2,
    this.center = false,
  });

  final TextStyle title;
  final int lines;
  final bool center;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          BarqTextBone(title, widthFactor: .6, center: center),
          const SizedBox(height: BarqSpacing.xs),
          for (var i = 0; i < lines; i++)
            BarqTextBone(BarqText.body,
                widthFactor: i == lines - 1 ? .55 : .9, center: center),
        ],
      );
}

/// Stands for [BarqStepProgress]: [count] bars 6 high, 6 apart, with the
/// small labels under them when [labels].
class BarqStepProgressSkeleton extends StatelessWidget {
  const BarqStepProgressSkeleton({super.key, this.count = 4, this.labels = true});

  final int count;
  final bool labels;

  static const _label = TextStyle(fontSize: 10.5, height: 1.4);

  Widget _row(Widget Function() item) => Row(
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(child: item()),
          ],
        ],
      );

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _row(() => const BarqBone(height: 6, radius: 9)),
          if (labels) ...[
            const SizedBox(height: 6),
            _row(() =>
                const BarqTextBone(_label, widthFactor: .7, center: true)),
          ],
        ],
      );
}

/// One more row of two product tiles, under a product grid that is loading
/// its next page.
class BarqProductPairSkeleton extends StatelessWidget {
  const BarqProductPairSkeleton({super.key, this.showStore = true});

  final bool showStore;

  @override
  Widget build(BuildContext context) => BarqSkeleton(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              BarqSpacing.page, BarqSpacing.gap, BarqSpacing.page, 0),
          child: Row(
            children: [
              Expanded(child: BarqProductTileSkeleton(showStore: showStore)),
              const SizedBox(width: BarqSpacing.gap),
              Expanded(child: BarqProductTileSkeleton(showStore: showStore)),
            ],
          ),
        ),
      );
}

/// A map screen that is loading: the map fills the space and a bottom sheet
/// (radius 34) holds [children]. Use it inside an `Expanded`.
class BarqMapSheetSkeleton extends StatelessWidget {
  const BarqMapSheetSkeleton({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    return BarqSkeleton(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ColoredBox(color: p.progressOff.withValues(alpha: .5)),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(BarqSpacing.page,
                BarqSpacing.section, BarqSpacing.page, BarqSpacing.formBottom),
            decoration: BoxDecoration(
              color: p.sheet,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(BarqRadius.sheet)),
            ),
            child: BarqSkeletonColumn(children: [
              const Center(child: BarqBone(width: 44, height: 5, radius: 3)),
              ...children,
            ]),
          ),
        ],
      ),
    );
  }
}

/// A waiting or result page while it loads: the round picture, the centered
/// title and text, and the card under them.
class BarqStatePageSkeleton extends StatelessWidget {
  const BarqStatePageSkeleton({super.key, this.art = 180, this.cardRows = 2});

  final double art;
  final int cardRows;

  @override
  Widget build(BuildContext context) => BarqSkeletonPage(
        padding: const EdgeInsets.fromLTRB(
            BarqSpacing.page, BarqSpacing.section, BarqSpacing.page, 0),
        gap: BarqSpacing.section,
        children: [
          Center(child: BarqBone.circle(art)),
          const BarqTextBlockSkeleton(center: true),
          BarqSummaryCardSkeleton(rows: cardRows, total: false),
        ],
      );
}
