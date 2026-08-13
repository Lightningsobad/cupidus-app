import 'dart:async';

import 'package:cupid_mobile/core/realtime/realtime_coordinator.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/pairing/data/partner_link.dart';
import 'package:cupid_mobile/features/pairing/data/partner_link_poller.dart';
import 'package:cupid_mobile/features/pairing/presentation/joincode_cubit.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/joincode_screen.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/paired_screen.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/waiting_screen.dart';
import 'package:cupid_mobile/features/pairing/presentation/waiting_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

/// Duplicated from `waiting_screen_test.dart` (P2's own test fakes are not
/// exported/importable across test files) so this phase's arrival-path test
/// can drive `WaitingCubit`'s poll without waiting on real timers.
class _FakeLifecycleSource implements RealtimeLifecycleSource {
  _FakeLifecycleSource(this.currentState);

  @override
  AppLifecycleState currentState;

  final _controller = StreamController<AppLifecycleState>.broadcast(
    sync: true,
  );

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

Widget _themed(Widget home) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    home: home,
  );
}

void main() {
  testWidgets(
    'reachable via WaitingScreen.onPaired (inviter path, poll-triggered '
    'auto-navigation)',
    (tester) async {
      const link = PartnerLink(partnerId: 'partner-1');
      final lifecycle = _FakeLifecycleSource(AppLifecycleState.resumed);
      final scheduled = <_FakeTimer>[];

      await tester.pumpWidget(
        _themed(
          WaitingScreen(
            expiresAt: DateTime.utc(2026, 1, 2),
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
            onPaired: (context, _) => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const PairedScreen()),
            ),
          ),
        ),
      );
      await tester.pump();

      // Simulate the poll detecting `partnerId != null` — no user tap.
      scheduled.single.callback();
      await tester.pump();
      // Bounded pumps rather than `pumpAndSettle`: `PairedScreen`'s bob
      // animation repeats forever by design (§8) and would never settle.
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(PairedScreen), findsOneWidget);
    },
  );

  testWidgets(
    'reachable via JoincodeScreen.onPaired (invitee path, user-initiated '
    'tap)',
    (tester) async {
      await tester.pumpWidget(
        _themed(
          JoincodeScreen(
            createJoincodeCubit: () =>
                JoincodeCubit(acceptInvitation: (_) async {}),
            onPaired: (context) => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const PairedScreen()),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField), '3F9A2B');
      await tester.tap(find.text('Pair up'));
      await tester.pump();
      await tester.pump();
      // Bounded pumps rather than `pumpAndSettle`: `PairedScreen`'s bob
      // animation repeats forever by design (§8) and would never settle.
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(PairedScreen), findsOneWidget);
    },
  );

  testWidgets('the celebratory status text is exposed as a live region', (
    tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();

    await tester.pumpWidget(_themed(const PairedScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    final Finder textFinder = find.text('You are paired!');
    expect(textFinder, findsOneWidget);

    final SemanticsNode node = tester.getSemantics(textFinder);
    expect(node.flagsCollection.isLiveRegion, isTrue);

    handle.dispose();
  });

  testWidgets(
    'the decorative couple-avatar celebration is excluded from semantics',
    (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(_themed(const PairedScreen()));
      await tester.pump();

      expect(
        find.descendant(
          of: find.byType(ExcludeSemantics),
          matching: find.byType(AnimatedBuilder),
        ),
        findsNWidgets(2),
      );

      handle.dispose();
    },
  );

  testWidgets('renders the design source celebration content', (tester) async {
    await tester.pumpWidget(_themed(const PairedScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(
      find.text(
        'From now on everything in Cupid belongs to both of you. '
        'No backing out 🎀',
      ),
      findsOneWidget,
    );
    expect(find.text('💕'), findsOneWidget);

    for (final String stat in <String>['1', '16', '0']) {
      expect(find.text(stat), findsOneWidget);
    }
    for (final String label in <String>['day', 'features', 'fights']) {
      expect(find.text(label), findsOneWidget);
    }

    expect(find.text('Sign the Love Contract →'), findsOneWidget);
  });

  testWidgets('the title and body use the design source type ramp', (
    tester,
  ) async {
    await tester.pumpWidget(_themed(const PairedScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    final TextStyle title = tester
        .widget<Text>(find.text('You are paired!'))
        .style!;
    expect(title.fontFamily, 'Nunito');
    expect(title.fontWeight, FontWeight.w900);
    expect(title.fontSize, 28);
    expect(title.height, 1.2);

    final TextStyle cta = tester
        .widget<Text>(find.text('Sign the Love Contract →'))
        .style!;
    expect(cta.fontSize, 16.5);
    expect(cta.fontWeight, FontWeight.w800);
  });

  testWidgets('the CTA reports the caller-supplied contract seam', (
    tester,
  ) async {
    int taps = 0;

    await tester.pumpWidget(
      _themed(PairedScreen(onSignContract: () => taps++)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.text('Sign the Love Contract →'));
    await tester.pump();

    expect(taps, 1);
  });
}
