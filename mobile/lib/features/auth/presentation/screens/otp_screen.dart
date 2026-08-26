import 'dart:async';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/navigation/onboarding_chain.dart';
import 'package:cupid_mobile/core/navigation/onboarding_router.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/auth_repository.dart';
import '../auth_failure_text.dart';
import '../otp_cubit.dart';

/// `mark_email_unread` glyph the design source's badge uses.
const IconData _markEmailUnreadIcon = IconData(
  0xf18a,
  fontFamily: CupidIcons.fontFamily,
);

/// Digits the design source's code input accepts.
const int _codeLength = 6;

/// `otp` screen (design canvas id `otp`, `isOtp` block of
/// `cupid-app-design-system/project/Cupid Screens.dc.html` lines 1495-1511).
class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.email,
    this.initialCode = '',
    this.resendSeconds = 60,
    this.authRepository,
    this.router,
    this.onVerify,
    this.onResend,
  });

  final String email;
  final String initialCode;
  final int resendSeconds;
  final AuthRepository? authRepository;
  final OnboardingRouter? router;
  final ValueChanged<String>? onVerify;
  final VoidCallback? onResend;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialCode,
  );
  final FocusNode _focusNode = FocusNode();
  OtpCubit? _otpCubit;

  AuthRepository? get _authRepository =>
      widget.authRepository ??
      (getIt.isRegistered<AuthRepository>() ? getIt<AuthRepository>() : null);

  OnboardingRouter? get _router =>
      widget.router ??
      (getIt.isRegistered<OnboardingRouter>()
          ? getIt<OnboardingRouter>()
          : null);

  String get _effectiveEmail =>
      widget.email.isNotEmpty ? widget.email : (_authRepository?.pendingEmail ?? '');

  @override
  void initState() {
    super.initState();
    final repo = _authRepository;
    if (repo != null && widget.onVerify == null) {
      _otpCubit = OtpCubit(repository: repo, email: _effectiveEmail);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _otpCubit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_otpCubit != null) {
      return BlocProvider<OtpCubit>.value(
        value: _otpCubit!,
        child: BlocConsumer<OtpCubit, OtpState>(
          listener: (context, state) {
            if (state is OtpSuccess) {
              _router?.goNext(context, OnboardingNode.otp);
            }
          },
          builder: (context, state) {
            final int currentResendSeconds = state.resendSeconds;
            final bool isSubmitting = state is OtpInProgress;
            final String? errorText = state is OtpFailed
                ? authFailureMessage(context, state.failure)
                : null;

            return _buildScaffold(
              context,
              resendSeconds: currentResendSeconds,
              isSubmitting: isSubmitting,
              errorText: errorText,
              onVerifyAction: (code) => _otpCubit!.verifyCode(code),
              onResendAction: () => _otpCubit!.resendCode(),
            );
          },
        ),
      );
    }

    return _buildScaffold(
      context,
      resendSeconds: widget.resendSeconds,
      isSubmitting: false,
      errorText: null,
      onVerifyAction: (code) => widget.onVerify?.call(code),
      onResendAction: () => widget.onResend?.call(),
    );
  }

  Widget _buildScaffold(
    BuildContext context, {
    required int resendSeconds,
    required bool isSubmitting,
    required String? errorText,
    required ValueChanged<String> onVerifyAction,
    required VoidCallback onResendAction,
  }) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(child: _PopIn(child: _MailBadge(colors: colors))),
              const SizedBox(height: 20),
              Text(
                context.viEn('Kiểm tra hộp thư nhé', 'Check your inbox'),
                textAlign: TextAlign.center,
                style: type.display.copyWith(
                  color: colors.colorText,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 9),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: context.viEn(
                            'Tụi mình vừa gửi 6 chữ số tới ',
                            'We sent 6 digits to ',
                          ),
                        ),
                        TextSpan(
                          text: _effectiveEmail,
                          style: TextStyle(
                            color: colors.colorText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: type.caption.copyWith(
                      color: colors.colorTextMuted,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _CodeField(
                    controller: _controller,
                    focusNode: _focusNode,
                    colors: colors,
                    type: type,
                    onChanged: (code) {
                      setState(() {});
                      if (code.length == 6) {
                        onVerifyAction(code);
                      }
                    },
                  ),
                ),
              ),
              if (errorText != null) ...[
                const SizedBox(height: 14),
                Center(
                  child: Text(
                    errorText,
                    textAlign: TextAlign.center,
                    style: type.caption.copyWith(
                      color: colors.colorRed,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              Center(
                child: _ResendLine(
                  secondsRemaining: resendSeconds,
                  onResend: onResendAction,
                  colors: colors,
                  type: type,
                ),
              ),
              const SizedBox(height: 26),
              _GradientCta(
                label: isSubmitting
                    ? context.viEn('Đang xác nhận...', 'Verifying...')
                    : context.viEn('Xác nhận', 'Verify'),
                onPressed: isSubmitting
                    ? null
                    : () {
                        final code = _controller.text.trim();
                        onVerifyAction(code);
                      },
                colors: colors,
                type: type,
                platformTokens: platformTokens,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 78px rounded tile behind the mail glyph
class _MailBadge extends StatelessWidget {
  const _MailBadge({required this.colors});

  final CupidColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 78,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.colorAccentPink.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(28),
      ),
      child: CupidIcon(
        _markEmailUnreadIcon,
        size: 40,
        color: colors.colorAccentPink,
      ),
    );
  }
}

class _PopIn extends StatefulWidget {
  const _PopIn({required this.child});

  final Widget child;

  @override
  State<_PopIn> createState() => _PopInState();
}

class _PopInState extends State<_PopIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..forward();

  late final Animation<double> _pop = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pop,
      builder: (BuildContext context, Widget? child) {
        final double t = _pop.value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - t)),
            child: Transform.scale(scale: 0.94 + 0.06 * t, child: child),
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _CodeField extends StatelessWidget {
  const _CodeField({
    required this.controller,
    required this.focusNode,
    required this.colors,
    required this.type,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final CupidColorTokens colors;
  final CupidTypographyTokens type;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final String code = controller.text;

    return Stack(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (int i = 0; i < _codeLength; i++) ...<Widget>[
              if (i > 0) const SizedBox(width: 9),
              _CodeBox(
                key: Key('otp-cell-$i'),
                digit: i < code.length ? code[i] : null,
                caret: i == code.length,
                colors: colors,
                type: type,
              ),
            ],
          ],
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              showCursor: false,
              enableInteractiveSelection: false,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(_codeLength),
              ],
              decoration: const InputDecoration.collapsed(hintText: ''),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox({
    super.key,
    required this.digit,
    required this.caret,
    required this.colors,
    required this.type,
  });

  final String? digit;
  final bool caret;
  final CupidColorTokens colors;
  final CupidTypographyTokens type;

  @override
  Widget build(BuildContext context) {
    final bool filled = digit != null;

    return Container(
      width: 49,
      height: 59,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: filled ? colors.colorAccentPink : colors.colorLine,
          width: 1.5,
        ),
        boxShadow: filled ? colors.glowShadow : null,
      ),
      child: filled || caret
          ? Text(
              digit ?? '|',
              style: type.display.copyWith(
                color: filled ? colors.colorText : colors.colorAccentPink,
                fontSize: 24,
              ),
            )
          : null,
    );
  }
}

class _ResendLine extends StatelessWidget {
  const _ResendLine({
    required this.secondsRemaining,
    required this.onResend,
    required this.colors,
    required this.type,
  });

  final int secondsRemaining;
  final VoidCallback? onResend;
  final CupidColorTokens colors;
  final CupidTypographyTokens type;

  @override
  Widget build(BuildContext context) {
    final TextStyle base = type.caption.copyWith(
      color: colors.colorTextMuted,
      fontSize: 12.5,
    );

    if (secondsRemaining <= 0) {
      return GestureDetector(
        key: const Key('otp-resend'),
        onTap: onResend,
        child: Text(
          context.viEn('Gửi lại mã', 'Resend code'),
          style: base.copyWith(
            color: colors.colorAccentPink,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    final Duration left = Duration(seconds: secondsRemaining);
    final String minutes = left.inMinutes.toString().padLeft(2, '0');
    final String seconds = (left.inSeconds % 60).toString().padLeft(2, '0');

    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(text: context.viEn('Gửi lại sau ', 'Resend in ')),
          TextSpan(
            text: '$minutes:$seconds',
            style: type.labelMono.copyWith(
              color: colors.colorText,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      style: base,
    );
  }
}

class _GradientCta extends StatelessWidget {
  const _GradientCta({
    required this.label,
    required this.onPressed,
    required this.colors,
    required this.type,
    required this.platformTokens,
  });

  final String label;
  final VoidCallback? onPressed;
  final CupidColorTokens colors;
  final CupidTypographyTokens type;
  final CupidPlatformTokens platformTokens;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(
      platformTokens.radiusButton,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: colors.gradientHot,
        borderRadius: radius,
        boxShadow: colors.glowShadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: SizedBox(
            height: 54,
            child: Center(
              child: Text(
                label,
                style: type.body.copyWith(
                  color: colors.colorText,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension on BuildContext {
  String viEn(String vi, String en) =>
      Localizations.localeOf(this).languageCode == 'vi' ? vi : en;
}
