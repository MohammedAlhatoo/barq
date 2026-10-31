import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/locale_cubit.dart';
import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/location_repository.dart';
import '../state/welcome_cubit.dart';
import 'widgets/delivery_location_card.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  String? _locationMessage(AppLocalizations l10n, WelcomeState state) =>
      switch (state.locationProblem) {
        LocationProblem.serviceOff => l10n.welcomeLocationOff,
        LocationProblem.denied => l10n.welcomeLocationDenied,
        null => state.locationError,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<WelcomeCubit>();
    final language = context.watch<LocaleCubit>().state.languageCode;
    return BlocConsumer<WelcomeCubit, WelcomeState>(
      listenWhen: (previous, current) => current.done,
      listener: (context, _) => context.go(Routes.home),
      builder: (context, state) {
        final locationMessage = _locationMessage(l10n, state);
        final error = state.error;
        return DesignOverlay(
          image: 'design/01_auth_07.png',
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
                    if (error != null)
                      BarqNote(
                        error,
                        icon: BarqIcons.alert,
                        tone: BarqNoteTone.danger,
                      ),
                    BarqButton(
                      label: l10n.welcomeStart,
                      loading: state.saving,
                      onPressed: state.canFinish
                          ? () => cubit.finish(language)
                          : null,
                    ),
                  ],
                ),
              ),
              children: [
                BarqHeader(
                  large: true,
                  titleWidget: const Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: BarqWordmark(size: BarqSizes.wordmarkHeader),
                  ),
                  trailing: BarqPill(
                    l10n.welcomeVerified,
                    tone: BarqPillTone.success,
                    icon: BarqIcons.check,
                  ),
                  bottom: BarqGap(
                    gap: BarqSpacing.xs,
                    children: [
                      Text(l10n.welcomeTitle, style: BarqText.h1),
                      Text(l10n.welcomeBody, style: BarqText.body),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    BarqSpacing.page,
                    BarqSpacing.section,
                    BarqSpacing.page,
                    0,
                  ),
                  child: BarqGap(
                    gap: BarqSpacing.section,
                    children: [
                      BarqInput(
                        label: l10n.welcomeNameLabel,
                        hint: l10n.welcomeNameHint,
                        textInputAction: TextInputAction.done,
                        onChanged: cubit.nameChanged,
                      ),
                      DeliveryLocationCard(state: state),
                      BarqButton(
                        label: l10n.welcomeLocate,
                        icon: BarqIcons.locate,
                        small: true,
                        variant: BarqButtonVariant.outlineDashed,
                        loading: state.locating,
                        onPressed: () => cubit.locate(l10n.welcomeAddressLabel),
                      ),
                      if (locationMessage != null)
                        BarqNote(
                          locationMessage,
                          icon: BarqIcons.alert,
                          tone: BarqNoteTone.danger,
                        ),
                      BarqCard(
                        child: Row(
                          children: [
                            const BarqIconTile(BarqIcons.bell),
                            const SizedBox(width: BarqSpacing.gap),
                            Expanded(
                              child: BarqGap(
                                gap: 0,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.welcomeNotifications,
                                    style: BarqText.h3,
                                  ),
                                  Text(
                                    l10n.welcomeNotificationsBody,
                                    style: BarqText.xs,
                                  ),
                                ],
                              ),
                            ),
                            BarqToggle(
                              value: state.notifications,
                              onChanged: cubit.notificationsChanged,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
