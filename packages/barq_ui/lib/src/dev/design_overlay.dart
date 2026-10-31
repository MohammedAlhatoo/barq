import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Pixel-matching helper: draws the design PNG of this screen on top of the
/// running screen with adjustable opacity, so anyone (with or without an AI
/// tool) can see exactly where the UI differs from the design.
///
/// ```dart
/// return DesignOverlay(
///   image: 'design/03_checkout_04.png', // from docs/design/overlay/...
///   child: BarqScreen(...),
/// );
/// ```
///
/// * Tap the small orange "تصميم" pill (bottom-left) to show/hide the design.
/// * Drag the slider to change opacity (try 50%: misaligned edges look doubled).
/// * Does nothing in release builds, or when the image is not in the assets.
///   `design/` is left out of the apps' pubspec so release builds stay small:
///   add it back while comparing a screen.
class DesignOverlay extends StatefulWidget {
  const DesignOverlay(
      {super.key,
      required this.image,
      required this.child,
      this.enabled = true,
      this.package});

  /// Asset path of the design image (overlay version, without phone frame).
  final String image;
  final Widget child;
  final bool enabled;

  /// Set if the image lives in another package.
  final String? package;

  @override
  State<DesignOverlay> createState() => _DesignOverlayState();
}

class _DesignOverlayState extends State<DesignOverlay> {
  bool _visible = false;
  double _opacity = .5;
  bool _imageFound = false;

  @override
  void initState() {
    super.initState();
    if (!kReleaseMode) _checkImage();
  }

  @override
  void didUpdateWidget(DesignOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!kReleaseMode && oldWidget.image != widget.image) _checkImage();
  }

  Future<void> _checkImage() async {
    final package = widget.package;
    final key =
        package == null ? widget.image : 'packages/$package/${widget.image}';
    var found = true;
    try {
      await rootBundle.load(key);
    } on Object {
      found = false;
    }
    if (mounted && found != _imageFound) setState(() => _imageFound = found);
  }

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode || !widget.enabled || !_imageFound) return widget.child;
    return Stack(
      children: [
        widget.child,
        if (_visible)
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: _opacity,
                child: Image.asset(widget.image,
                    package: widget.package,
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topCenter),
              ),
            ),
          ),
        Positioned(
          left: 8,
          bottom: 120,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Material(
              color: const Color(0xE6151515),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _visible = !_visible),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _visible
                              ? const Color(0xFFFF7A21)
                              : const Color(0xFF3A2E28),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          'تصميم',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    if (_visible)
                      SizedBox(
                        width: 120,
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                              trackHeight: 2,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 7)),
                          child: Slider(
                            value: _opacity,
                            min: .1,
                            max: 1,
                            activeColor: const Color(0xFFFF7A21),
                            onChanged: (v) => setState(() => _opacity = v),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
