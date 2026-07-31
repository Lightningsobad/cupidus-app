import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/account_repository.dart';
import '../domain/cupid_profile.dart';
import '../domain/zodiac.dart';

/// `profile edit` sub-screen draft state (`coding-plan/master-plan.md` §6.2
/// P2, `ux/uiux-spec.md` §3). [showNameError]/[showDobError] are booleans
/// rather than pre-rendered strings — mirroring `RegisterFailed` carrying an
/// untranslated failure object — so the screen maps them to localized copy
/// via `AppL10n`, keeping this cubit free of `BuildContext`.
class ProfileEditState {
  const ProfileEditState({
    required this.name,
    required this.birthday,
    required this.initialName,
    required this.initialBirthday,
    this.isSubmitting = false,
    this.showNameError = false,
    this.showDobError = false,
    this.submitFailure,
    this.submittedProfile,
  });

  factory ProfileEditState.fromProfile(CupidProfile profile) =>
      ProfileEditState(
        name: profile.displayName ?? '',
        birthday: profile.birthday,
        initialName: profile.displayName ?? '',
        initialBirthday: profile.birthday,
      );

  final String name;
  final DateTime? birthday;
  final String initialName;
  final DateTime? initialBirthday;
  final bool isSubmitting;
  final bool showNameError;
  final bool showDobError;

  /// A `CupidApiFailure` from the last failed submit, or `null`.
  final Object? submitFailure;

  /// Set once a submit has succeeded; the screen pops with this value.
  final CupidProfile? submittedProfile;

  bool get isDirty => name != initialName || birthday != initialBirthday;

  /// Live-updating zodiac chip (`ux/uiux-spec.md` §3: "chip updates live as
  /// DOB changes").
  String? get zodiacSign =>
      birthday == null ? null : zodiacSignFor(birthday!);

  ProfileEditState copyWith({
    String? name,
    DateTime? birthday,
    bool? isSubmitting,
    bool? showNameError,
    bool? showDobError,
    Object? submitFailure,
    bool clearSubmitFailure = false,
  }) {
    return ProfileEditState(
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
      initialName: initialName,
      initialBirthday: initialBirthday,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      showNameError: showNameError ?? this.showNameError,
      showDobError: showDobError ?? this.showDobError,
      submitFailure: clearSubmitFailure
          ? null
          : (submitFailure ?? this.submitFailure),
    );
  }
}

class ProfileEditCubit extends Cubit<ProfileEditState> {
  ProfileEditCubit({required this._repository, required CupidProfile profile})
    : super(ProfileEditState.fromProfile(profile));

  final AccountRepository _repository;

  void nameChanged(String value) {
    emit(
      state.copyWith(
        name: value,
        showNameError: false,
        clearSubmitFailure: true,
      ),
    );
  }

  void birthdayChanged(DateTime value) {
    emit(
      state.copyWith(
        birthday: value,
        showDobError: false,
        clearSubmitFailure: true,
      ),
    );
  }

  /// Validates (name non-empty, DOB required), then — only if dirty — sends
  /// a partial PATCH. `birthday`/`zodiacSign` are sent together or not at
  /// all (`coding-plan/master-plan.md` §6.2 P2).
  Future<void> submit() async {
    final String trimmedName = state.name.trim();
    final bool nameError = trimmedName.isEmpty;
    final bool dobError = state.birthday == null;

    if (nameError || dobError) {
      emit(state.copyWith(showNameError: nameError, showDobError: dobError));
      return;
    }

    if (!state.isDirty) return;

    emit(state.copyWith(isSubmitting: true, clearSubmitFailure: true));

    final bool didDobChange = state.birthday != state.initialBirthday;
    final bool didNameChange = trimmedName != state.initialName;

    try {
      final CupidProfile updated = await _repository.updateProfile(
        displayName: didNameChange ? trimmedName : null,
        birthday: didDobChange ? state.birthday : null,
        zodiacSign: didDobChange ? zodiacSignFor(state.birthday!) : null,
      );
      if (!isClosed) {
        emit(
          ProfileEditState(
            name: updated.displayName ?? '',
            birthday: updated.birthday,
            initialName: updated.displayName ?? '',
            initialBirthday: updated.birthday,
            submittedProfile: updated,
          ),
        );
      }
    } catch (failure) {
      if (!isClosed) {
        emit(state.copyWith(isSubmitting: false, submitFailure: failure));
      }
    }
  }
}
