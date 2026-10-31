import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../state/proof_cubit.dart';
import 'widgets/confirm_step.dart';
import 'widgets/proof_listener.dart';

/// "صوّر الطلب" at the store. The phone's own camera takes the picture, so
/// the design's flash and switch buttons are not needed here.
class PhotoScreen extends StatelessWidget {
  const PhotoScreen({super.key});

  static const _frame = 360.0;
  static const _art = 240.0;

  Future<void> _send(BuildContext context) async {
    final cubit = context.read<ProofCubit>();
    if (await confirmStep(context, cubit.next)) await cubit.send();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = BarqPalette.of(context);
    final cubit = context.read<ProofCubit>();
    return ProofListener(
      child: BlocBuilder<ProofCubit, ProofState>(
        builder: (context, state) {
          final photo = state.photo;
          return DesignOverlay(
            image: 'design/08_driver_jobs_06.png',
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
                      if (state.cameraFailed)
                        BarqNote(
                          l10n.photoCameraFailed,
                          icon: BarqIcons.alert,
                          tone: BarqNoteTone.danger,
                        ),
                      if (state.notice != null)
                        BarqNote(
                          state.notice!,
                          icon: BarqIcons.alert,
                          tone: BarqNoteTone.danger,
                        ),
                      BarqButton(
                        label: cubit.next.label,
                        loading: state.sending,
                        onPressed: photo == null ? null : () => _send(context),
                      ),
                    ],
                  ),
                ),
                children: [
                  BarqHeader(
                    back: true,
                    title: l10n.photoTitle,
                    bottom: Text(
                      l10n.photoBody,
                      style: BarqText.body.copyWith(
                        color: BarqColors.darkSubtle,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      BarqSpacing.page,
                      BarqSpacing.section,
                      BarqSpacing.page,
                      BarqSpacing.page,
                    ),
                    child: BarqViewfinder(
                      height: _frame,
                      child: photo == null
                          ? const Center(
                              child: BarqIllustration(
                                BarqIllustrations.basket,
                                width: _art,
                                height: _art,
                              ),
                            )
                          : Image.file(photo, fit: BoxFit.cover),
                    ),
                  ),
                  Center(
                    child: BarqShutterButton(
                      tooltip: l10n.photoShutter,
                      onPressed: cubit.take,
                    ),
                  ),
                  if (photo != null) ...[
                    const SizedBox(height: BarqSpacing.sm),
                    Text(
                      l10n.photoRetake,
                      textAlign: TextAlign.center,
                      style: BarqText.xs.copyWith(color: p.textMuted),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
