import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/orders_models.dart';
import '../state/tracking_cubit.dart';
import 'order_format.dart';
import 'widgets/cancel_order_sheet.dart';
import 'widgets/tracking_map.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key, required this.orderId});

  final int orderId;

  /// About as tall as the sheet, so the camera keeps the pins above it.
  static const _sheetHeight = 340.0;

  void _follow(BuildContext context, TrackingState state) {
    final statusKey = state.tracking?.statusKey;
    if (statusKey == null) return;
    final config = ConfigScope.of(context).config;
    switch (stageOf(config, statusKey)) {
      case OrderStage.delivered:
        context.go(
          state.order?.rated == true
              ? Routes.receiptOf(orderId)
              : Routes.rateOf(orderId),
        );
      case OrderStage.cancelled:
        context.go(Routes.orderOf(orderId));
      case OrderStage.waiting:
      case OrderStage.tracking:
        break;
    }
  }

  Future<void> _share(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<TrackingCubit>();
    final actions = context.read<AppDependencies>().vendorActions;
    final link = await cubit.createShareLink();
    if (link == null || !context.mounted) return;
    await showBarqSheet<void>(
      context,
      children: [
        Text(l10n.trackingShare, style: BarqText.h2),
        Text(l10n.shareLinkBody, style: BarqText.body),
        BarqButton(
          label: l10n.shareLinkSend,
          icon: BarqIcons.share,
          onPressed: () => actions.share(link.url),
        ),
        BarqButton(
          label: l10n.shareLinkStop,
          variant: BarqButtonVariant.softRed,
          onPressed: () {
            cubit.stopShareLink();
            closeBarqSheet<void>(context);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DesignOverlay(
      image: 'design/04_order_status_04.png',
      child: BarqScreen(
        body: BlocConsumer<TrackingCubit, TrackingState>(
          listenWhen: (previous, current) =>
              previous.tracking?.statusKey != current.tracking?.statusKey,
          listener: _follow,
          builder: (context, state) {
            final tracking = state.tracking;
            final error = state.error;
            if (tracking == null) {
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
                            onAction: context.read<TrackingCubit>().load,
                          ),
                  ),
                ],
              );
            }
            return Stack(
              fit: StackFit.expand,
              children: [
                TrackingMap(tracking: tracking, bottomInset: _sheetHeight),
                PositionedDirectional(
                  top: BarqSpacing.headerTop,
                  start: BarqSpacing.page,
                  end: BarqSpacing.page,
                  child: _topRow(context, state, tracking),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _sheet(context, state, tracking),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _topRow(BuildContext context, TrackingState state, Tracking tracking) {
    final l10n = AppLocalizations.of(context);
    final eta = tracking.etaMinutes;
    final shareable = ConfigScope.of(context).config
        .hasModule('public_tracking');
    return Row(
      children: [
        BarqIconButton(
          icon: BarqIcons.back,
          onPressed: () => context.go(Routes.orders),
        ),
        const SizedBox(width: BarqSpacing.sm),
        Expanded(
          child: eta == null
              ? const SizedBox.shrink()
              : Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: BarqPill(
                      l10n.trackingEta(eta),
                      tone: BarqPillTone.white,
                      icon: BarqIcons.clock,
                    ),
                  ),
                ),
        ),
        if (shareable) ...[
          const SizedBox(width: BarqSpacing.sm),
          BarqIconButton(
            icon: BarqIcons.share,
            tooltip: l10n.trackingShare,
            onPressed: state.sharing ? null : () => _share(context),
          ),
        ],
      ],
    );
  }

  Widget _sheet(BuildContext context, TrackingState state, Tracking tracking) {
    final l10n = AppLocalizations.of(context);
    final config = ConfigScope.of(context).config;
    final cubit = context.read<TrackingCubit>();
    final name = tracking.driverName;
    final phone = tracking.driverPhone;
    final rating = tracking.ratingAverage;
    final cancel = state.order?.action('cancel');
    final shareError = state.shareError;
    return BarqSheet(
      gap: BarqSpacing.gap,
      children: [
        Text(config.status(tracking.statusKey).label, style: BarqText.h2),
        OrderStatusProgress(
          keys: OrderTimelines.tracking,
          current: tracking.statusKey,
          showLabels: true,
        ),
        if (name == null)
          Text(l10n.trackingNoDriver, style: BarqText.body)
        else
          Row(
            children: [
              BarqAvatar(name.characters.first, dark: true),
              const SizedBox(width: BarqSpacing.gap),
              Expanded(
                child: BarqGap(
                  gap: 0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: BarqText.h3),
                    Text(
                      [
                        if (rating != null) '★ ${rating.toStringAsFixed(1)}',
                        vehicleName(l10n, tracking.vehicleType),
                      ].join(' · '),
                      style: BarqText.xs,
                    ),
                  ],
                ),
              ),
              if (phone != null)
                BarqIconButton(
                  icon: BarqIcons.phone,
                  background: BarqColors.primary,
                  iconColor: Colors.white,
                  onPressed: () => callOrShow(context, phone),
                ),
            ],
          ),
        BarqNote(
          l10n.trackingPhotoNote,
          icon: BarqIcons.camera,
          tone: BarqNoteTone.orange,
        ),
        if (shareError != null)
          BarqNote(
            shareError,
            icon: BarqIcons.alert,
            tone: BarqNoteTone.danger,
          ),
        if (cancel != null)
          BarqButton(
            label: cancel.label,
            variant: BarqButtonVariant.softRed,
            onPressed: () async {
              final cancelled = await showCancelOrderSheet(context, orderId);
              if (cancelled) await cubit.load();
            },
          ),
      ],
    );
  }
}
