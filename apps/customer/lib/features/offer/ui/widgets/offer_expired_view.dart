import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../orders/ui/reorder_flow.dart';
import '../../data/offer_models.dart';
import '../../state/offer_cubit.dart';

/// The store's offer was not answered in time, so the server cancelled it.
class OfferExpiredView extends StatelessWidget {
  const OfferExpiredView({super.key, required this.order, required this.offer});

  final OrderInfo order;
  final Offer offer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<OfferCubit>().state;
    final minutes = offer.minutesToAnswer;
    final actionError = state.actionError;
    return DesignOverlay(
      image: 'design/04_order_status_03.png',
      child: BarqScreen(
        body: BarqFillScroll(
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
                if (order.vendorId != null)
                  BarqButton(
                    label: l10n.offerExpiredReorder,
                    icon: BarqIcons.refresh,
                    loading: state.reordering,
                    onPressed: () => reorderToCart(
                      context,
                      context.read<OfferCubit>().reorder,
                    ),
                  ),
                BarqButton(
                  label: l10n.offerExpiredHome,
                  variant: BarqButtonVariant.white,
                  onPressed: () => context.go(Routes.home),
                ),
              ],
            ),
          ),
          children: [
            BarqHeader(
              title: l10n.orderTitle(order.code),
              back: true,
              onBack: () => context.go(Routes.home),
            ),
            BarqOfferExpiredArt(label: l10n.offerExpiredPill),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: BarqSpacing.page),
              child: BarqGap(
                gap: BarqSpacing.sm,
                children: [
                  Text(
                    l10n.offerExpiredTitle,
                    textAlign: TextAlign.center,
                    style: BarqText.h1,
                  ),
                  Text(
                    minutes == null
                        ? l10n.offerExpiredBodyPlain
                        : l10n.offerExpiredBody(minutes),
                    textAlign: TextAlign.center,
                    style: BarqText.body,
                  ),
                  const SizedBox(height: BarqSpacing.gap),
                  BarqCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: BarqSpacing.section,
                      vertical: BarqSpacing.gap,
                    ),
                    child: Row(
                      children: [
                        const BarqIllustration(
                          BarqIllustrations.storefront,
                          width: BarqSizes.iconTile,
                          height: BarqSizes.iconTile,
                        ),
                        const SizedBox(width: BarqSpacing.gap),
                        Expanded(
                          child: BarqGap(
                            gap: 0,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.vendorName ?? order.code,
                                style: BarqText.h3,
                              ),
                              Text(
                                l10n.offerExpiredSummary(
                                  order.items.length,
                                  order.total.formatted,
                                ),
                                style: BarqText.xs,
                              ),
                            ],
                          ),
                        ),
                        OrderStatusPill(order.statusKey),
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
  }
}
