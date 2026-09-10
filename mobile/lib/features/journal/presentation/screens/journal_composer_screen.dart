import 'dart:io';

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/journal/journal_media_store.dart';
import '../../../../l10n/generated/app_l10n.dart';
import '../../data/journal_repository.dart';
import '../journal_composer_cubit.dart';

/// Edge of an attached-photo preview in the composer strip. Larger than the
/// list screen's 56pt thumbnail because this one is the photo the user is
/// deciding about, not a row ornament.
const double _previewSize = 88;

/// Full-screen composer for one journal entry
/// (`coding-plan/phase-P4-journal-composer-screen.md`).
///
/// A route rather than a bottom sheet because the body has no length bound
/// (`ux/uiux-spec.md` §3). The absences carry the same weight as on the list
/// screen: no share, export or copy-all affordance anywhere (AC-6), no draft
/// written to disk, and no version history beside the saved entry (AC-3,
/// AC-13). `journal_composer_screen_test.dart` walks the built tree for the
/// first and the placeholder's invariance for BR-8.
class JournalComposerScreen extends StatelessWidget {
  const JournalComposerScreen({
    super.key,
    required this.repository,
    required this.mediaStore,
    this.entryId,
    this.seedText,
    this.seedPhotoPaths = const <String>[],
    this.originRef,
    this.pickImages,
  });

  final JournalRepository repository;
  final JournalMediaStore mediaStore;

  /// Non-null reopens that entry for editing; saving overwrites it in place.
  final String? entryId;

  final String? seedText;
  final List<String> seedPhotoPaths;

  /// Opaque provenance tag stored verbatim with the entry — never parsed and
  /// never rendered (`architecture/contract-summary.md` §3).
  final String? originRef;

  /// Test seam for the OS image picker.
  final JournalImagePicker? pickImages;

  bool get _isSeeded =>
      seedText != null || seedPhotoPaths.isNotEmpty || originRef != null;

  JournalComposerCubit _createCubit() {
    if (entryId != null) {
      return JournalComposerCubit.editing(
        repository: repository,
        mediaStore: mediaStore,
        entryId: entryId!,
        pickImages: pickImages,
      );
    }
    if (_isSeeded) {
      return JournalComposerCubit.seeded(
        repository: repository,
        mediaStore: mediaStore,
        seedText: seedText,
        seedPhotoPaths: seedPhotoPaths,
        originRef: originRef,
        pickImages: pickImages,
      );
    }
    return JournalComposerCubit.blank(
      repository: repository,
      mediaStore: mediaStore,
      pickImages: pickImages,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<JournalComposerCubit>(
      create: (_) => _createCubit(),
      child: const _ComposerView(),
    );
  }
}

class _ComposerView extends StatelessWidget {
  const _ComposerView();

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return BlocConsumer<JournalComposerCubit, JournalComposerState>(
      listenWhen: (JournalComposerState previous, JournalComposerState current) =>
          previous.savedEntryId == null && current.savedEntryId != null,
      listener: (BuildContext context, JournalComposerState state) {
        Navigator.of(context).pop(state.savedEntryId);
      },
      builder: (BuildContext context, JournalComposerState state) {
        final JournalComposerCubit cubit = context.read<JournalComposerCubit>();

        return Scaffold(
          appBar: CupidHeader(
            title: state.isEditing
                ? l10n.journal_composer_edit_title
                : l10n.journal_composer_title,
            onBack: Navigator.of(context).canPop()
                // Leaving without saving discards the entry: nothing was
                // written, and no draft is kept anywhere (AC-13).
                ? () => Navigator.of(context).maybePop()
                : null,
            actions: <Widget>[
              TextButton(
                key: const Key('journal-composer-save'),
                onPressed: state.canSave ? cubit.save : null,
                child: Text(l10n.journal_composer_save),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Expanded(child: _ComposerField()),
                if (state.photoPaths.isNotEmpty)
                  _AttachmentStrip(
                    paths: state.photoPaths,
                    onRemove: cubit.removePhotoAt,
                  ),
                _ComposerToolbar(onAttach: cubit.attachPhotos),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Auto-growing body field (`ux/uiux-spec.md` §3). The hint is the fixed ARB
/// preset: it is read once per build from the same key, so it cannot differ
/// between two opens (BR-8).
class _ComposerField extends StatefulWidget {
  const _ComposerField();

  @override
  State<_ComposerField> createState() => _ComposerFieldState();
}

class _ComposerFieldState extends State<_ComposerField> {
  late final TextEditingController _controller = TextEditingController(
    text: context.read<JournalComposerCubit>().state.bodyText,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return BlocListener<JournalComposerCubit, JournalComposerState>(
      // Edit mode resolves its body after the first frame, so the controller
      // is filled from state rather than from a constructor argument.
      listenWhen: (JournalComposerState previous, JournalComposerState current) =>
          current.bodyText != _controller.text,
      listener: (BuildContext context, JournalComposerState state) =>
          _controller.text = state.bodyText,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(CupidSpacing.md),
        child: TextField(
          key: const Key('journal-composer-body-field'),
          controller: _controller,
          onChanged: context.read<JournalComposerCubit>().bodyChanged,
          autofocus: true,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          style: type.body.copyWith(color: colors.colorText),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: l10n.journal_composer_placeholder,
            hintStyle: type.body.copyWith(color: colors.colorTextMuted),
          ),
        ),
      ),
    );
  }
}

class _AttachmentStrip extends StatelessWidget {
  const _AttachmentStrip({required this.paths, required this.onRemove});

  final List<String> paths;
  final void Function(int index) onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _previewSize,
      child: ListView.separated(
        key: const Key('journal-composer-attachments'),
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: CupidSpacing.md),
        itemCount: paths.length,
        separatorBuilder: (BuildContext context, int index) =>
            SizedBox(width: CupidSpacing.sm),
        itemBuilder: (BuildContext context, int index) => _AttachmentPreview(
          path: paths[index],
          onRemove: () => onRemove(index),
          index: index,
        ),
      ),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  const _AttachmentPreview({
    required this.path,
    required this.onRemove,
    required this.index,
  });

  final String path;
  final VoidCallback onRemove;
  final int index;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return Stack(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
          child: SizedBox.square(
            dimension: _previewSize,
            child: Image.file(
              File(path),
              key: Key('journal-composer-photo-$index'),
              fit: BoxFit.cover,
              semanticLabel: l10n.journal_composer_photo_label,
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stack) =>
                      ColoredBox(color: colors.colorSurfaceAlt),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            key: Key('journal-composer-remove-photo-$index'),
            iconSize: 18,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: l10n.journal_composer_remove_photo,
            // Material Symbols Rounded is the app's only icon family
            // (`CupidIcons`), and it carries no `close`; `remove` is the
            // detach affordance the tooltip and semantic label name.
            icon: Icon(CupidIcons.remove, color: colors.colorText),
            onPressed: onRemove,
          ),
        ),
      ],
    );
  }
}

/// The composer's whole toolbar: one action, and it attaches a photo. There is
/// no share, export or copy-all row beside it, hidden or disabled (AC-6).
class _ComposerToolbar extends StatelessWidget {
  const _ComposerToolbar({required this.onAttach});

  final Future<void> Function() onAttach;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: CupidSpacing.sm,
        vertical: CupidSpacing.sm,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          key: const Key('journal-composer-attach'),
          onPressed: () => onAttach(),
          icon: Icon(CupidIcons.add, color: colors.colorAccentPink),
          label: Text(
            l10n.journal_composer_attach,
            style: TextStyle(color: colors.colorAccentPink),
          ),
        ),
      ),
    );
  }
}
