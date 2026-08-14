import 'dart:async';

/// Why a session ended (`architecture/solution.md` ADR-6, defect D6).
///
/// A deliberate sign-out and a failed mid-session token refresh both converge
/// on `CupidSession.signOut()`, so the reason has to travel on its own channel
/// for AC5 (→ `welcome`) and AC6 (→ `login`) to resolve to different
/// destinations.
enum SessionTerminationReason { userInitiated, refreshFailed }

/// Broadcast so publishers stay decoupled from whether a consumer is currently
/// mounted: a termination fired while no listener exists is dropped rather
/// than buffered, which matches the intent (there is nothing to navigate).
///
/// Deliberately free of Firebase/Dio/Flutter dependencies so both publishers
/// and the widget consumer can take it without pulling a transport in.
class SessionTerminationNotifier {
  final StreamController<SessionTerminationReason> _controller =
      StreamController<SessionTerminationReason>.broadcast();

  Stream<SessionTerminationReason> get stream => _controller.stream;

  void emit(SessionTerminationReason reason) {
    if (_controller.isClosed) return;
    _controller.add(reason);
  }

  Future<void> dispose() => _controller.close();
}
