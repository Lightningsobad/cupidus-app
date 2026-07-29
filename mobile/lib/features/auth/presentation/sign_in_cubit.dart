import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_repository.dart';

/// `login` screen state (`ux/uiux-spec.md` section 6: disable + inline
/// spinner on submit, restore + inline error on failure).
sealed class SignInState {
  const SignInState();
}

class SignInIdle extends SignInState {
  const SignInIdle();
}

class SignInInProgress extends SignInState {
  const SignInInProgress();
}

class SignInSuccess extends SignInState {
  const SignInSuccess();
}

/// [failure] is a `CupidAuthFailure` or `CupidApiFailure` (never a raw
/// exception) — map it with `authFailureMessage` before showing it.
class SignInFailed extends SignInState {
  const SignInFailed(this.failure);

  final Object failure;
}

class SignInCubit extends Cubit<SignInState> {
  SignInCubit({required this._repository}) : super(const SignInIdle());

  final AuthRepository _repository;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) => _run(
    () => _repository.signInWithEmail(email: email, password: password),
  );

  Future<void> signInWithGoogle() => _run(_repository.signInWithGoogle);

  Future<void> signInWithApple() => _run(_repository.signInWithApple);

  Future<void> signInWithFacebook() => _run(_repository.signInWithFacebook);

  Future<void> _run(Future<void> Function() action) async {
    emit(const SignInInProgress());
    try {
      await action();
      if (!isClosed) emit(const SignInSuccess());
    } catch (failure) {
      if (!isClosed) emit(SignInFailed(failure));
    }
  }
}
