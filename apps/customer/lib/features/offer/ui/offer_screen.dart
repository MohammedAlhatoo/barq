import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/countdown.dart';
import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/offer_models.dart';
import '../state/offer_cubit.dart';
import 'widgets/offer_expired_view.dart';
import 'widgets/offer_item_row.dart';

class OfferScreen extends StatelessWidget {
  const OfferScreen({super.key, required this.orderId});

  final int orderId;

  void _leave(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.orderOf(orderId));
    }
  }

  Future<void> _confirmReject(BuildContext context, OrderAction action) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<OfferCubit>();
    final reject = await showBarqSheet<bool>(
      context,
      children: [
        Text(action.confirm ?? action.label, style: BarqText.h2),
        BarqButton(
          label: action.label,
          variant: BarqButtonVariant.red,
          onPressed: () => closeBarqSheet(context, true),
        ),
        BarqButton(
          label: l10n.commonCancel,
          variant: BarqButtonVariant.light,
          onPressed: () => closeBarqSheet(context, false),
        ),
      ],
    );
    if (reject == true) await cubit.reject();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<OfferCubit, OfferState>(
      listenWhen: (previous, current) => !previous.answered && current.answered,
      listener: (context, _) => _leave(context),
      builder: (context, state) {
        final offer = state.offer;
        final order = state.order;
        if (offer != null && order != null && offer.isExpired) {
          return OfferExpiredView(order: order, offer: offer);
        }
        if (offer != null && order != null && offer.isOpen) {
          return DesignOverlay(
            image: 'design/04_order_status_02.png',
            child: BarqScreen(body: _offer(context, state, order, offer)),
          );
        }
        final error = state.error;
        return DesignOverlay(
          image: 'design/04_order_status_02.png',
          child: BarqScreen(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BarqHeader(title: l10n.offerTitle, back: true),
                Expanded(
                  child: state.loading
                      ? const BarqLoadingView()
                      : error != null
                      ? BarqMessageView(
                          title: error,
                          icon: BarqIcons.alert,
                          actionLabel: l10n.commonRetry,
                          onAction: context.read<OfferCubit>().load,
                        )
                      : BarqMessageView(
                          title: l10n.offerNotReadyTitle,
                          message: l10n.offerNotReadyBody,
                          icon: BarqIcons.clock,
                          actionLabel: l10n.commonRetry,
                          onAction: context.read<OfferCubit>().load,
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _offer(
    BuildContext context,
    OfferState state,
    OrderInfo order,
    Offer offer,
  ) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<OfferCubit>();
    final cancel = order.cancelAction;
    final minutes = offer.minutesToAnswer;
    final note = offer.note;
    final actionError = state.actionRefused
        ? l10n.offerActionRefused
        : state.actionError;
    final discount = order.discount;
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
            if (actionError != null)
              BarqNote(
                actionError,
                icon: BarqIcons.alert,
                tone: BarqNoteTone.danger,
              ),
            BarqButton(
              label: l10n.offerApprove,
              icon: BarqIcons.check,
              variant: BarqButtonVariant.green,
              loading: state.approving,
              onPressed: state.busy ? null : cubit.approve,
            ),
            if (cancel != null)
              BarqButton(
                label: cancel.label,
                variant: BarqButtonVariant.softRed,
                loading: state.rejecting,
                onPressed: state.busy
                    ? null
                    : () => _confirmReject(context, cancel),
              ),
          ],
        ),
      ),
      children: [
        BarqHeader(
          title: l10n.offerTitle,
          back: true,
          trailing: BarqPill(
            formatCountdown(state.secondsLeft),
            tone: BarqPillTone.dark,
            icon: BarqIcons.clock,
          ),
        ),
        BarqGap(
          gap: BarqSpacing.md,
          padding: const EdgeInsets.fromLTRB(
            BarqSpacing.page,
            BarqSpacing.section,
            BarqSpacing.page,
            0,
          ),
          children: [
            _PricedCard(storeName: order.vendorName),
            for (final (index, item) in offer.items.indexed)
              BarqStaggerItem(
                group: 'offer-items',
                index: index,
                child: OfferItemRow(item: item),
              ),
            if (note != null && note.isNotEmpty)
              BarqNote(l10n.offerStoreNote(note), icon: BarqIcons.chat),
            BarqCard(
              padding: const EdgeInsets.symmetric(
                horizontal: BarqSpacing.section,
                vertical: BarqSpacing.gap,
              ),
              child: BarqGap(
                gap: BarqSpacing.xs,
                children: [
                  BarqSummaryRow(
                    l10n.offerItemsTotal,
                    offer.itemsTotal.formatted,
                  ),
                  BarqSummaryRow(
                    l10n.offerDelivery,
                    offer.deliveryFee.formatted,
                  ),
                  if (discount != null)
                    BarqSummaryRow(
                      discount.label,
                      discount.price.formatted,
                      valueColor: BarqColors.successText,
                    ),
                  const BarqDivider(),
                  BarqSummaryRow(
                    l10n.checkoutTotal,
                    offer.total.formatted,
                    total: true,
                  ),
                ],
              ),
            ),
            if (minutes != null)
              BarqNote(l10n.offerDeadline(minutes), tone: BarqNoteTone.warning),
          ],
        ),
      ],
    );
  }
}

class _PricedCard extends StatelessWidget {
  const _PricedCard({required this.storeName});

  final String? storeName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = storeName;
    return BarqCard(
      padding: const EdgeInsets.symmetric(
        horizontal: BarqSpacing.section,
        vertical: BarqSpacing.gap,
      ),
      child: Row(
        children: [
          const BarqIllustration(
            BarqIllustrations.storefront,
            width: BarqSizes.offerStore,
            height: BarqSizes.offerStore,
          ),
          const SizedBox(width: BarqSpacing.gap),
          Expanded(
            child: BarqGap(
              gap: 0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.offerPricedTitle, style: BarqText.h3),
                Text(
                  name == null
                      ? l10n.offerPricedBody
                      : '$name · ${l10n.offerPricedBody}',
                  style: BarqText.xs,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
