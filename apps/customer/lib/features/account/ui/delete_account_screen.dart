import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../state/delete_account_cubit.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<DeleteAccountCubit>();
    return DesignOverlay(
      image: 'design/06_account_03.png',
      child: BarqScreen(
        body: BlocBuilder<DeleteAccountCubit, DeleteAccountState>(
          builder: (context, state) {
            final error = state.error;
            return BarqFillScroll(
              footer: Padding(
                padding: const EdgeInsets.fromLTRB(
                  BarqSpacing.page,
                  BarqSpacing.section,
                  BarqSpacing.page,
                  BarqSpacing.stateBottom,
                ),
                child: BarqGap(
                  gap: BarqSpacing.md,
                  children: [
                    if (error != null)
                      BarqNote(
                        error,
                        icon: BarqIcons.alert,
                        tone: BarqNoteTone.danger,
                      ),
                    BarqButton(
                      label: l10n.deleteConfirm,
                      variant: BarqButtonVariant.red,
                      loading: state.deleting,
                      onPressed: state.understood ? cubit.delete : null,
                    ),
                    BarqButton(
                      label: l10n.commonCancel,
                      variant: BarqButtonVariant.white,
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),
              children: [
                const BarqHeader(back: true),
                const BarqDeleteAccountArt(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: BarqSpacing.page,
                  ),
                  child: BarqGap(
                    gap: BarqSpacing.xs,
                    children: [
                      Text(
                        l10n.deleteTitle,
                        textAlign: TextAlign.center,
                        style: BarqText.h1,
                      ),
                      Text(
                        l10n.deleteBody,
                        textAlign: TextAlign.center,
                        style: BarqText.body,
                      ),
                    ],
                  ),
                ),
                BarqGap(
                  gap: 14,
                  padding: const EdgeInsets.fromLTRB(
                    BarqSpacing.page,
                    BarqSpacing.section,
                    BarqSpacing.page,
                    0,
                  ),
                  children: [
                    BarqCard(
                      child: BarqGap(
                        children: [
                          _Consequence(l10n.deleteNameAddresses),
                          _Consequence(l10n.deleteOrders),
                          _Consequence(
                            l10n.deleteActive,
                            icon: BarqIcons.info,
                            color: BarqColors.muted,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => cubit.understoodChanged(!state.understood),
                      child: Row(
                        children: [
                          BarqCheckbox(
                            value: state.understood,
                            activeColor: BarqColors.danger,
                            onChanged: cubit.understoodChanged,
                          ),
                          const SizedBox(width: BarqSpacing.md),
                          Expanded(
                            child: Text(
                              l10n.deleteUnderstand,
                              style: BarqText.t,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Consequence extends StatelessWidget {
  const _Consequence(
    this.text, {
    this.icon = BarqIcons.x,
    this.color = BarqColors.danger,
  });

  final String text;
  final String icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      BarqIcon(icon, size: BarqSizes.iconS, color: color),
      const SizedBox(width: BarqSpacing.md),
      Expanded(child: Text(text, style: BarqText.t)),
    ],
  );
}
