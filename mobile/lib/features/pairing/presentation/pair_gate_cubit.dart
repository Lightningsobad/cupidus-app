import 'dart:async';

import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/partner_link.dart';

/// The app root's paired/unpaired outcomes (`ux/uiux-spec.md` section 6,
/// AC4). Gating happens at the shell level, not per-screen: the whole
/// pairing flow is unreachable once paired, and the whole tab shell is
/// unreachable until paired.
sealed class PairGateState {
  const PairGateState();
}

/// The one-shot `GET /users/me` check has not resolved yet.
class PairGateChecking extends PairGateState {
  const PairGateChecking();
}

/// No partner on the account: route into the pairing-flow stack.
class PairGateUnpaired extends PairGateState {
  const PairGateUnpaired();
}

/// A partner is already linked: route into the main tab shell.
class PairGatePaired extends PairGateState {
  const PairGatePaired();
}

/// Network failure when checking partner link: route to offline / retry screen.
class PairGateNetworkError extends PairGateState {
  const PairGateNetworkError();
}

/// Drives the app-root shell gate (`ux/uiux-spec.md` section 6) from a single
/// [PartnerLink] read, typically `PairingRepository.getPartnerLink`. Kept as
/// a function injection point (mirroring `SessionGateCubit`'s seam) so this
/// gate can be unit/widget-tested without a live/mocked `Dio`.
///
/// This is a one-shot shell check, not the `waiting` screen's bounded
/// `PartnerLinkPoller` (D1): the shell only needs to know the state once at
/// app-root build time, it does not keep polling for a live transition.
///
/// A failed check emits [PairGateUnpaired] rather than [PairGatePaired]: the
/// verification contract's blocker is "any paired-only surface reachable
/// while unpaired" (plan section 5), so an unresolved check must never grant
/// access to the tab shell.
class PairGateCubit extends Cubit<PairGateState> {
  PairGateCubit({required Future<PartnerLink> Function() getPartnerLink})
    : _getPartnerLink = getPartnerLink,
      super(const PairGateChecking()) {
    unawaited(_check());
  }

  final Future<PartnerLink> Function() _getPartnerLink;

  Future<void> _check() async {
    try {
      final PartnerLink link = await _getPartnerLink();
      if (isClosed) return;
      emit(link.isPaired ? const PairGatePaired() : const PairGateUnpaired());
    } on NetworkUnavailableFailure {
      if (isClosed) return;
      emit(const PairGateNetworkError());
    } on TimeoutFailure {
      if (isClosed) return;
      emit(const PairGateNetworkError());
    } catch (_) {
      if (isClosed) return;
      emit(const PairGateUnpaired());
    }
  }

  void retry() {
    emit(const PairGateChecking());
    unawaited(_check());
  }
}
