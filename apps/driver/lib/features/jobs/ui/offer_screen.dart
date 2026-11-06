import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../data/job_models.dart';
import '../state/offer_cubit.dart';
import 'widgets/job_map.dart';

/// "طلب جديد". The API gives no time limit for an offer, so the design's
/// countdown ring is hidden.
class OfferScreen extends StatelessWidget {
  const OfferScreen({super.key});

  static const _sheetHeight = 430.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<OfferCubit>();
    return BlocConsumer<OfferCubit, OfferState>(
      listenWhen: (previous, current) => current.result != null,
      listener: (context, state) => context.pop(state.result),
      builder: (context, state) {
        final job = state.job;
        if (job == null) {
          return BarqScreen(
            body: Column(
              children: [
                const BarqHeader(back: true),
                Expanded(
                  child: state.loading
                      ? const BarqMapSheetSkeleton(
                          children: [
                            BarqTileRowSkeleton(
                              card: false,
                              padding: EdgeInsets.zero,
                              trailing: BarqTextBone(BarqText.h2, width: 56),
                            ),
                            BarqSummaryCardSkeleton(rows: 2),
                            BarqButtonSkeleton(),
                          ],
                        )
                      : BarqMessageView(
                          title: state.error ?? '',
                          icon: BarqIcons.alert,
                          actionLabel: l10n.commonRetry,
                          onAction: cubit.load,
                        ),
                ),
              ],
            ),
          );
        }
        return DesignOverlay(
          image: 'design/08_driver_jobs_04.png',
          child: BarqScreen(
            body: Stack(
              children: [
                Positioned.fill(
                  child: JobMap(job: job, bottomInset: _sheetHeight),
                ),
                BarqHeader(
                  back: true,
                  titleWidget: BarqPill(
                    l10n.offerTitle,
                    icon: BarqIcons.bell,
                    tone: BarqPillTone.orangeSolid,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SingleChildScrollView(
                    child: _OfferSheet(job: job, state: state),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OfferSheet extends StatelessWidget {
  const _OfferSheet({required this.job, required this.state});

  final Job job;
  final OfferState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = BarqPalette.of(context);
    final cubit = context.read<OfferCubit>();
    final toStore = job.distanceToPickupKm;
    final toHome = job.distanceKm;
    return BarqSheet(
      showGrab: false,
      gap: 14,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.jobYourFare,
              style: BarqText.xs.copyWith(color: p.textMuted),
            ),
            Text(
              job.earning.formatted,
              style: BarqText.h0.copyWith(color: BarqColors.primaryLight),
            ),
          ],
        ),
        BarqCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Column(
            children: [
              _StopRow(
                icon: BarqIcons.store,
                title: job.storeName,
                subtitle: toStore == null
                    ? l10n.offerPickup
                    : l10n.offerPickupDistance(toStore.toString()),
              ),
              const BarqDivider(dashed: true),
              _StopRow(
                icon: BarqIcons.home,
                solid: true,
                title: job.dropoff.label ?? '',
                subtitle: toHome == null
                    ? l10n.offerDropoff
                    : l10n.offerDropoffDistance(toHome.toString()),
              ),
            ],
          ),
        ),
        BarqSummaryRow(
          l10n.offerCollect,
          l10n.offerCash(job.collect.formatted),
        ),
        if (state.notice != null)
          BarqNote(state.notice!, tone: BarqNoteTone.danger),
        BarqButton(
          label: l10n.offerAccept,
          loading: state.busy,
          onPressed: cubit.accept,
        ),
        BarqButton(
          label: l10n.offerIgnore,
          variant: BarqButtonVariant.white,
          onPressed: state.busy ? null : cubit.ignore,
        ),
      ],
    );
  }
}

class _StopRow extends StatelessWidget {
  const _StopRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.solid = false,
  });

  final String icon;
  final String title;
  final String subtitle;

  /// The orange tile of the home, against the white tile of the store.
  final bool solid;

  static const _tile = 36.0;

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: BarqSpacing.md),
      child: Row(
        children: [
          BarqIconTile(
            icon,
            size: _tile,
            tone: solid ? BarqTileTone.darkOrange : BarqTileTone.orange,
          ),
          const SizedBox(width: BarqSpacing.gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: BarqText.h3.copyWith(color: p.text),
                ),
                Text(subtitle, style: BarqText.xs.copyWith(color: p.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
