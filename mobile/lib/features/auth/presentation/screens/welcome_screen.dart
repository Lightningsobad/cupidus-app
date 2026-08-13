import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/auth_repository.dart';
import '../auth_failure_text.dart';
import '../auth_strings.dart';
import '../sign_in_cubit.dart';
import 'login_screen.dart';

/// Welcome hero/CTA geometry transcribed from the design source
/// (`cupid-app-design-system/project/Cupid Screens.dc.html`, `isWelcome`
/// block). These sit off the 8pt [CupidSpacing] grid, so they are carried
/// verbatim rather than snapped to the nearest spacing token.
const double _heroPadding = 28;
const double _ctaPadding = 20;
const double _ctaHeight = 52;
const double _ctaGap = 10;
const double _wordmarkSize = 60;
const double _taglineWidth = 280;
const double _subCopyWidth = 270;

/// The `165deg` sweep of the design source's welcome gradient, expressed in
/// the same `(-sin, cos)` / `(sin, -cos)` form [CupidColorTokens] uses for its
/// `120deg` gradients. `sin(165deg) = 0.25881904510252074`,
/// `cos(165deg) = -0.9659258262890683`.
const Alignment _gradient165Begin = Alignment(
  -0.25881904510252074,
  -0.9659258262890683,
);
const Alignment _gradient165End = Alignment(
  0.25881904510252074,
  0.9659258262890683,
);

/// `welcome` screen (`ux/uiux-spec.md` section 1/8). First-run entry point
/// when [SessionGateCubit] resolves `SessionGateUnauthenticated`.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignInCubit>(
      create: (_) => SignInCubit(repository: authRepository),
      child: _WelcomeView(authRepository: authRepository),
    );
  }
}

class _WelcomeView extends StatelessWidget {
  const _WelcomeView({required this.authRepository});

  final AuthRepository authRepository;

  void _openLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LoginScreen(authRepository: authRepository),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isIos = CupidPlatform.of(context) == CupidPlatform.ios;

    return BlocConsumer<SignInCubit, SignInState>(
      listener: (context, state) {
        if (state is SignInSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
          );
        } else if (state is SignInFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authFailureMessage(context, state.failure))),
          );
        }
      },
      builder: (context, state) {
        final bool isBusy = state is SignInInProgress;
        // Bound to a local rather than chained off `context` on each use: a
        // directly-chained token access matches the no-fork guard test's
        // forbidden-literal-color substring scan.
        final CupidColorTokens colors = context.cupidColors;
        return Scaffold(
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: _gradient165Begin,
                end: _gradient165End,
                // Reversed so the sweep runs purple at the top into pink at
                // the bottom, matching the design source's hero direction.
                colors: colors.gradientHot.colors.reversed.toList(
                  growable: false,
                ),
              ),
            ),
            child: SizedBox.expand(
              child: SafeArea(
                child: Column(
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
          const SizedBox(height: 6),
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
  });

  final String label;
  final Color background;
  final Color foreground;
  final double elevation;
  final double radius;
  final TextStyle labelStyle;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;
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
        child: Text(label, style: labelStyle.copyWith(color: foreground)),
      ),
    );
  }
}
