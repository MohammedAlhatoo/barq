import 'package:flutter/material.dart';

import '../foundation/barq_assets.dart';
import '../foundation/barq_theme.dart';
import '../foundation/barq_tokens.dart';
import 'buttons.dart';
import 'indicators.dart';
import 'layout.dart';
import 'misc.dart';
import 'surfaces.dart';

/// The orange card on the account screen: avatar, name, phone, edit button and
/// up to three numbers. [stats] is (value, label) pairs.
class BarqProfileCard extends StatelessWidget {
  const BarqProfileCard({
    super.key,
    required this.initial,
    required this.name,
    required this.phone,
    this.imageUrl,
    this.onEdit,
    this.stats = const [],
  });

  final String initial;
  final String name;
  final String phone;
  final String? imageUrl;
  final VoidCallback? onEdit;
  final List<({String value, String label})> stats;

  @override
  Widget build(BuildContext context) => BarqBanner(
        radius: BarqRadius.profileCard,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const PositionedDirectional(
              top: -88,
              end: -68,
              child: BarqBlob(size: 180, color: BarqColors.onOrangeTint),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    BarqAvatar(initial,
                        size: BarqSizes.profileAvatar,
                        light: true,
                        imageUrl: imageUrl),
                    const SizedBox(width: BarqSpacing.gap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: BarqText.h2.copyWith(color: Colors.white)),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(phone,
                                style: BarqText.t
                                    .copyWith(color: BarqColors.onOrangeMuted)),
                          ),
                        ],
                      ),
                    ),
                    BarqIconButton(
                        icon: 'edit', glass: true, onPressed: onEdit),
                  ],
                ),
                if (stats.isNotEmpty) ...[
                  const SizedBox(height: BarqSpacing.section),
                  Row(
                    children: [
                      for (var i = 0; i < stats.length; i++) ...[
                        if (i > 0) const SizedBox(width: BarqSpacing.sm),
                        Expanded(child: _Stat(stats[i])),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      );
}

class _Stat extends StatelessWidget {
  const _Stat(this.stat);

  final ({String value, String label}) stat;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(BarqSpacing.md),
        decoration: BoxDecoration(
          color: BarqColors.onOrangePanel,
          borderRadius: BorderRadius.circular(BarqRadius.profileStat),
        ),
        child: Column(
          children: [
            Text(stat.value, style: BarqText.h2.copyWith(color: Colors.white)),
            Text(stat.label,
                style: BarqText.xs.copyWith(color: BarqColors.onOrangeMuted)),
          ],
        ),
      );
}

/// One saved address. [selected] is the orange default card of the design.
class BarqAddressCard extends StatelessWidget {
  const BarqAddressCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.badge,
    this.selected = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.trailing,
  });

  /// A [BarqIcons] name.
  final String icon;
  final String title;
  final String? subtitle;

  /// Pill next to the title ("الافتراضي").
  final String? badge;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  /// Replaces the edit and delete buttons (the radio in the picker).
  final Widget? trailing;

  Widget _action(String name, VoidCallback onPressed, String tooltip) =>
      BarqIconButton(
        icon: name,
        size: BarqSizes.addressAction,
        background: BarqColors.addressAction,
        onPressed: onPressed,
        tooltip: tooltip,
      );

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    final text = subtitle;
    final label = badge;
    final edit = onEdit;
    final delete = onDelete;
    return BarqCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
          horizontal: BarqSpacing.section, vertical: 14),
      borderColor: selected ? BarqColors.primary : null,
      child: Row(
        children: [
          BarqIconTile(icon,
              tone: selected ? BarqTileTone.darkOrange : BarqTileTone.neutral),
          const SizedBox(width: BarqSpacing.gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: BarqText.h3.copyWith(color: p.text)),
                    ),
                    if (label != null) ...[
                      const SizedBox(width: BarqSpacing.sm),
                      BarqPill(label, tone: BarqPillTone.orange),
                    ],
                  ],
                ),
                if (text != null && text.isNotEmpty)
                  Text(text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: BarqText.xs.copyWith(color: p.textMuted)),
              ],
            ),
          ),
          const SizedBox(width: BarqSpacing.sm),
          if (trailing != null)
            trailing!
          else ...[
            if (edit != null) _action('edit', edit, 'تعديل'),
            if (delete != null) ...[
              const SizedBox(width: BarqSpacing.xs),
              _action('trash', delete, 'حذف'),
            ],
          ],
        ],
      ),
    );
  }
}

/// The picture of the delete account screen (06_account_03).
class BarqDeleteAccountArt extends StatelessWidget {
  const BarqDeleteAccountArt({super.key});

  @override
  Widget build(BuildContext context) => const BarqIllustrationArea(
        height: BarqSizes.deleteAccountArt,
        blobSize: BarqSizes.deleteAccountBlob,
        blobGradient: BarqBlob.red,
        child: BarqIconCard(
          icon: 'trash',
          size: BarqSizes.deleteAccountIcon,
          radius: 36,
          angle: -6,
          iconColor: BarqColors.danger,
        ),
      );
}

/// The pin in the middle of the address map with the hint above it. The point
/// the user picks is the map's center, so this widget never moves.
class BarqMapCenterPin extends StatelessWidget {
  const BarqMapCenterPin({super.key, required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        // The keyboard can make the map shorter than the pin; the map clips it.
        child: OverflowBox(
          maxHeight: double.infinity,
          // The tip of the pin sits on the center, so the column ends there.
          child: FractionalTranslation(
            translation: const Offset(0, -.5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BarqPill(hint, tone: BarqPillTone.dark),
                const BarqIllustration('pin3d',
                    width: BarqSizes.addressMapPin,
                    height: BarqSizes.addressMapPin),
              ],
            ),
          ),
        ),
      );
}
