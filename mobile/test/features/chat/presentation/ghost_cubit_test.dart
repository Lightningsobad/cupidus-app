import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:cupid_mobile/features/chat/data/chat_events.dart';
import 'package:cupid_mobile/features/chat/data/chat_partner_store.dart';
import 'package:cupid_mobile/features/chat/data/ghost_consent_store.dart';
import 'package:cupid_mobile/features/chat/presentation/ghost_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _myId = 'me-1';
const String _partnerId = 'partner-1';

/// Mirrors `chat_repository_test.dart`'s fake adapter: every test scripts a
/// handler instead of making a real request.
class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this._handler);

  final Object? Function(RequestOptions options) _handler;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final body = _handler(options);
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _EmitCall {
  _EmitCall(this.name, this.payload);

  final String name;
  final Object? payload;
}

/// Fake [RealtimeCoordinator]: `GhostCubit` only ever uses `events(names:)`
/// and `emit`, never `status`.
class _FakeCoordinator implements RealtimeCoordinator {
  final List<_EmitCall> emitCalls = [];
  final _eventsController = StreamController<RealtimeEvent>.broadcast();

  @override
  Stream<RealtimeEvent> events({Set<String>? names}) {
    final stream = _eventsController.stream;
    if (names == null) return stream;
    return stream.where((event) => names.contains(event.name));
  }

  @override
  Stream<RealtimeStatus> get status => const Stream.empty();

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> resync() async {}

  @override
  Future<Object?> emit(String name, Object? payload) async {
    emitCalls.add(_EmitCall(name, payload));
    return null;
  }

  void fireEvent(RealtimeEvent event) => _eventsController.add(event);

  Future<void> dispose() => _eventsController.close();
}

RealtimeEvent _ghostEvent(String name, {String? content}) => GenericRealtimeEvent(
      name: name,
      id: null,
      data: content == null ? const {} : {'content': content},
      transport: RealtimeTransport.socket,
      receivedAt: DateTime.utc(2026, 7, 31),
    );

/// A scheduled call captured by [_FakeClock] instead of a real [Timer] — the
/// deterministic fake-clock seam `coding-plan/phase-P3-typing-ghost.md` §3
/// asks for, so all four ADR-013b constants are asserted without any real
/// wall-clock delay.
class _ScheduledEntry {
  _ScheduledEntry(this.duration, this.onElapsed);

  final Duration duration;
  final void Function() onElapsed;
  bool cancelled = false;
  bool fired = false;
}

class _FakeTimer implements Timer {
  _FakeTimer(this._entry);

  final _ScheduledEntry _entry;

  @override
  void cancel() => _entry.cancelled = true;

  @override
  bool get isActive => !_entry.cancelled && !_entry.fired;

  @override
  int get tick => 0;
}

class _FakeClock {
  final List<_ScheduledEntry> _scheduled = [];

  Timer schedule(Duration duration, void Function() onElapsed) {
    final entry = _ScheduledEntry(duration, onElapsed);
    _scheduled.add(entry);
    return _FakeTimer(entry);
  }

  /// Fires the most recently armed (not cancelled, not already fired) entry
  /// for [duration] — mirrors a real `Timer` elapsing. Throws if nothing is
  /// armed, so a test bug never silently becomes a no-op.
  void elapse(Duration duration) {
    final _ScheduledEntry entry = _scheduled.lastWhere(
      (e) => e.duration == duration && !e.cancelled && !e.fired,
      orElse: () => throw StateError('no armed timer for $duration'),
    );
    entry.fired = true;
    entry.onElapsed();
  }

  int countArmed(Duration duration) => _scheduled
      .where((e) => e.duration == duration && !e.cancelled && !e.fired)
      .length;
}

class _TestContext {
  _TestContext({
    required this.coordinator,
    required this.clock,
    required this.consentStore,
    required this.cubit,
  });

  final _FakeCoordinator coordinator;
  final _FakeClock clock;
  final GhostConsentStore consentStore;
  final GhostCubit cubit;

  Future<void> dispose() async {
    await cubit.close();
    await coordinator.dispose();
  }
}

Object? _usersMeHandler(RequestOptions options, bool serverGhostEnabled) {
  if (options.method == 'GET') {
    return {
      'partnerId': _partnerId,
      'displayName': 'Partner One',
      'isGhostModeEnabled': serverGhostEnabled,
    };
  }
  return null;
}

/// Builds a ready [GhostCubit] wired to fakes. `serverGhostEnabled` mirrors
/// `User.isGhostModeEnabled` (ADR-013e defaults this `true` server-side,
/// which is exactly the case informed local opt-in must still gate).
Future<_TestContext> _buildContext({bool serverGhostEnabled = true}) async {
  final adapter = _FakeHttpClientAdapter(
    (options) => _usersMeHandler(options, serverGhostEnabled),
  );
  final dio = Dio()..httpClientAdapter = adapter;
  final partnerStore = ChatPartnerStore(dio: dio);
  await partnerStore.refreshFromServer();
  final consentStore = GhostConsentStore(dio: dio);
  final backendUserIdStore = BackendUserIdStore()
    ..updateFromLoginResponse({'id': _myId});
  final coordinator = _FakeCoordinator();
  final clock = _FakeClock();

  final cubit = GhostCubit(
    coordinator: coordinator,
    consentStore: consentStore,
    partnerStore: partnerStore,
    backendUserIdStore: backendUserIdStore,
    timerFactory: clock.schedule,
  );
  // Lets the constructor's unawaited `_loadLocalOptIn()` resolve before any
  // assertion, matching `chat_cubit_test.dart`'s `Future<void>.delayed(Duration.zero)`
  // convention for cubits with async constructor work.
  await Future<void>.delayed(Duration.zero);

  return _TestContext(
    coordinator: coordinator,
    clock: clock,
    consentStore: consentStore,
    cubit: cubit,
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('sender timing (ADR-013b, AC2)', () {
    test(
      'rapid keystrokes within the throttle window produce one trailing '
      'typing emit with the latest content',
      () async {
        SharedPreferences.setMockInitialValues({
          'cupid_ghost_local_opt_in_v1': true,
        });
        final ctx = await _buildContext();

        ctx.cubit.draftChanged('h');
        ctx.cubit.draftChanged('he');
        ctx.cubit.draftChanged('hel');

        expect(
          ctx.coordinator.emitCalls.where((c) => c.name == ChatEvents.typing),
          isEmpty,
        );

        ctx.clock.elapse(ghostOutboundThrottleDuration);

        final typingCalls = ctx.coordinator.emitCalls
            .where((c) => c.name == ChatEvents.typing)
            .toList();
        expect(typingCalls, hasLength(1));
        expect(
          typingCalls.single.payload,
          {'senderId': _myId, 'receiverId': _partnerId, 'content': 'hel'},
        );

        await ctx.dispose();
      },
    );

    test(
      'a content-length decrease flushes immediately even inside an active '
      'throttle window',
      () async {
        SharedPreferences.setMockInitialValues({
          'cupid_ghost_local_opt_in_v1': true,
        });
        final ctx = await _buildContext();

        ctx.cubit.draftChanged('hello');
        expect(ctx.clock.countArmed(ghostOutboundThrottleDuration), 1);

        ctx.cubit.draftChanged('he');

        final typingCalls = ctx.coordinator.emitCalls
            .where((c) => c.name == ChatEvents.typing)
            .toList();
        expect(typingCalls, hasLength(1));
        expect(
          typingCalls.single.payload,
          {'senderId': _myId, 'receiverId': _partnerId, 'content': 'he'},
        );
        expect(ctx.clock.countArmed(ghostOutboundThrottleDuration), 0);

        await ctx.dispose();
      },
    );

    test(
      '1200ms of no further keystrokes produces exactly one stopTyping emit',
      () async {
        SharedPreferences.setMockInitialValues({
          'cupid_ghost_local_opt_in_v1': true,
        });
        final ctx = await _buildContext();

        ctx.cubit.draftChanged('h');
        ctx.clock.elapse(ghostSenderIdleDuration);

        final stopCalls = ctx.coordinator.emitCalls
            .where((c) => c.name == ChatEvents.stopTyping)
            .toList();
        expect(stopCalls, hasLength(1));
        expect(
          stopCalls.single.payload,
          {'senderId': _myId, 'receiverId': _partnerId},
        );
        expect(ctx.clock.countArmed(ghostOutboundThrottleDuration), 0);

        await ctx.dispose();
      },
    );

    test('draftChanged never emits while consent is off', () async {
      final ctx = await _buildContext();
      expect(ctx.cubit.state.consentLevel, GhostConsentLevel.off);

      ctx.cubit.draftChanged('h');
      ctx.cubit.draftChanged('he');

      expect(ctx.coordinator.emitCalls, isEmpty);
      expect(ctx.clock.countArmed(ghostOutboundThrottleDuration), 0);
      expect(ctx.clock.countArmed(ghostSenderIdleDuration), 0);

      await ctx.dispose();
    });
  });

  group('receiver timing and deleted-run derivation (ADR-013b, AC2)', () {
    test(
      '6000ms with no further ghostTyping clears the partner ghost bubble '
      'even when no ghostStopTyping arrives',
      () async {
        final ctx = await _buildContext();

        ctx.coordinator.fireEvent(_ghostEvent(ChatEvents.ghostTyping, content: 'hi'));
        await Future<void>.delayed(Duration.zero);
        expect(ctx.cubit.state.isPartnerGhosting, isTrue);

        ctx.clock.elapse(ghostReceiverStaleExpiryDuration);

        expect(ctx.cubit.state.isPartnerGhosting, isFalse);
        expect(ctx.cubit.state.partnerKeptContent, isEmpty);
        expect(ctx.cubit.state.partnerStruckContent, isEmpty);

        await ctx.dispose();
      },
    );

    test('a ghostStopTyping event clears the partner ghost bubble', () async {
      final ctx = await _buildContext();

      ctx.coordinator.fireEvent(_ghostEvent(ChatEvents.ghostTyping, content: 'hi'));
      await Future<void>.delayed(Duration.zero);
      expect(ctx.cubit.state.isPartnerGhosting, isTrue);

      ctx.coordinator.fireEvent(_ghostEvent(ChatEvents.ghostStopTyping));
      await Future<void>.delayed(Duration.zero);

      expect(ctx.cubit.state.isPartnerGhosting, isFalse);

      await ctx.dispose();
    });

    test('feeding "hello" then "he" yields a struck-through "llo" run', () async {
      final ctx = await _buildContext();

      ctx.coordinator.fireEvent(_ghostEvent(ChatEvents.ghostTyping, content: 'hello'));
      await Future<void>.delayed(Duration.zero);
      expect(ctx.cubit.state.partnerKeptContent, 'hello');
      expect(ctx.cubit.state.partnerStruckContent, isEmpty);

      ctx.coordinator.fireEvent(_ghostEvent(ChatEvents.ghostTyping, content: 'he'));
      await Future<void>.delayed(Duration.zero);

      expect(ctx.cubit.state.partnerKeptContent, 'he');
      expect(ctx.cubit.state.partnerStruckContent, 'llo');

      await ctx.dispose();
    });
  });

  group('consent state machine (ADR-013e)', () {
    test(
      'server flag true but no local opt-in renders off and never emits '
      'typing',
      () async {
        final ctx = await _buildContext();

        expect(ctx.cubit.state.consentLevel, GhostConsentLevel.off);

        ctx.cubit.draftChanged('h');
        expect(ctx.coordinator.emitCalls, isEmpty);

        await ctx.dispose();
      },
    );

    test(
      'optIn enters pending, and the first received ghostTyping moves it to '
      'on',
      () async {
        final ctx = await _buildContext();
        expect(ctx.cubit.state.consentLevel, GhostConsentLevel.off);

        await ctx.cubit.optIn();
        expect(ctx.cubit.state.consentLevel, GhostConsentLevel.pending);

        ctx.coordinator.fireEvent(_ghostEvent(ChatEvents.ghostTyping, content: 'hi'));
        await Future<void>.delayed(Duration.zero);

        expect(ctx.cubit.state.consentLevel, GhostConsentLevel.on);

        await ctx.dispose();
      },
    );

    test('toggleTapped is a no-op while on, and opts in while off/pending', () async {
      final ctx = await _buildContext();

      await ctx.cubit.toggleTapped();
      expect(ctx.cubit.state.consentLevel, GhostConsentLevel.pending);

      ctx.coordinator.fireEvent(_ghostEvent(ChatEvents.ghostTyping, content: 'hi'));
      await Future<void>.delayed(Duration.zero);
      expect(ctx.cubit.state.consentLevel, GhostConsentLevel.on);

      await ctx.cubit.toggleTapped();
      expect(ctx.cubit.state.consentLevel, GhostConsentLevel.on);

      await ctx.dispose();
    });

    test('optOut returns to off and cancels any in-flight sender timers', () async {
      SharedPreferences.setMockInitialValues({
        'cupid_ghost_local_opt_in_v1': true,
      });
      final ctx = await _buildContext();
      ctx.cubit.draftChanged('h');
      expect(ctx.clock.countArmed(ghostOutboundThrottleDuration), 1);

      await ctx.cubit.optOut();

      expect(ctx.cubit.state.consentLevel, GhostConsentLevel.off);
      expect(ctx.clock.countArmed(ghostOutboundThrottleDuration), 0);
      expect(ctx.clock.countArmed(ghostSenderIdleDuration), 0);

      await ctx.dispose();
    });
  });

  group('no-persistence guard (architecture/solution.md §2 invariant 3)', () {
    test('ghost_cubit.dart never references Drift or a database', () {
      final file = File('lib/features/chat/presentation/ghost_cubit.dart');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      expect(content.contains('drift'), isFalse);
      expect(content.contains('Database'), isFalse);
      expect(content.contains('Dao'), isFalse);
    });

    test(
      'GhostConsentStore persists only the boolean opt-in flag, never draft '
      'content',
      () async {
        final adapter = _FakeHttpClientAdapter(
          (options) => _usersMeHandler(options, true),
        );
        final dio = Dio()..httpClientAdapter = adapter;
        final store = GhostConsentStore(dio: dio);

        await store.optIn();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getKeys(), {'cupid_ghost_local_opt_in_v1'});
        expect(prefs.getBool('cupid_ghost_local_opt_in_v1'), isTrue);
      },
    );

    test(
      'a full receiver ghost session leaves shared_preferences with only '
      'the opt-in flag, never draft content',
      () async {
        SharedPreferences.setMockInitialValues({
          'cupid_ghost_local_opt_in_v1': true,
        });
        final ctx = await _buildContext();

        ctx.coordinator.fireEvent(
          _ghostEvent(ChatEvents.ghostTyping, content: 'a secret draft'),
        );
        await Future<void>.delayed(Duration.zero);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getKeys(), {'cupid_ghost_local_opt_in_v1'});

        await ctx.dispose();
      },
    );
  });
}
