import 'dart:async';

import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/chat_repository.dart';

/// Immutable UI state for `ChatScreen` (`ux/uiux-spec.md` §3, AC1/AC3/AC4).
class ChatState {
  const ChatState({
    required this.myId,
    this.messages = const <Message>[],
    this.hasCompletedInitialFetch = false,
    this.connectionDegraded = false,
    this.showNetworkUnavailableError = false,
  });

  /// This device's own backend `User.id` — used by `ChatScreen` to decide
  /// mine-vs-theirs bubble styling (`ux/uiux-spec.md` §3b).
  final String myId;

  /// Ascending-by-`createdAt` thread page, mirrored straight from
  /// [ChatRepository.watchThread] (AC1, AC3).
  final List<Message> messages;

  /// `true` once the constructor's page-1 [ChatRepository.resyncPageOne]
  /// call has settled — the only signal [showEmptyState] uses to
  /// distinguish "not loaded yet" from "genuinely empty" (AC3, `ux/uiux-spec
  /// .md` §3c first-ever-open case).
  final bool hasCompletedInitialFetch;

  /// Mirrors `RealtimeCoordinator.status != RealtimeStatus.live`
  /// (`architecture/solution.md` ADR-013c) as a subtle non-blocking banner —
  /// never a presence dot on the peer.
  final bool connectionDegraded;

  /// Set when the most recent send attempt failed with
  /// `RealtimeNotLiveFailure` (AC4); cleared on the next successful send.
  final bool showNetworkUnavailableError;

  /// Shown only once the initial fetch has completed and the thread is
  /// still empty — never during the initial fetch itself (AC3, `ux/uiux-spec
  /// .md` §3c).
  bool get showEmptyState => hasCompletedInitialFetch && messages.isEmpty;

  ChatState copyWith({
    List<Message>? messages,
    bool? hasCompletedInitialFetch,
    bool? connectionDegraded,
    bool? showNetworkUnavailableError,
  }) {
    return ChatState(
      myId: myId,
      messages: messages ?? this.messages,
      hasCompletedInitialFetch:
          hasCompletedInitialFetch ?? this.hasCompletedInitialFetch,
      connectionDegraded: connectionDegraded ?? this.connectionDegraded,
      showNetworkUnavailableError:
          showNetworkUnavailableError ?? this.showNetworkUnavailableError,
    );
  }
}

/// Cubit for the `chat` thread screen
/// (`coding-plan/phase-P2-chat-screen.md` §3, AC1/AC3/AC4). Delegates every
/// read/write to [ChatRepository]; never touches Drift, `Dio`, or the socket
/// transport directly (D2, ADR-003).
class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required ChatRepository repository,
    required RealtimeCoordinator coordinator,
    required BackendUserIdStore backendUserIdStore,
  }) : _repository = repository,
       _coordinator = coordinator,
       super(ChatState(myId: backendUserIdStore.backendUserId ?? '')) {
    _threadSubscription = _repository.watchThread().listen(_handleThread);
    _statusSubscription = _coordinator.status.listen(_handleStatus);
    unawaited(_loadInitialPage());
  }

  final ChatRepository _repository;
  final RealtimeCoordinator _coordinator;
  late final StreamSubscription<List<Message>> _threadSubscription;
  late final StreamSubscription<RealtimeStatus> _statusSubscription;

  Future<void> _loadInitialPage() async {
    await _repository.resyncPageOne();
    if (!isClosed) emit(state.copyWith(hasCompletedInitialFetch: true));
  }

  void _handleThread(List<Message> messages) {
    if (isClosed) return;
    emit(state.copyWith(messages: messages));
  }

  void _handleStatus(RealtimeStatus status) {
    if (isClosed) return;
    emit(state.copyWith(connectionDegraded: status != RealtimeStatus.live));
  }

  /// Sends [draft] via [ChatRepository.send]. Returns `true` on success, so
  /// the composer clears its draft only then. On `RealtimeNotLiveFailure`
  /// (AC4) no bubble is added and no retry is attempted; the caller keeps
  /// its draft text as-is and [ChatState.showNetworkUnavailableError] is set
  /// so the composer surfaces the reused `NetworkUnavailableFailure` copy
  /// (`auth_failure_text.dart`) instead of inventing new offline copy.
  Future<bool> sendPressed(String draft) async {
    final String text = draft.trim();
    if (text.isEmpty) return false;
    try {
      await _repository.send(text);
      if (!isClosed && state.showNetworkUnavailableError) {
        emit(state.copyWith(showNetworkUnavailableError: false));
      }
      return true;
    } on RealtimeNotLiveFailure {
      if (!isClosed) emit(state.copyWith(showNetworkUnavailableError: true));
      return false;
    }
  }

  /// Fetches the next older page (`ux/uiux-spec.md` §3c pagination).
  Future<void> loadOlderRequested() => _repository.loadOlder();

  /// Marks the visible thread as seen (ADR-013d: `markSeen` only). Called
  /// once per screen mount from `ChatScreen.initState`.
  Future<void> markThreadSeen() => _repository.markSeen();

  @override
  Future<void> close() async {
    await _threadSubscription.cancel();
    await _statusSubscription.cancel();
    return super.close();
  }
}
