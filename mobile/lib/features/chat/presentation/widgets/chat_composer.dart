import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../auth/presentation/auth_failure_text.dart';
import '../chat_strings.dart';

/// Message composer (`ux/uiux-spec.md` §3e). Deliberately has no
/// attachment/image affordance anywhere in this widget — the icon is
/// removed, not shipped disabled (ADR-013a).
class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.onSend,
    required this.showNetworkUnavailableError,
  });

  /// Returns `true` on a successful send. The composer only clears the
  /// draft on success — on failure the draft stays exactly as typed
  /// (`ux/uiux-spec.md` §5, AC4).
  final Future<bool> Function(String draft) onSend;

  /// Surfaces the reused `NetworkUnavailableFailure` copy after a send
  /// failed with `RealtimeNotLiveFailure` (AC4) — never new offline copy.
  final bool showNetworkUnavailableError;

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
    final bool hasDraft = _controller.text.trim().isNotEmpty;
    if (hasDraft != _hasDraft) setState(() => _hasDraft = hasDraft);
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // P3 inserts the Typing Ghost toggle button here, to the
                // left of the text field (`ux/uiux-spec.md` §3d). Not added
                // in this phase.
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
                          hintText: ChatStrings.composerHint(context),
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
                        color: _hasDraft ? Colors.white : colors.colorTextMuted,
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
