import 'dart:async';

import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../jobs/data/jobs_repository.dart';
import '../data/earnings_models.dart';
import '../data/earnings_repository.dart';

class EarningsState {
  const EarningsState({
    this.period = EarningsPeriod.week,
    this.loading = true,
    this.error,
    this.earnings,
    this.cash,
  });

  final EarningsPeriod period;
  final bool loading;
  final String? error;
  final Earnings? earnings;
  final CashSummary? cash;
}

class EarningsCubit extends Cubit<EarningsState> {
  EarningsCubit({required this._earnings, required JobsRepository jobs})
    : super(const EarningsState()) {
    _changes = jobs.changes.listen((_) => load());
  }

  final EarningsRepository _earnings;
  late final StreamSubscription<void> _changes;

  /// A request can end after the user left the screen.
  @override
  void emit(EarningsState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> load() => _load(state.period);

  Future<void> choose(EarningsPeriod period) => _load(period);

  Future<void> _load(EarningsPeriod period) async {
    emit(
      EarningsState(
        period: period,
        loading: state.earnings == null,
        earnings: state.earnings,
        cash: state.cash,
      ),
    );
    try {
      final results = await (_earnings.earnings(period), _earnings.cash()).wait;
      if (state.period != period) return;
      emit(
        EarningsState(
          period: period,
          loading: false,
          earnings: results.$1,
          cash: results.$2,
        ),
      );
    } on ParallelWaitError<dynamic, dynamic> catch (e) {
      final failure = [e.errors.$1, e.errors.$2].whereType<ApiException>();
      emit(
        EarningsState(
          period: period,
          loading: false,
          error: failure.first.userMessage,
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _changes.cancel();
    return super.close();
  }
}
