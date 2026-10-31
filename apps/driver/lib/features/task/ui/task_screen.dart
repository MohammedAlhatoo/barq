import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../jobs/data/job_models.dart';
import '../../jobs/ui/widgets/job_map.dart';
import '../state/task_cubit.dart';
import 'too_far_screen.dart';
import 'widgets/task_sheet.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  static const _sheetShare = 0.62;

  /// Where the driver is heading now.
  JobPlace _target(Job job) => job.isHeadingToStore ? job.pickup : job.dropoff;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<TaskCubit>();
    return BlocConsumer<TaskCubit, TaskState>(
      listenWhen: (previous, current) =>
          current.tooFar != null && previous.tooFar != current.tooFar,
      listener: (context, state) async {
        final retry = await context.push<bool>(
          Routes.taskTooFar,
          extra: TooFarArgs(state.job!, state.tooFar!),
        );
        if (retry ?? false) await cubit.advance();
      },
      builder: (context, state) {
        final job = state.job;
        if (job == null) {
          return BarqScreen(
            body: Column(
              children: [
                const BarqHeader(back: true),
                Expanded(
                  child: state.loading
                      ? const BarqLoadingView()
                      : state.error != null
                      ? BarqMessageView(
                          title: state.error!,
                          icon: BarqIcons.alert,
                          actionLabel: l10n.commonRetry,
                          onAction: cubit.load,
                        )
                      : BarqMessageView(
                          title: l10n.taskEmptyTitle,
                          message: l10n.taskEmptyBody,
                          icon: BarqIcons.bolt,
                          actionLabel: l10n.commonBack,
                          onAction: () => context.pop(),
                        ),
                ),
              ],
            ),
          );
        }
        final height = MediaQuery.sizeOf(context).height;
        final config = ConfigScope.of(context).config;
        final target = _target(job);
        return DesignOverlay(
          image: 'design/08_driver_jobs_05.png',
          child: BarqScreen(
            body: Stack(
              children: [
                Positioned.fill(
                  child: JobMap(job: job, bottomInset: height * _sheetShare),
                ),
                BarqHeader(
                  back: true,
                  titleWidget: BarqPill(
                    l10n.taskHeading(
                      config.status(job.statusKey).label,
                      job.isHeadingToStore
                          ? l10n.taskToStore
                          : l10n.taskToCustomer,
                    ),
                    tone: BarqPillTone.dark,
                  ),
                  trailing: target.hasLocation
                      ? BarqIconButton(
                          icon: BarqIcons.nav,
                          tooltip: l10n.taskNavigate,
                          background: BarqColors.primary,
                          iconColor: Colors.white,
                          onPressed: () => context
                              .read<AppDependencies>()
                              .deviceActions
                              .navigate(target.lat!, target.lng!),
                        )
                      : null,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: height * _sheetShare,
                    ),
                    child: SingleChildScrollView(
                      child: TaskSheet(job: job, state: state),
                    ),
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
