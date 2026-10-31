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

/// App logo in a rounded square: glass on the splash, white on forced update.
class BarqLogoTile extends StatelessWidget {
  const BarqLogoTile({super.key, this.glass = false});
  final bool glass;

  @override
  Widget build(BuildContext context) {
    final size = glass ? 170.0 : 150.0;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: glass ? const Color(0x2EFFFFFF) : Colors.white,
        borderRadius: BorderRadius.circular(glass ? 48 : 46),
        border: glass ? Border.all(color: const Color(0x59FFFFFF)) : null,
        boxShadow: glass
            ? null
            : const [
                BoxShadow(
                    color: Color(0x99782800),
                    offset: Offset(0, 24),
                    blurRadius: 40,
                    spreadRadius: -18)
              ],
      ),
      child: BarqWordmark(
          size: glass ? 92 : 76,
          color: glass ? Colors.white : BarqColors.primary),
    );
  }
}

/// .ph.or splash content: decor circles, glass logo, tagline and the dots.
class BarqSplashContent extends StatelessWidget {
  const BarqSplashContent({super.key, required this.tagline});
  final String tagline;

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(child: BarqDecorCircles()),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BarqLogoTile(glass: true),
              const SizedBox(height: 26),
              Text(tagline,
                  textAlign: TextAlign.center,
                  style: BarqText.h2.copyWith(color: Colors.white)),
            ],
          ),
          const Positioned(
            bottom: 70,
            child: BarqDots(
                count: 3,
                index: 0,
                activeWidth: 8,
                activeColor: Colors.white,
                inactiveColor: Color(0x80FFFFFF)),
          ),
        ],
      );
}

/// White ring + orange gradient circle with an icon (OTP screen shield).
class BarqRingBadge extends StatelessWidget {
  const BarqRingBadge({super.key, required this.icon});

  /// A [BarqIcons] name.
  final String icon;

  @override
  Widget build(BuildContext context) => Container(
        width: 150,
        height: 150,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Color(0xB3FF7A21),
                offset: Offset(0, 20),
                blurRadius: 40,
                spreadRadius: -20)
          ],
        ),
        child: Container(
          width: 96,
          height: 96,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              shape: BoxShape.circle, gradient: BarqGradients.orange),
          child: BarqIcon(icon, size: BarqSizes.iconXL, color: Colors.white),
        ),
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
    return BarqFillScroll(
      padding: const EdgeInsets.fromLTRB(
          BarqSpacing.page, 60, BarqSpacing.page, BarqSpacing.stateBottom),
      crossAxisAlignment: CrossAxisAlignment.center,
      footer: BarqGap(
          gap: BarqSpacing.md,
          children: [...actions, if (footer != null) footer!]),
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
                  mono: true,
                  tone:
                      onOrange ? BarqPillTone.onOrange : BarqPillTone.white)),
        ],
      ],
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

/// Thin bar above a list: what the list is limited to, and a link to change it
/// ("تتسوّق من: ميني ماركت النور · كل المتاجر").
class BarqScopeBar extends StatelessWidget {
  const BarqScopeBar(
      {super.key, required this.text, required this.action, this.onAction});

  final String text;
  final String action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    return BarqCard(
      radius: BarqRadius.pill,
      padding: const EdgeInsets.symmetric(
          horizontal: BarqSpacing.section, vertical: BarqSpacing.sm),
      child: Row(
        children: [
          const BarqIcon('store',
              size: BarqSizes.iconS, color: BarqColors.primary),
          const SizedBox(width: BarqSpacing.xs),
          Flexible(
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: BarqText.t.copyWith(color: p.text)),
          ),
          Text(' · ', style: BarqText.t.copyWith(color: p.textMuted)),
          BarqLink(action, onPressed: onAction),
        ],
      ),
    );
  }
}

/// Spinner for a screen or list that is loading.
class BarqLoadingView extends StatelessWidget {
  const BarqLoadingView({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(BarqSpacing.lg),
          child: CircularProgressIndicator(color: BarqColors.primary),
        ),
      );
}

/// Small centered message for an empty or failed list inside a screen.
/// [BarqStateView] is the full-screen version.
class BarqMessageView extends StatelessWidget {
  const BarqMessageView({
    super.key,
    required this.title,
    this.message,
    this.icon = 'info',
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;

  /// A [BarqIcons] name.
  final String icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    final action = actionLabel;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(BarqSpacing.page),
        child: BarqGap(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            BarqIconTile(icon),
            Text(title,
                textAlign: TextAlign.center,
                style: BarqText.h3.copyWith(color: p.text)),
            if (message != null)
              Text(message!,
                  textAlign: TextAlign.center,
                  style: BarqText.t.copyWith(color: p.textMuted)),
            if (action != null)
              BarqButton(
                  label: action,
                  small: true,
                  expand: false,
                  onPressed: onAction),
          ],
        ),
      ),
    );
  }
}

/// The picture of the empty cart screen (07_states_02).
class BarqEmptyCartArt extends StatelessWidget {
  const BarqEmptyCartArt({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
        width: 270,
        height: 270,
        child: Stack(
          alignment: Alignment.center,
          children: [
            BarqIconCard(icon: 'bag', angle: -6),
            Positioned(
                left: 169,
                top: 37,
                child: BarqIllustration('lemon', width: 56)),
            Positioned(
                left: 43,
                top: 181,
                child: BarqIllustration('tomato', width: 56)),
          ],
        ),
      );
}

/// The pin with a red x of the out-of-zone screen (07_states_01).
class BarqOutOfZoneArt extends StatelessWidget {
  const BarqOutOfZoneArt({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 220,
        height: 220,
        child: Stack(
          children: [
            const BarqIllustration('pin3d', width: 220),
            Positioned(
              left: 34,
              top: 17,
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: BarqColors.danger,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: const BarqIcon('x',
                    size: BarqSizes.iconM, color: Colors.white),
              ),
            ),
          ],
        ),
      );
}

/// The tilted basket with a pill under it (03_checkout_03).
class BarqBasketArt extends StatelessWidget {
  const BarqBasketArt({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => BarqIllustrationArea(
        height: 220,
        blobSize: 200,
        overlays: [
          Positioned(
              bottom: 22,
              child: BarqPill(label,
                  tone: BarqPillTone.danger,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8))),
        ],
        child: Transform.rotate(
          angle: -6 * 3.1415926535 / 180,
          child: Container(
            width: 124,
            height: 124,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(38),
            ),
            child: const BarqIllustration('basket', width: 100, height: 96),
          ),
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
