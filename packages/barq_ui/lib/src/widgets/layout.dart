import 'package:flutter/material.dart';

import '../foundation/barq_assets.dart';
import '../foundation/barq_theme.dart';
import '../foundation/barq_tokens.dart';
import 'buttons.dart';

/// .top — screen header: [leading] · centered [title] · [trailing], with the
/// design paddings (52 top incl. status bar, 22 sides). Pass `back: true`
/// for the standard back button (pops the route).
class BarqHeader extends StatelessWidget {
  const BarqHeader({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.trailing,
    this.back = false,
    this.onBack,
    this.bottom,
    this.large = false,
    this.padding = const EdgeInsets.fromLTRB(
        BarqSpacing.page, BarqSpacing.headerTop, BarqSpacing.page, 0),
  });

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final Widget? trailing;
  final bool back;
  final VoidCallback? onBack;

  /// Content under the header row (search bar, description, pills…), 16px gap.
  final Widget? bottom;

  /// Big start-aligned title (h1) like "طلباتي", "حسابي" instead of centered h2.
  final bool large;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    final lead = leading ??
        (back
            ? BarqIconButton(
                icon: 'back',
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                tooltip: 'رجوع')
            : null);
    Widget row;
    if (large) {
      row = Row(children: [
        Expanded(
            child: titleWidget ??
                Text(title ?? '', style: BarqText.h1.copyWith(color: p.text))),
        if (trailing != null) trailing!,
      ]);
    } else {
      row = SizedBox(
        height: BarqSizes.iconButton,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (titleWidget != null || title != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 56),
                child: titleWidget ??
                    Text(title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: BarqText.h2.copyWith(color: p.text)),
              ),
            if (lead != null)
              Align(alignment: AlignmentDirectional.centerStart, child: lead),
            if (trailing != null)
              Align(alignment: AlignmentDirectional.centerEnd, child: trailing),
          ],
        ),
      );
    }
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row,
          if (bottom != null) ...[const SizedBox(height: 16), bottom!]
        ],
      ),
    );
  }
}

/// .sec — section title with an optional link on the other side ("الأكثر طلبًا · عرض الكل").
class BarqSectionHeader extends StatelessWidget {
  const BarqSectionHeader(this.title,
      {super.key,
      this.action,
      this.onAction,
      this.padding = const EdgeInsets.symmetric(horizontal: BarqSpacing.page)});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
                child: Text(title,
                    style: BarqText.h2
                        .copyWith(color: BarqPalette.of(context).text))),
            if (action != null)
              BarqLink(action!, onPressed: onAction, color: BarqColors.muted),
          ],
        ),
      );
}

enum BarqTileTone { orange, green, neutral, red, yellow, darkOrange }

/// .ti — rounded icon tile (46px, radius 16).
class BarqIconTile extends StatelessWidget {
  const BarqIconTile(this.icon,
      {super.key,
      this.tone = BarqTileTone.orange,
      this.size = BarqSizes.iconTile,
      this.radius = BarqRadius.iconTile,
      this.iconSize});

  /// A [BarqIcons] name.
  final String icon;
  final BarqTileTone tone;
  final double size;
  final double radius;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final dark = BarqPalette.of(context).isDark;
    final (Color bg, Color fg) = switch (tone) {
      BarqTileTone.orange => dark
          ? (const Color(0xFF3A2C25), BarqColors.primaryLight)
          : (BarqColors.primaryTint, BarqColors.primary),
      BarqTileTone.green => dark
          ? (BarqColors.darkSuccessSoft, BarqColors.darkSuccessText)
          : (BarqColors.successSoft, BarqColors.successText),
      BarqTileTone.neutral => dark
          ? (BarqColors.darkChip, BarqColors.white)
          : (BarqColors.chipMuted, BarqColors.ink),
      BarqTileTone.red => dark
          ? (const Color(0xFF3A1A15), const Color(0xFFFF8A7A))
          : (BarqColors.dangerSoft, BarqColors.danger),
      BarqTileTone.yellow => dark
          ? (const Color(0xFF3A2C25), BarqColors.cashYellow)
          : (BarqColors.warningSoft, BarqColors.warningText),
      BarqTileTone.darkOrange => (BarqColors.primary, Colors.white),
    };
    return Container(
      width: size,
      height: size,
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(radius)),
      alignment: Alignment.center,
      child: BarqIcon(icon,
          size: iconSize ?? (size >= 44 ? BarqSizes.icon : BarqSizes.iconM),
          color: fg),
    );
  }
}

/// .li — list row with bottom divider: [leading] · title/subtitle · [trailing] (default chevron).
class BarqListTile extends StatelessWidget {
  const BarqListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.showChevron = true,
    this.showDivider = true,
    this.titleColor,
    this.value,
  });

  final String title;
  final String? subtitle;

  /// Usually a [BarqIconTile] or [BarqRadio].
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool showDivider;
  final Color? titleColor;

  /// Small grey value before the chevron ("العربية", "دراجة نارية").
  final String? value;

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                      color: p.isDark
                          ? const Color(0xFF322722)
                          : BarqColors.listDivider))
              : null,
        ),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 14)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: BarqText.h3.copyWith(color: titleColor ?? p.text)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: BarqText.xs.copyWith(color: p.textMuted)),
                ],
              ),
            ),
            if (value != null) ...[
              Text(value!, style: BarqText.xs.copyWith(color: p.textMuted)),
              const SizedBox(width: 8)
            ],
            if (trailing != null)
              trailing!
            else if (showChevron)
              BarqIcon(BarqIconsInternal.chev,
                  size: BarqSizes.iconM,
                  color: p.isDark ? const Color(0xFF6E625A) : BarqColors.muted),
          ],
        ),
      ),
    );
  }
}

enum BarqNoteTone { info, warning, orange, success, danger }

/// Tinted note row with an icon ("الأسعار بدون التوصيل", "إذا لم توافق خلال 60 دقيقة…").
class BarqNote extends StatelessWidget {
  const BarqNote(this.text,
      {super.key, this.icon = 'info', this.tone = BarqNoteTone.info});
  final String text;
  final String icon;
  final BarqNoteTone tone;

  @override
  Widget build(BuildContext context) {
    final dark = BarqPalette.of(context).isDark;
    final (Color bg, Color fg, Color tc) = switch (tone) {
      BarqNoteTone.info => dark
          ? (BarqColors.darkCard, BarqColors.darkMuted, BarqColors.darkLabel)
          : (BarqColors.segmentBg, BarqColors.muted, BarqColors.ink),
      BarqNoteTone.warning => (
          BarqColors.warningSoft,
          BarqColors.warningTextDark,
          BarqColors.warningTextDark
        ),
      BarqNoteTone.orange => (
          BarqColors.primaryTint2,
          BarqColors.primarySoftText,
          const Color(0xFF5A3A26)
        ),
      BarqNoteTone.success => (
          BarqColors.successSoft,
          BarqColors.successText,
          BarqColors.successText
        ),
      BarqNoteTone.danger => (
          BarqColors.dangerSoft,
          BarqColors.danger,
          BarqColors.danger
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 1),
              child: BarqIcon(icon, size: BarqSizes.iconM, color: fg)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: BarqText.t.copyWith(color: tc))),
        ],
      ),
    );
  }
}

/// Label · value row used in totals, receipts, earnings ("التوصيل (1.8 كم)  ₪7").
class BarqSummaryRow extends StatelessWidget {
  const BarqSummaryRow(this.label, this.value,
      {super.key, this.total = false, this.valueColor, this.valueWidget});
  final String label;
  final String value;

  /// Bold "الإجمالي" row with big value.
  final bool total;
  final Color? valueColor;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    return Row(
      children: [
        Expanded(
            child: Text(label,
                style: total
                    ? BarqText.h3.copyWith(color: p.text)
                    : BarqText.t.copyWith(color: p.textMuted))),
        valueWidget ??
            Text(value,
                style: (total ? BarqText.h2 : BarqText.t).copyWith(
                    color: valueColor ?? p.text,
                    fontWeight: total ? FontWeight.w600 : FontWeight.w500)),
      ],
    );
  }
}

/// Vertical list with fixed gaps (.stk) — avoids sprinkling SizedBoxes.
class BarqGap extends StatelessWidget {
  const BarqGap(
      {super.key,
      required this.children,
      this.gap = BarqSpacing.gap,
      this.padding = EdgeInsets.zero,
      this.crossAxisAlignment = CrossAxisAlignment.stretch});
  final List<Widget> children;
  final double gap;
  final EdgeInsetsGeometry padding;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: crossAxisAlignment,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) SizedBox(height: gap),
              children[i]
            ]
          ],
        ),
      );
}
