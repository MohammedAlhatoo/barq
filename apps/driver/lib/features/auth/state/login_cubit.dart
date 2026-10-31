import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_repository.dart';
import '../data/phone_number.dart';

class LoginState {
  const LoginState({
    this.isValid = false,
    this.sending = false,
    this.error,
    this.loggedIn = false,
  });

  final bool isValid;
  final bool sending;
  final String? error;
  final bool loggedIn;
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._repository) : super(const LoginState());

  final AuthRepository _repository;
  String _phone = '';
  String _password = '';

  bool get _isValid => PhoneNumber.isValid(_phone) && _password.isNotEmpty;

  void phoneChanged(String typed) {
    _phone = typed;
    emit(LoginState(isValid: _isValid));
  }

  void passwordChanged(String typed) {
    _password = typed;
    emit(LoginState(isValid: _isValid));
  }

  Future<void> login() async {
    if (!_isValid || state.sending) return;
    emit(const LoginState(isValid: true, sending: true));
    try {
      await _repository.login(
        phone: PhoneNumber.normalize(_phone),
        password: _password,
      );
      emit(const LoginState(isValid: true, loggedIn: true));
    } on ApiException catch (e) {
      emit(LoginState(isValid: true, error: e.userMessage));
    }
  }
}
