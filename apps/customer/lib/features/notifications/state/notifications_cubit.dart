import 'package:barq_core/barq_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../orders/data/orders_models.dart';
import '../../orders/data/orders_repository.dart';
import 'unread_cubit.dart';

class NotificationsState {
  const NotificationsState({
    this.loading = true,
    this.error,
    this.items = const [],
    this.nextPage,
    this.loadingMore = false,
    this.readError,
  });

  final bool loading;
  final String? error;
  final List<AppNotification> items;
  final int? nextPage;
  final bool loadingMore;
  final String? readError;

  bool get hasUnread => items.any((item) => item.readAt == null);
}

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({required this._repository, required this._unread})
    : super(const NotificationsState());

  final OrdersRepository _repository;
  final UnreadCubit _unread;

  /// A request can end after the user left the screen.
  @override
  void emit(NotificationsState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> load() async {
    emit(const NotificationsState());
    try {
      final page = await _repository.notifications();
      emit(
        NotificationsState(
          loading: false,
          items: page.items,
          nextPage: page.nextPage,
        ),
      );
    } on ApiException catch (e) {
      emit(NotificationsState(loading: false, error: e.messageAr));
    }
  }

  Future<void> loadMore() async {
    final next = state.nextPage;
    if (next == null || state.loadingMore) return;
    emit(
      NotificationsState(
        loading: false,
        items: state.items,
        nextPage: next,
        loadingMore: true,
      ),
    );
    try {
      final page = await _repository.notifications(page: next);
      emit(
        NotificationsState(
          loading: false,
          items: [...state.items, ...page.items],
          nextPage: page.nextPage,
        ),
      );
    } on ApiException catch (e) {
      debugPrint('More notifications failed: $e');
      emit(
        NotificationsState(loading: false, items: state.items, nextPage: next),
      );
    }
  }

  Future<void> readAll() async {
    try {
      await _repository.readAllNotifications();
      _unread.clear();
      await load();
    } on ApiException catch (e) {
      emit(
        NotificationsState(
          loading: false,
          items: state.items,
          nextPage: state.nextPage,
          readError: e.messageAr,
        ),
      );
    }
  }

  /// Tells the server, and answers the order to open. A failed report must not
  /// stop the user from reaching the order.
  Future<int?> open(AppNotification item) async {
    try {
      await _repository.notificationOpened(item.id);
      await _unread.refresh();
    } on ApiException catch (e) {
      debugPrint('Notification not reported as opened: $e');
    }
    return orderIdOf(item.data);
  }
}
