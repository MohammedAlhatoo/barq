import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../foundation/barq_theme.dart';
import '../foundation/barq_tokens.dart';

enum BarqScreenBackground {
  /// Light gradient (.ph) — default for the customer app
  light,

  /// Dark gradient (.ph.dk) — default for the driver app
  dark,

  /// Full orange (.ph.or) — splash, forced update
  orange,

  /// Plain white (product details, tracking, store page)
  white,
}

/// Screen scaffold with the design background. Content is NOT wrapped in
/// SafeArea on purpose: the design's headers start at 52px (status bar
/// included) — use [BarqHeader] / [BarqSpacing.headerTop].
class BarqScreen extends StatelessWidget {
  const BarqScreen({
    super.key,
    required this.body,
    this.background,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.floating,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget body;

  /// Defaults to light (customer theme) or dark (driver theme).
  final BarqScreenBackground? background;

  /// e.g. [BarqNavBar]
  final Widget? bottomNavigationBar;

  /// Pinned bottom content (e.g. a [BarqSheet] with totals + button).
  final Widget? bottomSheet;

  /// Extra layers above the body (e.g. a [BarqScrim] + sheet for dialogs).
  final List<Widget>? floating;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    final bg = background ??
        (p.isDark ? BarqScreenBackground.dark : BarqScreenBackground.light);
    final decoration = switch (bg) {
      BarqScreenBackground.light =>
        const BoxDecoration(gradient: BarqGradients.screen),
      BarqScreenBackground.dark =>
        const BoxDecoration(gradient: BarqGradients.darkScreen),
      BarqScreenBackground.orange =>
        const BoxDecoration(gradient: BarqGradients.orangeScreen),
      BarqScreenBackground.white => const BoxDecoration(color: Colors.white),
    };
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: DecoratedBox(
        decoration: decoration,
        child: Stack(
          children: [
            Positioned.fill(child: body),
            if (bottomSheet != null)
              Positioned(left: 0, right: 0, bottom: 0, child: bottomSheet!),
            if (bottomNavigationBar != null)
              Positioned(
                  left: 0, right: 0, bottom: 0, child: bottomNavigationBar!),
            ...?floating,
          ],
        ),
      ),
    );
  }
}

/// Page whose [children] scroll on short screens while [footer] stays at the
/// bottom on tall ones (.pad with margin-top:auto). Don't put a PageView inside.
class BarqFillScroll extends StatelessWidget {
  const BarqFillScroll({
    super.key,
    required this.children,
    this.footer,
    this.padding = EdgeInsets.zero,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });

  final List<Widget> children;
  final Widget? footer;
  final EdgeInsetsGeometry padding;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) => CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: crossAxisAlignment,
                children: [
                  ...children,
                  if (footer != null) ...[const Spacer(), footer!],
                ],
              ),
            ),
          ),
        ],
      );
}

/// The two soft white circles on orange screens (splash, forced update).
/// Put it in a Stack behind the content.
class BarqDecorCircles extends StatelessWidget {
  const BarqDecorCircles({super.key, this.showBottom = true});

  /// The forced update design only has the top circle.
  final bool showBottom;

  static const _color = Color(0x14FFFFFF);

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          const Positioned(
              top: -120,
              right: -160,
              child: BarqBlob(size: 420, color: _color)),
          if (showBottom)
            const Positioned(
                bottom: -60,
                left: -120,
                child: BarqBlob(size: 300, color: _color)),
        ],
      );
}

/// .card — white rounded card (dark card on driver screens).
class BarqCard extends StatelessWidget {
  const BarqCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderColor,
    this.borderWidth = 1.5,
    this.radius = BarqRadius.card,
    this.shadow,
    this.onTap,
    this.glass = false,
    this.clip = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  /// Highlight border (e.g. selected store = primary, "best basket" = success).
  final Color? borderColor;
  final double borderWidth;
  final double radius;
  final List<BoxShadow>? shadow;
  final VoidCallback? onTap;

  /// .card.gl — translucent white card on colored backgrounds.
  final bool glass;

  /// Clip children to the rounded shape (cards with a map/image on top).
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    final card = Container(
      padding: padding,
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      decoration: BoxDecoration(
        color: color ?? (glass ? const Color(0x9EFFFFFF) : p.card),
        borderRadius: BorderRadius.circular(radius),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : (glass ? Border.all(color: const Color(0xCCFFFFFF)) : null),
        // A shadow would show through the see-through glass.
        boxShadow: glass ? null : (shadow ?? p.cardShadow),
      ),
      child: child,
    );
    final surface = glass
        ? ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14), child: card),
          )
        : card;
    return onTap == null
        ? surface
        : GestureDetector(
            onTap: onTap, behavior: HitTestBehavior.opaque, child: surface);
  }
}

/// .sheet — bottom sheet surface with rounded top (34) and optional grab handle.
/// Use as [BarqScreen.bottomSheet] or inside [showBarqSheet].
class BarqSheet extends StatelessWidget {
  const BarqSheet({
    super.key,
    required this.children,
    this.showGrab = true,
    this.gap = 16,
    this.padding = const EdgeInsets.fromLTRB(22, 12, 22, 30),
  });

  final List<Widget> children;
  final bool showGrab;
  final double gap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    final items = <Widget>[
      if (showGrab) Center(child: BarqGrab(color: p.grab)),
      ...children,
    ];
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: p.sheet,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(BarqRadius.sheet)),
        boxShadow: p.isDark ? null : BarqShadows.sheet,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) SizedBox(height: gap),
            items[i],
          ],
        ],
      ),
    );
  }
}

/// Shows a modal [BarqSheet] with the design scrim (.scrim). It opens on the
/// root navigator so it covers the nav bar; close it with [closeBarqSheet].
Future<T?> showBarqSheet<T>(BuildContext context,
    {required List<Widget> children, bool showGrab = true}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x6B281208),
    builder: (_) => BarqSheet(showGrab: showGrab, children: children),
  );
}

/// Closes the sheet opened by [showBarqSheet], with an optional result.
void closeBarqSheet<T>(BuildContext context, [T? result]) =>
    Navigator.of(context, rootNavigator: true).pop(result);

/// .grab — the small handle at the top of sheets.
class BarqGrab extends StatelessWidget {
  const BarqGrab({super.key, this.color});
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
        width: 46,
        height: 5,
        decoration: BoxDecoration(
          color: color ?? BarqPalette.of(context).grab,
          borderRadius: BorderRadius.circular(9),
        ),
      );
}

/// .scrim — dark overlay behind a sheet drawn inside the screen.
class BarqScrim extends StatelessWidget {
  const BarqScrim({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: GestureDetector(
          onTap: onTap,
          child: ColoredBox(
              color: BarqPalette.of(context).isDark
                  ? const Color(0x8C000000)
                  : const Color(0x6B281208)),
        ),
      );
}

/// .blob — soft orange (or custom) circle behind illustrations.
class BarqBlob extends StatelessWidget {
  const BarqBlob(
      {super.key,
      required this.size,
      this.gradient,
      this.color,
      this.child,
      this.opacity = 1});

  final double size;
  final Gradient? gradient;
  final Color? color;
  final Widget? child;
  final double opacity;

  /// Preset blob tints used on the state screens.
  static const green = RadialGradient(
      center: Alignment(-0.3, -0.4),
      colors: [Color(0xFFDDF5E5), Color(0xFFB9EBC9)]);
  static const grey = RadialGradient(
      center: Alignment(-0.3, -0.4),
      colors: [Color(0xFFF3ECE8), Color(0xFFE3D7D0)]);
  static const yellow = RadialGradient(
      center: Alignment(-0.3, -0.4),
      colors: [Color(0xFFFFF4CC), Color(0xFFFFE28A)]);
  static const red = RadialGradient(
      center: Alignment(-0.3, -0.4),
      colors: [Color(0xFFFFE6E1), Color(0xFFFFE6E1)]);

  @override
  Widget build(BuildContext context) {
    final b = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        gradient: color == null ? (gradient ?? BarqGradients.blob) : null,
      ),
      child: child,
    );
    return opacity >= 1 ? b : Opacity(opacity: opacity, child: b);
  }
}

/// Illustration area (.ill): blob + illustration centered, fixed height.
class BarqIllustrationArea extends StatelessWidget {
  const BarqIllustrationArea(
      {super.key,
      required this.height,
      required this.child,
      this.blobSize,
      this.blobGradient,
      this.blobTop,
      this.overlays = const []});

  final double height;
  final Widget child;
  final double? blobSize;
  final Gradient? blobGradient;

  /// Distance from the top. Null centers the blob.
  final double? blobTop;

  /// Extra positioned widgets (badges like "انتهت المهلة", floating pills).
  final List<Widget> overlays;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (blobSize != null)
              Positioned(
                  top: blobTop,
                  child: BarqBlob(size: blobSize!, gradient: blobGradient)),
            child,
            ...overlays,
          ],
        ),
      );
}
