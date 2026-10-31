import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../jobs/data/job_models.dart';
import '../../state/task_cubit.dart';

/// The steps, who to reach, the items and the one button from `next_action`.
class TaskSheet extends StatelessWidget {
  const TaskSheet({super.key, required this.job, required this.state});

  final Job job;
  final TaskState state;

  static const _shownItems = 2;
  static const _logo = 50.0;

  Future<void> _onPressed(BuildContext context, NextAction next) async {
    final cubit = context.read<TaskCubit>();
    final question = next.confirm;
    if (question != null && !await _confirmed(context, next, question)) return;
    await cubit.advance();
  }

  Future<bool> _confirmed(
    BuildContext context,
    NextAction next,
    String question,
  ) async {
    final l10n = AppLocalizations.of(context);
    final p = BarqPalette.of(context);
    final answer = await showBarqSheet<bool>(
      context,
      children: [
        Text(question, style: BarqText.h2.copyWith(color: p.text)),
        Builder(
          builder: (sheet) => BarqButton(
            label: next.label,
            onPressed: () => closeBarqSheet(sheet, true),
          ),
        ),
        Builder(
          builder: (sheet) => BarqButton(
            label: l10n.commonCancel,
            variant: BarqButtonVariant.white,
            onPressed: () => closeBarqSheet(sheet, false),
          ),
        ),
      ],
    );
    return answer ?? false;
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
        else if (next.isDeliver)
          BarqNote(l10n.taskDeliverNext)
        else ...[
          BarqButton(
            label: next.label,
            icon: BarqIcons.package,
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
