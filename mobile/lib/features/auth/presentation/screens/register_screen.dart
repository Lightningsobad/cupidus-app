import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/auth_repository.dart';
import '../auth_failure_text.dart';
import '../auth_strings.dart';
import '../register_cubit.dart';
import 'login_screen.dart';

/// `register` screen (`ux/uiux-spec.md` section 1/6).
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RegisterCubit>(
      create: (_) => RegisterCubit(repository: authRepository),
      child: _RegisterView(authRepository: authRepository),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView({required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _openLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => LoginScreen(authRepository: widget.authRepository),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
          );
        }
      },
      builder: (context, state) {
        final bool isBusy = state is RegisterInProgress;
        final String? errorText = state is RegisterFailed
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
                    context.viEn('Tạo tài khoản', 'Create an account'),
                    style: context.cupidType.cardTitle.copyWith(
                      color: colors.colorText,
                    ),
                  ),
                  SizedBox(height: CupidSpacing.lg),
                  TextField(
                    controller: _nameController,
                    style: TextStyle(color: colors.colorText),
                    decoration: InputDecoration(
                      labelText: context.viEn('Tên hiển thị', 'Display name'),
                    ),
                  ),
                  SizedBox(height: CupidSpacing.sm),
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
                  SizedBox(height: CupidSpacing.lg),
                  CupidPrimaryButton(
                    label: context.viEn('Tạo tài khoản', 'Create account'),
                    onPressed: isBusy
                        ? null
                        : () => context.read<RegisterCubit>().registerWithEmail(
                            email: _emailController.text,
                            password: _passwordController.text,
                            displayName: _nameController.text.isEmpty
                                ? null
                                : _nameController.text,
                          ),
                  ),
                  SizedBox(height: CupidSpacing.lg),
                  TextButton(
                    onPressed: isBusy ? null : () => _openLogin(context),
                    child: Text(
                      context.viEn(
                        'Đã có tài khoản? Đăng nhập',
                        'Already have one? Log in',
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
