import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/di.dart';
import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/notifications_repository.dart';
import '../state/notifications_cubit.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _loadMoreThreshold = 300.0;

  /// Opens the job when the notification is about the current one.
  Future<void> _open(BuildContext context, DriverNotification item) async {
    final jobs = context.read<AppDependencies>().jobsRepository;
    await context.read<NotificationsCubit>().open(item);
    final orderId = orderIdOf(item.data);
    if (orderId == null) return;
    try {
      final current = await jobs.current();
      if (context.mounted && current?.id == orderId) {
        await context.push(Routes.task);
      }
    } on ApiException catch (e) {
      debugPrint('Current job not checked: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<NotificationsCubit>();
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) => DesignOverlay(
        image: 'design/09_driver_delivery_06.png',
        child: BarqScreen(
          body: Column(
            children: [
              BarqHeader(
                back: true,
                title: l10n.accountNotifications,
                trailing: state.hasUnread
                    ? BarqLink(
                        l10n.notificationsReadAll,
                        onPressed: cubit.readAll,
                      )
                    : null,
              ),
              Expanded(
                child: state.loading
                    ? const BarqLoadingView()
                    : state.error != null
                    ? BarqMessageView(
                        title: state.error!,
                        icon: BarqIcons.alert,
                        actionLabel: l10n.commonRetry,
                        onAction: cubit.load,
                      )
                    : state.items.isEmpty
                    ? BarqMessageView(
                        title: l10n.notificationsEmptyTitle,
                        message: l10n.notificationsEmptyBody,
                        icon: BarqIcons.bell,
                      )
                    : RefreshIndicator(
                        onRefresh: cubit.load,
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            if (notification.metrics.extentAfter <
                                _loadMoreThreshold) {
                              cubit.loadMore();
                            }
                            return false;
                          },
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(
                              BarqSpacing.page,
                              18,
                              BarqSpacing.page,
                              BarqSpacing.stateBottom,
                            ),
                            children: [
                              if (state.notice != null)
                                BarqNote(
                                  state.notice!,
                                  icon: BarqIcons.alert,
                                  tone: BarqNoteTone.danger,
                                ),
                              for (final item in state.items)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: BarqSpacing.md,
                                  ),
                                  child: _NotificationRow(
                                    item: item,
                                    onTap: () => _open(context, item),
                                  ),
                                ),
                              if (state.loadingMore) const BarqLoadingView(),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.item, required this.onTap});

  final DriverNotification item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final format = DateFormat.jm(locale)..useNativeDigits = false;
    final time = format.format(item.createdAt.toLocal());
    return BarqCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: BarqSpacing.gap,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BarqIconTile(
            BarqIcons.bell,
            tone: item.isUnread ? BarqTileTone.darkOrange : BarqTileTone.orange,
          ),
          const SizedBox(width: BarqSpacing.gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: BarqText.h3.copyWith(color: p.text),
                      ),
                    ),
                    if (item.isUnread) const BarqUnreadDot(),
                  ],
                ),
                Text(
                  '${item.body} · $time',
                  style: BarqText.xs.copyWith(color: p.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
