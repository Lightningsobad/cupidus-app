import 'dart:async';

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/pairing/data/pairing_invitation.dart';
import 'package:cupid_mobile/features/pairing/data/partner_link.dart';
import 'package:cupid_mobile/features/pairing/data/partner_link_poller.dart';
import 'package:cupid_mobile/features/pairing/presentation/invite_cubit.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/invite_screen.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/waiting_screen.dart';
import 'package:cupid_mobile/features/pairing/presentation/waiting_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

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

/// Stands in for `WaitingScreen`'s GetIt-backed default cubit: its
/// `PairingRepository` constructor param is private to its own library, so it
/// cannot be faked from this file. Uses the real, already-tested
/// `PartnerLinkPoller` with a timer factory that is never invoked, so the
/// poller stays idle rather than scheduling a real `Timer`.
WaitingCubit _fakeWaitingCubit() {
  return WaitingCubit(
    getPartnerLink: () async => const PartnerLink(partnerId: null),
    expiresAt: DateTime.utc(2026, 1, 2),
    createPoller: (onPaired, onTimedOut) => PartnerLinkPoller(
      fetchPartnerLink: () async => const PartnerLink(partnerId: null),
      expiresAt: DateTime.utc(2026, 1, 2),
      onPaired: onPaired,
      onTimedOut: onTimedOut,
      timerFactory: (duration, callback) => _FakeTimer(callback),
    ),
  );
}

Widget _harness({required InviteCubit Function() createInviteCubit}) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    home: InviteScreen(
      createInviteCubit: createInviteCubit,
      createWaitingCubit: _fakeWaitingCubit,
    ),
  );
}

void main() {
  // The test environment has no default mock handler for the
  // `flutter/platform` channel's `Clipboard.setData` method, so without this
  // the awaited call inside `_copyAndAdvance` never completes.
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (
          MethodCall methodCall,
        ) async {
          return null;
        });
  });

  tearDown(() {
    TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('renders the code and a live expiresAt countdown', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 1, 1, 12);
    final invitation = PairingInvitation(
      code: '3F9A2B',
      expiresAt: now.add(const Duration(hours: 23, minutes: 40)),
    );

    await tester.pumpWidget(
      _harness(
        createInviteCubit: () => InviteCubit(
          generateInvitation: () async => invitation,
          now: () => now,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('3F9A2B'), findsOneWidget);
    expect(find.text('6-character code'), findsOneWidget);
    expect(find.text('Expires in 23h 40m'), findsOneWidget);
  });

  testWidgets('an idempotent refresh does not flash a spinner', (
    tester,
  ) async {
    var callCount = 0;
    final invitation = PairingInvitation(
      code: '3F9A2B',
      expiresAt: DateTime.utc(2026, 1, 2),
    );
    late InviteCubit cubit;

    await tester.pumpWidget(
      _harness(
        createInviteCubit: () {
          cubit = InviteCubit(
            generateInvitation: () async {
              callCount++;
              return invitation;
            },
            now: () => DateTime.utc(2026, 1, 1),
          );
          return cubit;
        },
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('3F9A2B'), findsOneWidget);

    await cubit.refresh();
    await tester.pump();

    expect(callCount, 2);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('3F9A2B'), findsOneWidget);
  });

  testWidgets('copy announces via a snackbar and advances to waiting', (
    tester,
  ) async {
    final invitation = PairingInvitation(
      code: '3F9A2B',
      expiresAt: DateTime.utc(2026, 1, 2),
    );

    await tester.pumpWidget(
      _harness(
        createInviteCubit: () => InviteCubit(
          generateInvitation: () async => invitation,
          now: () => DateTime.utc(2026, 1, 1),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Copy code'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));

    expect(find.text('Copied'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(WaitingScreen), findsOneWidget);
  });

  testWidgets('share announces a distinct message and advances to waiting', (
    tester,
  ) async {
    final invitation = PairingInvitation(
      code: '3F9A2B',
      expiresAt: DateTime.utc(2026, 1, 2),
    );

    await tester.pumpWidget(
      _harness(
        createInviteCubit: () => InviteCubit(
          generateInvitation: () async => invitation,
          now: () => DateTime.utc(2026, 1, 1),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Share invite'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));

    expect(find.text('Copied to share'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(WaitingScreen), findsOneWidget);
  });

  testWidgets('a generation failure shows an error with a retry action', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        createInviteCubit: () => InviteCubit(
          generateInvitation: () async => throw Exception('boom'),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.text('Could not create an invite code. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });
}
