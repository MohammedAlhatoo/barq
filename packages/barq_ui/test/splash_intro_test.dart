import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _intro({
  bool reducedMotion = false,
  bool animate = true,
  VoidCallback? onFinished,
}) =>
    MediaQuery(
      data: MediaQueryData(disableAnimations: reducedMotion),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: BarqSplashIntro(
          startColor: BarqColors.primary,
          animate: animate,
          onFinished: onFinished,
          logo: (_) =>
              const SizedBox.square(dimension: BarqLogoTile.splashSize),
          tagline: const Text('شعار'),
          dots: const SizedBox(),
        ),
      ),
    );

double _logoScale(WidgetTester tester) =>
    tester.widget<Transform>(find.byType(Transform).first).transform.storage[0];

void main() {
  testWidgets('starts at the native logo size and lasts 1.2 to 1.5 seconds', (
    tester,
  ) async {
    var finished = 0;
    await tester.pumpWidget(_intro(onFinished: () => finished++));

    expect(
      _logoScale(tester),
      closeTo(BarqLogoTile.nativeSize / BarqLogoTile.splashSize, .001),
    );
    expect(
        BarqDurations.splashIntro.inMilliseconds, inInclusiveRange(1200, 1500));

    await tester
        .pump(BarqDurations.splashIntro - const Duration(milliseconds: 50));
    expect(finished, 0);

    await tester.pump(const Duration(milliseconds: 100));
    expect(finished, 1);
    expect(_logoScale(tester), closeTo(1, .001));
  });

  testWidgets('reduced motion shows the end and finishes at once', (
    tester,
  ) async {
    var finished = 0;
    await tester.pumpWidget(
      _intro(reducedMotion: true, onFinished: () => finished++),
    );
    await tester.pump();

    expect(finished, 1);
    expect(_logoScale(tester), closeTo(1, .001));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('does not play again when coming back from a retry', (
    tester,
  ) async {
    var finished = 0;
    await tester
        .pumpWidget(_intro(animate: false, onFinished: () => finished++));
    await tester.pump();

    expect(finished, 1);
    expect(_logoScale(tester), closeTo(1, .001));
  });
}
