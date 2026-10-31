import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/job_models.dart';
import '../data/jobs_repository.dart';

enum OfferResult { accepted, ignored, taken, cashLimit }

class OfferState {
  const OfferState({
    this.loading = true,
    this.error,
    this.job,
    this.busy = false,
    this.notice,
    this.result,
  });

  final bool loading;
  final String? error;
  final Job? job;

  /// True while accepting or ignoring.
  final bool busy;
  final String? notice;
  final OfferResult? result;
}

class OfferCubit extends Cubit<OfferState> {
  OfferCubit(this._repository, this._id) : super(const OfferState());

  final JobsRepository _repository;
  final int _id;

  /// A request can end after the user left the screen.
  @override
  void emit(OfferState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> load() async {
    emit(const OfferState());
    try {
      emit(OfferState(loading: false, job: await _repository.job(_id)));
    } on ApiException catch (e) {
      emit(OfferState(loading: false, error: e.userMessage));
    }
  }

  Future<void> accept() async {
    if (state.busy) return;
    emit(OfferState(loading: false, job: state.job, busy: true));
    try {
      await _repository.accept(_id);
      _finish(OfferResult.accepted);
    } on ApiException catch (e) {
      switch (e.code) {
        case 'already_taken':
          _finish(OfferResult.taken);
        case 'cash_limit_reached':
          _finish(OfferResult.cashLimit);
        default:
          emit(
            OfferState(loading: false, job: state.job, notice: e.userMessage),
          );
      }
    }
  }

  Future<void> ignore() async {
    if (state.busy) return;
    emit(OfferState(loading: false, job: state.job, busy: true));
    try {
      await _repository.reject(_id);
      _finish(OfferResult.ignored);
    } on ApiException catch (e) {
      emit(OfferState(loading: false, job: state.job, notice: e.userMessage));
    }
  }

  void _finish(OfferResult result) =>
      emit(OfferState(loading: false, job: state.job, result: result));
}
