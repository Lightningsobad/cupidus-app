/// AC3 tail + AC4 exit: the three edges that close the chain after pairing —
/// `paired -> loveContract -> vow -> home`.
///
/// The tail builders here mirror `service_locator.dart`'s production registry
/// entries for the same nodes. They are restated rather than imported because
/// the production map is built inside `configureDependencies()`, which needs
/// live Firebase; `chain_chrome_guard_test.dart` covers the other half by
/// proving each of these screens actually builds.
library;

import 'dart:async';
import 'dart:convert';

import 'package:cupid_mobile/core/navigation/onboarding_chain.dart';
import 'package:cupid_mobile/core/navigation/onboarding_router.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/network/cupid_error_interceptor.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/love_contracts/data/love_contract_repository.dart';
import 'package:cupid_mobile/features/love_contracts/presentation/screens/love_contract_screen.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/paired_screen.dart';
import 'package:cupid_mobile/features/vow/presentation/screens/vow_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _UnsignedContractAdapter implements HttpClientAdapter {
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
      'clauses': <String>['Always tell the truth'],
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
    ..httpClientAdapter = _UnsignedContractAdapter()
    ..interceptors.add(const CupidErrorInterceptor());
  return LoveContractRepository(CupidApi(dio: dio, interceptors: const []));
}

/// Stands in for `home`, whose real target (`PairGateShell`) resolves a live
/// pairing gate. `chain_chrome_guard_test.dart` owns the assertion that the
/// shell behind that node is where `CupidTabBar` first appears.
class _NodeStub extends StatelessWidget {
  const _NodeStub(this.node);

  final OnboardingNode node;

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('node:${node.name}')));
}

Finder _node(OnboardingNode node) => find.text('node:${node.name}');

/// Late-bound so the builders can call back into the router they belong to,
/// exactly as the production entries resolve theirs at tap time.
OnboardingRouter _tailRouter() {
  late final OnboardingRouter router;
  return router = OnboardingRouter(
    builders: <OnboardingNode, WidgetBuilder>{
      OnboardingNode.paired: (BuildContext context) => PairedScreen(
        onSignContract: () => router.goNext(context, OnboardingNode.paired),
      ),
      OnboardingNode.loveContract: (_) => LoveContractScreen(
        entry: LoveContractEntry.onboardingStep,
        repository: _loveContractRepository(),
        router: router,
      ),
      OnboardingNode.vow: (BuildContext context) => VowScreen(
        selfVowed: true,
        partnerVowed: true,
        onEnterDashboard: () => router.resetTo(context, OnboardingNode.home),
      ),
      OnboardingNode.home: (_) => const _NodeStub(OnboardingNode.home),
    },
  );
}

Widget _harness({required Widget home, GlobalKey<NavigatorState>? navigatorKey}) =>
    MaterialApp(
      navigatorKey: navigatorKey,
      locale: const Locale('en'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      theme: buildCupidTheme(
        platform: CupidPlatform.material,
        brightness: Brightness.dark,
      ),
      home: home,
    );

/// Bounded pumps rather than `pumpAndSettle`: `PairedScreen`'s heart and
/// `VowScreen`'s star field loop by design and would never settle.
Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('paired advances to the love contract as an in-chain step', (
    tester,
  ) async {
    final OnboardingRouter router = _tailRouter();
    await tester.pumpWidget(
      _harness(
        home: Builder(
          builder: (BuildContext context) => PairedScreen(
            onSignContract: () =>
                router.goNext(context, OnboardingNode.paired),
          ),
        ),
      ),
    );
    await _advance(tester);

    await tester.tap(find.text('Sign the Love Contract →'));
    await _advance(tester);

    expect(find.byType(LoveContractScreen), findsOneWidget);
    // The registry builds the in-chain entry, so the contract arrives without
    // the header its post-home entry keeps.
    expect(find.byType(CupidHeader), findsNothing);
  });

  testWidgets('entering the dashboard from vow clears the onboarding stack', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final OnboardingRouter router = _tailRouter();

    await tester.pumpWidget(
      _harness(
        navigatorKey: navigatorKey,
        home: const _NodeStub(OnboardingNode.paired),
      ),
    );
    await _advance(tester);

    unawaited(router.push(navigatorKey.currentContext!, OnboardingNode.vow));
    await _advance(tester);
    expect(navigatorKey.currentState!.canPop(), isTrue);

    await tester.tap(find.byKey(const Key('vow_enter_dashboard_cta')));
    await _advance(tester);

    expect(_node(OnboardingNode.home), findsOneWidget);
    // AC4's real guarantee: back cannot re-enter onboarding from home.
    expect(navigatorKey.currentState!.canPop(), isFalse);
  });

  test('the forward chain runs register to home without revisiting auth', () {
    // `pairingChoice` branches, so the walk states which leg it takes; every
    // other step comes from the chain itself.
    const List<OnboardingNode> legs = <OnboardingNode>[
      OnboardingNode.register,
      OnboardingNode.invite,
    ];

    final List<OnboardingNode> walked = <OnboardingNode>[];
    for (final OnboardingNode leg in legs) {
      OnboardingNode? cursor = leg;
      while (cursor != null) {
        walked.add(cursor);
        cursor = OnboardingChain.next(cursor);
      }
    }

    expect(walked, <OnboardingNode>[
      OnboardingNode.register,
      OnboardingNode.otp,
      OnboardingNode.permissions,
      OnboardingNode.profileSetup,
      OnboardingNode.pairingChoice,
      OnboardingNode.invite,
      OnboardingNode.waiting,
      OnboardingNode.paired,
      OnboardingNode.loveContract,
      OnboardingNode.vow,
      OnboardingNode.home,
    ]);
    expect(walked.last, OnboardingNode.home);
    expect(walked, isNot(contains(OnboardingNode.welcome)));
    expect(walked, isNot(contains(OnboardingNode.login)));
  });
}
