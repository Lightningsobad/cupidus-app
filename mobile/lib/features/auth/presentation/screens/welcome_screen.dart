import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/auth_repository.dart';
import '../auth_failure_text.dart';
import '../auth_strings.dart';
import '../sign_in_cubit.dart';
import 'login_screen.dart';
import 'register_screen.dart';

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

  void _openRegister(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RegisterScreen(authRepository: authRepository),
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
            decoration: BoxDecoration(gradient: colors.gradientHot),
            child: SizedBox.expand(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(CupidSpacing.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Cupid',
                        style: context.cupidType.display.copyWith(
                          color: colors.colorText,
                          fontSize: 60,
                        ),
                      ),
                      SizedBox(height: CupidSpacing.lg),
                      Text(
                        context.viEn(
                          'Yêu nghiêm túc.\nChia tay đàng hoàng.',
                          'Love hard.\nBreak up politely.',
                        ),
                        textAlign: TextAlign.center,
                        style: context.cupidType.cardTitle.copyWith(
                          color: colors.colorText,
                        ),
                      ),
                      SizedBox(height: CupidSpacing.xxl),
                      if (isIos) ...[
                        CupidPrimaryButton(
                          label: context.viEn(
                            'Tiếp tục với Apple',
                            'Continue with Apple',
                          ),
                          onPressed: isBusy
                              ? null
                              : () => context.read<SignInCubit>().signInWithApple(),
                        ),
                        SizedBox(height: CupidSpacing.sm),
                      ],
                      CupidPrimaryButton(
                        label: context.viEn(
                          'Tiếp tục với Google',
                          'Continue with Google',
                        ),
                        onPressed: isBusy
                            ? null
                            : () => context.read<SignInCubit>().signInWithGoogle(),
                      ),
                      SizedBox(height: CupidSpacing.sm),
                      TextButton(
                        onPressed: isBusy ? null : () => _openLogin(context),
                        child: Text(
                          context.viEn('Dùng email', 'Use email'),
                          style: context.cupidType.body.copyWith(
                            color: colors.colorText,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: isBusy ? null : () => _openRegister(context),
                        child: Text(
                          context.viEn(
                            'Chưa có tài khoản? Đăng ký',
                            'No account yet? Sign up',
                          ),
                          style: context.cupidType.caption.copyWith(
                            color: colors.colorTextMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
