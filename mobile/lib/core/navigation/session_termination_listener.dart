import 'dart:async';

import 'package:flutter/material.dart';

import '../auth/session_termination.dart';
import '../di/service_locator.dart';
import 'onboarding_chain.dart';
import 'onboarding_router.dart';

/// ADR-6's single consumer of [SessionTerminationNotifier], mounted exactly
/// once at the app root by `PairGateShell` alongside `ReminderOverlayHost`.
///
/// Centralising the destination here is what makes AC5 and AC6 differ from one
/// signal source: `userInitiated` resets to `welcome`, `refreshFailed` resets
/// to `login`. No sign-out call site navigates on its own.
///
/// [notifier] and [router] default to the `getIt` registrations. Both resolve
/// to `null` when `setupServiceLocator()` never ran (widget tests pumping this
/// subtree directly), in which case the subtree renders unchanged instead of
/// crashing — same tolerance `ReminderOverlayHost` applies.
class SessionTerminationListener extends StatefulWidget {
  const SessionTerminationListener({
    super.key,
    required this.child,
    this._notifier,
    this._router,
  });

  final Widget child;
  final SessionTerminationNotifier? _notifier;
  final OnboardingRouter? _router;

  @override
  State<SessionTerminationListener> createState() =>
      _SessionTerminationListenerState();
}

class _SessionTerminationListenerState
    extends State<SessionTerminationListener> {
  StreamSubscription<SessionTerminationReason>? _subscription;

  @override
  void initState() {
    super.initState();
    final SessionTerminationNotifier? notifier =
        widget._notifier ??
        (getIt.isRegistered<SessionTerminationNotifier>()
            ? getIt<SessionTerminationNotifier>()
            : null);
    _subscription = notifier?.stream.listen(_onTerminated);
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  void _onTerminated(SessionTerminationReason reason) {
    if (!mounted) return;
    final OnboardingRouter? router =
        widget._router ??
        (getIt.isRegistered<OnboardingRouter>()
            ? getIt<OnboardingRouter>()
            : null);
    if (router == null) return;
    final OnboardingNode target = switch (reason) {
      SessionTerminationReason.userInitiated => OnboardingNode.welcome,
      SessionTerminationReason.refreshFailed => OnboardingNode.login,
    };
    // `resetTo` clears the stack this listener is mounted inside, so the
    // returned route future never completes.
    unawaited(router.resetTo(context, target));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
