import 'dart:async';
import 'dart:io';

import 'package:cupid_mobile/app/cupid_app.dart';
import 'package:cupid_mobile/core/auth/cupid_auth.dart';
import 'package:cupid_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:cupid_mobile/features/auth/presentation/screens/splash_screen.dart';
import 'package:cupid_mobile/features/auth/presentation/screens/welcome_screen.dart';
import 'package:cupid_mobile/features/auth/presentation/session_gate_cubit.dart';
import 'package:cupid_mobile/features/pairing/data/partner_link.dart';
import 'package:cupid_mobile/features/pairing/presentation/pair_gate_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// REQ-002 STORY-001 P2: app-level guards for ADR-1 (splash is the entry
// route), ADR-5 (the resume invariant is structural, not lifecycle
// machinery), and AC4 (nothing navigates before the gate resolves).

/// The unpaired pairing stack `PairGateShell` lands on. Chosen over the paired
/// `AppShell` branch because it needs nothing from `getIt`, which this suite
/// deliberately never populates: a `getIt` lookup escaping onto the launch path
/// should fail the test, not be papered over by a registration.
final Finder _routedDestination = find.byKey(const Key('pairing_stack'));

class _Harness {
  _Harness()
    : controller = StreamController<CupidSessionState>(),
      _gateCreations = 0;

  final StreamController<CupidSessionState> controller;
  int _gateCreations;

  /// How many times the splash gate has been mounted. `BlocProvider.create`
  /// runs once per mount, so this is the AC5 "splash mounts exactly once"
  /// counter.
  int get gateCreations => _gateCreations;

  Widget build() => CupidApp(
    createSessionGateCubit: () {
      _gateCreations++;
      return SessionGateCubit(
        sessionState: controller.stream,
        idToken: ({forceRefresh = false}) async => 'token',
      );
    },
    createPairGateCubit: () => PairGateCubit(
      getPartnerLink: () async => const PartnerLink(partnerId: null),
    ),
  );
}

/// Drives the full valid-session launch: splash mounts, the dwell elapses, the
/// gate resolves, and splash is replaced by the authenticated root.
Future<void> _launchAuthenticated(WidgetTester tester, _Harness harness) async {
  await tester.pumpWidget(harness.build());
  harness.controller.add(const CupidSessionSignedIn(uid: 'u1', email: 'a@b.com'));
  await tester.pump(const Duration(seconds: 3));
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}

/// The transition sequence `WidgetsBinding` accepts: it rejects a direct
/// resumed → paused jump, so the intermediate states are mandatory.
Future<void> _cycleAppLifecycle(WidgetTester tester) async {
  for (final AppLifecycleState state in <AppLifecycleState>[
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
    await tester.pump();
  }
}

void main() {
  testWidgets('CupidApp boots to splash, not straight to the pair gate (AC1, '
      'ADR-1)', (tester) async {
    final _Harness harness = _Harness();
    addTearDown(harness.controller.close);

    await tester.pumpWidget(harness.build());
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(harness.gateCreations, 1);
    expect(_routedDestination, findsNothing);
  });

  testWidgets(
    'no navigation before the dwell elapses, and none while the gate is '
    'still checking (AC4)',
    (tester) async {
      final _Harness harness = _Harness();
      addTearDown(harness.controller.close);

      await tester.pumpWidget(harness.build());
      // Session resolved at t=0: the dwell alone must still hold splash.
      harness.controller.add(
        const CupidSessionSignedIn(uid: 'u1', email: 'a@b.com'),
      );
      await tester.pump(const Duration(milliseconds: 1900));

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(_routedDestination, findsNothing);

      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(_routedDestination, findsOneWidget);
    },
  );

  testWidgets(
    'the dwell elapsing on an unresolved gate navigates nowhere (AC4)',
    (tester) async {
      final _Harness harness = _Harness();
      addTearDown(harness.controller.close);

      await tester.pumpWidget(harness.build());
      harness.controller.add(const CupidSessionUnknown());
      await tester.pump(const Duration(seconds: 5));

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(_routedDestination, findsNothing);
      expect(find.byType(WelcomeScreen), findsNothing);
      expect(find.byType(LoginScreen), findsNothing);
    },
  );

  testWidgets(
    'a foreground/background lifecycle cycle after routing neither re-mounts '
    'splash nor changes the route (AC5 invariant 1)',
    (tester) async {
      final _Harness harness = _Harness();
      addTearDown(harness.controller.close);

      await _launchAuthenticated(tester, harness);
      expect(_routedDestination, findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);

      await _cycleAppLifecycle(tester);

      expect(harness.gateCreations, 1);
      expect(find.byType(SplashScreen), findsNothing);
      expect(_routedDestination, findsOneWidget);
    },
  );

  testWidgets(
    'a session emission arriving after splash was replaced causes no '
    'navigation (AC5 invariant 2)',
    (tester) async {
      final _Harness harness = _Harness();
      addTearDown(harness.controller.close);

      await _launchAuthenticated(tester, harness);
      expect(_routedDestination, findsOneWidget);

      harness.controller.add(const CupidSessionSignedOut());
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(WelcomeScreen), findsNothing);
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(SplashScreen), findsNothing);
      expect(_routedDestination, findsOneWidget);
    },
  );

  test(
    'the entry-routing path subscribes to no app lifecycle signal '
    '(AC5, ADR-5 invariant 1)',
    () {
      const List<String> entryRoutingSources = <String>[
        'lib/app/cupid_app.dart',
        'lib/features/auth/presentation/screens/splash_screen.dart',
      ];

      for (final String path in entryRoutingSources) {
        final String source = File(path).readAsStringSync();
        expect(
          source,
          isNot(contains('WidgetsBindingObserver')),
          reason:
              '$path drives entry routing; a lifecycle observer here would '
              'let a foreground resume re-run the launch decision (AC5).',
        );
        expect(source, isNot(contains('AppLifecycleState')), reason: path);
        expect(source, isNot(contains('didChangeAppLifecycleState')),
            reason: path);
      }
    },
  );

  test(
    'the production splash gate is built with the auth history store so AC2 '
    'is reachable outside tests (ADR-3)',
    () {
      final String source = File(
        'lib/features/auth/presentation/screens/splash_screen.dart',
      ).readAsStringSync();

      expect(
        source,
        contains('authHistoryStore: getIt<AuthHistoryStore>()'),
        reason:
            'Without the marker the signed-out branch always resolves to '
            'welcome, so an expired prior session never reaches login (D3).',
      );
    },
  );
}
