import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/starter_selector.dart';

/// Screen (6)'s chrome wording.
///
/// Deliberately not an ARB key and deliberately not near the pack: every
/// *content* string on this screen — the starter lines and the event names —
/// comes off the shipped packs, and the gate test rejects any of it appearing
/// in Dart or l10n (`architecture/solution.md` §4, BR-15). These are the
/// screen's own labels, which the packs never supply. Same shape as the card
/// hub's `activityHubText`.
String starterText(BuildContext context, String vi, String en) =>
    Localizations.localeOf(context).languageCode == 'vi' ? vi : en;

/// Smallest comfortable touch target for the copy control
/// (`ux/uiux-spec.md` §2: ≥44pt / 48dp).
const double kStarterCopyTapTarget = 44;

/// One starter, read-and-copy.
///
/// Text on the left, one copy control on the right, and nothing else.
/// Deliberately absent, and asserted absent by this phase's screen test: a
/// checkbox, an "đã dùng" toggle, a like/dislike pair, a favourite star, and
/// any per-line counter. Each of those either scores the other person's
/// behaviour (R-1b) or opens a record outside the notebook (R-1f, AC-3/SC-1').
class StarterLine extends StatelessWidget {
  const StarterLine({
    super.key,
    required this.starter,
    required this.onCopied,
  });

  final RenderedStarter starter;

  /// Fired after the line reaches the clipboard, so the screen can raise its
  /// transient confirmation. Copying creates no card and stores no list.
  final VoidCallback onCopied;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Padding(
      key: Key('starter_line_${starter.id}'),
      padding: const EdgeInsets.symmetric(vertical: CupidSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Text(
              starter.text,
              key: Key('starter_line_text_${starter.id}'),
              style: type.body.copyWith(color: colors.colorText),
            ),
          ),
          const SizedBox(width: CupidSpacing.sm),
          StarterCopyButton(starter: starter, onCopied: onCopied),
        ],
      ),
    );
  }
}

/// The one copy control a starter gets, wherever it is drawn.
///
/// Shared by [StarterLine] and the hero card so both write the same clipboard
/// payload and keep the same `starter_line_copy_<id>` key — the hero's raised
/// card changes the starter's visual rank, not what copying it does (AC-2).
class StarterCopyButton extends StatelessWidget {
  const StarterCopyButton({
    super.key,
    required this.starter,
    required this.onCopied,
  });

  final RenderedStarter starter;

  final VoidCallback onCopied;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: starterText(context, 'Sao chép', 'Copy'),
      child: InkWell(
        key: Key('starter_line_copy_${starter.id}'),
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: starter.text));
          onCopied();
        },
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: kStarterCopyTapTarget,
          height: kStarterCopyTapTarget,
          child: Center(
            child: CupidIcon(
              CupidIcons.contentCopy,
              variant: CupidIconVariant.line,
              size: CupidSpacing.lg,
            ),
          ),
        ),
      ),
    );
  }
}
