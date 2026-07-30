import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/partner_link.dart';
import '../data/partner_link_poller.dart';

/// `waiting` screen state (`ux/uiux-spec.md` §2/§7) — inviter-only hold
/// state after `invite` generates a code.
sealed class WaitingState {
  const WaitingState();
}

class WaitingInProgress extends WaitingState {
  const WaitingInProgress();
}

class WaitingPaired extends WaitingState {
  const WaitingPaired(this.link);

  final PartnerLink link;
}

/// Poll hard-stop reached (`PartnerLinkPoller`, plan §1 D1) — surfaces the
/// manual-refresh fallback (§7).
class WaitingTimedOut extends WaitingState {
  const WaitingTimedOut();
}

/// Wraps a [PartnerLinkPoller] (plan §1 D1) to drive the `waiting` screen.
///
/// [createPoller] is a function-injection seam (mirroring `PairGateCubit`'s
/// seam) so a test can supply a [PartnerLinkPoller] wired to a fake clock,
/// timer factory, and lifecycle source without waiting on real timers,
/// reusing `PartnerLinkPoller`'s own already-tested poll contract rather
/// than re-implementing it here.
class WaitingCubit extends Cubit<WaitingState> {
  WaitingCubit({
    required Future<PartnerLink> Function() getPartnerLink,
    required DateTime expiresAt,
    PartnerLinkPoller Function(
      void Function(PartnerLink link) onPaired,
      void Function() onTimedOut,
    )?
    createPoller,
  }) : _getPartnerLink = getPartnerLink,
       super(const WaitingInProgress()) {
    final PartnerLinkPoller Function(
      void Function(PartnerLink link) onPaired,
      void Function() onTimedOut,
    )
    factory =
        createPoller ??
        (onPaired, onTimedOut) => PartnerLinkPoller(
          fetchPartnerLink: getPartnerLink,
          expiresAt: expiresAt,
          onPaired: onPaired,
          onTimedOut: onTimedOut,
        );
    _poller = factory(_handlePaired, _handleTimedOut)..start();
  }

  final Future<PartnerLink> Function() _getPartnerLink;
  late final PartnerLinkPoller _poller;

  /// Manual refresh fallback (§7): checks immediately instead of waiting for
  /// the next scheduled poll tick. Failures are silent, matching the
  /// poller's own D1 contract — the screen just keeps waiting.
  Future<void> refreshNow() async {
    try {
      final PartnerLink link = await _getPartnerLink();
      if (link.partnerId != null) _handlePaired(link);
    } catch (_) {
      // Silent per D1: a manual check failing should not surface an error.
    }
  }

  void _handlePaired(PartnerLink link) {
    if (!isClosed) emit(WaitingPaired(link));
  }

  void _handleTimedOut() {
    if (!isClosed) emit(const WaitingTimedOut());
  }

  @override
  Future<void> close() {
    _poller.dispose();
    return super.close();
  }
}
