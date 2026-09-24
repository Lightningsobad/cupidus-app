import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/content/content_package.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../design_system/icons/cupid_icons.dart';
import '../../../../../design_system/theme/cupid_theme_context.dart';
import '../../../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../../../design_system/tokens/cupid_platform_tokens.dart';
import '../../../../../design_system/tokens/cupid_spacing.dart';
import '../../../../../design_system/tokens/cupid_typography_tokens.dart';
import '../../../../invite_composer/domain/invite_preset.dart';
import '../../../../invite_composer/domain/preset_catalogue.dart';
import '../../../../invite_composer/presentation/widgets/invite_composer_sheet.dart';
import '../../../domain/activity_card.dart';

/// Same file-local bilingual helper the rest of the block uses: `mobile/lib/l10n/`
/// is outside this story's write scope. Only chrome goes through here — every
/// thank-you sentence is read off the shipped pack (R-15a).
String _text(BuildContext context, String vi, String en) =>
    Localizations.localeOf(context).languageCode == 'vi' ? vi : en;

/// The preset category this section opens the STORY-002 composer with.
///
/// Declared here rather than in `preset_catalogue.dart` because adding a
/// category is adding an asset file: [presetAssetKey] already maps this id to
/// `assets/data/req016/presets.thank_you_after_date.v1.json` by string
/// convention, with no lookup table to edit (AC-21/AC-29).
const String thankYouAfterDateCategoryId = 'thank_you_after_date';

/// How the composer is opened, as a seam rather than a direct call so a test
/// can drive the row without the composer's own DI. Mirrors
/// `InviteComposerOpener` in STORY-002's prepare-actions sheet.
typedef ThankYouComposerOpener =
    Future<bool> Function(
      BuildContext context,
      ActivityCard card,
      String categoryId,
    );

/// Test/preview seams for [ThanksSection]. Both null in production.
@immutable
class ThanksOptions {
  const ThanksOptions({this.catalogue, this.openComposer});

  final PresetCatalogue? catalogue;
  final ThankYouComposerOpener? openComposer;
}

/// Whether the thank-you category resolves to a pack with at least one preset.
///
/// Resolved *before* the entry point is drawn, the same defence
/// `showPrepareActionsSheet` applies: a missing or malformed pack means no row
/// at all, never a sheet that opens empty and never an error the user has to
/// read (AC-27).
Future<bool> thankYouPresetsAvailable([PresetCatalogue? catalogue]) async {
  try {
    final ContentPackage<InvitePreset> package =
        await (catalogue ?? getIt<PresetCatalogue>())
            .load(thankYouAfterDateCategoryId);
    return package.items.isNotEmpty;
  } catch (_) {
    return false;
  }
}

/// Phần 1 — "Soạn lời cảm ơn" (`ux/uiux-spec.md` mục 3).
///
/// One row at the secondary-action tier that opens STORY-002's existing
/// composer sheet with a different category id. It draws no composer UI of its
/// own and offers no category picker: `categoryId` is a hidden parameter the
/// caller supplies (AC-8/AC-9).
///
/// The section stays in the tree after the sheet closes — the block's single
/// presentation is spent by AC-3, not by using one of its parts (mục 4).
class ThanksSection extends StatelessWidget {
  const ThanksSection({
    super.key,
    required this.card,
    this.options = const ThanksOptions(),
  });

  final ActivityCard card;
  final ThanksOptions options;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Align(
      key: const Key('thanks_section'),
      alignment: Alignment.centerLeft,
      child: Semantics(
        button: true,
        child: GestureDetector(
          key: const Key('thanks_compose_chip'),
          behavior: HitTestBehavior.opaque,
          onTap: () => unawaited(_openComposer(context)),
          child: Container(
            constraints: BoxConstraints(minHeight: platform.tapTarget),
            padding: const EdgeInsets.symmetric(
              horizontal: CupidSpacing.sm,
              vertical: CupidSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: colors.colorSurface,
              border: Border.all(color: colors.colorLine),
              borderRadius: BorderRadius.circular(platform.radiusSmall),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  CupidIcons.editNote,
                  size: 20,
                  color: colors.colorTextMuted,
                ),
                const SizedBox(width: CupidSpacing.sm),
                Text(
                  _text(context, 'Soạn lời cảm ơn', 'Write a thank you'),
                  style: type.body.copyWith(color: colors.colorText),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openComposer(BuildContext context) async {
    final ThankYouComposerOpener open =
        options.openComposer ?? showInviteComposerSheet;
    await open(context, card, thankYouAfterDateCategoryId);
  }
}
