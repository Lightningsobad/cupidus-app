import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/widgets.dart';

import '../../domain/vibe_mood.dart';
import '../vibe_strings.dart';
import 'vibe_mood_face.dart';

/// Discoverable entry point mounted on `HomeScreen`
/// (`architecture/solution.md` §4 D-010-5,
/// `coding-plan/phase-P3-vibe-screen-entrypoint.md`): one tappable card that
/// pushes `VibeScreen`.
///
/// REQ-010 STORY-002 rebuilds it to the locked design source's two-tile shape
/// (`Cupid Screens.dc.html`, `isHome`, lines 274-289): a header row
/// (`mood` glyph + title, `Lịch sử` link) above the "you"/"partner" sub-tiles.
///
/// [today] and [partnerToday] optionally preview the mood glyphs for a future
/// home-dashboard data-bind; v1 mounts this with both omitted so no duplicate
/// fetch happens ahead of `VibeScreen`'s own load.
///
/// Design-source geometry with no `CupidSpacing` equivalent, transcribed
/// verbatim rather than rounded onto the 8pt scale (same sourcing rule as
/// `partner_vibe_card.dart`).
const double _cardPadding = 17;
const double _headerIconSize = 19;
const double _headerTitleSize = 12.5;
const double _headerTitleTracking = _headerTitleSize * 0.03;
const double _historyLabelSize = 11.5;
const double _headerBottomGap = 14;
const double _tileGap = 10;
const double _tilePadding = 12;
const double _tileFaceSize = 36;
const double _tileInnerGap = 11;
const double _tileLabelSize = 11;
const double _tileMoodSize = 13.5;

class VibeEntryCard extends StatelessWidget {
  const VibeEntryCard({
    super.key,
    this.today,
    this.partnerToday,
    required this.onTap,
  });

  final VibeMood? today;
  final VibeMood? partnerToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;
    final String title = context.viEn('Cảm xúc hằng ngày', 'Daily Vibe Check');
    final String historyLabel = context.viEn('Lịch sử', 'History');

    return Semantics(
      button: true,
      label: title,
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: platform.tapTarget),
            child: Container(
              padding: const EdgeInsets.all(_cardPadding),
              decoration: BoxDecoration(
                color: colors.colorSurface,
                borderRadius: BorderRadius.circular(platform.radiusCard),
                boxShadow: platform.elevationShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            CupidIcon(
                              CupidIcons.mood,
                              size: _headerIconSize,
                              color: colors.colorAccentPink,
                            ),
                            const SizedBox(width: CupidSpacing.sm),
                            Flexible(
                              child: Text(
                                title,
                                style: type.caption.copyWith(
                                  fontSize: _headerTitleSize,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: _headerTitleTracking,
                                  color: colors.colorText,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        historyLabel,
                        style: type.caption.copyWith(
                          fontSize: _historyLabelSize,
                          fontWeight: FontWeight.w700,
                          color: colors.colorAccentPink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: _headerBottomGap),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _VibeMiniTile(
                          mood: today,
                          label: context.viEn('Bạn', 'You'),
                        ),
                      ),
                      const SizedBox(width: _tileGap),
                      Expanded(
                        child: _VibeMiniTile(
                          mood: partnerToday,
                          // The design source binds the partner's name here.
                          // No partner-profile source reaches Home yet
                          // (STORY-006 owns that), and REQ-010 forbids a
                          // fabricated name, so this reuses the generic label
                          // `PartnerVibeCard` already established.
                          label: context.viEn('Đối tác', 'Partner'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VibeMiniTile extends StatelessWidget {
  const _VibeMiniTile({required this.mood, required this.label});

  final VibeMood? mood;
  final String label;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final VibeMood? mood = this.mood;
    final String moodLabel = mood == null
        ? context.waitingLabel
        : context.moodLabel(mood);

    return Container(
      padding: const EdgeInsets.all(_tilePadding),
      decoration: BoxDecoration(
        color: colors.colorSurfaceAlt,
        borderRadius: BorderRadius.circular(context.cupidPlatform.radiusSmall),
      ),
      child: Row(
        children: <Widget>[
          VibeMoodFace(mood: mood, size: _tileFaceSize),
          const SizedBox(width: _tileInnerGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  label,
                  style: type.caption.copyWith(
                    fontSize: _tileLabelSize,
                    color: colors.colorTextMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  moodLabel,
                  style: type.body.copyWith(
                    fontSize: _tileMoodSize,
                    fontWeight: FontWeight.w800,
                    color: colors.colorText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
