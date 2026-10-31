import 'package:barq_core/barq_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/data/auth_repository.dart';
import '../features/auth/data/location_repository.dart';
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
  });

  final AuthStore auth;
  final ApiClient api;
  final ConfigStore config;
  final PushService push;
  final LocaleCubit locale;
  final SystemCubit system;
  final AuthRepository authRepository;
  final LocationRepository locationRepository;

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
    return AppDependencies(
      auth: auth,
      api: api,
      config: config,
      push: PushService(api: api, app: BarqAppKind.customer),
      locale: locale,
      system: system,
      authRepository: ApiAuthRepository(api, prefs),
      locationRepository: GeolocatorLocationRepository(),
    );
  }
}
