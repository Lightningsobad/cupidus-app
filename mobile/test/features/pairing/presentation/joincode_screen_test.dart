import 'dart:async';

import 'package:cupid_mobile/core/navigation/onboarding_chain.dart';
import 'package:cupid_mobile/core/navigation/onboarding_router.dart';
import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/pairing/data/pairing_failure.dart';
import 'package:cupid_mobile/features/pairing/presentation/joincode_cubit.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/joincode_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stands in for the `getIt`-registered production registry, which this suite
/// never calls `setupServiceLocator()` to build.
const Key pairedRouteKey = Key('routed_paired');
const Key inviteRouteKey = Key('routed_invite');
const Key vowRouteKey = Key('routed_vow');

OnboardingRouter _stubRouter() => OnboardingRouter(
  builders: <OnboardingNode, WidgetBuilder>{
    OnboardingNode.paired: (_) =>
        const Scaffold(key: pairedRouteKey, body: SizedBox.shrink()),
    OnboardingNode.invite: (_) =>
        const Scaffold(key: inviteRouteKey, body: SizedBox.shrink()),
  },
);

/// Serves the platform clipboard this suite has no real one for. Cleared by
/// [_clearClipboard] so a stubbed payload cannot leak into the next test.
void _stubClipboard(WidgetTester tester, String? text) {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (MethodCall call) async {
      if (call.method != 'Clipboard.getData') return null;
      return text == null ? null : <String, dynamic>{'text': text};
    },
  );
}

void _clearClipboard(WidgetTester tester) {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    null,
  );
}

String _enteredCode(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).controller!.text;

Widget _harness({
  required JoincodeCubit Function() createJoincodeCubit,
  void Function(BuildContext context)? onPaired,
}) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    home: JoincodeScreen(
      createJoincodeCubit: createJoincodeCubit,
      onPaired: onPaired,
      router: _stubRouter(),
    ),
  );
}

Future<void> _enterAndSubmit(WidgetTester tester, String code) async {
  await tester.enterText(find.byType(TextField), code);
  await tester.tap(find.text('Pair up'));
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('success calls onPaired', (tester) async {
    var pairedCalled = false;

    await tester.pumpWidget(
      _harness(
        createJoincodeCubit: () =>
            JoincodeCubit(acceptInvitation: (_) async {}),
        onPaired: (_) => pairedCalled = true,
      ),
    );
    await tester.pump();

    await _enterAndSubmit(tester, '3F9A2B');

    expect(pairedCalled, isTrue);
  });

  testWidgets('submits the code uppercased', (tester) async {
    String? sentCode;

    await tester.pumpWidget(
      _harness(
        createJoincodeCubit: () => JoincodeCubit(
          acceptInvitation: (code) async {
            sentCode = code;
          },
        ),
      ),
    );
    await tester.pump();

    await _enterAndSubmit(tester, '3f9a2b');

    expect(sentCode, '3F9A2B');
  });

  testWidgets(
    'InvalidOrExpiredCodeFailure renders its inline line and re-enables',
    (tester) async {
      await tester.pumpWidget(
        _harness(
          createJoincodeCubit: () => JoincodeCubit(
            acceptInvitation: (_) async =>
                throw const InvalidOrExpiredCodeFailure(),
          ),
        ),
      );
      await tester.pump();

      await _enterAndSubmit(tester, '3F9A2B');

      expect(find.text('Invalid or expired code'), findsOneWidget);
      expect(find.text('Pair up'), findsOneWidget);
      expect(find.byType(Dialog), findsNothing);
      final CupidPrimaryButton button = tester.widget(
        find.byType(CupidPrimaryButton),
      );
      expect(button.onPressed, isNotNull);
    },
  );

  testWidgets('AlreadyPairedFailure renders its inline line and re-enables', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        createJoincodeCubit: () => JoincodeCubit(
          acceptInvitation: (_) async => throw const AlreadyPairedFailure(),
        ),
      ),
    );
    await tester.pump();

    await _enterAndSubmit(tester, '3F9A2B');

    expect(find.text("You're already paired"), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
    final CupidPrimaryButton button = tester.widget(
      find.byType(CupidPrimaryButton),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('SelfInviteFailure renders its inline line and re-enables', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        createJoincodeCubit: () => JoincodeCubit(
          acceptInvitation: (_) async => throw const SelfInviteFailure(),
        ),
      ),
    );
    await tester.pump();

    await _enterAndSubmit(tester, '3F9A2B');

    expect(find.text('This is your own code'), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
    final CupidPrimaryButton button = tester.widget(
      find.byType(CupidPrimaryButton),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets(
    'InviterAlreadyPairedFailure (AC3 couple-only case) renders its inline '
    'line and re-enables',
    (tester) async {
      await tester.pumpWidget(
        _harness(
          createJoincodeCubit: () => JoincodeCubit(
            acceptInvitation: (_) async =>
                throw const InviterAlreadyPairedFailure(),
          ),
        ),
      );
      await tester.pump();

      await _enterAndSubmit(tester, '3F9A2B');

      expect(
        find.text('This person is already paired with someone else'),
        findsOneWidget,
      );
      expect(find.byType(Dialog), findsNothing);
      final CupidPrimaryButton button = tester.widget(
        find.byType(CupidPrimaryButton),
      );
      expect(button.onPressed, isNotNull);
    },
  );

  testWidgets(
    'an unmapped failure renders the generic fallback line and re-enables',
    (tester) async {
      await tester.pumpWidget(
        _harness(
          createJoincodeCubit: () => JoincodeCubit(
            acceptInvitation: (_) async =>
                throw UnmappedPairingFailure(const UnexpectedFailure()),
          ),
        ),
      );
      await tester.pump();

      await _enterAndSubmit(tester, '3F9A2B');

      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
      expect(find.byType(Dialog), findsNothing);
      final CupidPrimaryButton button = tester.widget(
        find.byType(CupidPrimaryButton),
      );
      expect(button.onPressed, isNotNull);
    },
  );

  testWidgets('disables the field and swaps the label for a spinner while '
      'submitting, with no layout shift', (tester) async {
    await tester.pumpWidget(
      _harness(
        createJoincodeCubit: () =>
            JoincodeCubit(acceptInvitation: (_) => Completer<void>().future),
      ),
    );
    await tester.pump();

    final buttonFinder = find.byType(CupidPrimaryButton);
    final Size idleSize = tester.getSize(buttonFinder);

    await tester.enterText(find.byType(TextField), '3F9A2B');
    await tester.tap(find.text('Pair up'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Pair up'), findsNothing);
    expect(tester.getSize(buttonFinder), idleSize);

    final TextField field = tester.widget(find.byType(TextField));
    expect(field.enabled, isFalse);

    final CupidPrimaryButton button = tester.widget(buttonFinder);
    expect(button.onPressed, isNull);
  });

  testWidgets(
    'with no onPaired override a successful accept lands on paired directly, '
    'never through a waiting frame (ADR-4)',
    (tester) async {
      await tester.pumpWidget(
        _harness(
          createJoincodeCubit: () =>
              JoincodeCubit(acceptInvitation: (_) async {}),
        ),
      );
      await tester.pump();

      await _enterAndSubmit(tester, '3F9A2B');
      await tester.pump(const Duration(seconds: 1));

      expect(find.byKey(pairedRouteKey), findsOneWidget);
      expect(find.byType(JoincodeScreen), findsNothing);
    },
  );

  testWidgets('carries no header or tab chrome (AC4 NO_CHROME/NO_TABS)', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        createJoincodeCubit: () =>
            JoincodeCubit(acceptInvitation: (_) async {}),
      ),
    );
    await tester.pump();

    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(CupidHeader), findsNothing);
    expect(find.byType(BottomNavigationBar), findsNothing);
    expect(find.byType(CupidTabBar), findsNothing);
  });

  testWidgets('the in-body back control still pops the route', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCupidTheme(
          platform: CupidPlatform.material,
          brightness: Brightness.dark,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => JoincodeScreen(
                      createJoincodeCubit: () =>
                          JoincodeCubit(acceptInvitation: (_) async {}),
                      router: _stubRouter(),
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(JoincodeScreen), findsOneWidget);

    await tester.tap(find.byIcon(CupidIcons.arrowBack));
    await tester.pumpAndSettle();

    expect(find.byType(JoincodeScreen), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('a pasted code fills every slot at once', (tester) async {
    _stubClipboard(tester, '  3f9a2b  ');
    addTearDown(() => _clearClipboard(tester));

    String? sentCode;
    await tester.pumpWidget(
      _harness(
        createJoincodeCubit: () => JoincodeCubit(
          acceptInvitation: (code) async {
            sentCode = code;
          },
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Paste'));
    await tester.pumpAndSettle();

    expect(_enteredCode(tester), '3F9A2B');
    for (final String character in <String>['3', 'F', '9', 'A', '2', 'B']) {
      expect(find.text(character), findsOneWidget);
    }

    await tester.tap(find.text('Pair up'));
    await tester.pump();
    await tester.pump();
    expect(sentCode, '3F9A2B');
  });

  testWidgets('a longer clipboard payload is truncated to the code length', (
    tester,
  ) async {
    _stubClipboard(tester, 'ABCDEFGH');
    addTearDown(() => _clearClipboard(tester));

    await tester.pumpWidget(
      _harness(
        createJoincodeCubit: () =>
            JoincodeCubit(acceptInvitation: (_) async {}),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Paste'));
    await tester.pumpAndSettle();

    expect(_enteredCode(tester), 'ABCDEF');
  });

  testWidgets('an empty clipboard leaves the entry untouched', (tester) async {
    _stubClipboard(tester, null);
    addTearDown(() => _clearClipboard(tester));

    await tester.pumpWidget(
      _harness(
        createJoincodeCubit: () =>
            JoincodeCubit(acceptInvitation: (_) async {}),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), '3F9');
    await tester.tap(find.text('Paste'));
    await tester.pumpAndSettle();

    expect(_enteredCode(tester), '3F9');
  });

  testWidgets('backspace clears the slots one character at a time', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        createJoincodeCubit: () =>
            JoincodeCubit(acceptInvitation: (_) async {}),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), '3F9A2B');
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();
    expect(_enteredCode(tester), '3F9A2');
    expect(find.text('B'), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();
    expect(_enteredCode(tester), '3F9A');
    expect(find.text('2'), findsNothing);
  });

  testWidgets('the invite cross-link pushes invite instead of resetting the '
      'chain', (tester) async {
    await tester.pumpWidget(
      _harness(
        createJoincodeCubit: () =>
            JoincodeCubit(acceptInvitation: (_) async {}),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), '3F9');
    await tester.tap(find.text('I am the one with the code →'));
    await tester.pumpAndSettle();

    expect(find.byKey(inviteRouteKey), findsOneWidget);
    // A push, not a reset: this screen stays on the stack (offstage under the
    // opaque route), so popping back returns the half-typed code rather than a
    // fresh chain.
    expect(find.byType(JoincodeScreen, skipOffstage: false), findsOneWidget);

    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pop();
    await tester.pumpAndSettle();

    expect(find.byKey(inviteRouteKey), findsNothing);
    expect(_enteredCode(tester), '3F9');
  });

  testWidgets('AC3: the continue path resolves to paired, never vow', (
    tester,
  ) async {
    // Assumption A2 (`architecture/solution.md` §3): ADR-4 keeps
    // `acceptInvitation(code)` synchronous for the invitee, so this branch has
    // no `waiting` step. AC3's binding content is "not Fingerprint Vow", and
    // the router below registers `vow` precisely so its absence is an
    // assertion rather than a missing builder.
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCupidTheme(
          platform: CupidPlatform.material,
          brightness: Brightness.dark,
        ),
        home: JoincodeScreen(
          createJoincodeCubit: () =>
              JoincodeCubit(acceptInvitation: (_) async {}),
          router: OnboardingRouter(
            builders: <OnboardingNode, WidgetBuilder>{
              OnboardingNode.paired: (_) =>
                  const Scaffold(key: pairedRouteKey, body: SizedBox.shrink()),
              OnboardingNode.vow: (_) =>
                  const Scaffold(key: vowRouteKey, body: SizedBox.shrink()),
            },
          ),
        ),
      ),
    );
    await tester.pump();

    await _enterAndSubmit(tester, '3F9A2B');
    await tester.pumpAndSettle();

    expect(find.byKey(pairedRouteKey), findsOneWidget);
    expect(find.byKey(vowRouteKey), findsNothing);
  });
}
