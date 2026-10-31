import 'package:flutter/material.dart';

import '../foundation/barq_asset_names.dart';
import '../foundation/barq_assets.dart';
import '../foundation/barq_theme.dart';
import '../foundation/barq_tokens.dart';
import 'indicators.dart';
import 'inputs.dart';
import 'misc.dart';

/// The "متصل / غير متصل" pill with its toggle (driver home header).
class BarqOnlineSwitch extends StatelessWidget {
  const BarqOnlineSwitch({
    super.key,
    required this.online,
    required this.label,
    required this.onChanged,
    this.busy = false,
  });

  final bool online;
  final String label;
  final ValueChanged<bool> onChanged;

  /// True while the server is answering: taps do nothing.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final foreground =
        online ? BarqColors.darkSuccessText : BarqColors.darkSubtle;
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 6, 6, 6),
      decoration: BoxDecoration(
        color: online ? BarqColors.darkSuccessSoft : BarqColors.darkChip,
        borderRadius: BorderRadius.circular(BarqRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: BarqText.pill.copyWith(color: foreground)),
          const SizedBox(width: BarqSpacing.sm),
          BarqToggle(
            value: online,
            activeColor: BarqColors.success,
            onChanged: busy ? (_) {} : onChanged,
          ),
        ],
      ),
    );
  }
}

/// A number with a small label on a [BarqBanner] ("7 طلبات", "4.9 تقييم").
class BarqBannerStat extends StatelessWidget {
  const BarqBannerStat({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: BarqColors.onOrangePanel,
          borderRadius: BorderRadius.circular(BarqRadius.iconTile),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: BarqText.h2.copyWith(color: Colors.white)),
            Text(
              label,
              style: BarqText.xs.copyWith(color: BarqColors.onOrangeMuted),
            ),
          ],
        ),
      );
}

/// The big green power button on the driver's offline screen.
class BarqPowerButton extends StatelessWidget {
  const BarqPowerButton({super.key, this.onPressed, this.loading = false});

  final VoidCallback? onPressed;
  final bool loading;

  static const _outer = 260.0;
  static const _middle = 200.0;
  static const _inner = 140.0;
  static const _icon = 64.0;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: _outer,
        height: _outer,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: _outer,
              height: _outer,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: BarqColors.darkLine, width: 2),
              ),
            ),
            Container(
              width: _middle,
              height: _middle,
              decoration: const BoxDecoration(
                color: BarqColors.darkCard,
                shape: BoxShape.circle,
              ),
            ),
            GestureDetector(
              onTap: loading ? null : onPressed,
              child: Container(
                width: _inner,
                height: _inner,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  gradient: BarqGradients.green,
                  shape: BoxShape.circle,
                  boxShadow: BarqShadows.greenButton,
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const BarqIcon(
                        BarqIcons.power,
                        size: _icon,
                        color: Colors.white,
                      ),
              ),
            ),
          ],
        ),
      );
}

/// How full something is, as a thin bar ("النقد اللي معك"). [value] is 0 to 1.
class BarqProgressBar extends StatelessWidget {
  const BarqProgressBar({super.key, required this.value, this.gradient});

  final double value;

  /// Defaults to yellow into orange.
  final Gradient? gradient;

  static const _height = 8.0;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(_height),
        child: Container(
          height: _height,
          color: BarqPalette.of(context).progressOff,
          alignment: AlignmentDirectional.centerStart,
          child: FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: gradient ?? BarqGradients.cashProgress,
              ),
            ),
          ),
        ),
      );
}

/// "برق" with the "كابتن" pill: the driver app's logo (login, splash).
class BarqCaptainWordmark extends StatelessWidget {
  const BarqCaptainWordmark({
    super.key,
    required this.label,
    this.size = defaultSize,
  });

  static const defaultSize = 52.0;

  /// The word on the pill, from the app's translations.
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          BarqWordmark(size: size),
          const SizedBox(width: BarqSpacing.md),
          Flexible(child: BarqPill(label, tone: BarqPillTone.white)),
        ],
      );
}

/// The driver app's splash: logo over a soft orange glow on the dark screen.
class BarqCaptainSplash extends StatelessWidget {
  const BarqCaptainSplash({
    super.key,
    required this.label,
    required this.tagline,
  });

  final String label;
  final String tagline;

  static const _glow = 380.0;
  static const _wordmark = 72.0;
  static const _dotsBottom = 70.0;

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: _glow,
            height: _glow,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: BarqGradients.captainGlow,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BarqCaptainWordmark(label: label, size: _wordmark),
              const SizedBox(height: BarqSpacing.lg),
              Text(
                tagline,
                textAlign: TextAlign.center,
                style: BarqText.body.copyWith(color: BarqColors.darkSubtle),
              ),
            ],
          ),
          const Positioned(
            bottom: _dotsBottom,
            child: BarqDots(
              count: 3,
              index: 0,
              activeWidth: 8,
              activeColor: BarqColors.primary,
              inactiveColor: BarqColors.darkLine,
            ),
          ),
        ],
      );
}

/// The dark frame with four orange corners (photo of the order). Shows
/// [child], the art before the photo and the photo after it.
class BarqViewfinder extends StatelessWidget {
  const BarqViewfinder({
    super.key,
    required this.child,
    required this.height,
    this.radius = 30,
    this.cornerInset = 20,
    this.cornerSize = 40,
  });

  final Widget child;
  final double height;
  final double radius;
  final double cornerInset;
  final double cornerSize;

  static const _line = BorderSide(color: BarqColors.primary, width: 4);
  static const _cornerRadius = Radius.circular(14);

  Widget _corner(
    AlignmentGeometry alignment,
    Border border,
    BorderRadiusGeometry shape,
  ) =>
      Align(
        alignment: alignment,
        child: Padding(
          padding: EdgeInsets.all(cornerInset),
          child: Container(
            width: cornerSize,
            height: cornerSize,
            decoration: BoxDecoration(border: border, borderRadius: shape),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          height: height,
          decoration: const BoxDecoration(gradient: BarqGradients.viewfinder),
          child: Stack(
            fit: StackFit.expand,
            children: [
              child,
              _corner(
                Alignment.topRight,
                const Border(top: _line, right: _line),
                const BorderRadius.only(topRight: _cornerRadius),
              ),
              _corner(
                Alignment.topLeft,
                const Border(top: _line, left: _line),
                const BorderRadius.only(topLeft: _cornerRadius),
              ),
              _corner(
                Alignment.bottomRight,
                const Border(bottom: _line, right: _line),
                const BorderRadius.only(bottomRight: _cornerRadius),
              ),
              _corner(
                Alignment.bottomLeft,
                const Border(bottom: _line, left: _line),
                const BorderRadius.only(bottomLeft: _cornerRadius),
              ),
            ],
          ),
        ),
      );
}

/// The round camera button under [BarqViewfinder].
class BarqShutterButton extends StatelessWidget {
  const BarqShutterButton({super.key, this.onPressed, this.tooltip});

  final VoidCallback? onPressed;
  final String? tooltip;

  static const _outer = 78.0;
  static const _inner = 58.0;
  static const _ring = 5.0;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: tooltip,
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            width: _outer,
            height: _outer,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: _ring),
            ),
            child: Container(
              width: _inner,
              height: _inner,
              decoration: const BoxDecoration(
                color: BarqColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      );
}

/// One column of [BarqBarChart]. [value] only sets the height.
class BarqBar {
  const BarqBar(
      {required this.label, required this.value, this.active = false});

  final String label;
  final num value;

  /// The orange bar: today.
  final bool active;
}

/// The earnings chart: one rounded bar per day, the tallest fills the height.
class BarqBarChart extends StatelessWidget {
  const BarqBarChart({super.key, required this.bars});

  final List<BarqBar> bars;

  static const _height = 130.0;
  static const _emptyBar = 12.0;
  static const _labelSpace = 24.0;
  static const _gap = 4.0;

  @override
  Widget build(BuildContext context) {
    var tallest = 0.0;
    for (final bar in bars) {
      if (bar.value > tallest) tallest = bar.value.toDouble();
    }
    final room = _height - _labelSpace;
    return SizedBox(
      height: _height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final bar in bars)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: _gap),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: tallest == 0 || bar.value == 0
                          ? _emptyBar
                          : (bar.value / tallest * room).clamp(_emptyBar, room),
                      decoration: BoxDecoration(
                        color: bar.active ? null : BarqColors.darkLine,
                        gradient: bar.active ? BarqGradients.chartBar : null,
                        borderRadius: BorderRadius.circular(BarqSpacing.md),
                      ),
                    ),
                    const SizedBox(height: BarqSpacing.xs),
                    Text(
                      bar.label,
                      maxLines: 1,
                      style: BarqText.xs.copyWith(
                        color: bar.active
                            ? BarqColors.primaryLight
                            : BarqColors.darkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
