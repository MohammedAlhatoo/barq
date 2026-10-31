import 'dart:io';

import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/locale_cubit.dart';
import '../data/account_models.dart';
import '../data/account_repository.dart';
import '../data/avatar_picker.dart';

class EditProfileState {
  const EditProfileState({
    this.loading = true,
    this.profile,
    this.name = '',
    required this.language,
    this.picked,
    this.saving = false,
    this.loadError,
    this.error,
    this.done = false,
  });

  final bool loading;
  final Profile? profile;
  final String name;
  final String language;

  /// A new picture. It is uploaded when the user saves.
  final File? picked;
  final bool saving;
  final String? loadError;
  final String? error;
  final bool done;

  /// `PUT /me` needs at least 2 letters.
  bool get canSave => name.trim().length >= 2 && !saving;

  /// The first letter of what is typed now, so the avatar follows the field.
  String get initial => Profile(name: name, phone: '').initial;

  EditProfileState copyWith({
    bool? loading,
    Profile? profile,
    String? name,
    String? language,
    File? picked,
    bool? saving,
    String? loadError,
    String? error,
    bool? done,
  }) => EditProfileState(
    loading: loading ?? this.loading,
    profile: profile ?? this.profile,
    name: name ?? this.name,
    language: language ?? this.language,
    picked: picked ?? this.picked,
    saving: saving ?? this.saving,
    loadError: loadError,
    error: error,
    done: done ?? this.done,
  );
}

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit({
    required this._repository,
    required this._picker,
    required this._locale,
  }) : super(EditProfileState(language: _locale.state.languageCode));

  final AccountRepository _repository;
  final AvatarPicker _picker;
  final LocaleCubit _locale;

  /// Kept so a retry after a failed save does not upload the picture twice.
  int? _uploadId;

  /// A request can end after the user left the screen.
  @override
  void emit(EditProfileState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    try {
      final profile = await _repository.profile();
      emit(
        state.copyWith(
          loading: false,
          profile: profile,
          name: profile.name ?? '',
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(loading: false, loadError: e.messageAr));
    }
  }

  void nameChanged(String name) => emit(state.copyWith(name: name));

  void languageChanged(String language) =>
      emit(state.copyWith(language: language));

  Future<void> pickPhoto() async {
    final file = await _picker.pick();
    if (file == null) return;
    _uploadId = null;
    emit(state.copyWith(picked: file));
  }

  /// The language changes only after the server accepted it, because the
  /// server sends notifications in the account's language.
  Future<void> save() async {
    if (!state.canSave) return;
    emit(state.copyWith(saving: true));
    try {
      final file = state.picked;
      if (file != null) _uploadId ??= await _repository.uploadAvatar(file);
      await _repository.updateProfile(
        name: state.name.trim(),
        locale: state.language,
        avatarUploadId: _uploadId,
      );
      await _locale.change(state.language);
      emit(state.copyWith(saving: false, done: true));
    } on ApiException catch (e) {
      emit(state.copyWith(saving: false, error: e.messageAr));
    }
  }
}
