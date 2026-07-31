import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../auth/presentation/auth_failure_text.dart';
import '../chat_strings.dart';
import '../ghost_cubit.dart' show GhostConsentLevel;

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

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(CupidSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showNetworkUnavailableError)
              Padding(
                padding: const EdgeInsets.only(bottom: CupidSpacing.xs),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    authFailureMessage(
                      context,
                      const NetworkUnavailableFailure(),
                    ),
                    style: context.cupidType.caption.copyWith(
                      color: colors.colorRed,
                    ),
                  ),
                ),
              ),
            // "You are being watched" warning row (`ux/uiux-spec.md` §3d) —
            // only while ghost is on and the draft is non-empty.
            if (ghostIsOn && _hasDraft && widget.partnerDisplayName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: CupidSpacing.xs),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    ChatStrings.ghostWatchingWarning(
                      context,
                      widget.partnerDisplayName!,
                    ),
                    style: context.cupidType.caption.copyWith(
                      color: colors.colorAccentPurple,
                    ),
                  ),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _GhostToggleButton(
                  colors: colors,
                  platformTokens: platformTokens,
                  consentLevel: widget.ghostConsentLevel,
                  onPressed: widget.onGhostTogglePressed,
                ),
                const SizedBox(width: CupidSpacing.sm),
                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: platformTokens.tapTarget,
                    ),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 46),
                      padding: const EdgeInsets.symmetric(
                        horizontal: CupidSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: colors.colorSurface,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        style: TextStyle(color: colors.colorText),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: ghostIsOn
                              ? ChatStrings.composerHintGhostOn(context)
                              : ChatStrings.composerHint(context),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: CupidSpacing.sm),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: platformTokens.tapTarget,
                    minHeight: platformTokens.tapTarget,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: _hasDraft ? colors.gradientHot : null,
                      color: _hasDraft ? null : colors.colorSurfaceAlt,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _hasDraft ? _handleSendPressed : null,
                      // `CupidIcons` (design_system/icons/) does not yet
                      // carry a verified cmap codepoint for a send glyph —
                      // adding one is out of this phase's write scope. Uses
                      // Flutter's bundled Material Icons font directly
                      // rather than guessing an unverified codepoint on the
                      // app's custom icon font.
                      icon: Icon(
                        Icons.send,
                        color: _hasDraft
                            ? colors.colorText
                            : colors.colorTextMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
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

    return Semantics(
      button: true,
      label: ChatStrings.ghostToggleSemanticLabel(context, consentLevel),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: platformTokens.tapTarget,
          minHeight: platformTokens.tapTarget,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isOn
                ? colors.colorAccentPurple.withValues(alpha: 0.24)
                : colors.colorSurfaceAlt,
            shape: BoxShape.circle,
          ),
          child: ExcludeSemantics(
            child: TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(shape: const CircleBorder()),
              child: Text(
                ChatStrings.ghostToggleGlyph(consentLevel),
                style: context.cupidType.caption.copyWith(
                  color: isOn ? colors.colorAccentPurple : colors.colorTextMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
