import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/orders_models.dart';
import '../state/order_waiting_cubit.dart';
import 'order_format.dart';
import 'widgets/cancel_order_sheet.dart';

/// `/orders/{id}`: every way into an order lands here, and it moves on to the
/// offer, tracking or rating screen as the order's status says.
class OrderWaitingScreen extends StatelessWidget {
  const OrderWaitingScreen({super.key, required this.orderId});

  final int orderId;

  /// With no store app, this button plays the store's next step.
  static bool get _sandbox =>
      kDebugMode && BarqEnv.projectKey.startsWith('pk_test_');

  Future<void> _follow(BuildContext context, OrderWaitingState state) async {
    final cubit = context.read<OrderWaitingCubit>();
    final order = state.order;
    if (order == null) return;
    if (state.openOffer) {
      await context.push(Routes.offerOf(orderId));
      await cubit.refresh();
      return;
    }
    final config = ConfigScope.of(context).config;
    switch (stageOf(config, order.statusKey)) {
      case OrderStage.tracking:
        context.go(Routes.trackOf(orderId));
      case OrderStage.delivered:
        context.go(
          order.rated ? Routes.receiptOf(orderId) : Routes.rateOf(orderId),
        );
      case OrderStage.waiting:
      case OrderStage.cancelled:
        break;
    }
  }

  /// Every order starts before the first row, and that row is what the
  /// customer is waiting for, so it is the one shown as "now".
  String _timelineStatus(AppConfig config, String statusKey) {
    final first = OrderTimelines.waiting.first;
    return config.status(statusKey).step < config.status(first).step
        ? first
        : statusKey;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DesignOverlay(
      image: 'design/04_order_status_01.png',
      child: BarqScreen(
        body: BlocConsumer<OrderWaitingCubit, OrderWaitingState>(
          listenWhen: (previous, current) =>
              (!previous.openOffer && current.openOffer) ||
              previous.order?.statusKey != current.order?.statusKey,
          listener: _follow,
          builder: (context, state) {
            final order = state.order;
            final error = state.error;
            final support = ConfigScope.of(context).config.supportPhone;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (order == null)
                  BarqHeader(
                    back: true,
                    onBack: () => context.go(Routes.orders),
                  ),
                Expanded(
                  child: state.loading
                      ? const BarqStatePageSkeleton()
                      : order == null
                      ? BarqMessageView(
                          title: error ?? l10n.commonRetry,
                          icon: BarqIcons.alert,
                          actionLabel: l10n.commonRetry,
                          onAction: context.read<OrderWaitingCubit>().refresh,
                        )
                      : _body(context, state, order, support),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    OrderWaitingState state,
    Order order,
    String? support,
  ) {
    final l10n = AppLocalizations.of(context);
    final config = ConfigScope.of(context).config;
    final cubit = context.read<OrderWaitingCubit>();
    final cancel = order.action('cancel');
    final advanceError = state.advanceError;
    final store = order.vendorName;
    final cancelled = stageOf(config, order.statusKey) == OrderStage.cancelled;
    return BarqFillScroll(
      padding: const EdgeInsets.only(bottom: BarqSpacing.stateBottom),
      footer: Padding(
        padding: const EdgeInsets.fromLTRB(
          BarqSpacing.page,
          BarqSpacing.section,
          BarqSpacing.page,
          0,
        ),
        child: BarqGap(
          gap: BarqSpacing.md,
          children: [
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
                onPressed: cubit.advanceInSandbox,
              ),
            if (cancel != null)
              BarqButton(
                label: cancel.label,
                variant: BarqButtonVariant.softRed,
                onPressed: () async {
                  final cancelled = await showCancelOrderSheet(
                    context,
                    orderId,
                  );
                  if (cancelled) await cubit.refresh();
                },
              ),
          ],
        ),
      ),
      children: [
        BarqHeader(
          title: l10n.orderTitle(order.code),
          back: true,
          onBack: () => context.go(Routes.orders),
          trailing: support == null
              ? null
              : BarqIconButton(
                  icon: BarqIcons.help,
                  onPressed: () => callOrShow(context, support),
                ),
        ),
        const BarqWaitingArt(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: BarqSpacing.page),
          child: BarqGap(
            gap: BarqSpacing.xs,
            children: [
              Text(
                config.status(order.statusKey).label,
                textAlign: TextAlign.center,
                style: BarqText.h1,
              ),
              Text(
                cancelled
                    ? l10n.orderCancelledBody
                    : store == null
                    ? l10n.orderWaitingBodyPlain
                    : l10n.orderWaitingBody(store),
                textAlign: TextAlign.center,
                style: BarqText.body,
              ),
              const SizedBox(height: BarqSpacing.md),
              BarqCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: BarqSpacing.section,
                  vertical: BarqSpacing.sm,
                ),
                child: OrderStatusTimeline(
                  keys: OrderTimelines.waiting,
                  current: _timelineStatus(config, order.statusKey),
                  currentTrailing: order.isTerminal
                      ? null
                      : BarqPill(l10n.orderNow, tone: BarqPillTone.orange),
                ),
              ),
              if (!cancelled) ...[
                const SizedBox(height: BarqSpacing.xs),
                BarqNote(
                  l10n.orderPhotoNote,
                  icon: BarqIcons.camera,
                  tone: BarqNoteTone.orange,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
