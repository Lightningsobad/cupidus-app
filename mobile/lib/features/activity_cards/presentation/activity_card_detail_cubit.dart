import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/activity_card.dart';
import '../domain/activity_type.dart';
import '../domain/activity_card_repository.dart';
import '../domain/time_of_day_slot.dart';

/// The two branches of the *Đã hẹn ngày → Mới nghĩ ra* regression question
/// (AC-15, `ux/uiux-spec.md` §5). Two values, no third, and no default:
/// [ActivityCardDetailCubit.changeStatus] parks the transition until the user
/// names one of them, so nothing is dropped by a tap the user did not make.
enum ScheduledDateChoice { keep, clear }

class ActivityCardDetailState {
  const ActivityCardDetailState({
    required this.card,
    this.pendingRegression,
    this.deleted = false,
    this.failed = false,
  });

  final ActivityCard card;

  /// The status a regression is waiting on. Non-null means the AC-15 question
  /// has been asked and not yet answered; nothing has been written for it.
  final ActivityCardStatus? pendingRegression;
  final bool deleted;
  final bool failed;

  /// *Đã đi rồi* — the "ghi lại" mode of this screen (SC-4).
  bool get isRecording => card.status == ActivityCardStatus.done;

  /// *Đã thành kỷ niệm* — the "xem lại" mode (AC-13). Still carries the delete
  /// path, so it is a mode of this screen and not a dead end.
  bool get isReviewing => card.status == ActivityCardStatus.memory;

  ActivityCardDetailState copyWith({
    ActivityCard? card,
    ActivityCardStatus? pendingRegression,
    bool clearPendingRegression = false,
    bool? deleted,
    bool? failed,
  }) {
    return ActivityCardDetailState(
      card: card ?? this.card,
      pendingRegression: clearPendingRegression
          ? null
          : pendingRegression ?? this.pendingRegression,
      deleted: deleted ?? this.deleted,
      failed: failed ?? this.failed,
    );
  }
}

/// Drives one card's detail screen: the SB-76 fields, the two-way lifecycle,
/// and the delete path.
///
/// Persistence boundary, stated once here so no caller has to guess it. Every
/// public mutator on this cubit reaches the store: field edits go through
/// `updateCardDetails` (P8), the lifecycle through `updateStatus` and
/// `clearScheduledDate`, and removal through `deleteCard`. Nothing is held as
/// screen-local state that a restart would drop.
///
/// The store is written *before* the new card is emitted, never after, so
/// [ActivityCardDetailState.card] can never claim a value the store does not
/// hold. A write that throws or reports zero rows leaves the card exactly as it
/// was and raises [ActivityCardDetailState.failed].
///
/// When each write happens is the caller's call, not this cubit's: a discrete
/// control (chip, toggle, picker) calls its mutator the moment it settles,
/// while a text field commits on submit or blur rather than per keystroke.
class ActivityCardDetailCubit extends Cubit<ActivityCardDetailState> {
  ActivityCardDetailCubit({
    required ActivityCardRepository repository,
    required ActivityCard card,
  })  : _repository = repository,
        super(ActivityCardDetailState(card: card));

  final ActivityCardRepository _repository;

  /// AC-12 in one gesture: the picked civil date is recorded and the card
  /// moves to *Đã hẹn ngày*, so it lands in that pane without a second step.
  ///
  /// The date is written first and the status second. That order is what makes
  /// AC-15 work later: `_needsScheduledDateQuestion` reads a `scheduled_on`
  /// that is really in the store, so a regression next week still finds a date
  /// to ask about.
  Future<void> scheduleDate(String scheduledOn) async {
    if (!await _persist(scheduledOn: scheduledOn)) {
      return;
    }
    await _writeStatus(ActivityCardStatus.scheduled);
  }

  /// AC-14: any of the four statuses, in either direction. The single guarded
  /// case is the regression that would strand a saved date — it is parked for
  /// [resolveRegression] instead of being written here.
  Future<void> changeStatus(ActivityCardStatus next) async {
    if (next == state.card.status) {
      return;
    }
    if (_needsScheduledDateQuestion(next)) {
      emit(state.copyWith(pendingRegression: next));
      return;
    }
    await _writeStatus(next);
  }

  /// Answers the AC-15 question. [ScheduledDateChoice.keep] writes only the
  /// status column, so the saved date, the note and the card's photo rows are
  /// all untouched; [ScheduledDateChoice.clear] is the only path that drops
  /// the date, and only because the user said so.
  Future<void> resolveRegression(ScheduledDateChoice choice) async {
    final ActivityCardStatus? next = state.pendingRegression;
    if (next == null) {
      return;
    }
    emit(state.copyWith(clearPendingRegression: true));
    if (choice == ScheduledDateChoice.clear) {
      final int rows;
      try {
        rows = await _repository.clearScheduledDate(state.card.id);
      } on Object {
        if (isClosed) {
          return;
        }
        emit(state.copyWith(failed: true));
        return;
      }
      if (isClosed) {
        return;
      }
      // Zero rows is "not this owner's card". Moving the status on top of a
      // date that is still in the store is the data loss AC-15 exists to
      // prevent, so the whole answer stops here.
      if (rows == 0) {
        emit(state.copyWith(failed: true));
        return;
      }
      _emitCard(scheduledOn: null, clearScheduledOn: true);
    }
    await _writeStatus(next);
  }

  /// Dismissing the question leaves the card exactly as it was — the safe
  /// branch is what happens when the user does nothing.
  void cancelRegression() {
    if (state.pendingRegression == null) {
      return;
    }
    emit(state.copyWith(clearPendingRegression: true));
  }

  /// AC-17/AC-18: "đã rủ" is a two-value flag the user sets by hand. No
  /// timestamp is recorded beside it and nothing infers it.
  Future<void> toggleInvited() => _persist(invited: !state.card.invited);

  Future<void> toggleReplyState() => _persist(
        replyState: state.card.replyState == ActivityCardReplyState.answered
            ? ActivityCardReplyState.notAnswered
            : ActivityCardReplyState.answered,
      );

  Future<void> editTitle(String title) => _persist(title: title);

  Future<void> editNote(String? note) =>
      _persist(note: note, clearNote: note == null);

  /// B-1's `note_keywords`. One comma-separated string, never a list on this
  /// gate — [formatNoteKeywords] owns the encoding (`vi_field_format.dart`),
  /// and an empty selection arrives here as `null`, never as `''`.
  Future<void> editNoteKeywords(String? noteKeywords) => _persist(
        noteKeywords: noteKeywords,
        clearNoteKeywords: noteKeywords == null,
      );

  /// Writes the link and its provenance stamp in one snapshot: §13.4 makes
  /// `link_saved_at` a consequence of the link changing, so the two columns
  /// can never be persisted a round apart.
  Future<void> editSourceLink(String? sourceLink) {
    final String? current = state.card.sourceLink;
    final bool cleared = sourceLink == null || sourceLink.isEmpty;
    final bool changed = sourceLink != current;
    if (cleared) {
      return _persist(
        sourceLink: null,
        clearSourceLink: true,
        linkSavedAt: null,
        clearLinkSavedAt: true,
      );
    }
    if (!changed) {
      return _persist(sourceLink: sourceLink);
    }
    return _persist(
      sourceLink: sourceLink,
      linkSavedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// B-1's `link_source_label`. AC/contract rule: the label is what the user
  /// says the link is, never something parsed back out of the URL
  /// (`contract-summary.md` line 80).
  Future<void> editLinkSourceLabel(String? linkSourceLabel) => _persist(
        linkSourceLabel: linkSourceLabel,
        clearLinkSourceLabel: linkSourceLabel == null,
      );

  /// B-1's `location` (AC-4), the free-text place the invite composer reads as
  /// its `{place}` variable. An emptied field arrives as `null`, never as `''`,
  /// so it clears the column instead of storing a place nobody typed.
  Future<void> editLocation(String? location) =>
      _persist(location: location, clearLocation: location == null);

  Future<void> editActivityType(ActivityType? activityType) => _persist(
        activityType: activityType,
        clearActivityType: activityType == null,
      );

  Future<void> editPriceVnd(int? priceVnd) =>
      _persist(priceVnd: priceVnd, clearPriceVnd: priceVnd == null);

  Future<void> editDistanceKm(double? distanceKm) =>
      _persist(distanceKm: distanceKm, clearDistanceKm: distanceKm == null);

  /// B-1's `duration_minutes`, in minutes — never a formatted string. A-2 puts
  /// `2 tiếng` on screen and `120` on this gate (`vi_field_format.dart`).
  Future<void> editDurationMinutes(int? durationMinutes) => _persist(
        durationMinutes: durationMinutes,
        clearDurationMinutes: durationMinutes == null,
      );

  /// B-1's `time_of_day_slot`. *Chưa rõ* is a real answer, so it arrives as
  /// `null` and clears the column. Nothing derives it from `scheduled_on`: a
  /// date says which day, never which part of the day.
  Future<void> editTimeOfDaySlot(TimeOfDaySlot? timeOfDaySlot) => _persist(
        timeOfDaySlot: timeOfDaySlot,
        clearTimeOfDaySlot: timeOfDaySlot == null,
      );

  Future<void> editNeedsBooking(bool? needsBooking) => _persist(
        needsBooking: needsBooking,
        clearNeedsBooking: needsBooking == null,
      );

  Future<void> editIndoorOutdoor(ActivityCardIndoorOutdoor? indoorOutdoor) =>
      _persist(
        indoorOutdoor: indoorOutdoor,
        clearIndoorOutdoor: indoorOutdoor == null,
      );

  Future<void> editScheduledOn(String? scheduledOn) =>
      _persist(scheduledOn: scheduledOn, clearScheduledOn: scheduledOn == null);

  /// AC-16. Available in every mode including *Đã thành kỷ niệm*, which is
  /// what keeps that mode from being a dead end (AC-13). The card's photo rows
  /// go with it through the `ON DELETE CASCADE` the schema declares.
  Future<void> deleteCard() async {
    final int rows;
    try {
      rows = await _repository.deleteCard(state.card.id);
    } on Object {
      if (isClosed) {
        return;
      }
      emit(state.copyWith(failed: true));
      return;
    }
    if (isClosed) {
      return;
    }
    if (rows == 0) {
      emit(state.copyWith(failed: true));
      return;
    }
    emit(state.copyWith(deleted: true));
  }

  /// Only this pair strands data: leaving *Đã hẹn ngày* for *Mới nghĩ ra*
  /// while a date is saved. Every other transition keeps every column by
  /// contract, so asking about them would be a confirmation habit rather than
  /// a real question.
  bool _needsScheduledDateQuestion(ActivityCardStatus next) =>
      state.card.status == ActivityCardStatus.scheduled &&
      next == ActivityCardStatus.idea &&
      state.card.scheduledOn != null;

  Future<void> _writeStatus(ActivityCardStatus next) async {
    final int rows;
    try {
      rows = await _repository.updateStatus(state.card.id, next);
    } on Object {
      if (isClosed) {
        return;
      }
      emit(state.copyWith(failed: true));
      return;
    }
    if (isClosed) {
      return;
    }
    if (rows == 0) {
      emit(state.copyWith(failed: true));
      return;
    }
    _emitCard(status: next);
  }

  /// Writes one field change through `updateCardDetails` and emits the new card
  /// only once the store has taken it. Returns whether the write landed, so a
  /// two-step operation like [scheduleDate] can stop instead of moving the
  /// status over a date that was never saved.
  Future<bool> _persist({
    String? title,
    ActivityType? activityType,
    bool clearActivityType = false,
    String? scheduledOn,
    bool clearScheduledOn = false,
    int? priceVnd,
    bool clearPriceVnd = false,
    double? distanceKm,
    bool clearDistanceKm = false,
    bool? needsBooking,
    bool clearNeedsBooking = false,
    ActivityCardIndoorOutdoor? indoorOutdoor,
    bool clearIndoorOutdoor = false,
    String? note,
    bool clearNote = false,
    String? sourceLink,
    bool clearSourceLink = false,
    int? durationMinutes,
    bool clearDurationMinutes = false,
    TimeOfDaySlot? timeOfDaySlot,
    bool clearTimeOfDaySlot = false,
    String? noteKeywords,
    bool clearNoteKeywords = false,
    String? linkSourceLabel,
    bool clearLinkSourceLabel = false,
    int? linkSavedAt,
    bool clearLinkSavedAt = false,
    String? location,
    bool clearLocation = false,
    bool? invited,
    ActivityCardReplyState? replyState,
  }) async {
    if (isClosed) {
      return false;
    }
    final ActivityCard next = _withEdits(
      title: title,
      activityType: activityType,
      clearActivityType: clearActivityType,
      scheduledOn: scheduledOn,
      clearScheduledOn: clearScheduledOn,
      priceVnd: priceVnd,
      clearPriceVnd: clearPriceVnd,
      distanceKm: distanceKm,
      clearDistanceKm: clearDistanceKm,
      needsBooking: needsBooking,
      clearNeedsBooking: clearNeedsBooking,
      indoorOutdoor: indoorOutdoor,
      clearIndoorOutdoor: clearIndoorOutdoor,
      note: note,
      clearNote: clearNote,
      sourceLink: sourceLink,
      clearSourceLink: clearSourceLink,
      durationMinutes: durationMinutes,
      clearDurationMinutes: clearDurationMinutes,
      timeOfDaySlot: timeOfDaySlot,
      clearTimeOfDaySlot: clearTimeOfDaySlot,
      noteKeywords: noteKeywords,
      clearNoteKeywords: clearNoteKeywords,
      linkSourceLabel: linkSourceLabel,
      clearLinkSourceLabel: clearLinkSourceLabel,
      linkSavedAt: linkSavedAt,
      clearLinkSavedAt: clearLinkSavedAt,
      location: location,
      clearLocation: clearLocation,
      invited: invited,
      replyState: replyState,
    );
    final int rows;
    try {
      rows = await _repository.updateCardDetails(
        next.id,
        ActivityCardEdit.from(next),
      );
    } on Object {
      if (isClosed) {
        return false;
      }
      emit(state.copyWith(failed: true));
      return false;
    }
    if (isClosed) {
      return false;
    }
    if (rows == 0) {
      emit(state.copyWith(failed: true));
      return false;
    }
    emit(state.copyWith(card: next));
    return true;
  }

  /// In-memory only, for the two writers that own their own column and have
  /// already run: [_writeStatus] and the `clearScheduledDate` branch of
  /// [resolveRegression].
  void _emitCard({
    ActivityCardStatus? status,
    String? scheduledOn,
    bool clearScheduledOn = false,
  }) {
    if (isClosed) {
      return;
    }
    emit(
      state.copyWith(
        card: _withEdits(
          status: status,
          scheduledOn: scheduledOn,
          clearScheduledOn: clearScheduledOn,
        ),
      ),
    );
  }

  ActivityCard _withEdits({
    String? title,
    ActivityCardStatus? status,
    ActivityType? activityType,
    bool clearActivityType = false,
    String? scheduledOn,
    bool clearScheduledOn = false,
    int? priceVnd,
    bool clearPriceVnd = false,
    double? distanceKm,
    bool clearDistanceKm = false,
    bool? needsBooking,
    bool clearNeedsBooking = false,
    ActivityCardIndoorOutdoor? indoorOutdoor,
    bool clearIndoorOutdoor = false,
    String? note,
    bool clearNote = false,
    String? sourceLink,
    bool clearSourceLink = false,
    int? durationMinutes,
    bool clearDurationMinutes = false,
    TimeOfDaySlot? timeOfDaySlot,
    bool clearTimeOfDaySlot = false,
    String? noteKeywords,
    bool clearNoteKeywords = false,
    String? linkSourceLabel,
    bool clearLinkSourceLabel = false,
    int? linkSavedAt,
    bool clearLinkSavedAt = false,
    String? location,
    bool clearLocation = false,
    bool? invited,
    ActivityCardReplyState? replyState,
  }) {
    final ActivityCard card = state.card;
    return ActivityCard(
      id: card.id,
      ownerKey: card.ownerKey,
      title: title ?? card.title,
      status: status ?? card.status,
      origin: card.origin,
      activityType:
          clearActivityType ? null : activityType ?? card.activityType,
      scheduledOn: clearScheduledOn ? null : scheduledOn ?? card.scheduledOn,
      priceVnd: clearPriceVnd ? null : priceVnd ?? card.priceVnd,
      distanceKm: clearDistanceKm ? null : distanceKm ?? card.distanceKm,
      needsBooking:
          clearNeedsBooking ? null : needsBooking ?? card.needsBooking,
      indoorOutdoor:
          clearIndoorOutdoor ? null : indoorOutdoor ?? card.indoorOutdoor,
      note: clearNote ? null : note ?? card.note,
      sourceLink: clearSourceLink ? null : sourceLink ?? card.sourceLink,
      durationMinutes:
          clearDurationMinutes ? null : durationMinutes ?? card.durationMinutes,
      // Every B-1 column now has an editor, but the carry-forward below is not
      // redundant: `_persist` hands the result to `updateCardDetails` as a full
      // snapshot, where a missing field is an instruction to clear the column.
      // Dropping any of these would make every unrelated edit — one character
      // typed into the note — silently erase them.
      timeOfDaySlot:
          clearTimeOfDaySlot ? null : timeOfDaySlot ?? card.timeOfDaySlot,
      noteKeywords: clearNoteKeywords ? null : noteKeywords ?? card.noteKeywords,
      linkSourceLabel: clearLinkSourceLabel
          ? null
          : linkSourceLabel ?? card.linkSourceLabel,
      // `link_saved_at` is derived, never typed: only [editSourceLink] passes a
      // value, and it does so in the same snapshot as the link itself (§13.4).
      linkSavedAt: clearLinkSavedAt ? null : linkSavedAt ?? card.linkSavedAt,
      location: clearLocation ? null : location ?? card.location,
      invited: invited ?? card.invited,
      replyState: replyState ?? card.replyState,
      createdAt: card.createdAt,
      // `updated_at` belongs to the repository, which owns normalization and
      // timestamps (`contract-summary.md` §3). A screen-local edit does not
      // get to invent one, so this carries the old value until the next read.
      updatedAt: card.updatedAt,
    );
  }
}
