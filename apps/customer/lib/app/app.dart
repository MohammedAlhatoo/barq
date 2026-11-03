import 'dart:async';

import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/orders/data/orders_models.dart';
import '../features/system/ui/system_gate.dart';
import '../l10n/generated/app_localizations.dart';
import 'di.dart';
import 'locale_cubit.dart';
import 'router.dart';

/// Theme, language, shared objects, and the system screens above all routes.
class BarqCustomerApp extends StatefulWidget {
  const BarqCustomerApp({super.key, required this.deps});

  final AppDependencies deps;

  @override
  State<BarqCustomerApp> createState() => _BarqCustomerAppState();
}

class _BarqCustomerAppState extends State<BarqCustomerApp> {
  late final GoRouter _router = createRouter(widget.deps.auth);
  StreamSubscription<PushMessage>? _pushOpened;

  @override
  void initState() {
    super.initState();
    _pushOpened = widget.deps.push.onOpen.listen((message) {
      final orderId = orderIdOf(message.data);
      if (orderId != null) _router.go(Routes.orderOf(orderId));
    });
  }

  /// Labels from the server depend on the language.
  Future<void> _reloadConfig() async {
    try {
      await widget.deps.config.load();
    } on ApiException catch (e) {
      debugPrint('Config not reloaded after language change: $e');
    }
  }

  @override
  void dispose() {
    _pushOpened?.cancel();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deps = widget.deps;
    return RepositoryProvider.value(
      value: deps,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: deps.locale),
          BlocProvider.value(value: deps.system),
          BlocProvider.value(value: deps.cart),
          BlocProvider.value(value: deps.scope),
          BlocProvider.value(value: deps.unread),
        ],
        child: ConfigScope(
          store: deps.config,
          child: BlocConsumer<LocaleCubit, Locale>(
            listener: (_, _) => _reloadConfig(),
            builder: (context, locale) => MaterialApp.router(
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context).appName,
              debugShowCheckedModeBanner: false,
              theme: barqLightTheme(),
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              routerConfig: _router,
              builder: (context, child) => SystemGate(
                onLogin: () => _router.go(Routes.login),
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
