import 'dart:async';

import 'package:barq_core/barq_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../earnings/data/earnings_models.dart';
import '../../earnings/data/earnings_repository.dart';
import '../../jobs/data/jobs_repository.dart';
import '../data/history_repository.dart';

/// The endpoint has no filter, so this happens in the app.
enum HistoryFilter { all, delivered, cancelled }

class HistoryState {
  const HistoryState({
    this.loading = true,
    this.error,
    this.orders = const [],
    this.filter = HistoryFilter.all,
    this.today,
    this.nextPage,
    this.loadingMore = false,
  });

  final bool loading;
  final String? error;

  /// Everything loaded so far, before the filter.
  final List<HistoryOrder> orders;
  final HistoryFilter filter;
  final Earnings? today;
  final int? nextPage;
  final bool loadingMore;

  List<HistoryOrder> get shown => switch (filter) {
    HistoryFilter.all => orders,
    HistoryFilter.delivered => orders.where((o) => o.isDelivered).toList(),
    HistoryFilter.cancelled => orders.where((o) => !o.isDelivered).toList(),
  };

  HistoryState copyWith({
    bool? loading,
    List<HistoryOrder>? orders,
    HistoryFilter? filter,
    Earnings? today,
    int? nextPage,
    bool? loadingMore,
  }) => HistoryState(
    loading: loading ?? this.loading,
    orders: orders ?? this.orders,
    filter: filter ?? this.filter,
    today: today ?? this.today,
    nextPage: nextPage,
    loadingMore: loadingMore ?? false,
  );
}

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit({
    required this._history,
    required this._earnings,
    required JobsRepository jobs,
  }) : super(const HistoryState()) {
    _changes = jobs.changes.listen((_) => load());
  }

  final HistoryRepository _history;
  final EarningsRepository _earnings;
  late final StreamSubscription<void> _changes;

  /// A request can end after the user left the screen.
  @override
  void emit(HistoryState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> load() async {
    emit(HistoryState(filter: state.filter));
    try {
      final page = await _history.history();
      final today = await _earnings.earnings(EarningsPeriod.day);
      emit(
        HistoryState(
          loading: false,
          orders: page.items,
          filter: state.filter,
          today: today,
          nextPage: page.nextPage,
        ),
      );
      await _fillFilter();
    } on ApiException catch (e) {
      emit(
        HistoryState(
          loading: false,
          filter: state.filter,
          error: e.userMessage,
        ),
      );
    }
  }

  Future<void> choose(HistoryFilter filter) async {
    emit(state.copyWith(filter: filter, nextPage: state.nextPage));
    await _fillFilter();
  }

  /// A filter can hide a whole page, leaving nothing to scroll for more.
  Future<void> _fillFilter() async {
    while (state.shown.isEmpty && state.nextPage != null && !isClosed) {
      final before = state.nextPage;
      await loadMore();
      if (state.nextPage == before) return;
    }
  }

  Future<void> loadMore() async {
    final next = state.nextPage;
    if (next == null || state.loadingMore) return;
    emit(state.copyWith(nextPage: next, loadingMore: true));
    try {
      final page = await _history.history(page: next);
      emit(
        state.copyWith(
          orders: [...state.orders, ...page.items],
          nextPage: page.nextPage,
        ),
      );
    } on ApiException catch (e) {
      debugPrint('More history failed: $e');
      emit(state.copyWith(nextPage: next));
    }
  }

  @override
  Future<void> close() async {
    await _changes.cancel();
    return super.close();
  }
}
