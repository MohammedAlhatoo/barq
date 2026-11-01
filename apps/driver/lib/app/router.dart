import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/state/login_cubit.dart';
import '../features/auth/state/splash_cubit.dart';
import '../features/auth/ui/login_screen.dart';
import '../features/auth/ui/splash_screen.dart';
import '../features/earnings/state/earnings_cubit.dart';
import '../features/earnings/ui/earnings_screen.dart';
import '../features/history/state/history_cubit.dart';
import '../features/history/ui/history_screen.dart';
import '../features/jobs/data/job_models.dart';
import '../features/jobs/state/cash_limit_cubit.dart';
import '../features/jobs/state/jobs_cubit.dart';
import '../features/jobs/state/offer_cubit.dart';
import '../features/jobs/ui/cash_limit_screen.dart';
import '../features/jobs/ui/jobs_screen.dart';
import '../features/jobs/ui/offer_screen.dart';
import '../features/notifications/state/notifications_cubit.dart';
import '../features/notifications/ui/notifications_screen.dart';
import '../features/profile/ui/account_screen.dart';
import '../features/system/state/system_cubit.dart';
import '../features/task/state/proof_cubit.dart';
import '../features/task/state/task_cubit.dart';
import '../features/task/ui/deliver_screen.dart';
import '../features/task/ui/photo_screen.dart';
import '../features/task/ui/task_screen.dart';
import '../features/task/ui/too_far_screen.dart';
import 'di.dart';
import 'main_shell.dart';

abstract final class Routes {
  static const splash = '/splash';
  static const login = '/login';
  static const jobs = '/jobs';
  static const earnings = '/earnings';
  static const history = '/history';
  static const account = '/account';
  static const offer = '/offer/:id';
  static const cashLimit = '/cash-limit';
  static const task = '/task';
  static const taskPhoto = '/task/photo';
  static const taskDeliver = '/task/deliver';
  static const taskTooFar = '/task/too-far';
  static const notifications = '/notifications';

  static String offerOf(int id) => '/offer/$id';

  /// Routes that work without a login.
  static const public = {splash, login};
}

/// Fades in: the first screen after the splash must not slide over it.
Page<void> _fadePage(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: BarqDurations.normal,
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );

GoRouter createRouter(AuthStore auth) => GoRouter(
  initialLocation: Routes.splash,
  refreshListenable: auth,
  redirect: (context, state) {
    final path = state.matchedLocation;
    if (!auth.isLoggedIn && !Routes.public.contains(path)) return Routes.login;
    const needJob = {Routes.taskPhoto, Routes.taskDeliver};
    if (needJob.contains(path)) {
      final job = state.extra;
      if (job is! Job || job.nextAction == null) return Routes.task;
    }
    if (path == Routes.taskTooFar && state.extra is! TooFarArgs) {
      return Routes.task;
    }
    return null;
  },
  routes: [
    GoRoute(
      path: Routes.splash,
      builder: (context, _) => BlocProvider(
        create: (context) => SplashCubit(
          config: context.read<AppDependencies>().config,
          auth: context.read<AppDependencies>().auth,
          system: context.read<SystemCubit>(),
          appVersion: appVersion,
        )..start(),
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      path: Routes.login,
      pageBuilder: (context, state) => _fadePage(
        state,
        BlocProvider(
          create: (context) =>
              LoginCubit(context.read<AppDependencies>().authRepository),
          child: const LoginScreen(),
        ),
      ),
    ),
    StatefulShellRoute.indexedStack(
      pageBuilder: (context, state, shell) =>
          _fadePage(state, MainShell(shell: shell)),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.jobs,
              builder: (context, _) => BlocProvider(
                create: (context) {
                  final deps = context.read<AppDependencies>();
                  return JobsCubit(
                    jobs: deps.jobsRepository,
                    earnings: deps.earningsRepository,
                    pollSeconds: () => deps.config.isLoaded
                        ? deps.config.config.polling.availableOrdersSeconds
                        : null,
                  );
                },
                child: const JobsScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.earnings,
              builder: (context, _) => BlocProvider(
                create: (context) {
                  final deps = context.read<AppDependencies>();
                  return EarningsCubit(
                    earnings: deps.earningsRepository,
                    jobs: deps.jobsRepository,
                  )..load();
                },
                child: const EarningsScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.history,
              builder: (context, _) => BlocProvider(
                create: (context) {
                  final deps = context.read<AppDependencies>();
                  return HistoryCubit(
                    history: deps.historyRepository,
                    earnings: deps.earningsRepository,
                    jobs: deps.jobsRepository,
                  )..load();
                },
                child: const HistoryScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.account,
              builder: (context, _) => const AccountScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: Routes.offer,
      builder: (context, state) => BlocProvider(
        create: (context) => OfferCubit(
          context.read<AppDependencies>().jobsRepository,
          int.parse(state.pathParameters['id']!),
        )..load(),
        child: const OfferScreen(),
      ),
    ),
    GoRoute(
      path: Routes.cashLimit,
      builder: (context, _) => BlocProvider(
        create: (context) =>
            CashLimitCubit(context.read<AppDependencies>().earningsRepository)
              ..load(),
        child: const CashLimitScreen(),
      ),
    ),
    GoRoute(
      path: Routes.task,
      builder: (context, _) => BlocProvider(
        create: (context) {
          final deps = context.read<AppDependencies>();
          return TaskCubit(
            jobs: deps.jobsRepository,
            pollSeconds: () => deps.config.isLoaded
                ? deps.config.config.polling.trackingSeconds
                : null,
          )..load();
        },
        child: const TaskScreen(),
      ),
    ),
    GoRoute(
      path: Routes.taskPhoto,
      builder: (context, state) => _proof(state, const PhotoScreen()),
    ),
    GoRoute(
      path: Routes.taskDeliver,
      builder: (context, state) => _proof(state, const DeliverScreen()),
    ),
    GoRoute(
      path: Routes.taskTooFar,
      builder: (context, state) =>
          TooFarScreen(args: state.extra! as TooFarArgs),
    ),
    GoRoute(
      path: Routes.notifications,
      builder: (context, _) => BlocProvider(
        create: (context) => NotificationsCubit(
          context.read<AppDependencies>().notificationsRepository,
        )..load(),
        child: const NotificationsScreen(),
      ),
    ),
  ],
);

/// The redirect above guarantees a job with a next step on these routes.
Widget _proof(GoRouterState state, Widget screen) {
  final job = state.extra! as Job;
  return BlocProvider(
    create: (context) {
      final deps = context.read<AppDependencies>();
      return ProofCubit(
        jobs: deps.jobsRepository,
        photos: deps.proofPhotos,
        job: job,
        next: job.nextAction!,
      );
    },
    child: screen,
  );
}
