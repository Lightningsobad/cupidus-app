import 'dart:async';

import 'package:cupid_mobile/core/auth/cupid_auth.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/auth/data/auth_repository.dart';
import 'package:cupid_mobile/features/auth/data/firebase_sign_in_gateway.dart';
import 'package:cupid_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:cupid_mobile/features/auth/presentation/screens/splash_screen.dart';
import 'package:cupid_mobile/features/auth/presentation/screens/welcome_screen.dart';
import 'package:cupid_mobile/features/auth/presentation/session_gate_cubit.dart';
import 'package:cupid_mobile/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every method throws — this suite never drives a real sign-in, it only
/// needs an [AuthRepository] instance to satisfy [SplashScreen]'s
/// constructor and forward to the routes it pushes.
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
  required StreamController<CupidSessionState> controller,
  required Future<String?> Function({bool forceRefresh}) idToken,
}) {
  final AuthRepository authRepository = AuthRepository(
    gateway: _UnusedGateway(),
    api: CupidApiClient.create(),
  );

  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    home: SplashScreen(
      authRepository: authRepository,
      createSessionGateCubit: () => SessionGateCubit(
        sessionState: controller.stream,
        idToken: idToken,
      ),
    ),
  );
}

void main() {
  testWidgets('CupidSessionUnknown keeps splash on the checking state', (
    tester,
  ) async {
    final StreamController<CupidSessionState> controller =
        StreamController<CupidSessionState>();
    addTearDown(controller.close);

    await tester.pumpWidget(
      _harness(
        controller: controller,
        idToken: ({forceRefresh = false}) async => 'token',
      ),
    );
    await tester.pump(const Duration(seconds: 3));

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(WelcomeScreen), findsNothing);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('CupidSessionSignedOut routes to WelcomeScreen', (
    tester,
  ) async {
    final StreamController<CupidSessionState> controller =
        StreamController<CupidSessionState>();
    addTearDown(controller.close);

    await tester.pumpWidget(
      _harness(
        controller: controller,
        idToken: ({forceRefresh = false}) async => 'token',
      ),
    );

    controller.add(const CupidSessionSignedOut());
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets(
    'CupidSessionSignedIn with a resolving token routes to HomeScreen',
    (tester) async {
      final StreamController<CupidSessionState> controller =
          StreamController<CupidSessionState>();
      addTearDown(controller.close);

      await tester.pumpWidget(
        _harness(
          controller: controller,
          idToken: ({forceRefresh = false}) async => 'token',
        ),
      );

      controller.add(const CupidSessionSignedIn(uid: 'u1', email: 'a@b.com'));
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(HomeScreen), findsOneWidget);
    },
  );

  testWidgets(
    'CupidSessionSignedIn with a failing token routes to the session-expired '
    'LoginScreen variant',
    (tester) async {
      final StreamController<CupidSessionState> controller =
          StreamController<CupidSessionState>();
      addTearDown(controller.close);

      await tester.pumpWidget(
        _harness(
          controller: controller,
          idToken: ({forceRefresh = false}) =>
              Future<String?>.error(const SessionExpiredFailure()),
        ),
      );

      controller.add(
        const CupidSessionSignedIn(uid: 'u1', email: 'a@b.com'),
      );
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(LoginScreen), findsOneWidget);
      // The harness sets no explicit `Locale`, so `AuthLocaleText.viEn`
      // resolves to its English branch (flutter_test's default locale).
      expect(
        find.text('Sign in again to continue'),
        findsOneWidget,
      );
    },
  );
}
