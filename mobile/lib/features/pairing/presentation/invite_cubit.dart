import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/pairing_invitation.dart';

/// `invite` screen state (`ux/uiux-spec.md` §3).
sealed class InviteState {
  const InviteState();
}

class InviteLoading extends InviteState {
  const InviteLoading();
}

/// [remaining] is the live `expiresAt` countdown (§3's copy correction: 24h
/// TTL, not the mockup's "15 minutes"), recomputed on every tick.
class InviteReady extends InviteState {
  const InviteReady({required this.invitation, required this.remaining});

  final PairingInvitation invitation;
  final Duration remaining;
}

/// [failure] is a `CupidApiFailure` (never a raw exception).
class InviteFailed extends InviteState {
  const InviteFailed(this.failure);

  final Object failure;
}

/// Drives the `invite` screen: generates/fetches the active invitation code
/// and ticks a live countdown from [PairingInvitation.expiresAt].
///
/// Backend truth (`generateCode`, plan §1 D1/§3) is idempotent — calling
/// [refresh] again after a ready state is already shown must not flash a
/// loading state, since the returned code is unchanged; [_generate] only
/// emits [InviteLoading] when there is no prior ready state to hold onto.
class InviteCubit extends Cubit<InviteState> {
  InviteCubit({
    required Future<PairingInvitation> Function() generateInvitation,
    DateTime Function() now = DateTime.now,
    Timer Function(Duration duration, void Function() callback)?
    timerFactory,
  }) : _generateInvitation = generateInvitation,
       _now = now,
       _timerFactory = timerFactory ?? Timer.new,
       super(const InviteLoading()) {
    unawaited(_generate());
  }

  static const Duration _tickInterval = Duration(seconds: 30);

  final Future<PairingInvitation> Function() _generateInvitation;
  final DateTime Function() _now;
  final Timer Function(Duration duration, void Function() callback)
  _timerFactory;

  Timer? _tickTimer;

  /// Re-runs generation. Safe to call repeatedly (idempotent backend), and
  /// does not flash a loading state if a code is already on screen.
  Future<void> refresh() => _generate();

  Future<void> _generate() async {
    final InviteState previous = state;
    if (previous is! InviteReady) {
      emit(const InviteLoading());
    }
    try {
      final PairingInvitation invitation = await _generateInvitation();
      if (isClosed) return;
      _tickTimer?.cancel();
      _emitReady(invitation);
      _scheduleTick(invitation);
    } catch (failure) {
      if (!isClosed) emit(InviteFailed(failure));
    }
  }

  void _emitReady(PairingInvitation invitation) {
    emit(
      InviteReady(
        invitation: invitation,
        remaining: _remaining(invitation.expiresAt),
      ),
    );
  }

  void _scheduleTick(PairingInvitation invitation) {
    if (isClosed) return;
    if (_remaining(invitation.expiresAt) <= Duration.zero) return;
    _tickTimer = _timerFactory(_tickInterval, () {
      if (isClosed) return;
      _emitReady(invitation);
      _scheduleTick(invitation);
    });
  }

  Duration _remaining(DateTime expiresAt) {
    final Duration diff = expiresAt.difference(_now());
    return diff.isNegative ? Duration.zero : diff;
  }

  @override
  Future<void> close() {
    _tickTimer?.cancel();
    return super.close();
  }
}
