import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/di.dart';
import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/phone_number.dart';
import '../state/phone_cubit.dart';
import 'widgets/auth_header.dart';

class PhoneScreen extends StatelessWidget {
  const PhoneScreen({super.key});

  void _openTerms(BuildContext context) {
    final config = context.read<AppDependencies>().config;
    final url = config.isLoaded ? config.config.termsUrl : null;
    if (url == null) return;
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<PhoneCubit>();
    return BlocConsumer<PhoneCubit, PhoneState>(
      listenWhen: (previous, current) => current.ticket != null,
      listener: (context, state) =>
          context.push(Routes.otp, extra: state.ticket),
      builder: (context, state) => DesignOverlay(
        image: 'design/01_auth_05.png',
        child: BarqScreen(
          body: BarqFillScroll(
            footer: Padding(
              padding: const EdgeInsets.fromLTRB(
                BarqSpacing.page,
                BarqSpacing.section,
                BarqSpacing.page,
                BarqSpacing.formBottom,
              ),
              child: BarqGap(
                gap: BarqSpacing.section,
                children: [
                  BarqButton(
                    label: l10n.loginSend,
                    loading: state.sending,
                    onPressed: state.isValid ? cubit.send : null,
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text(l10n.loginAgreePrefix, style: BarqText.xs),
                      BarqLink(
                        l10n.loginTerms,
                        fontSize: BarqText.xs.fontSize,
                        onPressed: () => _openTerms(context),
                      ),
                      Text(l10n.loginAnd, style: BarqText.xs),
                      BarqLink(
                        l10n.loginPrivacy,
                        fontSize: BarqText.xs.fontSize,
                        onPressed: () => _openTerms(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            children: [
              const AuthHeader(),
              const BarqIllustrationArea(
                height: BarqSizes.phoneArt,
                blobSize: BarqSizes.phoneBlob,
                child: BarqIllustration(
                  BarqIllustrations.phone3d,
                  width: BarqSizes.phoneImage,
                  height: BarqSizes.phoneImage,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: BarqSpacing.page,
                ),
                child: BarqGap(
                  gap: BarqSpacing.md,
                  children: [
                    Text(l10n.loginTitle, style: BarqText.h1),
                    Text(l10n.loginBody, style: BarqText.body),
                    const SizedBox(height: BarqSpacing.md),
                    BarqFieldLabel(l10n.loginPhoneLabel),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: BarqInput(
                        hint: l10n.loginPhoneHint,
                        errorText: state.error,
                        keyboardType: TextInputType.phone,
                        textDirection: TextDirection.ltr,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(
                            PhoneNumber.maxDigits,
                          ),
                        ],
                        prefix: BarqPill(l10n.loginCountryCode),
                        onChanged: cubit.phoneChanged,
                        onSubmitted: (_) => cubit.send(),
                      ),
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
