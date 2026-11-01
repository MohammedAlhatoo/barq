import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/account/state/account_cubit.dart';
import '../features/account/state/address_form_cubit.dart';
import '../features/account/state/addresses_cubit.dart';
import '../features/account/state/delete_account_cubit.dart';
import '../features/account/state/edit_profile_cubit.dart';
import '../features/account/ui/account_screen.dart';
import '../features/account/ui/address_form_screen.dart';
import '../features/account/ui/addresses_screen.dart';
import '../features/account/ui/delete_account_screen.dart';
import '../features/account/ui/edit_profile_screen.dart';
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
import '../features/checkout/state/checkout_cubit.dart';
import '../features/checkout/ui/checkout_screen.dart';
import '../features/notifications/state/notifications_cubit.dart';
import '../features/notifications/ui/notifications_screen.dart';
import '../features/offer/state/offer_cubit.dart';
import '../features/offer/ui/offer_screen.dart';
import '../features/orders/state/order_waiting_cubit.dart';
import '../features/orders/state/orders_cubit.dart';
import '../features/orders/state/rate_cubit.dart';
import '../features/orders/state/receipt_cubit.dart';
import '../features/orders/state/tracking_cubit.dart';
import '../features/orders/ui/order_waiting_screen.dart';
import '../features/orders/ui/orders_screen.dart';
import '../features/orders/ui/rate_screen.dart';
import '../features/orders/ui/receipt_screen.dart';
import '../features/orders/ui/tracking_screen.dart';
import '../features/system/state/system_cubit.dart';
import '../l10n/generated/app_localizations.dart';
import 'di.dart';
import 'main_shell.dart';

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
  static const accountEdit = '/account/edit';
  static const accountDelete = '/account/delete';
  static const addresses = '/addresses';
  static const addressNew = '/addresses/new';
  static const addressEdit = '/addresses/edit';
  static const notifications = '/notifications';
  static const order = '/orders/:id';
  static const offer = '/orders/:id/offer';
  static const track = '/orders/:id/track';
  static const rate = '/orders/:id/rate';
  static const receipt = '/orders/:id/receipt';

  static String productOf(int id) => '/product/$id';
  static String vendorOf(int id) => '/vendor/$id';
  static String orderOf(int id) => '/orders/$id';
  static String offerOf(int id) => '/orders/$id/offer';
  static String trackOf(int id) => '/orders/$id/track';
  static String rateOf(int id) => '/orders/$id/rate';
  static String receiptOf(int id) => '/orders/$id/receipt';
  static String categoryOf(int id) => '$categories?category=$id';

  /// Routes that work without a login.
  static const public = {splash, onboarding, login, otp, welcome};
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
    if (path == Routes.otp && state.extra is! OtpTicket) return Routes.login;
    if (path == Routes.addressEdit && state.extra is! SavedAddress) {
      return Routes.addresses;
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
          repository: context.read<AppDependencies>().authRepository,
          system: context.read<SystemCubit>(),
          appVersion: appVersion,
        )..start(),
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      path: Routes.onboarding,
      pageBuilder: (context, state) => _fadePage(
        state,
        BlocProvider(
          create: (_) => OnboardingCubit(),
          child: const OnboardingScreen(),
        ),
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
      pageBuilder: (context, state) => _fadePage(
        state,
        BlocProvider(
          create: (context) => WelcomeCubit(
            repository: context.read<AppDependencies>().authRepository,
            location: context.read<AppDependencies>().locationRepository,
          ),
          child: const WelcomeScreen(),
        ),
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
      builder: (context, state) {
        final deps = context.read<AppDependencies>();
        final address = state.extra;
        return BlocProvider(
          create: (_) => CompareCubit(
            browse: deps.browseRepository,
            cart: deps.cartRepository,
            current: context.read<CartCubit>().state,
            address: address is SavedAddress ? address : null,
          )..load(),
          child: const CompareScreen(),
        );
      },
    ),
    GoRoute(
      path: Routes.checkout,
      builder: (context, _) {
        final deps = context.read<AppDependencies>();
        return BlocProvider(
          create: (_) => CheckoutCubit(
            repository: deps.checkoutRepository,
            browse: deps.browseRepository,
            carts: deps.cartRepository,
            cart: deps.cart,
            compareEnabled: () =>
                deps.config.config.hasModule('basket_compare'),
          )..start(),
          child: const CheckoutScreen(),
        );
      },
    ),
    GoRoute(
      path: Routes.order,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final deps = context.read<AppDependencies>();
        return BlocProvider(
          create: (_) => OrderWaitingCubit(
            orders: deps.ordersRepository,
            offers: deps.offerRepository,
            orderId: id,
            pollSeconds:
                deps.config.config.polling.eventsSeconds ?? Poller.minSeconds,
          )..start(),
          child: OrderWaitingScreen(orderId: id),
        );
      },
    ),
    GoRoute(
      path: Routes.offer,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final deps = context.read<AppDependencies>();
        return BlocProvider(
          create: (_) => OfferCubit(
            repository: deps.offerRepository,
            cart: deps.cart,
            orderId: id,
          )..load(),
          child: OfferScreen(orderId: id),
        );
      },
    ),
    GoRoute(
      path: Routes.track,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final deps = context.read<AppDependencies>();
        return BlocProvider(
          create: (_) => TrackingCubit(
            repository: deps.ordersRepository,
            orderId: id,
            pollSeconds:
                deps.config.config.polling.trackingSeconds ?? Poller.minSeconds,
          )..start(),
          child: TrackingScreen(orderId: id),
        );
      },
    ),
    GoRoute(
      path: Routes.rate,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return BlocProvider(
          create: (context) => RateCubit(
            repository: context.read<AppDependencies>().ordersRepository,
            orderId: id,
          )..load(),
          child: const RateScreen(),
        );
      },
    ),
    GoRoute(
      path: Routes.receipt,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final deps = context.read<AppDependencies>();
        return BlocProvider(
          create: (_) => ReceiptCubit(
            repository: deps.ordersRepository,
            cart: deps.cart,
            orderId: id,
          )..load(),
          child: const ReceiptScreen(),
        );
      },
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
    GoRoute(
      path: Routes.accountEdit,
      builder: (context, _) {
        final deps = context.read<AppDependencies>();
        return BlocProvider(
          create: (_) => EditProfileCubit(
            repository: deps.accountRepository,
            picker: deps.avatarPicker,
            locale: deps.locale,
          )..load(),
          child: const EditProfileScreen(),
        );
      },
    ),
    GoRoute(
      path: Routes.accountDelete,
      builder: (context, _) => BlocProvider(
        create: (context) => DeleteAccountCubit(
          context.read<AppDependencies>().accountRepository,
        ),
        child: const DeleteAccountScreen(),
      ),
    ),
    GoRoute(
      path: Routes.addresses,
      builder: (context, _) => BlocProvider(
        create: (context) =>
            AddressesCubit(context.read<AppDependencies>().accountRepository)
              ..load(),
        child: const AddressesScreen(),
      ),
    ),
    GoRoute(
      path: Routes.addressNew,
      builder: (context, _) => _addressForm(context, null),
    ),
    GoRoute(
      path: Routes.addressEdit,
      builder: (context, state) =>
          _addressForm(context, state.extra! as SavedAddress),
    ),
    GoRoute(
      path: Routes.notifications,
      builder: (context, _) {
        final deps = context.read<AppDependencies>();
        return BlocProvider(
          create: (_) => NotificationsCubit(
            repository: deps.ordersRepository,
            unread: deps.unread,
          )..load(),
          child: const NotificationsScreen(),
        );
      },
    ),
    StatefulShellRoute.indexedStack(
      pageBuilder: (context, state, shell) =>
          _fadePage(state, MainShell(shell: shell)),
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
                  context.read<AppDependencies>().accountRepository.changes,
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
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.orders,
              builder: (context, _) {
                final deps = context.read<AppDependencies>();
                return BlocProvider(
                  create: (_) => OrdersCubit(
                    repository: deps.ordersRepository,
                    cart: deps.cart,
                  )..load(),
                  child: const OrdersScreen(),
                );
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.account,
              builder: (context, _) => BlocProvider(
                create: (context) => AccountCubit(
                  context.read<AppDependencies>().accountRepository,
                )..load(),
                child: const AccountScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);

Widget _addressForm(BuildContext context, SavedAddress? existing) {
  final deps = context.read<AppDependencies>();
  final l10n = AppLocalizations.of(context);
  return BlocProvider(
    create: (_) => AddressFormCubit(
      repository: deps.accountRepository,
      location: deps.locationRepository,
      homeLabel: l10n.addressHome,
      workLabel: l10n.addressWork,
      otherLabel: l10n.addressOther,
      existing: existing,
    )..start(),
    child: const AddressFormScreen(),
  );
}
