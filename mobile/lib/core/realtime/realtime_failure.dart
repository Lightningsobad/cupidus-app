/// Typed failures thrown by [RealtimeCoordinator] (`architecture/solution.md`
/// §2). Feature code catches these instead of raw transport exceptions.
sealed class RealtimeFailure {
  const RealtimeFailure();
}

/// Thrown by `emit` when `status` is not `RealtimeStatus.live`
/// (`architecture/solution.md` §2, ADR-012h).
class RealtimeNotLiveFailure extends RealtimeFailure {
  const RealtimeNotLiveFailure();
}

/// Thrown when the injected `backendUserId` resolver cannot produce the
/// backend `User.id` needed to key the `joinRoom` room (`architecture/
/// solution.md` §2 `backendUserId`, Room-key typing gap).
class RealtimeRoomKeyUnavailableFailure extends RealtimeFailure {
  const RealtimeRoomKeyUnavailableFailure();
}
