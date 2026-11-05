import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../profile/data/driver_models.dart';
import '../../profile/state/driver_cubit.dart';
import '../data/job_models.dart';
import '../data/location_source.dart';
import '../state/jobs_cubit.dart';
import '../state/offer_cubit.dart';
import 'widgets/job_card.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  void _onAcceptResult(BuildContext context, AcceptResult result) {
    final path = result == AcceptResult.accepted
        ? Routes.task
        : Routes.cashLimit;
    context.push(path);
  }

  @override
  Widget build(BuildContext context) => MultiBlocListener(
    listeners: [
      BlocListener<DriverCubit, DriverState>(
        listenWhen: (previous, current) =>
            previous.isOnline != current.isOnline ||
            previous.loading != current.loading,
        listener: (context, state) {
          if (!state.loading) {
            context.read<JobsCubit>().setOnline(state.isOnline);
          }
        },
      ),
      BlocListener<JobsCubit, JobsState>(
        listenWhen: (previous, current) =>
            previous.result != current.result && current.result != null,
        listener: (context, state) => _onAcceptResult(context, state.result!),
      ),
    ],
    child: BlocBuilder<DriverCubit, DriverState>(
      builder: (context, driverState) {
        final driver = driverState.driver;
        if (driver == null) {
          return _DriverStatus(state: driverState);
        }
        return driverState.isOnline
            ? DesignOverlay(
                image: 'design/08_driver_jobs_02.png',
                child: _OnlineView(driver: driver, state: driverState),
              )
            : DesignOverlay(
                image: 'design/08_driver_jobs_03.png',
                child: _OfflineView(driver: driver, state: driverState),
              );
      },
    ),
  );
}

/// Before the profile arrives.
class _DriverStatus extends StatelessWidget {
  const _DriverStatus({required this.state});

  final DriverState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final error = state.error;
    if (error == null) return const BarqLoadingView();
    return BarqMessageView(
      title: error,
      icon: BarqIcons.alert,
      actionLabel: l10n.commonRetry,
      onAction: context.read<DriverCubit>().load,
    );
  }
}

/// Why the switch did not change. Shared by both views.
class _SwitchNote extends StatelessWidget {
  const _SwitchNote({required this.state});

  final DriverState state;

  String? _message(AppLocalizations l10n) => switch (state.locationProblem) {
    LocationProblem.denied => l10n.locationDenied,
    LocationProblem.serviceOff => l10n.locationServiceOff,
    LocationProblem.unavailable => l10n.locationUnavailable,
    null => state.switchError,
  };

  @override
  Widget build(BuildContext context) {
    final message = _message(AppLocalizations.of(context));
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        BarqSpacing.page,
        BarqSpacing.gap,
        BarqSpacing.page,
        0,
      ),
      child: BarqNote(
        message,
        icon: BarqIcons.alert,
        tone: BarqNoteTone.danger,
      ),
    );
  }
}

class _OnlineSwitch extends StatelessWidget {
  const _OnlineSwitch({required this.state});

  final DriverState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BarqOnlineSwitch(
      online: state.isOnline,
      label: state.isOnline ? l10n.statusOnline : l10n.statusOffline,
      busy: state.switching,
      onChanged: context.read<DriverCubit>().setOnline,
    );
  }
}

class _OnlineView extends StatelessWidget {
  const _OnlineView({required this.driver, required this.state});

  final Driver driver;
  final DriverState state;

  String _greeting(AppLocalizations l10n) =>
      DateTime.now().hour < 12 ? l10n.greetingMorning : l10n.greetingEvening;

  Future<void> _open(BuildContext context, Job job) async {
    final jobs = context.read<JobsCubit>();
    final result = await context.push<OfferResult>(Routes.offerOf(job.id));
    if (!context.mounted) return;
    switch (result) {
      case OfferResult.accepted:
        await context.push(Routes.task);
      case OfferResult.cashLimit:
        await context.push(Routes.cashLimit);
      case OfferResult.taken:
        jobs.showTaken();
      case OfferResult.ignored:
      case null:
        break;
    }
    await jobs.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = BarqPalette.of(context);
    final cubit = context.read<JobsCubit>();
    return BlocBuilder<JobsCubit, JobsState>(
      builder: (context, jobs) {
        final today = jobs.today;
        return RefreshIndicator(
          onRefresh: cubit.load,
          child: ListView(
            padding: const EdgeInsets.only(bottom: BarqSpacing.navClearance),
            children: [
              BarqHeader(
                large: true,
                titleWidget: Row(
                  children: [
                    BarqAvatar(driver.initial, imageUrl: driver.avatarUrl),
                    const SizedBox(width: BarqSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(l10n),
                            style: BarqText.xs.copyWith(color: p.textMuted),
                          ),
                          Text(
                            driver.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: BarqText.h3.copyWith(color: p.text),
                          ),
                        ],
                      ),
                    ),
                    _OnlineSwitch(state: state),
                  ],
                ),
                bottom: BarqBanner(
                  radius: BarqRadius.card,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: BarqSpacing.section,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.jobsTodayEarnings,
                              style: BarqText.xs.copyWith(
                                color: BarqColors.onOrangeMuted,
                              ),
                            ),
                            Text(
                              today?.earnings.formatted ?? '',
                              style: BarqText.h0.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      BarqBannerStat(
                        value: '${today?.orders ?? ''}',
                        label: l10n.jobsOrdersStat,
                      ),
                      const SizedBox(width: BarqSpacing.gap),
                      BarqBannerStat(
                        value: driver.ratingAverage.toString(),
                        label: l10n.jobsRatingStat,
                      ),
                    ],
                  ),
                ),
              ),
              _SwitchNote(state: state),
              if (jobs.taken)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    BarqSpacing.page,
                    BarqSpacing.gap,
                    BarqSpacing.page,
                    0,
                  ),
                  child: BarqNote(
                    l10n.jobsTaken,
                    tone: BarqNoteTone.danger,
                    onClose: cubit.clearNotice,
                  ),
                ),
              if (jobs.notice != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    BarqSpacing.page,
                    BarqSpacing.gap,
                    BarqSpacing.page,
                    0,
                  ),
                  child: BarqNote(
                    jobs.notice!,
                    tone: BarqNoteTone.danger,
                    onClose: cubit.clearNotice,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  BarqSpacing.page,
                  18,
                  BarqSpacing.page,
                  BarqSpacing.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        l10n.jobsNearby(jobs.jobs.length),
                        style: BarqText.h2.copyWith(color: p.text),
                      ),
                    ),
                    Text(
                      l10n.jobsAutoRefresh,
                      style: BarqText.xs.copyWith(color: p.textMuted),
                    ),
                  ],
                ),
              ),
              if (jobs.loading)
                const BarqLoadingView()
              else if (jobs.error != null)
                BarqMessageView(
                  title: jobs.error!,
                  icon: BarqIcons.alert,
                  actionLabel: l10n.commonRetry,
                  onAction: cubit.load,
                )
              else if (jobs.jobs.isEmpty)
                BarqMessageView(
                  title: l10n.jobsEmptyTitle,
                  message: l10n.jobsEmptyBody,
                  icon: BarqIcons.package,
                )
              else
                BarqGap(
                  gap: BarqSpacing.md,
                  padding: const EdgeInsets.symmetric(
                    horizontal: BarqSpacing.page,
                  ),
                  children: [
                    for (final (index, job) in jobs.jobs.indexed)
                      BarqStaggerItem(
                        group: 'jobs',
                        index: index,
                        child: JobCard(
                          job: job,
                          accepting: jobs.acceptingId == job.id,
                          onOpen: () => _open(context, job),
                          onAccept: jobs.acceptingId == null
                              ? () => cubit.accept(job)
                              : null,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _OfflineView extends StatelessWidget {
  const _OfflineView({required this.driver, required this.state});

  final Driver driver;
  final DriverState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = BarqPalette.of(context);
    return ListView(
      padding: const EdgeInsets.only(bottom: BarqSpacing.navClearance),
      children: [
        BarqHeader(
          large: true,
          titleWidget: Row(
            children: [
              BarqAvatar(
                driver.initial,
                imageUrl: driver.avatarUrl,
                dark: true,
              ),
              const SizedBox(width: BarqSpacing.md),
              Expanded(
                child: Text(
                  driver.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: BarqText.h3.copyWith(color: p.text),
                ),
              ),
              _OnlineSwitch(state: state),
            ],
          ),
        ),
        _SwitchNote(state: state),
        const SizedBox(height: BarqSpacing.lg),
        Center(
          child: BarqPowerButton(
            loading: state.switching,
            onPressed: () => context.read<DriverCubit>().setOnline(true),
          ),
        ),
        const SizedBox(height: BarqSpacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: BarqSpacing.page),
          child: Column(
            children: [
              Text(
                l10n.offlineJobsTitle,
                textAlign: TextAlign.center,
                style: BarqText.h1.copyWith(color: p.text),
              ),
              const SizedBox(height: BarqSpacing.xs),
              Text(
                l10n.offlineJobsBody,
                textAlign: TextAlign.center,
                style: BarqText.body.copyWith(color: BarqColors.darkSubtle),
              ),
              const SizedBox(height: BarqSpacing.page),
              BlocBuilder<JobsCubit, JobsState>(
                builder: (context, jobs) => Row(
                  children: [
                    Expanded(
                      child: _OfflineStat(
                        value: jobs.today?.earnings.formatted ?? '',
                        label: l10n.jobsTodayEarnings,
                      ),
                    ),
                    const SizedBox(width: BarqSpacing.md),
                    Expanded(
                      child: _OfflineStat(
                        value: '${jobs.today?.orders ?? ''}',
                        label: l10n.jobsOrdersStat,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OfflineStat extends StatelessWidget {
  const _OfflineStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    return BarqCard(
      padding: const EdgeInsets.all(BarqSpacing.gap),
      child: Column(
        children: [
          Text(value, style: BarqText.h2.copyWith(color: p.text)),
          Text(label, style: BarqText.xs.copyWith(color: p.textMuted)),
        ],
      ),
    );
  }
}
