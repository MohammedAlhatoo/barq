import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../cart/state/cart_cubit.dart';
import '../../data/offer_models.dart';
import '../../state/offer_cubit.dart';

/// The store's offer was not answered in time, so the server cancelled it.
class OfferExpiredView extends StatelessWidget {
  const OfferExpiredView({super.key, required this.order, required this.offer});

  final OrderInfo order;
  final Offer offer;

  Future<void> _reorder(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final router = GoRouter.of(context);
    final cubit = context.read<OfferCubit>();
    if (!context.read<CartCubit>().state.isEmpty) {
      final replace = await showBarqSheet<bool>(
        context,
        children: [
          Text(l10n.reorderReplaceTitle, style: BarqText.h2),
          Text(l10n.reorderReplaceBody, style: BarqText.body),
          BarqButton(
            label: l10n.reorderReplaceConfirm,
            onPressed: () => closeBarqSheet(context, true),
          ),
          BarqButton(
            label: l10n.commonKeepCart,
            variant: BarqButtonVariant.light,
            onPressed: () => closeBarqSheet(context, false),
          ),
        ],
      );
      if (replace != true) return;
    }
    final missing = await cubit.reorder();
    if (missing == null || !context.mounted) return;
    if (missing > 0) {
      await showBarqSheet<void>(
        context,
        children: [
          Text(l10n.reorderMissing(missing), style: BarqText.h3),
          BarqButton(
            label: l10n.commonOk,
            onPressed: () => closeBarqSheet<void>(context),
          ),
        ],
      );
    }
    router
      ..go(Routes.home)
      ..push(Routes.cart);
  }

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
                    onPressed: () => _reorder(context),
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
