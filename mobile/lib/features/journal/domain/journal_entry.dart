/// Where an entry came from (`architecture/solution.md` §4 Entry Data Model).
/// `external` marks an entry the user saved from another surface's composer
/// seed; it never means the app wrote the entry by itself (BR-5).
enum JournalEntryOrigin {
  manual,
  external;

  static JournalEntryOrigin fromStorage(String value) {
    return value == external.name ? external : manual;
  }
}

/// One photo attached to a [JournalEntry].
class JournalEntryPhoto {
  const JournalEntryPhoto({
    required this.id,
    required this.relativePath,
    required this.sortIndex,
    required this.createdAt,
  });

  final String id;

  /// Relative to the journal media root, never absolute — resolve it through
  /// `JournalMediaStore`, which owns that root.
  final String relativePath;

  final int sortIndex;

  /// Epoch milliseconds UTC.
  final int createdAt;
}

/// Plain-Dart domain model for a private journal entry. This repo has no
/// `freezed`, so equality is deliberately identity-based; nothing compares
/// entries by value.
///
/// There is no `deletedAt`, no counter, and no share state here on purpose
/// (BR-2, BR-4) — the absence is the requirement, not an omission to fill in.
class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.ownerUserId,
    required this.bodyText,
    required this.createdAt,
    required this.updatedAt,
    this.origin = JournalEntryOrigin.manual,
    this.originRef,
    this.photos = const <JournalEntryPhoto>[],
  });

  /// UUID v4 generated on device, stable for the entry's whole life: editing
  /// rewrites this id's row rather than minting a new one (AC-3).
  final String id;

  /// Backend `User.id`. Every read and write filters on it — it is the only
  /// isolation between two accounts sharing one device.
  final String ownerUserId;

  /// May be empty when the entry carries only photos.
  final String bodyText;

  /// Epoch milliseconds UTC; descending sort key of the entry list.
  final int createdAt;

  /// Epoch milliseconds UTC.
  final int updatedAt;

  final JournalEntryOrigin origin;

  /// Opaque provenance tag set by the calling story. Stored only — never
  /// rendered, never parsed, never turned into a link.
  final String? originRef;

  final List<JournalEntryPhoto> photos;

  JournalEntry copyWith({
    String? ownerUserId,
    String? bodyText,
    int? updatedAt,
    List<JournalEntryPhoto>? photos,
  }) {
    return JournalEntry(
      id: id,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      bodyText: bodyText ?? this.bodyText,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      origin: origin,
      originRef: originRef,
      photos: photos ?? this.photos,
    );
  }
}
