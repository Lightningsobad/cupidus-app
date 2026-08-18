import 'dart:math' as math;

import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../auth/presentation/auth_failure_text.dart';
import '../chat_strings.dart';
import '../ghost_cubit.dart' show GhostConsentLevel;

// Off-scale metrics transcribed verbatim from the locked design source
// (`cupid-app-design-system/project/Cupid Screens.dc.html`, `isChat` block,
// composer bar). They do not map onto the 8pt `CupidSpacing` scale.
const double _barPaddingX = 12;
const double _barPaddingY = 10;
const double _barBottomGap = 8;
const double _barGap = 9;
const double _warnRowPaddingX = 18;
const double _warnRowPaddingTop = 8;
const double _warnRowGap = 6;
const double _warnFontSize = 11;
const double _warnIconSize = 13;
const double _ghostButtonSize = 46;
const double _ghostButtonIconSize = 21;
const double _ghostButtonLabelSize = 7;
const double _inputMinHeight = 46;
const double _inputRadius = 23;
const double _inputPaddingLeft = 15;
const double _inputPaddingRight = 6;
const double _inputFontSize = 15.5;
const double _sendButtonSize = 36;
const double _sendIconSize = 19;

/// `border:1px solid rgba(183,140,245,.75)` on the ghost toggle while on —
/// the dark-theme `colorAccentPurple` value at 75% alpha, so it is derived
/// from the token rather than pinned.
const double _ghostButtonOnBorderAlpha = 0.75;

/// Message composer (`ux/uiux-spec.md` §3e, §3d). Deliberately has no
/// attachment/image affordance anywhere in this widget — the icon is
/// removed, not shipped disabled (ADR-013a).
class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.onSend,
    required this.showNetworkUnavailableError,
    required this.ghostConsentLevel,
    required this.onGhostTogglePressed,
    required this.partnerDisplayName,
    this.onDraftChanged,
  });

  /// Returns `true` on a successful send. The composer only clears the
  /// draft on success — on failure the draft stays exactly as typed
  /// (`ux/uiux-spec.md` §5, AC4).
  final Future<bool> Function(String draft) onSend;

  /// Surfaces the reused `NetworkUnavailableFailure` copy after a send
  /// failed with `RealtimeNotLiveFailure` (AC4) — never new offline copy.
  final bool showNetworkUnavailableError;

  /// Drives the 3-state ghost toggle's visual and the placeholder/warning
  /// row swap (`ux/uiux-spec.md` §3d).
  final GhostConsentLevel ghostConsentLevel;

  /// Tapping the toggle while `off`/`pending` opts in; while `on` it is a
  /// no-op (`GhostCubit.toggleTapped` owns that rule — this widget only
  /// forwards the tap).
  final VoidCallback onGhostTogglePressed;

  final String? partnerDisplayName;

  /// Forwards every draft change to `GhostCubit.draftChanged` (ADR-013b
  /// sender path). `null` is accepted so this widget stays usable without a
  /// ghost cubit wired up.
  final ValueChanged<String>? onDraftChanged;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final TextEditingController _controller = TextEditingController();
  bool _hasDraft = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleDraftChanged);
  }

  void _handleDraftChanged() {
    final String draft = _controller.text;
    final bool hasDraft = draft.trim().isNotEmpty;
    if (hasDraft != _hasDraft) {
      setState(() => _hasDraft = hasDraft);
    }
    // Ghost needs every keystroke, not just the trimmed-non-empty flag
    // flipping (ADR-013b sender path).
    widget.onDraftChanged?.call(draft);
  }

  Future<void> _handleSendPressed() async {
    final String draft = _controller.text.trim();
    if (draft.isEmpty) return;
    final bool sent = await widget.onSend(draft);
    if (sent && mounted) _controller.clear();
  }

  @override
  void dispose() {
    _controller.removeListener(_handleDraftChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final bool ghostIsOn = widget.ghostConsentLevel == GhostConsentLevel.on;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.colorLine)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showNetworkUnavailableError)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  _warnRowPaddingX,
                  _warnRowPaddingTop,
                  _warnRowPaddingX,
                  0,
                ),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    authFailureMessage(
                      context,
                      const NetworkUnavailableFailure(),
                    ),
                    style: context.cupidType.caption.copyWith(
                      fontSize: _warnFontSize,
                      fontWeight: FontWeight.w700,
                      color: colors.colorRed,
                    ),
                  ),
                ),
              ),
            // "You are being watched" warning row (`ux/uiux-spec.md` §3d) —
            // only while ghost is on and the draft is non-empty.
            if (ghostIsOn && _hasDraft && widget.partnerDisplayName != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  _warnRowPaddingX,
                  _warnRowPaddingTop,
                  _warnRowPaddingX,
                  0,
                ),
                child: Semantics(
                  liveRegion: true,
                  child: Row(
                    children: [
                      Icon(
                        Icons.visibility,
                        size: _warnIconSize,
                        color: colors.colorAccentPurple,
                      ),
                      const SizedBox(width: _warnRowGap),
                      Flexible(
                        child: Text(
                          ChatStrings.ghostWatchingWarning(
                            context,
                            widget.partnerDisplayName!,
                          ),
                          style: context.cupidType.caption.copyWith(
                            fontSize: _warnFontSize,
                            fontWeight: FontWeight.w700,
                            color: colors.colorAccentPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                _barPaddingX,
                _barPaddingY,
                _barPaddingX,
                _barBottomGap,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _GhostToggleButton(
                    colors: colors,
                    platformTokens: platformTokens,
                    consentLevel: widget.ghostConsentLevel,
                    onPressed: widget.onGhostTogglePressed,
                  ),
                  const SizedBox(width: _barGap),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: platformTokens.tapTarget,
                      ),
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: _inputMinHeight,
                        ),
                        padding: const EdgeInsets.only(
                          left: _inputPaddingLeft,
                          right: _inputPaddingRight,
                        ),
                        decoration: BoxDecoration(
                          color: colors.colorSurface,
                          borderRadius: BorderRadius.circular(_inputRadius),
                          boxShadow: platformTokens.elevationShadow,
                        ),
                        alignment: Alignment.centerLeft,
                        child: TextField(
                          controller: _controller,
                          minLines: 1,
                          maxLines: 4,
                          style: context.cupidType.body.copyWith(
                            fontSize: _inputFontSize,
                            color: colors.colorText,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            hintStyle: context.cupidType.body.copyWith(
                              fontSize: _inputFontSize,
                              color: colors.colorTextMuted,
                            ),
                            hintText: ghostIsOn
                                ? ChatStrings.composerHintGhostOn(context)
                                : ChatStrings.composerHint(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: _barGap),
                  _SendButton(
                    colors: colors,
                    platformTokens: platformTokens,
                    enabled: _hasDraft,
                    onPressed: _handleSendPressed,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular gradient send affordance. The design source draws it at 36pt; the
/// hit target is expanded to [CupidPlatformTokens.tapTarget] around that
/// visual so the smaller glyph does not shrink the touch area below the
/// platform minimum (`ux/uiux-spec.md` §5).
class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.colors,
    required this.platformTokens,
    required this.enabled,
    required this.onPressed,
  });

  final CupidColorTokens colors;
  final CupidPlatformTokens platformTokens;
  final bool enabled;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: platformTokens.tapTarget,
      height: platformTokens.tapTarget,
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: enabled ? colors.gradientHot : null,
            color: enabled ? null : colors.colorSurfaceAlt,
            shape: BoxShape.circle,
            boxShadow: enabled ? colors.glowShadow : null,
          ),
          child: SizedBox(
            width: _sendButtonSize,
            height: _sendButtonSize,
            child: IconButton(
              onPressed: enabled ? onPressed : null,
              padding: EdgeInsets.zero,
              // `CupidIcons` (design_system/icons/) does not yet carry a
              // verified cmap codepoint for an arrow glyph — adding one is
              // out of this phase's write scope. Uses Flutter's bundled
              // Material Icons font directly rather than guessing an
              // unverified codepoint on the app's custom icon font.
              icon: Icon(
                Icons.arrow_upward,
                size: _sendIconSize,
                color: enabled ? colors.colorOnAccent : colors.colorTextMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The 3-state ghost toggle to the left of the text field (`ux/uiux-spec.md`
/// §3d). Tapping while `pending` calls the accept/opt-in action rather than
/// re-toggling — that rule lives in `GhostCubit.toggleTapped`, which
/// `widget.onGhostTogglePressed` is wired to; this widget only renders the
/// three visual states and forwards the tap.
class _GhostToggleButton extends StatelessWidget {
  const _GhostToggleButton({
    required this.colors,
    required this.platformTokens,
    required this.consentLevel,
    required this.onPressed,
  });

  final CupidColorTokens colors;
  final CupidPlatformTokens platformTokens;
  final GhostConsentLevel consentLevel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bool isOn = consentLevel == GhostConsentLevel.on;
    final Color foreground = isOn
        ? colors.colorAccentPurple
        : colors.colorTextMuted;
    // A bare `platformTokens.tapTarget` slot silently clamped the design
    // source's `width:46px;height:46px` toggle to 44x44 on
    // `CupidPlatformTokens.ios()`, with no overflow error to surface it.
    final double slot = math.max(platformTokens.tapTarget, _ghostButtonSize);

    return Semantics(
      button: true,
      label: ChatStrings.ghostToggleSemanticLabel(context, consentLevel),
      child: ExcludeSemantics(
        child: SizedBox(
          width: slot,
          height: slot,
          child: Center(
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(
                platformTokens.radiusSmall,
              ),
              child: Container(
                width: _ghostButtonSize,
                height: _ghostButtonSize,
                decoration: BoxDecoration(
                  color: isOn
                      ? colors.colorAccentPurple.withValues(alpha: 0.24)
                      : colors.colorSurface,
                  borderRadius: BorderRadius.circular(
                    platformTokens.radiusSmall,
                  ),
                  border: Border.all(
                    color: isOn
                        ? colors.colorAccentPurple.withValues(
                            alpha: _ghostButtonOnBorderAlpha,
                          )
                        : colors.colorLine,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // `CupidIcons` (design_system/icons/) does not yet carry
                    // a verified cmap codepoint for a blur glyph — adding one
                    // is out of this phase's write scope. Uses Flutter's
                    // bundled Material Icons font directly rather than
                    // guessing an unverified codepoint on the app's custom
                    // icon font.
                    Icon(
                      Icons.blur_on,
                      size: _ghostButtonIconSize,
                      color: foreground,
                    ),
                    Text(
                      ChatStrings.ghostToggleGlyph(consentLevel),
                      style: context.cupidType.labelMono.copyWith(
                        fontSize: _ghostButtonLabelSize,
                        letterSpacing: _ghostButtonLabelSize * 0.06,
                        color: foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
