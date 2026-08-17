import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Design source `Cupid Screens.dc.html` line 139: `gap:12px` between the
/// checkbox, the clause text and the `§N` id, and `padding:12px` around the
/// row. Neither value lands on a `CupidSpacing` step, and both are structural
/// row geometry rather than the card-section padding tracked separately as a
/// token-vs-source policy question.
const double _rowPadding = 12;
const double _rowGap = 12;

/// One preset-or-custom clause row (`ux/uiux-spec.md` §4, "checkbox-style,
/// c.on/c.off states"). The on/off state is exposed two ways so it is never
/// colour-only (§8): a semantic [Semantics.toggled] flag, and a filled
/// check-marked box vs. an empty outlined box.
class ClauseToggleRow extends StatelessWidget {
  const ClauseToggleRow({
    super.key,
    required this.clauseNumber,
    required this.text,
    required this.selected,
    required this.onToggle,
  });

  /// 1-based display index (`§{{ c.no }}`, ux/uiux-spec.md §4).
  final int clauseNumber;
  final String text;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return Semantics(
      toggled: selected,
      button: true,
      label: text,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: platformTokens.tapTarget),
          child: Padding(
            padding: const EdgeInsets.all(_rowPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ExcludeSemantics(
                  child: _ClauseCheckbox(selected: selected),
                ),
                const SizedBox(width: _rowGap),
                Expanded(
                  child: ExcludeSemantics(
                    child: Text(
                      text,
                      style: type.body.copyWith(
                        color: colors.colorText,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: _rowGap),
                ExcludeSemantics(
                  child: Padding(
                    padding: const EdgeInsets.only(top: CupidSpacing.xs),
                    child: Text(
                      '§$clauseNumber',
                      style: type.labelMono.copyWith(
                        color: colors.colorTextMuted,
                        fontSize: 9.5,
                      ),
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

/// Design source `Cupid Screens.dc.html` lines 141/144: a 24x24 box at radius
/// 9, filled with `--grad-hot` behind a 16px `check` when on, and a bare
/// `1.5px solid var(--line)` outline when off.
class _ClauseCheckbox extends StatelessWidget {
  const _ClauseCheckbox({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        gradient: selected ? colors.gradientHot : null,
        border: selected
            ? null
            : Border.all(color: colors.colorLine, width: 1.5),
      ),
      child: selected
          ? const Icon(
              CupidIcons.check,
              size: 16,
              color: OnAccentPalette.foreground,
            )
          : null,
    );
  }
}
