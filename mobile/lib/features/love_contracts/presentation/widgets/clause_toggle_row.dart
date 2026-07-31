import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

/// `check_circle`/`radio_button_unchecked` glyphs from the bundled Material
/// Symbols Rounded font, confirmed via the font's `cmap` (same
/// codepoint-sourcing rule as `design_system/icons/cupid_icons.dart`).
/// Defined locally instead of added to `CupidIcons` because this phase's
/// write scope does not include that shared file.
const IconData _iconCheckCircle = IconData(
  0xe86c,
  fontFamily: CupidIcons.fontFamily,
);
const IconData _iconRadioButtonUnchecked = IconData(
  0xe836,
  fontFamily: CupidIcons.fontFamily,
);

/// One preset-or-custom clause row (`ux/uiux-spec.md` §4, "checkbox-style,
/// c.on/c.off states"). The on/off state is exposed two ways so it is never
/// colour-only (§8): a semantic [Semantics.toggled] flag, and a filled-check
/// vs. outlined-circle icon shape.
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
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: platformTokens.tapTarget),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: CupidSpacing.xs),
            child: Row(
              children: <Widget>[
                ExcludeSemantics(
                  child: SizedBox(
                    width: 32,
                    child: Text(
                      '§$clauseNumber',
                      style: type.labelMono.copyWith(
                        color: colors.colorTextMuted,
                      ),
                    ),
                  ),
                ),
                ExcludeSemantics(
                  child: Icon(
                    selected ? _iconCheckCircle : _iconRadioButtonUnchecked,
                    color: selected ? colors.colorAccentPink : colors.colorGhost,
                  ),
                ),
                SizedBox(width: CupidSpacing.sm),
                Expanded(
                  child: ExcludeSemantics(
                    child: Text(
                      text,
                      style: type.body.copyWith(color: colors.colorText),
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
