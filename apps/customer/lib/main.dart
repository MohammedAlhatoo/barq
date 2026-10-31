import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core_check_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = AuthStore();
  await auth.load();
  final api = ApiClient(authStore: auth, appVersion: '1.0.0');
  final config = ConfigStore(api: api, app: BarqAppKind.customer);
  runApp(BarqCustomerApp(config: config));
}

/// Temporary root for phase 1: checks barq_core against the real server.
class BarqCustomerApp extends StatelessWidget {
  const BarqCustomerApp({super.key, required this.config});

  final ConfigStore config;

  @override
  Widget build(BuildContext context) {
    return ConfigScope(
      store: config,
      child: MaterialApp(
        title: 'Barq',
        debugShowCheckedModeBanner: false,
        theme: barqLightTheme(),
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: CoreCheckScreen(store: config),
      ),
    );
  }
}
