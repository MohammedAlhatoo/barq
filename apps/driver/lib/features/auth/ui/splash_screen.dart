import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../system/state/system_cubit.dart';
import '../../system/ui/no_internet_view.dart';
import '../state/splash_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// The logo animation plays to its end before anything else shows.
  bool _introDone = false;

  void _onIntroFinished() {
    setState(() => _introDone = true);
    _onState(context, context.read<SplashCubit>().state);
  }

  void _onState(BuildContext context, SplashState state) {
    if (!_introDone) return;
    switch (state.status) {
      case SplashStatus.goJobs:
        context.go(Routes.jobs);
      case SplashStatus.goLogin:
        context.go(Routes.login);
      case SplashStatus.loading:
      case SplashStatus.offline:
      case SplashStatus.failed:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<SplashCubit>();
    return MultiBlocListener(
      listeners: [
        BlocListener<SplashCubit, SplashState>(listener: _onState),
        // A system screen was solved on top of this one: try again.
        BlocListener<SystemCubit, SystemState>(
          listenWhen: (previous, current) =>
              previous.issue != null && current.issue == null,
          listener: (_, _) {
            if (cubit.state.isStopped) cubit.start();
          },
        ),
      ],
      child: BlocBuilder<SplashCubit, SplashState>(
        builder: (context, state) {
          if (_introDone && state.status == SplashStatus.offline) {
            return NoInternetView(onRetry: cubit.start);
          }
          final message = state.message;
          if (_introDone && message != null) {
            return BarqScreen(
              body: BarqStateView(
                illustration: const BarqIconCard(icon: BarqIcons.alert),
                title: l10n.appName,
                message: message,
                actions: [
                  BarqButton(
                    label: l10n.commonRetry,
                    icon: BarqIcons.refresh,
                    onPressed: cubit.start,
                  ),
                ],
              ),
            );
          }
          return BarqScreen(
            body: BarqCaptainSplash(
              label: l10n.loginCaptain,
              tagline: l10n.splashTagline,
              animate: !_introDone,
              onFinished: _onIntroFinished,
            ),
          );
        },
      ),
    );
  }
}
