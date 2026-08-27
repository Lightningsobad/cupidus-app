import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/network/cupid_error_interceptor.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/anti_ghosting/anti_ghosting.dart';
import 'package:cupid_mobile/features/chat/data/chat_events.dart';
import 'package:cupid_mobile/features/chat/data/chat_partner_store.dart';
import 'package:cupid_mobile/features/chat/data/chat_repository.dart';
import 'package:cupid_mobile/features/chat/data/ghost_consent_store.dart';
import 'package:cupid_mobile/features/chat/presentation/screens/chat_screen.dart';
import 'package:cupid_mobile/features/chat/presentation/widgets/chat_composer.dart';
import 'package:cupid_mobile/features/chat/presentation/widgets/ghost_bubble.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _myId = 'me-1';
const String _partnerId = 'partner-1';
const String _displayName = 'Partner One';
const String _seenNoReplyCopy = 'Seen, no reply yet';
const String _stormCtaCopy = 'Fire Emoji Storm';

/// Routes `GET /users/me` and `GET /ghost-config/storm-status/:partnerId` off
/// one transport so a single test can drive both the chat partner cache and
/// the row's own storm poll, and can count storm requests.
class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter({required this.partnerId, required this.stormBody});

  final String? partnerId;
  final Map<String, Object?> stormBody;
  final List<RequestOptions> requests = <RequestOptions>[];

  Iterable<RequestOptions> get stormRequests =>
      requests.where((r) => r.path.startsWith('/ghost-config/storm-status/'));

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final Object? body;
    if (options.path.startsWith('/ghost-config/storm-status/')) {
      body = stormBody;
    } else {
      body = <String, Object?>{
        'partnerId': partnerId,
        'displayName': _displayName,
        'isGhostModeEnabled': false,
      };
    }
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

/// `_FakeChatRepository` and `_FakeRealtimeCoordinator` in `chat_cubit_test.dart`
/// are private to that library, so the same shapes are re-declared here rather
/// than exported from it.
class _FakeChatRepository implements ChatRepository {
  final StreamController<List<Message>> _threadController =
      StreamController<List<Message>>();

  @override
  Stream<List<Message>> watchThread() => _threadController.stream;

  @override
  Future<void> send(String text) async {}

  @override
  Future<void> loadOlder() async {}

  @override
  Future<List<RealtimeEvent>> resyncPageOne() async => const <RealtimeEvent>[];

  @override
  Future<void> markSeen() async {}

  @override
  Stream<int> watchUnreadCount() => const Stream.empty();

  @override
  Future<void> dispose() async => _threadController.close();
}

class _FakeRealtimeCoordinator implements RealtimeCoordinator {
  final StreamController<RealtimeStatus> _statusController =
      StreamController<RealtimeStatus>.broadcast();
  final StreamController<RealtimeEvent> _eventsController =
      StreamController<RealtimeEvent>.broadcast();

  void fireEvent(RealtimeEvent event) => _eventsController.add(event);

  @override
  Stream<RealtimeEvent> events({Set<String>? names}) {
    final Stream<RealtimeEvent> stream = _eventsController.stream;
    if (names == null) return stream;
    return stream.where((event) => names.contains(event.name));
  }

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

  Future<void> dispose() async {
    await _statusController.close();
    await _eventsController.close();
  }
}

RealtimeEvent _ghostTypingEvent(String content) => GenericRealtimeEvent(
      name: ChatEvents.ghostTyping,
      id: null,
      data: {'content': content},
      transport: RealtimeTransport.socket,
      receivedAt: DateTime.utc(2026, 8, 12),
    );

class _Harness {
  _Harness({
    required this.widget,
    required this.adapter,
    required this.coordinator,
  });

  final Widget widget;
  final _FakeHttpClientAdapter adapter;
  final _FakeRealtimeCoordinator coordinator;
}

/// [partnerId] `null` reproduces the unpaired defensive path; `registerConfig`
/// `false` reproduces a harness that never called `setupServiceLocator()`.
Future<_Harness> _buildHarness({
  required Key key,
  String? partnerId = _partnerId,
  Map<String, Object?> stormBody = const {'eligible': false, 'penalty': null},
  bool registerConfig = true,
}) async {
  final adapter = _FakeHttpClientAdapter(
    partnerId: partnerId,
    stormBody: stormBody,
  );
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost'))
    ..httpClientAdapter = adapter
    ..interceptors.add(const CupidErrorInterceptor());

  if (registerConfig) {
    getIt.registerSingleton<GhostConfigRepository>(
      GhostConfigRepository(api: CupidApi(dio: dio, interceptors: const [])),
    );
  }

  final partnerStore = ChatPartnerStore(dio: dio);
  await partnerStore.refreshFromServer();
  final repository = _FakeChatRepository();
  final coordinator = _FakeRealtimeCoordinator();

  return _Harness(
    adapter: adapter,
    coordinator: coordinator,
    widget: MaterialApp(
      theme: buildCupidTheme(
        platform: CupidPlatform.material,
        brightness: Brightness.light,
      ),
      locale: const Locale('en'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: ChatScreen(
        key: key,
        repository: repository,
        coordinator: coordinator,
        backendUserIdStore: BackendUserIdStore()
          ..updateFromLoginResponse({'id': _myId}),
        partnerStore: partnerStore,
        consentStore: GhostConsentStore(dio: dio),
      ),
    ),
  );
}

/// `GhostBubble` runs a repeating cursor animation, so `pumpAndSettle` never
/// converges once the bubble is on screen. Pumping a bounded number of short
/// frames drains the storm-status future and the ghost event stream without
/// reaching the row's 60s poll tick.
Future<void> _settle(WidgetTester tester) async {
  for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

/// `refreshFromServer` only completes on the real event loop, so harness
/// construction runs outside the fake-async zone `testWidgets` installs.
Future<T> _realAsync<T>(WidgetTester tester, Future<T> Function() body) async {
  return (await tester.runAsync(body)) as T;
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await getIt.reset();
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets(
    'AC1: for a paired user with an eligible storm status the row renders '
    'below the Typing-Ghost bubble and above the composer',
    (tester) async {
      final _Harness harness = await _realAsync(
        tester,
        () => _buildHarness(
          key: const ValueKey('eligible'),
          stormBody: const {'eligible': true, 'penalty': 'emoji_storm'},
        ),
      );

      await tester.pumpWidget(harness.widget);
      harness.coordinator.fireEvent(_ghostTypingEvent('hello'));
      await _settle(tester);

      expect(find.byType(GhostStateRow), findsOneWidget);
      expect(find.text(_seenNoReplyCopy), findsOneWidget);
      expect(find.text(_stormCtaCopy), findsOneWidget);
      expect(find.byType(GhostBubble), findsOneWidget);

      final double bubbleBottom =
          tester.getBottomLeft(find.byType(GhostBubble)).dy;
      final Rect row = tester.getRect(find.byType(GhostStateRow));
      final double composerTop =
          tester.getTopLeft(find.byType(ChatComposer)).dy;

      expect(row.height, greaterThan(0));
      expect(row.top, greaterThanOrEqualTo(bubbleBottom));
      expect(row.bottom, lessThanOrEqualTo(composerTop));
    },
  );

  testWidgets(
    'AC2: a non-eligible storm status renders no copy and costs no layout '
    'against the unmounted baseline',
    (tester) async {
      // The baseline is the pre-mount layout: an unpaired user never mounts
      // the row, so its config repository is deliberately left unregistered
      // and the two harnesses can be built back to back.
      final List<_Harness> harnesses = await _realAsync(tester, () async {
        return <_Harness>[
          await _buildHarness(
            key: const ValueKey('baseline'),
            partnerId: null,
            registerConfig: false,
          ),
          await _buildHarness(
            key: const ValueKey('mounted'),
            stormBody: const {'eligible': false, 'penalty': 'emoji_storm'},
          ),
        ];
      });

      await tester.pumpWidget(harnesses[0].widget);
      await _settle(tester);
      expect(find.byType(GhostStateRow), findsNothing);
      final Rect baselineComposer = tester.getRect(find.byType(ChatComposer));

      await tester.pumpWidget(harnesses[1].widget);
      await _settle(tester);

      expect(find.byType(GhostStateRow), findsOneWidget);
      expect(find.text(_seenNoReplyCopy), findsNothing);
      expect(find.text(_stormCtaCopy), findsNothing);
      expect(tester.getSize(find.byType(GhostStateRow)).height, 0);
      expect(tester.getRect(find.byType(ChatComposer)), baselineComposer);
    },
  );

  testWidgets(
    'AC2: an unregistered GhostConfigRepository renders no copy and costs no '
    'layout',
    (tester) async {
      final _Harness harness = await _realAsync(
        tester,
        () => _buildHarness(
          key: const ValueKey('unregistered'),
          stormBody: const {'eligible': true, 'penalty': 'emoji_storm'},
          registerConfig: false,
        ),
      );

      await tester.pumpWidget(harness.widget);
      await _settle(tester);

      expect(find.byType(GhostStateRow), findsOneWidget);
      expect(find.text(_seenNoReplyCopy), findsNothing);
      expect(tester.getSize(find.byType(GhostStateRow)).height, 0);
      expect(harness.adapter.stormRequests, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'AC3: a null partnerId keeps GhostStateRow out of the tree entirely',
    (tester) async {
      final _Harness harness = await _realAsync(
        tester,
        () => _buildHarness(
          key: const ValueKey('unpaired'),
          partnerId: null,
          stormBody: const {'eligible': true, 'penalty': 'emoji_storm'},
        ),
      );

      await tester.pumpWidget(harness.widget);
      await _settle(tester);

      expect(find.byType(GhostStateRow), findsNothing);
      expect(find.text(_seenNoReplyCopy), findsNothing);
      expect(harness.adapter.stormRequests, isEmpty);
    },
  );

  testWidgets(
    'AC4: chat contributes no second GhostStormCubit provider, so the row '
    'drives exactly one storm poll',
    (tester) async {
      final _Harness harness = await _realAsync(
        tester,
        () => _buildHarness(
          key: const ValueKey('single-poll'),
          stormBody: const {'eligible': true, 'penalty': 'emoji_storm'},
        ),
      );

      await tester.pumpWidget(harness.widget);
      await _settle(tester);

      expect(find.byType(BlocProvider<GhostStormCubit>), findsOneWidget);
      expect(harness.adapter.stormRequests, hasLength(1));
      expect(
        harness.adapter.stormRequests.single.path,
        '/ghost-config/storm-status/$_partnerId',
      );
    },
  );
}
