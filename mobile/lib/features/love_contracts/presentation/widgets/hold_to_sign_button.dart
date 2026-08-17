import 'dart:math' as math;

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

/// `touch_app` glyph from the bundled Material Symbols Rounded font, confirmed
/// via the font's `cmap` (single codepoint, no alias — same codepoint-sourcing
/// rule as `design_system/icons/cupid_icons.dart`). Defined locally instead of
/// added to `CupidIcons` because this story's write scope does not include that
/// shared file.
const IconData _iconTouchApp = IconData(
  0xe913,
  fontFamily: CupidIcons.fontFamily,
);

/// Design source `Cupid Screens.dc.html` line 161: the control is `height:64px`
/// with a `gap:12px` between the touch puck and the label. Neither lands on a
/// `CupidSpacing` step.
const double _buttonHeight = 64;
const double _puckGap = 12;

/// `rgba(0,0,0,.28)` dim overlay (design source line 162). It covers the whole
/// control at rest and recedes right-to-left as the dwell fills, so the button
/// brightens under the finger rather than being painted over.
const Color _dimOverlay = Color.fromRGBO(0, 0, 0, 0.28);

/// `rgba(255,255,255,.28)` unfilled half of the touch puck's conic ring
/// (design source line 163).
const Color _puckTrack = Color.fromRGBO(255, 255, 255, 0.28);

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

/// Design source `Cupid Screens.dc.html` line 163: a 32x32 dwell ring filled
/// `conic-gradient(#fff <progress>%, rgba(255,255,255,.28) 0)` around a 24x24
/// `--pink` disc carrying the 15px `touch_app` glyph.
///
/// CSS conic gradients start at 12 o'clock; [SweepGradient] starts at 3
/// o'clock, hence the quarter-turn on [SweepGradient.startAngle].
class _TouchPuck extends StatelessWidget {
  const _TouchPuck({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: math.pi * 1.5,
          colors: const <Color>[
            OnAccentPalette.foreground,
            OnAccentPalette.foreground,
            _puckTrack,
            _puckTrack,
          ],
          stops: <double>[0, progress, progress, 1],
        ),
      ),
      child: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.colorAccentPink,
        ),
        child: const Icon(
          _iconTouchApp,
          size: 15,
          color: OnAccentPalette.foreground,
        ),
      ),
    );
  }
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
              final double progress = _progress.value.clamp(0.0, 1.0);

              return Container(
                height: _buttonHeight,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  gradient: widget.enabled ? colors.gradientHot : null,
                  color: widget.enabled
                      ? null
                      : colors.colorGhost.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(
                    platformTokens.radiusCard,
                  ),
                  boxShadow: widget.enabled ? colors.glowShadow : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FractionallySizedBox(
                          // `inset:0` on the design source's dim layer: it
                          // spans the full height and only its width tracks
                          // the dwell.
                          heightFactor: 1,
                          widthFactor: 1 - progress,
                          child: const ColoredBox(color: _dimOverlay),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _TouchPuck(progress: progress),
                        const SizedBox(width: _puckGap),
                        Flexible(
                          child: Text(
                            widget.label,
                            style: type.body.copyWith(
                              color: OnAccentPalette.foreground,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
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
