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

        return Scaffold(
          backgroundColor: colors.colorBackground,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(CupidSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: CupidSpacing.xl),
                  Text(
                    widget.sessionExpired
                        ? context.viEn(
                            'Đăng nhập lại để tiếp tục',
                            'Sign in again to continue',
                          )
                        : context.viEn('Mừng bạn quay lại 🎀', 'Welcome back 🎀'),
                    style: context.cupidType.cardTitle.copyWith(
                      color: colors.colorText,
                    ),
                  ),
                  SizedBox(height: CupidSpacing.lg),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: colors.colorText),
                    decoration: InputDecoration(
                      labelText: context.viEn('Email', 'Email'),
                    ),
                  ),
                  SizedBox(height: CupidSpacing.sm),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: TextStyle(color: colors.colorText),
                    decoration: InputDecoration(
                      labelText: context.viEn('Mật khẩu', 'Password'),
                    ),
                  ),
                  if (errorText != null) ...[
                    SizedBox(height: CupidSpacing.sm),
                    Text(
                      errorText,
                      style: context.cupidType.caption.copyWith(
                        color: colors.colorRed,
                      ),
                    ),
                  ],
                  SizedBox(height: CupidSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isBusy ? null : () => _openForgot(context),
                      child: Text(
                        context.viEn('Quên mật khẩu?', 'Forgot password?'),
                      ),
                    ),
                  ),
                  SizedBox(height: CupidSpacing.sm),
                  CupidPrimaryButton(
                    label: context.viEn('Đăng nhập', 'Log in'),
                    onPressed: isBusy
                        ? null
                        : () => context.read<SignInCubit>().signInWithEmail(
                            email: _emailController.text,
                            password: _passwordController.text,
                          ),
                  ),
                  SizedBox(height: CupidSpacing.lg),
                  Text(
                    context.viEn('hoặc', 'or'),
                    textAlign: TextAlign.center,
                    style: context.cupidType.caption.copyWith(
                      color: colors.colorTextMuted,
                    ),
                  ),
                  SizedBox(height: CupidSpacing.sm),
                  if (isIos)
                    OutlinedButton(
                      onPressed: isBusy
                          ? null
                          : () => context.read<SignInCubit>().signInWithApple(),
                      child: Text(context.viEn('Apple', 'Apple')),
                    )
                  else
                    OutlinedButton(
                      onPressed: isBusy
                          ? null
                          : () =>
                                context.read<SignInCubit>().signInWithFacebook(),
                      child: Text(context.viEn('Facebook', 'Facebook')),
                    ),
                  SizedBox(height: CupidSpacing.sm),
                  OutlinedButton(
                    onPressed: isBusy
                        ? null
                        : () => context.read<SignInCubit>().signInWithGoogle(),
                    child: Text(context.viEn('Google', 'Google')),
                  ),
                  SizedBox(height: CupidSpacing.lg),
                  TextButton(
                    onPressed: isBusy ? null : () => _openRegister(context),
                    child: Text(
                      context.viEn(
                        'Chưa có tài khoản? Đăng ký',
                        'No account yet? Sign up',
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
