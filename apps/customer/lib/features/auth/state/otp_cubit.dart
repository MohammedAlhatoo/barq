import 'dart:async';

import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_models.dart';
import '../data/auth_repository.dart';

enum OtpResult { none, goWelcome, goHome }

class OtpState {
  const OtpState({
    required this.ticket,
    required this.secondsLeft,
    this.code = '',
    this.busy = false,
    this.error,
    this.result = OtpResult.none,
    this.resendCount = 0,
  });

  final OtpTicket ticket;

  /// Countdown until the user may ask for a new code.
  final int secondsLeft;
  final String code;
  final bool busy;
  final String? error;
  final OtpResult result;

  /// Changes with every new code, so the screen can empty the boxes.
  final int resendCount;

  bool get isComplete => code.length == ticket.length;

  OtpState copyWith({
    OtpTicket? ticket,
    int? secondsLeft,
    String? code,
    bool? busy,
    String? error,
    OtpResult? result,
    int? resendCount,
  }) => OtpState(
    ticket: ticket ?? this.ticket,
    secondsLeft: secondsLeft ?? this.secondsLeft,
    code: code ?? this.code,
    busy: busy ?? this.busy,
    error: error,
    result: result ?? this.result,
    resendCount: resendCount ?? this.resendCount,
  );
}

class OtpCubit extends Cubit<OtpState> {
  OtpCubit({
    required this._repository,
    required this._auth,
    required OtpTicket ticket,
  }) : super(OtpState(ticket: ticket, secondsLeft: ticket.expiresIn)) {
    _startTimer();
  }

  final AuthRepository _repository;
  final AuthStore _auth;
  Timer? _timer;

  void codeChanged(String code) => emit(state.copyWith(code: code));

  Future<void> verify() async {
    if (!state.isComplete || state.busy) return;
    emit(state.copyWith(busy: true));
    try {
      final session = await _repository.verifyOtp(
        phone: state.ticket.phone,
        code: state.code,
      );
      await _auth.save(session.token);
      emit(
        state.copyWith(
          busy: false,
          result: session.needsProfile ? OtpResult.goWelcome : OtpResult.goHome,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(busy: false, error: e.messageAr));
    }
  }

  Future<void> resend() async {
    if (state.secondsLeft > 0 || state.busy) return;
    emit(state.copyWith(busy: true));
    try {
      final ticket = await _repository.sendOtp(state.ticket.phone);
      emit(
        state.copyWith(
          ticket: ticket,
          secondsLeft: ticket.expiresIn,
          code: '',
          busy: false,
          resendCount: state.resendCount + 1,
        ),
      );
      _startTimer();
    } on ApiException catch (e) {
      emit(state.copyWith(busy: false, error: e.messageAr));
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final left = state.secondsLeft - 1;
      if (left <= 0) timer.cancel();
      emit(
        state.copyWith(secondsLeft: left < 0 ? 0 : left, error: state.error),
      );
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
