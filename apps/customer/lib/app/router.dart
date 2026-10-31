import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/data/auth_models.dart';
import '../features/auth/state/onboarding_cubit.dart';
import '../features/auth/state/otp_cubit.dart';
import '../features/auth/state/phone_cubit.dart';
import '../features/auth/state/splash_cubit.dart';
import '../features/auth/state/welcome_cubit.dart';
import '../features/auth/ui/onboarding_screen.dart';
import '../features/auth/ui/otp_screen.dart';
import '../features/auth/ui/phone_screen.dart';
import '../features/auth/ui/splash_screen.dart';
import '../features/auth/ui/welcome_screen.dart';
import '../features/system/state/system_cubit.dart';
import '../l10n/generated/app_localizations.dart';
import 'di.dart';
import 'main_shell.dart';
import 'placeholder_screen.dart';

abstract final class Routes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const otp = '/otp';
  static const welcome = '/welcome';
  static const home = '/home';
  static const categories = '/categories';
  static const orders = '/orders';
  static const account = '/account';
  static const cart = '/cart';

  /// Routes that work without a login.
  static const public = {splash, onboarding, login, otp, welcome};
}

GoRouter createRouter(AuthStore auth) => GoRouter(
  initialLocation: Routes.splash,
  refreshListenable: auth,
  redirect: (context, state) {
    final path = state.matchedLocation;
    if (!auth.isLoggedIn && !Routes.public.contains(path)) return Routes.login;
    if (path == Routes.otp && state.extra is! OtpTicket) return Routes.login;
    return null;
  },
  routes: [
    GoRoute(
      path: Routes.splash,
      builder: (context, _) => BlocProvider(
        create: (context) => SplashCubit(
          config: context.read<AppDependencies>().config,
          auth: context.read<AppDependencies>().auth,
          repository: context.read<AppDependencies>().authRepository,
          system: context.read<SystemCubit>(),
          appVersion: appVersion,
        )..start(),
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      path: Routes.onboarding,
      builder: (context, _) => BlocProvider(
        create: (_) => OnboardingCubit(),
        child: const OnboardingScreen(),
      ),
    ),
    GoRoute(
      path: Routes.login,
      builder: (context, _) => BlocProvider(
        create: (context) =>
            PhoneCubit(context.read<AppDependencies>().authRepository),
        child: const PhoneScreen(),
      ),
    ),
    GoRoute(
      path: Routes.otp,
      builder: (context, state) {
        final ticket = state.extra! as OtpTicket;
        return BlocProvider(
          create: (context) => OtpCubit(
            repository: context.read<AppDependencies>().authRepository,
            auth: context.read<AppDependencies>().auth,
            ticket: ticket,
          ),
          child: const OtpScreen(),
        );
      },
    ),
    GoRoute(
      path: Routes.welcome,
      builder: (context, _) => BlocProvider(
        create: (context) => WelcomeCubit(
          repository: context.read<AppDependencies>().authRepository,
          location: context.read<AppDependencies>().locationRepository,
        ),
        child: const WelcomeScreen(),
      ),
    ),
    GoRoute(
      path: Routes.cart,
      builder: (context, _) => PlaceholderScreen(
        title: AppLocalizations.of(context).navCart,
        design: 'design/03_checkout_01.png',
        back: true,
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => MainShell(shell: shell),
      branches: [
        _tab(Routes.home, 'design/02_browse_01.png', (l10n) => l10n.navHome),
        _tab(
          Routes.categories,
          'design/02_browse_02.png',
          (l10n) => l10n.navCategories,
        ),
        _tab(
          Routes.orders,
          'design/05_after_order_03.png',
          (l10n) => l10n.navOrders,
        ),
        _tab(
          Routes.account,
          'design/06_account_01.png',
          (l10n) => l10n.navAccount,
        ),
      ],
    ),
  ],
);

StatefulShellBranch _tab(
  String path,
  String design,
  String Function(AppLocalizations) title,
) => StatefulShellBranch(
  routes: [
    GoRoute(
      path: path,
      builder: (context, _) => PlaceholderScreen(
        title: title(AppLocalizations.of(context)),
        design: design,
      ),
    ),
  ],
);
