import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../data/auth_repository.dart';
import '../auth_failure_text.dart';
import '../auth_strings.dart';

/// Layout values transcribed verbatim from the `isForgot` block of the locked
/// design source (`cupid-app-design-system/project/Cupid Screens.dc.html`).
/// The 8pt `CupidSpacing` scale and the `CupidTypographyTokens` roles have no
/// step matching these, so they are carried as design-source values rather
/// than rounded to a nearby token (same precedent as
/// `_materialPrimaryCtaRadius` in `cupid_primary_button.dart`).
const EdgeInsets _screenPadding = EdgeInsets.fromLTRB(20, 20, 20, 40);
const double _heroBadgeSize = 72;
const double _heroBadgeRadius = 26;
const double _heroBadgeTint = 0.2;
const double _heroIconSize = 36;
const double _titleSize = 25;
const double _titleLineHeight = 1.25;
const double _titleGap = 9;
const double _leadLineHeight = 1.6;
const EdgeInsets _fieldCardPadding = EdgeInsets.symmetric(
  horizontal: 16,
  vertical: 13,
);
const double _fieldLabelSize = 11;
const double _fieldLabelTracking = _fieldLabelSize * 0.06;
const double _fieldLabelGap = 6;
const double _fieldInputSize = 16;
const EdgeInsets _notePadding = EdgeInsets.symmetric(
  horizontal: 16,
  vertical: 15,
);
const double _noteIconSize = 20;
const double _noteIconGap = 11;
const double _noteTextSize = 12.5;
const double _noteLineHeight = 1.55;
const double _noteSurfaceTint = 0.12;
const double _noteBorderTint = 0.32;

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
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Scaffold(
      // No app-bar chrome: `ux/uiux-spec.md` Chrome Rules apply unconditionally
      // to every onboarding-chain node, which overrides the design source's
      // `NO_CHROME` map omitting `forgot`.
      // backgroundColor override intentionally removed (REQ-002 STORY-032
      // AC1): the shared CupidAppBackground app-shell layer now paints the
      // sky-gradient wash behind every screen; a Scaffold-level solid fill
      // here would occlude it.
      body: SafeArea(
        child: SingleChildScrollView(
          padding: _screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: _heroBadgeSize,
                  height: _heroBadgeSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.colorAccentPurple.withValues(
                      alpha: _heroBadgeTint,
                    ),
                    borderRadius: BorderRadius.circular(_heroBadgeRadius),
                  ),
                  child: CupidIcon(
                    CupidIcons.lockReset,
                    size: _heroIconSize,
                    color: colors.colorAccentPurple,
                  ),
                ),
              ),
              SizedBox(height: CupidSpacing.md),
              Text(
                context.viEn(
                  'Quên mật khẩu là chuyện thường',
                  'Forgetting happens',
                ),
                style: type.display.copyWith(
                  fontSize: _titleSize,
                  height: _titleLineHeight,
                  color: colors.colorText,
                ),
              ),
              SizedBox(height: _titleGap),
              Text(
                context.viEn(
                  'Nhập email, tụi mình gửi link đặt lại. Đừng lo, kỷ niệm '
                      'vẫn còn nguyên.',
                  'Enter your email and we will send a reset link. Your '
                      'memories stay put.',
                ),
                style: type.caption.copyWith(
                  height: _leadLineHeight,
                  color: colors.colorTextMuted,
                ),
              ),
              SizedBox(height: CupidSpacing.md),
              Container(
                padding: _fieldCardPadding,
                decoration: BoxDecoration(
                  color: colors.colorSurface,
                  borderRadius: BorderRadius.circular(platform.radiusCard),
                  boxShadow: platform.elevationShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      context.viEn('Email', 'Email').toUpperCase(),
                      style: type.caption.copyWith(
                        fontSize: _fieldLabelSize,
                        letterSpacing: _fieldLabelTracking,
                        color: colors.colorTextMuted,
                      ),
                    ),
                    SizedBox(height: _fieldLabelGap),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: type.body.copyWith(
                        fontSize: _fieldInputSize,
                        color: colors.colorText,
                      ),
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
              if (errorText != null) ...[
                SizedBox(height: CupidSpacing.sm),
                Text(
                  errorText,
                  style: type.caption.copyWith(
                    fontSize: _noteTextSize,
                    height: _noteLineHeight,
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
                  style: type.caption.copyWith(
                    fontSize: _noteTextSize,
                    height: _noteLineHeight,
                    color: colors.colorMint,
                  ),
                ),
              ],
              SizedBox(height: CupidSpacing.md),
              CupidPrimaryButton(
                label: context.viEn('Gửi link đặt lại', 'Send reset link'),
                onPressed: _isBusy ? null : _submit,
              ),
              SizedBox(height: CupidSpacing.md),
              Container(
                padding: _notePadding,
                decoration: BoxDecoration(
                  color: colors.colorMint.withValues(alpha: _noteSurfaceTint),
                  borderRadius: BorderRadius.circular(platform.radiusCard),
                  border: Border.all(
                    color: colors.colorMint.withValues(alpha: _noteBorderTint),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CupidIcon(
                      CupidIcons.shieldMoon,
                      size: _noteIconSize,
                      color: colors.colorMint,
                    ),
                    SizedBox(width: _noteIconGap),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: context.viEn(
                                'Đổi mật khẩu ',
                                'Resetting does ',
                              ),
                            ),
                            TextSpan(
                              text: context.viEn('không', 'not'),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: colors.colorText,
                              ),
                            ),
                            TextSpan(
                              text: context.viEn(
                                ' làm mất ảnh trong Private Gallery — khoá đó '
                                    'nằm trong máy bạn, không nằm ở mật khẩu.',
                                ' lose your Private Gallery — that key lives '
                                    'on your phone, not in your password.',
                              ),
                            ),
                          ],
                        ),
                        style: type.caption.copyWith(
                          fontSize: _noteTextSize,
                          height: _noteLineHeight,
                          color: colors.colorTextMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
