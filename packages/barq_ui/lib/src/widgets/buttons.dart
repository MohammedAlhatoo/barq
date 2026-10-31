import 'package:flutter/material.dart';

import '../foundation/barq_assets.dart';
import '../foundation/barq_theme.dart';
import '../foundation/barq_tokens.dart';

/// .btn variants
enum BarqButtonVariant {
  /// Orange (default)                        .btn
  primary,

  /// White with soft shadow                  .btn.w
  white,

  /// Light orange, orange text               .btn.lt
  light,

  /// Black                                   .btn.dk
  dark,

  /// Green ("اختيار الأوفر", "تم التسليم")    .btn.gr
  green,

  /// Light red, red text ("إلغاء الطلب")      .btn.rd
  softRed,

  /// Solid red ("تأكيد الإلغاء", "حذف الحساب")
  red,

  /// Transparent with dashed orange border ("تحديد موقعي", "إضافة عنوان جديد")
  outlineDashed,
}

/// Full-width pill button. `onPressed: null` = disabled look.
class BarqButton extends StatelessWidget {
  const BarqButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = BarqButtonVariant.primary,
    this.icon,
    this.small = false,
    this.loading = false,
    this.expand = true,
    this.trailing,
    this.labelColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final BarqButtonVariant variant;

  /// A [BarqIcons] name shown before the label.
  final String? icon;
  final bool small;
  final bool loading;
  final bool expand;

  /// Optional widget at the end (e.g. price "₪46" in "عرض السلة").
  final Widget? trailing;

  /// Replaces the variant's text color ("تحديث الآن" on orange screens).
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    final disabled = onPressed == null && !loading;
    Color bg;
    Color fg;
    List<BoxShadow> shadow;
    Border? border;
    switch (variant) {
      case BarqButtonVariant.primary:
        bg = BarqColors.primary;
        fg = Colors.white;
        shadow = BarqShadows.primaryButton;
      case BarqButtonVariant.white:
        bg = p.isDark ? BarqColors.darkCard : Colors.white;
        fg = p.text;
        shadow = p.isDark ? const [] : BarqShadows.soft;
        if (p.isDark) border = Border.all(color: BarqColors.darkLine);
      case BarqButtonVariant.light:
        bg = BarqColors.primarySoft;
        fg = BarqColors.primarySoftText;
        shadow = const [];
      case BarqButtonVariant.dark:
        bg = BarqColors.ink;
        fg = Colors.white;
        shadow = BarqShadows.darkButton;
      case BarqButtonVariant.green:
        bg = BarqColors.success;
        fg = Colors.white;
        shadow = BarqShadows.greenButton;
      case BarqButtonVariant.softRed:
        bg = BarqColors.dangerSoft;
        fg = BarqColors.danger;
        shadow = const [];
      case BarqButtonVariant.red:
        bg = BarqColors.danger;
        fg = Colors.white;
        shadow = BarqShadows.redButton;
      case BarqButtonVariant.outlineDashed:
        bg = Colors.transparent;
        fg = BarqColors.primaryText;
        shadow = const [];
    }
    fg = labelColor ?? fg;
    if (disabled) {
      bg = p.disabledButton;
      fg = p.disabledButtonText;
      shadow = const [];
      border = null;
    }
    final style =
        (small ? BarqText.buttonSmall : BarqText.button).copyWith(color: fg);
    final content = loading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: fg))
        : Row(
            mainAxisSize:
                trailing == null ? MainAxisSize.min : MainAxisSize.max,
            mainAxisAlignment: trailing == null
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
            children: [
              if (icon != null) ...[
                BarqIcon(icon!,
                    size: small ? BarqSizes.iconM : BarqSizes.icon, color: fg),
                const SizedBox(width: 10)
              ],
              Flexible(
                  child: Text(label,
                      style: style,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis)),
              if (trailing != null) ...[
                const Spacer(),
                DefaultTextStyle(style: style, child: trailing!)
              ],
            ],
          );

    Widget box = AnimatedContainer(
      duration: BarqDurations.fast,
      height: small ? BarqSizes.buttonSmall : BarqSizes.button,
      width: expand ? double.infinity : null,
      padding: EdgeInsets.symmetric(horizontal: trailing == null ? 22 : 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(BarqRadius.pill),
        boxShadow: shadow,
        border: border,
      ),
      alignment: Alignment.center,
      child: trailing == null
          ? content
          : Row(children: [Expanded(child: content)]),
    );
    if (variant == BarqButtonVariant.outlineDashed && !disabled) {
      box = CustomPaint(
        foregroundPainter: _DashedRRectPainter(
            color: BarqColors.primary, radius: BarqRadius.pill),
        child: box,
      );
    }
    return Semantics(
      button: true,
      enabled: !disabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: loading ? null : onPressed,
        child: box,
      ),
    );
  }
}

/// .icb — round 48px header button (back, notifications, share …).
class BarqIconButton extends StatelessWidget {
  const BarqIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = BarqSizes.iconButton,
    this.background,
    this.iconColor,
    this.showDot = false,
    this.glass = false,
    this.flat = false,
    this.tooltip,
  });

  /// A [BarqIcons] name.
  final String icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? background;
  final Color? iconColor;

  /// Red notification dot (.dot)
  final bool showDot;

  /// Translucent white on orange backgrounds (.icb.gl)
  final bool glass;

  /// No shadow
  final bool flat;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    final bg = background ?? (glass ? const Color(0x38FFFFFF) : p.iconButton);
    final fg = iconColor ?? (glass ? Colors.white : p.iconButtonIcon);
    final btn = GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow:
              (glass || flat || background != null) ? null : p.iconButtonShadow,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            BarqIcon(icon,
                size: size > 44 ? BarqSizes.icon : BarqSizes.iconM, color: fg),
            if (showDot)
              PositionedDirectional(
                top: 11,
                start: 12,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: BarqColors.dotRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}

/// .plus — round orange "+" add button. Shows [count] instead of + when > 0
/// (black circle with the quantity, as in the category grid).
class BarqPlusButton extends StatelessWidget {
  const BarqPlusButton(
      {super.key, this.onPressed, this.small = false, this.count = 0});

  final VoidCallback? onPressed;
  final bool small;
  final int count;

  @override
  Widget build(BuildContext context) {
    final s = small ? BarqSizes.plusSmall : BarqSizes.plus;
    final hasCount = count > 0;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
          color: hasCount ? BarqColors.ink : BarqColors.primary,
          shape: BoxShape.circle,
          boxShadow: hasCount ? null : BarqShadows.plus,
        ),
        alignment: Alignment.center,
        child: hasCount
            ? Text('$count',
                style:
                    BarqText.tBold.copyWith(color: Colors.white, fontSize: 15))
            : BarqIcon(BarqIconsInternal.plus,
                size: small ? BarqSizes.iconM : BarqSizes.icon,
                color: Colors.white),
      ),
    );
  }
}

/// .lnk — orange text link ("عرض الكل", "تغيير", "تعديل الرقم").
class BarqLink extends StatelessWidget {
  const BarqLink(this.label,
      {super.key, this.onPressed, this.color, this.fontSize});

  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final double? fontSize;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onPressed,
        child: Text(label,
            style: BarqText.link.copyWith(color: color, fontSize: fontSize)),
      );
}

/// Internal icon names used by widgets (kept here to avoid an import cycle).
abstract final class BarqIconsInternal {
  static const plus = 'plus';
  static const minus = 'minus';
  static const trash = 'trash';
  static const check = 'check';
  static const chev = 'chev';
  static const search = 'search';
  static const heart = 'heart';
  static const heartFilled = 'heartf';
  static const star = 'star';
  static const lock = 'lock';
  static const x = 'x';
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color, required this.radius});
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final r = radius.clamp(0, size.height / 2).toDouble();
    final rrect =
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(r))
            .deflate(0.75);
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 6), paint);
        d += 10;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter old) =>
      old.color != color || old.radius != radius;
}

/// Public helper so other widgets (cards, inputs) can draw the same dashed border.
class BarqDashedBorder extends StatelessWidget {
  const BarqDashedBorder(
      {super.key,
      required this.child,
      this.radius = BarqRadius.card,
      this.color = BarqColors.primary});
  final Widget child;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(
      foregroundPainter: _DashedRRectPainter(color: color, radius: radius),
      child: child);
}
