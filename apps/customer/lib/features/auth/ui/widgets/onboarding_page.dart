import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';

/// One slide: illustration, big title and description.
///
/// The picture and the text follow the finger, each at its own speed, so the
/// slides feel layered. The first slide also plays a short entrance once.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    super.key,
    required this.art,
    required this.title,
    required this.body,
    required this.index,
    required this.pages,
    this.playIntro = false,
  });

  final Widget art;
  final String title;
  final String body;

  /// This slide's place in the PageView that [pages] controls.
  final int index;
  final PageController pages;
  final bool playIntro;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  // Each is a share of the movement while the slide is one page away.
  static const _artShift = .16;
  static const _artTilt = .10;
  static const _artShrink = .18;
  static const _textShift = .28;

  static const _introArtStart = .86;
  static const _introTextRise = 18.0;

  late final _intro = AnimationController(
    vsync: this,
    duration: BarqDurations.onboardingIntro,
  );
  late final _artIntro = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0, .75, curve: Curves.easeOutBack),
  );
  late final _titleIntro = CurvedAnimation(
    parent: _intro,
    curve: const Interval(.25, .8, curve: Curves.easeOutCubic),
  );
  late final _bodyIntro = CurvedAnimation(
    parent: _intro,
    curve: const Interval(.4, 1, curve: Curves.easeOutCubic),
  );

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (widget.playIntro && !MediaQuery.disableAnimationsOf(context)) {
      _intro.forward();
    } else {
      _intro.value = 1;
    }
  }

  @override
  void dispose() {
    _artIntro.dispose();
    _titleIntro.dispose();
    _bodyIntro.dispose();
    _intro.dispose();
    super.dispose();
  }

  /// 0 when this slide is centered, 1 when it is a full page away.
  double get _distance {
    final pages = widget.pages;
    final ready = pages.hasClients && pages.position.haveDimensions;
    final page = ready ? pages.page! : pages.initialPage.toDouble();
    return (widget.index - page).clamp(-1.0, 1.0);
  }

  Widget _text(String text, TextStyle style, double intro, double shift) =>
      Transform.translate(
        offset: Offset(shift, _introTextRise * (1 - intro)),
        child: Opacity(
          opacity: intro.clamp(0.0, 1.0),
          child: Text(text, style: style),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final side = Directionality.of(context) == TextDirection.rtl ? -1.0 : 1.0;
    return AnimatedBuilder(
      animation: Listenable.merge([widget.pages, _intro]),
      builder: (context, _) {
        final distance = _distance;
        final away = distance.abs();
        final introScale =
            _introArtStart + (1 - _introArtStart) * _artIntro.value;
        final textShift = distance * side * width * _textShift;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Transform.translate(
                offset: Offset(-distance * side * width * _artShift, 0),
                child: Transform.rotate(
                  angle: distance * side * _artTilt,
                  child: Transform.scale(
                    scale: (1 - away * _artShrink) * introScale,
                    child: Opacity(
                      opacity: _intro.value.clamp(0.0, 1.0) * (1 - away * .6),
                      child: widget.art,
                    ),
                  ),
                ),
              ),
              Opacity(
                opacity: 1 - away,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: BarqSpacing.page,
                  ),
                  child: BarqGap(
                    gap: BarqSpacing.md,
                    children: [
                      _text(
                        widget.title,
                        BarqText.h0,
                        _titleIntro.value,
                        textShift,
                      ),
                      _text(
                        widget.body,
                        BarqText.body,
                        _bodyIntro.value,
                        textShift * 1.3,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
