import 'dart:async';

import 'package:cupid_mobile/core/auth/session_termination.dart';
import 'package:cupid_mobile/core/navigation/onboarding_chain.dart';
import 'package:cupid_mobile/core/navigation/onboarding_router.dart';
import 'package:cupid_mobile/core/navigation/pair_gate_shell.dart';
import 'package:cupid_mobile/core/navigation/session_termination_listener.dart';
import 'package:cupid_mobile/features/pairing/data/partner_link.dart';
import 'package:cupid_mobile/features/pairing/presentation/pair_gate_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Counts builds per node so "mounted exactly once" is observable: a duplicated
/// listener would navigate twice for a single event.
class _CountingBuilders {
  final Map<OnboardingNode, int> builds = <OnboardingNode, int>{};

  Map<OnboardingNode, WidgetBuilder> registry(Iterable<OnboardingNode> nodes) {
    return <OnboardingNode, WidgetBuilder>{
      for (final OnboardingNode node in nodes)
        node: (BuildContext context) {
          builds[node] = (builds[node] ?? 0) + 1;
          return Scaffold(body: Text(node.name));
        },
    };
  }
}

Future<void> _pumpHost(
  WidgetTester tester, {
  required SessionTerminationNotifier notifier,
  required OnboardingRouter router,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: SessionTerminationListener(
        notifier: notifier,
        router: router,
        child: const Scaffold(body: Text('app-root')),
      ),
    ),
  );
}

void main() {
  testWidgets('a user-initiated termination resets to welcome (AC5)', (
    tester,
  ) async {
    final notifier = SessionTerminationNotifier();
    addTearDown(notifier.dispose);
    final builders = _CountingBuilders();
    await _pumpHost(
      tester,
      notifier: notifier,
      router: OnboardingRouter(
        builders: builders.registry(<OnboardingNode>[
          OnboardingNode.welcome,
          OnboardingNode.login,
        ]),
      ),
    );

    notifier.emit(SessionTerminationReason.userInitiated);
    await tester.pumpAndSettle();

    expect(find.text(OnboardingNode.welcome.name), findsOneWidget);
    expect(find.text(OnboardingNode.login.name), findsNothing);
    expect(find.text('app-root'), findsNothing);
  });

  testWidgets('a refresh failure resets to login (AC6)', (tester) async {
    final notifier = SessionTerminationNotifier();
    addTearDown(notifier.dispose);
    final builders = _CountingBuilders();
    await _pumpHost(
      tester,
      notifier: notifier,
      router: OnboardingRouter(
        builders: builders.registry(<OnboardingNode>[
          OnboardingNode.welcome,
          OnboardingNode.login,
        ]),
      ),
    );

    notifier.emit(SessionTerminationReason.refreshFailed);
    await tester.pumpAndSettle();

    expect(find.text(OnboardingNode.login.name), findsOneWidget);
    expect(find.text(OnboardingNode.welcome.name), findsNothing);
    expect(find.text('app-root'), findsNothing);
  });

  testWidgets('one event drives exactly one navigation', (tester) async {
    final notifier = SessionTerminationNotifier();
    addTearDown(notifier.dispose);
    final builders = _CountingBuilders();
    await _pumpHost(
      tester,
      notifier: notifier,
      router: OnboardingRouter(
        builders: builders.registry(<OnboardingNode>[OnboardingNode.welcome]),
      ),
    );

    notifier.emit(SessionTerminationReason.userInitiated);
    await tester.pumpAndSettle();

    expect(builders.builds[OnboardingNode.welcome], 1);
    expect(find.text(OnboardingNode.welcome.name), findsOneWidget);
  });

  testWidgets('a terminated listener stops routing once unmounted', (
    tester,
  ) async {
    final notifier = SessionTerminationNotifier();
    addTearDown(notifier.dispose);
    final builders = _CountingBuilders();
    await _pumpHost(
      tester,
      notifier: notifier,
      router: OnboardingRouter(
        builders: builders.registry(<OnboardingNode>[
          OnboardingNode.welcome,
          OnboardingNode.login,
        ]),
      ),
    );

    notifier.emit(SessionTerminationReason.userInitiated);
    await tester.pumpAndSettle();

    // The reset cleared the stack the listener was mounted in, so a second
    // signal must not navigate again from a disposed listener.
    notifier.emit(SessionTerminationReason.refreshFailed);
    await tester.pumpAndSettle();

    expect(find.text(OnboardingNode.welcome.name), findsOneWidget);
    expect(builders.builds[OnboardingNode.login], isNull);
  });

  testWidgets('PairGateShell mounts the listener exactly once', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PairGateShell(
          // Never completes, so the gate stays in its checking state and this
          // test needs neither a PartnerLink fixture nor a live Dio.
          createPairGateCubit: () => PairGateCubit(
            getPartnerLink: () => Completer<PartnerLink>().future,
          ),
        ),
      ),
    );

    expect(find.byType(SessionTerminationListener), findsOneWidget);
  });

  testWidgets('renders its child unchanged when nothing is registered', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SessionTerminationListener(
          child: Scaffold(body: Text('app-root')),
        ),
      ),
    );

    expect(find.text('app-root'), findsOneWidget);
  });
}
