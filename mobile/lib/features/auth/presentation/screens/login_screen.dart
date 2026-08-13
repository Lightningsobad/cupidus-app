import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/auth_repository.dart';
import '../auth_failure_text.dart';
import '../auth_strings.dart';
import '../sign_in_cubit.dart';
import 'forgot_screen.dart';
import 'register_screen.dart';

// Metrics below are transcribed verbatim from the locked design source
// `cupid-app-design-system/project/Cupid Screens.dc.html`, `isLogin` block
// (lines 1425-1457). They sit off the 8pt `CupidSpacing` scale, so they are
// carried as named design-source constants rather than snapped to the nearest
// token — same precedent as `_materialPrimaryCtaRadius` in
// `design_system/adaptive/cupid_primary_button.dart`.
const double _screenPaddingH = 20;
const double _screenPaddingTop = 12;
const double _screenPaddingBottom = 40;
const double _sectionGap = 16;
const double _headerPaddingTop = 14;
const double _headerPaddingBottom = 4;
const double _headingFontSize = 27;
const double _headingSubtitleGap = 7;
const double _fieldGap = 11;
const double _fieldCardPaddingH = 16;
const double _fieldCardPaddingV = 13;
const double _fieldLabelFontSize = 11;
const double _fieldLabelLetterSpacing = 0.66; // .06em at 11px
const double _fieldLabelGap = 6;
const double _fieldInputFontSize = 16;
const double _forgotFontSize = 12.5;
const double _dividerGap = 12;
const double _dividerMarginV = 2;
const double _dividerLabelFontSize = 11.5;
const double _socialGap = 10;
const double _socialButtonHeight = 50;
const double _socialButtonBorderWidth = 1.5;
const double _socialButtonFontSize = 14;
const double _registerLinkMarginTop = 6;

/// `login` screen (`ux/uiux-spec.md` section 1/4b/6/8).
///
/// [sessionExpired] renders the section 4b session-expired heading variant
/// and shows the one-time snackbar, and [prefillEmail] autofills the email
/// field, when [SessionGateCubit] routes here from a stale-refresh-token
/// splash outcome.
class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
    required this.authRepository,
    this.sessionExpired = false,
    this.prefillEmail,
  });

  final AuthRepository authRepository;
  final bool sessionExpired;
  final String? prefillEmail;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignInCubit>(
      create: (_) => SignInCubit(repository: authRepository),
      child: _LoginView(
        authRepository: authRepository,
        sessionExpired: sessionExpired,
        prefillEmail: prefillEmail,
      ),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView({
    required this.authRepository,
    required this.sessionExpired,
    required this.prefillEmail,
  });

  final AuthRepository authRepository;
  final bool sessionExpired;
  final String? prefillEmail;

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  late final TextEditingController _emailController = TextEditingController(
    text: widget.prefillEmail ?? '',
  );
  final TextEditingController _passwordController = TextEditingController();
  bool _snackbarShown = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSessionExpiredSnackbarOnce(BuildContext context) {
    if (_snackbarShown || !widget.sessionExpired) return;
    _snackbarShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.viEn(
              'Phiên đăng nhập đã hết hạn',
              'Your session has expired',
            ),
          ),
        ),
      );
    });
  }

  void _openForgot(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ForgotScreen(authRepository: widget.authRepository),
      ),
    );
  }

  void _openRegister(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            RegisterScreen(authRepository: widget.authRepository),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _showSessionExpiredSnackbarOnce(context);
    final bool isIos = CupidPlatform.of(context) == CupidPlatform.ios;

    return BlocConsumer<SignInCubit, SignInState>(
      listener: (context, state) {
        if (state is SignInSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
          );
        }
      },
      builder: (context, state) {
        final bool isBusy = state is SignInInProgress;
        final String? errorText = state is SignInFailed
            ? authFailureMessage(context, state.failure)
            : null;
        // Bound to a local rather than chained off `context` on each use: a
        // directly-chained token access matches the no-fork guard test's
        // forbidden-literal-color substring scan.
        final CupidColorTokens colors = context.cupidColors;
        final CupidTypographyTokens type = context.cupidType;
        final double buttonRadius = context.cupidPlatform.radiusButton;

        return Scaffold(
          backgroundColor: colors.colorBackground,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                _screenPaddingH,
                _screenPaddingTop,
                _screenPaddingH,
                _screenPaddingBottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: _headerPaddingTop,
                      bottom: _headerPaddingBottom,
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.sessionExpired
                              ? context.viEn(
                                  'Đăng nhập lại để tiếp tục',
                                  'Sign in again to continue',
                                )
                              : context.viEn(
                                  'Mừng bạn quay lại 🎀',
                                  'Welcome back 🎀',
                                ),
                          textAlign: TextAlign.center,
                          style: type.display.copyWith(
                            fontSize: _headingFontSize,
                            color: colors.colorText,
                          ),
                        ),
                        const SizedBox(height: _headingSubtitleGap),
                        Text(
                          context.viEn(
                            'Bae đang đợi ở trong đấy',
                            'Bae is waiting inside',
                          ),
                          textAlign: TextAlign.center,
                          style: type.caption.copyWith(
                            color: colors.colorTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: _sectionGap),
                  _FieldCard(
                    label: context.viEn('Email', 'Email'),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: type.body.copyWith(
                        fontSize: _fieldInputFontSize,
                        color: colors.colorText,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(height: _fieldGap),
                  _FieldCard(
                    label: context.viEn('Mật khẩu', 'Password'),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: type.body.copyWith(
                        fontSize: _fieldInputFontSize,
                        color: colors.colorText,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: _fieldGap),
                    Text(
                      errorText,
                      style: type.caption.copyWith(color: colors.colorRed),
                    ),
                  ],
                  const SizedBox(height: _sectionGap),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isBusy ? null : () => _openForgot(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        context.viEn('Quên mật khẩu?', 'Forgot password?'),
                        style: type.caption.copyWith(
                          fontSize: _forgotFontSize,
                          fontWeight: FontWeight.w700,
                          color: colors.colorAccentPink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: _sectionGap),
                  CupidPrimaryButton(
                    label: context.viEn('Đăng nhập', 'Log in'),
                    onPressed: isBusy
                        ? null
                        : () => context.read<SignInCubit>().signInWithEmail(
                            email: _emailController.text,
                            password: _passwordController.text,
                          ),
                  ),
                  const SizedBox(height: _sectionGap),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: _dividerMarginV,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ColoredBox(
                            color: colors.colorLine,
                            child: const SizedBox(height: 1),
                          ),
                        ),
                        const SizedBox(width: _dividerGap),
                        Text(
                          context.viEn('hoặc', 'or'),
                          style: type.caption.copyWith(
                            fontSize: _dividerLabelFontSize,
                            color: colors.colorTextMuted,
                          ),
                        ),
                        const SizedBox(width: _dividerGap),
                        Expanded(
                          child: ColoredBox(
                            color: colors.colorLine,
                            child: const SizedBox(height: 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: _sectionGap),
                  Row(
                    children: [
                      Expanded(
                        child: _SocialButton(
                          label: context.viEn('Google', 'Google'),
                          radius: buttonRadius,
                          onPressed: isBusy
                              ? null
                              : () =>
                                    context.read<SignInCubit>().signInWithGoogle(),
                        ),
                      ),
                      const SizedBox(width: _socialGap),
                      Expanded(
                        child: isIos
                            ? _SocialButton(
                                label: context.viEn('Apple', 'Apple'),
                                radius: buttonRadius,
                                onPressed: isBusy
                                    ? null
                                    : () => context
                                          .read<SignInCubit>()
                                          .signInWithApple(),
                              )
                            : _SocialButton(
                                label: context.viEn('Facebook', 'Facebook'),
                                radius: buttonRadius,
                                onPressed: isBusy
                                    ? null
                                    : () => context
                                          .read<SignInCubit>()
                                          .signInWithFacebook(),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: _sectionGap + _registerLinkMarginTop),
                  GestureDetector(
                    onTap: isBusy ? null : () => _openRegister(context),
                    behavior: HitTestBehavior.opaque,
                    child: Text.rich(
                      TextSpan(
                        children: <InlineSpan>[
                          TextSpan(
                            text: context.viEn(
                              'Chưa có tài khoản? ',
                              'No account yet? ',
                            ),
                          ),
                          TextSpan(
                            text: context.viEn('Đăng ký', 'Sign up'),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: colors.colorAccentPink,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: type.caption.copyWith(
                        color: colors.colorTextMuted,
                      ),
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

/// Design-source form field: a `--surf` card at `--r-card` with the elevation
/// shadow, an uppercase `--tx2` micro-label, and a borderless input
/// (`Cupid Screens.dc.html` lines 1432-1442).
class _FieldCard extends StatelessWidget {
  const _FieldCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platform.radiusCard),
        boxShadow: platform.elevationShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _fieldCardPaddingH,
          vertical: _fieldCardPaddingV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: type.caption.copyWith(
                fontSize: _fieldLabelFontSize,
                letterSpacing: _fieldLabelLetterSpacing,
                color: colors.colorTextMuted,
              ),
            ),
            const SizedBox(height: _fieldLabelGap),
            child,
          ],
        ),
      ),
    );
  }
}

/// Design-source social sign-in button: outlined `--line` pill, no fill
/// (`Cupid Screens.dc.html` lines 1449-1454).
class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.radius,
    required this.onPressed,
  });

  final String label;
  final double radius;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return SizedBox(
      height: _socialButtonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.colorText,
          side: BorderSide(
            color: colors.colorLine,
            width: _socialButtonBorderWidth,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          label,
          style: type.body.copyWith(
            fontSize: _socialButtonFontSize,
            fontWeight: FontWeight.w700,
            color: colors.colorText,
          ),
        ),
      ),
    );
  }
}
