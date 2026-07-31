import 'dart:async';

import 'package:cupid_mobile/core/realtime/realtime_coordinator.dart'
    show RealtimeLifecycleSource;
import 'package:flutter/widgets.dart';

import 'partner_link.dart';

/// Caller-supplied `GET /users/me` call, typically
/// `PairingRepository.getPartnerLink`. Kept as a function injection point
/// (mirroring `RealtimeCoordinator`'s `ResyncFetcher` seam) so this poller
/// can be unit-tested without a real `Dio`/`CupidApi`.
typedef PartnerLinkFetcher = Future<PartnerLink> Function();

/// D1's fixed poll contract (`coding-plan/master-plan.md` §1): polls
/// [PartnerLinkFetcher] until `partnerId` is non-null, since nothing in the
/// `invitations` module pushes the inviter a pairing event (the rejected
/// `RealtimeCoordinator` alternative is documented in the plan — no backend
/// event source exists for pairing).
///
/// Contract, do not improvise: interval 3s for the first 60s elapsed, then
/// 10s; hard stop at 10 minutes elapsed or at [expiresAt], whichever is
/// sooner; stop immediately on `partnerId != null` ([onPaired]) or
/// [dispose]; pause while backgrounded and resume on foreground, treating a
/// resume past the hard-stop deadline as a timeout ([onTimedOut]). Poll
/// failures are silent — caught and ignored so the loop keeps waiting;
/// only the terminal hard stop calls [onTimedOut] to surface the
/// manual-refresh fallback (UX spec §7).
///
/// Reuses `core/realtime`'s [RealtimeLifecycleSource] seam rather than a new
/// lifecycle abstraction: it is a generic `AppLifecycleListener` wrapper with
/// no socket/FCM coupling, already built to be faked in tests.
class PartnerLinkPoller {
  PartnerLinkPoller({
    required this._fetchPartnerLink,
    required this._expiresAt,
    required this._onPaired,
    required this._onTimedOut,
    RealtimeLifecycleSource? lifecycleSource,
    this._now = DateTime.now,
    Timer Function(Duration duration, void Function() callback)?
    timerFactory,
  }) : _lifecycleSource = lifecycleSource ?? _AppLifecyclePollerSource(),
       _timerFactory = timerFactory ?? Timer.new;

  static const Duration _fastInterval = Duration(seconds: 3);
  static const Duration _fastWindow = Duration(seconds: 60);
  static const Duration _slowInterval = Duration(seconds: 10);
  static const Duration _maxDuration = Duration(minutes: 10);

  final PartnerLinkFetcher _fetchPartnerLink;
  final DateTime _expiresAt;
  final void Function(PartnerLink link) _onPaired;
  final void Function() _onTimedOut;
  final RealtimeLifecycleSource _lifecycleSource;
  final DateTime Function() _now;
  final Timer Function(Duration duration, void Function() callback)
  _timerFactory;

  DateTime? _startedAt;
  late DateTime _hardStopAt;
  Timer? _timer;
  StreamSubscription<AppLifecycleState>? _lifecycleSubscription;
  bool _foreground = true;
  bool _stopped = false;
  bool _polling = false;

  /// Starts the poll loop. A no-op if already started.
  void start() {
    if (_startedAt != null) return;
    final startedAt = _now();
    _startedAt = startedAt;
    final maxStopAt = startedAt.add(_maxDuration);
    _hardStopAt = _expiresAt.isBefore(maxStopAt) ? _expiresAt : maxStopAt;

    _lifecycleSubscription = _lifecycleSource.states.listen(
      _handleLifecycleState,
    );
    _foreground = _lifecycleSource.currentState == AppLifecycleState.resumed;
    if (_foreground) {
      _scheduleNext();
    }
  }

  /// Screen-dispose stop (D1): tears down the timer and lifecycle
  /// subscription without invoking either callback.
  void dispose() {
    _stopped = true;
    _timer?.cancel();
    _timer = null;
    _lifecycleSubscription?.cancel();
    _lifecycleSubscription = null;
    _lifecycleSource.dispose();
  }

  void _handleLifecycleState(AppLifecycleState state) {
    if (_stopped) return;
    final resumed = state == AppLifecycleState.resumed;
    if (resumed == _foreground) return;
    _foreground = resumed;
    if (!resumed) {
      _timer?.cancel();
      _timer = null;
      return;
    }
    if (!_now().isBefore(_hardStopAt)) {
      _timeout();
      return;
    }
    _scheduleNext();
  }

  void _scheduleNext() {
    if (_stopped || !_foreground || _polling) return;
    final elapsed = _now().difference(_startedAt!);
    final interval = elapsed < _fastWindow ? _fastInterval : _slowInterval;
    _timer = _timerFactory(interval, _poll);
  }

  Future<void> _poll() async {
    _timer = null;
    if (_stopped) return;
    if (!_now().isBefore(_hardStopAt)) {
      _timeout();
      return;
    }
    _polling = true;
    try {
      final link = await _fetchPartnerLink();
      if (_stopped) return;
      if (link.partnerId != null) {
        _stopped = true;
        _lifecycleSubscription?.cancel();
        _lifecycleSubscription = null;
        _onPaired(link);
        return;
      }
    } catch (_) {
      // Poll failures are silent (D1): keep waiting instead of surfacing a
      // transient error; only the terminal hard stop reports failure.
    } finally {
      _polling = false;
    }
    if (_stopped) return;
    if (!_now().isBefore(_hardStopAt)) {
      _timeout();
      return;
    }
    _scheduleNext();
  }

  void _timeout() {
    _stopped = true;
    _timer?.cancel();
    _timer = null;
    _lifecycleSubscription?.cancel();
    _lifecycleSubscription = null;
    _onTimedOut();
  }
}

class _AppLifecyclePollerSource implements RealtimeLifecycleSource {
  _AppLifecyclePollerSource() {
    _listener = AppLifecycleListener(onStateChange: _controller.add);
  }

  final _controller = StreamController<AppLifecycleState>.broadcast(
    sync: true,
  );
  late final AppLifecycleListener _listener;

  @override
  AppLifecycleState get currentState =>
      WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;

  @override
  Stream<AppLifecycleState> get states => _controller.stream;

  @override
  void dispose() {
    _listener.dispose();
    _controller.close();
  }
}
