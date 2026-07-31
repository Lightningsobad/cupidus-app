import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../../../design_system/design_system.dart';
import '../../../auth/presentation/auth_strings.dart';
import '../reminder_firing_cubit.dart';
import '../reminder_strings.dart';

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
  late final AnimationController _shakeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
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
      color: colors.colorBackground.withValues(alpha: 0.94),
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
                      final double dx = 6 * (_shakeController.value * 2 - 1);
                      return Transform.translate(
                        offset: Offset(dx, 0),
                        child: child,
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(CupidSpacing.lg),
                      decoration: BoxDecoration(
                        gradient: colors.gradientHot,
                        shape: BoxShape.circle,
                        boxShadow: colors.glowShadow,
                      ),
                      child: CupidIcon(
                        CupidIcons.notificationsActive,
                        size: 48,
                        color: colors.colorText,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: CupidSpacing.lg),
                Text(
                  context.reminderFiringBody,
                  textAlign: TextAlign.center,
                  style: type.body.copyWith(color: colors.colorText),
                ),
                SizedBox(height: CupidSpacing.lg),
                _PartnerStateRow(state: widget.state),
                SizedBox(height: CupidSpacing.xl),
                Semantics(
                  label: context.reminderDismissAccessibleLabel,
                  button: true,
                  excludeSemantics: true,
                  child: Focus(
                    focusNode: _dismissFocusNode,
                    child: CupidPrimaryButton(
                      label: context.reminderDismissCta,
                      onPressed:
                          widget.state.viewerDismissed ? null : widget.onDismiss,
                    ),
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

/// Two-up "You" / "Partner" state row, mirroring the schedule screen's
/// dual-confirmation avatar-pair pattern (`ux/uiux-spec.md` §8 reuse note).
class _PartnerStateRow extends StatelessWidget {
  const _PartnerStateRow({required this.state});

  final ReminderFiringOpen state;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PartnerStateChip(
          label: context.viEn('Bạn', 'You'),
          dismissed: state.viewerDismissed,
        ),
        SizedBox(width: CupidSpacing.xl),
        _PartnerStateChip(
          label: context.viEn('Đối tác', 'Partner'),
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
        Text(
          dismissed ? context.reminderYouAwake : context.reminderStillAsleep,
          style: type.body.copyWith(color: stateColor, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
