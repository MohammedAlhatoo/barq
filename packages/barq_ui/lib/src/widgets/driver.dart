import 'package:flutter/material.dart';

import '../foundation/barq_asset_names.dart';
import '../foundation/barq_assets.dart';
import '../foundation/barq_theme.dart';
import '../foundation/barq_tokens.dart';
import 'inputs.dart';

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
