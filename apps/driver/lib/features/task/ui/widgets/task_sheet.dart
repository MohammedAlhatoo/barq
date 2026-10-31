import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../app/router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../jobs/data/job_models.dart';
import '../../state/task_cubit.dart';
import 'confirm_step.dart';

/// The steps, who to reach, the items and the one button from `next_action`.
class TaskSheet extends StatelessWidget {
  const TaskSheet({super.key, required this.job, required this.state});

  final Job job;
  final TaskState state;

  static const _shownItems = 2;
  static const _logo = 50.0;

  Future<void> _onPressed(BuildContext context, NextAction next) async {
    final cubit = context.read<TaskCubit>();
    if (next.isDeliver) {
      final delivered = await context.push<bool>(
        Routes.taskDeliver,
        extra: job,
      );
      if (!context.mounted) return;
      if (delivered ?? false) {
        context.pop();
      } else {
        await cubit.load();
      }
    } else if (next.needsPhoto) {
      await context.push(Routes.taskPhoto, extra: job);
      await cubit.load();
    } else if (await confirmStep(context, next)) {
      await cubit.advance();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = BarqPalette.of(context);
    final next = job.nextAction;
    final atStore = job.isHeadingToStore;
    final name = atStore
        ? job.storeName
        : job.customerName ?? job.dropoff.label ?? '';
    final place = atStore ? job.pickup : job.dropoff;
    final distance = atStore ? job.distanceToPickupKm : null;
    final phone = atStore ? job.vendorPhone : job.customerPhone;
    final subtitle = [
      ?place.details,
      if (distance != null) l10n.distanceKm(distance.toString()),
    ].join(' · ');
    final hidden = job.items.length - _shownItems;
    return BarqSheet(
      gap: BarqSpacing.gap,
      children: [
        OrderStatusProgress(
          keys: OrderTimelines.tracking,
          current: next?.to ?? job.statusKey,
          showLabels: true,
        ),
        Row(
          children: [
            BarqThumb(
              size: _logo,
              radius: BarqRadius.iconTile,
              image: const BarqIllustration(BarqIllustrations.storefront),
            ),
            const SizedBox(width: BarqSpacing.gap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: BarqText.h2.copyWith(color: p.text),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: BarqText.xs.copyWith(color: p.textMuted),
                    ),
                ],
              ),
            ),
            if (phone != null)
              BarqIconButton(
                icon: BarqIcons.phone,
                flat: true,
                tooltip: l10n.taskCall,
                onPressed: () =>
                    context.read<AppDependencies>().deviceActions.call(phone),
              ),
          ],
        ),
        if (job.items.isNotEmpty)
          BarqCard(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: BarqSpacing.md,
            ),
            child: BarqGap(
              gap: BarqSpacing.sm,
              children: [
                for (final item in job.items.take(_shownItems))
                  Text(
                    l10n.taskItem(item.name, item.qty),
                    style: BarqText.t.copyWith(color: p.text),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      hidden > 0 ? l10n.taskMoreItems(hidden) : '',
                      style: BarqText.t.copyWith(color: p.textMuted),
                    ),
                    Text(
                      '#${job.code}',
                      textDirection: TextDirection.ltr,
                      style: BarqText.xs.copyWith(color: p.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        if (state.notice != null)
          BarqNote(
            state.notice!,
            icon: BarqIcons.alert,
            tone: BarqNoteTone.danger,
          ),
        if (next == null)
          BarqNote(l10n.taskNoStep)
        else ...[
          BarqButton(
            label: next.label,
            icon: next.isDeliver ? BarqIcons.check : BarqIcons.package,
            variant: next.isDeliver
                ? BarqButtonVariant.green
                : BarqButtonVariant.primary,
            loading: state.submitting,
            onPressed: () => _onPressed(context, next),
          ),
          if (next.needsPhoto)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BarqIcon(
                  BarqIcons.camera,
                  size: BarqSizes.iconS,
                  color: p.textMuted,
                ),
                const SizedBox(width: BarqSpacing.xs),
                Flexible(
                  child: Text(
                    l10n.taskPhotoHint,
                    style: BarqText.xs.copyWith(color: p.textMuted),
                  ),
                ),
              ],
            ),
        ],
      ],
    );
  }
}
