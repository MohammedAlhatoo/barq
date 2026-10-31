import 'package:flutter/material.dart';

import '../foundation/barq_assets.dart';
import '../foundation/barq_theme.dart';
import '../foundation/barq_tokens.dart';
import 'buttons.dart';
import 'indicators.dart';
import 'layout.dart';
import 'surfaces.dart';

/// .wm — the "برق" wordmark (Lalezar) with the small yellow bolt (.bl).
class BarqWordmark extends StatelessWidget {
  const BarqWordmark(
      {super.key,
      this.size = 40,
      this.color = BarqColors.primary,
      this.showBolt = true});
  final double size;
  final Color color;
  final bool showBolt;

  @override
  Widget build(BuildContext context) => Stack(
        clipBehavior: Clip.none,
        children: [
          Text('برق', style: BarqText.wordmark(size, color: color)),
          if (showBolt)
            Positioned(
              top: -size * .02,
              left: -size * .2,
              child: Transform.rotate(
                angle: 0.21, // 12deg
                child: BarqIllustration('boltc',
                    width: size * .34, height: size * .46),
              ),
            ),
        ],
      );
}

/// Round avatar with an initial ("م") — orange gradient (customer) or black (driver).
class BarqAvatar extends StatelessWidget {
  const BarqAvatar(this.initial,
      {super.key,
      this.size = 48,
      this.dark = false,
      this.border = 0,
      this.imageUrl,
      this.badge});
  final String initial;
  final double size;
  final bool dark;

  /// White ring width (profile header uses 4–5).
  final double border;
  final String? imageUrl;

  /// Small widget at the bottom-end (camera button on edit profile).
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final circle = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: dark ? null : BarqGradients.orange,
        color: dark ? BarqColors.ink : null,
        border:
            border > 0 ? Border.all(color: Colors.white, width: border) : null,
        image: imageUrl != null
            ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: imageUrl != null
          ? null
          : Text(initial,
              style: BarqText.h2
                  .copyWith(color: Colors.white, fontSize: size * .38)),
    );
    if (badge == null) return circle;
    return Stack(clipBehavior: Clip.none, children: [
      circle,
      PositionedDirectional(bottom: -2, end: -2, child: badge!)
    ]);
  }
}

/// .map — static map background used in tracking/address screens until the real
/// map widget is plugged in (google_maps_flutter / flutter_map). Children are
/// positioned on top (pins, route).
class BarqMapBackground extends StatelessWidget {
  const BarqMapBackground(
      {super.key, this.children = const [], this.darken = false});
  final List<Widget> children;

  /// Driver screens dim the map (filter: brightness(.55)).
  final bool darken;

  @override
  Widget build(BuildContext context) => ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: BarqColors.mapBg),
            const BarqIllustration('map', fit: BoxFit.cover),
            if (darken) const ColoredBox(color: Color(0x80000000)),
            ...children,
          ],
        ),
      );
}

enum BarqPinStyle { orange, dark, white, red }

/// .mpin — round map pin with icon and halo.
class BarqMapPin extends StatelessWidget {
  const BarqMapPin(
      {super.key,
      required this.icon,
      this.style = BarqPinStyle.orange,
      this.size = BarqSizes.mapPin});
  final String icon;
  final BarqPinStyle style;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, Color halo) = switch (style) {
      BarqPinStyle.orange => (
          BarqColors.primary,
          Colors.white,
          const Color(0x38FF7A21)
        ),
      BarqPinStyle.dark => (
          BarqColors.ink,
          Colors.white,
          const Color(0x1F151515)
        ),
      BarqPinStyle.white => (
          Colors.white,
          BarqColors.primary,
          Colors.transparent
        ),
      BarqPinStyle.red => (
          const Color(0xFFD93A2B),
          Colors.white,
          const Color(0x33D93A2B)
        ),
    };
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: [
          if (halo != Colors.transparent)
            BoxShadow(color: halo, spreadRadius: 8),
          BoxShadow(
              color: style == BarqPinStyle.white
                  ? const Color(0x4D000000)
                  : bg.withAlpha(0xE6),
              offset: const Offset(0, 10),
              blurRadius: 18,
              spreadRadius: -6),
        ],
      ),
      alignment: Alignment.center,
      child: BarqIcon(icon,
          size: size > 46 ? BarqSizes.icon : BarqSizes.iconM, color: fg),
    );
  }
}

/// Gradient banner card (home promo, driver earnings, driver cash to collect).
class BarqBanner extends StatelessWidget {
  const BarqBanner(
      {super.key,
      required this.child,
      this.gradient = BarqGradients.orange,
      this.padding = const EdgeInsets.all(18),
      this.radius = 28,
      this.height});
  final Widget child;
  final Gradient gradient;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double? height;

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        padding: padding,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: const [
            BoxShadow(
                color: Color(0x80F2600C),
                offset: Offset(0, 18),
                blurRadius: 30,
                spreadRadius: -16)
          ],
        ),
        child: child,
      );
}

/// Full-screen state (out of zone, empty cart, offline, maintenance, session
/// expired, forced update): illustration in a blob, title, text, optional code
/// pill, and buttons pinned to the bottom.
class BarqStateView extends StatelessWidget {
  const BarqStateView({
    super.key,
    required this.illustration,
    required this.title,
    required this.message,
    this.code,
    this.actions = const [],
    this.blobGradient,
    this.footer,
    this.onOrange = false,
  });

  /// The visual inside the blob (BarqIllustration or an icon card).
  final Widget illustration;
  final String title;
  final String message;

  /// Technical code pill, e.g. "422 out_of_zone".
  final String? code;

  /// Usually 1–2 [BarqButton]s.
  final List<Widget> actions;
  final Gradient? blobGradient;
  final Widget? footer;

  /// White text for the orange background (forced update).
  final bool onOrange;

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    final titleColor = onOrange ? Colors.white : p.text;
    final bodyColor = onOrange
        ? const Color(0xFFFFEADF)
        : (p.isDark ? BarqColors.darkSubtle : BarqColors.muted);
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(BarqSpacing.page, 60, BarqSpacing.page, 30),
      child: Column(
        children: [
          BarqIllustrationArea(
            height: 400,
            blobSize: 270,
            blobGradient: onOrange
                ? const RadialGradient(
                    colors: [Color(0x24FFFFFF), Color(0x24FFFFFF)])
                : blobGradient,
            child: illustration,
          ),
          Text(title,
              textAlign: TextAlign.center,
              style: BarqText.h1.copyWith(color: titleColor)),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: BarqText.body.copyWith(color: bodyColor)),
          if (code != null) ...[
            const SizedBox(height: 12),
            Directionality(
                textDirection: TextDirection.ltr,
                child: BarqPill(code!,
                    tone: onOrange ? BarqPillTone.dark : BarqPillTone.neutral)),
          ],
          const Spacer(),
          BarqGap(gap: 10, children: [...actions, if (footer != null) footer!]),
        ],
      ),
    );
  }
}

/// White rounded card holding a big icon, tilted (state screens: bag, clock,
/// wrench, trash…). Example: `BarqIconCard(icon: BarqIcons.wrench, angle: 8)`.
class BarqIconCard extends StatelessWidget {
  const BarqIconCard(
      {super.key,
      required this.icon,
      this.size = 150,
      this.angle = 0,
      this.iconColor,
      this.background,
      this.gradient,
      this.radius = 46,
      this.circle = false});
  final String icon;
  final double size;

  /// Degrees.
  final double angle;
  final Color? iconColor;
  final Color? background;
  final Gradient? gradient;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) => Transform.rotate(
        angle: angle * 3.1415926535 / 180,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: gradient == null ? (background ?? Colors.white) : null,
            gradient: gradient,
            shape: circle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: circle ? null : BorderRadius.circular(radius),
            boxShadow: const [
              BoxShadow(
                  color: Color(0xCCC86E50),
                  offset: Offset(0, 20),
                  blurRadius: 40,
                  spreadRadius: -20)
            ],
          ),
          child: BarqIcon(icon,
              size: size * .52,
              color: iconColor ??
                  (gradient != null ? Colors.white : BarqColors.primary)),
        ),
      );
}

/// Store/stores row ("ميني ماركت النور · تحضير 15 د · 1.2 كم").
class BarqMetaRow extends StatelessWidget {
  const BarqMetaRow({super.key, required this.items, this.color});

  /// (icon, text, iconColor?) triples.
  final List<({String icon, String text, Color? iconColor})> items;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? BarqPalette.of(context).textMuted;
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        for (final it in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BarqIcon(it.icon,
                  size: BarqSizes.iconS, color: it.iconColor ?? c),
              const SizedBox(width: 4),
              Text(it.text,
                  style: BarqText.xs.copyWith(fontSize: 13, color: c)),
            ],
          ),
      ],
    );
  }
}
