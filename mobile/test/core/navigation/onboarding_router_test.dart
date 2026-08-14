import 'dart:async';

import 'package:cupid_mobile/core/navigation/onboarding_chain.dart';
import 'package:cupid_mobile/core/navigation/onboarding_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _stub(String label) => Scaffold(body: Text(label));

Map<OnboardingNode, WidgetBuilder> _stubBuilders(
  Iterable<OnboardingNode> nodes,
) {
  return <OnboardingNode, WidgetBuilder>{
    for (final OnboardingNode node in nodes)
      node: (BuildContext context) => _stub(node.name),
  };
}

void main() {
  // Route futures complete only when the pushed route pops, and nothing here
  // pops, so every router call is fire-and-forget.
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<BuildContext> pumpHost(
    WidgetTester tester,
    OnboardingNode host,
  ) async {
    await tester.pumpWidget(
      MaterialApp(navigatorKey: navigatorKey, home: _stub(host.name)),
    );
    return navigatorKey.currentContext!;
  }

  testWidgets('goNext pushes the chain successor', (WidgetTester tester) async {
    final OnboardingRouter router = OnboardingRouter(
      builders: _stubBuilders(<OnboardingNode>[OnboardingNode.permissions]),
    );
    final BuildContext context = await pumpHost(tester, OnboardingNode.otp);

    unawaited(router.goNext(context, OnboardingNode.otp));
    await tester.pumpAndSettle();

    expect(find.text(OnboardingNode.permissions.name), findsOneWidget);
    expect(navigatorKey.currentState!.canPop(), isTrue);
  });

  testWidgets('goNext throws for a node with no single successor', (
    WidgetTester tester,
  ) async {
    final OnboardingRouter router = OnboardingRouter(
      builders: _stubBuilders(OnboardingNode.values),
    );
    final BuildContext context = await pumpHost(
      tester,
      OnboardingNode.pairingChoice,
    );

    expect(
      () => router.goNext(context, OnboardingNode.pairingChoice),
      throwsA(isA<OnboardingChainHasNoSuccessor>()),
    );
  });

  testWidgets('an unregistered node throws OnboardingRouteNotRegistered', (
    WidgetTester tester,
  ) async {
    final OnboardingRouter router = OnboardingRouter(
      builders: _stubBuilders(<OnboardingNode>[OnboardingNode.otp]),
    );
    final BuildContext context = await pumpHost(tester, OnboardingNode.otp);

    expect(
      () => router.goNext(context, OnboardingNode.otp),
      throwsA(isA<OnboardingRouteNotRegistered>()),
    );
    expect(
      () => router.replaceWith(context, OnboardingNode.vow),
      throwsA(isA<OnboardingRouteNotRegistered>()),
    );
  });

  testWidgets('replaceWith swaps the current route', (
    WidgetTester tester,
  ) async {
    final OnboardingRouter router = OnboardingRouter(
      builders: _stubBuilders(<OnboardingNode>[OnboardingNode.login]),
    );
    final BuildContext context = await pumpHost(tester, OnboardingNode.welcome);

    unawaited(router.replaceWith(context, OnboardingNode.login));
    await tester.pumpAndSettle();

    expect(find.text(OnboardingNode.login.name), findsOneWidget);
    expect(find.text(OnboardingNode.welcome.name), findsNothing);
    expect(navigatorKey.currentState!.canPop(), isFalse);
  });

  testWidgets('resetTo clears the stack', (WidgetTester tester) async {
    final OnboardingRouter router = OnboardingRouter(
      builders: _stubBuilders(<OnboardingNode>[
        OnboardingNode.permissions,
        OnboardingNode.home,
      ]),
    );
    final BuildContext context = await pumpHost(tester, OnboardingNode.otp);

    unawaited(router.goNext(context, OnboardingNode.otp));
    await tester.pumpAndSettle();
    expect(navigatorKey.currentState!.canPop(), isTrue);

    unawaited(router.resetTo(context, OnboardingNode.home));
    await tester.pumpAndSettle();

    expect(find.text(OnboardingNode.home.name), findsOneWidget);
    expect(find.text(OnboardingNode.otp.name), findsNothing);
    expect(navigatorKey.currentState!.canPop(), isFalse);
  });
}
