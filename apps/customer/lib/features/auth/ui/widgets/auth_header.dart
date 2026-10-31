import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';

/// Back button + centered logo, used on the phone and OTP screens. With no
/// page to go back to (after an expired session) it opens the onboarding.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BarqHeader(
      back: true,
      onBack: () =>
          context.canPop() ? context.pop() : context.go(Routes.onboarding),
      titleWidget: const BarqWordmark(size: BarqSizes.wordmarkHeader),
    );
  }
}
