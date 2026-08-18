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

/// A null [publicCountdown] omits the key entirely, standing in for a backend
/// that has not deployed the column yet (`architecture/contract-summary.md` §4).
Map<String, Object?> _configJson({
  String id = 'config-1',
  int timeoutMinutes = 10,
  String penalty = 'emoji_storm',
  String proposedBy = 'user-a',
  String status = 'pending_approval',
  bool? publicCountdown = true,
}) {
  return {
    'id': id,
    'coupleId': 'a:b',
    'timeoutMinutes': timeoutMinutes,
    'penalty': penalty,
    'publicCountdown': ?publicCountdown,
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

BoxDecoration _publicCountdownSwitchDecoration(WidgetTester tester) {
  final Container pill = tester.widget<Container>(
    find.byKey(antiGhostPublicCountdownSwitchKey),
  );
  return pill.decoration! as BoxDecoration;
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
      // The primary CTA and the public-countdown switch paint `--grad-hot` as
      // well, so the segment assertion excludes their own decorations rather
      // than counting the tree. The switch pill and the selected segment are
      // value-equal `BoxDecoration`s (same gradient, same 999 radius), so the
      // exclusion has to be by identity.
      final otherGradientDecorations = tester
          .widgetList<DecoratedBox>(
            find.descendant(
              of: find.byType(CupidPrimaryButton),
              matching: find.byType(DecoratedBox),
            ),
          )
          .map((d) => d.decoration)
          .whereType<BoxDecoration>()
          .toList()
        ..add(_publicCountdownSwitchDecoration(tester));
      expect(
        decorations.where(
          (d) =>
              d.gradient == colors.gradientHot &&
              !otherGradientDecorations.any((other) => identical(other, d)),
        ),
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

  testWidgets(
    'AC2/AC3 (dark + vi): the public-countdown row leads the penalty card with '
    'the design-source tokens',
    (tester) async {
      adapter.queueJson(null);
      adapter.queueJson(<Object?>[]);

      await tester.pumpWidget(
        _harness(brightness: Brightness.dark, locale: const Locale('vi')),
      );
      await tester.pumpAndSettle();

      const colors = CupidColorTokens.dark();

      expect(find.text('Đếm ngược công khai'), findsOneWidget);
      expect(find.text('Hiện trên dashboard cả hai'), findsOneWidget);

      // AC2: the row is the penalty card's first child, above the heading.
      expect(
        tester.getTopLeft(find.text('Đếm ngược công khai')).dy,
        lessThan(tester.getTopLeft(find.text('Hình phạt')).dy),
      );

      // Amber leading tile at 0.2 alpha, distinct from Emoji Storm's peach one.
      final tileDecorations = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((d) => d.decoration)
          .whereType<BoxDecoration>()
          .where((d) => d.color == colors.colorAmber.withValues(alpha: 0.2));
      expect(tileDecorations, hasLength(1));

      // State A seeds the toggle on when there is no prefill.
      expect(_publicCountdownSwitchDecoration(tester).gradient, colors.gradientHot);
    },
  );

  testWidgets('AC3 (en): the public-countdown row uses the en strings', (tester) async {
    adapter.queueJson(null);
    adapter.queueJson(<Object?>[]);

    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('Public countdown'), findsOneWidget);
    expect(find.text('Shown on both dashboards'), findsOneWidget);
  });

  testWidgets(
    'AC7 (State B): a config served without publicCountdown renders the row on',
    (tester) async {
      getIt.unregister<BackendUserIdStore>();
      getIt.registerSingleton<BackendUserIdStore>(
        BackendUserIdStore()..updateFromLoginResponse({'id': 'user-a'}),
      );
      adapter.queueJson(null);
      adapter.queueJson([_configJson(proposedBy: 'user-a', publicCountdown: null)]);

      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(
        _publicCountdownSwitchDecoration(tester).gradient,
        const CupidColorTokens.light().gradientHot,
      );
    },
  );

  testWidgets(
    'AC2 (State B): a seeded publicCountdown=false renders the row off and '
    'non-interactive',
    (tester) async {
      getIt.unregister<BackendUserIdStore>();
      getIt.registerSingleton<BackendUserIdStore>(
        BackendUserIdStore()..updateFromLoginResponse({'id': 'user-a'}),
      );
      adapter.queueJson(null);
      adapter.queueJson([_configJson(proposedBy: 'user-a', publicCountdown: false)]);

      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      const colors = CupidColorTokens.light();
      final decoration = _publicCountdownSwitchDecoration(tester);
      expect(decoration.gradient, isNull);
      expect(decoration.color, colors.colorLine);

      final GestureDetector gesture = tester.widget<GestureDetector>(
        find.ancestor(
          of: find.byKey(antiGhostPublicCountdownSwitchKey),
          matching: find.byType(GestureDetector),
        ),
      );
      expect(gesture.onTap, isNull);
    },
  );

  testWidgets(
    'AC4: toggling the row off puts publicCountdown:false in the propose POST body',
    (tester) async {
      adapter.queueJson(null);
      adapter.queueJson(<Object?>[]);

      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(antiGhostPublicCountdownSwitchKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(antiGhostPublicCountdownSwitchKey));
      await tester.pumpAndSettle();

      adapter.queueJson(_configJson(publicCountdown: false));
      adapter.queueJson(_configJson(status: 'active', publicCountdown: false));

      await tester.ensureVisible(find.text('Propose to your partner'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Propose to your partner'));
      await tester.pumpAndSettle();

      final postRequests = adapter.requests.where((r) => r.method == 'POST').toList();
      expect(postRequests, hasLength(1));
      expect(
        (postRequests.single.data! as Map<String, Object?>)['publicCountdown'],
        isFalse,
      );
    },
  );

  testWidgets('AC6 (vi): the noise penalty option reads "Phát âm thanh"', (tester) async {
    adapter.queueJson(null);
    adapter.queueJson(<Object?>[]);

    await tester.pumpWidget(_harness(locale: const Locale('vi')));
    await tester.pumpAndSettle();

    expect(find.text('Phát âm thanh'), findsOneWidget);
    expect(find.text('Gây ồn'), findsNothing);
  });
}
