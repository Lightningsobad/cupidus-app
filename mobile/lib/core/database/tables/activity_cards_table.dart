import 'package:drift/drift.dart';

import '../../../features/activity_cards/domain/activity_type.dart';
import '../../../features/activity_cards/domain/time_of_day_slot.dart';

/// Re-exported because `cupid_database.g.dart` is a `part` of
/// `cupid_database.dart` and names [ActivityType] in the generated row type,
/// so the symbol has to reach that library through an import it already has.
export '../../../features/activity_cards/domain/activity_type.dart';

/// Same reason as [ActivityType] above: [TimeOfDaySlot] appears in the
/// generated row type.
export '../../../features/activity_cards/domain/time_of_day_slot.dart';

/// Maps the closed [ActivityType] vocabulary onto the column's unchanged
/// `TEXT NULL` storage. No DDL and no `schemaVersion` bump: only the Dart type
/// moves, so the drop-and-recreate ban below still holds trivially.
///
/// Reads are lenient by way of [activityTypeFromWireValue] — a row written
/// before the vocabulary existed keeps its other fields and simply reads back
/// as `null`. Writes always emit the canonical ASCII wire value.
class ActivityTypeConverter extends TypeConverter<ActivityType?, String?> {
  const ActivityTypeConverter();

  @override
  ActivityType? fromSql(String? fromDb) => activityTypeFromWireValue(fromDb);

  @override
  String? toSql(ActivityType? value) => value?.wireValue;
}

/// Maps the closed [TimeOfDaySlot] vocabulary (ruling B-1) onto a `TEXT NULL`
/// column, mirroring [ActivityTypeConverter].
///
/// Reads go through [timeOfDaySlotFromWireValue], so every row written before
/// schema v4 reads back as `null` instead of throwing.
class TimeOfDaySlotConverter extends TypeConverter<TimeOfDaySlot?, String?> {
  const TimeOfDaySlotConverter();

  @override
  TimeOfDaySlot? fromSql(String? fromDb) => timeOfDaySlotFromWireValue(fromDb);

  @override
  String? toSql(TimeOfDaySlot? value) => value?.wireValue;
}

/// Client-owned solo data — NOT a read-through cache.
///
/// Every other table in this database follows ADR-007 ("Drift is a cache, the
/// server is the source of truth"), which makes a destructive drop-and-recreate
/// migration harmless. This table is the exception: REQ-016 has no backend
/// counterpart, so these rows are the only copy that exists and a
/// drop-and-recreate would permanently destroy the user's own data
/// (`architecture/solution.md` §1 Key Discovery). Future schema bumps must use
/// additive migrations here.
///
/// Multi-user isolation on a shared device is done with [ownerKey] on every
/// query, never by wiping the table on sign-out: this DAO deliberately does not
/// implement `SessionScopedStore` (AC-22).
///
/// The column set is an exact allowlist (`architecture/contract-summary.md` §3)
/// and is enforced by test. Columns that measure the partner's behavior
/// (`partner_seen_at`, `opened_count`, `reply_latency`, ...) are forbidden by
/// R-1b (§4); `replyState` changes only on an explicit user tap.
@DataClassName('ActivityCardRow')
@TableIndex(name: 'activity_cards_owner_status', columns: {#ownerKey, #status})
class ActivityCards extends Table {
  /// Client-generated UUID v4, permanently stable. Never a rowid/autoincrement
  /// (R-15a) — later stories reference cards by this id.
  TextColumn get id => text()();

  /// Backend `User.id` of the session that created the card.
  TextColumn get ownerKey => text()();

  /// The single mandatory user-supplied field (AC-6).
  TextColumn get title => text()();

  /// One of `idea` | `scheduled` | `done` | `memory`.
  TextColumn get status => text().withDefault(const Constant('idea'))();

  /// Internal provenance identifier; never rendered as a metric (AC-9).
  TextColumn get origin => text()();

  TextColumn get activityType =>
      text().nullable().map(const ActivityTypeConverter())();

  /// Civil date `YYYY-MM-DD` in the device calendar — deliberately not a
  /// DateTime/instant, so it never shifts with the host's UTC offset.
  TextColumn get scheduledOn => text().nullable()();

  IntColumn get priceVnd => integer().nullable()();

  RealColumn get distanceKm => real().nullable()();

  /// Three-valued: null means "not known yet", not "false".
  BoolColumn get needsBooking => boolean().nullable()();

  TextColumn get indoorOutdoor => text().nullable()();

  TextColumn get note => text().nullable()();

  /// Raw URL as pasted by the user, kept verbatim (AC-7).
  TextColumn get sourceLink => text().nullable()();

  BoolColumn get invited => boolean().withDefault(const Constant(false))();

  /// `not_answered` | `answered` (R-1b).
  TextColumn get replyState =>
      text().withDefault(const Constant('not_answered'))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  /// Duration in **minutes** (B-1). The Vietnamese display string ("2 tiếng")
  /// is produced by the presentation formatter; a formatted string must never
  /// reach this column.
  IntColumn get durationMinutes => integer().nullable()();

  /// User-picked part of the day (B-1). Never inferred from [scheduledOn].
  TextColumn get timeOfDaySlot =>
      text().nullable().map(const TimeOfDaySlotConverter())();

  /// Short keyword list (B-1), a sibling of [note] rather than a replacement:
  /// [note] keeps its free-text meaning and is never migrated into here.
  TextColumn get noteKeywords => text().nullable()();

  /// Display name of the source shown next to [sourceLink] (B-1). Not derived
  /// from the URL.
  TextColumn get linkSourceLabel => text().nullable()();

  /// When the user pasted the link (B-1). INTEGER, not a `DateTimeColumn`, per
  /// the settled table in `ux/uiux-spec.md` §8.
  IntColumn get linkSavedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Memory photos copied into an app-owned directory, so deleting a card can
/// also clean up its files and the images do not vanish when the user tidies
/// the system gallery.
///
/// Same client-owned lifetime rules as [ActivityCards]: no destructive
/// migration.
@DataClassName('ActivityCardPhotoRow')
class ActivityCardPhotos extends Table {
  TextColumn get id => text()();

  TextColumn get cardId =>
      text().references(ActivityCards, #id, onDelete: KeyAction.cascade)();

  TextColumn get localPath => text()();

  IntColumn get sortIndex => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
