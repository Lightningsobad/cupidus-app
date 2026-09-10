/// The context notebook's whole contact surface with the rest of the app
/// (`architecture/contract-summary.md` §3).
///
/// STORY-005/008/009/010 read the notebook and reuse the ask mechanism through
/// this file and nothing else. Deliberately absent: the DAO, the repository,
/// the cubit and every internal widget, plus any function that counts, ranks,
/// or searches what the user wrote — a ranking helper here is how a "how
/// complete is your notebook" surface gets built by accident (AC-12/AC-25).
library;

import 'package:flutter/widgets.dart';

import '../../core/di/service_locator.dart';
import 'data/context_notebook_repository.dart';
import 'domain/context_notebook_models.dart';

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

/// Will push the "Sổ tay người yêu" screen, full-screen and on its own route.
///
/// Phase P3 fixes the signature because STORY-005/008/009/010 are written
/// against it, but the screen itself belongs to phase P4, which replaces this
/// body with the real push
/// (`coding-plan/phase-P3-ask-on-the-spot-shared-surface.md` §6: "phase này
/// không gắn lối vào; P4 và P7 làm việc đó"). Until then a call is a wiring
/// mistake, and throwing is what stops it shipping as a dead menu row.
Future<void> openNotebookScreen(BuildContext context) {
  throw UnimplementedError(
    'openNotebookScreen is wired in coding-plan phase P4, together with the '
    'notebook screen it pushes.',
  );
}

/// Will push the "Những gì bạn giỏi" screen, full-screen and on its own route.
///
/// Same P3/P4 split as [openNotebookScreen].
Future<void> openSkillProfileScreen(BuildContext context) {
  throw UnimplementedError(
    'openSkillProfileScreen is wired in coding-plan phase P4, together with '
    'the skill profile screen it pushes.',
  );
}
