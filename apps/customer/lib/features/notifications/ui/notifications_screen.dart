import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../browse/ui/widgets/load_more_listener.dart';
import '../../orders/data/orders_models.dart';
import '../../orders/ui/order_format.dart';
import '../state/notifications_cubit.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  /// Today · yesterday · earlier, in the phone's time.
  int _daysAgo(DateTime date) {
    final now = DateTime.now();
    final local = date.toLocal();
    return DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(local.year, local.month, local.day)).inDays;
  }

  String _section(AppLocalizations l10n, DateTime date) =>
      switch (_daysAgo(date)) {
        <= 0 => l10n.notificationsToday,
        1 => l10n.notificationsYesterday,
        _ => l10n.notificationsEarlier,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DesignOverlay(
      image: 'design/06_account_06.png',
      child: BarqScreen(
        body: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            final cubit = context.read<NotificationsCubit>();
            final error = state.error;
            final readError = state.readError;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BarqHeader(
                  title: l10n.notificationsTitle,
                  back: true,
                  trailing: state.hasUnread
                      ? BarqLink(
                          l10n.notificationsReadAll,
                          onPressed: cubit.readAll,
                        )
                      : null,
                ),
                if (readError != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      BarqSpacing.page,
                      BarqSpacing.md,
                      BarqSpacing.page,
                      0,
                    ),
                    child: BarqNote(
                      readError,
                      icon: BarqIcons.alert,
                      tone: BarqNoteTone.danger,
                    ),
                  ),
                Expanded(
                  child: state.loading
                      ? const BarqLoadingView()
                      : error != null
                      ? BarqMessageView(
                          title: error,
                          icon: BarqIcons.alert,
                          actionLabel: l10n.commonRetry,
                          onAction: cubit.load,
                        )
                      : state.items.isEmpty
                      ? BarqMessageView(
                          title: l10n.notificationsEmpty,
                          icon: BarqIcons.bell,
                        )
                      : LoadMoreListener(
                          onLoadMore: cubit.loadMore,
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(
                              BarqSpacing.page,
                              BarqSpacing.md,
                              BarqSpacing.page,
                              BarqSpacing.stateBottom,
                            ),
                            children: _rows(context, state.items),
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

  List<Widget> _rows(BuildContext context, List<AppNotification> items) {
    final l10n = AppLocalizations.of(context);
    final rows = <Widget>[];
    String? section;
    for (final item in items) {
      final title = _section(l10n, item.createdAt);
      if (title != section) {
        section = title;
        rows.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: BarqSpacing.sm),
            child: Text(title, style: BarqText.xs),
          ),
        );
      }
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: BarqSpacing.sm),
          child: _NotificationCard(item: item),
        ),
      );
    }
    return [
      for (final (index, row) in rows.indexed)
        BarqStaggerItem(group: 'notifications', index: index, child: row),
    ];
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final AppNotification item;

  Future<void> _open(BuildContext context) async {
    final router = GoRouter.of(context);
    final orderId = await context.read<NotificationsCubit>().open(item);
    if (orderId != null) await router.push<void>(Routes.orderOf(orderId));
  }

  @override
  Widget build(BuildContext context) {
    final status = item.data['status'];
    final icon = status is String
        ? ConfigScope.of(context).config.status(status).barqIcon
        : BarqIcons.bell;
    final unread = item.readAt == null;
    return GestureDetector(
      onTap: () => _open(context),
      child: BarqCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BarqIconTile(
              icon,
              tone: unread ? BarqTileTone.orange : BarqTileTone.neutral,
            ),
            const SizedBox(width: BarqSpacing.gap),
            Expanded(
              child: BarqGap(
                gap: BarqSpacing.xs,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(item.title, style: BarqText.h3)),
                      if (unread) const BarqUnreadDot(),
                    ],
                  ),
                  Text(
                    '${item.body} · ${formatAgo(context, item.createdAt)}',
                    style: BarqText.xs,
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
