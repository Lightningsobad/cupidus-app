import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/zodiac_red_flag.dart';

/// Card 2 of the `zodiac` screen (`Cupid Screens.dc.html` L613-624,
/// `ux/ux-spec.md` §2a "Card 2"): score, `/scoreMax` suffix, both partners'
/// element-coloured [CupidZodiacIcon] discs, and the conflict bar.
///
/// The bar width is [ZodiacConflictIndex.fillFraction] — the one value mobile
/// derives (`architecture/contract-summary.md` §3 row 3). Neither the design's
/// `10` denominator nor its `70%` fill is reproduced as a literal here.
class ZodiacConflictIndexCard extends StatelessWidget {
  const ZodiacConflictIndexCard({
    super.key,
    required this.conflictIndex,
    required this.partners,
  });

  final ZodiacConflictIndex conflictIndex;

  /// Contractually 2 entries, `partners[0].role == self` (§3 row 5). Rendered
  /// in wire order with a `bolt` glyph between neighbours.
  final List<ZodiacPartner> partners;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return Container(
      padding: const EdgeInsets.all(_cardPadding),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        boxShadow: platformTokens.elevationShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(child: _ScoreBlock(conflictIndex: conflictIndex)),
              _PartnerPair(partners: partners),
            ],
          ),
          const SizedBox(height: _headerRowBottomGap),
          _ConflictBar(fillFraction: conflictIndex.fillFraction),
          const SizedBox(height: _barCaptionTopGap),
          const _BarCaption(),
        ],
      ),
    );
  }
}

/// Design-source geometry with no token equivalent (`Cupid Screens.dc.html`
/// L613-623): card padding `18px`, `14px` gap under the top row, `4px` between
/// label and score, a `17px` score suffix, `11px` between the two discs and the
/// `bolt` glyph, `46px` discs with a `10px` name `5px` below, a `10px`-tall
/// `6px`-radius bar, and a `7px` gap to its caption row.
const double _cardPadding = 18;
const double _headerRowBottomGap = 14;
const double _indexLabelSize = 12;
const double _scoreTopGap = 4;
const double _scoreHeight = 1.1;
const double _scoreSuffixSize = 17;
const double _partnerGap = 11;
const double _partnerDiscSize = 46;
const double _partnerNameSize = 10;
const double _partnerNameTopGap = 5;
const double _boltSize = 17;
const double _barHeight = 10;
const double _barRadius = 6;
const double _barCaptionTopGap = 7;
const double _barCaptionSize = 10;

/// The design's `linear-gradient(90deg, var(--mint), var(--butter) 55%,
/// var(--peach))` mid stop.
const double _barButterStop = 0.55;

/// `bolt`, confirmed in the bundled `MaterialSymbolsRounded-Variable.ttf` cmap
/// at 0xea0b. Declared here rather than in [CupidIcons] because
/// `design_system/icons/cupid_icons.dart` is outside this phase's write scope;
/// promoting it is a follow-up, not a behaviour change.
const IconData _boltIcon = IconData(0xea0b, fontFamily: CupidIcons.fontFamily);

class _ScoreBlock extends StatelessWidget {
  const _ScoreBlock({required this.conflictIndex});

  final ZodiacConflictIndex conflictIndex;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    // `ux/ux-spec.md` §4: the score is one semantic label, not two disjoint
    // text nodes, and it is what carries the bar's meaning to a screen reader.
    return Semantics(
      label: _viEn(
        context,
        'Chỉ số xung đột hôm nay: ${conflictIndex.score} trên '
            '${conflictIndex.scoreMax}',
        'Conflict index today: ${conflictIndex.score} out of '
            '${conflictIndex.scoreMax}',
      ),
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            _viEn(context, 'Chỉ số xung đột hôm nay', 'Conflict index today'),
            style: type.caption.copyWith(
              fontSize: _indexLabelSize,
              color: colors.colorTextMuted,
            ),
          ),
          const SizedBox(height: _scoreTopGap),
          Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(text: '${conflictIndex.score}'),
                TextSpan(
                  text: '/${conflictIndex.scoreMax}',
                  style: TextStyle(
                    fontSize: _scoreSuffixSize,
                    color: colors.colorTextMuted,
                  ),
                ),
              ],
            ),
            style: type.display.copyWith(
              height: _scoreHeight,
              color: colors.colorPeach,
            ),
          ),
        ],
      ),
    );
  }
}

class _PartnerPair extends StatelessWidget {
  const _PartnerPair({required this.partners});

  final List<ZodiacPartner> partners;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    final List<Widget> children = <Widget>[];
    for (final ZodiacPartner partner in partners) {
      if (children.isNotEmpty) {
        children.addAll(<Widget>[
          const SizedBox(width: _partnerGap),
          ExcludeSemantics(
            child: CupidIcon(
              _boltIcon,
              size: _boltSize,
              color: colors.colorTextMuted,
            ),
          ),
          const SizedBox(width: _partnerGap),
        ]);
      }
      children.add(_PartnerDisc(partner: partner));
    }

    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}

class _PartnerDisc extends StatelessWidget {
  const _PartnerDisc({required this.partner});

  final ZodiacPartner partner;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Semantics(
      // `ux/ux-spec.md` §4: the disc carries no text, so its label combines the
      // partner label with the sign name.
      label: _viEn(
        context,
        'Cung của ${partner.label}: ${partner.sign.viLabel}',
        '${partner.label}: ${partner.sign.enLabel}',
      ),
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // No `color` override: [CupidZodiacIcon] already inks each sign by
          // element (fire peach/orange, earth mint, air lilac, water pink).
          CupidZodiacIcon(partner.sign, size: _partnerDiscSize),
          const SizedBox(height: _partnerNameTopGap),
          Text(
            partner.label,
            style: type.caption.copyWith(
              fontSize: _partnerNameSize,
              color: colors.colorTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConflictBar extends StatelessWidget {
  const _ConflictBar({required this.fillFraction});

  final double fillFraction;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_barRadius),
        child: Container(
          height: _barHeight,
          color: colors.colorSurfaceAlt,
          alignment: AlignmentDirectional.centerStart,
          child: FractionallySizedBox(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: fillFraction,
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_barRadius),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[
                    colors.colorMint,
                    colors.colorButter,
                    colors.colorPeach,
                  ],
                  stops: const <double>[0, _barButterStop, 1],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BarCaption extends StatelessWidget {
  const _BarCaption();

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final TextStyle style = context.cupidType.labelMono.copyWith(
      fontSize: _barCaptionSize,
      color: colors.colorTextMuted,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(_viEn(context, 'êm', 'calm'), style: style),
        Text(_viEn(context, 'drama', 'drama'), style: style),
      ],
    );
  }
}

/// Locale pick for this file's static labels. `zodiac_strings.dart` does not
/// exist and is outside this phase's write scope, so the mapping stays local —
/// the same precedent as `pet_screen.dart`'s `_petFailureMessage`.
String _viEn(BuildContext context, String vi, String en) =>
    Localizations.localeOf(context).languageCode == 'vi' ? vi : en;
