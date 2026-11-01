// Draws the launcher icons and launch screen logos of both apps from the real
// barq_ui widgets (real Lalezar shaping, real boltc.svg). Run it from
// packages/barq_ui, then run the two packages that use the PNGs:
//
//   flutter test tool/generate_brand_assets.dart
//   cd ../../apps/customer   (and apps/driver)
//   dart run flutter_launcher_icons
//   dart run flutter_native_splash:create
//
// It is a test only because that gives us a renderer with no device. It lives
// outside test/, so `flutter test` never runs it.
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _canvas = 1024.0;

/// Android keeps a circle of about this share of the canvas on every mask.
const _safeCircle = .66;

/// The legacy icon's rounded corners, as a share of the canvas.
const _legacyRadius = .225;

/// Android 12 and the others show this image at 288 logical pixels (4x).
const _splashCanvas = 1152.0;
const _splashScale = 4.0;

const _captainLabel = 'كابتن';

/// A pixel lighter than this counts as empty when measuring the logo.
const _visibleAlpha = 8;

class _App {
  const _App(this.folder, this.background, this.logo, this.tile, this.theme);

  final String folder;
  final Widget background;

  /// The logo at any size, on nothing.
  final Widget logo;

  /// The splash tile, exactly as the Flutter splash draws it.
  final Widget tile;

  /// The app's own theme, so the tile matches its Flutter splash exactly.
  final ThemeData Function() theme;

  String get output => '../../apps/$folder/assets/icon';
}

final _apps = [
  _App(
    'customer',
    const DecoratedBox(
      decoration: BoxDecoration(gradient: BarqGradients.orange),
    ),
    const BarqWordmark(size: 200, color: Colors.white),
    const BarqLogoTile(glass: true),
    barqLightTheme,
  ),
  _App(
    'driver',
    const ColoredBox(color: BarqColors.ink),
    const BarqCaptainLogo(label: _captainLabel, size: 200),
    const BarqLogoTile(captainLabel: _captainLabel),
    barqDarkTheme,
  ),
];

final _boundary = GlobalKey();

Future<void> _loadFonts() async {
  Future<ByteData> read(String path) async =>
      ByteData.sublistView(await File(path).readAsBytes());

  final lalezar = FontLoader('packages/barq_ui/Lalezar')
    ..addFont(read('fonts/Lalezar-Regular.ttf'));
  final rubik = FontLoader('packages/barq_ui/Rubik');
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    rubik.addFont(read('fonts/Rubik-$weight.ttf'));
  }
  await Future.wait([lalezar.load(), rubik.load()]);
}

/// Pumps [child] on a transparent [size] square and returns its picture.
Future<ui.Image> _render(
  WidgetTester tester,
  Widget child, {
  required double size,
  double pixelRatio = 1,
  ThemeData Function() theme = barqLightTheme,
}) async {
  await tester.pumpWidget(
    Theme(
      data: theme(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Align(
          alignment: Alignment.topLeft,
          child: RepaintBoundary(
            key: _boundary,
            child: SizedBox.square(dimension: size, child: child),
          ),
        ),
      ),
    ),
  );
  // The SVG loads with real timers, outside the fake clock.
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 60)),
    );
    await tester.pump();
  }
  final boundary =
      _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  return (await tester.runAsync(
    () => boundary.toImage(pixelRatio: pixelRatio),
  ))!;
}

Future<void> _save(WidgetTester tester, ui.Image image, String path) async {
  await tester.runAsync(() async {
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File(path)..createSync(recursive: true);
    await file.writeAsBytes(png!.buffer.asUint8List());
  });
}

class _Bounds {
  const _Bounds(this.center, this.radius);

  /// Middle of the logo's bounding box.
  final Offset center;

  /// Distance from [center] to the logo's farthest pixel.
  final double radius;
}

Future<_Bounds> _measure(WidgetTester tester, ui.Image image) async {
  final bytes = (await tester.runAsync(
    () => image.toByteData(format: ui.ImageByteFormat.rawRgba),
  ))!;
  final pixels = <Offset>[];
  var left = double.infinity, top = double.infinity;
  var right = 0.0, bottom = 0.0;
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      if (bytes.getUint8((y * image.width + x) * 4 + 3) <= _visibleAlpha) {
        continue;
      }
      pixels.add(Offset(x.toDouble(), y.toDouble()));
      left = math.min(left, x.toDouble());
      right = math.max(right, x.toDouble());
      top = math.min(top, y.toDouble());
      bottom = math.max(bottom, y.toDouble());
    }
  }
  final center = Offset((left + right) / 2, (top + bottom) / 2);
  final radius = pixels.map((p) => (p - center).distance).reduce(math.max);
  return _Bounds(center, radius);
}

/// [logo] centered by what you see (not by its layout box), and just big
/// enough to touch the safe circle.
Future<Widget> _fitted(WidgetTester tester, Widget logo) async {
  final measured = await _measure(
    tester,
    await _render(tester, Center(child: logo), size: _canvas),
  );
  final scale = _canvas * _safeCircle / 2 / measured.radius;
  final middle = const Offset(_canvas / 2, _canvas / 2);
  return Transform.scale(
    scale: scale,
    child: Transform.translate(
      offset: middle - measured.center,
      child: Center(child: logo),
    ),
  );
}

void main() {
  testWidgets('generate', (tester) async {
    await tester.runAsync(_loadFonts);
    tester.view.physicalSize = const Size(1600, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    for (final app in _apps) {
      final foreground = await _fitted(tester, app.logo);

      final layers = {
        'icon_background.png': app.background,
        'icon_foreground.png': foreground,
        'icon_ios.png': Stack(
          fit: StackFit.expand,
          children: [app.background, foreground],
        ),
        'icon_legacy.png': ClipRRect(
          borderRadius: BorderRadius.circular(_canvas * _legacyRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [app.background, foreground],
          ),
        ),
      };
      for (final MapEntry(key: name, value: widget) in layers.entries) {
        final image = await _render(tester, widget, size: _canvas);
        await _save(tester, image, '${app.output}/$name');
      }

      final splash = await _render(
        tester,
        Center(
          child: Transform.scale(
            scale: BarqLogoTile.nativeSize / BarqLogoTile.splashSize,
            child: app.tile,
          ),
        ),
        size: _splashCanvas / _splashScale,
        pixelRatio: _splashScale,
        theme: app.theme,
      );
      await _save(tester, splash, '${app.output}/splash_logo.png');

      final check = await _measure(
        tester,
        await _render(tester, foreground, size: _canvas),
      );
      final limit = _canvas * _safeCircle / 2 + 4;
      expect(
        (check.center - const Offset(_canvas / 2, _canvas / 2)).distance +
            check.radius,
        lessThan(limit),
        reason: '${app.folder}: the logo left the adaptive safe zone',
      );
    }
  });
}
