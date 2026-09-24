import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../../core/database/daos/activity_card_dao.dart';
import '../../../../core/di/service_locator.dart';
import '../../../journal/journal_entry_point.dart';

/// One already-saved photo phần 2 may attach to the share item.
///
/// A file reference and nothing else. The class is the enforcement of AC-17:
/// with no text, timestamp or entry-label field to read, no widget and no
/// future edit of the share path can carry journal content out of the device,
/// because the type it is handed simply has nowhere to put it.
@immutable
class AttachablePhoto {
  const AttachablePhoto(this.filePath);

  /// Absolute path of the file as its own store already holds it. Never a copy
  /// made for sharing: STORY-003's delete has to be able to clear every copy
  /// that exists (AC-18).
  final String filePath;

  @override
  bool operator ==(Object other) =>
      other is AttachablePhoto && other.filePath == filePath;

  @override
  int get hashCode => filePath.hashCode;
}

/// How phần 2 gets its photos, as a seam so a test can drive the section
/// without a composition root. [loadAttachablePhotos] in production.
typedef AttachablePhotoLoader = Future<List<AttachablePhoto>> Function(
  String cardId,
);

/// The two read-only sources for one card, merged.
///
/// Card photos come first because they are the card's own memories; the journal
/// half is whatever the user filed against this card as its provenance tag. The
/// journal half is empty until a story owning a card-to-journal entry flow
/// passes `originRef` (STORY-008), which is why the card half is what AC-14 and
/// AC-15 run on today.
Future<List<AttachablePhoto>> loadAttachablePhotos(String cardId) async {
  final List<String> cardPaths =
      (await getIt<ActivityCardDao>().photosForCard(cardId))
          .map((row) => row.localPath)
          .toList(growable: false);
  final List<String> journalPaths = await journalPhotoPathsForOrigin(cardId);
  return mergeAttachablePhotos(
    cardPaths: cardPaths,
    journalPaths: journalPaths,
  );
}

/// Merges the two sources, keeping each file once.
///
/// De-duplication is by file path, so a card photo the user also filed in the
/// journal is offered twice — the journal keeps its own copy under its own
/// media root, and those are two files with two independent lifetimes. Only the
/// same file reaching here from both sides collapses.
///
/// A path whose file is gone is dropped rather than drawn as a broken
/// thumbnail: both stores delete rows and files in separate steps, so a
/// momentary row-without-file is a state this read can actually see.
List<AttachablePhoto> mergeAttachablePhotos({
  required Iterable<String> cardPaths,
  required Iterable<String> journalPaths,
}) {
  final Set<String> seen = <String>{};
  final List<AttachablePhoto> photos = <AttachablePhoto>[];
  for (final String path in <String>[...cardPaths, ...journalPaths]) {
    if (!seen.add(path) || !File(path).existsSync()) {
      continue;
    }
    photos.add(AttachablePhoto(path));
  }
  return photos;
}
