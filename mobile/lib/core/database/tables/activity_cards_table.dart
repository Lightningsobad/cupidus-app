import 'package:drift/drift.dart';

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

  TextColumn get activityType => text().nullable()();

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
