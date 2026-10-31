import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../foundation/barq_assets.dart';
import '../foundation/barq_theme.dart';
import '../foundation/barq_tokens.dart';

class BarqNavItem {
  const BarqNavItem({required this.icon, required this.label});

  /// A [BarqIcons] name.
  final String icon;
  final String label;
}

/// .nb — curved bottom bar with the notch + center FAB (cart in the customer
/// app, current job / power in the driver app). Exactly 4 [items]: 2 on each
/// side of the FAB (RTL order: items[0] is the right-most).
/// Put it in [BarqScreen.bottomNavigationBar] and add ~110px bottom padding to
/// scrolling content so the last item isn't hidden.
class BarqNavBar extends StatelessWidget {
  const BarqNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.fabIcon,
    this.onFab,
    this.fabBadge,
    this.fabGradient,
  }) : assert(items.length == 4);

  final List<BarqNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// A [BarqIcons] name (bag / bolt / power).
  final String fabIcon;
  final VoidCallback? onFab;

  /// Count shown on the FAB (cart items). null/0 = hidden.
  final int? fabBadge;

  /// Defaults to orange; driver "offline" uses [BarqGradients.green].
  final Gradient? fabGradient;

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    Widget item(int i) {
      final on = i == currentIndex;
      final c = on ? p.navActive : p.navInactive;
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onTap(i),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BarqIcon(items[i].icon, size: BarqSizes.icon, color: c),
              const SizedBox(height: 4),
              Text(items[i].label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: BarqText.nav.copyWith(
                      color: c,
                      fontWeight: on ? FontWeight.w600 : FontWeight.w400)),
              const SizedBox(height: 4),
              Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                      color: on ? c : Colors.transparent,
                      shape: BoxShape.circle)),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: BarqSizes.navBar + bottomInset,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Notched background (navbar.svg / navbar-dark.svg) + soft shadow.
          // drop-shadow(0 -8px 18px rgba(200,110,80,.22)) that follows the notch shape
          Positioned(
            left: 0,
            right: 0,
            top: -8,
            height: BarqSizes.navBar,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
              child: SvgPicture.asset(
                'assets/illustrations/navbar.svg',
                package: 'barq_ui',
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(
                    p.isDark
                        ? const Color(0x66000000)
                        : const Color(0x38C86E50),
                    BlendMode.srcIn),
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              children: [
                SizedBox(
                  height: BarqSizes.navBar,
                  width: double.infinity,
                  child: SvgPicture.asset(
                      'assets/illustrations/${p.navBarAsset}.svg',
                      package: 'barq_ui',
                      fit: BoxFit.fill),
                ),
                if (bottomInset > 0)
                  Expanded(
                      child: ColoredBox(
                          color:
                              p.isDark ? BarqColors.darkSheet : Colors.white)),
              ],
            ),
          ),
          Positioned(
            left: 6,
            right: 6,
            top: 6,
            height: BarqSizes.navBar - 20,
            child: Row(
              children: [
                item(0),
                item(1),
                const SizedBox(width: 100),
                item(2),
                item(3)
              ],
            ),
          ),
          Positioned(
            top: -30,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: onFab,
                child: Container(
                  width: BarqSizes.fab,
                  height: BarqSizes.fab,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: fabGradient ?? BarqGradients.orange,
                    boxShadow: [
                      BoxShadow(color: p.fabRing, spreadRadius: 6),
                      BoxShadow(
                          color: p.isDark
                              ? const Color(0xB3FF7A21)
                              : const Color(0xE6FF7A21),
                          offset: const Offset(0, 14),
                          blurRadius: 24,
                          spreadRadius: -8),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      BarqIcon(fabIcon,
                          size: BarqSizes.iconL, color: Colors.white),
                      if ((fabBadge ?? 0) > 0)
                        PositionedDirectional(
                          top: -2,
                          start: -2,
                          child: Container(
                            constraints: const BoxConstraints(minWidth: 22),
                            height: 22,
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: BarqColors.ink,
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Text('$fabBadge',
                                style: BarqText.pill
                                    .copyWith(color: Colors.white)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
