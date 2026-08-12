import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/network/cupid_error_interceptor.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/account/data/account_repository.dart';
import 'package:cupid_mobile/features/account/presentation/screens/privacy_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _Handler = ResponseBody Function(RequestOptions options, String? body);

/// Mirrors `test/features/account/data/account_repository_test.dart`'s fake
/// transport, extended to record requests/bodies so PATCH assertions can
/// inspect the exact JSON sent — no bloc_test/mocktail (F3).
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final _Handler handler;
  final List<RequestOptions> requests = [];
  final List<String?> bodies = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    String? body;
    if (requestStream != null) {
      final bytes = await requestStream.expand((chunk) => chunk).toList();
      body = utf8.decode(bytes);
    }
    bodies.add(body);
    return handler(options, body);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonBody(Map<String, dynamic> json, {int statusCode = 200}) {
  return ResponseBody.fromBytes(
    utf8.encode(jsonEncode(json)),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

Map<String, dynamic> _profileJson({bool isGhostModeEnabled = true}) => {
  'id': 'user-1',
  'email': 'alex@example.com',
  'displayName': 'Alex',
  'photoUrl': null,
  'birthday': '1996-05-15',
  'relationshipStartDate': null,
  'zodiacSign': 'Taurus',
  'language': 'vi',
  'partnerId': null,
  'coupleType': null,
  'vowTaken': false,
  'isGhostModeEnabled': isGhostModeEnabled,
};

AccountRepository _repository(_FakeAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
  dio.httpClientAdapter = adapter;
  dio.interceptors.add(const CupidErrorInterceptor());
  return AccountRepository(api: CupidApi(dio: dio, interceptors: const []));
}

Widget _harness(AccountRepository repository) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    home: PrivacyScreen(accountRepository: repository),
  );
}

const Key _toggleKey = Key('privacy-controls-ghost-mode-toggle');

const String _titleText = 'Hide typing activity by default';
const String _onLabel =
    'Hide typing activity by default, on. Double tap to turn off.';
const String _offLabel =
    'Hide typing activity by default, off. Double tap to turn on.';
const String _loadingLabel = 'Hide typing activity by default, loading.';
const String _loadErrorText = "Couldn't load this setting right now.";
const String _updateErrorText =
    "Couldn't update this setting. Please try again.";

/// The `Semantics(button: true, ...)` wrapper around the ghost-mode toggle
/// (`ux/uiux-spec.md` §5), scoped to an ancestor of [_toggleKey] so it does
/// not also match `CupidHeader`'s back-button semantics.
Semantics _toggleSemantics(WidgetTester tester) {
  return tester.widget<Semantics>(
    find
        .ancestor(
          of: find.byKey(_toggleKey),
          matching: find.byWidgetPredicate(
            (widget) => widget is Semantics && widget.properties.button == true,
          ),
        )
        .first,
  );
}

void main() {
  group('PrivacyScreen', () {
    testWidgets('renders the three tier cards', (tester) async {
      final repository = _repository(
        _FakeAdapter((options, body) => _jsonBody(_profileJson())),
      );
      await tester.pumpWidget(_harness(repository));

      expect(find.text('Device only'), findsOneWidget);
      expect(find.text('Server, end-to-end'), findsOneWidget);
      // The new controls card pushes tier 3 past the ListView's default
      // cache extent, so it is not built until scrolled into view.
      await tester.scrollUntilVisible(find.text('Standard server'), 300);
      expect(find.text('Standard server'), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets(
      'renders no export button and shows the ghost-mode privacy control (DEC-5)',
      (tester) async {
        final repository = _repository(
          _FakeAdapter((options, body) => _jsonBody(_profileJson())),
        );
        await tester.pumpWidget(_harness(repository));
        await tester.pumpAndSettle();

        expect(find.textContaining('Export'), findsNothing);
        expect(find.text(_titleText), findsOneWidget);
        expect(find.byKey(_toggleKey), findsOneWidget);
      },
    );

    testWidgets(
      'shows the toggle inert with the loading label before the initial fetch resolves',
      (tester) async {
        final repository = _repository(
          _FakeAdapter((options, body) => _jsonBody(_profileJson())),
        );
        await tester.pumpWidget(_harness(repository));

        final semantics = _toggleSemantics(tester);
        expect(semantics.properties.enabled, false);
        expect(semantics.properties.label, _loadingLabel);

        await tester.pumpAndSettle();
      },
    );

    testWidgets('shows the toggle on when isGhostModeEnabled is true', (
      tester,
    ) async {
      final repository = _repository(
        _FakeAdapter((options, body) => _jsonBody(_profileJson())),
      );
      await tester.pumpWidget(_harness(repository));
      await tester.pumpAndSettle();

      final semantics = _toggleSemantics(tester);
      expect(semantics.properties.enabled, true);
      expect(semantics.properties.label, _onLabel);
    });

    testWidgets('shows the toggle off when isGhostModeEnabled is false', (
      tester,
    ) async {
      final repository = _repository(
        _FakeAdapter(
          (options, body) =>
              _jsonBody(_profileJson(isGhostModeEnabled: false)),
        ),
      );
      await tester.pumpWidget(_harness(repository));
      await tester.pumpAndSettle();

      final semantics = _toggleSemantics(tester);
      expect(semantics.properties.enabled, true);
      expect(semantics.properties.label, _offLabel);
    });

    testWidgets(
      'shows the inline load-error caption and an inert toggle when the initial fetch fails',
      (tester) async {
        final repository = _repository(
          _FakeAdapter(
            (options, body) => _jsonBody({'message': 'boom'}, statusCode: 500),
          ),
        );
        await tester.pumpWidget(_harness(repository));
        await tester.pumpAndSettle();

        expect(find.text(_loadErrorText), findsOneWidget);
        final semantics = _toggleSemantics(tester);
        expect(semantics.properties.enabled, false);
        expect(semantics.properties.label, _loadingLabel);
      },
    );

    testWidgets(
      'flips the toggle optimistically, disables it in flight, and applies the PATCH result',
      (tester) async {
        bool serverValue = true;
        final adapter = _FakeAdapter((options, body) {
          if (options.method == 'PATCH') {
            serverValue =
                (jsonDecode(body!) as Map<String, dynamic>)['isGhostModeEnabled']
                    as bool;
            return _jsonBody({});
          }
          return _jsonBody(_profileJson(isGhostModeEnabled: serverValue));
        });
        final repository = _repository(adapter);
        await tester.pumpWidget(_harness(repository));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(_toggleKey));
        await tester.pump();

        final inFlight = _toggleSemantics(tester);
        expect(inFlight.properties.enabled, false);
        expect(inFlight.properties.label, _loadingLabel);

        await tester.pumpAndSettle();

        final settled = _toggleSemantics(tester);
        expect(settled.properties.enabled, true);
        expect(settled.properties.label, _offLabel);

        final patchRequest = adapter.requests.firstWhere(
          (r) => r.method == 'PATCH',
        );
        final sentBody =
            jsonDecode(adapter.bodies[adapter.requests.indexOf(patchRequest)]!)
                as Map<String, dynamic>;
        expect(sentBody, {'isGhostModeEnabled': false});
      },
    );

    testWidgets(
      'rolls back the toggle and shows a snackbar when the PATCH fails',
      (tester) async {
        final repository = _repository(
          _FakeAdapter((options, body) {
            if (options.method == 'PATCH') {
              return _jsonBody({'message': 'boom'}, statusCode: 500);
            }
            return _jsonBody(_profileJson());
          }),
        );
        await tester.pumpWidget(_harness(repository));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(_toggleKey));
        await tester.pumpAndSettle();

        final semantics = _toggleSemantics(tester);
        expect(semantics.properties.enabled, true);
        expect(semantics.properties.label, _onLabel);
        expect(find.text(_updateErrorText), findsOneWidget);
      },
    );
  });
}
