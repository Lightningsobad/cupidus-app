/// The private journal's whole contact surface with the rest of the app
/// (`architecture/contract-summary.md`).
///
/// Two of the four declarations below are the cross-story contract STORY-007
/// and STORY-008 call — [openJournalComposer] and [JournalComposerSeed], with
/// the signatures §1 of that document locks. The third,
/// [openJournalScreen], exists because
/// `coding-plan/phase-P5-journal-entry-point-and-menu.md` §3 also makes this
/// file "nơi duy nhất mở `JournalScreen` từ ngoài feature", which its §4 turns
/// into an acceptance criterion: nothing outside `features/journal/**` and
/// `core/journal/**` may import a journal internal, and `me_screen.dart` has to
/// reach the journal somehow. It is navigation only.
///
/// What is deliberately absent is the point of the file: no `JournalDao`,
/// `JournalRepository`, `JournalMediaStore`, cubit or internal widget is
/// re-exported, and there is no function to list, count, search or preview an
/// entry (AC-7, `contract-summary.md` §5).
///
/// The one thing that can be read back out is [journalPhotoPathsForOrigin],
/// added by STORY-007 P4 under the 2026-09-23 `JOURNAL_SOURCE_CONTRACT_CLOSED`
/// ruling (`req_master.md` `## Design Ruling Log`). It hands back photo files
/// and nothing else, so text and metadata still never leave the journal
/// (AC-17/BR-8) and the surface stays "hand content in" plus one photo-only
/// read, rather than a readable journal.
library;

import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/journal/journal_media_store.dart';
import 'data/journal_repository.dart';
import 'presentation/screens/journal_composer_screen.dart';
import 'presentation/screens/journal_screen.dart';

/// Content a caller hands to [openJournalComposer]. Every field stays editable
/// and erasable by the user once the composer opens.
class JournalComposerSeed {
  const JournalComposerSeed({
    this.seedText,
    this.seedPhotoPaths = const <String>[],
    this.originRef,
  });

  /// Pre-filled body text; `null` opens on the empty placeholder.
  final String? seedText;

  /// Local files the caller owns. The journal copies each one into its own
  /// media root when the user saves, so the caller deleting its file later
  /// cannot empty a journal entry, and vice versa (`contract-summary.md` §3).
  /// A path that cannot be read is dropped rather than raised.
  final List<String> seedPhotoPaths;

  /// Opaque provenance tag stored verbatim with the entry. Never parsed, never
  /// rendered, never turned into a link.
  final String? originRef;
}

/// Opens the composer pre-filled from [seed] and completes with the id of the
/// entry the user saved, or `null` if they left without saving.
///
/// Never throws for an unreadable path in [JournalComposerSeed.seedPhotoPaths]:
/// the composer opens with that photo missing and the rest of the seed intact.
Future<String?> openJournalComposer(
  BuildContext context, {
  JournalComposerSeed seed = const JournalComposerSeed(),
}) {
  return Navigator.of(context).push<String>(
    MaterialPageRoute<String>(
      builder: (BuildContext _) => JournalComposerScreen(
        repository: getIt<JournalRepository>(),
        mediaStore: getIt<JournalMediaStore>(),
        seedText: seed.seedText,
        seedPhotoPaths: seed.seedPhotoPaths,
        originRef: seed.originRef,
      ),
    ),
  );
}

/// Absolute paths of the photos held by the entries tagged with [originRef].
///
/// The only read the journal allows out, and only in this shape: file
/// references, never body text, timestamps, entry ids or how many entries
/// matched. A caller that already knows the provenance tag it wrote can pick up
/// its own photos again; it still cannot list, count, search or preview
/// anything (AC-17/BR-8).
///
/// An entry whose photo file has since gone is simply absent from the result.
Future<List<String>> journalPhotoPathsForOrigin(String originRef) {
  return getIt<JournalRepository>().photoFilePathsForOrigin(originRef);
}

/// Pushes the journal itself, full-screen, with its "Viết điều gì đó" CTA wired
/// to [openJournalComposer].
///
/// The list is not a tab and not a sub-tab of anything: it is one independent
/// route, which is what keeps it separate from the notebook and skill surfaces
/// sharing its menu block (AC-17, `ux/uiux-spec.md` §8).
Future<void> openJournalScreen(BuildContext context) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (BuildContext routeContext) => JournalScreen(
        repository: getIt<JournalRepository>(),
        mediaStore: getIt<JournalMediaStore>(),
        onCompose: () => openJournalComposer(routeContext),
      ),
    ),
  );
}
