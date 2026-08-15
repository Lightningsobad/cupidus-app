import 'dart:async';

import 'package:cupid_mobile/core/navigation/onboarding_chain.dart';
import 'package:cupid_mobile/core/navigation/onboarding_router.dart';
import 'package:cupid_mobile/core/realtime/realtime_coordinator.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/pairing/data/partner_link.dart';
import 'package:cupid_mobile/features/pairing/data/partner_link_poller.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/waiting_screen.dart';
import 'package:cupid_mobile/features/pairing/presentation/waiting_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLifecycleSource implements RealtimeLifecycleSource {
  _FakeLifecycleSource(this.currentState);

  @override
  AppLifecycleState currentState;

  final _controller = StreamController<AppLifecycleState>.broadcast(sync: true);

  @override
  Stream<AppLifecycleState> get states => _controller.stream;

  @override
  void dispose() => _controller.close();
}

class _FakeTimer implements Timer {
  _FakeTimer(this.callback);

  final void Function() callback;
  bool _cancelled = false;

  @override
  bool get isActive => !_cancelled;

  @override
  void cancel() => _cancelled = true;

  @override
  int get tick => 0;
}

/// Stands in for the `getIt`-registered production registry, which this suite
/// never calls `setupServiceLocator()` to build. `paired` resolves to a marked
/// stub rather than the real `PairedScreen` so these tests assert the edge was
/// taken without dragging that screen's forever-repeating bob animation in.
const Key pairedRouteKey = Key('routed_paired');

OnboardingRouter _stubRouter() => OnboardingRouter(
  builders: <OnboardingNode, WidgetBuilder>{
    OnboardingNode.paired: (_) =>
        const Scaffold(key: pairedRouteKey, body: SizedBox.shrink()),
  },
);

Widget _harness({
  required WaitingCubit Function() createWaitingCubit,
  void Function(BuildContext, PartnerLink)? onPaired,
}) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    home: WaitingScreen(
      expiresAt: DateTime.utc(2026, 1, 2),
      onPaired: onPaired,
      router: _stubRouter(),
      createWaitingCubit: createWaitingCubit,
    ),
  );
}

void main() {
  testWidgets('shows the waiting status text while unpaired', (tester) async {
    final lifecycle = _FakeLifecycleSource(AppLifecycleState.resumed);

    await tester.pumpWidget(
      _harness(
        createWaitingCubit: () => WaitingCubit(
          getPartnerLink: () async => throw UnimplementedError(),
          expiresAt: DateTime.utc(2026, 1, 2),
          createPoller: (onPaired, onTimedOut) => PartnerLinkPoller(
            fetchPartnerLink: () async => throw UnimplementedError(),
            expiresAt: DateTime.utc(2026, 1, 2),
            onPaired: onPaired,
            onTimedOut: onTimedOut,
            lifecycleSource: lifecycle,
            now: () => DateTime.utc(2026, 1, 1),
            timerFactory: (duration, callback) => _FakeTimer(callback),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Waiting for your partner…'), findsOneWidget);
    expect(find.text('Refresh'), findsOneWidget);
  });

  testWidgets(
    'a poll transition to paired updates the status text and invokes onPaired',
    (tester) async {
      const link = PartnerLink(partnerId: 'partner-1');
      final lifecycle = _FakeLifecycleSource(AppLifecycleState.resumed);
      final scheduled = <_FakeTimer>[];
      PartnerLink? handled;

      await tester.pumpWidget(
        _harness(
          createWaitingCubit: () => WaitingCubit(
            getPartnerLink: () async => link,
            expiresAt: DateTime.utc(2026, 1, 2),
            createPoller: (onPaired, onTimedOut) => PartnerLinkPoller(
              fetchPartnerLink: () async => link,
              expiresAt: DateTime.utc(2026, 1, 2),
              onPaired: onPaired,
              onTimedOut: onTimedOut,
              lifecycleSource: lifecycle,
              now: () => DateTime.utc(2026, 1, 1),
              timerFactory: (duration, callback) {
                final timer = _FakeTimer(callback);
                scheduled.add(timer);
                return timer;
              },
            ),
          ),
          onPaired: (context, l) => handled = l,
        ),
      );
      await tester.pump();

      scheduled.single.callback();
      await tester.pump();
      await tester.pump();

      expect(find.textContaining("You're paired"), findsOneWidget);
      expect(handled, link);
    },
  );

  testWidgets(
    'with no onPaired override the poll routes to paired and leaves no way '
    'back to waiting (P4 tail)',
    (tester) async {
      const link = PartnerLink(partnerId: 'partner-1');
      final lifecycle = _FakeLifecycleSource(AppLifecycleState.resumed);
      final scheduled = <_FakeTimer>[];

      await tester.pumpWidget(
        _harness(
          createWaitingCubit: () => WaitingCubit(
            getPartnerLink: () async => link,
            expiresAt: DateTime.utc(2026, 1, 2),
            createPoller: (onPaired, onTimedOut) => PartnerLinkPoller(
              fetchPartnerLink: () async => link,
              expiresAt: DateTime.utc(2026, 1, 2),
              onPaired: onPaired,
              onTimedOut: onTimedOut,
              lifecycleSource: lifecycle,
              now: () => DateTime.utc(2026, 1, 1),
              timerFactory: (duration, callback) {
                final timer = _FakeTimer(callback);
                scheduled.add(timer);
                return timer;
              },
            ),
          ),
        ),
      );
      await tester.pump();

      scheduled.single.callback();
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byKey(pairedRouteKey), findsOneWidget);
      // `resetTo`, not a push: `waiting` is gone from the stack rather than
      // sitting underneath where a back gesture could return to it.
      expect(find.byType(WaitingScreen), findsNothing);
    },
  );

  testWidgets('a timed-out poll surfaces the manual refresh fallback text', (
    tester,
  ) async {
    var clock = DateTime.utc(2026, 1, 1);
    final lifecycle = _FakeLifecycleSource(AppLifecycleState.resumed);
    final scheduled = <_FakeTimer>[];

    await tester.pumpWidget(
      _harness(
        createWaitingCubit: () => WaitingCubit(
          getPartnerLink: () async => const PartnerLink(partnerId: null),
          expiresAt: clock.add(const Duration(minutes: 2)),
          createPoller: (onPaired, onTimedOut) => PartnerLinkPoller(
            fetchPartnerLink: () async => const PartnerLink(partnerId: null),
            expiresAt: clock.add(const Duration(minutes: 2)),
            onPaired: onPaired,
            onTimedOut: onTimedOut,
            lifecycleSource: lifecycle,
            now: () => clock,
            timerFactory: (duration, callback) {
              final timer = _FakeTimer(callback);
              scheduled.add(timer);
              return timer;
            },
          ),
        ),
      ),
    );
    await tester.pump();

    clock = clock.add(const Duration(minutes: 2));
    scheduled.single.callback();
    await tester.pump();

    expect(
      find.text('This is taking a while — try refreshing'),
      findsOneWidget,
    );
    expect(find.text('Refresh'), findsOneWidget);
  });

  testWidgets('tapping Refresh manually re-checks via refreshNow', (
    tester,
  ) async {
    const link = PartnerLink(partnerId: 'partner-1');
    final lifecycle = _FakeLifecycleSource(AppLifecycleState.resumed);
    var callCount = 0;

    await tester.pumpWidget(
      _harness(
        createWaitingCubit: () => WaitingCubit(
          getPartnerLink: () async {
            callCount++;
            return callCount == 1 ? const PartnerLink(partnerId: null) : link;
          },
          expiresAt: DateTime.utc(2026, 1, 2),
          createPoller: (onPaired, onTimedOut) => PartnerLinkPoller(
            fetchPartnerLink: () async => const PartnerLink(partnerId: null),
            expiresAt: DateTime.utc(2026, 1, 2),
            onPaired: onPaired,
            onTimedOut: onTimedOut,
            lifecycleSource: lifecycle,
            now: () => DateTime.utc(2026, 1, 1),
            timerFactory: (duration, callback) => _FakeTimer(callback),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Refresh'));
    await tester.pump();

    expect(callCount, 1);
    expect(find.text('Waiting for your partner…'), findsOneWidget);

    await tester.tap(find.text('Refresh'));
    await tester.pump();

    expect(callCount, 2);
    expect(find.textContaining("You're paired"), findsOneWidget);
  });
}
