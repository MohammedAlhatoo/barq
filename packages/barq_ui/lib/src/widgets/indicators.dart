import 'package:flutter/material.dart';

import '../foundation/barq_assets.dart';
import '../foundation/barq_theme.dart';
import '../foundation/barq_tokens.dart';
import 'buttons.dart';

enum BarqPillTone {
  /// green (.pill.ok) — "تم التوصيل", "داخل منطقة الخدمة"
  success,

  /// orange (.pill.or) — "في الطريق", counters
  orange,

  /// red (.pill.no) — "ملغي", "غير متوفر"
  danger,

  /// black (.pill.dk) — "عرض اليوم", timers
  dark,

  /// translucent white (.pill.wh)
  white,

  /// solid green with white text — discount badge "−25%"
  successSolid,

  /// solid orange with white text
  orangeSolid,

  /// light grey (code chips like "422 out_of_zone")
  neutral,
}

/// .pill — small rounded status/label chip.
class BarqPill extends StatelessWidget {
  const BarqPill(this.label,
      {super.key,
      this.tone = BarqPillTone.orange,
      this.icon,
      this.padding,
      this.fontSize});

  final String label;
  final BarqPillTone tone;

  /// A [BarqIcons] name shown before the label.
  final String? icon;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    final (Color bg, Color fg) = switch (tone) {
      BarqPillTone.success => p.isDark
          ? (BarqColors.darkSuccessSoft, BarqColors.darkSuccessText)
          : (BarqColors.successSoft, BarqColors.successText),
      BarqPillTone.orange => (
          BarqColors.primarySoft,
          BarqColors.primarySoftText
        ),
      BarqPillTone.danger => (BarqColors.dangerSoft, BarqColors.danger),
      BarqPillTone.dark => (BarqColors.ink, Colors.white),
      BarqPillTone.white => (const Color(0xBFFFFFFF), BarqColors.ink),
      BarqPillTone.successSolid => (BarqColors.success, Colors.white),
      BarqPillTone.orangeSolid => (BarqColors.primary, Colors.white),
      BarqPillTone.neutral => p.isDark
          ? (BarqColors.darkChip, BarqColors.darkLabel)
          : (const Color(0xFFF3F3F3), const Color(0xFF4A4A4A)),
    };
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(BarqRadius.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            BarqIcon(icon!, size: BarqSizes.iconS, color: fg),
            const SizedBox(width: 4)
          ],
          Text(label,
              style: BarqText.pill.copyWith(color: fg, fontSize: fontSize),
              maxLines: 1),
        ],
      ),
    );
  }
}

/// Order progress: N bars, bars up to [current] are orange, optional labels
/// under each bar (the 5 driver/customer statuses). [current] is 0-based.
class BarqStepProgress extends StatelessWidget {
  const BarqStepProgress(
      {super.key,
      required this.count,
      required this.current,
      this.labels,
      this.height = 6});

  final int count;
  final int current;
  final List<String>? labels;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    final activeLabel = p.isDark ? BarqColors.primaryLight : BarqColors.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (var i = 0; i < count; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: AnimatedContainer(
                  duration: BarqDurations.normal,
                  height: height,
                  decoration: BoxDecoration(
                    color: i <= current ? BarqColors.primary : p.progressOff,
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (labels != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              for (var i = 0; i < count; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    labels![i],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: BarqText.xs.copyWith(
                      fontSize: 10.5,
                      color: i == current ? activeLabel : p.textMuted,
                      fontWeight:
                          i == current ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

/// Vertical status timeline (customer "بانتظار المتجر" screen).
/// Each item: icon name + label; items before [current] are done (green check),
/// [current] is orange with an optional trailing pill, later ones are grey.
class BarqTimeline extends StatelessWidget {
  const BarqTimeline(
      {super.key,
      required this.items,
      required this.current,
      this.currentTrailing});

  final List<({String icon, String label})> items;
  final int current;
  final Widget? currentTrailing;

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < current
                        ? BarqColors.successSoft
                        : i == current
                            ? BarqColors.primary
                            : BarqColors.chipMuted,
                  ),
                  alignment: Alignment.center,
                  child: BarqIcon(
                    i < current ? BarqIconsInternal.check : items[i].icon,
                    size: BarqSizes.iconS,
                    color: i < current
                        ? BarqColors.successText
                        : (i == current
                            ? Colors.white
                            : BarqColors.placeholder),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    items[i].label,
                    style:
                        (i <= current ? BarqText.tBold : BarqText.t).copyWith(
                      color: i == current
                          ? BarqColors.primaryText
                          : (i < current ? p.text : BarqColors.placeholder),
                    ),
                  ),
                ),
                if (i == current && currentTrailing != null) currentTrailing!,
              ],
            ),
          ),
      ],
    );
  }
}

/// .dots — onboarding page indicator.
class BarqDots extends StatelessWidget {
  const BarqDots(
      {super.key,
      required this.count,
      required this.index,
      this.activeColor,
      this.inactiveColor});
  final int count;
  final int index;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            AnimatedContainer(
              duration: BarqDurations.normal,
              width: i == index ? 26 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == index
                    ? (activeColor ?? BarqColors.ink)
                    : (inactiveColor ?? BarqColors.radioOff),
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ],
        ],
      );
}

/// .hr — 1px divider; [dashed] for receipts/totals.
class BarqDivider extends StatelessWidget {
  const BarqDivider({super.key, this.dashed = false, this.color});
  final bool dashed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ??
        (dashed ? const Color(0xFFEADBD2) : BarqPalette.of(context).line);
    if (!dashed) return Container(height: 1, color: c);
    return LayoutBuilder(builder: (context, box) {
      final n = (box.maxWidth / 9).floor();
      return Row(
        children: List.generate(
            n,
            (_) => Expanded(
                child: Container(
                    height: 1.5,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    color: c))),
      );
    });
  }
}

/// 5-star rating (read-only or tappable).
class BarqStars extends StatelessWidget {
  const BarqStars(
      {super.key,
      required this.value,
      this.onChanged,
      this.size = 26,
      this.spacing = 3});
  final int value;
  final ValueChanged<int>? onChanged;
  final double size;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final off = BarqPalette.of(context).isDark
        ? BarqColors.darkLine
        : BarqColors.starOff;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++) ...[
          if (i > 1) SizedBox(width: spacing),
          GestureDetector(
            onTap: onChanged == null ? null : () => onChanged!(i),
            child: BarqIcon(BarqIconsInternal.star,
                size: size, color: i <= value ? BarqColors.star : off),
          ),
        ],
      ],
    );
  }
}

/// Price with optional struck-through compare-at price and unit:
/// "₪6  ₪8  / كغ". Pass already-formatted strings (the API gives prices).
class BarqPrice extends StatelessWidget {
  const BarqPrice(this.price,
      {super.key, this.compareAt, this.unit, this.style, this.color});

  final String price;
  final String? compareAt;
  final String? unit;
  final TextStyle? style;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    final base = (style ?? BarqText.tBold).copyWith(color: color ?? p.text);
    return Text.rich(
      TextSpan(children: [
        TextSpan(text: price, style: base),
        if (compareAt != null) ...[
          const TextSpan(text: ' '),
          TextSpan(
              text: compareAt,
              style: BarqText.strike.copyWith(color: p.textMuted)),
        ],
        if (unit != null)
          TextSpan(
              text: ' $unit', style: BarqText.xs.copyWith(color: p.textMuted)),
      ]),
      maxLines: 1,
    );
  }
}
