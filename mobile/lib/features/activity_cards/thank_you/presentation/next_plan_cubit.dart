import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/content/content_package.dart';
import '../../../conversation_starters/domain/starter_content.dart';
import '../../domain/activity_card.dart';
import '../domain/next_plan_suggestion_service.dart';

/// Everything phần 3 draws.
///
/// Deliberately has no `loading` flag and no "pack was empty" flag: an empty
/// [suggestions] draws nothing at all, which is the same shape before the pack
/// resolves and after a pack with no upcoming occasion resolves. That is what
/// keeps a spinner, a skeleton row and an empty-state card out of the block
/// (AC-29, AC-35).
@immutable
class NextPlanState {
  const NextPlanState({this.suggestions = const <NextPlanSuggestion>[]});

  final List<NextPlanSuggestion> suggestions;

  @override
  bool operator ==(Object other) =>
      other is NextPlanState && listEquals(other.suggestions, suggestions);

  @override
  int get hashCode => Object.hashAll(suggestions);
}

/// Resolves the chips of phần 3 and owns its one write.
///
/// [today] is injected rather than read here, so a test can pin the day and the
/// same pack renders the same chips either side of midnight (AC-19).
class NextPlanCubit extends Cubit<NextPlanState> {
  NextPlanCubit({
    required this.today,
    required this.service,
    this.package,
    this.loader = const ContentPackageLoader(),
    this.slots = maxNextPlanSuggestions,
  }) : super(const NextPlanState());

  /// Civil `YYYY-MM-DD`.
  final String today;

  final NextPlanSuggestionService service;

  /// Test/preview seam. Null in production, so [load] reads the shipped pack.
  final ContentPackage<CalendarEvent>? package;

  final ContentPackageLoader loader;
  final int slots;

  Future<void> load() async {
    final ContentPackage<CalendarEvent> resolved =
        package ?? await NextPlanSuggestionService.loadPackage(loader);
    if (isClosed) {
      return;
    }
    emit(
      NextPlanState(
        suggestions: NextPlanSuggestionService.suggest(
          package: resolved,
          today: today,
          slots: slots,
        ),
      ),
    );
  }

  /// The tap *is* the confirmation step (AC-20): no dialog, no second screen.
  ///
  /// The chip stays where it is afterwards. Removing it would make the undo
  /// snackbar's "Hoàn tác" restore into a gap, and a chip that vanishes on tap
  /// reads as a checklist item being ticked off — which this section is not
  /// (AC-25/AC-28).
  Future<ActivityCard> accept(NextPlanSuggestion suggestion) =>
      service.accept(suggestion);

  Future<void> undo(ActivityCard card) => service.undo(card);
}
