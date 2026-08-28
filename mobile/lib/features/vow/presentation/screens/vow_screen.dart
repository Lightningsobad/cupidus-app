import 'dart:math' as math;

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../vow_strings.dart';

/// `vow` screen — the Fingerprint Vow dual-confirmation ritual. `NO_CHROME`:
/// no header, no tab bar.
///
/// Layout, spacing, color and typography are transcribed from the locked
/// design source `cupid-app-design-system/project/Cupid Screens.dc.html`
/// (`isVow` block). The bare numeric literals below are design-source pixel
/// values that fall off the 8pt [CupidSpacing] grid; they are carried verbatim
/// as named constants rather than rounded to the nearest token so the rendered
/// screen matches the source exactly.
///
/// The screen is presentational. The design source's `doVow` binding flips its
/// own local prototype state, and the underlying dual-confirmation business
/// logic (repository call, partner polling) belongs to the feature story that
/// owns it — so a completed hold flips local state and reports out through
/// [onVowSigned], exactly as `PairedScreen` renders its CTA without wiring a
/// route.
class VowScreen extends StatefulWidget {
  const VowScreen({
    super.key,
    this.selfVowed = false,
    this.partnerVowed = false,
    this.selfInitial,
    this.partnerInitial,
    this.onVowSigned,
    this.onEnterDashboard,
  });

  /// Whether the signed-in user has already taken the vow (`myVowed`).
  final bool selfVowed;

  /// Whether the partner has already taken the vow (`vowStatusB`).
  final bool partnerVowed;

  /// Leading avatar initial. Null renders the design's gradient disc without a
  /// glyph, matching `HomeScreen`'s presence row.
  final String? selfInitial;

  /// Trailing avatar initial. `GET /users/me` exposes only the partner's
  /// opaque `partnerId`, so production callers pass null.
  final String? partnerInitial;

  /// Fired once when a full [_holdDuration] dwell completes.
  final VoidCallback? onVowSigned;

  /// Destination for the design source's "Vào Dashboard" CTA. Choosing where
  /// `vow` navigates next is owned by the inter-screen navigation stories, so
  /// this screen renders the CTA but wires no route.
  final VoidCallback? onEnterDashboard;

  @override
  State<VowScreen> createState() => _VowScreenState();
}

/// `ux/uiux-spec.md` §5, §8 + `architecture/solution.md` ADR-006a: the shared
/// hold-to-sign ritual dwell, identical to `HoldToSignButton.holdDuration`.
const Duration _holdDuration = Duration(milliseconds: 1500);

const double _screenBottomPadding = 40;
const double _eyebrowFontSize = 10;

/// `letter-spacing:.2em` resolved against [_eyebrowFontSize].
const double _eyebrowLetterSpacing = _eyebrowFontSize * 0.2;
const double _titleFontSize = 29;
const double _titleLineHeight = 1.15;
const double _titleTopGap = 12;
const double _titleBottomGap = 8;
const double _subtitleFontSize = 13.5;
const double _subtitleLineHeight = 1.55;
const double _subtitleMaxWidth = 270;
const double _holdTargetTopGap = 34;
const double _holdTargetDiameter = 150;
const double _holdTargetBorderWidth = 1.5;
const double _pulseRingBorderWidth = 2;
const double _fingerprintGlyphSize = 78;
const double _signedDiscDiameter = 154;
const double _signedDiscBorderWidth = 2;
const double _checkGlyphSize = 72;
const double _statusRowTopGap = 30;
const double _statusRowGap = 14;
const double _statusAvatarDiameter = 38;
const double _statusAvatarInitialFontSize = 14;
const double _statusLabelGap = 6;
const double _statusLabelFontSize = 11;
const double _statusConnectorWidth = 34;
const double _ctaTopGap = 30;
const double _ctaHeight = 52;
const double _ctaHorizontalPadding = 26;
const double _ctaFontSize = 16.5;

class _VowScreenState extends State<VowScreen>
    with SingleTickerProviderStateMixin {
  // Eager, not `late final ... = `: an already-signed screen never builds the
  // hold target, so a lazy field would first initialize inside `dispose()`,
  // where `createTicker` cannot look up `TickerMode` any more.
  late final AnimationController _hold;

  late bool _signed;
  bool _holding = false;

  @override
  void initState() {
    super.initState();
    _signed = widget.selfVowed;
    _hold = AnimationController(vsync: this, duration: _holdDuration)
      ..addStatusListener(_onHoldStatusChanged);
  }

  @override
  void didUpdateWidget(covariant VowScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selfVowed != widget.selfVowed) {
      _signed = widget.selfVowed;
    }
  }

  @override
  void dispose() {
    _hold.dispose();
    super.dispose();
  }

  void _onHoldStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && _holding) {
      _completeVow();
    }
  }

  // Reaching the dwell deliberately leaves [_hold] parked at 1.0 instead of
  // resetting it: this runs inside the controller's own status callback, and
  // `_handleHoldStart` already rewinds with `forward(from: 0)`.
  void _completeVow() {
    if (_signed) return;
    _holding = false;
    setState(() => _signed = true);
    widget.onVowSigned?.call();
  }

  void _handleHoldStart() {
    if (_signed || _holding) return;
    setState(() => _holding = true);
    _hold.forward(from: 0);
  }

  void _handleHoldRelease() {
    if (!_holding) return;
    _hold.stop();
    _hold.value = 0;
    setState(() => _holding = false);
  }

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final bool bothVowed = _signed && widget.partnerVowed;

    return Scaffold(
      key: const Key('vow_screen'),
      // backgroundColor override intentionally removed (REQ-002 STORY-032
      // AC1): the shared CupidAppBackground app-shell layer now paints the
      // sky-gradient wash behind every screen; a Scaffold-level solid fill
      // here would occlude it.
      body: DecoratedBox(
        // `radial-gradient(circle at 50% 30%, rgba(123,47,190,.5),
        // transparent 62%)`. The end stop keeps the same hue at zero alpha so
        // the fade carries no gray fringe. CSS sizes a bare `circle` to the
        // farthest corner, which on the design frame (406x900, centre at
        // 50%/30%) puts the 62% stop at 0.62 * 662 = 410px — 1.01 of the
        // shortest side, the fraction [RadialGradient.radius] expects.
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.4),
            radius: 1.01,
            colors: <Color>[
              VowPalette.heroWash.withValues(alpha: 0.5),
              VowPalette.heroWash.withValues(alpha: 0),
            ],
          ),
        ),
        child: Stack(
          children: <Widget>[
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    CupidSpacing.lg,
                    0,
                    CupidSpacing.lg,
                    _screenBottomPadding,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Fingerprint Vow'.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: type.labelMono.copyWith(
                          fontSize: _eyebrowFontSize,
                          letterSpacing: _eyebrowLetterSpacing,
                          color: colors.colorAccentPink,
                        ),
                      ),
                      const SizedBox(height: _titleTopGap),
                      Text(
                        context.viEn(
                          'Cùng đặt ngón tay\nvào một lúc',
                          'Place your fingers\nat the same time',
                        ),
                        textAlign: TextAlign.center,
                        style: type.display.copyWith(
                          fontSize: _titleFontSize,
                          height: _titleLineHeight,
                          color: colors.colorText,
                        ),
                      ),
                      const SizedBox(height: _titleBottomGap),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: _subtitleMaxWidth,
                        ),
                        child: Text(
                          context.viEn(
                            'Vân tay xử lý ngay trên máy. Cupid chỉ biết “xong '
                                'rồi”, không biết vân tay của bạn.',
                            'Biometrics stay on-device. Cupid only learns that it '
                                'worked.',
                          ),
                          textAlign: TextAlign.center,
                          style: type.caption.copyWith(
                            fontSize: _subtitleFontSize,
                            height: _subtitleLineHeight,
                            color: colors.colorTextMuted,
                          ),
                        ),
                      ),
                      const SizedBox(height: _holdTargetTopGap),
                      if (_signed)
                        const _SignedDisc()
                      else
                        _HoldTarget(
                          progress: _hold,
                          holding: _holding,
                          onHoldStart: _handleHoldStart,
                          onHoldRelease: _handleHoldRelease,
                          onActivate: _completeVow,
                        ),
                      const SizedBox(height: _statusRowTopGap),
                      _VowStatusRow(
                        selfVowed: _signed,
                        partnerVowed: widget.partnerVowed,
                        selfInitial: widget.selfInitial,
                        partnerInitial: widget.partnerInitial,
                      ),
                      if (bothVowed) ...<Widget>[
                        const SizedBox(height: _ctaTopGap),
                        _EnterDashboardCta(onPressed: widget.onEnterDashboard),
                      ] else if (_signed) ...<Widget>[
                        const SizedBox(height: _ctaTopGap),
                        _EnterDashboardSoloCta(onPressed: widget.onEnterDashboard),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The idle/holding gesture affordance: the design source's `pulseRing` halo
/// over a gradient fingerprint disc.
///
/// The design source binds this element to a plain `onClick`, but AC3 and
/// `ux/uiux-spec.md` §5/§8 (ADR-006a) make the vow a 1.5s hold ritual. The
/// dwell is therefore rendered by sweeping the disc's own 1.5px border from
/// the design's `rgba(255,127,182,.5)` to full-alpha pink — the source
/// specifies no separate holding style, so no new geometry or color is
/// introduced for it.
///
/// Accessibility (§8): the [Semantics] activation gesture completes the vow
/// without the raw dwell, mirroring `HoldToSignButton`.
class _HoldTarget extends StatelessWidget {
  const _HoldTarget({
    required this.progress,
    required this.holding,
    required this.onHoldStart,
    required this.onHoldRelease,
    required this.onActivate,
  });

  final Animation<double> progress;
  final bool holding;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldRelease;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Semantics(
      key: const Key('vow_hold_target'),
      button: true,
      label: context.viEn(
        'Giữ 1,5 giây để ký Fingerprint Vow',
        'Hold for 1.5 seconds to sign the Fingerprint Vow',
      ),
      onTap: onActivate,
      child: ExcludeSemantics(
        child: GestureDetector(
          onTapDown: (_) => onHoldStart(),
          onTapUp: (_) => onHoldRelease(),
          onTapCancel: onHoldRelease,
          child: SizedBox(
            width: _holdTargetDiameter,
            height: _holdTargetDiameter,
            child: Stack(
              children: <Widget>[
                _PulseRing(color: colors.colorAccentPink),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          colors.colorAccentPink.withValues(alpha: 0.24),
                          colors.colorAccentPurple.withValues(alpha: 0.24),
                        ],
                      ),
                      border: Border.all(
                        color: colors.colorAccentPink.withValues(alpha: 0.5),
                        width: _holdTargetBorderWidth,
                      ),
                    ),
                    child: Center(
                      child: CupidIcon(
                        CupidIcons.fingerprint,
                        size: _fingerprintGlyphSize,
                        color: colors.colorAccentPink,
                      ),
                    ),
                  ),
                ),
                if (holding)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: progress,
                      builder: (BuildContext context, Widget? child) {
                        return CustomPaint(
                          painter: _HoldDwellPainter(
                            progress: progress.value,
                            color: colors.colorAccentPink,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Sweeps the disc's own border stroke clockwise from 12 o'clock as the 1.5s
/// dwell elapses.
class _HoldDwellPainter extends CustomPainter {
  const _HoldDwellPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final Rect bounds = (Offset.zero & size).deflate(
      _holdTargetBorderWidth / 2,
    );
    canvas.drawArc(
      bounds,
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _holdTargetBorderWidth
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_HoldDwellPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

/// One `pulseRing` keyframe run: `scale(.9)/opacity .7` expanding to
/// `scale(1.5)/opacity 0` over the first 70% of the cycle, then held invisible
/// for the remainder. The `isVow` block runs it at `1.9s ease-out infinite`
/// over a `2px solid var(--pink)` ring.
class _PulseRing extends StatefulWidget {
  const _PulseRing({required this.color});

  final Color color;

  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cycle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  )..repeat();

  @override
  void dispose() {
    _cycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _cycle,
        builder: (BuildContext context, Widget? child) {
          final double t = _cycle.value;
          if (t >= 0.7) return const SizedBox.shrink();
          final double eased = Curves.easeOut.transform(t / 0.7);
          return Opacity(
            opacity: 0.7 * (1 - eased),
            child: Transform.scale(scale: 0.9 + 0.6 * eased, child: child),
          );
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.color,
              width: _pulseRingBorderWidth,
            ),
          ),
        ),
      ),
    );
  }
}

/// The signed confirmation disc, played in on the design source's `boom`
/// keyframe: `scale(.2)/opacity 0` -> `scale(1.18)/opacity 1` at 55% ->
/// `scale(1)` over 600ms `ease-out`.
class _SignedDisc extends StatefulWidget {
  const _SignedDisc();

  @override
  State<_SignedDisc> createState() => _SignedDiscState();
}

class _SignedDiscState extends State<_SignedDisc>
    with SingleTickerProviderStateMixin {
  late final AnimationController _boom = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..forward();

  @override
  void dispose() {
    _boom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Semantics(
      key: const Key('vow_signed_disc'),
      liveRegion: true,
      label: context.viEn('Bạn đã ký Fingerprint Vow', 'You signed the vow'),
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _boom,
          builder: (BuildContext context, Widget? child) {
            final double t = Curves.easeOut.transform(_boom.value);
            final double scale = t <= 0.55
                ? 0.2 + (1.18 - 0.2) * (t / 0.55)
                : 1.18 + (1 - 1.18) * ((t - 0.55) / 0.45);
            return Opacity(
              opacity: (t / 0.55).clamp(0.0, 1.0),
              child: Transform.scale(scale: scale, child: child),
            );
          },
          child: Container(
            width: _signedDiscDiameter,
            height: _signedDiscDiameter,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.colorMint.withValues(alpha: 0.16),
              border: Border.all(
                color: colors.colorMint,
                width: _signedDiscBorderWidth,
              ),
            ),
            child: CupidIcon(
              CupidIcons.checkCircle,
              size: _checkGlyphSize,
              color: colors.colorMint,
            ),
          ),
        ),
      ),
    );
  }
}

/// The two-partner readiness row: `{{ vowStatusA }}` / `{{ vowStatusB }}`
/// under their gradient avatars, joined by a 34x1 `--line` connector.
class _VowStatusRow extends StatelessWidget {
  const _VowStatusRow({
    required this.selfVowed,
    required this.partnerVowed,
    required this.selfInitial,
    required this.partnerInitial,
  });

  final bool selfVowed;
  final bool partnerVowed;
  final String? selfInitial;
  final String? partnerInitial;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _VowStatusAvatar(
          gradient: VowPalette.selfAvatarGradient,
          initial: selfInitial,
          vowed: selfVowed,
        ),
        const SizedBox(width: _statusRowGap),
        SizedBox(
          width: _statusConnectorWidth,
          height: 1,
          child: ColoredBox(color: colors.colorLine),
        ),
        const SizedBox(width: _statusRowGap),
        _VowStatusAvatar(
          gradient: VowPalette.partnerAvatarGradient,
          initial: partnerInitial,
          vowed: partnerVowed,
        ),
      ],
    );
  }
}

class _VowStatusAvatar extends StatelessWidget {
  const _VowStatusAvatar({
    required this.gradient,
    required this.initial,
    required this.vowed,
  });

  final LinearGradient gradient;
  final String? initial;
  final bool vowed;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: _statusAvatarDiameter,
          height: _statusAvatarDiameter,
          alignment: Alignment.center,
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: gradient),
          child: initial == null
              ? null
              : Text(
                  initial!,
                  style: type.caption.copyWith(
                    fontSize: _statusAvatarInitialFontSize,
                    fontWeight: FontWeight.w700,
                    color: VowPalette.avatarInitial,
                  ),
                ),
        ),
        const SizedBox(height: _statusLabelGap),
        Text(
          vowed
              ? context.viEn('sẵn sàng', 'ready')
              : context.viEn('đang đợi', 'waiting'),
          style: type.caption.copyWith(
            fontSize: _statusLabelFontSize,
            color: colors.colorTextMuted,
          ),
        ),
      ],
    );
  }
}

class _EnterDashboardCta extends StatelessWidget {
  const _EnterDashboardCta({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final BorderRadius radius = BorderRadius.circular(
      context.cupidPlatform.radiusButton,
    );

    return SizedBox(
      height: _ctaHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.colorGreen,
          borderRadius: radius,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            key: const Key('vow_enter_dashboard_cta'),
            borderRadius: radius,
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _ctaHorizontalPadding,
              ),
              child: Center(
                child: Text(
                  context.viEn('Vào Dashboard', 'Enter Dashboard'),
                  style: type.body.copyWith(
                    fontSize: _ctaFontSize,
                    fontWeight: FontWeight.w700,
                    color: VowPalette.dashboardCtaInk,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EnterDashboardSoloCta extends StatelessWidget {
  const _EnterDashboardSoloCta({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final BorderRadius radius = BorderRadius.circular(
      context.cupidPlatform.radiusButton,
    );

    return SizedBox(
      height: _ctaHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.colorSurfaceAlt,
          borderRadius: radius,
          border: Border.all(color: colors.colorLine),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            key: const Key('vow_enter_dashboard_solo_cta'),
            borderRadius: radius,
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _ctaHorizontalPadding,
              ),
              child: Center(
                child: Text(
                  context.viEn('Vào Dashboard →', 'Enter Dashboard →'),
                  style: type.body.copyWith(
                    fontSize: _ctaFontSize,
                    fontWeight: FontWeight.w600,
                    color: colors.colorText,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

