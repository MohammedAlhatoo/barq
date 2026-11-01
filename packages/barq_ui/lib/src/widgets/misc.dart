import 'package:flutter/material.dart';

import '../foundation/barq_asset_names.dart';
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
      this.gradient,
      this.showBolt = true,
      this.boltFlash = 0});
  final double size;
  final Color color;

  /// Paints the letters with this gradient instead of [color].
  final Gradient? gradient;
  final bool showBolt;

  /// 0 is the resting bolt, 1 is the peak of its flash on the splash.
  final double boltFlash;

  static const _flashGrowth = .22;
  static const _glowFactor = 1.1;

  @override
  Widget build(BuildContext context) {
    final letters = Text('برق', style: BarqText.wordmark(size, color: color));
    final fill = gradient;
    final boltWidth = size * .34;
    final boltHeight = size * .46;
    final glow = size * _glowFactor;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (fill == null)
          letters
        else
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: fill.createShader,
            child: letters,
          ),
        if (showBolt && boltFlash > 0)
          Positioned(
            top: -size * .02 + (boltHeight - glow) / 2,
            left: -size * .2 + (boltWidth - glow) / 2,
            child: IgnorePointer(
              child: Opacity(
                opacity: boltFlash.clamp(0.0, 1.0),
                child: Container(
                  width: glow,
                  height: glow,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: BarqGradients.boltGlow,
                  ),
                ),
              ),
            ),
          ),
        if (showBolt)
          Positioned(
            top: -size * .02,
            left: -size * .2,
            child: Transform.rotate(
              angle: 0.21, // 12deg
              child: Transform.scale(
                scale: 1 + boltFlash * _flashGrowth,
                child: BarqIllustration('boltc',
                    width: boltWidth, height: boltHeight),
              ),
            ),
          ),
      ],
    );
  }
}

/// App logo in a rounded square: glass on the splash, white on forced update,
/// dark with the "كابتن" pill when [captainLabel] is set (driver splash).
class BarqLogoTile extends StatelessWidget {
  const BarqLogoTile(
      {super.key, this.glass = false, this.captainLabel, this.boltFlash = 0});
  final bool glass;

  /// The word on the pill, from the app's translations.
  final String? captainLabel;

  /// See [BarqWordmark.boltFlash].
  final double boltFlash;

  /// The tile on the splash. The launch screen PNGs show it at [nativeSize],
  /// so the animation can start exactly where they stop.
  static const splashSize = 170.0;
  static const nativeSize = 150.0;
  static const _captainWordmark = 80.0;

  @override
  Widget build(BuildContext context) {
    final label = captainLabel;
    final isSplash = glass || label != null;
    final size = isSplash ? splashSize : 150.0;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: label != null
            ? BarqColors.darkCard
            : glass
                ? const Color(0x2EFFFFFF)
                : Colors.white,
        borderRadius: BorderRadius.circular(isSplash ? 48 : 46),
        border: label != null
            ? Border.all(color: BarqColors.darkLine)
            : glass
                ? Border.all(color: const Color(0x59FFFFFF))
                : null,
        boxShadow: isSplash
            ? null
            : const [
                BoxShadow(
                    color: Color(0x99782800),
                    offset: Offset(0, 24),
                    blurRadius: 40,
                    spreadRadius: -18)
              ],
      ),
      child: label != null
          ? FittedBox(
              fit: BoxFit.scaleDown,
              child: BarqCaptainLogo(
                  label: label, size: _captainWordmark, boltFlash: boltFlash),
            )
          : BarqWordmark(
              size: glass ? 92 : 76,
              color: glass ? Colors.white : BarqColors.primary,
              boltFlash: boltFlash),
    );
  }
}

/// "برق" in the orange gradient over the "كابتن" pill: the driver's app icon
/// and the inside of its splash tile.
class BarqCaptainLogo extends StatelessWidget {
  const BarqCaptainLogo(
      {super.key, required this.label, this.size = 80, this.boltFlash = 0});

  final String label;
  final double size;

  /// See [BarqWordmark.boltFlash].
  final double boltFlash;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BarqWordmark(
              size: size, gradient: BarqGradients.orange, boltFlash: boltFlash),
          SizedBox(height: size * .1),
          BarqPill(label,
              tone: BarqPillTone.orange,
              fontSize: size * .19,
              padding: EdgeInsets.symmetric(
                  horizontal: size * .18, vertical: size * .04)),
        ],
      );
}

/// Plays after the native launch screen, whose last picture is its first
/// frame: [startColor] with the logo at its native size, in the exact center.
/// The logo grows, the bolt flashes, then the real background ([decor] and
/// whatever is behind this widget), [tagline] and the dots appear.
///
/// With reduced motion, or [animate] false, it shows the end at once.
class BarqSplashIntro extends StatefulWidget {
  const BarqSplashIntro({
    super.key,
    required this.startColor,
    required this.logo,
    required this.tagline,
    required this.dots,
    this.decor,
    this.animate = true,
    this.onFinished,
  });

  final Color startColor;

  /// Builds the logo for a bolt flash from 0 to 1.
  final Widget Function(double boltFlash) logo;
  final Widget tagline;
  final Widget dots;
  final Widget? decor;
  final bool animate;
  final VoidCallback? onFinished;

  static const _dotsBottom = 70.0;
  static const _taglineGap = 26.0;

  @override
  State<BarqSplashIntro> createState() => _BarqSplashIntroState();
}

class _BarqSplashIntroState extends State<BarqSplashIntro>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: BarqDurations.splashIntro);

  late final Animation<double> _scale = Tween(
    begin: BarqLogoTile.nativeSize / BarqLogoTile.splashSize,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, .45, curve: Curves.easeOutBack),
  ));

  late final Animation<double> _flash = TweenSequence<double>([
    TweenSequenceItem(tween: ConstantTween(0), weight: 25),
    TweenSequenceItem(
      tween: Tween<double>(begin: 0, end: 1)
          .chain(CurveTween(curve: Curves.easeOut)),
      weight: 12,
    ),
    TweenSequenceItem(
      tween: Tween<double>(begin: 1, end: 0)
          .chain(CurveTween(curve: Curves.easeIn)),
      weight: 23,
    ),
    TweenSequenceItem(tween: ConstantTween(0), weight: 40),
  ]).animate(_controller);

  late final Animation<double> _reveal = CurvedAnimation(
    parent: _controller,
    curve: const Interval(.4, .85, curve: Curves.easeInOut),
  );

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (!widget.animate || MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) => _finish());
    } else {
      _controller.forward().whenComplete(_finish);
    }
  }

  void _finish() {
    if (mounted) widget.onFinished?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final reveal = _reveal.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              if (widget.decor != null) Positioned.fill(child: widget.decor!),
              if (reveal < 1)
                Positioned.fill(
                  child: Opacity(
                    opacity: 1 - reveal,
                    child: ColoredBox(color: widget.startColor),
                  ),
                ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: _scale.value,
                    child: widget.logo(_flash.value),
                  ),
                  // Starts with no height, so the logo starts in the center.
                  ClipRect(
                    child: Align(
                      alignment: Alignment.topCenter,
                      heightFactor: reveal,
                      child: Opacity(
                        opacity: reveal,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: BarqSplashIntro._taglineGap),
                          child: widget.tagline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: BarqSplashIntro._dotsBottom,
                child: Opacity(opacity: reveal, child: widget.dots),
              ),
            ],
          );
        },
      );
}

/// Splash body: the glass logo tile, tagline and three dots (animated).
class BarqSplashContent extends StatelessWidget {
  const BarqSplashContent(
      {super.key, required this.tagline, this.animate = true, this.onFinished});
  final String tagline;

  /// See [BarqSplashIntro].
  final bool animate;
  final VoidCallback? onFinished;

  @override
  Widget build(BuildContext context) => BarqSplashIntro(
        startColor: BarqColors.primary,
        animate: animate,
        onFinished: onFinished,
        decor: const BarqDecorCircles(),
        logo: (flash) => BarqLogoTile(glass: true, boltFlash: flash),
        tagline: Text(tagline,
            textAlign: TextAlign.center,
            style: BarqText.h2.copyWith(color: Colors.white)),
        dots: const BarqDots(
            count: 3,
            index: 0,
            activeWidth: 8,
            activeColor: Colors.white,
            inactiveColor: Color(0x80FFFFFF)),
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
      this.light = false,
      this.border = 0,
      this.imageUrl,
      this.image,
      this.badge});
  final String initial;
  final double size;
  final bool dark;

  /// White circle with an orange letter (the account card).
  final bool light;

  /// White ring width (profile header uses 4–5).
  final double border;
  final String? imageUrl;

  /// A picked picture that is not uploaded yet. Wins over [imageUrl].
  final ImageProvider? image;

  /// Small widget at the bottom-end (camera button on edit profile).
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    final picture = image ?? (url != null ? NetworkImage(url) : null);
    final circle = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: dark || light ? null : BarqGradients.orange,
        color: dark ? BarqColors.ink : (light ? Colors.white : null),
        border:
            border > 0 ? Border.all(color: Colors.white, width: border) : null,
        image: picture != null
            ? DecorationImage(image: picture, fit: BoxFit.cover)
            : null,
      ),
      child: picture != null
          ? null
          : Text(initial,
              style: BarqText.h2.copyWith(
                  color: light ? BarqColors.primary : Colors.white,
                  fontSize: size * .38)),
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
                  tone: onOrange ? BarqPillTone.onOrange : BarqPillTone.white)),
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

/// The picture of the offer expired screen (04_order_status_03): a tilted
/// clock card with [label] on a pill under it.
class BarqOfferExpiredArt extends StatelessWidget {
  const BarqOfferExpiredArt({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => BarqIllustrationArea(
        height: BarqSizes.offerExpiredArt,
        blobSize: BarqSizes.offerExpiredBlob,
        overlays: [
          Positioned(
            bottom: BarqSizes.offerExpiredPillBottom,
            child: BarqPill(label, tone: BarqPillTone.danger),
          ),
        ],
        child: const BarqIconCard(
          icon: 'clock',
          size: BarqSizes.offerExpiredIcon,
          radius: 40,
          angle: -8,
        ),
      );
}

/// Rings around a store: the customer's "waiting for the store" screen.
class BarqWaitingArt extends StatelessWidget {
  const BarqWaitingArt({super.key});

  Widget _ring(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  @override
  Widget build(BuildContext context) => SizedBox(
        height: BarqSizes.waitingArt,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _ring(BarqSizes.waitingOuter, const Color(0x14FF7A21)),
            _ring(BarqSizes.waitingInner, const Color(0x24FF7A21)),
            Container(
              width: BarqSizes.waitingBadge,
              height: BarqSizes.waitingBadge,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xCCFF7A21),
                    offset: Offset(0, 16),
                    blurRadius: 30,
                    spreadRadius: -14,
                  ),
                ],
              ),
              child: const BarqIllustration(
                'storefront',
                width: BarqSizes.waitingStore,
                height: BarqSizes.waitingStore,
              ),
            ),
          ],
        ),
      );
}

/// A box on a green circle with confetti: the "delivered" screen.
class BarqDeliveredArt extends StatelessWidget {
  const BarqDeliveredArt({super.key});

  Widget _confetti(double width, double height, Color color, double angle) =>
      Transform.rotate(
        angle: angle,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => SizedBox(
        height: BarqSizes.deliveredArtHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: BarqSizes.deliveredCircle,
              height: BarqSizes.deliveredCircle,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: Alignment(-.3, -.4),
                  colors: [Color(0xFFDDF5E5), Color(0xFFB9EBC9)],
                ),
              ),
            ),
            const BarqIllustration(
              'box',
              width: BarqSizes.deliveredBox,
              height: BarqSizes.deliveredBox,
            ),
            Positioned(
              top: 40,
              right: 70,
              child: _confetti(12, 12, BarqColors.primary, .35),
            ),
            Positioned(
              top: 70,
              left: 66,
              child: _confetti(10, 10, const Color(0xFFFFC21A), 0),
            ),
            Positioned(
              bottom: 40,
              right: 56,
              child: _confetti(9, 16, const Color(0xFF1E9E55), -.5),
            ),
          ],
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

/// Card floating above the nav bar: the customer's running order, its status
/// and a short hint. [highlighted] marks something waiting for the customer.
class BarqActiveOrderBar extends StatelessWidget {
  const BarqActiveOrderBar(
      {super.key,
      required this.code,
      required this.hint,
      required this.status,
      this.more = 0,
      this.highlighted = false,
      this.onTap});

  final String code;
  final String hint;

  /// The status pill. barq_ui knows nothing about order statuses.
  final Widget status;

  /// How many other orders are running, shown as "+N". 0 = hidden.
  final int more;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    return BarqCard(
      onTap: onTap,
      borderColor: highlighted ? BarqColors.primary : BarqColors.primaryBorder,
      padding: const EdgeInsets.all(BarqSpacing.gap),
      child: Row(
        children: [
          BarqIconTile(highlighted ? BarqIcons.bell : BarqIcons.receipt),
          const SizedBox(width: BarqSpacing.gap),
          Expanded(
            child: BarqGap(
              gap: 0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: BarqText.h3.copyWith(color: p.text)),
                Text(hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: highlighted
                        ? BarqText.xs.copyWith(
                            color: BarqColors.primary,
                            fontWeight: FontWeight.w700)
                        : BarqText.xs),
              ],
            ),
          ),
          const SizedBox(width: BarqSpacing.sm),
          // The server writes the status, so its length is unknown.
          ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: BarqSizes.activeOrderStatus),
            child: FittedBox(fit: BoxFit.scaleDown, child: status),
          ),
          if (more > 0) ...[
            const SizedBox(width: BarqSpacing.xs),
            // Without this, RTL text would draw it as "2+".
            Directionality(
              textDirection: TextDirection.ltr,
              child: BarqPill('+$more', tone: BarqPillTone.neutral),
            ),
          ],
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
