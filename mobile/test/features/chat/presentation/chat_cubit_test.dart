import 'dart:async';

import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:cupid_mobile/features/chat/data/chat_repository.dart';
import 'package:cupid_mobile/features/chat/presentation/chat_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

const String _myId = 'me-1';
const String _partnerId = 'partner-1';

Message _message({
  required String id,
  required String senderId,
  String content = 'hi',
  String status = 'sent',
}) {
  return Message(
    id: id,
    senderId: senderId,
    receiverId: senderId == _myId ? _partnerId : _myId,
    content: content,
    type: 'text',
    status: status,
    readAt: null,
    createdAt: DateTime.utc(2026, 1, 1),
    cachedAt: DateTime.utc(2026, 1, 1),
  );
}

/// Fakes only the public surface `ChatCubit` depends on
/// (`mobile/lib/features/chat/data/chat_repository.dart`). Uses a
/// single-subscription controller — matching Drift's own `.watch()` stream
/// shape — so events added before `watchThread()` is listened to (simulating
/// pre-seeded cache rows) are buffered and delivered on first listen, exactly
/// like AC3 expects.
class _FakeChatRepository implements ChatRepository {
  final StreamController<List<Message>> _threadController =
      StreamController<List<Message>>();
  final List<String> calls = <String>[];
  Object? sendFailure;

  void emitThread(List<Message> messages) => _threadController.add(messages);

  @override
  Stream<List<Message>> watchThread() => _threadController.stream;

  @override
  Future<void> send(String text) async {
    calls.add('send:$text');
    final Object? failure = sendFailure;
    if (failure != null) throw failure;
  }

  @override
  Future<void> loadOlder() async => calls.add('loadOlder');

  @override
  Future<List<RealtimeEvent>> resyncPageOne() async {
    calls.add('resyncPageOne');
    return const <RealtimeEvent>[];
  }

  @override
  Future<void> markSeen() async => calls.add('markSeen');

  @override
  Stream<int> watchUnreadCount() => const Stream.empty();

  @override
  Future<void> dispose() async => _threadController.close();
}

class _FakeRealtimeCoordinator implements RealtimeCoordinator {
  final StreamController<RealtimeStatus> _statusController =
      StreamController<RealtimeStatus>.broadcast();

  void emitStatus(RealtimeStatus status) => _statusController.add(status);

  @override
  Stream<RealtimeEvent> events({Set<String>? names}) => const Stream.empty();

  @override
  Stream<RealtimeStatus> get status => _statusController.stream;

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<Object?> emit(String name, Object? payload) async => null;

  @override
  Future<void> resync() async {}

  Future<void> dispose() => _statusController.close();
}

BackendUserIdStore _signedInBackendUserIdStore() {
  return BackendUserIdStore()..updateFromLoginResponse({'id': _myId});
}

void main() {
  late _FakeChatRepository repository;
  late _FakeRealtimeCoordinator coordinator;

  setUp(() {
    repository = _FakeChatRepository();
    coordinator = _FakeRealtimeCoordinator();
  });

  tearDown(() async {
    await repository.dispose();
    await coordinator.dispose();
  });

  ChatCubit buildCubit() {
    return ChatCubit(
      repository: repository,
      coordinator: coordinator,
      backendUserIdStore: _signedInBackendUserIdStore(),
    );
  }

  test(
    'reflects a pre-seeded thread without ever surfacing an empty message '
    'list (AC3)',
    () async {
      final List<Message> seed = <Message>[
        _message(id: 'm1', senderId: _partnerId),
      ];
      repository.emitThread(seed);

      final ChatCubit cubit = buildCubit();
      addTearDown(cubit.close);

      final List<ChatState> states = <ChatState>[];
      final StreamSubscription<ChatState> subscription = cubit.stream.listen(
        states.add,
      );
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(states, isNotEmpty);
      expect(states.any((s) => s.messages.isEmpty), isFalse);
      expect(cubit.state.messages, seed);
    },
  );

  test(
    'shows the first-open empty state only after the initial fetch '
    'completes with zero rows (AC3)',
    () async {
      final ChatCubit cubit = buildCubit();
      addTearDown(cubit.close);

      expect(cubit.state.showEmptyState, isFalse);

      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.hasCompletedInitialFetch, isTrue);
      expect(cubit.state.showEmptyState, isTrue);
    },
  );

  test(
    'sendPressed forwards the trimmed draft and returns true on success '
    '(AC1)',
    () async {
      final ChatCubit cubit = buildCubit();
      addTearDown(cubit.close);

      final bool result = await cubit.sendPressed('  hello  ');

      expect(result, isTrue);
      expect(repository.calls, contains('send:hello'));
      expect(cubit.state.showNetworkUnavailableError, isFalse);
    },
  );

  test('sendPressed returns false for a blank draft without calling the '
      'repository', () async {
    final ChatCubit cubit = buildCubit();
    addTearDown(cubit.close);

    final bool result = await cubit.sendPressed('   ');

    expect(result, isFalse);
    expect(repository.calls.where((c) => c.startsWith('send')), isEmpty);
  });

  test(
    'sendPressed fails fast on RealtimeNotLiveFailure, keeps the draft (by '
    'returning false), does not retry, and reuses the network-unavailable '
    'copy signal (AC4)',
    () async {
      repository.sendFailure = const RealtimeNotLiveFailure();
      final ChatCubit cubit = buildCubit();
      addTearDown(cubit.close);

      final bool result = await cubit.sendPressed('hello');

      expect(result, isFalse);
      expect(repository.calls.where((c) => c == 'send:hello').length, 1);
      expect(cubit.state.showNetworkUnavailableError, isTrue);
      expect(cubit.state.messages, isEmpty);
    },
  );

  test('an inbound newMessage-driven repository emission appends to '
      'state.messages (AC1) and automatically marks seen if unread from partner', () async {
    final ChatCubit cubit = buildCubit();
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);

    final Message incoming = _message(id: 'm2', senderId: _partnerId, status: 'sent');
    repository.emitThread(<Message>[incoming]);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.messages, <Message>[incoming]);
    expect(repository.calls, contains('markSeen'));
  });

  test('a messageSeen-driven repository emission surfaces the seen status '
      'as a two-state read receipt (ADR-013d)', () async {
    final ChatCubit cubit = buildCubit();
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);

    final Message sentMessage = _message(id: 'm3', senderId: _myId);
    repository.emitThread(<Message>[sentMessage]);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.messages.single.status, 'sent');

    final Message seenMessage = _message(
      id: 'm3',
      senderId: _myId,
      status: 'seen',
    );
    repository.emitThread(<Message>[seenMessage]);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.messages.single.status, 'seen');
  });

  test('loadOlderRequested calls through to repository.loadOlder exactly '
      'once', () async {
    final ChatCubit cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.loadOlderRequested();

    expect(repository.calls.where((c) => c == 'loadOlder').length, 1);
  });

  test('markThreadSeen calls through to repository.markSeen (ADR-013d)', () async {
    final ChatCubit cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.markThreadSeen();

    expect(repository.calls, contains('markSeen'));
  });

  test(
    'connectionDegraded mirrors coordinator.status away from and back to '
    'live (ADR-013c)',
    () async {
      final ChatCubit cubit = buildCubit();
      addTearDown(cubit.close);

      coordinator.emitStatus(RealtimeStatus.offline);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.connectionDegraded, isTrue);

      coordinator.emitStatus(RealtimeStatus.live);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.connectionDegraded, isFalse);
    },
  );
}
