import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../state/cancel_cubit.dart';

/// Answers true when the order was cancelled.
Future<bool> showCancelOrderSheet(BuildContext context, int orderId) async {
  final repository = context.read<AppDependencies>().ordersRepository;
  final cancelled = await showBarqSheet<bool>(
    context,
    children: [
      BlocProvider(
        create: (_) =>
            CancelCubit(repository: repository, orderId: orderId)..load(),
        child: const _CancelContent(),
      ),
    ],
  );
  return cancelled ?? false;
}

class _CancelContent extends StatelessWidget {
  const _CancelContent();

  /// The server may send more reasons than fit, so the list scrolls.
  static const _listShare = .4;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<CancelCubit, CancelState>(
      listenWhen: (previous, current) => !previous.done && current.done,
      listener: (context, _) => closeBarqSheet(context, true),
      builder: (context, state) {
        final cubit = context.read<CancelCubit>();
        final loadError = state.loadError;
        final sendError = state.sendError;
        return BarqGap(
          gap: BarqSpacing.md,
          children: [
            Row(
              children: [
                const BarqIconTile(BarqIcons.x, tone: BarqTileTone.red),
                const SizedBox(width: BarqSpacing.gap),
                Expanded(
                  child: BarqGap(
                    gap: 0,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.cancelTitle, style: BarqText.h2),
                      Text(l10n.cancelBody, style: BarqText.xs),
                    ],
                  ),
                ),
              ],
            ),
            if (state.loading)
              const BarqLoadingView()
            else if (loadError != null)
              BarqMessageView(
                title: loadError,
                icon: BarqIcons.alert,
                actionLabel: l10n.commonRetry,
                onAction: cubit.load,
              )
            else ...[
              Text(l10n.cancelWhy, style: BarqText.h3),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * _listShare,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: state.reasons.length,
                  separatorBuilder: (_, _) => const BarqDivider(),
                  itemBuilder: (context, index) {
                    final reason = state.reasons[index];
                    final selected = reason.key == state.selected;
                    return InkWell(
                      onTap: () => cubit.select(reason.key),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: BarqSpacing.gap,
                        ),
                        child: Row(
                          children: [
                            BarqRadio(
                              selected: selected,
                              onTap: () => cubit.select(reason.key),
                            ),
                            const SizedBox(width: BarqSpacing.gap),
                            Expanded(
                              child: Text(
                                reason.label,
                                style: selected ? BarqText.tBold : BarqText.t,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            if (sendError != null)
              BarqNote(
                sendError,
                icon: BarqIcons.alert,
                tone: BarqNoteTone.danger,
              ),
            if (loadError == null && !state.loading)
              BarqButton(
                label: l10n.cancelConfirm,
                variant: BarqButtonVariant.red,
                loading: state.sending,
                onPressed: state.selected == null ? null : cubit.confirm,
              ),
            BarqButton(
              label: l10n.cancelBack,
              variant: BarqButtonVariant.white,
              onPressed: () => closeBarqSheet(context, false),
            ),
          ],
        );
      },
    );
  }
}
