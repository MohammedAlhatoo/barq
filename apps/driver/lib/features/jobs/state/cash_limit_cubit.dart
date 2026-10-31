import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../earnings/data/earnings_models.dart';
import '../../earnings/data/earnings_repository.dart';

class CashLimitState {
  const CashLimitState({this.loading = true, this.error, this.cash});

  final bool loading;
  final String? error;
  final CashSummary? cash;
}

class CashLimitCubit extends Cubit<CashLimitState> {
  CashLimitCubit(this._repository) : super(const CashLimitState());

  final EarningsRepository _repository;

  /// A request can end after the user left the screen.
  @override
  void emit(CashLimitState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> load() async {
    emit(const CashLimitState());
    try {
      emit(CashLimitState(loading: false, cash: await _repository.cash()));
    } on ApiException catch (e) {
      emit(CashLimitState(loading: false, error: e.userMessage));
    }
  }
}
