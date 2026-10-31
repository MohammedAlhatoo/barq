import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../state/order_waiting_cubit.dart';

/// Shows the order's status and opens the offer once the store prices it.
/// Phase 6 replaces it with `04_order_status_01`.
class OrderWaitingScreen extends StatelessWidget {
  const OrderWaitingScreen({super.key, required this.orderId});

  final int orderId;

  /// With no store app, this button plays the store's next step.
  static bool get _sandbox =>
      kDebugMode && BarqEnv.projectKey.startsWith('pk_test_');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DesignOverlay(
      image: 'design/04_order_status_01.png',
      child: BarqScreen(
        body: BlocConsumer<OrderWaitingCubit, OrderWaitingState>(
          listenWhen: (previous, current) =>
              !previous.openOffer && current.openOffer,
          listener: (context, _) async {
            final cubit = context.read<OrderWaitingCubit>();
            await context.push(Routes.offerOf(orderId));
            await cubit.refresh();
          },
          builder: (context, state) {
            final order = state.order;
            final error = state.error;
            final advanceError = state.advanceError;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BarqHeader(
                  title: order == null ? null : l10n.orderTitle(order.code),
                  back: true,
                  onBack: () => context.go(Routes.home),
                ),
                Expanded(
                  child: state.loading
                      ? const BarqLoadingView()
                      : order == null
                      ? BarqMessageView(
                          title: error ?? l10n.orderWaitingTitle,
                          icon: BarqIcons.alert,
                          actionLabel: l10n.commonRetry,
                          onAction: context.read<OrderWaitingCubit>().refresh,
                        )
                      : Padding(
                          padding: const EdgeInsets.all(BarqSpacing.page),
                          child: BarqGap(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              OrderStatusPill(order.statusKey),
                              Text(
                                l10n.orderWaitingTitle,
                                textAlign: TextAlign.center,
                                style: BarqText.body,
                              ),
                              if (advanceError != null)
                                BarqNote(
                                  advanceError,
                                  icon: BarqIcons.alert,
                                  tone: BarqNoteTone.danger,
                                ),
                              if (_sandbox && !order.isTerminal)
                                BarqButton(
                                  label: l10n.orderSandboxAdvance,
                                  variant: BarqButtonVariant.light,
                                  loading: state.advancing,
                                  onPressed: context
                                      .read<OrderWaitingCubit>()
                                      .advanceInSandbox,
                                ),
                            ],
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
