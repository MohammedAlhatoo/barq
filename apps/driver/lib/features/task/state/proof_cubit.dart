import 'dart:io';

import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../jobs/data/job_models.dart';
import '../../jobs/data/jobs_repository.dart';
import '../data/proof_photo.dart';

class ProofState {
  const ProofState({
    this.photo,
    this.sending = false,
    this.cameraFailed = false,
    this.notice,
    this.tooFar,
    this.done = false,
  });

  final File? photo;
  final bool sending;
  final bool cameraFailed;
  final String? notice;
  final ApiException? tooFar;

  /// The server took the step: the screen closes.
  final bool done;
}

/// One photo step: at the store (`transition`) or at the door (`deliver`).
/// Which one comes from `next_action.action`.
class ProofCubit extends Cubit<ProofState> {
  ProofCubit({
    required this._jobs,
    required this._photos,
    required this.job,
    required this.next,
  }) : super(const ProofState());

  final JobsRepository _jobs;
  final ProofPhotos _photos;
  final Job job;
  final NextAction next;

  /// Kept after a refused step, so "حاول مرة أخرى" does not upload it twice.
  int? _uploadId;

  /// A request can end after the user left the screen.
  @override
  void emit(ProofState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> take() async {
    if (state.sending) return;
    try {
      final photo = await _photos.take();
      if (photo == null) return;
      _uploadId = null;
      emit(ProofState(photo: photo));
    } on CameraFailure {
      emit(ProofState(photo: state.photo, cameraFailed: true));
    }
  }

  Future<void> send() async {
    final photo = state.photo;
    if (photo == null || state.sending) return;
    emit(ProofState(photo: photo, sending: true));
    try {
      final id = _uploadId ??= await _photos.upload(photo);
      if (next.isDeliver) {
        await _jobs.deliver(job.id, uploadIds: [id]);
      } else {
        await _jobs.transition(job.id, to: next.to, uploadIds: [id]);
      }
      emit(ProofState(photo: photo, done: true));
    } on ApiException catch (e) {
      emit(
        next.isTooFar(e)
            ? ProofState(photo: photo, tooFar: e)
            : ProofState(photo: photo, notice: e.userMessage),
      );
    }
  }
}
