import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/phone_number.dart';
import '../state/otp_cubit.dart';
import 'widgets/auth_header.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  /// 65 becomes "01:05".
  String _time(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final rest = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$rest';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<OtpCubit>();
    return BlocConsumer<OtpCubit, OtpState>(
      listenWhen: (previous, current) => previous.result != current.result,
      listener: (context, state) {
        if (state.result == OtpResult.goWelcome) context.go(Routes.welcome);
        if (state.result == OtpResult.goHome) context.go(Routes.home);
      },
      builder: (context, state) {
        final error = state.error;
        return DesignOverlay(
          image: 'design/01_auth_06.png',
          child: BarqScreen(
            body: BarqFillScroll(
              footer: Padding(
                padding: const EdgeInsets.fromLTRB(
                  BarqSpacing.page,
                  BarqSpacing.section,
                  BarqSpacing.page,
                  BarqSpacing.formBottom,
                ),
                child: BarqButton(
                  label: l10n.otpConfirm,
                  loading: state.busy,
                  onPressed: state.isComplete ? cubit.verify : null,
                ),
              ),
              children: [
                const AuthHeader(),
                const BarqIllustrationArea(
                  height: BarqSizes.otpArt,
                  child: BarqRingBadge(icon: BarqIcons.shield),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: BarqSpacing.page,
                  ),
                  child: BarqGap(
                    gap: BarqSpacing.md,
                    children: [
                      Text(l10n.otpTitle, style: BarqText.h1),
                      _SentTo(state: state),
                    ],
                  ),
                ),
                const SizedBox(height: BarqSpacing.lg),
                BarqCodeInput(
                  key: ValueKey(state.resendCount),
                  length: state.ticket.length,
                  hasError: error != null,
                  onChanged: cubit.codeChanged,
                  onCompleted: (_) => cubit.verify(),
                ),
                if (error != null) ...[
                  const SizedBox(height: BarqSpacing.gap),
                  Text(
                    error,
                    textAlign: TextAlign.center,
                    style: BarqText.xs.copyWith(color: BarqColors.danger),
                  ),
                ],
                const SizedBox(height: BarqSpacing.page),
                Center(
                  child: state.secondsLeft > 0
                      ? Text.rich(
                          TextSpan(
                            style: BarqText.t.copyWith(color: BarqColors.muted),
                            children: [
                              TextSpan(text: l10n.otpResendIn),
                              // Keeps the digits of the time in LTR order.
                              TextSpan(
                                text: '\u2066${_time(state.secondsLeft)}\u2069',
                                style: BarqText.tBold,
                              ),
                            ],
                          ),
                        )
                      : BarqLink(l10n.otpResend, onPressed: cubit.resend),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// "أرسلنا رمزًا … إلى 059 912 3456 · تعديل الرقم"
class _SentTo extends StatelessWidget {
  const _SentTo({required this.state});

  final OtpState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phone = PhoneNumber.display(state.ticket.phone);
    return Text.rich(
      TextSpan(
        style: BarqText.body,
        children: [
          TextSpan(text: l10n.otpSentTo(state.ticket.length)),
          TextSpan(text: '\u2066$phone\u2069', style: BarqText.tBold),
          const TextSpan(text: ' · '),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: BarqLink(l10n.otpEditPhone, onPressed: () => context.pop()),
          ),
        ],
      ),
    );
  }
}
