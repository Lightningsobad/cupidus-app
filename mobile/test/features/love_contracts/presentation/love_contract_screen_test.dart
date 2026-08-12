import 'dart:async';
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
import 'package:flutter_test/flutter_test.dart';

/// Same scripted-adapter double as
/// `test/features/love_contracts/presentation/love_contract_bloc_test.dart`
/// (injected fakes, no mocking package), duplicated locally since test
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

Map<String, dynamic> _contractJson(List<String> clauses) => <String, dynamic>{
  'id': 'contract-1',
  'requesterId': 'user-1',
  'partnerId': null,
  'clauses': clauses,
  'status': 'created',
  'signedAtRequester': null,
  'signedAtPartner': null,
  'createdAt': '2026-01-01T00:00:00.000Z',
  'updatedAt': '2026-01-01T00:00:00.000Z',
};

/// STORY-019 P3: a viewer-aware fixture that also sets `viewerRole` and both
/// sign timestamps, for the `partnerAlreadySigned`/`signedByMe`/`bothSigned`
/// derivation (ADR-019c) that [_contractJson] does not cover.
Map<String, dynamic> _viewerContractJson({
  List<String> clauses = const <String>[],
  required String viewerRole,
  String? signedAtRequester,
  String? signedAtPartner,
}) => <String, dynamic>{
  'id': 'contract-1',
  'requesterId': 'user-1',
  'partnerId': 'user-2',
  'clauses': clauses,
  'status': 'created',
  'signedAtRequester': signedAtRequester,
  'signedAtPartner': signedAtPartner,
  'createdAt': '2026-01-01T00:00:00.000Z',
  'updatedAt': '2026-01-01T00:00:00.000Z',
  'viewerRole': viewerRole,
};

String? _noPartnerName() => null;

Widget _harness(
  LoveContractRepository repository, {
  String? Function() partnerDisplayName = _noPartnerName,
}) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.light,
    ),
    home: LoveContractScreen(
      repository: repository,
      partnerDisplayName: partnerDisplayName,
    ),
  );
}

void main() {
  testWidgets('shows the skeleton while the contract is loading, then '
      'the empty ready state with no pending contract', (tester) async {
    final completer = Completer<ResponseBody>();
    final repository = _repositoryWith({
      'GET /love-contracts/my-pending': (options) => completer.future,
    });

    await tester.pumpWidget(_harness(repository));
    await tester.pump();

    expect(find.byKey(const Key('love_contract_loading')), findsOneWidget);
    expect(find.byKey(const Key('love_contract_ready')), findsNothing);

    completer.complete(_jsonResponse(null));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('love_contract_loading')), findsNothing);
    expect(find.byKey(const Key('love_contract_ready')), findsOneWidget);
    expect(
      find.text('Select at least one clause to get started'),
      findsOneWidget,
    );
  });

  testWidgets('a network failure shows the inline retry banner, and retry '
      'recovers to the ready state', (tester) async {
    var attempt = 0;
    final repository = _repositoryWith({
      'GET /love-contracts/my-pending': (options) async {
        attempt += 1;
        if (attempt == 1) {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
          );
        }
        return _jsonResponse(null);
      },
    });

    await tester.pumpWidget(_harness(repository));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('love_contract_load_failed')), findsOneWidget);
    expect(find.text('No internet connection'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('love_contract_load_failed')), findsNothing);
    expect(find.byKey(const Key('love_contract_ready')), findsOneWidget);
  });

  testWidgets('clause toggle rows expose on/off state through a semantic '
      'flag and an icon-shape change, not colour alone', (tester) async {
    final handle = tester.ensureSemantics();

    final repository = _repositoryWith({
      'GET /love-contracts/my-pending': (options) async => _jsonResponse(null),
    });

    await tester.pumpWidget(_harness(repository));
    await tester.pumpAndSettle();

    final rowFinder = find.byKey(const ValueKey('preset-honesty'));
    expect(rowFinder, findsOneWidget);

    expect(
      tester.getSemantics(rowFinder),
      matchesSemantics(
        isButton: true,
        hasToggledState: true,
        isToggled: false,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
        label: 'Always tell the truth',
      ),
    );
    final beforeIcon = tester.widget<Icon>(
      find.descendant(of: rowFinder, matching: find.byType(Icon)),
    );
    expect(beforeIcon.icon, isA<IconData>());
    final beforeCodePoint = beforeIcon.icon!.codePoint;

    await tester.tap(rowFinder);
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(rowFinder),
      matchesSemantics(
        isButton: true,
        hasToggledState: true,
        isToggled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
        label: 'Always tell the truth',
      ),
    );
    final afterIcon = tester.widget<Icon>(
      find.descendant(of: rowFinder, matching: find.byType(Icon)),
    );
    final afterCodePoint = afterIcon.icon!.codePoint;

    expect(
      afterCodePoint,
      isNot(beforeCodePoint),
      reason: 'The on/off affordance must change icon shape, not rely on '
          'colour alone.',
    );
    expect(find.text('1/20 clauses'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('the add-clause sheet traps input focus while open and '
      'releases it once dismissed', (tester) async {
    final repository = _repositoryWith({
      'GET /love-contracts/my-pending': (options) async => _jsonResponse(null),
    });

    await tester.pumpWidget(_harness(repository));
    await tester.pumpAndSettle();

    expect(tester.testTextInput.isVisible, isFalse);

    await tester.tap(find.byKey(const Key('love_contract_add_clause_button')));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(tester.testTextInput.isVisible, isTrue);

    await tester.enterText(find.byType(TextField), 'Always share dessert');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    expect(
      tester.testTextInput.isVisible,
      isFalse,
      reason: 'Dismissing the sheet must release keyboard focus, not leave '
          'it dangling on the disposed field.',
    );
    expect(find.text('Always share dessert'), findsOneWidget);
    expect(find.text('1/20 clauses'), findsOneWidget);
  });

  testWidgets('cancelling the add-clause sheet adds nothing', (tester) async {
    final repository = _repositoryWith({
      'GET /love-contracts/my-pending': (options) async => _jsonResponse(null),
    });

    await tester.pumpWidget(_harness(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('love_contract_add_clause_button')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Should not be saved');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    expect(find.text('Should not be saved'), findsNothing);
    expect(find.text('0/20 clauses'), findsOneWidget);
  });

  testWidgets('the 20-clause cap disables the add-clause action', (
    tester,
  ) async {
    final sixteenCustomClauses = List<String>.generate(
      16,
      (i) => 'Custom clause $i',
    );
    final repository = _repositoryWith({
      'GET /love-contracts/my-pending': (options) async =>
          _jsonResponse(_contractJson(sixteenCustomClauses)),
    });

    await tester.pumpWidget(_harness(repository));
    await tester.pumpAndSettle();

    expect(find.text('16/20 clauses'), findsOneWidget);
    final addButton = tester.widget<TextButton>(
      find.byKey(const Key('love_contract_add_clause_button')),
    );
    expect(addButton.onPressed, isNotNull);

    for (final presetId in [
      'preset-honesty',
      'preset-cooldown',
      'preset-check-in',
      'preset-apology',
    ]) {
      await tester.tap(find.byKey(ValueKey(presetId)));
      await tester.pumpAndSettle();
    }

    expect(find.text('20/20 clauses'), findsOneWidget);
    final disabledAddButton = tester.widget<TextButton>(
      find.byKey(const Key('love_contract_add_clause_button')),
    );
    expect(
      disabledAddButton.onPressed,
      isNull,
      reason: 'At the 20-clause backend cap, the add-clause action must be '
          'disabled rather than allow an over-cap request.',
    );
  });

  testWidgets(
    'partner viewer + partnerAlreadySigned shows the Neutral acknowledgment '
    'line and an enabled hold-to-sign button (AC2 partner CTA)',
    (tester) async {
      final repository = _repositoryWith({
        'GET /love-contracts/my-pending': (options) async => _jsonResponse(
          _viewerContractJson(
            clauses: const ['Always tell the truth'],
            viewerRole: 'partner',
            signedAtRequester: '2026-01-02T00:00:00.000Z',
          ),
        ),
      });

      await tester.pumpWidget(_harness(repository));
      await tester.pumpAndSettle();

      expect(
        find.text('Your partner already signed — your turn'),
        findsOneWidget,
      );
      final holdButton = tester.widget<HoldToSignButton>(
        find.byType(HoldToSignButton),
      );
      expect(holdButton.enabled, isTrue);
    },
  );

  testWidgets(
    'partner viewer + partnerAlreadySigned shows the Named acknowledgment '
    'line when the requester display name is known',
    (tester) async {
      final repository = _repositoryWith({
        'GET /love-contracts/my-pending': (options) async => _jsonResponse(
          _viewerContractJson(
            clauses: const ['Always tell the truth'],
            viewerRole: 'partner',
            signedAtRequester: '2026-01-02T00:00:00.000Z',
          ),
        ),
      });

      await tester.pumpWidget(
        _harness(repository, partnerDisplayName: () => 'Minh Anh'),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Minh Anh already signed — your turn'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'requester viewer + signedByMe shows the signed card with the '
    'awaiting-partner line and no sign button (unchanged behavior)',
    (tester) async {
      final repository = _repositoryWith({
        'GET /love-contracts/my-pending': (options) async => _jsonResponse(
          _viewerContractJson(
            clauses: const ['Always tell the truth'],
            viewerRole: 'requester',
            signedAtRequester: '2026-01-02T00:00:00.000Z',
          ),
        ),
      });

      await tester.pumpWidget(_harness(repository));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('love_contract_signed_card')), findsOneWidget);
      expect(
        find.text('Waiting for your partner to sign'),
        findsOneWidget,
      );
      expect(find.byType(HoldToSignButton), findsNothing);
    },
  );

  testWidgets(
    'bothSigned shows the signed card with the Neutral both-signed line',
    (tester) async {
      final repository = _repositoryWith({
        'GET /love-contracts/my-pending': (options) async => _jsonResponse(
          _viewerContractJson(
            clauses: const ['Always tell the truth'],
            viewerRole: 'requester',
            signedAtRequester: '2026-01-02T00:00:00.000Z',
            signedAtPartner: '2026-01-03T00:00:00.000Z',
          ),
        ),
      });

      await tester.pumpWidget(_harness(repository));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('love_contract_signed_card')), findsOneWidget);
      expect(find.text('You both signed'), findsOneWidget);
      expect(find.byType(HoldToSignButton), findsNothing);
    },
  );

  testWidgets(
    'bothSigned shows the Named both-signed line when the partner display '
    'name is known, for the partner viewer too',
    (tester) async {
      final repository = _repositoryWith({
        'GET /love-contracts/my-pending': (options) async => _jsonResponse(
          _viewerContractJson(
            clauses: const ['Always tell the truth'],
            viewerRole: 'partner',
            signedAtRequester: '2026-01-02T00:00:00.000Z',
            signedAtPartner: '2026-01-03T00:00:00.000Z',
          ),
        ),
      });

      await tester.pumpWidget(
        _harness(repository, partnerDisplayName: () => 'Minh Anh'),
      );
      await tester.pumpAndSettle();

      expect(find.text('You and Minh Anh both signed'), findsOneWidget);
    },
  );

  testWidgets(
    'partner viewer hides the add-clause button and clause taps are inert '
    '(ADR-019e, clause_toggle_row.dart out of write scope)',
    (tester) async {
      final repository = _repositoryWith({
        'GET /love-contracts/my-pending': (options) async => _jsonResponse(
          _viewerContractJson(viewerRole: 'partner'),
        ),
      });

      await tester.pumpWidget(_harness(repository));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('love_contract_add_clause_button')),
        findsNothing,
      );

      final rowFinder = find.byKey(const ValueKey('preset-honesty'));
      expect(rowFinder, findsOneWidget);
      await tester.tap(rowFinder, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('0/20 clauses'), findsOneWidget);
    },
  );
}
