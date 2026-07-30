import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/network/cupid_error_interceptor.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/anti_ghosting/data/ghost_config_repository.dart';
import 'package:cupid_mobile/features/anti_ghosting/presentation/widgets/ghost_state_row.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hand-written fake transport (no `mocktail`/`bloc_test`), mirroring
/// `anti_ghost_entry_card_test.dart`'s fake.
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
        : const _QueuedResponse('{"eligible":false,"penalty":null}', 200);
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

Widget _harness() {
  return MaterialApp(
    theme: buildCupidTheme(platform: CupidPlatform.material, brightness: Brightness.light),
    locale: const Locale('en'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: const Scaffold(body: GhostStateRow(partnerId: 'partner-1')),
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
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('eligible + emoji_storm: neutral line and the storm CTA both render', (
    tester,
  ) async {
    adapter.queueJson({'eligible': true, 'penalty': 'emoji_storm'});

    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('Seen, no reply yet'), findsOneWidget);
    expect(find.text('Fire Emoji Storm'), findsOneWidget);
    expect(find.text('Send Noise'), findsNothing);
  });

  testWidgets('eligible + noise: neutral line and the noise CTA both render', (tester) async {
    adapter.queueJson({'eligible': true, 'penalty': 'noise'});

    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('Seen, no reply yet'), findsOneWidget);
    expect(find.text('Send Noise'), findsOneWidget);
    expect(find.text('Fire Emoji Storm'), findsNothing);
  });

  testWidgets('eligible + none: the neutral line renders but the CTA is suppressed', (
    tester,
  ) async {
    adapter.queueJson({'eligible': true, 'penalty': 'none'});

    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('Seen, no reply yet'), findsOneWidget);
    expect(find.text('Fire Emoji Storm'), findsNothing);
    expect(find.text('Send Noise'), findsNothing);
  });

  testWidgets('no active config (penalty null, not eligible): nothing renders', (tester) async {
    adapter.queueJson({'eligible': false, 'penalty': null});

    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('Seen, no reply yet'), findsNothing);
    expect(find.byType(GhostStateRow), findsOneWidget);
  });

  testWidgets('an active config but not eligible: nothing renders', (tester) async {
    adapter.queueJson({'eligible': false, 'penalty': 'emoji_storm'});

    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('Seen, no reply yet'), findsNothing);
    expect(find.text('Fire Emoji Storm'), findsNothing);
  });

  testWidgets('a fetch failure renders nothing rather than an error state', (tester) async {
    adapter.queueJson(null, statusCode: 500);

    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('Seen, no reply yet'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no repository registered: renders nothing rather than throwing', (tester) async {
    await getIt.reset();

    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.byType(GhostStateRow), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the storm CTA is exposed as a live region for screen readers', (tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    adapter.queueJson({'eligible': true, 'penalty': 'emoji_storm'});

    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Fire Emoji Storm'));
    expect(node.flagsCollection.isLiveRegion, isTrue);

    handle.dispose();
  });
}
