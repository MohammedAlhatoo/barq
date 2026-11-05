import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';

/// Moves [child] slowly up and down, as if it floats. It stays still when the
/// phone asks for less motion.
class OnboardingFloat extends StatefulWidget {
  const OnboardingFloat({
    super.key,
    required this.child,
    this.distance = 6,
    this.delay = 0,
  });

  final Widget child;

  /// How far it travels, in pixels.
  final double distance;

  /// Where in the round it starts, from 0 to 1, so layers move apart.
  final double delay;

  @override
  State<OnboardingFloat> createState() => _OnboardingFloatState();
}

class _OnboardingFloatState extends State<OnboardingFloat>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: BarqDurations.onboardingFloat,
    value: widget.delay,
  );
  late final _position = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _position.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _position,
    child: widget.child,
    builder: (context, child) => Transform.translate(
      offset: Offset(0, (_position.value - .5) * widget.distance),
      child: child,
    ),
  );
}

/// Grows [child] into place once, from the point [center].
class OnboardingPop extends StatelessWidget {
  const OnboardingPop({super.key, required this.child, required this.center});

  final Widget child;
  final Alignment center;

  static const _start = .7;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: still ? 1 : _start, end: 1),
      duration: BarqDurations.onboardingPop,
      curve: Curves.easeOutBack,
      child: child,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, alignment: center, child: child),
    );
  }
}
