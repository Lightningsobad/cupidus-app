import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/network/cupid_error_interceptor.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/anti_ghosting/data/ghost_config_models.dart';
import 'package:cupid_mobile/features/anti_ghosting/data/ghost_config_repository.dart';
import 'package:cupid_mobile/features/anti_ghosting/presentation/screens/anti_ghost_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hand-written fake transport (no `mocktail`/`bloc_test`), mirroring
/// `anti_ghost_cubit_test.dart`'s fake, wired behind [CupidErrorInterceptor]
/// so widget-level 400s surface as [CupidApiFailure].
class _FakeHttpClientAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  final List<_QueuedResponse Function(RequestOptions)> _queue = [];

  void queueJson(Object? body, {int statusCode = 200}) {
    _queue.add((_) => _QueuedResponse(jsonEncode(body), statusCode, asJson: true));
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
        : const _QueuedResponse('{}', 200, asJson: true);
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
  const _QueuedResponse(this.body, this.statusCode, {required this.asJson});

  final String body;
  final int statusCode;
  final bool asJson;
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

Widget _harness({
  Brightness brightness = Brightness.light,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    theme: buildCupidTheme(platform: CupidPlatform.material, brightness: brightness),
    locale: locale,
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: const AntiGhostScreen(),
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
      GhostConfigRepository(api: CupidApi(dio: dio, interceptors: const [])),
    );
    getIt.registerSingleton<BackendUserIdStore>(BackendUserIdStore());
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('AC3: pairing-required guard renders with zero mutating calls', (tester) async {
    adapter.queueJson(null, statusCode: 400);

    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('Pair up first'), findsOneWidget);
    expect(
      adapter.requests.where((r) => r.method != 'GET'),
      isEmpty,
      reason: 'The pairing guard must never trigger a mutating request.',
    );
  });

  testWidgets('State A: penalty selector exposes single-select radio semantics', (tester) async {
    adapter.queueJson(null);
    adapter.queueJson(<Object?>[]);

    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    final radioTiles = tester
        .widgetList<RadioListTile<Penalty>>(find.byType(RadioListTile<Penalty>))
        .toList();
    expect(radioTiles, hasLength(3));
    expect(find.text('Emoji Storm'), findsOneWidget);
    expect(find.text('Noise'), findsOneWidget);
    expect(find.text('None'), findsOneWidget);
  });

  testWidgets(
    'State B: pending-mine controls are present but disabled, with an accessible disabled reason',
    (tester) async {
      getIt.unregister<BackendUserIdStore>();
      final store = BackendUserIdStore()..updateFromLoginResponse({'id': 'user-a'});
      getIt.registerSingleton<BackendUserIdStore>(store);
      adapter.queueJson(null);
      adapter.queueJson([_configJson(proposedBy: 'user-a')]);

      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(find.text('Proposed'), findsOneWidget);
      final radioTiles = tester
          .widgetList<RadioListTile<Penalty>>(find.byType(RadioListTile<Penalty>))
          .toList();
      expect(radioTiles, hasLength(3));
      final ignorePointerFinder = find.ancestor(
        of: find.byType(RadioGroup<Penalty>),
        matching: find.byType(IgnorePointer),
      );
      expect(tester.widget<IgnorePointer>(ignorePointerFinder.first).ignoring, isTrue);
      // The threshold picker is a segmented control, so each segment carries
      // selectable button semantics rather than being a Material chip.
      final thresholdSegments = tester
          .widgetList<Semantics>(find.byType(Semantics))
          .where((s) => s.properties.button == true && s.properties.selected != null)
          .toList();
      expect(thresholdSegments, isNotEmpty);
      for (final segment in thresholdSegments) {
        expect(segment.properties.enabled, isFalse);
      }
      expect(
        find.bySemanticsLabel('Disabled — waiting for your partner to respond'),
        findsOneWidget,
      );
      handle.dispose();
    },
  );

  testWidgets(
    'State C: Accept/Decline carry full accessible labels naming the actual values',
    (tester) async {
      getIt.unregister<BackendUserIdStore>();
      final store = BackendUserIdStore()..updateFromLoginResponse({'id': 'user-a'});
      getIt.registerSingleton<BackendUserIdStore>(store);
      adapter.queueJson(null);
      adapter.queueJson([_configJson(proposedBy: 'user-b', timeoutMinutes: 10, penalty: 'noise')]);

      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel('Accept 10 minute Noise rules'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Decline 10 minute Noise rules'),
        findsOneWidget,
      );
      handle.dispose();
    },
  );

  testWidgets('State A: a double-tap on propose issues exactly one POST', (tester) async {
    adapter.queueJson(null);
    adapter.queueJson(<Object?>[]);

    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    adapter.queueJson(_configJson());
    adapter.queueJson(_configJson(status: 'active'));

    await tester.ensureVisible(find.text('Propose to your partner'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Propose to your partner'));
    await tester.tap(find.text('Propose to your partner'));
    await tester.pumpAndSettle();

    final postRequests = adapter.requests.where((r) => r.method == 'POST');
    expect(postRequests, hasLength(1));
  });

  testWidgets(
    'AC1/AC3 (dark + vi): settings cards, threshold track, and selected segment '
    'paint the design-source tokens',
    (tester) async {
      adapter.queueJson(null);
      adapter.queueJson(<Object?>[]);

      await tester.pumpWidget(
        _harness(brightness: Brightness.dark, locale: const Locale('vi')),
      );
      await tester.pumpAndSettle();

      const colors = CupidColorTokens.dark();
      const platform = CupidPlatformTokens.material();

      expect(find.text('Bơ tin nhắn thì phải trả giá 🎀'), findsOneWidget);
      expect(find.text('Ngưỡng “bơ”'), findsOneWidget);

      // `Container` builds its own `DecoratedBox`, so this covers both.
      final decorations = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((d) => d.decoration)
          .whereType<BoxDecoration>()
          .toList();

      // Threshold card and penalty card: `--surf` fill, card radius, shadow.
      final settingsCards =
          decorations.where((d) => d.color == colors.colorSurface).toList();
      expect(settingsCards, hasLength(2));
      for (final card in settingsCards) {
        expect(card.borderRadius, BorderRadius.circular(platform.radiusCard));
        expect(card.boxShadow, platform.elevationShadow);
      }

      // Segmented track sits on `--surf2`; the selected segment is `--grad-hot`.
      expect(
        decorations.where(
          (d) => d.color == colors.colorSurfaceAlt && d.borderRadius == BorderRadius.circular(999),
        ),
        isNotEmpty,
      );
      expect(
        decorations.where((d) => d.gradient == colors.gradientHot),
        hasLength(1),
      );

      // Emoji Storm is the only peach-tinted penalty tile in the design source.
      expect(
        decorations.where(
          (d) => d.color == colors.colorPeach.withValues(alpha: 0.2),
        ),
        hasLength(1),
      );
    },
  );
}
