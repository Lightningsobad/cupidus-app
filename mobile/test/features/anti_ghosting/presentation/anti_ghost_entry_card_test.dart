import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/network/cupid_error_interceptor.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/anti_ghosting/data/ghost_config_repository.dart';
import 'package:cupid_mobile/features/anti_ghosting/presentation/screens/anti_ghost_screen.dart';
import 'package:cupid_mobile/features/anti_ghosting/presentation/widgets/anti_ghost_entry_card.dart';
import 'package:cupid_mobile/features/home/presentation/home_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hand-written fake transport (no `mocktail`/`bloc_test`), mirroring
/// `anti_ghost_screen_test.dart`'s fake.
class _FakeHttpClientAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  final List<_QueuedResponse Function(RequestOptions)> _queue = [];

  void queueJson(Object? body, {int statusCode = 200}) {
    _queue.add((_) => _QueuedResponse(jsonEncode(body), statusCode));
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final queued = _queue.isNotEmpty
        ? _queue.removeAt(0)(options)
        : const _QueuedResponse('{}', 200);
    if (queued.statusCode >= 400) {
      throw DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: queued.statusCode,
          data: jsonDecode(queued.body),
        ),
        type: DioExceptionType.badResponse,
      );
    }
    return ResponseBody.fromString(
      queued.body,
      queued.statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _QueuedResponse {
  const _QueuedResponse(this.body, this.statusCode);

  final String body;
  final int statusCode;
}

Map<String, Object?> _configJson({
  String id = 'config-1',
  int timeoutMinutes = 10,
  String penalty = 'emoji_storm',
  String proposedBy = 'user-a',
  String status = 'pending_approval',
}) {
  return {
    'id': id,
    'coupleId': 'a:b',
    'timeoutMinutes': timeoutMinutes,
    'penalty': penalty,
    'proposedBy': proposedBy,
    'approvedBy': null,
    'status': status,
    'createdAt': '2026-07-30T00:00:00.000Z',
    'updatedAt': '2026-07-30T00:00:00.000Z',
  };
}

Widget _harness() {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.light,
    ),
    locale: const Locale('en'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: const Scaffold(
      body: Column(
        key: Key('home_screen_ready_signal'),
        children: <Widget>[
          AntiGhostEntryCard(),
        ],
      ),
    ),
  );
}

void main() {
  late _FakeHttpClientAdapter adapter;

  setUp(() async {
    adapter = _FakeHttpClientAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'))
      ..httpClientAdapter = adapter
      ..interceptors.add(const CupidErrorInterceptor());
    await getIt.reset();
    getIt.registerSingleton<GhostConfigRepository>(
      GhostConfigRepository(
        api: CupidApi(dio: dio, interceptors: const []),
      ),
    );
    getIt.registerSingleton<BackendUserIdStore>(BackendUserIdStore());
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('readiness key still resolves alongside the entry card', (
    tester,
  ) async {
    adapter.queueJson(null);
    adapter.queueJson(<Object?>[]);

    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home_screen_ready_signal')), findsOneWidget);
  });

  testWidgets('no active config: subtitle reads "Not set up yet"', (
    tester,
  ) async {
    adapter.queueJson(null);
    adapter.queueJson(<Object?>[]);

    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('Anti-Ghosting'), findsOneWidget);
    expect(find.text('Not set up yet'), findsOneWidget);
  });

  testWidgets('active config: subtitle reads "{minutes} min · {penalty}"', (
    tester,
  ) async {
    adapter.queueJson(
      _configJson(status: 'active', timeoutMinutes: 10, penalty: 'emoji_storm'),
    );

    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('10 min · Emoji Storm'), findsOneWidget);
  });

  testWidgets(
    'pending, proposed by me: subtitle reads the waiting-for-partner copy',
    (tester) async {
      getIt.unregister<BackendUserIdStore>();
      final store = BackendUserIdStore()
        ..updateFromLoginResponse({'id': 'user-a'});
      getIt.registerSingleton<BackendUserIdStore>(store);
      adapter.queueJson(null);
      adapter.queueJson([_configJson(proposedBy: 'user-a')]);

      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(find.text('Waiting for your partner to confirm'), findsOneWidget);
    },
  );

  testWidgets(
    'pending, proposed by partner: subtitle reads the partner-proposed copy',
    (tester) async {
      getIt.unregister<BackendUserIdStore>();
      final store = BackendUserIdStore()
        ..updateFromLoginResponse({'id': 'user-a'});
      getIt.registerSingleton<BackendUserIdStore>(store);
      adapter.queueJson(null);
      adapter.queueJson([_configJson(proposedBy: 'user-b')]);

      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(find.text('Your partner suggested new rules'), findsOneWidget);
    },
  );

  testWidgets(
    'REQ-010 STORY-001: the banner wears the design source\'s amber alert '
    'chrome, and no state paints a pending-only variant',
    (tester) async {
      getIt.unregister<BackendUserIdStore>();
      getIt.registerSingleton<BackendUserIdStore>(
        BackendUserIdStore()..updateFromLoginResponse({'id': 'user-a'}),
      );
      adapter.queueJson(null);
      adapter.queueJson([_configJson(proposedBy: 'user-a')]);

      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.text('Anti-Ghosting'));
      final CupidColorTokens colors = context.cupidColors;

      final Finder cardFinder = find
          .ancestor(
            of: find.text('Anti-Ghosting'),
            matching: find.byType(Material),
          )
          .first;
      final Material card = tester.widget<Material>(cardFinder);
      expect(card.color, colors.colorAmber.withValues(alpha: 0.15));
      expect(
        (card.shape as RoundedRectangleBorder).side.color,
        colors.colorAmber.withValues(alpha: 0.4),
      );

      // D4/D5: the concerned-face glyph on an amber tile, never the purple
      // accent timer the pre-fidelity card used.
      final Icon leading = tester.widget<Icon>(
        find.byIcon(CupidIcons.sentimentDissatisfied),
      );
      expect(leading.color, colors.colorAmber);

      // D9: the entry-point affordance the design source draws. Scoped to this
      // card — sibling Home cards carry their own chevron.
      expect(
        find.descendant(
          of: cardFinder,
          matching: find.byIcon(CupidIcons.chevronRight),
        ),
        findsOneWidget,
      );

      // D6/D8: title always amber, subtitle always muted — this is the
      // `pending mine` state, which previously painted an amber subtitle plus
      // a second timer badge (D7).
      expect(
        tester.widget<Text>(find.text('Anti-Ghosting')).style?.color,
        colors.colorAmber,
      );
      expect(
        tester
            .widget<Text>(find.text('Waiting for your partner to confirm'))
            .style
            ?.color,
        colors.colorTextMuted,
      );
      expect(find.byIcon(CupidIcons.timer), findsNothing);
    },
  );

  testWidgets('unpaired user sees no card', (tester) async {
    adapter.queueJson(null, statusCode: 400);

    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('Anti-Ghosting'), findsNothing);
    expect(find.byKey(const Key('home_screen_ready_signal')), findsOneWidget);
  });

  testWidgets('tapping the card from HomeScreen pushes AntiGhostScreen', (
    tester,
  ) async {
    adapter.queueJson(null);
    adapter.queueJson(<Object?>[]);

    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Anti-Ghosting'));
    // The pushed screen re-fetches from a fresh repository call.
    adapter.queueJson(null);
    adapter.queueJson(<Object?>[]);
    await tester.pumpAndSettle();

    expect(find.byType(AntiGhostScreen), findsOneWidget);
  });

  testWidgets(
    'a partner-proposed pending config routes to the review state (State C) on tap',
    (tester) async {
      getIt.unregister<BackendUserIdStore>();
      final store = BackendUserIdStore()
        ..updateFromLoginResponse({'id': 'user-a'});
      getIt.registerSingleton<BackendUserIdStore>(store);
      adapter.queueJson(null);
      adapter.queueJson([
        _configJson(proposedBy: 'user-b', timeoutMinutes: 10, penalty: 'noise'),
      ]);

      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Anti-Ghosting'));
      // The pushed screen re-fetches from a fresh repository call.
      adapter.queueJson(null);
      adapter.queueJson([
        _configJson(proposedBy: 'user-b', timeoutMinutes: 10, penalty: 'noise'),
      ]);
      await tester.pumpAndSettle();

      expect(find.byType(AntiGhostScreen), findsOneWidget);
      expect(find.text('Your partner suggested new rules'), findsOneWidget);
      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);
    },
  );
}
