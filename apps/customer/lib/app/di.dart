import 'package:barq_core/barq_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/account/data/account_repository.dart';
import '../features/account/data/avatar_picker.dart';
import '../features/account/data/local_session.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/data/location_repository.dart';
import '../features/browse/data/browse_repository.dart';
import '../features/browse/data/user_location.dart';
import '../features/browse/data/vendor_actions.dart';
import '../features/cart/data/cart_repository.dart';
import '../features/cart/state/cart_cubit.dart';
import '../features/cart/state/shop_scope_cubit.dart';
import '../features/checkout/data/checkout_repository.dart';
import '../features/offer/data/offer_repository.dart';
import '../features/system/state/system_cubit.dart';
import 'locale_cubit.dart';

/// Keep equal to `version` in pubspec.yaml. Sent as X-App-Version.
const appVersion = '1.0.0';

/// Debug only: opens a system screen on start, for checking its design.
/// `--dart-define=BARQ_PREVIEW=maintenance` (offline, updateRequired,
/// maintenance, sessionExpired).
const _preview = String.fromEnvironment('BARQ_PREVIEW');

/// Creates everything once. The app shares this one object through
/// RepositoryProvider, because Provider refuses ChangeNotifiers such as AuthStore.
class AppDependencies {
  AppDependencies({
    required this.auth,
    required this.api,
    required this.config,
    required this.push,
    required this.locale,
    required this.system,
    required this.authRepository,
    required this.locationRepository,
    required this.browseRepository,
    required this.userLocation,
    required this.vendorActions,
    required this.cartRepository,
    required this.cart,
    required this.scope,
    required this.checkoutRepository,
    required this.offerRepository,
    required this.accountRepository,
    required this.avatarPicker,
    required this.prefs,
    this.mapTileUrl,
  });

  final AuthStore auth;
  final ApiClient api;
  final ConfigStore config;
  final PushService push;
  final LocaleCubit locale;
  final SystemCubit system;
  final AuthRepository authRepository;
  final LocationRepository locationRepository;
  final BrowseRepository browseRepository;
  final UserLocation userLocation;
  final VendorActions vendorActions;
  final CartRepository cartRepository;
  final CartCubit cart;
  final ShopScopeCubit scope;
  final CheckoutRepository checkoutRepository;
  final OfferRepository offerRepository;
  final AccountRepository accountRepository;
  final AvatarPicker avatarPicker;
  final SharedPreferences prefs;

  /// Null draws the map with no tiles, so tests never call the tile server.
  final String? mapTileUrl;

  static Future<AppDependencies> create() async {
    final prefs = await SharedPreferences.getInstance();
    final auth = AuthStore();
    await auth.load();

    final locale = LocaleCubit(prefs);
    final api = ApiClient(
      authStore: auth,
      appVersion: appVersion,
      language: () => locale.state.languageCode,
    );
    final config = ConfigStore(api: api, app: BarqAppKind.customer);
    final system = SystemCubit(
      api: api,
      auth: auth,
      config: config,
      network: NetworkMonitor(),
      appVersion: appVersion,
      initial: kDebugMode ? SystemIssue.values.asNameMap()[_preview] : null,
    );
    final browse = ApiBrowseRepository(api);
    final location = GeolocatorLocationRepository();
    final cart = CartCubit(prefs: prefs, config: config, browse: browse);
    return AppDependencies(
      auth: auth,
      api: api,
      config: config,
      push: PushService(api: api, app: BarqAppKind.customer),
      locale: locale,
      system: system,
      authRepository: ApiAuthRepository(api, prefs),
      locationRepository: location,
      browseRepository: browse,
      userLocation: UserLocation(browse, location),
      vendorActions: DeviceVendorActions(),
      cartRepository: ApiCartRepository(api),
      cart: cart,
      scope: ShopScopeCubit(cart: cart, browse: browse),
      checkoutRepository: ApiCheckoutRepository(api),
      offerRepository: ApiOfferRepository(api),
      accountRepository: ApiAccountRepository(
        api,
        UploadService(api: api),
        LocalSession(auth: auth, cart: cart, prefs: prefs),
      ),
      avatarPicker: GalleryAvatarPicker(),
      prefs: prefs,
      mapTileUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    );
  }
}
