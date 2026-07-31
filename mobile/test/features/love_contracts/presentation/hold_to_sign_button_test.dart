import 'dart:convert';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/network/cupid_error_interceptor.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/love_contracts/data/love_contract_repository.dart';
import 'package:cupid_mobile/features/love_contracts/presentation/screens/love_contract_screen.dart';
import 'package:cupid_mobile/features/love_contracts/presentation/widgets/hold_to_sign_button.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

const _holdDuration = Duration(milliseconds: 1500);
const _pastDwell = Duration(milliseconds: 1600);

Widget _buttonHarness({
  required bool enabled,
  required VoidCallback onHoldStarted,
  required VoidCallback onHoldCancelled,
  required VoidCallback onHoldCompleted,
}) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.light,
    ),
    home: Scaffold(
      body: Center(
        child: HoldToSignButton(
          enabled: enabled,
          label: 'Hold to sign',
          semanticLabel: 'Hold to sign',
          onHoldStarted: onHoldStarted,
          onHoldCancelled: onHoldCancelled,
          onHoldCompleted: onHoldCompleted,
          holdDuration: _holdDuration,
        ),
      ),
    ),
  );
}

/// Same scripted-adapter double as the other `love_contracts` presentation
/// tests (injected fakes, no mocking package), duplicated locally since test
/// libraries do not share private helpers across files.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this._handlers);

  final Map<String, Future<ResponseBody> Function(RequestOptions)> _handlers;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) {
    final key = '${options.method} ${options.path}';
    final handler = _handlers[key];
    if (handler == null) {
      throw StateError('No scripted handler for $key');
    }
    return handler(options);
  }
}

ResponseBody _jsonResponse(Object? data, [int statusCode = 200]) {
  return ResponseBody.fromString(
    jsonEncode(data),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

LoveContractRepository _repositoryWith(
  Map<String, Future<ResponseBody> Function(RequestOptions)> handlers,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost'))
    ..httpClientAdapter = _ScriptedAdapter(handlers)
    ..interceptors.add(const CupidErrorInterceptor());
  return LoveContractRepository(CupidApi(dio: dio, interceptors: const []));
}

Map<String, dynamic> _contractJson(List<String> clauses, {String status = 'created'}) =>
    <String, dynamic>{
      'id': 'contract-1',
      'requesterId': 'user-1',
      'partnerId': null,
      'clauses': clauses,
      'status': status,
      'signedAtRequester': status == 'signed_requester'
          ? '2026-01-01T00:00:00.000Z'
          : null,
      'signedAtPartner': null,
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-01-01T00:00:00.000Z',
    };

Widget _screenHarness(LoveContractRepository repository) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.light,
    ),
    home: LoveContractScreen(repository: repository),
  );
}

Future<void> _selectFirstPreset(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('preset-honesty')));
  await tester.pumpAndSettle();
}

Future<TestGesture> _pressHoldButton(WidgetTester tester) async {
  final finder = find.byKey(const Key('hold_to_sign_button'));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  return tester.startGesture(tester.getCenter(finder));
}

/// Drives the button through its accessible activation path (`Semantics`
/// `SemanticsAction.tap`, see `hold_to_sign_button.dart` dartdoc) instead of
/// the raw hold dwell. The screen's `HoldToSignButton` sits under a
/// `SingleChildScrollView` with real overflow, and a real device delivers a
/// continuous ~60fps ticker stream to drive that dwell; a widget test's
/// coarse-grained `pump(duration)` jumps do not reliably reach the same
/// scrollable subtree's ticker, so screen-level integration coverage drives
/// the same started -> completed event pair through the semantic action
/// instead. The dwell gesture itself is covered directly by the
/// `HoldToSignButton widget` group above, isolated from any scrollable
/// ancestor.
Future<void> _activateHoldButtonInstantly(WidgetTester tester) async {
  final finder = find.byKey(const Key('hold_to_sign_button'));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  final semantics = tester.getSemantics(finder);
  final owner = tester.element(finder).renderObject!.owner!;
  owner.semanticsOwner!.performAction(semantics.id, SemanticsAction.tap);
  await tester.pumpAndSettle();
}

void main() {
  group('HoldToSignButton widget', () {
    testWidgets(
      'releasing before the dwell completes cancels with no sign call',
      (tester) async {
        var started = 0;
        var cancelled = 0;
        var completed = 0;
        await tester.pumpWidget(
          _buttonHarness(
            enabled: true,
            onHoldStarted: () => started++,
            onHoldCancelled: () => cancelled++,
            onHoldCompleted: () => completed++,
          ),
        );

        final gesture = await _pressHoldButton(tester);
        await tester.pump();
        expect(started, 1);

        await tester.pump(const Duration(milliseconds: 300));
        await gesture.up();
        await tester.pump();

        expect(cancelled, 1);
        expect(completed, 0);
      },
    );

    testWidgets(
      'holding through the full dwell dispatches exactly one completed event',
      (tester) async {
        var started = 0;
        var cancelled = 0;
        var completed = 0;
        await tester.pumpWidget(
          _buttonHarness(
            enabled: true,
            onHoldStarted: () => started++,
            onHoldCancelled: () => cancelled++,
            onHoldCompleted: () => completed++,
          ),
        );

        final gesture = await _pressHoldButton(tester);
        await tester.pump();
        await tester.pump(_pastDwell);

        expect(completed, 1);
        expect(cancelled, 0);

        // Releasing after the dwell already completed must not
        // double-dispatch or retroactively cancel.
        await gesture.up();
        await tester.pump();

        expect(started, 1);
        expect(completed, 1);
        expect(cancelled, 0);
      },
    );

    testWidgets(
      'a semantic activation dispatches the same started/completed pair '
      'without the raw hold dwell',
      (tester) async {
        final handle = tester.ensureSemantics();
        var started = 0;
        var completed = 0;
        await tester.pumpWidget(
          _buttonHarness(
            enabled: true,
            onHoldStarted: () => started++,
            onHoldCancelled: () {},
            onHoldCompleted: () => completed++,
          ),
        );

        final finder = find.byKey(const Key('hold_to_sign_button'));
        final semantics = tester.getSemantics(finder);
        expect(
          semantics.getSemanticsData().hasAction(SemanticsAction.tap),
          isTrue,
          reason:
              'The control must expose an accessible activation action '
              'besides the raw hold gesture.',
        );

        final owner = tester.element(finder).renderObject!.owner!;
        owner.semanticsOwner!.performAction(semantics.id, SemanticsAction.tap);
        await tester.pump();

        expect(started, 1);
        expect(completed, 1);

        handle.dispose();
      },
    );

    testWidgets('a disabled control ignores tap-down and semantic activation', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var started = 0;
      await tester.pumpWidget(
        _buttonHarness(
          enabled: false,
          onHoldStarted: () => started++,
          onHoldCancelled: () {},
          onHoldCompleted: () {},
        ),
      );

      final gesture = await _pressHoldButton(tester);
      await tester.pump();
      await gesture.up();
      await tester.pump();

      final semantics = tester.getSemantics(
        find.byKey(const Key('hold_to_sign_button')),
      );
      expect(semantics.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
      expect(started, 0);

      handle.dispose();
    });
  });

  group('Love contract screen signing integration', () {
    testWidgets(
      'a completed hold saves and signs, then renders the signed '
      'confirmation card',
      (tester) async {
        final repository = _repositoryWith({
          'GET /love-contracts/my-pending': (options) async =>
              _jsonResponse(null),
          'POST /love-contracts': (options) async =>
              _jsonResponse(_contractJson(['Always tell the truth'])),
          'PATCH /love-contracts/sign': (options) async => _jsonResponse(
            _contractJson(
              ['Always tell the truth'],
              status: 'signed_requester',
            ),
          ),
        });

        await tester.pumpWidget(_screenHarness(repository));
        await tester.pumpAndSettle();
        await _selectFirstPreset(tester);

        await _activateHoldButtonInstantly(tester);

        expect(find.byKey(const Key('love_contract_signed_card')), findsOneWidget);
        expect(find.text('You signed'), findsOneWidget);
        expect(find.byKey(const Key('hold_to_sign_button')), findsNothing);
        expect(
          find.text('Pair up'),
          findsNothing,
          reason:
              'ux/uiux-spec.md §9-3: the both-signed CTA must never port the '
              'raw prototype "Pair up" label/handler.',
        );
      },
    );

    testWidgets(
      'a sign failure shows the mapped sign-unavailable banner, never a '
      'raw failure type or server string',
      (tester) async {
        final repository = _repositoryWith({
          'GET /love-contracts/my-pending': (options) async =>
              _jsonResponse(null),
          'POST /love-contracts': (options) async =>
              _jsonResponse(_contractJson(['Always tell the truth'])),
          'PATCH /love-contracts/sign': (options) async => _jsonResponse({
            'message': 'No pending contract found to sign',
          }, 404),
        });

        await tester.pumpWidget(_screenHarness(repository));
        await tester.pumpAndSettle();
        await _selectFirstPreset(tester);

        await _activateHoldButtonInstantly(tester);

        expect(
          find.byKey(const Key('love_contract_sign_error_banner')),
          findsOneWidget,
        );
        expect(
          find.text("Can't sign right now, try again later"),
          findsOneWidget,
        );
        expect(
          find.textContaining('No pending contract found to sign'),
          findsNothing,
        );
        expect(find.textContaining('HttpStatusFailure'), findsNothing);
        expect(find.textContaining('CupidApiFailure'), findsNothing);
        expect(find.textContaining('404'), findsNothing);
        // The card chrome (clause list) stays visible behind the banner.
        expect(find.byKey(const Key('love_contract_ready')), findsOneWidget);
      },
    );

    testWidgets('retrying the sign banner recovers to the signed state', (
      tester,
    ) async {
      var signAttempt = 0;
      final repository = _repositoryWith({
        'GET /love-contracts/my-pending': (options) async =>
            _jsonResponse(null),
        'POST /love-contracts': (options) async =>
            _jsonResponse(_contractJson(['Always tell the truth'])),
        'PATCH /love-contracts/sign': (options) async {
          signAttempt += 1;
          if (signAttempt == 1) {
            return _jsonResponse({
              'message': 'No pending contract found to sign',
            }, 404);
          }
          return _jsonResponse(
            _contractJson(
              ['Always tell the truth'],
              status: 'signed_requester',
            ),
          );
        },
      });

      await tester.pumpWidget(_screenHarness(repository));
      await tester.pumpAndSettle();
      await _selectFirstPreset(tester);

      await _activateHoldButtonInstantly(tester);

      expect(
        find.byKey(const Key('love_contract_sign_error_banner')),
        findsOneWidget,
      );

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('love_contract_signed_card')), findsOneWidget);
      expect(
        find.byKey(const Key('love_contract_sign_error_banner')),
        findsNothing,
      );
      expect(signAttempt, 2);
    });
  });
}
