import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/navigation/onboarding_chain.dart';
import 'package:cupid_mobile/core/navigation/onboarding_progress_resolver.dart';
import 'package:cupid_mobile/core/navigation/onboarding_router.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/account/domain/cupid_profile.dart';
import 'package:cupid_mobile/features/auth/data/auth_repository.dart';
import 'package:cupid_mobile/features/auth/data/firebase_sign_in_gateway.dart';
import 'package:cupid_mobile/features/auth/presentation/screens/forgot_screen.dart';
import 'package:cupid_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:cupid_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:cupid_mobile/features/auth/presentation/screens/welcome_screen.dart';
import 'package:cupid_mobile/features/onboarding/presentation/screens/onboarding_profile_setup_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every Firebase leg succeeds, so these tests observe the edge the screen
/// takes after the cubit reports success rather than the auth mechanics.
class _SucceedingGateway implements FirebaseSignInGateway {
  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signInWithApple() async {}

  @override
  Future<void> signInWithFacebook() async {}

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<bool> reloadEmailVerified() async => true;
}

class _FakeHttpClientAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode(<String, Object?>{'id': 'user-1'}),
    200,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    },
  );
}

AuthRepository _authRepository() {
  final CupidApi api = CupidApiClient.create();
  api.dio.httpClientAdapter = _FakeHttpClientAdapter();
  return AuthRepository(
    gateway: _SucceedingGateway(),
    api: api,
    signOut: () async {},
  );
}

/// Stand-in for a chain node. Keeps the edge assertions independent of screens
/// other phases own, and gives every node a builder so a wrong target shows up
/// as the wrong label rather than as `OnboardingRouteNotRegistered`.
class _NodeStub extends StatelessWidget {
  const _NodeStub(this.node);

  final OnboardingNode node;

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('node:${node.name}')));
}

Finder _node(OnboardingNode node) => find.text('node:${node.name}');

OnboardingRouter _router({
  Map<OnboardingNode, WidgetBuilder> overrides =
      const <OnboardingNode, WidgetBuilder>{},
}) {
  return OnboardingRouter(
    builders: <OnboardingNode, WidgetBuilder>{
      for (final OnboardingNode node in OnboardingNode.values)
        node: (_) => _NodeStub(node),
      ...overrides,
    },
  );
}

CupidProfile _profile({
  String? partnerId,
  bool vowTaken = false,
  String? displayName,
}) {
  return CupidProfile(
    id: 'user-1',
    email: 'user@example.com',
    language: 'vi',
    vowTaken: vowTaken,
    isGhostModeEnabled: true,
    displayName: displayName,
    partnerId: partnerId,
  );
}

OnboardingProgressResolver _resolver({
  required CupidProfile profile,
  bool emailVerified = true,
}) {
  return OnboardingProgressResolver(
    fetchProfile: () async => profile,
    reloadEmailVerified: () async => emailVerified,
  );
}

Widget _harness(Widget screen) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    locale: const Locale('vi'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: CupidPlatformOverride(
      platform: CupidPlatform.material,
      child: screen,
    ),
  );
}

bool _canPop(WidgetTester tester) =>
    tester.state<NavigatorState>(find.byType(Navigator)).canPop();

/// ADR-2's rule table as it is reachable from `login`, one entry per outcome
/// the router registry resolves. `profileSetup` is deliberately absent: it is
/// not registered in production, so a stub-registry assertion would prove
/// nothing about the shipped app. Its edge gets its own tests below, against
/// the real screen.
const List<(String, OnboardingNode)> _resolverOutcomes = <(String, OnboardingNode)>[
  ('paired and vow taken', OnboardingNode.home),
  ('paired without the vow', OnboardingNode.loveContract),
  ('email not verified', OnboardingNode.otp),
  ('unpaired and complete', OnboardingNode.pairingChoice),
];

OnboardingProgressResolver _resolverFor(OnboardingNode outcome) {
  return switch (outcome) {
    OnboardingNode.home => _resolver(
      profile: _profile(
        partnerId: 'partner-1',
        vowTaken: true,
        displayName: 'Mai',
      ),
    ),
    OnboardingNode.loveContract => _resolver(
      profile: _profile(partnerId: 'partner-1', displayName: 'Mai'),
    ),
    OnboardingNode.otp => _resolver(
      profile: _profile(displayName: 'Mai'),
      emailVerified: false,
    ),
    OnboardingNode.profileSetup => _resolver(profile: _profile()),
    _ => _resolver(profile: _profile(displayName: 'Mai')),
  };
}

void main() {
  group('welcome', () {
    testWidgets('"Dùng email" pushes login and keeps welcome underneath', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          WelcomeScreen(
            authRepository: _authRepository(),
            router: _router(),
            progressResolver: _resolver(profile: _profile()),
          ),
        ),
      );

      await tester.tap(find.text('Dùng email'));
      await tester.pumpAndSettle();

      expect(_node(OnboardingNode.login), findsOneWidget);
      expect(_canPop(tester), isTrue);
    });

    testWidgets('social sign-in lands on the resolved node, never straight on '
        'home', (tester) async {
      await tester.pumpWidget(
        _harness(
          WelcomeScreen(
            authRepository: _authRepository(),
            router: _router(),
            progressResolver: _resolverFor(OnboardingNode.pairingChoice),
          ),
        ),
      );

      await tester.tap(find.text('Tiếp tục với Google'));
      await tester.pumpAndSettle();

      expect(_node(OnboardingNode.pairingChoice), findsOneWidget);
      expect(_node(OnboardingNode.home), findsNothing);
      expect(_canPop(tester), isFalse);
    });

    testWidgets('social sign-in for an account with no display name resumes '
        'on the real profile setup screen', (tester) async {
      await tester.pumpWidget(
        _harness(
          WelcomeScreen(
            authRepository: _authRepository(),
            router: _router(),
            progressResolver: _resolverFor(OnboardingNode.profileSetup),
          ),
        ),
      );

      await tester.tap(find.text('Tiếp tục với Google'));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingProfileSetupScreen), findsOneWidget);
      expect(_canPop(tester), isFalse);
    });
  });

  group('register', () {
    testWidgets('success enters the chain at otp, not home', (tester) async {
      await tester.pumpWidget(
        _harness(
          RegisterScreen(
            authRepository: _authRepository(),
            router: _router(),
          ),
        ),
      );

      await tester.tap(find.byType(CupidPrimaryButton));
      await tester.pumpAndSettle();

      expect(_node(OnboardingNode.otp), findsOneWidget);
      expect(_node(OnboardingNode.home), findsNothing);
    });

    testWidgets('the footer link replaces register with login', (tester) async {
      await tester.pumpWidget(
        _harness(
          RegisterScreen(
            authRepository: _authRepository(),
            router: _router(),
          ),
        ),
      );

      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      expect(_node(OnboardingNode.login), findsOneWidget);
      expect(_canPop(tester), isFalse);
    });
  });

  group('login', () {
    for (final (String description, OnboardingNode outcome)
        in _resolverOutcomes) {
      testWidgets('success for an account that is $description resumes at '
          '${outcome.name}', (tester) async {
        await tester.pumpWidget(
          _harness(
            LoginScreen(
              authRepository: _authRepository(),
              router: _router(),
              progressResolver: _resolverFor(outcome),
            ),
          ),
        );

        await tester.tap(find.byType(CupidPrimaryButton));
        await tester.pumpAndSettle();

        expect(_node(outcome), findsOneWidget);
        // `resetTo`: a resumed user must not be able to swipe back into the
        // login stack.
        expect(_canPop(tester), isFalse);
      });
    }

    for (final OnboardingNode outcome in <OnboardingNode>[
      OnboardingNode.otp,
      OnboardingNode.pairingChoice,
    ]) {
      testWidgets('success for an unpaired account resuming at '
          '${outcome.name} never reaches home', (tester) async {
        await tester.pumpWidget(
          _harness(
            LoginScreen(
              authRepository: _authRepository(),
              router: _router(),
              progressResolver: _resolverFor(outcome),
            ),
          ),
        );

        await tester.tap(find.byType(CupidPrimaryButton));
        await tester.pumpAndSettle();

        expect(_node(OnboardingNode.home), findsNothing);
        expect(_node(outcome), findsOneWidget);
      });
    }

    // `profileSetup` has no registry entry — its screen needs the resolved
    // profile — so the resume edge must build the route itself. Asserted
    // against the real screen: a stub registry would pass even if production
    // threw `OnboardingRouteNotRegistered`.
    testWidgets('success for an account with no display name resumes on the '
        'real profile setup screen', (tester) async {
      await tester.pumpWidget(
        _harness(
          LoginScreen(
            authRepository: _authRepository(),
            router: _router(),
            progressResolver: _resolverFor(OnboardingNode.profileSetup),
          ),
        ),
      );

      await tester.tap(find.byType(CupidPrimaryButton));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingProfileSetupScreen), findsOneWidget);
      expect(_node(OnboardingNode.home), findsNothing);
      expect(_canPop(tester), isFalse);
    });

    testWidgets('continuing from the resumed profile setup lands on '
        'pairingChoice', (tester) async {
      await tester.pumpWidget(
        _harness(
          LoginScreen(
            authRepository: _authRepository(),
            router: _router(),
            progressResolver: _resolverFor(OnboardingNode.profileSetup),
          ),
        ),
      );

      await tester.tap(find.byType(CupidPrimaryButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tiếp tục → Ghép đôi'));
      await tester.pumpAndSettle();

      // `OnboardingChain.next(profileSetup)`. STORY-047 AC1 realigned the CTA
      // copy with the design source, so the label now names the node the chain
      // actually routes an unpaired resume to.
      expect(_node(OnboardingNode.pairingChoice), findsOneWidget);
      expect(_canPop(tester), isFalse);
    });

    testWidgets('the register link pushes register and keeps login underneath',
        (tester) async {
      await tester.pumpWidget(
        _harness(
          LoginScreen(
            authRepository: _authRepository(),
            router: _router(),
            progressResolver: _resolver(profile: _profile()),
          ),
        ),
      );

      await tester.tap(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is RichText &&
              widget.text.toPlainText() == 'Chưa có tài khoản? Đăng ký',
        ),
      );
      await tester.pumpAndSettle();

      expect(_node(OnboardingNode.register), findsOneWidget);
      expect(_canPop(tester), isTrue);
    });
  });

  group('forgot password', () {
    testWidgets('back from forgot returns to login', (tester) async {
      await tester.pumpWidget(
        _harness(
          LoginScreen(
            authRepository: _authRepository(),
            router: _router(
              overrides: <OnboardingNode, WidgetBuilder>{
                OnboardingNode.forgotPassword: (_) =>
                    ForgotScreen(authRepository: _authRepository()),
              },
            ),
            progressResolver: _resolver(profile: _profile()),
          ),
        ),
      );

      await tester.tap(find.text('Quên mật khẩu?'));
      await tester.pumpAndSettle();
      expect(find.byType(ForgotScreen), findsOneWidget);
      expect(_canPop(tester), isTrue);

      // AC4 leaves `forgot` chromeless, so the spec's
      // `forgot_password --back--> login` leg is the platform back gesture
      // rather than a header arrow (same shape as the `register` leg above).
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('Mừng bạn quay lại 🎀'), findsOneWidget);
      expect(_canPop(tester), isFalse);
    });
  });
}
