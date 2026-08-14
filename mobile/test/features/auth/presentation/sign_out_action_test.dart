import 'package:cupid_mobile/core/auth/session_termination.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/auth/data/auth_repository.dart';
import 'package:cupid_mobile/features/auth/data/firebase_sign_in_gateway.dart';
import 'package:cupid_mobile/features/auth/presentation/sign_out_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _UnusedGateway implements FirebaseSignInGateway {
  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<void> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) => throw UnimplementedError();

  @override
  Future<void> signInWithGoogle() => throw UnimplementedError();

  @override
  Future<void> signInWithApple() => throw UnimplementedError();

  @override
  Future<void> signInWithFacebook() => throw UnimplementedError();

  @override
  Future<void> sendEmailVerification() => throw UnimplementedError();

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      throw UnimplementedError();

  @override
  Future<bool> reloadEmailVerified() => throw UnimplementedError();
}

Widget _harness({
  required AuthRepository authRepository,
  FocusNode? focusNode,
  SessionTerminationNotifier? sessionTermination,
}) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    home: Scaffold(
      body: SignOutAction(
        authRepository: authRepository,
        focusNode: focusNode,
        sessionTermination: sessionTermination,
      ),
    ),
  );
}

void main() {
  testWidgets(
    'confirming the dialog tears down the session and publishes a '
    'user-initiated termination',
    (tester) async {
      var teardownCalls = 0;
      final authRepository = AuthRepository(
        gateway: _UnusedGateway(),
        api: CupidApiClient.create(),
        signOut: () async {
          teardownCalls++;
        },
      );
      final notifier = SessionTerminationNotifier();
      addTearDown(notifier.dispose);
      final reasons = <SessionTerminationReason>[];
      notifier.stream.listen(reasons.add);

      await tester.pumpWidget(
        _harness(authRepository: authRepository, sessionTermination: notifier),
      );

      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();

      expect(find.text('Log out?'), findsOneWidget);
      expect(
        find.text('Photos and private data on this device will be cleared.'),
        findsOneWidget,
      );

      // The dialog itself has two "Log out" targets (title tile + confirm
      // action) plus the body copy; the confirm button is the last one.
      await tester.tap(find.text('Log out').last);
      await tester.pumpAndSettle();

      expect(teardownCalls, 1);
      // ADR-6: this call site publishes a reason and never routes itself, so
      // the action is still mounted and the root listener owns the reset.
      expect(reasons, <SessionTerminationReason>[
        SessionTerminationReason.userInitiated,
      ]);
      expect(find.byType(SignOutAction), findsOneWidget);
    },
  );

  testWidgets(
    'cancelling the dialog runs no teardown and returns focus to the '
    'triggering control',
    (tester) async {
      var teardownCalls = 0;
      final authRepository = AuthRepository(
        gateway: _UnusedGateway(),
        api: CupidApiClient.create(),
        signOut: () async {
          teardownCalls++;
        },
      );
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      final notifier = SessionTerminationNotifier();
      addTearDown(notifier.dispose);
      final reasons = <SessionTerminationReason>[];
      notifier.stream.listen(reasons.add);

      await tester.pumpWidget(
        _harness(
          authRepository: authRepository,
          focusNode: focusNode,
          sessionTermination: notifier,
        ),
      );

      focusNode.requestFocus();
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();

      expect(find.text('Log out?'), findsOneWidget);
      expect(focusNode.hasFocus, isFalse);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Log out?'), findsNothing);
      expect(teardownCalls, 0);
      expect(reasons, isEmpty);
      expect(focusNode.hasFocus, isTrue);
    },
  );
}
