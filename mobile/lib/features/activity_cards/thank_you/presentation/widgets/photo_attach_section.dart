import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../design_system/icons/cupid_icons.dart';
import '../../../../../design_system/theme/cupid_theme_context.dart';
import '../../../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../../../design_system/tokens/cupid_platform_tokens.dart';
import '../../../../../design_system/tokens/cupid_spacing.dart';
import '../../../../../design_system/tokens/cupid_typography_tokens.dart';
import '../../data/attachable_photos.dart';

/// Same file-local bilingual helper the rest of the block uses: `mobile/lib/l10n/`
/// is outside this story's write scope. Only the section's own chrome goes
/// through here — nothing read out of the journal is ever rendered.
String _text(BuildContext context, String vi, String en) =>
    Localizations.localeOf(context).languageCode == 'vi' ? vi : en;

const double _thumbnailSize = 72;

/// Phần 2 — "đính ảnh" (`ux/uiux-spec.md` mục 3).
///
/// A horizontally scrolling row of photos the user already has, and no way to
/// add a new one: the section never opens the camera or the gallery, which is
/// what keeps this a read-only window onto the journal rather than a second
/// door into it.
///
/// Built only with a non-empty [photos]; nothing with no photo to show reaches
/// the widget tree, so the "card with no photo" state is the absence of this
/// section rather than an empty row (AC-15, BR-9).
class PhotoAttachSection extends StatelessWidget {
  const PhotoAttachSection({
    super.key,
    required this.photos,
    required this.selection,
  });

  final List<AttachablePhoto> photos;

  /// The file paths currently destined for the share item, shared with phần 1
  /// because the share item is assembled there. Starts empty and only ever
  /// changes under a tap: the app never attaches a photo on the user's behalf
  /// (AC-16).
  final ValueNotifier<List<String>> selection;

  void _toggle(String filePath) {
    final List<String> next = List<String>.of(selection.value);
    if (!next.remove(filePath)) {
      next.add(filePath);
    }
    selection.value = next;
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Column(
      key: const Key('photo_attach_section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          _text(context, 'KÈM ẢNH · KHÔNG BẮT BUỘC', 'ADD A PHOTO · OPTIONAL'),
          style: type.caption.copyWith(
            color: colors.colorTextMuted,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: CupidSpacing.xs),
        SizedBox(
          height: _thumbnailSize,
          child: ValueListenableBuilder<List<String>>(
            valueListenable: selection,
            builder: (BuildContext context, List<String> selected, Widget? _) {
              return ListView.separated(
                key: const Key('photo_attach_row'),
                scrollDirection: Axis.horizontal,
                itemCount: photos.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(width: CupidSpacing.xs),
                itemBuilder: (BuildContext _, int index) => _Thumbnail(
                  index: index,
                  photo: photos[index],
                  selected: selected.contains(photos[index].filePath),
                  onTap: () => _toggle(photos[index].filePath),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// One photo, drawn as the photo and nothing else.
///
/// No caption, no date, no entry label and no overlay of any kind while
/// unselected — the picture is all the user's journal is allowed to say out
/// here (AC-17, BR-8). The selection tick is the app's own mark, not the
/// photo's.
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.index,
    required this.photo,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final AttachablePhoto photo;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;

    return Semantics(
      button: true,
      selected: selected,
      label: _text(context, 'Ảnh ${index + 1}', 'Photo ${index + 1}'),
      child: GestureDetector(
        key: Key('photo_attach_thumb_$index'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: _thumbnailSize,
          height: _thumbnailSize,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(platform.radiusSmall),
                  child: Container(
                    color: colors.colorSurface,
                    child: Image.file(
                      File(photo.filePath),
                      fit: BoxFit.cover,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
              ),
              if (selected)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.colorAccentPink, width: 2),
                      borderRadius: BorderRadius.circular(platform.radiusSmall),
                    ),
                  ),
                ),
              if (selected)
                Positioned(
                  top: CupidSpacing.xs,
                  right: CupidSpacing.xs,
                  child: Container(
                    key: Key('photo_attach_tick_$index'),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: colors.colorAccentPink,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupidIcons.check,
                      size: 14,
                      color: colors.colorSurface,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
