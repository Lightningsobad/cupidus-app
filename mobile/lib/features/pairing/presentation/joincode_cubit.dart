import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/pairing_failure.dart';

/// `joincode` screen state (`ux/uiux-spec.md` §4, §5) — invitee's manual
/// code-entry path.
sealed class JoincodeState {
  const JoincodeState();
}

class JoincodeIdle extends JoincodeState {
  const JoincodeIdle();
}

class JoincodeInProgress extends JoincodeState {
  const JoincodeInProgress();
}

/// Success is immediate per §4: no intermediate loading screen beyond the
/// standard button-disable + inline-spinner pattern, straight to `paired`.
class JoincodeSuccess extends JoincodeState {
  const JoincodeSuccess();
}

/// [failure] is a [PairingFailure] — map it with `pairingFailureMessage`
/// before showing it inline (§5); re-enables the button and keeps the user
/// on this screen.
class JoincodeFailed extends JoincodeState {
  const JoincodeFailed(this.failure);

  final PairingFailure failure;
}

/// Drives the `joincode` screen: submits the entered code to
/// `PairingRepository.acceptInvitation` (plan §1 D4, §2), which always
/// throws a [PairingFailure] on rejection (never a raw exception).
class JoincodeCubit extends Cubit<JoincodeState> {
  JoincodeCubit({
    required Future<void> Function(String code) acceptInvitation,
  }) : _acceptInvitation = acceptInvitation,
       super(const JoincodeIdle());

  final Future<void> Function(String code) _acceptInvitation;

  Future<void> submit(String code) async {
    emit(const JoincodeInProgress());
    try {
      await _acceptInvitation(code);
      if (!isClosed) emit(const JoincodeSuccess());
    } on PairingFailure catch (failure) {
      if (!isClosed) emit(JoincodeFailed(failure));
    }
  }
}
