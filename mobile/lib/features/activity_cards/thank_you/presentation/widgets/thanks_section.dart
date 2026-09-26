import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/content/content_package.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../design_system/icons/cupid_icons.dart';
import '../../../../../design_system/theme/cupid_theme_context.dart';
import '../../../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../../../design_system/tokens/cupid_platform_tokens.dart';
import '../../../../../design_system/tokens/cupid_spacing.dart';
import '../../../../../design_system/tokens/cupid_typography_tokens.dart';
import '../../../../invite_composer/domain/invite_payload_repository.dart';
import '../../../../invite_composer/domain/invite_preset.dart';
import '../../../../invite_composer/domain/preset_catalogue.dart';
import '../../../../invite_composer/presentation/invite_composer_cubit.dart';
import '../../../../invite_composer/presentation/widgets/invite_composer_sheet.dart';
import '../../../domain/activity_card.dart';
import '../../../domain/activity_card_repository.dart';

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
///
/// [attachmentPaths] are the files phần 2 has selected at the moment the sheet
/// opens. A snapshot is enough: the sheet is modal, so the row of thumbnails
/// cannot be touched again before the share.
typedef ThankYouComposerOpener =
    Future<bool> Function(
      BuildContext context,
      ActivityCard card,
      String categoryId,
      List<String> attachmentPaths,
    );

/// Test/preview seams for [ThanksSection]. Both null in production.
@immutable
class ThanksOptions {
  const ThanksOptions({this.catalogue, this.openComposer});

  final PresetCatalogue? catalogue;
  final ThankYouComposerOpener? openComposer;
}

/// The share item: phần 1's text plus the original files picked in phần 2.
///
/// Every file goes out by reference to the path its own store already holds.
/// Nothing is copied into a share staging area, so deleting the journal entry
/// or the card still removes every copy of the photo the app ever made
/// (AC-18), and an empty selection produces an item with no file at all —
/// which is what the user gets until they tap a thumbnail (AC-16).
ShareParams thankYouShareParams({
  required String text,
  required List<String> filePaths,
}) =>
    ShareParams(
      text: text,
      files: <XFile>[for (final String path in filePaths) XFile(path)],
    );

/// Opens STORY-002's composer with the thank-you category and hands the OS the
/// text together with [attachmentPaths].
///
/// The composer is reached through its own public entry point; only the share
/// step is supplied here, because attaching a file is this block's behaviour
/// and not something STORY-002's invite flow does.
Future<bool> openThankYouComposer(
  BuildContext context,
  ActivityCard card,
  String categoryId,
  List<String> attachmentPaths,
) {
  return showInviteComposerSheet(
    context,
    card,
    categoryId,
    createCubit: () => InviteComposerCubit(
      card: card,
      categoryId: categoryId,
      catalogue: getIt<PresetCatalogue>(),
      payloads: getIt<InvitePayloadRepository>(),
      cards: getIt<ActivityCardRepository>(),
      share: (String text) async {
        await SharePlus.instance.share(
          thankYouShareParams(text: text, filePaths: attachmentPaths),
        );
      },
    ),
  );
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
    this.attachments,
  });

  final ActivityCard card;
  final ThanksOptions options;

  /// Photos phần 2 has selected, or null when there is no phần 2 to select in.
  /// Read at the moment the composer opens; this section never writes to it.
  final ValueListenable<List<String>>? attachments;

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
        options.openComposer ?? openThankYouComposer;
    await open(
      context,
      card,
      thankYouAfterDateCategoryId,
      attachments?.value ?? const <String>[],
    );
  }
}
