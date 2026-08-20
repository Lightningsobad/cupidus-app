import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/navigation/onboarding_chain.dart';
import 'package:cupid_mobile/core/navigation/onboarding_progress_resolver.dart';
import 'package:cupid_mobile/core/navigation/onboarding_router.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/account/domain/cupid_profile.dart';
import 'package:cupid_mobile/features/onboarding/presentation/screens/onboarding_profile_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/auth_repository.dart';
import '../auth_failure_text.dart';
import '../auth_strings.dart';
import '../sign_in_cubit.dart';

/// Welcome hero/CTA geometry transcribed from the design source
/// (`cupid-app-design-system/project/Cupid Screens.dc.html`, `isWelcome`
/// block). These sit off the 8pt [CupidSpacing] grid, so they are carried
/// verbatim rather than snapped to the nearest spacing token.
const double _heroPadding = 28;
const double _ctaPadding = 20;
const double _ctaHeight = 52;
const double _ctaGap = 10;

/// The design source's CTA column is a flex with `gap:10px` between every
/// child, so the footnote's own `margin-top:6px` stacks on top of that gap
/// rather than replacing it (`Cupid Screens.dc.html` lines 80 and 86).
const double _footnoteMargin = 6;
const double _wordmarkSize = 60;
const double _taglineWidth = 280;
const double _subCopyWidth = 270;

/// Google mark geometry on the welcome CTA, from the design source's
/// `width:20px;height:20px` inline SVG and the row's `gap:9px`
/// (`Cupid Screens.dc.html` line 84). The login screen draws the same mark a
/// point smaller in a tighter two-up row, hence the separate constants there.
const double _googleMarkSize = 20;
const double _googleMarkGap = 9;

/// `welcome` screen (`ux/uiux-spec.md` section 1/8). First-run entry point
/// when [SessionGateCubit] resolves `SessionGateUnauthenticated`.
///
/// [router] and [progressResolver] default to the composition root; they are
/// injectable so the edge tests run without `getIt`, Firebase, or Dio.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.authRepository,
    this.router,
    this.progressResolver,
  });

  final AuthRepository authRepository;
  final OnboardingRouter? router;
  final OnboardingProgressResolver? progressResolver;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignInCubit>(
      create: (_) => SignInCubit(repository: authRepository),
      child: _WelcomeView(router: router, progressResolver: progressResolver),
    );
  }
}

class _WelcomeView extends StatefulWidget {
  const _WelcomeView({required this.router, required this.progressResolver});

  final OnboardingRouter? router;
  final OnboardingProgressResolver? progressResolver;

  @override
  State<_WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<_WelcomeView> {
  bool _resolving = false;

  OnboardingRouter get _router => widget.router ?? getIt<OnboardingRouter>();

  OnboardingProgressResolver get _progressResolver =>
      widget.progressResolver ?? getIt<OnboardingProgressResolver>();

  void _openLogin(BuildContext context) =>
      _router.push(context, OnboardingNode.login);

  /// Social sign-in lands the same way email sign-in does (ADR-2): where the
  /// account already is in the chain, never straight to `home`.
  ///
  /// `profileSetup` is not in the registry — its screen needs the resolved
  /// [CupidProfile] — so that one target is pushed directly with its argument,
  /// the way `pairing_choice` pushes `invite`/`joinCode`.
  Future<void> _resolveAndRoute(BuildContext context) async {
    if (_resolving) return;
    setState(() => _resolving = true);
    try {
      final OnboardingResume resume = await _progressResolver.resolve();
      if (!context.mounted) return;
      final CupidProfile? profile = resume.profile;
      if (resume.node == OnboardingNode.profileSetup && profile != null) {
        await Navigator.of(context).pushAndRemoveUntil<void>(
          _profileSetupRoute(profile),
          (Route<dynamic> route) => false,
        );
        return;
      }
      await _router.resetTo(context, resume.node);
    } finally {
      // Without this the CTAs would stay busy forever on a routing failure,
      // leaving the user stuck on welcome with no recovery.
      if (mounted) setState(() => _resolving = false);
    }
  }

  Route<void> _profileSetupRoute(CupidProfile profile) {
    return MaterialPageRoute<void>(
      settings: RouteSettings(name: OnboardingNode.profileSetup.name),
      builder: (BuildContext routeContext) => OnboardingProfileSetupScreen(
        profile: profile,
        onContinue: () =>
            _router.resetTo(routeContext, OnboardingNode.pairingChoice),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isIos = CupidPlatform.of(context) == CupidPlatform.ios;

    return BlocConsumer<SignInCubit, SignInState>(
      listener: (context, state) {
        if (state is SignInSuccess) {
          _resolveAndRoute(context);
        } else if (state is SignInFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authFailureMessage(context, state.failure))),
          );
        }
      },
      builder: (context, state) {
        final bool isBusy = state is SignInInProgress || _resolving;
        // Bound to a local rather than chained off `context` on each use: a
        // directly-chained token access matches the no-fork guard test's
        // forbidden-literal-color substring scan.
        final CupidColorTokens colors = context.cupidColors;
        return Scaffold(
          body: DecoratedBox(
            decoration: BoxDecoration(gradient: colors.gradientBrandBackdrop),
            child: SizedBox.expand(
              // StackFit.expand, not the default loose: a loose stack would let
              // the body shrink-wrap, and the stretch below would then size the
              // hero to its widest child instead of the screen.
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  SafeArea(
                    child: Column(
                      // Without stretch the hero shrink-wraps to its widest
                      // child (_subCopyWidth + _heroPadding*2) and this Column
                      // centers that box, pushing left-aligned hero content
                      // ~42px right of the design's _heroPadding.
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Expanded(child: _WelcomeHero()),
                        _WelcomeCtaBlock(
                          isIos: isIos,
                          isBusy: isBusy,
                          onUseEmail: () => _openLogin(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero();

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _heroPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cupid',
            style: type.display.copyWith(
              color: colors.colorText,
              fontSize: _wordmarkSize,
              height: 0.95,
              // -.03em at 60pt.
              letterSpacing: -1.8,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.colorText.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(2),
              ),
              child: const SizedBox(width: 52, height: 4),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _taglineWidth),
            child: Text(
              context.viEn(
                'Yêu nghiêm túc.\nChia tay đàng hoàng.',
                'Love hard.\nBreak up politely.',
              ),
              style: type.display.copyWith(
                color: colors.colorText,
                fontWeight: FontWeight.w700,
                fontSize: 23,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _subCopyWidth),
            child: Text(
              context.viEn(
                'App cho hai người. Không có newsfeed, không có người thứ ba.',
                'An app for two. No feed, no third wheel.',
              ),
              style: type.body.copyWith(
                color: colors.colorText.withValues(alpha: 0.78),
                fontSize: 14,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeCtaBlock extends StatelessWidget {
  const _WelcomeCtaBlock({
    required this.isIos,
    required this.isBusy,
    required this.onUseEmail,
  });

  final bool isIos;
  final bool isBusy;
  final VoidCallback onUseEmail;

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final double radius = context.cupidPlatform.radiusButton;
    final TextStyle labelStyle = type.body.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(_ctaPadding, 0, _ctaPadding, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isIos) ...[
            _FilledCta(
              label: context.viEn(
                'Tiếp tục với Apple',
                'Continue with Apple',
              ),
              background: colors.colorBackground,
              foreground: colors.colorText,
              elevation: 0,
              radius: radius,
              labelStyle: labelStyle,
              onPressed: isBusy
                  ? null
                  : () => context.read<SignInCubit>().signInWithApple(),
            ),
            const SizedBox(height: _ctaGap),
          ],
          _FilledCta(
            label: context.viEn(
              'Tiếp tục với Google',
              'Continue with Google',
            ),
            background: colors.colorText,
            foreground: colors.colorBackground,
            elevation: 2,
            radius: radius,
            labelStyle: labelStyle,
            mark: CupidBrandMark.google,
            markSize: _googleMarkSize,
            markGap: _googleMarkGap,
            onPressed: isBusy
                ? null
                : () => context.read<SignInCubit>().signInWithGoogle(),
          ),
          const SizedBox(height: _ctaGap),
          SizedBox(
            height: _ctaHeight,
            child: OutlinedButton(
              onPressed: isBusy ? null : onUseEmail,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.colorText,
                side: BorderSide(
                  color: colors.colorText.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
              child: Text(
                context.viEn('Dùng email', 'Use email'),
                style: labelStyle.copyWith(color: colors.colorText),
              ),
            ),
          ),
          const SizedBox(height: _ctaGap + _footnoteMargin),
          Text(
            context.viEn(
              'Đăng ký nghĩa là bạn chấp nhận bị dỗi khi seen không trả lời.',
              'By signing up you accept being sulked at for leaving messages '
                  'on read.',
            ),
            textAlign: TextAlign.center,
            style: type.caption.copyWith(
              color: colors.colorText.withValues(alpha: 0.65),
              fontSize: 11.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilledCta extends StatelessWidget {
  const _FilledCta({
    required this.label,
    required this.background,
    required this.foreground,
    required this.elevation,
    required this.radius,
    required this.labelStyle,
    required this.onPressed,
    this.mark,
    this.markSize = 0,
    this.markGap = 0,
  });

  final String label;
  final Color background;
  final Color foreground;
  final double elevation;
  final double radius;
  final TextStyle labelStyle;
  final VoidCallback? onPressed;

  /// Provider brand mark drawn before [label]. Null for providers the design
  /// source draws as a bare label.
  final CupidBrandMark? mark;
  final double markSize;
  final double markGap;

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;
    final Widget text = Text(
      label,
      style: labelStyle.copyWith(color: foreground),
    );
    return SizedBox(
      height: _ctaHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          shadowColor: colors.colorBackground,
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: mark == null
            ? text
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupidBrandMarkIcon(mark!, size: markSize),
                  SizedBox(width: markGap),
                  text,
                ],
              ),
      ),
    );
  }
}
