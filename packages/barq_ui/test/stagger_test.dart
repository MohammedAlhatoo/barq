import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _list({
  required PageStorageBucket bucket,
  bool show = true,
  bool reducedMotion = false,
}) => MediaQuery(
  data: MediaQueryData(disableAnimations: reducedMotion),
  child: Directionality(
    textDirection: TextDirection.rtl,
    child: PageStorage(
      bucket: bucket,
      child: show
          ? Column(
              children: [
                for (var index = 0; index < 3; index++)
                  BarqStaggerItem(
                    group: 'test',
                    index: index,
                    child: Text('$index'),
                  ),
              ],
            )
          : const SizedBox(),
    ),
  ),
);

void main() {
  testWidgets('plays once, even when the items are built again', (
    tester,
  ) async {
    final bucket = PageStorageBucket();
    await tester.pumpWidget(_list(bucket: bucket));
    expect(find.byType(Animate), findsNWidgets(3));
    await tester.pumpAndSettle();

    await tester.pumpWidget(_list(bucket: bucket, show: false));
    await tester.pumpWidget(_list(bucket: bucket));
    expect(find.byType(Animate), findsNothing);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('reduced motion shows the items at once', (tester) async {
    await tester.pumpWidget(
      _list(bucket: PageStorageBucket(), reducedMotion: true),
    );
    expect(find.byType(Animate), findsNothing);
    expect(find.text('0'), findsOneWidget);
  });
}
