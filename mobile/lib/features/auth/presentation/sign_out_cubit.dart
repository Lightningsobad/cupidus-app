import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/auth/session_termination.dart';
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

/// Teardown succeeded. Navigation to `welcome` (section 5: "signing out is a
/// deliberate user choice, so the full marketing welcome screen is
/// appropriate") is driven from the `userInitiated` termination signal this
/// state accompanies, not from this state itself — ADR-6 keeps that routing in
/// one root listener so every sign-out call site behaves identically.
class SignOutSuccess extends SignOutState {
  const SignOutSuccess();
}

class SignOutFailed extends SignOutState {
  const SignOutFailed(this.failure);

  final Object failure;
}

class SignOutCubit extends Cubit<SignOutState> {
  SignOutCubit({required this._repository, this._sessionTermination})
    : super(const SignOutIdle());

  final AuthRepository _repository;
  final SessionTerminationNotifier? _sessionTermination;

  Future<void> signOut() async {
    emit(const SignOutInProgress());
    try {
      await _repository.signOut();
    } catch (failure) {
      if (!isClosed) emit(SignOutFailed(failure));
      return;
    }
    if (!isClosed) emit(const SignOutSuccess());
    // AC5 ordering: teardown has already completed here, so the signal that
    // triggers navigation can never overtake it. Do not move this above the
    // await.
    _sessionTermination?.emit(SessionTerminationReason.userInitiated);
  }
}
