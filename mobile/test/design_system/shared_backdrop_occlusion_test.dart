import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';
import 'package:cupid_mobile/core/database/cupid_database.dart' as db;
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/navigation/pair_gate_shell.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/network/cupid_error_interceptor.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/account/data/account_repository.dart';
import 'package:cupid_mobile/features/account/domain/cupid_profile.dart';
import 'package:cupid_mobile/features/auth/presentation/screens/otp_screen.dart';
import 'package:cupid_mobile/features/chat/data/chat_partner_store.dart';
import 'package:cupid_mobile/features/chat/data/chat_repository.dart';
import 'package:cupid_mobile/features/chat/data/ghost_consent_store.dart';
import 'package:cupid_mobile/features/chat/presentation/screens/chat_screen.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar_repository.dart';
import 'package:cupid_mobile/features/home/presentation/home_screen.dart';
import 'package:cupid_mobile/features/love_contracts/data/love_contract_repository.dart';
import 'package:cupid_mobile/features/love_contracts/presentation/screens/love_contract_screen.dart';
import 'package:cupid_mobile/features/onboarding/presentation/screens/onboarding_profile_setup_screen.dart';
import 'package:cupid_mobile/features/onboarding/presentation/screens/permissions_screen.dart';
import 'package:cupid_mobile/features/pairing/data/partner_link.dart';
import 'package:cupid_mobile/features/pairing/presentation/joincode_cubit.dart';
import 'package:cupid_mobile/features/pairing/presentation/pair_gate_cubit.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/joincode_screen.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_remote_data_source.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_repository.dart'
    as repo;
import 'package:cupid_mobile/features/timeline/presentation/screens/timeline_screen.dart';
import 'package:cupid_mobile/features/timeline/presentation/timeline_cubit.dart';
import 'package:cupid_mobile/features/timeline/presentation/timeline_state.dart';
import 'package:cupid_mobile/features/vow/presentation/screens/vow_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/timeline/presentation/stub_account_repository.dart';

/// REQ-002 STORY-046: per-screen backdrop probes for the 6 screens that used to
/// set an opaque `backgroundColor: colors.colorBackground` on their own
/// `Scaffold`, occluding the shared `CupidAppBackground` sky wash mounted once
/// at `cupid_app.dart:59`.
///
/// Each screen gets two renders of the same probe pixel:
///  - a negative control whose theme forces an opaque `scaffoldBackgroundColor`.
///    Seeing that sentinel proves the probe pixel is the very pixel the removed
///    override used to paint, and that the screen no longer overrides the
///    theme's transparent scaffold fill itself.
///  - the production theme, where the same pixel must read as the sky wash.
const Key _probeKey = Key('shared_backdrop_probe');

/// Under the first dark sky layer's ellipse (center 15%, -8%), so the wash
/// reads distinctly purple against the flat fill. Same rationale as
/// `cupid_app_background_test.dart`'s own wash probe.
const int _probeX = 120;
const int _probeY = 10;

/// Pure green appears in neither the flat fill nor any sky layer, so its green
/// channel alone separates "the Scaffold painted here" from "the wash did".
const Color _scaffoldFillSentinel = Color(0xFF00FF00);

final Color _flatFill = const CupidColorTokens.dark().colorBackground;

Widget _host({required Widget home, Color? scaffoldFill}) {
  final ThemeData theme = buildCupidTheme(
    platform: CupidPlatform.material,
    brightness: Brightness.dark,
  );

  return MaterialApp(
    locale: const Locale('vi'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    theme: scaffoldFill == null
        ? theme
        : theme.copyWith(scaffoldBackgroundColor: scaffoldFill),
    // Mirrors the production composition root: the background is mounted once
    // through `MaterialApp.builder`, not per screen.
    builder: (BuildContext context, Widget? child) => MediaQuery(
      // Parks the star ticker so `pumpAndSettle` terminates.
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: RepaintBoundary(
        key: _probeKey,
        child: CupidAppBackground(child: child ?? const SizedBox.shrink()),
      ),
    ),
    home: CupidPlatformOverride(
      platform: CupidPlatform.material,
      child: home,
    ),
  );
}

Future<Color> _probePixel(WidgetTester tester) async {
  final RenderRepaintBoundary boundary = tester
      .renderObject<RenderRepaintBoundary>(find.byKey(_probeKey));
  late final int imageWidth;
  // Rasterizing needs real async: the fake-async test zone never completes the
  // engine's toImage future.
  final ByteData rgba = (await tester.runAsync(() async {
    final ui.Image image = await boundary.toImage();
    imageWidth = image.width;
    return (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
  }))!;

  final int offset = (_probeY * imageWidth + _probeX) * 4;
  return Color.fromARGB(
    rgba.getUint8(offset + 3),
    rgba.getUint8(offset),
    rgba.getUint8(offset + 1),
    rgba.getUint8(offset + 2),
  );
}

Future<Color> _renderAndProbe(
  WidgetTester tester,
  Widget Function() screen, {
  Color? scaffoldFill,
  required bool settles,
}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(_host(home: screen(), scaffoldFill: scaffoldFill));
  if (settles) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }
  return _probePixel(tester);
}

Future<void> _expectSharedBackdropShowsThrough(
  WidgetTester tester,
  Widget Function() screen, {
  /// `vow` runs a perpetual idle animation, so it can only be pumped a fixed
  /// number of frames.
  bool settles = true,
}) async {
  final Color occluded = await _renderAndProbe(
    tester,
    screen,
    scaffoldFill: _scaffoldFillSentinel,
    settles: settles,
  );
  expect(
    occluded.g,
    greaterThan(0.5),
    reason:
        'the probe pixel must be one the screen Scaffold paints, otherwise it '
        'proves nothing about the removed override',
  );

  final Color washed = await _renderAndProbe(
    tester,
    screen,
    settles: settles,
  );
  expect(
    tester
        .widgetList<Scaffold>(find.byType(Scaffold))
        .map((Scaffold scaffold) => scaffold.backgroundColor),
    everyElement(isNull),
    reason: 'no Scaffold may reintroduce a solid backdrop fill',
  );
  expect(washed.g, lessThan(0.2));
  expect(washed, isNot(_flatFill));
  expect(washed.r, greaterThan(_flatFill.r));
  expect(washed.b, greaterThan(_flatFill.b));
}

class _ScriptedAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode(<String, dynamic>{
      'id': 'contract-1',
      'requesterId': 'user-1',
      'partnerId': 'user-2',
      'clauses': const <String>['Luôn nói thật'],
      'status': 'created',
      'signedAtRequester': null,
      'signedAtPartner': null,
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-01-01T00:00:00.000Z',
      'viewerRole': 'requester',
    }),
    200,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    },
  );
}

LoveContractRepository _loveContractRepository() {
  final Dio dio = Dio(BaseOptions(baseUrl: 'http://localhost'))
    ..httpClientAdapter = _ScriptedAdapter()
    ..interceptors.add(const CupidErrorInterceptor());
  return LoveContractRepository(
    CupidApi(dio: dio, interceptors: const <Interceptor>[]),
  );
}

// ---------------------------------------------------------------------------
// STORY-007 AD-5: the four extra probe targets below cover composition shapes
// the six STORY-046 screens do not exercise at all -- a nested shell Scaffold,
// a doubly-nested one, a long scrollable body, and persistent bottom chrome.
// They are a representative sample, deliberately capped at four: the guard test
// (`shared_backdrop_occlusion_guard_test.dart`) is what covers the whole
// inventory, so a fifth probe would buy pump time rather than coverage.
// ---------------------------------------------------------------------------

/// Answers every request from memory so a probe render never opens a socket.
class _HandlerAdapter implements HttpClientAdapter {
  _HandlerAdapter(this._handler);

  final Object? Function(RequestOptions options) _handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode(_handler(options)),
    200,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    },
  );
}

const String _selfId = 'me-1';
const String _partnerId = 'partner-1';

Dio _pairedDio() => Dio()
  ..httpClientAdapter = _HandlerAdapter((RequestOptions options) {
    if (options.path == '/users/me') {
      return <String, Object?>{
        'id': _selfId,
        'partnerId': _partnerId,
        'displayName': 'Minh',
        'isGhostModeEnabled': false,
      };
    }
    if (options.path == '/pets/status') {
      return null;
    }
    if (options.path == '/dream-jar') {
      return <Object?>[];
    }
    return <String, Object?>{};
  });

/// Mirrors `test/features/home/home_screen_test.dart`'s `_NoOpDreamJarRepository`
/// (private there, so it cannot be imported).
class _NoOpDreamJarRepository extends DreamJarRepository {
  _NoOpDreamJarRepository() : super(CupidApiClient.create());

  @override
  Future<List<DreamJar>> fetchJars({int limit = 50, int offset = 0}) async =>
      const <DreamJar>[];
}

/// Mirrors `test/features/chat/presentation/chat_design_fidelity_test.dart`'s
/// `_FakeChatRepository`. A one-shot `Stream.value` rather than a controller:
/// each probe mounts the screen twice, so `watchThread()` must tolerate a
/// second listen and must not leave an open controller between renders.
class _EmptyChatRepository implements ChatRepository {
  @override
  Stream<List<db.Message>> watchThread() =>
      Stream<List<db.Message>>.value(const <db.Message>[]);

  @override
  Future<void> send(String text) async {}

  @override
  Future<void> loadOlder() async {}

  @override
  Future<List<RealtimeEvent>> resyncPageOne() async => const <RealtimeEvent>[];

  @override
  Future<void> markSeen() async {}

  @override
  Future<void> dispose() async {}
}

/// Mirrors the `_FakeRealtimeCoordinator` in `chat_design_fidelity_test.dart`
/// and `app_shell_test.dart`; empty streams keep `pumpAndSettle` terminating.
class _SilentRealtimeCoordinator implements RealtimeCoordinator {
  @override
  Stream<RealtimeEvent> events({Set<String>? names}) =>
      const Stream<RealtimeEvent>.empty();

  @override
  Stream<RealtimeStatus> get status => const Stream<RealtimeStatus>.empty();

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> resync() async {}

  @override
  Future<Object?> emit(String name, Object? payload) async => null;
}

/// Mirrors `chat_design_fidelity_test.dart`'s `_NamedPartnerStore`: the header
/// needs both identity halves without a `/users/me` round trip.
class _NamedPartnerStore extends ChatPartnerStore {
  _NamedPartnerStore({required super.dio});

  @override
  String? get selfDisplayName => 'Minh';

  @override
  String? get partnerDisplayName => 'Linh';
}

/// Mirrors `timeline_screen_test.dart`'s `_StubTimelineCubit`: emits a settled
/// state directly so the probe renders the screen's own background rather than
/// the skeleton shimmer, and never touches the network.
class _EmptyTimelineCubit extends TimelineCubit {
  _EmptyTimelineCubit(super.repository) {
    emit(const TimelineEmpty());
  }

  @override
  Future<void> load() async {}

  @override
  Future<void> retry() async {}
}

CupidProfile _pairedProfile() => CupidProfile(
  id: _selfId,
  email: 'minh@example.com',
  language: 'vi',
  vowTaken: true,
  isGhostModeEnabled: false,
  displayName: 'Minh',
  relationshipStartDate: DateTime.utc(2025, 12, 20),
  partnerId: _partnerId,
);

void main() {
  testWidgets('AC2: otp shows the shared sky wash, not a solid fill', (
    WidgetTester tester,
  ) async {
    await _expectSharedBackdropShowsThrough(
      tester,
      () => const OtpScreen(email: 'minh@gmail.com'),
    );
  });

  testWidgets('AC3: contract shows the shared sky wash, not a solid fill', (
    WidgetTester tester,
  ) async {
    await _expectSharedBackdropShowsThrough(
      tester,
      // The in-chain entry is the header-less one, so the probe pixel is
      // backdrop rather than app-bar chrome.
      () => LoveContractScreen(
        repository: _loveContractRepository(),
        entry: LoveContractEntry.onboardingStep,
      ),
    );
  });

  testWidgets('AC4: profile setup shows the shared sky wash, not a solid fill', (
    WidgetTester tester,
  ) async {
    await _expectSharedBackdropShowsThrough(
      tester,
      () => OnboardingProfileSetupScreen(
        profile: CupidProfile(
          id: 'user-1',
          email: 'linh@example.com',
          language: 'vi',
          vowTaken: false,
          isGhostModeEnabled: true,
          displayName: 'Linh',
          birthday: DateTime(2001, 3, 3),
        ),
        onContinue: () {},
      ),
    );
  });

  testWidgets('AC5: permissions shows the shared sky wash, not a solid fill', (
    WidgetTester tester,
  ) async {
    await _expectSharedBackdropShowsThrough(
      tester,
      () => const PermissionsScreen(),
    );
  });

  testWidgets('AC6: joincode shows the shared sky wash, not a solid fill', (
    WidgetTester tester,
  ) async {
    await _expectSharedBackdropShowsThrough(
      tester,
      () => JoincodeScreen(
        createJoincodeCubit: () =>
            JoincodeCubit(acceptInvitation: (_) async {}),
      ),
    );
  });

  testWidgets('AC7: vow shows the shared sky wash, not a solid fill', (
    WidgetTester tester,
  ) async {
    await _expectSharedBackdropShowsThrough(
      tester,
      () => const VowScreen(selfInitial: 'M', partnerInitial: 'L'),
      settles: false,
    );
  });

  group('STORY-007 AD-5: composition shapes the STORY-046 six do not cover', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    tearDown(() async {
      await getIt.reset();
    });

    testWidgets(
      'home tab content shows the shared sky wash under its own hero glow',
      (WidgetTester tester) async {
        getIt.registerLazySingleton<DreamJarRepository>(
          _NoOpDreamJarRepository.new,
        );
        getIt.registerLazySingleton<BackendUserIdStore>(BackendUserIdStore.new);

        // The only probe target that paints a screen-local decorative glow of
        // its own (`home_screen.dart:310`). `ux/uiux-spec.md` §4 calls that an
        // additive foreground accent, not a substitute base layer, so the wash
        // must still read through beside it.
        await _expectSharedBackdropShowsThrough(
          tester,
          () => HomeScreen(
            resolvePairingStatus: () async => PairingStatus.unknown,
            resolveProfile: () async => _pairedProfile(),
          ),
        );
      },
    );

    testWidgets(
      'the paired pair-gate route shows the shared sky wash through two '
      'nested shell Scaffolds',
      (WidgetTester tester) async {
        final Dio dio = _pairedDio();
        final BackendUserIdStore backendUserIdStore = BackendUserIdStore()
          ..updateFromLoginResponse(<String, Object?>{'id': _selfId});
        final CupidApi api = CupidApi(
          dio: dio,
          interceptors: const <Interceptor>[],
        );
        // `AppShell`'s Home tab resolves these through the composition root;
        // they have no constructor seam, so the probe registers them.
        getIt.registerSingleton<CouplePairingStore>(
          CouplePairingStore(api: api, backendUserIdStore: backendUserIdStore),
        );
        getIt.registerSingleton<DreamJarRepository>(DreamJarRepository(api));
        getIt.registerSingleton<BackendUserIdStore>(backendUserIdStore);
        // A profile-shaped stub rather than the fake adapter: `AppShell` mounts
        // `const HomeScreen()` with no `resolveProfile` seam, and a profile that
        // fails to resolve collapses the couple hero to `SizedBox.shrink()`,
        // which slides an entry card up under the probe pixel. That renders a
        // shape production never shows a paired user, so the probe would be
        // measuring the wrong pixel rather than a real occlusion.
        getIt.registerSingleton<AccountRepository>(
          StubAccountRepository(
            relationshipStartDate: DateTime.utc(2025, 12, 20),
          ),
        );

        // PairGateShell -> AppShell -> HomeScreen is the deepest Scaffold
        // nesting in the app. Transparent-over-transparent has to hold at every
        // level; one opaque link anywhere in that chain hides the wash.
        await _expectSharedBackdropShowsThrough(
          tester,
          () => PairGateShell(
            createPairGateCubit: () => PairGateCubit(
              getPartnerLink: () async =>
                  const PartnerLink(partnerId: _partnerId),
            ),
            partnerStore: _NamedPartnerStore(dio: dio),
            chatRepository: _EmptyChatRepository(),
            coordinator: _SilentRealtimeCoordinator(),
            backendUserIdStore: backendUserIdStore,
            consentStore: GhostConsentStore(dio: dio),
          ),
        );
      },
    );

    testWidgets(
      'timeline shows the shared sky wash behind a long scrollable body',
      (WidgetTester tester) async {
        final db.CupidDatabase database = db.CupidDatabase(
          NativeDatabase.memory(),
        );
        addTearDown(database.close);
        final repo.TimelineRepository repository = repo.TimelineRepository(
          database.timelineDao,
          TimelineRemoteDataSource(CupidApiClient.create()),
        );

        await _expectSharedBackdropShowsThrough(
          tester,
          () => TimelineScreen(
            createCubit: () => _EmptyTimelineCubit(repository),
            repository: repository,
            accountRepository: StubAccountRepository(),
          ),
        );
      },
    );

    testWidgets(
      'chat shows the shared sky wash despite its persistent bottom chrome',
      (WidgetTester tester) async {
        final Dio dio = _pairedDio();
        final BackendUserIdStore backendUserIdStore = BackendUserIdStore()
          ..updateFromLoginResponse(<String, Object?>{'id': _selfId});

        await _expectSharedBackdropShowsThrough(
          tester,
          () => ChatScreen(
            repository: _EmptyChatRepository(),
            coordinator: _SilentRealtimeCoordinator(),
            backendUserIdStore: backendUserIdStore,
            partnerStore: _NamedPartnerStore(dio: dio),
            consentStore: GhostConsentStore(dio: dio),
          ),
        );
      },
    );
  });
}
