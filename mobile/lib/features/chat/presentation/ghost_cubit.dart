import 'dart:async';

import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/chat_events.dart';
import '../data/chat_partner_store.dart';
import '../data/ghost_consent_store.dart';

/// Timer/clock injection seam mirroring the `GraceTimerFactory` pattern in
/// `core/realtime/realtime_coordinator.dart`, declared locally rather than
/// imported from there — feature code reaches realtime only through the
/// `cupid_realtime.dart` barrel, and that implementation file sits outside
/// it.
typedef GhostTimerFactory = Timer Function(
  Duration duration,
  void Function() onElapsed,
);

Timer _realGhostTimer(Duration duration, void Function() onElapsed) =>
    Timer(duration, onElapsed);

/// ADR-013b timing contract. Exported so tests assert against these instead
/// of duplicating literals.
const Duration ghostOutboundThrottleDuration = Duration(milliseconds: 120);
const Duration ghostSenderIdleDuration = Duration(milliseconds: 1200);
const Duration ghostReceiverStaleExpiryDuration = Duration(milliseconds: 6000);

/// `ux/uiux-spec.md` §3d `ghostFade`: the struck-through deleted run fades
/// to 45% opacity over this duration. Not an ADR-013b emit-timing constant,
/// but exported for the same reason — `ghost_bubble.dart` and its tests
/// reference this rather than a duplicated literal.
const Duration ghostBubbleFadeDuration = Duration(milliseconds: 1300);

/// ADR-013e three-state consent model.
enum GhostConsentLevel {
  /// Local opt-in flag is false, or the server flag is false.
  off,

  /// Locally opted in and the server flag is true, but no `ghostTyping` has
  /// been received from the partner this session.
  pending,

  /// Locally opted in, server flag true, and at least one `ghostTyping` has
  /// been received from the partner this session.
  on,
}

/// Immutable UI state for the typing ghost (`ux/uiux-spec.md` §3d, §4, AC2).
class GhostState {
  const GhostState({
    this.consentLevel = GhostConsentLevel.off,
    this.partnerKeptContent = '',
    this.partnerStruckContent = '',
  });

  /// This device's own consent state — never the partner's, which the
  /// backend contract exposes no flag for (`ghost_settings_screen.dart`
  /// renders the partner column as waiting/unknown, not from this field).
  final GhostConsentLevel consentLevel;

  /// The partner's current draft with any struck-through deleted run
  /// already removed — the "kept" portion rendered as live ghost text.
  final String partnerKeptContent;

  /// The tail removed from the partner's previous draft since the last
  /// `ghostTyping`, rendered struck-through and fading to 45% opacity over
  /// [ghostBubbleFadeDuration]. Derived receiver-side — the backend carries
  /// no deletion information (ADR-013b).
  final String partnerStruckContent;

  /// Whether `GhostBubble` should currently be shown at all.
  bool get isPartnerGhosting =>
      partnerKeptContent.isNotEmpty || partnerStruckContent.isNotEmpty;

  GhostState copyWith({
    GhostConsentLevel? consentLevel,
    String? partnerKeptContent,
    String? partnerStruckContent,
  }) {
    return GhostState(
      consentLevel: consentLevel ?? this.consentLevel,
      partnerKeptContent: partnerKeptContent ?? this.partnerKeptContent,
      partnerStruckContent: partnerStruckContent ?? this.partnerStruckContent,
    );
  }
}

/// 2-way typing ghost cubit (`coding-plan/phase-P3-typing-ghost.md` §3,
/// AC2). Owns both the sender emit path (`typing`/`stopTyping`) and the
/// receiver diff/expiry path (`ghostTyping`/`ghostStopTyping`), plus the
/// ADR-013e consent state machine. Never touches Drift or
/// `shared_preferences` directly — ghost content must never be persisted or
/// logged (`architecture/solution.md` §2 invariant 3).
class GhostCubit extends Cubit<GhostState> {
  GhostCubit({
    required RealtimeCoordinator coordinator,
    required GhostConsentStore consentStore,
    required ChatPartnerStore partnerStore,
    required BackendUserIdStore backendUserIdStore,
    GhostTimerFactory timerFactory = _realGhostTimer,
  })  : _coordinator = coordinator,
        _consentStore = consentStore,
        _partnerStore = partnerStore,
        _backendUserIdStore = backendUserIdStore,
        _timerFactory = timerFactory,
        super(const GhostState()) {
    _serverFlagEnabled = _partnerStore.isGhostModeEnabled ?? false;
    _eventsSubscription = _coordinator
        .events(names: {ChatEvents.ghostTyping, ChatEvents.ghostStopTyping})
        .listen(_handleInboundEvent);
    unawaited(_loadLocalOptIn());
  }

  final RealtimeCoordinator _coordinator;
  final GhostConsentStore _consentStore;
  final ChatPartnerStore _partnerStore;
  final BackendUserIdStore _backendUserIdStore;
  final GhostTimerFactory _timerFactory;
  late final StreamSubscription<RealtimeEvent> _eventsSubscription;

  bool _hasLocalOptIn = false;
  bool _serverFlagEnabled = false;
  bool _hasReceivedGhostTypingThisSession = false;

  String _pendingOutboundContent = '';
  int _lastKnownDraftLength = 0;
  Timer? _throttleTimer;
  Timer? _idleTimer;

  String _lastPartnerContent = '';
  Timer? _staleExpiryTimer;

  /// Only ever called once a chat surface is mounted, which AC5's pairing
  /// gate guarantees is after a successful login (same assumption
  /// `chat_repository.dart` makes for `_myId`/`_partnerId`).
  String get _myId => _backendUserIdStore.backendUserId!;
  String get _partnerId => _partnerStore.partnerId!;

  Future<void> _loadLocalOptIn() async {
    final bool optedIn = await _consentStore.hasOptedIn();
    _hasLocalOptIn = optedIn;
    if (isClosed) return;
    emit(state.copyWith(consentLevel: _recomputeConsentLevel()));
  }

  GhostConsentLevel _recomputeConsentLevel() {
    if (!_hasLocalOptIn || !_serverFlagEnabled) return GhostConsentLevel.off;
    return _hasReceivedGhostTypingThisSession
        ? GhostConsentLevel.on
        : GhostConsentLevel.pending;
  }

  /// Opts this device in (ADR-013e). Also the target of a composer toggle
  /// tap while `off` or `pending` — there is no direct off-toggle from the
  /// composer; opting out only happens from `ghostset`.
  Future<void> optIn() async {
    await _consentStore.optIn();
    _hasLocalOptIn = true;
    if (isClosed) return;
    emit(state.copyWith(consentLevel: _recomputeConsentLevel()));
  }

  /// Opts this device out (ADR-013e) and immediately stops any in-flight
  /// outbound emission.
  Future<void> optOut() async {
    await _consentStore.optOut();
    _hasLocalOptIn = false;
    _cancelSenderTimers();
    if (isClosed) return;
    emit(state.copyWith(consentLevel: GhostConsentLevel.off));
  }

  /// Composer toggle tap handler: while `on`, tapping is a no-op — the
  /// composer never re-toggles ghost back off (`coding-plan/phase-P3-typing
  /// -ghost.md` §3).
  Future<void> toggleTapped() async {
    if (state.consentLevel == GhostConsentLevel.on) return;
    await optIn();
  }

  /// Sender path (ADR-013b): call on every composer draft change. Emits are
  /// gated entirely on consent — while `off`, no `typing`/`stopTyping` is
  /// ever emitted.
  void draftChanged(String draft) {
    if (state.consentLevel == GhostConsentLevel.off) {
      _cancelSenderTimers();
      _lastKnownDraftLength = 0;
      return;
    }

    final bool isDeletion = draft.length < _lastKnownDraftLength;
    _lastKnownDraftLength = draft.length;
    _pendingOutboundContent = draft;

    if (isDeletion) {
      _throttleTimer?.cancel();
      _throttleTimer = null;
      _sendTyping(draft);
    } else {
      _throttleTimer ??= _timerFactory(
        ghostOutboundThrottleDuration,
        _flushThrottle,
      );
    }

    _idleTimer?.cancel();
    _idleTimer = _timerFactory(ghostSenderIdleDuration, _handleIdleElapsed);
  }

  void _flushThrottle() {
    _throttleTimer = null;
    _sendTyping(_pendingOutboundContent);
  }

  void _sendTyping(String content) {
    unawaited(_emitIgnoringNotLive(ChatEvents.typing, {
      'senderId': _myId,
      'receiverId': _partnerId,
      'content': content,
    }));
  }

  void _handleIdleElapsed() {
    _idleTimer = null;
    _throttleTimer?.cancel();
    _throttleTimer = null;
    unawaited(_emitIgnoringNotLive(ChatEvents.stopTyping, {
      'senderId': _myId,
      'receiverId': _partnerId,
    }));
  }

  void _cancelSenderTimers() {
    _throttleTimer?.cancel();
    _throttleTimer = null;
    _idleTimer?.cancel();
    _idleTimer = null;
  }

  Future<void> _emitIgnoringNotLive(String name, Object? payload) async {
    try {
      await _coordinator.emit(name, payload);
    } on RealtimeNotLiveFailure {
      // A ghost emit sent while offline is a silent no-op, matching
      // `ChatRepository._emitIgnoringNotLive`'s `markSeen` precedent.
    }
  }

  void _handleInboundEvent(RealtimeEvent event) {
    switch (event.name) {
      case ChatEvents.ghostTyping:
        _handleGhostTyping(event);
      case ChatEvents.ghostStopTyping:
        _handleGhostStopTyping();
    }
  }

  /// Receiver path (ADR-013b): diffs the new content against the previously
  /// received content and derives the struck-through deleted run
  /// receiver-side — the backend carries no deletion information. Also
  /// (re)arms the stale-expiry timer as a hard requirement: ephemeral events
  /// are dropped while backgrounded (ADR-012d/g), so a `ghostStopTyping` can
  /// be lost and would otherwise leave a stuck ghost bubble.
  void _handleGhostTyping(RealtimeEvent event) {
    final Object? rawContent = event.data['content'];
    final String content = rawContent is String ? rawContent : '';

    final String previous = _lastPartnerContent;
    _lastPartnerContent = content;

    String kept = content;
    String struck = '';
    if (content.length < previous.length && previous.startsWith(content)) {
      kept = content;
      struck = previous.substring(content.length);
    }

    _staleExpiryTimer?.cancel();
    _staleExpiryTimer = _timerFactory(
      ghostReceiverStaleExpiryDuration,
      _handleStaleExpiry,
    );

    _hasReceivedGhostTypingThisSession = true;
    if (isClosed) return;
    emit(state.copyWith(
      consentLevel: _recomputeConsentLevel(),
      partnerKeptContent: kept,
      partnerStruckContent: struck,
    ));
  }

  void _handleGhostStopTyping() {
    _staleExpiryTimer?.cancel();
    _staleExpiryTimer = null;
    _lastPartnerContent = '';
    if (isClosed) return;
    emit(state.copyWith(partnerKeptContent: '', partnerStruckContent: ''));
  }

  void _handleStaleExpiry() {
    _staleExpiryTimer = null;
    _lastPartnerContent = '';
    if (isClosed) return;
    emit(state.copyWith(partnerKeptContent: '', partnerStruckContent: ''));
  }

  @override
  Future<void> close() async {
    _cancelSenderTimers();
    _staleExpiryTimer?.cancel();
    await _eventsSubscription.cancel();
    return super.close();
  }
}
