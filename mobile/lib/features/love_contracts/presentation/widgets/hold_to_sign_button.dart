import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

/// `ux/uiux-spec.md` §5, §8 + `architecture/solution.md` ADR-006a: the
/// hold-to-sign ritual control. The dwell fill is entirely widget-local —
/// only [onHoldStarted]/[onHoldCancelled]/[onHoldCompleted] cross into the
/// `Bloc` (ADR-006a forbids streaming per-frame progress through state).
/// A completed dwell fires [onHoldCompleted] exactly once; releasing before
/// [holdDuration] elapses fires [onHoldCancelled] instead and never
/// [onHoldCompleted].
///
/// Accessibility (§8): the [Semantics] activation gesture (double-tap under
/// a screen reader, or a plain tap when no assistive technology is active)
/// dispatches the same started -> completed pair immediately, without the
/// raw hold dwell. This is the control's required accessible alternative to
/// the gesture-only interaction, not a decorative extra.
class HoldToSignButton extends StatefulWidget {
  const HoldToSignButton({
    super.key,
    required this.enabled,
    required this.label,
    required this.semanticLabel,
    required this.onHoldStarted,
    required this.onHoldCancelled,
    required this.onHoldCompleted,
    this.holdDuration = const Duration(milliseconds: 1500),
  });

  final bool enabled;
  final String label;
  final String semanticLabel;
  final VoidCallback onHoldStarted;
  final VoidCallback onHoldCancelled;
  final VoidCallback onHoldCompleted;
  final Duration holdDuration;

  @override
  State<HoldToSignButton> createState() => _HoldToSignButtonState();
}

class _HoldToSignButtonState extends State<HoldToSignButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress;
  bool _holding = false;
  bool _completedDispatched = false;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(vsync: this, duration: widget.holdDuration)
      ..addStatusListener(_onStatusChanged);
  }

  @override
  void didUpdateWidget(covariant HoldToSignButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.holdDuration != widget.holdDuration) {
      _progress.duration = widget.holdDuration;
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed &&
        _holding &&
        !_completedDispatched) {
      _completedDispatched = true;
      widget.onHoldCompleted();
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled || _holding) return;
    _holding = true;
    _completedDispatched = false;
    widget.onHoldStarted();
    _progress.forward(from: 0);
  }

  void _handleRelease() {
    if (!_holding) return;
    final bool wasCompleted = _completedDispatched;
    _holding = false;
    _progress.stop();
    _progress.value = 0;
    if (!wasCompleted) {
      widget.onHoldCancelled();
    }
  }

  /// The accessible activation path (see class dartdoc): the same started ->
  /// completed pair a full hold would dispatch, without requiring the dwell.
  void _activateInstantly() {
    if (!widget.enabled) return;
    widget.onHoldStarted();
    widget.onHoldCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return Semantics(
      key: const Key('hold_to_sign_button'),
      button: true,
      enabled: widget.enabled,
      label: widget.semanticLabel,
      onTap: widget.enabled ? _activateInstantly : null,
      child: ExcludeSemantics(
        child: GestureDetector(
          onTapDown: widget.enabled ? _handleTapDown : null,
          onTapUp: widget.enabled ? (_) => _handleRelease() : null,
          onTapCancel: widget.enabled ? _handleRelease : null,
          child: AnimatedBuilder(
            animation: _progress,
            builder: (context, _) {
              return Container(
                height: platformTokens.tapTarget + CupidSpacing.sm,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  gradient: widget.enabled ? colors.gradientHot : null,
                  color: widget.enabled
                      ? null
                      : colors.colorGhost.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(
                    platformTokens.radiusButton,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: _progress.value.clamp(0.0, 1.0),
                        child: Container(
                          color: Colors.white.withValues(alpha: 0.32),
                        ),
                      ),
                    ),
                    Text(
                      widget.label,
                      style: type.body.copyWith(
                        color: colors.colorText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Positioned(
                      right: CupidSpacing.md,
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          value: _progress.value,
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colors.colorText,
                          ),
                          backgroundColor: colors.colorText.withValues(
                            alpha: 0.24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
