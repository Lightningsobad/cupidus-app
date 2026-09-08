import 'dart:io';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/journal/journal_media_store.dart';
import '../data/journal_repository.dart';
import '../domain/journal_entry.dart';

/// Overridable picker seam, following `GalleryUploadCubit.defaultPickImages`.
/// Unlike the gallery's, it declares no downscale budget: a journal photo is
/// copied to local storage and never uploaded, so there is no payload limit to
/// trade image quality against.
typedef JournalImagePicker = Future<List<XFile>> Function();

/// Composer state (`coding-plan/phase-P4-journal-composer-screen.md` §3).
///
/// There is no draft field and no serialization here, and the cubit is a plain
/// [Cubit] rather than a `HydratedCubit`: an unsaved composer that survived to
/// disk would be a copy of the entry the user chose not to keep (AC-13).
class JournalComposerState {
  const JournalComposerState({
    this.bodyText = '',
    this.photoPaths = const <String>[],
    this.isEditing = false,
    this.isReady = true,
    this.isSaving = false,
    this.savedEntryId,
  });

  final String bodyText;

  /// Absolute paths of the attachments as they stand right now — picker
  /// results, seed files the caller still owns, and (in edit mode) the entry's
  /// own files resolved through [JournalMediaStore]. They become journal-owned
  /// copies only when [JournalComposerCubit.save] runs.
  final List<String> photoPaths;

  /// Drives the "Sửa" title (`ux/uiux-spec.md` §3).
  final bool isEditing;

  /// False only while an edit-mode entry is being read back.
  final bool isReady;

  final bool isSaving;

  /// Set once, when a save has committed. The screen pops with it; nothing
  /// else in the app reads a journal id.
  final String? savedEntryId;

  /// [isReady] gates the save, it does not merely describe the readback: with
  /// `autofocus: true` on the body field, one keystroke landing before an
  /// edit-mode readback emits would otherwise save the typed fragment over the
  /// stored entry (F-D1).
  bool get canSave =>
      isReady &&
      !isSaving &&
      (bodyText.trim().isNotEmpty || photoPaths.isNotEmpty);

  JournalComposerState copyWith({
    String? bodyText,
    List<String>? photoPaths,
    bool? isReady,
    bool? isSaving,
    String? savedEntryId,
  }) {
    return JournalComposerState(
      bodyText: bodyText ?? this.bodyText,
      photoPaths: photoPaths ?? this.photoPaths,
      isEditing: isEditing,
      isReady: isReady ?? this.isReady,
      isSaving: isSaving ?? this.isSaving,
      savedEntryId: savedEntryId ?? this.savedEntryId,
    );
  }
}

/// Drives `JournalComposerScreen` in its three entry modes: a blank entry, an
/// existing entry reopened for editing, and an entry pre-filled from another
/// surface's content. The third is the shape `openJournalComposer` wraps in P5
/// (`architecture/contract-summary.md` §1).
///
/// Nothing here writes an entry on its own: [save] runs only from the user's
/// "Lưu" tap, which is what keeps an `external` entry a user decision rather
/// than something the app wrote on their behalf (BR-5).
class JournalComposerCubit extends Cubit<JournalComposerState> {
  JournalComposerCubit._({
    required JournalRepository repository,
    required JournalMediaStore mediaStore,
    required String entryId,
    required JournalEntryOrigin origin,
    String? originRef,
    JournalImagePicker? pickImages,
    JournalComposerState initial = const JournalComposerState(),
  })  : _repository = repository,
        _mediaStore = mediaStore,
        _entryId = entryId,
        _origin = origin,
        _originRef = originRef,
        _pickImages = pickImages ?? defaultPickImages,
        super(initial);

  /// Mode 1 — write a new entry from nothing.
  factory JournalComposerCubit.blank({
    required JournalRepository repository,
    required JournalMediaStore mediaStore,
    JournalImagePicker? pickImages,
    String Function()? newEntryId,
  }) {
    return JournalComposerCubit._(
      repository: repository,
      mediaStore: mediaStore,
      entryId: (newEntryId ?? newUuidV4)(),
      origin: JournalEntryOrigin.manual,
      pickImages: pickImages,
    );
  }

  /// Mode 2 — reopen a saved entry. Saving rewrites that same id in place, so
  /// no second row and no version history can appear (AC-3).
  factory JournalComposerCubit.editing({
    required JournalRepository repository,
    required JournalMediaStore mediaStore,
    required String entryId,
    JournalImagePicker? pickImages,
  }) {
    final JournalComposerCubit cubit = JournalComposerCubit._(
      repository: repository,
      mediaStore: mediaStore,
      entryId: entryId,
      origin: JournalEntryOrigin.manual,
      pickImages: pickImages,
      initial: const JournalComposerState(isEditing: true, isReady: false),
    );
    cubit._loadExisting();
    return cubit;
  }

  /// Mode 3 — open pre-filled from another surface. Every seeded field stays
  /// editable and erasable, and an unreadable seed path is dropped rather than
  /// raised, so the composer always opens (`contract-summary.md` §3).
  factory JournalComposerCubit.seeded({
    required JournalRepository repository,
    required JournalMediaStore mediaStore,
    String? seedText,
    List<String> seedPhotoPaths = const <String>[],
    String? originRef,
    JournalImagePicker? pickImages,
    String Function()? newEntryId,
  }) {
    return JournalComposerCubit._(
      repository: repository,
      mediaStore: mediaStore,
      entryId: (newEntryId ?? newUuidV4)(),
      origin: JournalEntryOrigin.external,
      originRef: originRef,
      pickImages: pickImages,
      initial: JournalComposerState(
        bodyText: seedText ?? '',
        photoPaths: <String>[
          for (final String path in seedPhotoPaths)
            if (File(path).existsSync()) path,
        ],
      ),
    );
  }

  static Future<List<XFile>> defaultPickImages() =>
      ImagePicker().pickMultiImage();

  final JournalRepository _repository;
  final JournalMediaStore _mediaStore;
  final String _entryId;
  final JournalEntryOrigin _origin;
  final String? _originRef;
  final JournalImagePicker _pickImages;

  /// Media-root-relative paths the entry referenced when this composer last
  /// synced with storage. [save] re-imports every attachment under a fresh
  /// name, which leaves these unreferenced.
  List<String> _supersededRelativePaths = const <String>[];

  Future<void> _loadExisting() async {
    final JournalEntry? entry = await _repository.entryById(_entryId);
    if (isClosed) {
      return;
    }
    if (entry == null) {
      emit(state.copyWith(isReady: true));
      return;
    }
    final List<String> paths = await _resolveAll(entry.photos);
    if (isClosed) {
      return;
    }
    _supersededRelativePaths = <String>[
      for (final JournalEntryPhoto photo in entry.photos) photo.relativePath,
    ];
    emit(
      state.copyWith(
        bodyText: entry.bodyText,
        photoPaths: paths,
        isReady: true,
      ),
    );
  }

  void bodyChanged(String value) => emit(state.copyWith(bodyText: value));

  Future<void> attachPhotos() async {
    final List<XFile> picked = await _pickImages();
    if (picked.isEmpty || isClosed) {
      return;
    }
    emit(
      state.copyWith(
        photoPaths: <String>[
          ...state.photoPaths,
          for (final XFile file in picked) file.path,
        ],
      ),
    );
  }

  void removePhotoAt(int index) {
    if (index < 0 || index >= state.photoPaths.length) {
      return;
    }
    final List<String> next = List<String>.of(state.photoPaths)
      ..removeAt(index);
    emit(state.copyWith(photoPaths: next));
  }

  /// Writes the entry, then removes the files the write superseded.
  ///
  /// The cleanup is not housekeeping: after an edit that dropped a photo, the
  /// dropped file would otherwise stay on disk as a copy of something the user
  /// removed, which is the hidden copy AC-13 rules out.
  Future<void> save() async {
    if (!state.canSave) {
      return;
    }
    emit(state.copyWith(isSaving: true));

    final List<String> superseded = _supersededRelativePaths;
    final JournalEntry? saved = await _repository.saveEntry(
      id: _entryId,
      bodyText: state.bodyText,
      photoSourcePaths: state.photoPaths,
      origin: _origin,
      originRef: _originRef,
    );
    if (saved == null) {
      if (!isClosed) {
        emit(state.copyWith(isSaving: false));
      }
      return;
    }

    for (final String relativePath in superseded) {
      final File file = await _mediaStore.resolvePhoto(relativePath);
      if (file.existsSync()) {
        await file.delete();
      }
    }
    _supersededRelativePaths = <String>[
      for (final JournalEntryPhoto photo in saved.photos) photo.relativePath,
    ];
    final List<String> paths = await _resolveAll(saved.photos);
    if (isClosed) {
      return;
    }
    emit(
      state.copyWith(
        photoPaths: paths,
        isSaving: false,
        savedEntryId: saved.id,
      ),
    );
  }

  Future<List<String>> _resolveAll(List<JournalEntryPhoto> photos) async {
    final List<String> paths = <String>[];
    for (final JournalEntryPhoto photo in photos) {
      paths.add((await _mediaStore.resolvePhoto(photo.relativePath)).path);
    }
    return paths;
  }
}

final Random _random = Random.secure();

/// Entry ids are UUID v4 generated on device (`domain/journal_entry.dart`).
/// Same construction as `JournalMediaStore`'s file ids; this repo carries no
/// `uuid` package.
String newUuidV4() {
  final List<int> bytes = List<int>.generate(16, (_) => _random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final String hex =
      bytes.map((int b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
