import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:cupid_mobile/features/timeline/domain/timeline_entry.dart';

/// UI state for the Timeline screen (`ux/uiux-spec.md` §2, `architecture/
/// solution.md` §4). `ready` covers both the online and offline-with-cache
/// presentations (`isOffline` distinguishes them); `empty` (synced, zero
/// entries) and `offlineNoCache` (never synced, unreachable) are never
/// conflated (D-012-6).
sealed class TimelineState {
  const TimelineState();
}

/// Initial Drift-cache read or first sync has not resolved yet -- drives the
/// 5-card skeleton (UX §2).
class TimelineLoading extends TimelineState {
  const TimelineLoading();
}

/// At least one entry is showing, either freshly synced or served from cache
/// while offline (`isOffline`).
class TimelineReady extends TimelineState {
  const TimelineReady(this.entries, {required this.isOffline});

  final List<TimelineEntry> entries;
  final bool isOffline;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimelineReady &&
          other.isOffline == isOffline &&
          _entriesEqual(other.entries, entries));

  @override
  int get hashCode => Object.hash(isOffline, Object.hashAll(entries));

  static bool _entriesEqual(List<TimelineEntry> a, List<TimelineEntry> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Synced, zero entries -- distinct from [TimelineOfflineNoCache] (D-012-6).
class TimelineEmpty extends TimelineState {
  const TimelineEmpty();
}

/// Never synced and currently unreachable -- distinct from [TimelineEmpty].
class TimelineOfflineNoCache extends TimelineState {
  const TimelineOfflineNoCache();
}

/// A non-connectivity failure with nothing cached to fall back on.
class TimelineError extends TimelineState {
  const TimelineError(this.failure);

  final CupidApiFailure failure;
}
