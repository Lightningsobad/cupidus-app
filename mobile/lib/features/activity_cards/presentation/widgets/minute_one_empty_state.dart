import 'package:flutter/material.dart';

import '../../../../core/content/content_package.dart';
import '../../../../design_system/icons/cupid_icon.dart';
import '../../../../design_system/icons/cupid_icons.dart';
import '../../../../design_system/theme/cupid_theme_context.dart';
import '../../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../../design_system/tokens/cupid_platform_tokens.dart';
import '../../../../design_system/tokens/cupid_spacing.dart';
import '../../../../design_system/tokens/cupid_typography_tokens.dart';
import '../../domain/activity_card.dart';
import '../../domain/activity_card_repository.dart';
import '../../domain/occasion_suggestion_service.dart';
import 'activity_status_filter.dart';
import 'quick_capture_sheet.dart';
import 'quick_entry_strip.dart';

/// Resolves the occasion prompt offered by the second invitation. Injected so
/// the branch stays deterministic in a test; production reads the shipped
/// asset package and the device date, with no network or model call on the
/// path (R-7, BR-8).
typedef OccasionPromptLoader = Future<OccasionPrompt?> Function();

/// Minute-1: the absolute-empty state of the card hub (`ux/uiux-spec.md` §4a).
///
/// The caller mounts this only when the whole store is empty, and suppresses
/// the segmented status filter while it shows — five panes that all read zero
/// are five ways to learn the same thing. What is here instead is exactly two
/// invitations, at most one short title line above them, and the three-cell
/// quick-entry strip §4a keeps in this state. There is deliberately no
/// illustration, no marketing paragraph, no form and no wizard: both
/// invitations reach a created card in one tap plus at most one field
/// (AC-1, AC-2, AC-3).
class MinuteOneEmptyState extends StatefulWidget {
  const MinuteOneEmptyState({
    super.key,
    required this.repository,
    this.loadPrompt,
    this.onCardCreated,
    this.onQuickEntryCellSelected,
  });

  final ActivityCardRepository repository;
  final OccasionPromptLoader? loadPrompt;

  /// Fired once a card exists, so the host can leave Minute-1.
  final ValueChanged<ActivityCard>? onCardCreated;

  /// Routes a tap on the embedded strip. Minute-1 is the first hub state a new
  /// user ever sees, so a cell that leads somewhere in the populated hub has to
  /// lead there from here too; left null the strip keeps its own neutral
  /// answer.
  final ValueChanged<QuickEntryCell>? onQuickEntryCellSelected;

  @override
  State<MinuteOneEmptyState> createState() => _MinuteOneEmptyStateState();
}

class _MinuteOneEmptyStateState extends State<MinuteOneEmptyState> {
  OccasionPrompt? _prompt;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    (widget.loadPrompt ?? _loadNearestOccasion)().then((
      OccasionPrompt? prompt,
    ) {
      if (!mounted) {
        return;
      }
      setState(() => _prompt = prompt);
    });
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final OccasionPrompt? prompt = _prompt;

    return Column(
      key: const Key('activity_card_hub_minute1'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            CupidSpacing.md,
            CupidSpacing.lg,
            CupidSpacing.md,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                activityHubText(
                  context,
                  'Bắt đầu từ một điều nhỏ nhé.',
                  'Start with one small thing.',
                ),
                key: const Key('activity_card_hub_minute1_title'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: type.cardTitle.copyWith(color: colors.colorText),
              ),
              const SizedBox(height: CupidSpacing.lg),
              _InviteCard(
                invitationKey: const Key('activity_minute1_invite_link'),
                glyph: CupidIcons.link,
                glyphColor: colors.colorOnAccent,
                tileGradient: colors.gradientHot,
                accented: true,
                label: activityHubText(
                  context,
                  'Dán cái link vừa thấy',
                  'Paste the link you just saw',
                ),
                onTap: _captureLink,
              ),
              // B-6: the shipped occasion package runs out on 2027-12-24, and
              // past that date this invitation can only dead-end. An offer that
              // cannot be honoured is worse than one that is not made, so it is
              // withheld rather than shown and then refused.
              if (prompt != null) ...<Widget>[
                const SizedBox(height: CupidSpacing.md),
                _InviteCard(
                  invitationKey: const Key('activity_minute1_invite_occasion'),
                  glyph: CupidIcons.schedule,
                  glyphColor: colors.colorMint,
                  tileGradient: null,
                  accented: false,
                  label: activityHubText(
                    context,
                    'Để mình mách cho, theo dịp gần nhất',
                    'Let me suggest something for the nearest occasion',
                  ),
                  onTap: _revealSuggestions,
                ),
              ],
              if (_showSuggestions && prompt != null)
                _SuggestionList(
                  prompt: prompt,
                  onSelected: _acceptSuggestion,
                ),
            ],
          ),
        ),
        const SizedBox(height: CupidSpacing.lg),
        QuickEntryStrip(onCellSelected: widget.onQuickEntryCellSelected),
        const SizedBox(height: CupidSpacing.lg),
      ],
    );
  }

  Future<void> _captureLink() async {
    final ActivityCard? card = await QuickCaptureSheet.show(
      context,
      mode: QuickCaptureMode.link,
      repository: widget.repository,
    );
    if (card != null) {
      widget.onCardCreated?.call(card);
    }
  }

  void _revealSuggestions() {
    setState(() => _showSuggestions = true);
  }

  Future<void> _acceptSuggestion(OccasionSuggestion suggestion) async {
    final ActivityCard card = await OccasionSuggestionService(
      repository: widget.repository,
    ).acceptSuggestion(suggestion);
    if (!mounted) {
      return;
    }
    widget.onCardCreated?.call(card);
  }
}

Future<OccasionPrompt?> _loadNearestOccasion() async {
  final ContentPackage<Occasion> package = await loadOccasionPackage();
  return OccasionSuggestionService.nearestOccasion(
    deviceDate: DateTime.now(),
    package: package,
  );
}

class _InviteCard extends StatelessWidget {
  const _InviteCard({
    required this.invitationKey,
    required this.glyph,
    required this.glyphColor,
    required this.tileGradient,
    required this.accented,
    required this.label,
    required this.onTap,
  });

  final Key invitationKey;
  final IconData glyph;
  final Color glyphColor;
  final Gradient? tileGradient;
  final bool accented;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;
    final double tileSize = platform.tapTarget;

    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        key: invitationKey,
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.colorSurface,
            borderRadius: BorderRadius.circular(platform.radiusCard),
            border: Border.all(
              color: accented ? colors.colorAccentPink : colors.colorLine,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(CupidSpacing.md),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: tileSize,
                  height: tileSize,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: tileGradient == null
                          ? colors.colorSurfaceAlt
                          : null,
                      gradient: tileGradient,
                      borderRadius: BorderRadius.circular(platform.radiusSmall),
                    ),
                    child: Center(
                      child: CupidIcon(
                        glyph,
                        variant: CupidIconVariant.line,
                        color: glyphColor,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: CupidSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: type.body.copyWith(
                      color: colors.colorText,
                      fontWeight: FontWeight.w600,
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

/// The 1–2 suggestions of the nearest occasion, each a tap-to-create row
/// (AC-3). Titles and the occasion name come from the shipped package, never
/// from Dart (R-15a).
class _SuggestionList extends StatelessWidget {
  const _SuggestionList({required this.prompt, required this.onSelected});

  final OccasionPrompt prompt;
  final ValueChanged<OccasionSuggestion> onSelected;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Padding(
      key: const Key('activity_minute1_suggestions'),
      padding: const EdgeInsets.only(top: CupidSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: CupidSpacing.md,
              vertical: CupidSpacing.sm,
            ),
            child: Text(
              prompt.occasion.name,
              key: const Key('activity_minute1_occasion_name'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: type.caption.copyWith(color: colors.colorTextMuted),
            ),
          ),
          for (final OccasionSuggestion suggestion in prompt.suggestions)
            Semantics(
              button: true,
              label: suggestion.title,
              child: GestureDetector(
                key: Key('activity_minute1_suggestion_${suggestion.id}'),
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelected(suggestion),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: platform.tapTarget),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CupidSpacing.md,
                      vertical: CupidSpacing.sm,
                    ),
                    child: Row(
                      children: <Widget>[
                        CupidIcon(
                          CupidIcons.add,
                          variant: CupidIconVariant.line,
                          color: colors.colorAccentPink,
                          size: 20,
                        ),
                        const SizedBox(width: CupidSpacing.sm),
                        Expanded(
                          child: Text(
                            suggestion.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: type.body.copyWith(color: colors.colorText),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
