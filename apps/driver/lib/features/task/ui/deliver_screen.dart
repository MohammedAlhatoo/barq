import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../state/proof_cubit.dart';
import 'widgets/confirm_step.dart';
import 'widgets/proof_listener.dart';

/// Hands the order over: collect the cash, photo at the door, then deliver.
/// No code from the customer: `delivery_confirmation = photo`.
class DeliverScreen extends StatelessWidget {
  const DeliverScreen({super.key});

  static const _frame = 200.0;
  static const _art = 150.0;
  static const _customer = 50.0;
  static const _cashIcon = 54.0;

  Future<void> _deliver(BuildContext context) async {
    final cubit = context.read<ProofCubit>();
    if (await confirmStep(context, cubit.next)) await cubit.send();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = BarqPalette.of(context);
    final cubit = context.read<ProofCubit>();
    final job = cubit.job;
    final config = ConfigScope.of(context);
    final actions = context.read<AppDependencies>().deviceActions;
    final support = config.isLoaded ? config.config.supportPhone : null;
    final name = job.customerName ?? job.dropoff.label ?? '';
    final phone = job.customerPhone;
    final address = [?job.dropoff.label, ?job.dropoff.details].join(' · ');
    return ProofListener(
      child: BlocBuilder<ProofCubit, ProofState>(
        builder: (context, state) {
          final photo = state.photo;
          return DesignOverlay(
            image: 'design/09_driver_delivery_01.png',
            child: BarqScreen(
              body: ListView(
                padding: const EdgeInsets.only(bottom: BarqSpacing.stateBottom),
                children: [
                  BarqHeader(
                    back: true,
                    titleWidget: BarqPill(
                      l10n.deliverTitle(
                        config.config.status(job.statusKey).label,
                      ),
                      tone: BarqPillTone.neutral,
                    ),
                    trailing: support == null
                        ? null
                        : BarqIconButton(
                            icon: BarqIcons.help,
                            flat: true,
                            tooltip: l10n.deliverHelp,
                            onPressed: () => actions.call(support),
                          ),
                    bottom: OrderStatusProgress(
                      keys: OrderTimelines.tracking,
                      current: cubit.next.to,
                      showLabels: true,
                    ),
                  ),
                  BarqGap(
                    padding: const EdgeInsets.fromLTRB(
                      BarqSpacing.page,
                      18,
                      BarqSpacing.page,
                      0,
                    ),
                    children: [
                      BarqCard(
                        child: Row(
                          children: [
                            BarqAvatar(
                              name.isEmpty
                                  ? ''
                                  : String.fromCharCode(name.runes.first),
                              size: _customer,
                            ),
                            const SizedBox(width: BarqSpacing.gap),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: BarqText.h3.copyWith(color: p.text),
                                  ),
                                  Text(
                                    address,
                                    style: BarqText.xs.copyWith(
                                      color: p.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (phone != null)
                              BarqIconButton(
                                icon: BarqIcons.phone,
                                flat: true,
                                tooltip: l10n.taskCall,
                                background: BarqColors.primary,
                                iconColor: Colors.white,
                                onPressed: () => actions.call(phone),
                              ),
                          ],
                        ),
                      ),
                      BarqBanner(
                        gradient: BarqGradients.cash,
                        child: Row(
                          children: [
                            BarqIconTile(
                              BarqIcons.cash,
                              size: _cashIcon,
                              tone: BarqTileTone.onCash,
                            ),
                            const SizedBox(width: BarqSpacing.gap),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.deliverCollect, style: BarqText.t),
                                  Text(
                                    l10n.deliverIncludesFee,
                                    style: BarqText.xs.copyWith(
                                      color: BarqColors.warningTextDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(job.collect.formatted, style: BarqText.h1),
                          ],
                        ),
                      ),
                      BarqCard(
                        child: BarqGap(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    l10n.deliverPhotoTitle,
                                    style: BarqText.h3.copyWith(color: p.text),
                                  ),
                                ),
                                if (photo != null)
                                  BarqPill(
                                    l10n.deliverPhotoTaken,
                                    tone: BarqPillTone.success,
                                    icon: BarqIcons.check,
                                  ),
                              ],
                            ),
                            GestureDetector(
                              onTap: photo == null ? cubit.take : null,
                              child: BarqViewfinder(
                                height: _frame,
                                radius: 22,
                                cornerInset: 14,
                                cornerSize: 30,
                                child: photo == null
                                    ? const Center(
                                        child: BarqIllustration(
                                          BarqIllustrations.box,
                                          width: _art,
                                          height: _art,
                                        ),
                                      )
                                    : Image.file(photo, fit: BoxFit.cover),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    l10n.deliverPhotoProof,
                                    style: BarqText.xs.copyWith(
                                      color: p.textMuted,
                                    ),
                                  ),
                                ),
                                BarqLink(
                                  photo == null
                                      ? l10n.deliverTakePhoto
                                      : l10n.deliverRetake,
                                  onPressed: cubit.take,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
                        icon: BarqIcons.check,
                        variant: BarqButtonVariant.green,
                        loading: state.sending,
                        onPressed: photo == null
                            ? null
                            : () => _deliver(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
