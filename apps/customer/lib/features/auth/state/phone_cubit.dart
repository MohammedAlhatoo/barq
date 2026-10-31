import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_models.dart';
import '../data/auth_repository.dart';
import '../data/phone_number.dart';

class PhoneState {
  const PhoneState({
    this.isValid = false,
    this.sending = false,
    this.error,
    this.ticket,
  });

  final bool isValid;
  final bool sending;
  final String? error;

  /// Set once the code is sent: the screen moves on to the OTP step.
  final OtpTicket? ticket;
}

class PhoneCubit extends Cubit<PhoneState> {
  PhoneCubit(this._repository) : super(const PhoneState());

  final AuthRepository _repository;
  String _typed = '';

  void phoneChanged(String typed) {
    _typed = typed;
    emit(PhoneState(isValid: PhoneNumber.isValid(typed)));
  }

  Future<void> send() async {
    if (!state.isValid || state.sending) return;
    emit(const PhoneState(isValid: true, sending: true));
    try {
      final ticket = await _repository.sendOtp(PhoneNumber.normalize(_typed));
      emit(PhoneState(isValid: true, ticket: ticket));
    } on ApiException catch (e) {
      emit(PhoneState(isValid: true, error: e.messageAr));
    }
  }
}
