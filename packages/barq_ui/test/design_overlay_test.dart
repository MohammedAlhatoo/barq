import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _pill = 'تصميم';

Widget _overlay() => const Directionality(
      textDirection: TextDirection.rtl,
      child: DesignOverlay(image: 'design/screen.png', child: Text('الشاشة')),
    );

void main() {
  testWidgets('a missing image shows only the screen', (tester) async {
    await tester.pumpWidget(_overlay());
    await tester.pumpAndSettle();

    expect(find.text('الشاشة'), findsOneWidget);
    expect(find.text(_pill), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a found image shows the pill', (tester) async {
    tester.binding.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (_) async => ByteData(1),
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', null),
    );

    await tester.pumpWidget(_overlay());
    await tester.pumpAndSettle();

    expect(find.text(_pill), findsOneWidget);
  });
}
