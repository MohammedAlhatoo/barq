import 'package:barq_core/barq_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/notifications_repository.dart';

class NotificationsState {
  const NotificationsState({
    this.loading = true,
    this.error,
    this.items = const [],
    this.nextPage,
    this.loadingMore = false,
    this.notice,
  });

  final bool loading;
  final String? error;
  final List<DriverNotification> items;
  final int? nextPage;
  final bool loadingMore;
  final String? notice;

  bool get hasUnread => items.any((item) => item.isUnread);
}

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._repository) : super(const NotificationsState());

  final NotificationsRepository _repository;

  /// A request can end after the user left the screen.
  @override
  void emit(NotificationsState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> load() async {
    emit(const NotificationsState());
    try {
      final page = await _repository.list();
      emit(
        NotificationsState(
          loading: false,
          items: page.items,
          nextPage: page.nextPage,
        ),
      );
    } on ApiException catch (e) {
      emit(NotificationsState(loading: false, error: e.userMessage));
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
      final page = await _repository.list(page: next);
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
      await _repository.readAll();
      await load();
    } on ApiException catch (e) {
      emit(
        NotificationsState(
          loading: false,
          items: state.items,
          nextPage: state.nextPage,
          notice: e.userMessage,
        ),
      );
    }
  }

  /// A failed report must not stop the driver from reaching the order.
  Future<void> open(DriverNotification item) async {
    try {
      await _repository.opened(item.id);
    } on ApiException catch (e) {
      debugPrint('Notification not reported as opened: $e');
    }
  }
}
