/// Card lifecycle stage. Wire values are the storage identifiers copied
/// verbatim from `architecture/contract-summary.md` §2 — ASCII, stable,
/// append-only (R-15a). Display labels are never hard-coded here; they come
/// from l10n key `cardStatus_<id>`.
enum ActivityCardStatus {
  idea('idea'),
  scheduled('scheduled'),
  done('done'),
  memory('memory');

  const ActivityCardStatus(this.wireValue);

  final String wireValue;

  static ActivityCardStatus fromWireValue(String value) =>
      values.firstWhere((status) => status.wireValue == value);
}

/// Provenance of a card (`architecture/contract-summary.md` §2), internal
/// only and never rendered as a metric (AC-9). Append-only: later stories add
/// new values here, never rename or remove an existing one.
enum ActivityCardOrigin {
  manual('manual'),
  pastedLink('pasted_link'),
  occasionSuggestion('occasion_suggestion');

  const ActivityCardOrigin(this.wireValue);

  final String wireValue;

  static ActivityCardOrigin fromWireValue(String value) =>
      values.firstWhere((origin) => origin.wireValue == value);
}

/// R-1b invite-reply flag. Changes only on an explicit user tap — never a
/// background process, inference, or accompanying timestamp.
enum ActivityCardReplyState {
  notAnswered('not_answered'),
  answered('answered');

  const ActivityCardReplyState(this.wireValue);

  final String wireValue;

  static ActivityCardReplyState fromWireValue(String value) =>
      values.firstWhere((state) => state.wireValue == value);
}

enum ActivityCardIndoorOutdoor {
  indoor('indoor'),
  outdoor('outdoor');

  const ActivityCardIndoorOutdoor(this.wireValue);

  final String wireValue;

  static ActivityCardIndoorOutdoor fromWireValue(String value) =>
      values.firstWhere((value_) => value_.wireValue == value);
}

/// One primary-action identifier per status (`ux/uiux-spec.md` §2, bảng
/// SC-4). Identifiers only — the Vietnamese label shown on the card footer
/// comes from l10n, never from this enum.
enum ActivityCardPrimaryAction {
  scheduleDate,
  prepare,
  recordMemory,
  review,
}

/// The single source mapping a status to its primary action (SC-4). Total
/// over [ActivityCardStatus]: every status resolves to exactly one action, so
/// no API built on top of this can ever surface two primary actions for one
/// card.
ActivityCardPrimaryAction primaryActionFor(ActivityCardStatus status) {
  switch (status) {
    case ActivityCardStatus.idea:
      return ActivityCardPrimaryAction.scheduleDate;
    case ActivityCardStatus.scheduled:
      return ActivityCardPrimaryAction.prepare;
    case ActivityCardStatus.done:
      return ActivityCardPrimaryAction.recordMemory;
    case ActivityCardStatus.memory:
      return ActivityCardPrimaryAction.review;
  }
}

/// One card in the activity card hub (`architecture/contract-summary.md`
/// §3). A missing optional field is a valid `null`, never an error — there is
/// no "soft required" field.
class ActivityCard {
  const ActivityCard({
    required this.id,
    required this.ownerKey,
    required this.title,
    required this.status,
    required this.origin,
    this.activityType,
    this.scheduledOn,
    this.priceVnd,
    this.distanceKm,
    this.needsBooking,
    this.indoorOutdoor,
    this.note,
    this.sourceLink,
    required this.invited,
    required this.replyState,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ownerKey;
  final String title;
  final ActivityCardStatus status;
  final ActivityCardOrigin origin;
  final String? activityType;

  /// Civil date `YYYY-MM-DD` in the device calendar, deliberately a plain
  /// string rather than a `DateTime`/instant (`contract-summary.md` §3).
  final String? scheduledOn;
  final int? priceVnd;
  final double? distanceKm;
  final bool? needsBooking;
  final ActivityCardIndoorOutdoor? indoorOutdoor;
  final String? note;

  /// Raw URL as pasted by the user, kept verbatim (AC-7).
  final String? sourceLink;
  final bool invited;
  final ActivityCardReplyState replyState;
  final DateTime createdAt;
  final DateTime updatedAt;
}

/// Draft for `createCard` — the sole write gate for the 11 consumer stories
/// (`architecture/contract-summary.md` §1). Only [title] and [origin] are
/// mandatory; every other field is optional, so a consumer's field-name
/// mismatch is a Dart compile error rather than silent data loss.
class NewActivityCard {
  const NewActivityCard({
    required this.title,
    required this.origin,
    this.activityType,
    this.scheduledOn,
    this.priceVnd,
    this.distanceKm,
    this.needsBooking,
    this.indoorOutdoor,
    this.note,
    this.sourceLink,
  });

  /// The single mandatory user-supplied field for most origins (AC-6). The
  /// paste-link flow (`ux/uiux-spec.md` §4a) may submit this blank; the
  /// repository derives a default from [sourceLink]'s host in that case
  /// (AC-7) — normalization and defaulting belong to the repository, never
  /// the UI (`contract-summary.md` §3).
  final String title;
  final ActivityCardOrigin origin;
  final String? activityType;
  final String? scheduledOn;
  final int? priceVnd;
  final double? distanceKm;
  final bool? needsBooking;
  final ActivityCardIndoorOutdoor? indoorOutdoor;
  final String? note;
  final String? sourceLink;
}
