import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../../../l10n/generated/app_l10n.dart';

/// Which of the two facets of a cell a [CompatFacetBlock] is drawing.
///
/// `fit` and `friction` are peers, not a good half and a bad half.
enum CompatFacetKind { fit, friction }

/// One facet of a compatibility cell — "Chỗ dễ hợp" or "Chỗ dễ va".
///
/// There is exactly one widget for both facets, and there must never be a
/// `CompatFitBlock` / `CompatFrictionBlock` pair: the acceptance rule in
/// `ux/uiux-spec.md` section 3.3 is that covering the two titles must leave the
/// blocks indistinguishable, and twins drift apart by the third edit without
/// anyone noticing. Only [kind] chooses the title and the leading icon;
/// padding, radius, border, gap, font size and font weight are read once below
/// and shared by both builds.
///
/// The friction block is therefore forbidden to move to the bottom of the
/// screen, collapse into an accordion, tint lighter, or take a smaller/lighter
/// heading than the fit block (AC-33). Both headings share the uppercase
/// `caption` style below; the symmetry rule is what matters, not the absolute
/// size.
class CompatFacetBlock extends StatelessWidget {
  const CompatFacetBlock({super.key, required this.kind, required this.text});

  final CompatFacetKind kind;

  /// `cell.fit` or `cell.friction`, already chosen by the caller.
  final String text;

  static const EdgeInsets _blockPadding = EdgeInsets.all(CupidSpacing.md);
  static const double _iconSize = 20;
  static const double _titleGap = CupidSpacing.sm;
  static const double _bodyGap = CupidSpacing.sm;

  IconData get _icon => switch (kind) {
    // `ux/uiux-spec.md` names `favorite`/`bolt` as an example pair. `bolt` has
    // no entry in CupidIcons and its codepoint may not be invented from
    // memory, so `cyclone` — the closest "turbulence" glyph already confirmed
    // against the bundled cmap — stands in for the friction side.
    CompatFacetKind.fit => CupidIcons.favorite,
    CompatFacetKind.friction => CupidIcons.cyclone,
  };

  String _title(AppL10n l10n) => switch (kind) {
    CompatFacetKind.fit => l10n.compat_block_fit_title,
    CompatFacetKind.friction => l10n.compat_block_friction_title,
  };

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final AppL10n l10n = AppL10n.of(context);

    final TextStyle titleStyle = type.caption.copyWith(
      color: colors.colorText,
    );
    final TextStyle bodyStyle = type.body.copyWith(color: colors.colorText);

    return DecoratedBox(
      key: Key('compat_facet_block_${kind.name}'),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platform.radiusSmall),
        border: Border.all(color: colors.colorLine),
      ),
      child: Padding(
        padding: _blockPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CupidIcon(
                  _icon,
                  variant: CupidIconVariant.line,
                  size: _iconSize,
                  color: colors.colorText,
                ),
                const SizedBox(width: _titleGap),
                // Upper case is a display treatment, not content: the l10n
                // string stays sentence-case and is what a screen reader
                // announces, so "CHỖ DỄ VA" is not spelled out letter by
                // letter or read as shouting.
                Expanded(
                  child: Semantics(
                    label: _title(l10n),
                    excludeSemantics: true,
                    child: Text(_title(l10n).toUpperCase(), style: titleStyle),
                  ),
                ),
              ],
            ),
            const SizedBox(height: _bodyGap),
            Text(text, style: bodyStyle),
          ],
        ),
      ),
    );
  }
}
