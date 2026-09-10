import 'package:flutter/material.dart';

import '../../../../core/content/content_package.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../design_system/icons/cupid_icons.dart';
import '../../../../design_system/theme/cupid_theme_context.dart';
import '../../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../../design_system/tokens/cupid_platform_tokens.dart';
import '../../../../design_system/tokens/cupid_spacing.dart';
import '../../../../design_system/tokens/cupid_typography_tokens.dart';
import '../../../activity_cards/domain/activity_card.dart';
import '../../domain/invite_preset.dart';
import '../../domain/preset_catalogue.dart';
import 'invite_composer_sheet.dart';

/// `mobile/lib/l10n/` is outside this story's write scope, so this surface uses
/// the same file-local bilingual helper the composer sheet uses.
String _prepareText(BuildContext context, String vi, String en) =>
    Localizations.localeOf(context).languageCode == 'vi' ? vi : en;

const double _grabHandleWidth = 40;
const double _grabHandleHeight = 4;

/// How the invite composer is opened from this sheet. A seam rather than a
/// direct call so a test can drive the row without the composer's own DI.
typedef InviteComposerOpener =
    Future<bool> Function(
      BuildContext context,
      ActivityCard card,
      String categoryId,
    );

/// How the whole sheet is presented, so the card detail screen can be driven
/// in a test without this feature's DI. Mirrors that screen's existing
/// `repository` seam.
typedef PrepareActionsPresenter =
    Future<void> Function(BuildContext context, ActivityCard card);

/// One row of the "Chuẩn bị" sheet.
///
/// A list of these from day one, even while only one resolves: STORY-006 and
/// STORY-008 add entries to [_resolveActions] rather than reshaping the sheet
/// (`ux/uiux-spec.md` §1).
class _PrepareAction {
  const _PrepareAction({
    required this.rowKey,
    required this.icon,
    required this.label,
    required this.run,
  });

  final Key rowKey;
  final IconData icon;
  final String Function(BuildContext context) label;

  /// Runs against the *card detail* context, after this sheet has closed, so
  /// dismissing whatever it opens lands back on the card and not on this sheet
  /// (`ux/uiux-spec.md` §4).
  final Future<void> Function(BuildContext context) run;
}

/// Opens the "Chuẩn bị" chooser for [card] (`ux/uiux-spec.md` §1).
///
/// This is the single entry surface the card's one primary action leads to
/// (AC-1/AC-2) — a bottom sheet, never a route (AC-3). Actions are resolved
/// *before* the sheet is shown, so a category whose pack does not resolve
/// simply has no row: the sheet never opens empty and never shows an error
/// screen (AC-27).
Future<void> showPrepareActionsSheet(
  BuildContext context,
  ActivityCard card, {
  PresetCatalogue? catalogue,
  InviteComposerOpener openComposer = showInviteComposerSheet,
}) async {
  final List<_PrepareAction> actions = await _resolveActions(
    card,
    catalogue ?? getIt<PresetCatalogue>(),
    openComposer,
  );
  if (actions.isEmpty || !context.mounted) {
    return;
  }

  final CupidColorTokens colors = context.cupidColors;
  final CupidPlatformTokens platform = context.cupidPlatform;
  final _PrepareAction? chosen = await showModalBottomSheet<_PrepareAction>(
    context: context,
    useSafeArea: true,
    backgroundColor: colors.colorSurface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(platform.radiusSheet),
      ),
    ),
    builder: (BuildContext _) => _PrepareActionsSheet(actions: actions),
  );
  if (chosen == null || !context.mounted) {
    return;
  }
  await chosen.run(context);
}

/// The rows that are usable for [card] right now, in display order.
Future<List<_PrepareAction>> _resolveActions(
  ActivityCard card,
  PresetCatalogue catalogue,
  InviteComposerOpener openComposer,
) async {
  final List<_PrepareAction> actions = <_PrepareAction>[];
  if (await _hasPresets(catalogue, inviteCategoryId)) {
    actions.add(
      _PrepareAction(
        rowKey: const Key('prepare_action_invite'),
        icon: CupidIcons.editNote,
        label: (BuildContext context) =>
            _prepareText(context, 'Xuất lời mời', 'Export the invite'),
        run: (BuildContext context) =>
            openComposer(context, card, inviteCategoryId),
      ),
    );
  }
  return actions;
}

/// Whether [categoryId] resolves to a pack with at least one preset. A missing
/// or malformed pack is "no row", never a thrown error the user has to read
/// (AC-27) — the same rule `InviteComposerCubit.load` applies one level down.
Future<bool> _hasPresets(PresetCatalogue catalogue, String categoryId) async {
  try {
    final ContentPackage<InvitePreset> package =
        await catalogue.load(categoryId);
    return package.items.isNotEmpty;
  } catch (_) {
    return false;
  }
}

class _PrepareActionsSheet extends StatelessWidget {
  const _PrepareActionsSheet({required this.actions});

  final List<_PrepareAction> actions;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Column(
      key: const Key('prepare_actions_sheet'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: CupidSpacing.sm),
        Center(
          child: Container(
            width: _grabHandleWidth,
            height: _grabHandleHeight,
            decoration: BoxDecoration(
              color: colors.colorLine,
              borderRadius: BorderRadius.circular(_grabHandleHeight),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(CupidSpacing.md),
          child: Text(
            _prepareText(context, 'Chuẩn bị', 'Get ready'),
            style: type.cardTitle.copyWith(color: colors.colorText),
          ),
        ),
        for (final _PrepareAction action in actions)
          _PrepareActionRow(action: action),
        const SizedBox(height: CupidSpacing.md),
      ],
    );
  }
}

class _PrepareActionRow extends StatelessWidget {
  const _PrepareActionRow({required this.action});

  final _PrepareAction action;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;
    final String label = action.label(context);

    return Semantics(
      button: true,
      child: GestureDetector(
        key: action.rowKey,
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(action),
        child: Container(
          constraints: BoxConstraints(minHeight: platform.tapTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: CupidSpacing.md,
            vertical: CupidSpacing.sm,
          ),
          child: Row(
            children: <Widget>[
              Icon(action.icon, size: 20, color: colors.colorAccentPink),
              const SizedBox(width: CupidSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: type.body.copyWith(color: colors.colorText),
                ),
              ),
              Icon(
                CupidIcons.chevronRight,
                size: 18,
                color: colors.colorTextMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
