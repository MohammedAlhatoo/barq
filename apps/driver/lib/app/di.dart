import 'package:barq_core/barq_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/data/auth_repository.dart';
import '../features/earnings/data/earnings_repository.dart';
import '../features/jobs/data/device_actions.dart';
import '../features/jobs/data/jobs_repository.dart';
import '../features/jobs/data/location_source.dart';
import '../features/jobs/data/location_tracker.dart';
import '../features/profile/data/profile_repository.dart';
import '../features/profile/state/driver_cubit.dart';
import '../features/system/state/system_cubit.dart';
import '../l10n/generated/app_localizations.dart';
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
    required this.profileRepository,
    required this.jobsRepository,
    required this.earningsRepository,
    required this.deviceActions,
    required this.tracker,
    required this.driver,
    this.mapTileUrl,
  });

  final AuthStore auth;
  final ApiClient api;
  final ConfigStore config;
  final PushService push;
  final LocaleCubit locale;
  final SystemCubit system;
  final AuthRepository authRepository;
  final ProfileRepository profileRepository;
  final JobsRepository jobsRepository;
  final EarningsRepository earningsRepository;
  final DeviceActions deviceActions;
  final LocationTracker tracker;
  final DriverCubit driver;

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
    final config = ConfigStore(api: api, app: BarqAppKind.driver);
    final system = SystemCubit(
      api: api,
      auth: auth,
      config: config,
      network: NetworkMonitor(),
      appVersion: appVersion,
      initial: kDebugMode ? SystemIssue.values.asNameMap()[_preview] : null,
    );
    final tracker = LocationTracker(
      api: api,
      source: GeolocatorLocationSource(
        notification: () {
          final l10n = lookupAppLocalizations(
            Locale(locale.state.languageCode),
          );
          return (
            title: l10n.locationServiceTitle,
            text: l10n.locationServiceBody,
          );
        },
      ),
      minIntervalSeconds: () => config.isLoaded
          ? config.config.driver?.locationMinIntervalSeconds
          : null,
    );
    final profile = ApiProfileRepository(api);
    return AppDependencies(
      auth: auth,
      api: api,
      config: config,
      push: PushService(api: api, app: BarqAppKind.driver),
      locale: locale,
      system: system,
      authRepository: ApiAuthRepository(api, auth),
      profileRepository: profile,
      jobsRepository: ApiJobsRepository(api),
      earningsRepository: ApiEarningsRepository(api),
      deviceActions: UrlDeviceActions(),
      tracker: tracker,
      driver: DriverCubit(repository: profile, tracker: tracker, auth: auth),
      mapTileUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    );
  }
}
