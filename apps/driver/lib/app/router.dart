import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/state/login_cubit.dart';
import '../features/auth/state/splash_cubit.dart';
import '../features/auth/ui/login_screen.dart';
import '../features/auth/ui/splash_screen.dart';
import '../features/jobs/state/cash_limit_cubit.dart';
import '../features/jobs/state/jobs_cubit.dart';
import '../features/jobs/state/offer_cubit.dart';
import '../features/jobs/ui/cash_limit_screen.dart';
import '../features/jobs/ui/jobs_screen.dart';
import '../features/jobs/ui/offer_screen.dart';
import '../features/system/state/system_cubit.dart';
import '../features/task/state/task_cubit.dart';
import '../features/task/ui/task_screen.dart';
import 'coming_soon_screen.dart';
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

  static String offerOf(int id) => '/offer/$id';

  /// Routes that work without a login.
  static const public = {splash, login};
}

GoRouter createRouter(AuthStore auth) => GoRouter(
  initialLocation: Routes.splash,
  refreshListenable: auth,
  redirect: (context, state) {
    final path = state.matchedLocation;
    if (!auth.isLoggedIn && !Routes.public.contains(path)) return Routes.login;
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
      builder: (context, _) => BlocProvider(
        create: (context) =>
            LoginCubit(context.read<AppDependencies>().authRepository),
        child: const LoginScreen(),
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => MainShell(shell: shell),
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
              builder: (context, _) => const ComingSoonScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.history,
              builder: (context, _) => const ComingSoonScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.account,
              builder: (context, _) => const ComingSoonScreen(),
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
  ],
);
