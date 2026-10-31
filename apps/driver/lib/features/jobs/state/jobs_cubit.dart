import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../earnings/data/earnings_models.dart';
import '../../earnings/data/earnings_repository.dart';
import '../data/job_models.dart';
import '../data/jobs_repository.dart';

/// Where the screen goes after pressing "قبول".
enum AcceptResult { accepted, cashLimit }

class JobsState {
  const JobsState({
    this.loading = true,
    this.error,
    this.jobs = const [],
    this.today,
    this.acceptingId,
    this.result,
    this.taken = false,
    this.notice,
  });

  final bool loading;
  final String? error;
  final List<Job> jobs;

  /// The earnings banner. Stays null if only this request failed.
  final Earnings? today;
  final int? acceptingId;
  final AcceptResult? result;

  /// Shows "سبقك سائق آخر لهذا الطلب".
  final bool taken;

  /// Any other refusal.
  final String? notice;

  JobsState copyWith({
    bool? loading,
    String? error,
    List<Job>? jobs,
    Earnings? today,
    int? acceptingId,
    AcceptResult? result,
    bool? taken,
    String? notice,
  }) => JobsState(
    loading: loading ?? this.loading,
    error: error,
    jobs: jobs ?? this.jobs,
    today: today ?? this.today,
    acceptingId: acceptingId,
    result: result,
    taken: taken ?? this.taken,
    notice: notice,
  );
}

/// The driver's home: today's earnings, and the nearby orders while online.
class JobsCubit extends Cubit<JobsState> {
  JobsCubit({
    required this._jobs,
    required this._earnings,
    required this._pollSeconds,
  }) : super(const JobsState());

  static const _defaultPollSeconds = 10;

  final JobsRepository _jobs;
  final EarningsRepository _earnings;
  final int? Function() _pollSeconds;
  Poller? _poller;
  bool _online = false;

  /// A request can end after the user left the screen.
  @override
  void emit(JobsState state) {
    if (!isClosed) super.emit(state);
  }

  /// Follows the online switch. Offline, the server answers an empty list.
  Future<void> setOnline(bool online) async {
    _online = online;
    _poller?.stop();
    _poller = null;
    if (online) {
      _poller = Poller(
        tick: _tick,
        defaultSeconds: _pollSeconds() ?? _defaultPollSeconds,
      )..start();
    }
    await load();
  }

  Future<void> load() async {
    emit(state.copyWith(loading: state.today == null && state.jobs.isEmpty));
    try {
      final today = await _earnings.earnings(EarningsPeriod.day);
      final jobs = _online ? await _jobs.available() : const <Job>[];
      emit(state.copyWith(loading: false, today: today, jobs: jobs));
    } on ApiException catch (e) {
      emit(state.copyWith(loading: false, error: e.userMessage));
    }
  }

  Future<int?> _tick() async {
    final jobs = await _jobs.available();
    emit(state.copyWith(jobs: jobs, acceptingId: state.acceptingId));
    return null;
  }

  Future<void> accept(Job job) async {
    if (state.acceptingId != null) return;
    emit(state.copyWith(acceptingId: job.id, taken: false));
    try {
      await _jobs.accept(job.id);
      emit(state.copyWith(result: AcceptResult.accepted));
    } on ApiException catch (e) {
      await _refused(e);
    }
  }

  Future<void> _refused(ApiException e) async {
    if (e.code == 'cash_limit_reached') {
      emit(state.copyWith(result: AcceptResult.cashLimit));
    } else if (e.code == 'already_taken') {
      showTaken();
      await load();
    } else {
      emit(state.copyWith(notice: e.userMessage));
    }
  }

  void showTaken() => emit(state.copyWith(taken: true));

  void clearNotice() => emit(state.copyWith(taken: false));

  @override
  Future<void> close() {
    _poller?.stop();
    return super.close();
  }
}
