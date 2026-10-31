import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/orders_models.dart';
import '../state/rate_cubit.dart';
import 'order_format.dart';

class RateScreen extends StatefulWidget {
  const RateScreen({super.key});

  @override
  State<RateScreen> createState() => _RateScreenState();
}

class _RateScreenState extends State<RateScreen> {
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  String _summary(Order order) {
    final l10n = AppLocalizations.of(context);
    final completed = order.completedAt;
    final discount = order.discount;
    return [
      if (completed != null)
        l10n.rateDeliveredAt(formatTime(context, completed)),
      l10n.ratePaid(order.total.formatted),
      if (discount.amount > 0) l10n.rateSaved(discount.formatted),
    ].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DesignOverlay(
      image: 'design/05_after_order_02.png',
      child: BarqScreen(
        body: BlocConsumer<RateCubit, RateState>(
          listenWhen: (previous, current) => !previous.done && current.done,
          listener: (context, _) => context.go(Routes.orders),
          builder: (context, state) {
            final order = state.order;
            final error = state.error;
            if (order == null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BarqHeader(
                    back: true,
                    onBack: () => context.go(Routes.orders),
                  ),
                  Expanded(
                    child: state.loading
                        ? const BarqLoadingView()
                        : BarqMessageView(
                            title: error ?? l10n.commonRetry,
                            icon: BarqIcons.alert,
                            actionLabel: l10n.commonRetry,
                            onAction: context.read<RateCubit>().load,
                          ),
                  ),
                ],
              );
            }
            return _body(context, state, order);
          },
        ),
      ),
    );
  }

  Widget _body(BuildContext context, RateState state, Order order) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<RateCubit>();
    final sendError = state.sendError;
    final driver = order.driverName;
    return BarqFillScroll(
      padding: const EdgeInsets.fromLTRB(
        BarqSpacing.page,
        BarqSpacing.headerTop,
        BarqSpacing.page,
        BarqSpacing.stateBottom,
      ),
      footer: Padding(
        padding: const EdgeInsets.only(top: BarqSpacing.section),
        child: BarqGap(
          gap: BarqSpacing.xs,
          children: [
            if (sendError != null)
              BarqNote(
                sendError,
                icon: BarqIcons.alert,
                tone: BarqNoteTone.danger,
              ),
            BarqButton(
              label: l10n.rateSend,
              loading: state.sending,
              onPressed: state.canSend ? () => cubit.send(_comment.text) : null,
            ),
            Center(
              child: BarqLink(
                l10n.rateSkip,
                onPressed: () => context.go(Routes.orders),
              ),
            ),
          ],
        ),
      ),
      children: [
        const BarqDeliveredArt(),
        Text(
          l10n.rateDeliveredTitle,
          textAlign: TextAlign.center,
          style: BarqText.h1,
        ),
        const SizedBox(height: BarqSpacing.xs),
        Text(
          _summary(order),
          textAlign: TextAlign.center,
          style: BarqText.body,
        ),
        const SizedBox(height: BarqSpacing.section),
        BarqCard(
          child: BarqGap(
            gap: BarqSpacing.gap,
            children: [
              Text(
                l10n.rateTitle,
                textAlign: TextAlign.center,
                style: BarqText.h3,
              ),
              _StarsRow(
                leading: BarqAvatar(
                  driver == null || driver.isEmpty
                      ? l10n.rateDriver.characters.first
                      : driver.characters.first,
                  dark: true,
                  size: BarqSizes.iconTile,
                ),
                label: l10n.rateDriver,
                value: state.driverStars,
                onChanged: cubit.setDriverStars,
              ),
              const BarqDivider(),
              _StarsRow(
                leading: const BarqIllustration(
                  BarqIllustrations.storefront,
                  width: BarqSizes.iconTile,
                  height: BarqSizes.iconTile,
                ),
                label: l10n.rateStore,
                value: state.storeStars,
                onChanged: cubit.setStoreStars,
              ),
              BarqInput(
                controller: _comment,
                hint: l10n.rateComment,
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StarsRow extends StatelessWidget {
  const _StarsRow({
    required this.leading,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final Widget leading;
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      leading,
      const SizedBox(width: BarqSpacing.sm),
      Expanded(child: Text(label, style: BarqText.tBold)),
      BarqStars(value: value, onChanged: onChanged),
    ],
  );
}
