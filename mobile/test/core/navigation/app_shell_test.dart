import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/navigation/app_shell.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/chat/data/chat_partner_store.dart';
import 'package:cupid_mobile/features/chat/data/chat_repository.dart';
import 'package:cupid_mobile/features/chat/data/ghost_consent_store.dart';
import 'package:cupid_mobile/features/chat/presentation/screens/chat_screen.dart';
import 'package:cupid_mobile/features/chat/presentation/screens/ghost_settings_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fake [HttpClientAdapter]; mirrors
/// `test/features/chat/data/chat_repository_test.dart`.
class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this._handler);

  final Object? Function(RequestOptions options) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
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

/// Fake [RealtimeCoordinator]; mirrors
/// `test/features/chat/presentation/chat_cubit_test.dart`.
class _FakeRealtimeCoordinator implements RealtimeCoordinator {
  final StreamController<RealtimeStatus> _statusController =
      StreamController<RealtimeStatus>.broadcast();

  @override
  Stream<RealtimeEvent> events({Set<String>? names}) => const Stream.empty();

  @override
  Stream<RealtimeStatus> get status => _statusController.stream;

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> resync() async {}

  @override
  Future<Object?> emit(String name, Object? payload) async => null;

  Future<void> dispose() => _statusController.close();
}

/// Fakes only the public surface `ChatCubit`/`ChatScreen` depend on; mirrors
/// `test/features/chat/presentation/chat_cubit_test.dart`. Avoids a real
/// Drift-backed `ChatRepository` here since this suite only exercises
/// shell navigation, not thread persistence.
class _FakeChatRepository implements ChatRepository {
  final StreamController<List<Message>> _threadController =
      StreamController<List<Message>>();

  void emitThread(List<Message> messages) => _threadController.add(messages);

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
  Future<void> dispose() async {
    // `close()`'s returned Future only completes once a listener processes
    // the done event; the unpaired-shell test never mounts `ChatScreen`, so
    // this controller has no listener and awaiting `close()` directly would
    // hang forever. Fire-and-forget instead.
    unawaited(_threadController.close());
  }
}

const String _myId = 'me-1';
const String _partnerId = 'partner-1';

Widget _harness({
  required bool paired,
  required _FakeChatRepository chatRepository,
  required _FakeRealtimeCoordinator coordinator,
}) {
  final adapter = _FakeHttpClientAdapter((options) {
    if (options.path == '/users/me') {
      return {
        'partnerId': paired ? _partnerId : null,
        'displayName': paired ? 'Partner One' : null,
        'isGhostModeEnabled': false,
      };
    }
    return <String, Object?>{};
  });
  final dio = Dio()..httpClientAdapter = adapter;
  final partnerStore = ChatPartnerStore(dio: dio);
  final backendUserIdStore = BackendUserIdStore()
    ..updateFromLoginResponse({'id': _myId});
  chatRepository.emitThread(const <Message>[]);
  final consentStore = GhostConsentStore(dio: dio);

  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: AppShell(
      partnerStore: partnerStore,
      chatRepository: chatRepository,
      coordinator: coordinator,
      backendUserIdStore: backendUserIdStore,
      consentStore: consentStore,
    ),
  );
}

void main() {
  late _FakeChatRepository chatRepository;
  late _FakeRealtimeCoordinator coordinator;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    chatRepository = _FakeChatRepository();
    coordinator = _FakeRealtimeCoordinator();
  });

  tearDown(() async {
    await chatRepository.dispose();
    await coordinator.dispose();
  });

  testWidgets(
    'paired: Home renders with the readiness key, Chat is reachable, and '
    'the ghostset action opens GhostSettingsScreen from Chat',
    (tester) async {
      await tester.pumpWidget(
        _harness(
          paired: true,
          chatRepository: chatRepository,
          coordinator: coordinator,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home_screen_ready_signal')), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(CupidTabBar),
          matching: find.byType(InkWell),
        ),
        findsNWidgets(2),
      );

      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();

      expect(find.byType(ChatScreen), findsOneWidget);
      expect(
        find.byKey(const Key('home_screen_ready_signal')),
        findsNothing,
      );

      await tester.tap(find.byKey(const Key('ghost_settings_entry_action')));
      await tester.pumpAndSettle();

      expect(find.byType(GhostSettingsScreen), findsOneWidget);
    },
  );

  testWidgets(
    'unpaired: Chat is hidden, Home still renders with the readiness key, '
    'no pet/money/me destinations exist',
    (tester) async {
      await tester.pumpWidget(
        _harness(
          paired: false,
          chatRepository: chatRepository,
          coordinator: coordinator,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home_screen_ready_signal')), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Chat'), findsNothing);
      expect(find.text('Pet'), findsNothing);
      expect(find.text('Money'), findsNothing);
      expect(find.text('Me'), findsNothing);
      expect(
        find.descendant(
          of: find.byType(CupidTabBar),
          matching: find.byType(InkWell),
        ),
        findsNWidgets(1),
      );
    },
  );

  group('STORY-005 pairing-source isolation guard', () {
    test('chat_entry_gate.dart depends only on chat_partner_store.dart, '
        'never a pairing source file', () {
      final file = File('lib/features/chat/presentation/chat_entry_gate.dart');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      expect(content.contains('pairing'), isFalse);
      expect(content.contains('STORY-005'), isFalse);
    });

    test('app_shell.dart never imports a features/pairing source file', () {
      final file = File('lib/core/navigation/app_shell.dart');
      final content = file.readAsStringSync();
      expect(content.contains('features/pairing'), isFalse);
    });
  });
}
