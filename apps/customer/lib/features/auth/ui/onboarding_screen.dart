import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/locale_cubit.dart';
import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../state/onboarding_cubit.dart';
import 'widgets/onboarding_art.dart';
import 'widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _designs = [
    'design/01_auth_02.png',
    'design/01_auth_03.png',
    'design/01_auth_04.png',
  ];

  final _pages = PageController();

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _next(OnboardingCubit cubit) {
    if (cubit.isLastPage) {
      context.push(Routes.login);
      return;
    }
    _pages.nextPage(duration: BarqDurations.normal, curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<OnboardingCubit>();
    return BlocBuilder<OnboardingCubit, int>(
      builder: (context, page) => DesignOverlay(
        image: _designs[page],
        child: BarqScreen(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BarqHeader(
                leading: BlocBuilder<LocaleCubit, Locale>(
                  builder: (context, locale) => BarqLanguageSwitch(
                    isArabic: locale.languageCode == 'ar',
                    onChanged: (arabic) => context.read<LocaleCubit>().change(
                      arabic ? 'ar' : 'en',
                    ),
                  ),
                ),
                trailing: cubit.isLastPage
                    ? null
                    : BarqLink(
                        l10n.onboardingSkip,
                        color: BarqColors.ink,
                        onPressed: () => context.push(Routes.login),
                      ),
              ),
              Expanded(
                child: PageView(
                  controller: _pages,
                  onPageChanged: cubit.pageChanged,
                  children: [
                    OnboardingPage(
                      art: const ShopArt(),
                      title: l10n.onboardingShopTitle,
                      body: l10n.onboardingShopBody,
                    ),
                    OnboardingPage(
                      art: const CompareArt(),
                      title: l10n.onboardingCompareTitle,
                      body: l10n.onboardingCompareBody,
                    ),
                    OnboardingPage(
                      art: const DeliveryArt(),
                      title: l10n.onboardingDeliveryTitle,
                      body: l10n.onboardingDeliveryBody,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  BarqSpacing.page,
                  0,
                  BarqSpacing.page,
                  BarqSpacing.formBottom,
                ),
                child: BarqGap(
                  gap: BarqSpacing.page,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BarqDots(count: OnboardingCubit.pageCount, index: page),
                    BarqButton(
                      label: cubit.isLastPage
                          ? l10n.onboardingStart
                          : l10n.onboardingNext,
                      onPressed: () => _next(cubit),
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
