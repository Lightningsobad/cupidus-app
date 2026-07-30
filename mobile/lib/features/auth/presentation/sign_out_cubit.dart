import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_repository.dart';

/// AC4 sign-out state machine (`ux/uiux-spec.md` section 5). Drives
/// [SignOutAction]: the destructive confirm dialog itself has no loading
/// state of its own (section 5 does not specify one, unlike section 6's
/// submit-button rule), so [SignOutInProgress] only needs to disable the
/// triggering control while teardown runs.
sealed class SignOutState {
  const SignOutState();
}

class SignOutIdle extends SignOutState {
  const SignOutIdle();
}

class SignOutInProgress extends SignOutState {
  const SignOutInProgress();
}

/// Teardown succeeded: the caller should navigate to `welcome`, per section
/// 5 ("signing out is a deliberate user choice, so the full marketing
/// welcome screen is appropriate").
class SignOutSuccess extends SignOutState {
  const SignOutSuccess();
}

class SignOutFailed extends SignOutState {
  const SignOutFailed(this.failure);

  final Object failure;
}

class SignOutCubit extends Cubit<SignOutState> {
  SignOutCubit({required this._repository}) : super(const SignOutIdle());

  final AuthRepository _repository;

  Future<void> signOut() async {
    emit(const SignOutInProgress());
    try {
      await _repository.signOut();
      if (!isClosed) emit(const SignOutSuccess());
    } catch (failure) {
      if (!isClosed) emit(SignOutFailed(failure));
    }
  }
}
