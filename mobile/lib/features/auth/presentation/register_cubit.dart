import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_repository.dart';

/// `register` screen state (`ux/uiux-spec.md` section 6).
sealed class RegisterState {
  const RegisterState();
}

class RegisterIdle extends RegisterState {
  const RegisterIdle();
}

class RegisterInProgress extends RegisterState {
  const RegisterInProgress();
}

class RegisterSuccess extends RegisterState {
  const RegisterSuccess();
}

/// [failure] is a `CupidAuthFailure` or `CupidApiFailure` — map it with
/// `authFailureMessage` before showing it.
class RegisterFailed extends RegisterState {
  const RegisterFailed(this.failure);

  final Object failure;
}

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit({required this._repository}) : super(const RegisterIdle());

  final AuthRepository _repository;

  Future<void> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    emit(const RegisterInProgress());
    try {
      await _repository.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      if (!isClosed) emit(const RegisterSuccess());
    } catch (failure) {
      if (!isClosed) emit(RegisterFailed(failure));
    }
  }
}
