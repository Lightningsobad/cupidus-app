/// The context notebook's whole contact surface with the rest of the app
/// (`architecture/contract-summary.md` §3).
///
/// STORY-005/008/009/010 read the notebook and reuse the ask mechanism through
/// this file and nothing else. Deliberately absent: the DAO, the repository,
/// the cubit and every internal widget, plus any function that counts, ranks,
/// or searches what the user wrote — a ranking helper here is how a "how
/// complete is your notebook" surface gets built by accident (AC-12/AC-25).
library;

import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import 'data/context_notebook_repository.dart';
import 'domain/context_notebook_models.dart';
import 'presentation/screens/notebook_screen.dart';
import 'presentation/screens/skill_profile_screen.dart';

/// [AskTarget] only: a caller has to name the targets it wants answered in
/// [AskOnTheSpotSlot.neededFieldIds], and copying those wire values into each
/// caller is how the §2 vocabulary drifts.
export 'domain/context_content.dart' show AskTarget;
export 'domain/context_notebook_models.dart'
    show NotebookEntry, NotebookKind, SkillEntry;
export 'presentation/widgets/ask_on_the_spot_slot.dart' show AskOnTheSpotSlot;

/// Read-only view of what the user has written down. Consumers personalise
/// from this; they never write through it, because the only two ways context
/// enters the app are the inline ask and the user's own "+ tự thêm" (BR-1).
abstract interface class ContextNotebookReader {
  /// Newest first. Empty is a normal answer, not a reason to prompt (AC-8).
  Future<List<NotebookEntry>> entries({NotebookKind? kind});

  /// Oldest first, so a seed tapped early keeps its place.
  Future<List<SkillEntry>> skills();
}

/// The one [ContextNotebookReader] implementation, resolved from the
/// composition root so a caller never has to hold a repository to read
/// context.
ContextNotebookReader contextNotebookReader() =>
    _RepositoryReader(getIt<ContextNotebookRepository>());

class _RepositoryReader implements ContextNotebookReader {
  const _RepositoryReader(this._repository);

  final ContextNotebookRepository _repository;

  @override
  Future<List<NotebookEntry>> entries({NotebookKind? kind}) =>
      _repository.entries(kind: kind);

  @override
  Future<List<SkillEntry>> skills() => _repository.skills();
}

/// Pushes the "Sổ tay người yêu" screen, full-screen and on its own route.
///
/// Its own route, not a tab or a sub-tab of the skill screen: the two surfaces
/// stay independent so neither can grow a switcher between them (AC-17,
/// `ux/uiux-spec.md` Phần 0).
Future<void> openNotebookScreen(BuildContext context) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (BuildContext _) =>
          NotebookScreen(repository: getIt<ContextNotebookRepository>()),
    ),
  );
}

/// Writes **one** answered question into the notebook and returns the new
/// `notebook_entries.id`.
///
/// The second write door, and the only one (`STORY-009/architecture/
/// contract-summary.md` §3, amending §6 of the STORY-004 contract). §6 forbids
/// a second door because a pre-fill flow would put words in the notebook the
/// user never wrote; this door keeps that intact by being exactly as wide as
/// one user-typed answer. There is deliberately no bulk, import, or pre-fill
/// variant, no update, no delete, and no read-all here: those are the doors §6
/// rules out, and this amendment does not open them.
///
/// [kind] is a [NotebookKind], so a skill can never arrive through here — the
/// enum has two values and gaining a third is what AC-6 forbids.
Future<String> recordAnsweredQuestion({
  required String entryPointId,
  required String questionId,
  required NotebookKind kind,
  required String value,
  String? detail,
  String? eventOn,
}) async {
  if (entryPointId.trim().isEmpty) {
    throw ArgumentError.value(
      entryPointId,
      'entryPointId',
      'must name the calling entry point',
    );
  }
  final trimmedQuestionId = questionId.trim();
  if (trimmedQuestionId.isEmpty) {
    throw ArgumentError.value(
      questionId,
      'questionId',
      'an answer written from $entryPointId must stay attached to its question',
    );
  }
  final entry = await getIt<ContextNotebookRepository>().addEntry(
    kind: kind,
    value: value,
    source: ContextEntrySource.askOnTheSpot,
    detail: detail,
    eventOn: eventOn,
    questionId: trimmedQuestionId,
  );
  return entry.id;
}

/// Pushes the "Những gì bạn giỏi" screen, full-screen and on its own route.
///
/// Same independence rule as [openNotebookScreen].
Future<void> openSkillProfileScreen(BuildContext context) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (BuildContext _) =>
          SkillProfileScreen(repository: getIt<ContextNotebookRepository>()),
    ),
  );
}
