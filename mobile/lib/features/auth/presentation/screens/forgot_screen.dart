import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../data/auth_repository.dart';
import '../auth_failure_text.dart';
import '../auth_strings.dart';

/// `forgot` screen (`ux/uiux-spec.md` section 1/6). No dedicated cubit is in
/// this phase's required Test Scope; state is local since the only action is
/// a single fire-and-report [AuthRepository.sendPasswordResetEmail] call.
class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isBusy = false;
  bool _sent = false;
  Object? _failure;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isBusy = true;
      _failure = null;
    });
    try {
      await widget.authRepository.sendPasswordResetEmail(_emailController.text);
      if (!mounted) return;
      setState(() {
        _isBusy = false;
        _sent = true;
      });
    } catch (failure) {
      if (!mounted) return;
      setState(() {
        _isBusy = false;
        _failure = failure;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? errorText = _failure == null
        ? null
        : authFailureMessage(context, _failure!);
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
                context.viEn('Quên mật khẩu là chuyện thường', 'Forgetting happens'),
                style: context.cupidType.cardTitle.copyWith(
                  color: colors.colorText,
                ),
              ),
              SizedBox(height: CupidSpacing.sm),
              Text(
                context.viEn(
                  'Nhập email để nhận liên kết đặt lại mật khẩu.',
                  'Enter your email to receive a password reset link.',
                ),
                style: context.cupidType.body.copyWith(
                  color: colors.colorTextMuted,
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
              if (errorText != null) ...[
                SizedBox(height: CupidSpacing.sm),
                Text(
                  errorText,
                  style: context.cupidType.caption.copyWith(
                    color: colors.colorRed,
                  ),
                ),
              ],
              if (_sent) ...[
                SizedBox(height: CupidSpacing.sm),
                Text(
                  context.viEn(
                    'Đã gửi email đặt lại mật khẩu.',
                    'Password reset email sent.',
                  ),
                  style: context.cupidType.caption.copyWith(
                    color: colors.colorMint,
                  ),
                ),
              ],
              SizedBox(height: CupidSpacing.lg),
              CupidPrimaryButton(
                label: context.viEn('Gửi liên kết', 'Send link'),
                onPressed: _isBusy ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
