import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../jobs/data/job_models.dart';
import '../../jobs/data/jobs_repository.dart';

class TaskState {
  const TaskState({
    this.loading = true,
    this.error,
    this.job,
    this.submitting = false,
    this.notice,
  });

  final bool loading;

  /// The first load failed, so there is no job to show.
  final String? error;

  /// Null after loading means no current job.
  final Job? job;
  final bool submitting;

  /// A step was refused: shown above the button.
  final String? notice;
}

/// The current job. Keeps asking the server, because the order can be
/// cancelled while the driver is on the way.
class TaskCubit extends Cubit<TaskState> {
  TaskCubit({required this._jobs, required this._pollSeconds})
    : super(const TaskState());

  static const _defaultPollSeconds = 30;

  final JobsRepository _jobs;
  final int? Function() _pollSeconds;
  Poller? _poller;

  /// A request can end after the user left the screen.
  @override
  void emit(TaskState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> load() async {
    emit(TaskState(job: state.job, loading: state.job == null));
    try {
      emit(TaskState(loading: false, job: await _jobs.current()));
      _poller ??= Poller(
        tick: _tick,
        defaultSeconds: _pollSeconds() ?? _defaultPollSeconds,
      )..start();
    } on ApiException catch (e) {
      emit(TaskState(loading: false, job: state.job, error: e.userMessage));
    }
  }

  Future<int?> _tick() async {
    if (state.submitting) return null;
    final job = await _jobs.current();
    emit(TaskState(loading: false, job: job, notice: state.notice));
    return null;
  }

  /// Sends `next_action.to`. The server answers with the following step.
  Future<void> advance({List<int>? uploadIds}) async {
    final job = state.job;
    final next = job?.nextAction;
    if (job == null || next == null || state.submitting) return;
    emit(TaskState(loading: false, job: job, submitting: true));
    try {
      final updated = await _jobs.transition(
        job.id,
        to: next.to,
        uploadIds: uploadIds,
      );
      emit(TaskState(loading: false, job: updated));
    } on ApiException catch (e) {
      if (e.code == 'invalid_transition') {
        // The order moved on without us: show where it is now.
        emit(TaskState(loading: false, job: job, notice: e.userMessage));
        await _reload();
      } else {
        emit(TaskState(loading: false, job: job, notice: e.userMessage));
      }
    }
  }

  Future<void> _reload() async {
    final notice = state.notice;
    try {
      emit(
        TaskState(loading: false, job: await _jobs.current(), notice: notice),
      );
    } on ApiException catch (e) {
      emit(TaskState(loading: false, job: state.job, notice: e.userMessage));
    }
  }

  @override
  Future<void> close() {
    _poller?.stop();
    return super.close();
  }
}
