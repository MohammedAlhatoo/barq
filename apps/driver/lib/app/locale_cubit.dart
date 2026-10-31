import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The app language. Arabic until the user picks English.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._prefs) : super(Locale(_prefs.getString(_key) ?? 'ar'));

  static const _key = 'barq_language';

  final SharedPreferences _prefs;

  Future<void> change(String languageCode) async {
    if (languageCode == state.languageCode) return;
    await _prefs.setString(_key, languageCode);
    emit(Locale(languageCode));
  }
}
