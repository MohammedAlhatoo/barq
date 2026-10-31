import 'package:flutter/material.dart';

import '../foundation/barq_theme.dart';
import '../foundation/barq_tokens.dart';
import 'misc.dart';
import 'surfaces.dart';

/// (icon, text, iconColor?) triples, as [BarqMetaRow] takes them.
typedef BarqVendorMeta = List<({String icon, String text, Color? iconColor})>;

/// Store card for a horizontal list: logo, name and details.
class BarqVendorCard extends StatelessWidget {
  const BarqVendorCard({
    super.key,
    required this.logo,
    required this.name,
    required this.meta,
    this.onTap,
  });

  /// Usually a [BarqNetworkImage].
  final Widget logo;
  final String name;
  final BarqVendorMeta meta;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => BarqCard(
        padding: const EdgeInsets.all(BarqSpacing.gap),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox.square(dimension: BarqSizes.storeLogo, child: logo),
                const SizedBox(width: BarqSpacing.sm),
                Expanded(
                  child: Text(name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: BarqText.h3
                          .copyWith(color: BarqPalette.of(context).text)),
                ),
              ],
            ),
            const SizedBox(height: BarqSpacing.sm),
            BarqMetaRow(items: meta),
          ],
        ),
      );
}

/// Store row for a vertical list: logo, name, [subtitle], details, and a
/// [trailing] widget such as the open/closed pill.
class BarqVendorRow extends StatelessWidget {
  const BarqVendorRow({
    super.key,
    required this.logo,
    required this.name,
    required this.meta,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  /// Usually a [BarqNetworkImage].
  final Widget logo;
  final String name;
  final String? subtitle;
  final BarqVendorMeta meta;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    return BarqCard(
      padding: const EdgeInsets.all(BarqSpacing.gap),
      onTap: onTap,
      child: Row(
        children: [
          SizedBox.square(dimension: BarqSizes.vendorRowLogo, child: logo),
          const SizedBox(width: BarqSpacing.gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: BarqText.h3.copyWith(color: p.text)),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: BarqSpacing.sm),
                      trailing!
                    ],
                  ],
                ),
                if (subtitle != null)
                  Text(subtitle!,
                      style: BarqText.xs.copyWith(color: p.textMuted)),
                const SizedBox(height: BarqSpacing.xs),
                BarqMetaRow(items: meta),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
