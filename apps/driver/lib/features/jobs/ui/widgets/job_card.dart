import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../data/job_models.dart';

/// One nearby order. A tap opens its details; the button accepts it at once.
class JobCard extends StatelessWidget {
  const JobCard({
    super.key,
    required this.job,
    required this.onOpen,
    required this.onAccept,
    this.accepting = false,
  });

  final Job job;
  final VoidCallback onOpen;
  final VoidCallback? onAccept;
  final bool accepting;

  static const _buttonWidth = 120.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = BarqPalette.of(context);
    final details = [
      if (job.dropoff.label != null) l10n.jobTo(job.dropoff.label!),
      if (job.distanceKm != null) l10n.distanceKm(job.distanceKm!.toString()),
      if (job.itemsCount != null) l10n.jobItems(job.itemsCount!),
    ].join(' · ');
    return BarqCard(
      onTap: onOpen,
      padding: const EdgeInsets.all(14),
      child: BarqGap(
        gap: BarqSpacing.md,
        children: [
          Row(
            children: [
              const BarqIconTile(BarqIcons.store, tone: BarqTileTone.orange),
              const SizedBox(width: BarqSpacing.gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.storeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: BarqText.h3.copyWith(color: p.text),
                    ),
                    Text(
                      details,
                      style: BarqText.xs.copyWith(color: p.textMuted),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    job.earning.formatted,
                    style: BarqText.h2.copyWith(color: BarqColors.primaryLight),
                  ),
                  Text(
                    l10n.jobYourFare,
                    style: BarqText.xs.copyWith(color: p.textMuted),
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: BarqPill(
                  l10n.jobCollect(job.collect.formatted),
                  icon: BarqIcons.cash,
                ),
              ),
              SizedBox(
                width: _buttonWidth,
                child: BarqButton(
                  label: l10n.jobAccept,
                  small: true,
                  loading: accepting,
                  onPressed: onAccept,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
