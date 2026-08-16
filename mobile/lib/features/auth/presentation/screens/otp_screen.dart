import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../auth_strings.dart';

/// `mark_email_unread` glyph the design source's badge uses. `CupidIcons` does
/// not expose it; the codepoint was read from the bundled
/// `assets/fonts/MaterialSymbolsRounded-Variable.ttf` cmap with `fontTools`,
/// not recalled from another icon font's PUA range.
const IconData _markEmailUnreadIcon = IconData(
  0xf18a,
  fontFamily: CupidIcons.fontFamily,
);

/// Digits the design source's code input accepts.
const int _codeLength = 6;

/// `otp` screen (design canvas id `otp`, `isOtp` block of
/// `cupid-app-design-system/project/Cupid Screens.dc.html` lines 1495-1511).
///
/// Presentational: the code field is real local state so the empty, partial,
/// and complete input states are reachable, but nothing is sent or verified
/// here — the app has no code-issuing backend. [onVerify] and [onResend] are
/// left for the story that owns the `register -> otp -> permissions` flow.
/// [resendSeconds] renders the design source's cooldown label and does not
/// tick; ticking is flow behaviour, not this screen's design fidelity.
class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.email,
    this.initialCode = '',
    this.resendSeconds = 0,
    this.onVerify,
    this.onResend,
  });

  /// Destination shown in the subtitle, emphasised the way the design source
  /// emphasises its `minh@gmail.com` fixture.
  final String email;

  /// Digits already entered when the screen opens.
  final String initialCode;

  /// Seconds left before a resend is allowed. `0` renders the
  /// resend-available state instead of the cooldown countdown.
  final int resendSeconds;

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

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return Scaffold(
      backgroundColor: colors.colorBackground,
      // No app-bar chrome: `ux/uiux-spec.md` Chrome Rules apply unconditionally
      // to every onboarding-chain node.
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
                  // The design source caps this block at 280px and its own
                  // Roboto fits the sentence on one line with ~6px to spare.
                  // Android's Roboto renders the same string just over that,
                  // so the literal cap wraps the email onto a second line and
                  // pushes everything below it down. 300 keeps the block
                  // narrow and centred while reproducing the design's line.
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
                          text: widget.email,
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
              // The design source's own metrics (6 x 49 cells + 5 x 9 gaps,
              // inside a 20px gutter) need 379px, so they overflow the 360dp
              // phones below the canvas's 412dp Android frame. Scaling down
              // keeps the frame exact where it fits and degrades instead of
              // painting an overflow stripe where it does not.
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _CodeField(
                    controller: _controller,
                    focusNode: _focusNode,
                    colors: colors,
                    type: type,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Center(
                child: _ResendLine(
                  secondsRemaining: widget.resendSeconds,
                  onResend: widget.onResend,
                  colors: colors,
                  type: type,
                ),
              ),
              const SizedBox(height: 26),
              _GradientCta(
                label: context.viEn('Xác nhận', 'Verify'),
                onPressed: widget.onVerify == null
                    ? null
                    : () => widget.onVerify!(_controller.text),
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

/// 78px rounded tile behind the mail glyph (design source
/// `background:rgba(255,127,182,.18)` — `--pink` at 18%).
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

/// Design source `animation:popIn .5s ease-out`, whose keyframes are
/// `scale(.94) translateY(8px) opacity 0 -> scale(1) translateY(0) opacity 1`.
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

/// Six-box code input. The boxes are the visual; a transparent field stacked
/// over them carries the real text state, so the design source's empty,
/// partial, and complete states are all reachable by typing.
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

/// One code cell. The design source sizes the cell `46x56` with a `1.5px`
/// border and no `box-sizing:border-box`, so its painted box is `49x59`;
/// Flutter insets borders, so the outer size carries the border here.
class _CodeBox extends StatelessWidget {
  const _CodeBox({
    super.key,
    required this.digit,
    required this.caret,
    required this.colors,
    required this.type,
  });

  /// `null` for a cell with no digit yet.
  final String? digit;

  /// Whether this cell holds the design source's pink text-entry caret.
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

/// Cooldown countdown (design source `Gửi lại sau <strong>00:42</strong>`) and,
/// once it expires, the resend action. The canvas only composes the cooldown
/// frame; the available state reuses the canvas's own inline-action idiom,
/// `<strong style="color:var(--pink)">`.
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

/// The screen's primary action. `CupidPrimaryButton` renders a flat
/// `colorAccentPink` fill, which does not match this screen's design source
/// (`background:var(--grad-hot)` plus `box-shadow:var(--glow)`); correcting
/// the shared widget would change every screen and is outside this story's
/// write scope, so the design-accurate treatment is built here.
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
