import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../../../design_system/design_system.dart';
import '../reminder_firing_cubit.dart';
import '../reminder_strings.dart';
import 'reminder_confirmed_tick.dart';

/// Firing badge box and corner radius (design source
/// `Cupid Screens.dc.html` line 1659: `width:96px;height:96px;
/// border-radius:34px`).
const double _badgeSize = 96;
const double _badgeRadius = 34;

/// Body-copy measure (design source line 1661: `max-width:250px`).
const double _bodyMaxWidth = 250;

/// Dismiss pill box (design source line 1668: `max-width:300px;height:60px`).
const double _dismissPillMaxWidth = 300;
const double _dismissPillHeight = 60;

/// Hairline between the two partner state chips (design source line 1664:
/// `width:30px;height:1px`).
const double _partnerDividerWidth = 30;

/// Clock readout under the badge (design source line 1660: `font-size:52px`,
/// `line-height:1`).
const double _clockFontSize = 52;

/// Amber wash over the scrim (design source line 1658:
/// `radial-gradient(circle at 50% 26%,rgba(255,201,126,.34),transparent 62%)`).
/// CSS sizes an untyped `circle` against the farthest corner, which at the
/// 412x915 reference viewport puts the transparent stop about 1.06x the
/// shortest side out from the centre.
const Alignment _scrimGlowCenter = Alignment(0, -0.48);
const double _scrimGlowRadius = 1.06;
const double _scrimGlowOpacity = 0.34;

String _formatClock(DateTime time) {
  final DateTime local = time.toLocal();
  final String hh = local.hour.toString().padLeft(2, '0');
  final String mm = local.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

/// The Synced Reminder firing overlay (`ux/uiux-spec.md` §3): full-screen
/// scrim, shaking `notifications_active` badge (never the alarm-clock glyph
/// D1 rules out), body copy, per-partner state labels, and the swipe/button
/// dismiss affordance. Rendered by `ReminderOverlayHost` whenever
/// `ReminderFiringCubit`'s state is [ReminderFiringOpen].
class ReminderFiringOverlay extends StatefulWidget {
  const ReminderFiringOverlay({
    super.key,
    required this.state,
    required this.onDismiss,
  });

  final ReminderFiringOpen state;
  final VoidCallback onDismiss;

  @override
  State<ReminderFiringOverlay> createState() => _ReminderFiringOverlayState();
}

class _ReminderFiringOverlayState extends State<ReminderFiringOverlay>
    with SingleTickerProviderStateMixin {
  /// Half of the design source's 1s `shake` keyframe cycle, which
  /// `repeat(reverse: true)` completes in both directions.
  late final AnimationController _shakeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..repeat(reverse: true);

  final FocusNode _dismissFocusNode = FocusNode();
  bool _announced = false;

  @override
  void dispose() {
    _shakeController.dispose();
    _dismissFocusNode.dispose();
    super.dispose();
  }

  /// §7 a11y: announce the overlay as an alert-level interruption once per
  /// mount and move focus to the dismiss action, without re-announcing on
  /// every rebuild (e.g. a D5 foreground `stopperIds` refresh).
  void _announceOnce(BuildContext context) {
    if (_announced) return;
    _announced = true;
    final String message = context.reminderFiringBody;
    final TextDirection textDirection = Directionality.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      SemanticsService.announce(message, textDirection);
      _dismissFocusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    _announceOnce(context);

    return Material(
      color: colors.colorBackground.withValues(alpha: 0.95),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: _scrimGlowCenter,
            radius: _scrimGlowRadius,
            colors: <Color>[
              colors.colorAmber.withValues(alpha: _scrimGlowOpacity),
              colors.colorAmber.withValues(alpha: 0),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(CupidSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onHorizontalDragEnd: widget.state.viewerDismissed
                        ? null
                        : (_) => widget.onDismiss(),
                    child: AnimatedBuilder(
                      animation: _shakeController,
                      builder: (context, child) {
                        final double dx = 5 * (_shakeController.value * 2 - 1);
                        return Transform.translate(
                          offset: Offset(dx, 0),
                          child: child,
                        );
                      },
                      child: Container(
                        width: _badgeSize,
                        height: _badgeSize,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors.colorAmber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(_badgeRadius),
                        ),
                        child: CupidIcon(
                          CupidIcons.notificationsActive,
                          size: 52,
                          color: colors.colorButter,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: CupidSpacing.lg),
                  Text(
                    _formatClock(widget.state.reminder.time),
                    style: type.display.copyWith(
                      fontSize: _clockFontSize,
                      height: 1,
                      color: colors.colorText,
                    ),
                  ),
                  SizedBox(height: CupidSpacing.sm),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _bodyMaxWidth),
                    child: Text(
                      context.reminderFiringBody,
                      textAlign: TextAlign.center,
                      style: type.caption.copyWith(color: colors.colorTextMuted),
                    ),
                  ),
                  SizedBox(height: CupidSpacing.xl),
                  _PartnerStateRow(state: widget.state),
                  SizedBox(height: CupidSpacing.xl),
                  Semantics(
                    label: context.reminderDismissAccessibleLabel,
                    button: true,
                    excludeSemantics: true,
                    child: Focus(
                      focusNode: _dismissFocusNode,
                      child: _DismissPill(
                        label: context.reminderDismissCta,
                        onPressed: widget.state.viewerDismissed
                            ? null
                            : widget.onDismiss,
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
  }
}

/// Two-up "You" / "Partner" state row, mirroring the schedule screen's
/// dual-confirmation avatar-pair pattern (`ux/uiux-spec.md` §8 reuse note).
class _PartnerStateRow extends StatelessWidget {
  const _PartnerStateRow({required this.state});

  final ReminderFiringOpen state;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PartnerStateChip(
          label: context.reminderYouLabel,
          dismissed: state.viewerDismissed,
        ),
        SizedBox(width: CupidSpacing.sm),
        Container(width: _partnerDividerWidth, height: 1, color: colors.colorLine),
        SizedBox(width: CupidSpacing.sm),
        _PartnerStateChip(
          label: context.reminderPartnerLabel,
          dismissed: state.partnerDismissed,
        ),
      ],
    );
  }
}

class _PartnerStateChip extends StatelessWidget {
  const _PartnerStateChip({required this.label, required this.dismissed});

  final String label;
  final bool dismissed;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    // §7 a11y: dismissed/awake state is conveyed by this text label paired
    // with colour, never colour alone.
    final Color stateColor = dismissed ? colors.colorMint : colors.colorTextMuted;

    return Column(
      children: [
        Text(label, style: type.caption.copyWith(color: colors.colorTextMuted)),
        SizedBox(height: CupidSpacing.xs),
        Text.rich(
          TextSpan(
            children: <InlineSpan>[
              TextSpan(
                text: dismissed
                    ? context.reminderYouAwake
                    : context.reminderStillAsleep,
              ),
              if (dismissed) ReminderConfirmedTick.span(stateColor),
            ],
          ),
          style: type.caption.copyWith(
            color: stateColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Swipe-to-dismiss CTA (design source line 1668): full-width pill capped at
/// [_dismissPillMaxWidth], `gradientHot` fill, glow shadow and a leading
/// `swipe_right` glyph. Rendered at reduced opacity once the viewer has
/// already swiped, because the reminder only clears when both partners do.
class _DismissPill extends StatelessWidget {
  const _DismissPill({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;
    final BorderRadius radius = BorderRadius.circular(
      platformTokens.radiusButton,
    );

    return Opacity(
      opacity: onPressed == null ? 0.45 : 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _dismissPillMaxWidth),
        child: SizedBox(
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: colors.gradientHot,
              borderRadius: radius,
              boxShadow: colors.glowShadow,
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onPressed,
                borderRadius: radius,
                child: SizedBox(
                  height: _dismissPillHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupidIcon(
                        CupidIcons.swipeRight,
                        size: 24,
                        color: colors.colorText,
                      ),
                      SizedBox(width: CupidSpacing.sm),
                      Flexible(
                        child: Text(
                          label,
                          style: type.body.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colors.colorText,
                          ),
                        ),
                      ),
                    ],
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
