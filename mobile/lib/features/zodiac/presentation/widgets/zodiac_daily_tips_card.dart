import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/zodiac_red_flag.dart';

/// Card 3 of the `zodiac` screen (`Cupid Screens.dc.html` L626-632,
/// `ux/ux-spec.md` §2a "Card 3"): one row per entry of [tips], in wire order,
/// with a `1px` `colorLine` divider between neighbours and none after the last.
///
/// Renders exactly the rows it is given. A short list is rendered short rather
/// than padded with fabricated rows (`ux/ux-spec.md` §2a).
class ZodiacDailyTipsCard extends StatelessWidget {
  const ZodiacDailyTipsCard({super.key, required this.tips});

  final List<ZodiacDailyTip> tips;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    final List<Widget> rows = <Widget>[];
    for (final ZodiacDailyTip tip in tips) {
      if (rows.isNotEmpty) {
        rows.add(
          ExcludeSemantics(
            child: Container(height: _dividerHeight, color: colors.colorLine),
          ),
        );
      }
      rows.add(_TipRow(tip: tip));
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _cardHorizontalPadding,
        vertical: _cardVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        boxShadow: platformTokens.elevationShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: rows,
      ),
    );
  }
}

/// Design-source geometry with no token equivalent (`Cupid Screens.dc.html`
/// L626-631): card padding `6px 17px`, rows `14px 0` with a `13px` gap, a
/// `36x36` `12px`-radius tile at `.18` tint opacity holding a `19px` glyph, and
/// `13.5px`/`1.45` row text.
const double _cardHorizontalPadding = 17;
const double _cardVerticalPadding = 6;
const double _rowVerticalPadding = 14;
const double _rowGap = 13;
const double _tileSize = 36;
const double _tileRadius = 12;
const double _tileTintOpacity = 0.18;
const double _tileIconSize = 19;
const double _tipTextSize = 13.5;
const double _tipTextHeight = 1.45;
const double _dividerHeight = 1;

/// Tip glyphs, confirmed in the bundled `MaterialSymbolsRounded-Variable.ttf`
/// cmap. Declared here rather than in [CupidIcons] because
/// `design_system/icons/cupid_icons.dart` is outside this phase's write scope;
/// `favorite` and `savings` are already there and are reused from it.
const IconData _videocamIcon = IconData(
  0xe04b,
  fontFamily: CupidIcons.fontFamily,
);
const IconData _blockIcon = IconData(0xe033, fontFamily: CupidIcons.fontFamily);
const IconData _localCafeIcon = IconData(
  0xe541,
  fontFamily: CupidIcons.fontFamily,
);
const IconData _nightlightIcon = IconData(
  0xef5e,
  fontFamily: CupidIcons.fontFamily,
);
const IconData _chatBubbleIcon = IconData(
  0xe0ca,
  fontFamily: CupidIcons.fontFamily,
);
const IconData _selfImprovementIcon = IconData(
  0xea78,
  fontFamily: CupidIcons.fontFamily,
);

class _TipRow extends StatelessWidget {
  const _TipRow({required this.tip});

  final ZodiacDailyTip tip;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final Color ink = _tintInk(tip.tint, colors);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _rowVerticalPadding),
      child: Row(
        children: <Widget>[
          // `ux/ux-spec.md` §4: the tile is decorative; the tip text is the
          // row's whole accessible content.
          ExcludeSemantics(
            child: Container(
              width: _tileSize,
              height: _tileSize,
              decoration: BoxDecoration(
                color: ink.withValues(alpha: _tileTintOpacity),
                borderRadius: BorderRadius.circular(_tileRadius),
              ),
              child: Center(
                child: CupidIcon(
                  _tipGlyph(tip.icon),
                  size: _tileIconSize,
                  color: ink,
                ),
              ),
            ),
          ),
          const SizedBox(width: _rowGap),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  // The design draws the row's lead phrase inside a `<strong>`
                  // span; `title` is that phrase and `body` its continuation.
                  TextSpan(
                    text: tip.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: ' — ${tip.body}'),
                ],
              ),
              style: type.body.copyWith(
                fontSize: _tipTextSize,
                height: _tipTextHeight,
                color: colors.colorText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `architecture/contract-summary.md` §2: the tint vocabulary is append-only,
/// so [ZodiacTipTint.neutral] — which the parser already resolves any unknown
/// wire value to — renders as a muted tile instead of throwing.
Color _tintInk(ZodiacTipTint tint, CupidColorTokens colors) => switch (tint) {
  ZodiacTipTint.mint => colors.colorMint,
  ZodiacTipTint.pink => colors.colorAccentPink,
  ZodiacTipTint.amber => colors.colorAmber,
  ZodiacTipTint.lilac => colors.colorAccentLilac,
  ZodiacTipTint.peach => colors.colorPeach,
  ZodiacTipTint.neutral => colors.colorTextMuted,
};

IconData _tipGlyph(ZodiacTipIcon icon) => switch (icon) {
  ZodiacTipIcon.videocam => _videocamIcon,
  ZodiacTipIcon.block => _blockIcon,
  ZodiacTipIcon.localCafe => _localCafeIcon,
  ZodiacTipIcon.nightlight => _nightlightIcon,
  ZodiacTipIcon.favorite => CupidIcons.favorite,
  ZodiacTipIcon.chatBubble => _chatBubbleIcon,
  ZodiacTipIcon.savings => CupidIcons.savings,
  ZodiacTipIcon.selfImprovement => _selfImprovementIcon,
};
