import 'package:flutter/material.dart';

import 'barq_tokens.dart';

const _pkg = 'barq_ui';

/// Text styles from the design (.h0 … .xs). Colors default to ink; widgets
/// override with the palette color when on dark screens.
abstract final class BarqText {
  static const family = 'Rubik';
  static const wordmarkFamily = 'Lalezar';

  static const h0 = TextStyle(
      fontFamily: family,
      package: _pkg,
      fontSize: 32,
      height: 1.25,
      fontWeight: FontWeight.w700,
      color: BarqColors.ink);
  static const h1 = TextStyle(
      fontFamily: family,
      package: _pkg,
      fontSize: 26,
      height: 1.3,
      fontWeight: FontWeight.w600,
      color: BarqColors.ink);
  static const h2 = TextStyle(
      fontFamily: family,
      package: _pkg,
      fontSize: 20,
      height: 1.35,
      fontWeight: FontWeight.w600,
      color: BarqColors.ink);
  static const h3 = TextStyle(
      fontFamily: family,
      package: _pkg,
      fontSize: 16,
      height: 1.4,
      fontWeight: FontWeight.w600,
      color: BarqColors.ink);

  /// .p — paragraph / screen description
  static const body = TextStyle(
      fontFamily: family,
      package: _pkg,
      fontSize: 15,
      height: 1.7,
      color: BarqColors.muted);

  /// .t — normal UI text
  static const t = TextStyle(
      fontFamily: family,
      package: _pkg,
      fontSize: 14,
      height: 1.55,
      color: BarqColors.ink);

  /// .t.b
  static const tBold = TextStyle(
      fontFamily: family,
      package: _pkg,
      fontSize: 14,
      height: 1.55,
      fontWeight: FontWeight.w600,
      color: BarqColors.ink);

  /// .xs — captions
  static const xs = TextStyle(
      fontFamily: family,
      package: _pkg,
      fontSize: 12,
      height: 1.4,
      color: BarqColors.muted);
  static const button = TextStyle(
      fontFamily: family,
      package: _pkg,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white);
  static const buttonSmall = TextStyle(
      fontFamily: family,
      package: _pkg,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: Colors.white);
  static const pill = TextStyle(
      fontFamily: family,
      package: _pkg,
      fontSize: 12,
      fontWeight: FontWeight.w600);
  static const chip = TextStyle(
      fontFamily: family, package: _pkg, fontSize: 15, color: BarqColors.ink);
  static const link = TextStyle(
      fontFamily: family,
      package: _pkg,
      fontSize: 14,
      color: BarqColors.primaryText);
  static const input = TextStyle(
      fontFamily: family, package: _pkg, fontSize: 16, color: BarqColors.ink);
  static const nav = TextStyle(fontFamily: family, package: _pkg, fontSize: 12);
  static const otp = TextStyle(
      fontFamily: family,
      package: _pkg,
      fontSize: 26,
      fontWeight: FontWeight.w600,
      color: BarqColors.ink);

  /// Struck-through "compare at" price.
  static const strike = TextStyle(
      fontFamily: family,
      package: _pkg,
      fontSize: 12,
      color: BarqColors.muted,
      decoration: TextDecoration.lineThrough);

  static TextStyle wordmark(double size, {Color color = BarqColors.primary}) =>
      TextStyle(
          fontFamily: wordmarkFamily,
          package: _pkg,
          fontSize: size,
          height: 1,
          color: color);
}

/// Light vs dark (driver) colors used by every barq_ui widget.
/// Read it with `BarqPalette.of(context)`.
@immutable
class BarqPalette extends ThemeExtension<BarqPalette> {
  const BarqPalette({
    required this.isDark,
    required this.screenGradient,
    required this.text,
    required this.textMuted,
    required this.label,
    required this.card,
    required this.cardShadow,
    required this.sheet,
    required this.chip,
    required this.chipText,
    required this.iconButton,
    required this.iconButtonIcon,
    required this.iconButtonShadow,
    required this.segment,
    required this.input,
    required this.inputBorder,
    required this.line,
    required this.progressOff,
    required this.grab,
    required this.disabledButton,
    required this.disabledButtonText,
    required this.navInactive,
    required this.navActive,
    required this.fabRing,
    required this.navBarAsset,
  });

  final bool isDark;
  final Gradient screenGradient;
  final Color text;
  final Color textMuted;
  final Color label;
  final Color card;
  final List<BoxShadow> cardShadow;
  final Color sheet;
  final Color chip;
  final Color chipText;
  final Color iconButton;
  final Color iconButtonIcon;
  final List<BoxShadow> iconButtonShadow;
  final Color segment;
  final Color input;
  final Color inputBorder;
  final Color line;
  final Color progressOff;
  final Color grab;
  final Color disabledButton;
  final Color disabledButtonText;
  final Color navInactive;
  final Color navActive;
  final Color fabRing;
  final String navBarAsset;

  static const light = BarqPalette(
    isDark: false,
    screenGradient: BarqGradients.screen,
    text: BarqColors.ink,
    textMuted: BarqColors.muted,
    label: Color(0xFF3B3B3B),
    card: BarqColors.white,
    cardShadow: BarqShadows.card,
    sheet: BarqColors.white,
    chip: BarqColors.white,
    chipText: BarqColors.ink,
    iconButton: BarqColors.white,
    iconButtonIcon: BarqColors.ink,
    iconButtonShadow: BarqShadows.iconButton,
    segment: BarqColors.segmentBg,
    input: BarqColors.white,
    inputBorder: BarqColors.border,
    line: BarqColors.divider,
    progressOff: BarqColors.divider,
    grab: BarqColors.grab,
    disabledButton: Color(0xFFEFE6E1),
    disabledButtonText: BarqColors.placeholder,
    navInactive: BarqColors.placeholder,
    navActive: BarqColors.primary,
    fabRing: Color(0xE6FFFFFF),
    navBarAsset: 'navbar',
  );

  static const dark = BarqPalette(
    isDark: true,
    screenGradient: BarqGradients.darkScreen,
    text: BarqColors.white,
    textMuted: BarqColors.darkMuted,
    label: BarqColors.darkLabel,
    card: BarqColors.darkCard,
    cardShadow: [],
    sheet: BarqColors.darkSheet,
    chip: BarqColors.darkCard,
    chipText: BarqColors.darkLabel,
    iconButton: BarqColors.darkChip,
    iconButtonIcon: BarqColors.white,
    iconButtonShadow: [],
    segment: BarqColors.darkCard,
    input: BarqColors.darkCard,
    inputBorder: BarqColors.darkLine,
    line: BarqColors.darkLine,
    progressOff: BarqColors.darkLine,
    grab: BarqColors.darkLine,
    disabledButton: BarqColors.darkLine,
    disabledButtonText: BarqColors.placeholder,
    navInactive: BarqColors.darkMuted,
    navActive: BarqColors.primaryLight,
    fabRing: Color(0xF21C1512),
    navBarAsset: 'navbar-dark',
  );

  static BarqPalette of(BuildContext context) =>
      Theme.of(context).extension<BarqPalette>() ?? BarqPalette.light;

  @override
  BarqPalette copyWith() => this;

  @override
  BarqPalette lerp(ThemeExtension<BarqPalette>? other, double t) =>
      (other is BarqPalette && t >= .5) ? other : this;
}

ThemeData _build(BarqPalette palette) {
  final brightness = palette.isDark ? Brightness.dark : Brightness.light;
  final scheme = ColorScheme.fromSeed(
          seedColor: BarqColors.primary, brightness: brightness)
      .copyWith(
    primary: BarqColors.primary,
    onPrimary: Colors.white,
    secondary: BarqColors.success,
    onSecondary: Colors.white,
    error: BarqColors.danger,
    surface: palette.card,
    onSurface: palette.text,
  );
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: 'packages/$_pkg/${BarqText.family}',
  );
  return base.copyWith(
    scaffoldBackgroundColor:
        palette.isDark ? BarqColors.darkBottom : Colors.white,
    textTheme: base.textTheme
        .apply(bodyColor: palette.text, displayColor: palette.text),
    iconTheme: IconThemeData(color: palette.text, size: BarqSizes.icon),
    dividerColor: palette.line,
    splashFactory: InkRipple.splashFactory,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: BarqColors.primary,
      selectionHandleColor: BarqColors.primary,
    ),
    extensions: [palette],
  );
}

/// Customer app theme.
ThemeData barqLightTheme() => _build(BarqPalette.light);

/// Barq Captain (driver) theme — dark screens.
ThemeData barqDarkTheme() => _build(BarqPalette.dark);
