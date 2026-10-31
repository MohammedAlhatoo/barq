import 'package:barq_core/barq_core.dart';
import 'package:flutter/widgets.dart';
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
import '../features/browse/state/home_cubit.dart';
import '../features/browse/state/product_cubit.dart';
import '../features/browse/state/products_cubit.dart';
import '../features/browse/state/search_cubit.dart';
import '../features/browse/state/vendor_cubit.dart';
import '../features/browse/state/vendors_cubit.dart';
import '../features/browse/ui/category_screen.dart';
import '../features/browse/ui/home_screen.dart';
import '../features/browse/ui/product_screen.dart';
import '../features/browse/ui/search_screen.dart';
import '../features/browse/ui/vendor_screen.dart';
import '../features/browse/ui/vendors_screen.dart';
import '../features/cart/state/cart_cubit.dart';
import '../features/cart/state/cart_summary_cubit.dart';
import '../features/cart/state/compare_cubit.dart';
import '../features/cart/ui/cart_screen.dart';
import '../features/cart/ui/compare_screen.dart';
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
  static const compare = '/cart/compare';
  static const checkout = '/checkout';
  static const search = '/search';
  static const product = '/product/:id';
  static const vendor = '/vendor/:id';
  static const vendors = '/vendors';

  static String productOf(int id) => '/product/$id';
  static String vendorOf(int id) => '/vendor/$id';
  static String categoryOf(int id) => '$categories?category=$id';

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
      builder: (context, _) {
        final deps = context.read<AppDependencies>();
        return BlocProvider(
          create: (_) => CartSummaryCubit(
            browse: deps.browseRepository,
            cart: deps.cartRepository,
          )..refresh(deps.cart.state),
          child: const CartScreen(),
        );
      },
    ),
    GoRoute(
      path: Routes.compare,
      builder: (context, _) {
        final deps = context.read<AppDependencies>();
        return BlocProvider(
          create: (_) => CompareCubit(
            browse: deps.browseRepository,
            cart: deps.cartRepository,
            current: context.read<CartCubit>().state,
          )..load(),
          child: const CompareScreen(),
        );
      },
    ),
    GoRoute(
      path: Routes.checkout,
      builder: (context, _) => PlaceholderScreen(
        title: AppLocalizations.of(context).checkoutTitle,
        design: 'design/03_checkout_04.png',
        back: true,
      ),
    ),
    GoRoute(
      path: Routes.search,
      builder: (context, _) {
        final deps = context.read<AppDependencies>();
        return BlocProvider(
          create: (_) => SearchCubit(
            deps.browseRepository,
            deps.prefs,
            deps.userLocation,
            deps.scope,
          )..loadVendors(),
          child: const SearchScreen(),
        );
      },
    ),
    GoRoute(
      path: Routes.product,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return BlocProvider(
          create: (context) =>
              ProductCubit(context.read<AppDependencies>().browseRepository, id)
                ..load(),
          child: const ProductScreen(),
        );
      },
    ),
    GoRoute(
      path: Routes.vendors,
      builder: (context, _) => BlocProvider(
        create: (context) => VendorsCubit(
          context.read<AppDependencies>().browseRepository,
          context.read<AppDependencies>().userLocation,
        )..load(),
        child: const VendorsScreen(),
      ),
    ),
    GoRoute(
      path: Routes.vendor,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final browse = context.read<AppDependencies>().browseRepository;
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => VendorCubit(browse, id)..load()),
            BlocProvider(
              create: (_) => ProductsCubit(browse, vendorId: id)..load(),
            ),
          ],
          child: const VendorScreen(),
        );
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => MainShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.home,
              builder: (context, _) => BlocProvider(
                create: (context) => HomeCubit(
                  context.read<AppDependencies>().browseRepository,
                  context.read<AppDependencies>().userLocation,
                  context.read<AppDependencies>().scope,
                )..load(),
                child: const HomeScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.categories,
              builder: (context, state) {
                final category = int.tryParse(
                  state.uri.queryParameters['category'] ?? '',
                );
                // The key starts a fresh list when a home chip picks another
                // category.
                return BlocProvider(
                  key: ValueKey(category),
                  create: (context) => ProductsCubit(
                    context.read<AppDependencies>().browseRepository,
                    categoryId: category,
                    scope: context.read<AppDependencies>().scope,
                  )..load(),
                  child: CategoryScreen(fromHome: category != null),
                );
              },
            ),
          ],
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
