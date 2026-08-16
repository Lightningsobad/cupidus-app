import 'dart:convert';

import 'package:cupid_mobile/core/navigation/onboarding_chain.dart';
import 'package:cupid_mobile/core/navigation/onboarding_router.dart';
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

/// Same scripted-adapter double as `love_contract_screen_test.dart` (injected
/// fakes, no mocking package), duplicated locally since test libraries do not
/// share private helpers across files.
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

Map<String, dynamic> _viewerContractJson({
  List<String> clauses = const <String>['Always tell the truth'],
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

/// The partner's turn: the requester has signed, so the hold-to-sign control
/// is enabled and one dwell moves this viewer to `bothSigned`.
LoveContractRepository _partnersTurnRepository() => _repositoryWith({
  'GET /love-contracts/my-pending': (options) async => _jsonResponse(
    _viewerContractJson(
      viewerRole: 'partner',
      signedAtRequester: '2026-01-02T00:00:00.000Z',
    ),
  ),
  'PATCH /love-contracts/sign': (options) async => _jsonResponse(
    _viewerContractJson(
      viewerRole: 'partner',
      signedAtRequester: '2026-01-02T00:00:00.000Z',
      signedAtPartner: '2026-01-03T00:00:00.000Z',
    ),
  ),
});

/// Stand-in for a chain node, so this file asserts the edge the screen takes
/// without pulling in screens other phases own.
class _NodeStub extends StatelessWidget {
  const _NodeStub(this.node);

  final OnboardingNode node;

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('node:${node.name}')));
}

Finder _node(OnboardingNode node) => find.text('node:${node.name}');

OnboardingRouter _stubRouter() => OnboardingRouter(
  builders: <OnboardingNode, WidgetBuilder>{
    for (final OnboardingNode node in OnboardingNode.values)
      node: (_) => _NodeStub(node),
  },
);

Widget _harness(
  LoveContractRepository repository, {
  required LoveContractEntry entry,
  OnboardingRouter? router,
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
      entry: entry,
      router: router ?? _stubRouter(),
    ),
  );
}

/// Completes one hold-to-sign dwell. The control's own dwell is widget-local,
/// so the gesture must stay down for the full [HoldToSignButton.holdDuration]
/// before release; a shorter press cancels instead of signing.
Future<void> _holdToSign(WidgetTester tester) async {
  // The chromed entry pushes the control further down the scroll view than
  // the chromeless one, so scroll it into the viewport before aiming at it.
  await tester.ensureVisible(find.byType(HoldToSignButton));
  await tester.pumpAndSettle();

  final HoldToSignButton button = tester.widget<HoldToSignButton>(
    find.byType(HoldToSignButton),
  );
  final gesture = await tester.startGesture(
    tester.getCenter(find.byType(HoldToSignButton)),
  );
  // Stepped pumps rather than one long jump: the tap recognizer only reports
  // the press down once its arena deadline passes, and the dwell controller
  // needs ticks after that to reach 1.0.
  const Duration step = Duration(milliseconds: 100);
  for (
    Duration elapsed = Duration.zero;
    elapsed <= button.holdDuration + step * 3;
    elapsed += step
  ) {
    await tester.pump(step);
  }
  await gesture.up();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'onboardingStep entry drops the header (AC4 NO_CHROME) and advances to '
    'the vow node once this viewer signs',
    (tester) async {
      await tester.pumpWidget(
        _harness(
          _partnersTurnRepository(),
          entry: LoveContractEntry.onboardingStep,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CupidHeader), findsNothing);
      expect(find.byType(AppBar), findsNothing);
      expect(find.byType(CupidTabBar), findsNothing);

      await _holdToSign(tester);

      expect(_node(OnboardingNode.vow), findsOneWidget);
      expect(find.byType(LoveContractScreen), findsNothing);
    },
  );

  testWidgets(
    'standalone entry keeps its header and stays put after signing '
    '(pre-existing post-home behaviour, unchanged)',
    (tester) async {
      await tester.pumpWidget(
        _harness(
          _partnersTurnRepository(),
          entry: LoveContractEntry.standalone,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CupidHeader), findsOneWidget);

      await _holdToSign(tester);

      expect(find.byType(HoldToSignButton), findsNothing);
      expect(find.byKey(const Key('love_contract_signed_card')), findsOneWidget);
      expect(_node(OnboardingNode.vow), findsNothing);
      expect(find.byType(LoveContractScreen), findsOneWidget);
    },
  );

  testWidgets(
    'standalone is the default entry, so every pre-existing caller keeps the '
    'header without naming it',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          theme: buildCupidTheme(
            platform: CupidPlatform.material,
            brightness: Brightness.light,
          ),
          home: LoveContractScreen(repository: _partnersTurnRepository()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CupidHeader), findsOneWidget);
    },
  );

  testWidgets(
    'opening the chain step on an already-signed contract does not bounce '
    'the viewer forward on its own',
    (tester) async {
      final repository = _repositoryWith({
        'GET /love-contracts/my-pending': (options) async => _jsonResponse(
          _viewerContractJson(
            viewerRole: 'partner',
            signedAtRequester: '2026-01-02T00:00:00.000Z',
            signedAtPartner: '2026-01-03T00:00:00.000Z',
          ),
        ),
      });

      await tester.pumpWidget(
        _harness(repository, entry: LoveContractEntry.onboardingStep),
      );
      await tester.pumpAndSettle();

      expect(_node(OnboardingNode.vow), findsNothing);
      expect(find.byKey(const Key('love_contract_signed_card')), findsOneWidget);
    },
  );
}
