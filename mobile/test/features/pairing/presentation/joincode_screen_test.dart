import 'dart:async';

import 'package:cupid_mobile/core/navigation/onboarding_chain.dart';
import 'package:cupid_mobile/core/navigation/onboarding_router.dart';
import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/pairing/data/pairing_failure.dart';
import 'package:cupid_mobile/features/pairing/presentation/joincode_cubit.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/joincode_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stands in for the `getIt`-registered production registry, which this suite
/// never calls `setupServiceLocator()` to build.
const Key pairedRouteKey = Key('routed_paired');

OnboardingRouter _stubRouter() => OnboardingRouter(
  builders: <OnboardingNode, WidgetBuilder>{
    OnboardingNode.paired: (_) =>
        const Scaffold(key: pairedRouteKey, body: SizedBox.shrink()),
  },
);

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
}
