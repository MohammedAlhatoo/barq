// Design tokens copied 1:1 from the design CSS (docs/design/html/assets/barq.css).
// Never hard-code a color/size in a screen — use these (or a widget that uses them).
import 'package:flutter/material.dart';

/// Raw colors. Prefer [BarqPalette.of] inside widgets so light/dark both work.
abstract final class BarqColors {
  // Brand
  static const primary = Color(0xFFFF7A21);
  static const primaryLight = Color(0xFFFF9A4A);
  static const primaryDeep = Color(0xFFF2600C);
  static const primaryText = Color(0xFFC9520A); // .or-t, .lnk
  static const primarySoft = Color(0xFFFFEDE2); // .pill.or / .btn.lt bg
  static const primarySoftText = Color(0xFFB34A08);
  static const primaryTint = Color(0xFFFFF0E6); // .ti bg
  static const primaryTint2 = Color(0xFFFFF3EB); // info rows

  // Neutrals
  static const ink = Color(0xFF151515);
  static const muted = Color(0xFF6F6F6F);
  static const placeholder = Color(0xFF8A7F79);
  static const white = Color(0xFFFFFFFF);
  static const onDarkMuted = Color(0xFFCFC5C0); // small text on black cards
  static const chipMuted = Color(0xFFF3ECE8); // .ti.k / .qb
  static const segmentBg = Color(0xFFF7F0EC);
  static const border = Color(0xFFF1DFD5); // .inp / .ob
  static const qtyBorder = Color(0xFFEEDDD4);
  static const divider = Color(0xFFF1E4DC); // .hr
  static const listDivider = Color(0xFFF3E7E0); // .li
  static const radioOff = Color(0xFFDCCFC8);
  static const grab = Color(0xFFE8DAD2);
  static const toggleOff = Color(0xFFE3D7D0);
  static const mapBg = Color(0xFFF4EEE8);
  static const dotRed = Color(0xFFFF4D2E);

  // Semantic
  static const success = Color(0xFF1E9E55);
  static const successText = Color(0xFF17803F);
  static const successSoft = Color(0xFFE2F6EA);
  static const danger = Color(0xFFC0291A);
  static const dangerSoft = Color(0xFFFFE6E1);
  static const warningSoft = Color(0xFFFFF4CC);
  static const warningText = Color(0xFF8A5A00);
  static const warningTextDark = Color(0xFF6B4A00);
  static const star = Color(0xFFFFB020);
  static const starOff = Color(0xFFEADFD8);

  // Driver (dark) surfaces
  static const darkTop = Color(0xFF2A201B);
  static const darkBottom = Color(0xFF171210);
  static const darkSheet = Color(0xFF1C1512);
  static const darkCard = Color(0xFF241B17);
  static const darkChip = Color(0xFF2B221E);
  static const darkLine = Color(0xFF3A2E28);
  static const darkMuted = Color(0xFF9C8F88);
  static const darkSubtle = Color(0xFFB8ABA4);
  static const darkLabel = Color(0xFFD9CEC8);
  static const darkSuccessSoft = Color(0xFF123A24);
  static const darkSuccessText = Color(0xFF6EE09C);
  static const cashYellow = Color(0xFFFFC94D);
  static const cashYellowDeep = Color(0xFFFFAA1A);
}

/// Product tile backgrounds (.bg-pink, .bg-yel …).
enum BarqTileColor {
  pink(Color(0xFFFFE6E1), Color(0xFFFFD2C9)),
  yellow(Color(0xFFFCF6DA), Color(0xFFF6E9AE)),
  mint(Color(0xFFE6F8EA), Color(0xFFC9EFD3)),
  lavender(Color(0xFFF1EBFF), Color(0xFFDED2FF)),
  peach(Color(0xFFFFEEDF), Color(0xFFFFD5B5)),
  sky(Color(0xFFE4F4FC), Color(0xFFC8E8F6)),
  cream(Color(0xFFFFF4EC), Color(0xFFFFF4EC));

  const BarqTileColor(this.top, this.bottom);
  final Color top;
  final Color bottom;

  Gradient get gradient => LinearGradient(
        begin: const Alignment(-0.36, -1),
        end: const Alignment(0.36, 1),
        colors: [top, bottom],
      );
}

abstract final class BarqGradients {
  /// Light screen background (.ph)
  static const screen = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFE7DF),
      Color(0xFFFFF5F0),
      Color(0xFFFFFFFF),
      Color(0xFFFFF8F4)
    ],
    stops: [0, .34, .70, 1],
  );

  /// Driver dark screen background (.ph.dk)
  static const darkScreen = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [BarqColors.darkTop, BarqColors.darkBottom],
  );

  /// Full orange screen (.ph.or) — splash / forced update.
  static const orangeScreen = LinearGradient(
    begin: Alignment(-0.34, -1),
    end: Alignment(0.34, 1),
    colors: [
      BarqColors.primaryLight,
      BarqColors.primary,
      BarqColors.primaryDeep
    ],
    stops: [0, .55, 1],
  );

  /// Orange hero (avatar, FAB, banners, active nav circle) — CSS 150deg.
  static const orange = LinearGradient(
    begin: Alignment(-0.58, -1),
    end: Alignment(0.58, 1),
    colors: [BarqColors.primaryLight, BarqColors.primaryDeep],
  );

  /// Green hero (driver "go online", success badges).
  static const green = LinearGradient(
    begin: Alignment(-0.58, -1),
    end: Alignment(0.58, 1),
    colors: [Color(0xFF3CC35C), Color(0xFF1E9A3E)],
  );

  /// Yellow cash banner (driver).
  static const cash = LinearGradient(
    begin: Alignment(-0.58, -1),
    end: Alignment(0.58, 1),
    colors: [BarqColors.cashYellow, BarqColors.cashYellowDeep],
  );

  /// Soft orange blob behind illustrations (.blob).
  static const blob = RadialGradient(
    center: Alignment(-0.3, -0.4),
    colors: [Color(0xFFFFD9C4), Color(0xFFFFC2A0), Color(0xFFFFAF85)],
    stops: [0, .6, 1],
  );
}

abstract final class BarqRadius {
  static const card = 24.0;
  static const productTile = 28.0;
  static const productGlass = 22.0;
  static const input = 20.0;
  static const otp = 20.0;
  static const iconTile = 16.0;
  static const sheet = 34.0;
  static const phone = 48.0;
  static const pill = 999.0;
}

abstract final class BarqSpacing {
  /// Horizontal page padding (.pad / .top)
  static const page = 22.0;

  /// Top padding of screen headers (.top) — includes the status bar area.
  static const headerTop = 52.0;
  static const gap = 12.0; // .row / .stk default gap
  static const section = 16.0;
  static const xxs = 4.0;
  static const xs = 6.0;
  static const sm = 8.0;
  static const md = 10.0;
  static const lg = 26.0;

  /// Space under the last button: forms (34) and state screens (30).
  static const formBottom = 34.0;
  static const stateBottom = 30.0;

  /// Bottom padding of lists, so nothing hides behind what floats over them.
  static const navClearance = 130.0;
  static const cartBarClearance = 110.0;
  static const cartSheetClearance = 230.0;
}

abstract final class BarqSizes {
  static const button = 58.0;
  static const buttonSmall = 46.0;
  static const input = 58.0;
  static const search = 52.0;
  static const chip = 44.0;
  static const iconButton = 48.0; // .icb
  static const iconTile = 46.0; // .ti
  static const plus = 44.0;
  static const plusSmall = 36.0;
  static const qtyButton = 32.0;
  static const navBar = 96.0;
  static const fab = 66.0;
  static const mapPin = 52.0;
  static const otpWidth = 62.0;
  static const otpHeight = 66.0;

  // Illustration areas of the login flow (height · blob · image).
  static const onboardingArt = 450.0;
  static const onboardingBlob = 330.0;
  static const onboardingImage = 330.0;
  static const onboardingPillTop = 70.0;
  static const onboardingBlobTop = 50.0;
  static const onboardingImageTop = 40.0;
  static const onboardingScooterWidth = 360.0;
  static const onboardingScooterHeight = 300.0;
  static const compareImage = 46.0;
  static const phoneArt = 230.0;
  static const phoneBlob = 190.0;
  static const phoneImage = 200.0;
  static const otpArt = 210.0;
  static const wordmarkHeader = 40.0;
  static const welcomeMap = 120.0;
  static const welcomePin = 64.0;

  // Browse and cart.
  static const productTile = 186.0;
  static const productHero = 220.0;
  static const storeHero = 250.0;
  static const storeHeroCardTop = 210.0; // the card overlaps the hero by 40
  static const storeHeroBlob = 200.0;
  static const optionChip = 38.0;
  static const rowThumb = 74.0;
  static const cartThumb = 52.0;
  static const storeLogo = 46.0;
  static const compareBasket = 62.0;
  static const cartBarIcon = 40.0;
  static const compareArrow = 38.0;
  static const homeProductTile = 160.0;
  static const homeVendorCard = 200.0;
  static const homeVendorCardHeight = 156.0;
  static const vendorRowLogo = 62.0;

  // Icon sizes (.i.s / .i / .i.m / .i.l / .i.xl)
  static const iconS = 16.0;
  static const iconM = 19.0;
  static const icon = 22.0;
  static const iconL = 28.0;
  static const iconXL = 40.0;
}

abstract final class BarqShadows {
  // .card  0 12px 28px -16px rgba(200,110,80,.45)
  static const card = [
    BoxShadow(
        color: Color(0x73C86E50),
        offset: Offset(0, 12),
        blurRadius: 28,
        spreadRadius: -16)
  ];
  // .icb   0 8px 18px -8px rgba(200,110,80,.45)
  static const iconButton = [
    BoxShadow(
        color: Color(0x73C86E50),
        offset: Offset(0, 8),
        blurRadius: 18,
        spreadRadius: -8)
  ];
  // .chip  0 6px 14px -8px rgba(200,110,80,.4)
  static const chip = [
    BoxShadow(
        color: Color(0x66C86E50),
        offset: Offset(0, 6),
        blurRadius: 14,
        spreadRadius: -8)
  ];
  // .chip.on 0 10px 20px -8px rgba(255,122,33,.7)
  static const chipOn = [
    BoxShadow(
        color: Color(0xB3FF7A21),
        offset: Offset(0, 10),
        blurRadius: 20,
        spreadRadius: -8)
  ];
  // .search / .btn.w  0 8px 18px -10px rgba(200,110,80,.4/.45)
  static const soft = [
    BoxShadow(
        color: Color(0x6BC86E50),
        offset: Offset(0, 8),
        blurRadius: 18,
        spreadRadius: -10)
  ];
  // .btn   0 14px 26px -12px rgba(255,122,33,.85)
  static const primaryButton = [
    BoxShadow(
        color: Color(0xD9FF7A21),
        offset: Offset(0, 14),
        blurRadius: 26,
        spreadRadius: -12)
  ];
  static const darkButton = [
    BoxShadow(
        color: Color(0x99000000),
        offset: Offset(0, 14),
        blurRadius: 26,
        spreadRadius: -12)
  ];
  static const greenButton = [
    BoxShadow(
        color: Color(0xCC1E9E55),
        offset: Offset(0, 14),
        blurRadius: 26,
        spreadRadius: -12)
  ];
  // السلة الأوفر card 0 20px 34px -18px rgba(30,158,85,.6)
  static const greenCard = [
    BoxShadow(
        color: Color(0x991E9E55),
        offset: Offset(0, 20),
        blurRadius: 34,
        spreadRadius: -18)
  ];
  static const redButton = [
    BoxShadow(
        color: Color(0xB3C0291A),
        offset: Offset(0, 14),
        blurRadius: 26,
        spreadRadius: -12)
  ];
  // .plus 0 10px 18px -8px rgba(255,122,33,.9)
  static const plus = [
    BoxShadow(
        color: Color(0xE6FF7A21),
        offset: Offset(0, 10),
        blurRadius: 18,
        spreadRadius: -8)
  ];
  // .inp.f focus ring 0 0 0 4px rgba(255,122,33,.14)
  static const focusRing = [
    BoxShadow(color: Color(0x24FF7A21), spreadRadius: 4)
  ];
  // .nb drop-shadow 0 -8px 18px rgba(200,110,80,.22)
  static const navBar = [
    BoxShadow(color: Color(0x38C86E50), offset: Offset(0, -8), blurRadius: 18)
  ];
  // sheets
  static const sheet = [
    BoxShadow(
        color: Color(0x80C86E50),
        offset: Offset(0, -12),
        blurRadius: 30,
        spreadRadius: -16)
  ];
}

abstract final class BarqDurations {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
}
