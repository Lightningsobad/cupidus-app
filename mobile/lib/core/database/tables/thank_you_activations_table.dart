import 'package:drift/drift.dart';

import 'activity_cards_table.dart';

/// The wire values of `thank_you_activations.status`, single-sourced here
/// because both `core/` readers and the `features/` vocabulary enum need them
/// and `core/` may not import `features/` (ADR-010).
///
/// Append-only: a value is already written into rows on real devices, so it is
/// never renamed and never reused for a different meaning.
abstract final class ThankYouActivationStatuses {
  static const String armed = 'armed';
  static const String consumed = 'consumed';
  static const String cancelled = 'cancelled';
}

/// The lifetime activation ledger for the "cảm ơn + chốt việc kế tiếp" block
/// (`architecture/solution.md` §4, BR-2).
///
/// One row per card, forever: [cardId] is the primary key, so the ledger can
/// express "this card already had its one turn" even after the card moves back
/// and forth between statuses (AC-4). [status] reaching `consumed` or
/// `cancelled` is absorbing — nothing in the lifecycle service writes `armed`
/// over an existing row.
///
/// Like `activity_cards` these rows are device-authoritative and exist on no
/// server, so every later migration touching them must be additive
/// (`architecture/solution.md` §1 Key Discovery).
///
/// The column set is a closed allowlist. AC-25 forbids turning a skipped block
/// into something the user can be shown as a shortfall, so `missed`, `skipped`,
/// `streak`, `reminder*`, `*count*` and every badge-shaped column are banned
/// permanently, and BR-3 bans an `expires_at` deadline.
@DataClassName('ThankYouActivationRow')
class ThankYouActivations extends Table {
  TextColumn get cardId =>
      text().references(ActivityCards, #id, onDelete: KeyAction.cascade)();

  /// `armed` | `consumed` | `cancelled`.
  TextColumn get status => text()();

  /// Civil date `YYYY-MM-DD` in the device calendar on the day the card entered
  /// *Đã đi rồi*. Deliberately not a DateTime/instant: AC-1 and AC-2 compare
  /// calendar days, so storing an instant would make the answer depend on the
  /// host's UTC offset rather than on the user's own date.
  TextColumn get armedOn => text()();

  /// Internal ordering only, never rendered and never compared against a
  /// deadline (BR-3).
  DateTimeColumn get consumedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {cardId};
}
