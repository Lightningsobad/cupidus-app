import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';
import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/navigation/app_shell.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/account/data/account_repository.dart';
import 'package:cupid_mobile/features/account/presentation/screens/me_screen.dart';
import 'package:cupid_mobile/features/chat/data/chat_partner_store.dart';
import 'package:cupid_mobile/features/chat/data/chat_repository.dart';
import 'package:cupid_mobile/features/chat/data/ghost_consent_store.dart';
import 'package:cupid_mobile/features/chat/presentation/screens/chat_screen.dart';
import 'package:cupid_mobile/features/chat/presentation/screens/ghost_settings_screen.dart';
import 'package:cupid_mobile/features/chat/presentation/widgets/chat_composer.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar_repository.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/screens/dream_jar_list_screen.dart';
import 'package:cupid_mobile/features/pet/data/pet_repository.dart';
import 'package:cupid_mobile/features/pet/presentation/pet_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:cupid_mobile/preview/preview_app_shell_chrome.dart';
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
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
    // STORY-061 P2: the Pet and Ví chung destination bodies now load through
    // this same adapter. Both endpoints have a documented "nothing yet" shape
    // — `null` for `/pets/status`, an empty array for `/dream-jar` — so the
    // shell tests exercise the destination wiring, not a parse failure.
    if (options.path == '/pets/status') {
      return null;
    }
    if (options.path == '/dream-jar') {
      return <Object?>[];
    }
    return <String, Object?>{};
  });
  final dio = Dio()..httpClientAdapter = adapter;
  final partnerStore = ChatPartnerStore(dio: dio);
  final backendUserIdStore = BackendUserIdStore()
    ..updateFromLoginResponse({'id': _myId});
  chatRepository.emitThread(const <Message>[]);
  final consentStore = GhostConsentStore(dio: dio);
  // The Home tab's `_TimelineEntryPointGate` resolves its own
  // `CouplePairingStore` through GetIt (`app_shell.dart` has no override
  // hook for it, unlike the stores above); register one backed by the same
  // fake `/users/me` adapter so the Home tab renders without a real network
  // call.
  final api = CupidApi(dio: dio, interceptors: const []);
  getIt.registerSingleton<CouplePairingStore>(
    CouplePairingStore(api: api, backendUserIdStore: backendUserIdStore),
  );
  // STORY-061 P2: the Pet / Ví chung / Tôi destination bodies resolve their
  // repositories through GetIt at build time, so selecting those tabs needs
  // registrations. They are backed by the same fake adapter, which answers
  // every non-`/users/me` path with an empty object — enough to mount each
  // screen, which is what the destination-set assertions are about.
  getIt.registerSingleton<PetRepository>(PetRepository(api: api));
  getIt.registerSingleton<DreamJarRepository>(DreamJarRepository(api));
  getIt.registerSingleton<AccountRepository>(AccountRepository(api: api));
  // `DreamJarListScreen` reads the signed-in id straight from the composition
  // root rather than from a constructor parameter.
  getIt.registerSingleton<BackendUserIdStore>(backendUserIdStore);

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
    await getIt.reset();
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
        // STORY-061 AC8: Nhà + Trò chuyện (unlocked) + Pet + Ví chung + Tôi.
        findsNWidgets(5),
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
    'unpaired: Chat is the only destination that drops out, Home still '
    'renders with the readiness key (STORY-061 AC8)',
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
      expect(find.text('Pet'), findsOneWidget);
      expect(find.text('Wallet'), findsOneWidget);
      expect(find.text('Me'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(CupidTabBar),
          matching: find.byType(InkWell),
        ),
        // Nhà + Pet + Ví chung + Tôi; Chat hidden while unpaired.
        findsNWidgets(4),
      );
    },
  );

  testWidgets(
    'paired: every destination mounts its own body at its post-change index '
    '(STORY-061 AC8)',
    (tester) async {
      await tester.pumpWidget(
        _harness(
          paired: true,
          chatRepository: chatRepository,
          coordinator: coordinator,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pet'), findsOneWidget);
      expect(find.text('Wallet'), findsOneWidget);
      expect(find.text('Me'), findsOneWidget);

      await tester.tap(find.text('Pet'));
      await tester.pumpAndSettle();
      expect(find.byType(PetScreen), findsOneWidget);

      await tester.tap(find.text('Wallet'));
      await tester.pumpAndSettle();
      expect(find.byType(DreamJarListScreen), findsOneWidget);

      await tester.tap(find.text('Me'));
      await tester.pumpAndSettle();
      expect(find.byType(MeScreen), findsOneWidget);

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('home_screen_ready_signal')), findsOneWidget);
    },
  );

  testWidgets(
    'unpaired: Ví chung and Tôi stay addressable once Chat vacates slot 1 '
    '(STORY-061 AC8)',
    (tester) async {
      await tester.pumpWidget(
        _harness(
          paired: false,
          chatRepository: chatRepository,
          coordinator: coordinator,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Wallet'));
      await tester.pumpAndSettle();
      expect(find.byType(DreamJarListScreen), findsOneWidget);

      await tester.tap(find.text('Me'));
      await tester.pumpAndSettle();
      expect(find.byType(MeScreen), findsOneWidget);

      await tester.tap(find.text('Pet'));
      await tester.pumpAndSettle();
      expect(find.byType(PetScreen), findsOneWidget);
    },
  );

  testWidgets(
    'no account FAB remains on any shell destination (STORY-061 AC8)',
    (tester) async {
      await tester.pumpWidget(
        _harness(
          paired: true,
          chatRepository: chatRepository,
          coordinator: coordinator,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsNothing);

      await tester.tap(find.text('Me'));
      await tester.pumpAndSettle();

      expect(find.byType(MeScreen), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
    },
  );

  // BUG-20260817-001: `find.byType(FloatingActionButton), findsNothing` above
  // only rules out one shape of occluder. This asserts the property the bug was
  // actually about — the composer's send button receives the pointer — so any
  // future bottom-right shell chrome that paints over it fails here.
  testWidgets(
    'chat tab: the composer send button is hit-testable, not occluded by '
    'shell chrome (BUG-20260817-001)',
    (tester) async {
      await tester.pumpWidget(
        _harness(
          paired: true,
          chatRepository: chatRepository,
          coordinator: coordinator,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.descendant(
          of: find.byType(ChatComposer),
          matching: find.byType(TextField),
        ),
        'anh xin lỗi',
      );
      await tester.pumpAndSettle();

      final Finder sendButton = find.descendant(
        of: find.byType(ChatComposer),
        matching: find.widgetWithIcon(IconButton, Icons.arrow_upward),
      );
      expect(sendButton, findsOneWidget);

      final RenderBox sendBox = tester.renderObject<RenderBox>(sendButton);
      final HitTestResult hit = tester.hitTestOnBinding(
        tester.getCenter(sendButton),
      );

      expect(
        hit.path.any((HitTestEntry entry) => entry.target == sendBox),
        isTrue,
        reason:
            'a pointer at the send button centre never reached it; something '
            'in the shell is painted above the chat composer',
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

  // The AC9 evidence capture renders `PreviewAppShellChrome`, not `AppShell`,
  // so a drift between the two would let the 5-tab shape pass in production
  // and still fail in the evidence. These assertions pin the mirror.
  group('STORY-061 AC8 preview shell mirror', () {
    Widget host(PreviewAppShellTab? activeTab) => MaterialApp(
      theme: buildCupidTheme(
        platform: CupidPlatform.material,
        brightness: Brightness.dark,
      ),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      locale: const Locale('vi'),
      home: PreviewAppShellChrome(
        activeTab: activeTab,
        child: const SizedBox.shrink(),
      ),
    );

    testWidgets('renders the same 5 destinations as AppShell, in order', (
      tester,
    ) async {
      await tester.pumpWidget(host(PreviewAppShellTab.viChung));
      await tester.pumpAndSettle();

      for (final String label in const <String>[
        'Nhà',
        'Trò chuyện',
        'Pet',
        'Ví chung',
        'Tôi',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      expect(find.text('Thư viện ảnh'), findsNothing);
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('highlights Ví chung at index 3 for the jarlist capture', (
      tester,
    ) async {
      await tester.pumpWidget(host(PreviewAppShellTab.viChung));
      await tester.pumpAndSettle();

      final CupidTabBar bar = tester.widget<CupidTabBar>(
        find.byType(CupidTabBar),
      );
      expect(bar.items.length, 5);
      expect(bar.currentIndex, 3);
      expect(bar.items[3].label, 'Ví chung');
    });
  });
}
