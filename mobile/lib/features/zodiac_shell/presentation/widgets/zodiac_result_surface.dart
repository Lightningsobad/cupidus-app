import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../../../l10n/generated/app_l10n.dart';
import '../../domain/zodiac_shell_content.dart';
import '../../domain/zodiac_shell_resolver.dart';

/// The whole result of one round, on one scrollable.
///
/// The three suggestions are not a slot this widget may leave empty: it renders
/// [ZodiacShellResult.suggestions], which the resolver already fixed at exactly
/// three, and there is no branch here that draws the insight without them
/// (AC-4/AC-5/AC-6, BR-2). An `ExpansionTile`, a "xem gợi ý" button or a second
/// route would each reintroduce the standalone verdict SB-136 forbids, so the
/// blocks below sit in one `ListView` with nothing collapsible between them.
class ZodiacResultSurface extends StatelessWidget {
  const ZodiacResultSurface({
    super.key,
    required this.result,
    required this.onAddToCards,
  });

  final ZodiacShellResult result;

  /// Emitted once per tap. The card creation, the snackbar and the undo belong
  /// to the screen, which owns the cubit and the `ScaffoldMessenger`.
  final ValueChanged<ZodiacSuggestion> onAddToCards;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final AppL10n l10n = AppL10n.of(context);
    final ZodiacOutcome outcome = result.outcome;
    final String? askLine = outcome.askLine;

    return ListView(
      key: const Key('zodiac_result_surface'),
      padding: const EdgeInsets.all(CupidSpacing.md),
      children: <Widget>[
        _InsightCard(outcome: outcome, askLine: askLine),
        const SizedBox(height: CupidSpacing.lg),
        Text(
          key: const Key('zodiac_result_suggestions_subheading'),
          l10n.zodiac_shell_suggestions_subheading.toUpperCase(),
          style: type.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.colorTextMuted,
          ),
        ),
        const SizedBox(height: CupidSpacing.sm),
        for (final ZodiacSuggestion suggestion in result.suggestions)
          Padding(
            padding: const EdgeInsets.only(bottom: CupidSpacing.sm),
            child: _SuggestionCard(
              suggestion: suggestion,
              onAdd: () => onAddToCards(suggestion),
            ),
          ),
        const SizedBox(height: CupidSpacing.sm),
        const _PositioningNote(),
      ],
    );
  }
}

/// The verdict block: the insight, and — only when the outcome speaks about the
/// other person — the guess provenance above it and the question to ask below
/// it, so no paragraph about them ever ends on a conclusion (AC-12/AC-15).
class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.outcome, required this.askLine});

  final ZodiacOutcome outcome;
  final String? askLine;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final AppL10n l10n = AppL10n.of(context);

    return DecoratedBox(
      key: const Key('zodiac_result_insight_card'),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platform.radiusCard),
        border: Border.all(color: colors.colorLine),
      ),
      child: Padding(
        padding: const EdgeInsets.all(CupidSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (outcome.aboutOther) ...<Widget>[
              Text(
                key: const Key('zodiac_result_guess_basis'),
                l10n.zodiac_shell_result_guess_basis.toUpperCase(),
                style: type.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.colorTextMuted,
                ),
              ),
              const SizedBox(height: CupidSpacing.sm),
            ],
            Text(
              key: const Key('zodiac_result_insight'),
              outcome.insight,
              style: type.body.copyWith(color: colors.colorText),
            ),
            if (outcome.aboutOther && askLine != null) ...<Widget>[
              const SizedBox(height: CupidSpacing.md),
              _AskBlock(askLine: askLine!),
            ],
          ],
        ),
      ),
    );
  }
}

/// "Câu để hỏi", in STORY-009's treatment: a layered tone, the `help_outline`
/// glyph, and plain text rather than a field — this story never collects an
/// answer about the other person.
class _AskBlock extends StatelessWidget {
  const _AskBlock({required this.askLine});

  final String askLine;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final AppL10n l10n = AppL10n.of(context);

    return DecoratedBox(
      key: const Key('zodiac_result_ask_block'),
      decoration: BoxDecoration(
        color: colors.colorSurfaceAlt,
        borderRadius: BorderRadius.circular(platform.radiusSmall),
        border: Border.all(color: colors.colorLine),
      ),
      child: Padding(
        padding: const EdgeInsets.all(CupidSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                CupidIcon(
                  CupidIcons.help,
                  variant: CupidIconVariant.line,
                  size: 20,
                  color: colors.colorTextMuted,
                ),
                const SizedBox(width: CupidSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.zodiac_shell_ask_block_title.toUpperCase(),
                    style: type.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.colorTextMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: CupidSpacing.sm),
            Text(
              key: const Key('zodiac_result_ask_line'),
              askLine,
              style: type.body.copyWith(
                fontWeight: FontWeight.w500,
                color: colors.colorText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One of the three, with the single primary action the spec allows it.
///
/// The `(+)` is the STORY-010 treatment reused verbatim rather than a third
/// card variant (`ux/uiux-spec.md` §5): outlined circle, 44x44 hit area, and a
/// `Semantics` label that still says "Thêm vào kho của tôi" out loud.
class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.suggestion, required this.onAdd});

  final ZodiacSuggestion suggestion;
  final VoidCallback onAdd;

  static const double _minTapTarget = 44;
  static const double _addIconSize = 20;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final AppL10n l10n = AppL10n.of(context);
    final String? note = suggestion.note;

    return DecoratedBox(
      key: Key('zodiac_suggestion_card_${suggestion.id}'),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platform.radiusSmall),
        border: Border.all(color: colors.colorLine),
      ),
      child: Padding(
        padding: const EdgeInsets.all(CupidSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CupidIcon(
              CupidIcons.localActivity,
              variant: CupidIconVariant.line,
              size: 20,
              color: colors.colorText,
            ),
            const SizedBox(width: CupidSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    suggestion.title,
                    style: type.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.colorText,
                    ),
                  ),
                  if (note != null) ...<Widget>[
                    const SizedBox(height: CupidSpacing.xs),
                    Text(
                      note,
                      style: type.caption.copyWith(color: colors.colorTextMuted),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: CupidSpacing.sm),
            Semantics(
              button: true,
              label: l10n.zodiac_shell_add_to_my_store_action,
              excludeSemantics: true,
              child: GestureDetector(
                key: Key('zodiac_suggestion_add_${suggestion.id}'),
                behavior: HitTestBehavior.opaque,
                onTap: onAdd,
                child: SizedBox(
                  width: _minTapTarget,
                  height: _minTapTarget,
                  child: Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.colorAccentPurple),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(CupidSpacing.xs),
                        child: CupidIcon(
                          CupidIcons.add,
                          variant: CupidIconVariant.line,
                          size: _addIconSize,
                          color: colors.colorAccentPurple,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The canvas closes screen (7) by saying in code what AC-17 says: this is a
/// shell to start a conversation with, not a verdict about anyone.
class _PositioningNote extends StatelessWidget {
  const _PositioningNote();

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final AppL10n l10n = AppL10n.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.colorSurfaceAlt,
        borderRadius: BorderRadius.circular(platform.radiusSmall),
      ),
      child: Padding(
        padding: const EdgeInsets.all(CupidSpacing.md),
        child: Text(
          key: const Key('zodiac_result_positioning_note'),
          l10n.zodiac_shell_positioning_note,
          style: type.caption.copyWith(color: colors.colorTextMuted),
        ),
      ),
    );
  }
}
