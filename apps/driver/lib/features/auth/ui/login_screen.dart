import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/phone_number.dart';
import '../state/login_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _artHeight = 220.0;
  static const _artWidth = 270.0;
  static const _wordmark = 52.0;

  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = BarqPalette.of(context);
    final cubit = context.read<LoginCubit>();
    return BlocConsumer<LoginCubit, LoginState>(
      listenWhen: (previous, current) => current.loggedIn,
      listener: (context, _) => context.go(Routes.jobs),
      builder: (context, state) => DesignOverlay(
        image: 'design/08_driver_jobs_01.png',
        child: BarqScreen(
          body: BarqFillScroll(
            footer: Padding(
              padding: const EdgeInsets.fromLTRB(
                BarqSpacing.page,
                BarqSpacing.section,
                BarqSpacing.page,
                BarqSpacing.stateBottom,
              ),
              child: BarqGap(
                children: [
                  BarqButton(
                    label: l10n.loginButton,
                    loading: state.sending,
                    onPressed: state.isValid ? cubit.login : null,
                  ),
                  Text(
                    l10n.loginFootnote,
                    textAlign: TextAlign.center,
                    style: BarqText.xs.copyWith(color: p.textMuted),
                  ),
                ],
              ),
            ),
            children: [
              BarqHeader(
                titleWidget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BarqWordmark(size: _wordmark),
                    const SizedBox(width: BarqSpacing.md),
                    Flexible(
                      child: BarqPill(
                        l10n.loginCaptain,
                        tone: BarqPillTone.white,
                      ),
                    ),
                  ],
                ),
              ),
              const BarqIllustrationArea(
                height: _artHeight,
                child: BarqIllustration(
                  BarqIllustrations.scooter,
                  width: _artWidth,
                  height: _artHeight,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: BarqSpacing.page,
                ),
                child: BarqGap(
                  gap: BarqSpacing.sm,
                  children: [
                    Text(
                      l10n.loginTitle,
                      style: BarqText.h1.copyWith(color: p.text),
                    ),
                    Text(
                      l10n.loginBody,
                      style: BarqText.body.copyWith(
                        color: BarqColors.darkSubtle,
                      ),
                    ),
                    const SizedBox(height: BarqSpacing.sm),
                    BarqFieldLabel(l10n.loginPhoneLabel),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: BarqInput(
                        hint: l10n.loginPhoneHint,
                        keyboardType: TextInputType.phone,
                        textDirection: TextDirection.ltr,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(
                            PhoneNumber.maxDigits,
                          ),
                        ],
                        prefix: BarqPill(l10n.loginCountryCode),
                        onChanged: cubit.phoneChanged,
                      ),
                    ),
                    const SizedBox(height: BarqSpacing.xs),
                    BarqFieldLabel(l10n.loginPasswordLabel),
                    BarqInput(
                      icon: BarqIcons.lock,
                      obscureText: !_showPassword,
                      errorText: state.error,
                      textInputAction: TextInputAction.done,
                      suffix: BarqLink(
                        _showPassword
                            ? l10n.loginHidePassword
                            : l10n.loginShowPassword,
                        fontSize: BarqText.xs.fontSize,
                        onPressed: () =>
                            setState(() => _showPassword = !_showPassword),
                      ),
                      onChanged: cubit.passwordChanged,
                      onSubmitted: (_) => cubit.login(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
