import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'barq_tokens.dart';

const _pkg = 'barq_ui';

/// A line icon from the design, tinted with [color] (defaults to the
/// current IconTheme color). Example: `BarqIcon(BarqIcons.bag, size: BarqSizes.iconM)`.
class BarqIcon extends StatelessWidget {
  const BarqIcon(this.name,
      {super.key, this.size = BarqSizes.icon, this.color, this.semanticLabel});

  /// One of [BarqIcons].
  final String name;
  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color ?? BarqColors.ink;
    return SvgPicture.asset(
      'assets/icons/$name.svg',
      package: _pkg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
      semanticsLabel: semanticLabel,
    );
  }
}

/// A colored illustration (products, 3D objects, map …). Keeps its own colors.
/// Example: `BarqIllustration(BarqIllustrations.basket, width: 300)`.
class BarqIllustration extends StatelessWidget {
  const BarqIllustration(this.name,
      {super.key,
      this.width,
      this.height,
      this.fit = BoxFit.contain,
      this.opacity = 1});

  /// One of [BarqIllustrations].
  final String name;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final pic = SvgPicture.asset(
      'assets/illustrations/$name.svg',
      package: _pkg,
      width: width,
      height: height,
      fit: fit,
    );
    return opacity >= 1 ? pic : Opacity(opacity: opacity, child: pic);
  }
}
