import '../../../core/content/content_package.dart';
import 'gift_content.dart';

/// The three shipped gift packs held together as one value
/// (`architecture/contract-summary.md` §2).
///
/// Branch and effort-tier lists are read off the taxonomy pack rather than
/// declared here, so a pack that ships a fourth branch or a fifth effort tier
/// changes what the flow offers without a Dart edit (AC-32/AC-34, R-15a).
class GiftCatalogue {
  GiftCatalogue({
    required this.gifts,
    required this.giftIndex,
    required this.taxonomy,
  });

  final ContentPackage<GiftIdea> gifts;
  final ContentPackage<GiftIndexRow> giftIndex;
  final ContentPackage<GiftTaxonomyItem> taxonomy;

  /// In pack order, which is the order the author chose. Never sorted by label:
  /// a locale-dependent sort would make the chip row differ between devices.
  late final List<GiftTaxonomyItem> branches =
      _itemsOfKind(GiftTaxonomyKind.branch);

  late final List<GiftTaxonomyItem> effortTiers =
      _itemsOfKind(GiftTaxonomyKind.effortTier);

  GiftTaxonomyItem? taxonomyItemById(String id) => taxonomy.itemById(id);

  List<GiftTaxonomyItem> _itemsOfKind(GiftTaxonomyKind kind) =>
      List<GiftTaxonomyItem>.unmodifiable(
        taxonomy.items.where((GiftTaxonomyItem item) => item.kind == kind),
      );
}

/// One thing the user wrote down, in the shape the index is keyed by.
class GiftContextValue {
  const GiftContextValue({
    required this.kind,
    required this.key,
    required this.label,
  });

  final GiftContextKind kind;

  /// What a [GiftIndexRow.value] is compared against: the recorded notebook
  /// text for the two notebook kinds, the durable seed id for a skill.
  final String key;

  /// What the user sees. Differs from [key] on a skill, where the pack keys by
  /// seed id but the reader recognises their own wording.
  final String label;
}

/// Everything the selector is allowed to personalise from.
///
/// A snapshot, not a live handle: the selector cannot re-read, cannot write,
/// and cannot ask for more, so no prefill path can grow out of the gift flow
/// (`architecture/contract-summary.md` §6).
class GiftContextSnapshot {
  const GiftContextSnapshot({required this.values});

  /// The normal starting state of a new reader, and a fully supported one:
  /// suggestions still come back (AC-15).
  static const GiftContextSnapshot empty =
      GiftContextSnapshot(values: <GiftContextValue>[]);

  final List<GiftContextValue> values;

  bool get isEmpty => values.isEmpty;
}

/// The branch and effort choices currently on screen. Both are pack item ids,
/// never Dart enum values (R-15a/AC-34).
class GiftFilter {
  const GiftFilter({this.branchId, this.effortTierId});

  static const GiftFilter none = GiftFilter();

  final String? branchId;

  /// Read as a ceiling, not an equality: picking "một tới hai giờ" keeps
  /// everything that fits inside two hours, which is what AC-17 asks of the
  /// "làm được trong 2 tiếng tối nay" filter.
  final String? effortTierId;
}

/// Why one idea surfaced: the exact thing the user wrote that led to it.
class GiftContextMatch {
  const GiftContextMatch({required this.indexRowId, required this.context});

  final String indexRowId;
  final GiftContextValue context;
}

/// One ranked idea, carrying what it was derived from so the screen can say so
/// (AC-14) and can name the skill behind a handmade idea (AC-20).
class GiftSuggestion {
  const GiftSuggestion({
    required this.idea,
    required this.branch,
    required this.effortTier,
    required this.matches,
  });

  final GiftIdea idea;

  /// `null` only when a pack points at a branch or tier the taxonomy does not
  /// declare, which the ship gate already rejects.
  final GiftTaxonomyItem? branch;
  final GiftTaxonomyItem? effortTier;

  /// Empty is normal: an idea with nothing behind it is still a usable general
  /// suggestion, not a degraded one.
  final List<GiftContextMatch> matches;

  /// How many recorded things led here — [matches] counted, nothing more.
  ///
  /// Ranking weight only, never rendered: a visible number here would be the
  /// progress or match-percentage indicator AC-33 forbids. There is
  /// deliberately no per-kind weighting, because "an event outranks an
  /// interest" is an editorial judgement, and editorial judgement belongs in
  /// the packs the out-of-repo CMS owns, not in Dart (R-15a).
  int get score => matches.length;

  int? get effortMinutes => effortTier?.maxMinutes;
}

/// Turns recorded context plus the on-screen filters into an ordered list of
/// ideas.
///
/// Deterministic by construction: no clock, no randomness, no network, no
/// model call, and no reliance on hash iteration order. The same recorded
/// state and the same filters produce the same list in the same order, in this
/// process run and in the next one (AC-28).
class GiftSelector {
  const GiftSelector();

  /// On the handmade branch this is what "intersect context with the skill
  /// profile" means: a skill the user listed lifts the ideas the packs tie to
  /// it, while an empty profile leaves every handmade idea level and still
  /// returns all of them. Intersection expressed as ranking, never as a gate —
  /// a gate here is the empty screen AC-13 forbids.
  List<GiftSuggestion> suggest({
    required GiftCatalogue catalogue,
    required GiftContextSnapshot context,
    GiftFilter filter = GiftFilter.none,
  }) {
    final Map<String, List<GiftContextMatch>> matchesByGiftId =
        _matchesByGiftId(catalogue, context);

    final List<GiftSuggestion> suggestions = <GiftSuggestion>[];
    for (final GiftIdea idea in catalogue.gifts.items) {
      if (!_passesFilter(catalogue, idea, filter)) {
        continue;
      }
      final List<GiftContextMatch> matches =
          matchesByGiftId[idea.id] ?? const <GiftContextMatch>[];
      suggestions.add(
        GiftSuggestion(
          idea: idea,
          branch: catalogue.taxonomyItemById(idea.branchId),
          effortTier: catalogue.taxonomyItemById(idea.effortTierId),
          matches: List<GiftContextMatch>.unmodifiable(matches),
        ),
      );
    }

    // Total order: ids are unique within a pack, so no pair of entries ever
    // compares equal and the unstable sort cannot reorder equal-scored ideas
    // between two runs.
    suggestions.sort(
      (GiftSuggestion a, GiftSuggestion b) => a.score == b.score
          ? a.idea.id.compareTo(b.idea.id)
          : b.score.compareTo(a.score),
    );

    return List<GiftSuggestion>.unmodifiable(suggestions);
  }

  /// [size] ideas starting at [cursor], wrapping around the end of [ranked].
  ///
  /// Running out is not a state this flow has: the cursor rolls over modulo the
  /// list length, so there is no "đã hết ý tưởng" message, no dead-end screen,
  /// and no remaining-count to show (AC-33). [cursor] belongs to the screen
  /// lifetime of the caller and is never persisted
  /// (`architecture/contract-summary.md` §6).
  ///
  /// A batch never repeats an idea, so a pack of one yields one, and the same
  /// call at any [cursor] works for a pack of any size (R-15b).
  List<GiftSuggestion> nextBatch(
    List<GiftSuggestion> ranked, {
    required int cursor,
    required int size,
  }) {
    if (ranked.isEmpty) {
      return const <GiftSuggestion>[];
    }

    final int length = ranked.length;
    final int take = size < length ? size : length;
    // The Dart `%` operator is non-negative for a positive divisor, so a
    // cursor that ran backwards still lands inside the list.
    final int start = cursor % length;

    return List<GiftSuggestion>.unmodifiable(
      List<GiftSuggestion>.generate(
        take,
        (int offset) => ranked[(start + offset) % length],
      ),
    );
  }

  /// Walks the index in pack order, so a gift's reasons always arrive in the
  /// same order regardless of the order the user wrote things down.
  Map<String, List<GiftContextMatch>> _matchesByGiftId(
    GiftCatalogue catalogue,
    GiftContextSnapshot context,
  ) {
    final Map<String, List<GiftContextMatch>> matches =
        <String, List<GiftContextMatch>>{};

    for (final GiftIndexRow row in catalogue.giftIndex.items) {
      final GiftContextValue? matched = _contextFor(row, context);
      if (matched == null) {
        continue;
      }
      final GiftContextMatch match =
          GiftContextMatch(indexRowId: row.id, context: matched);
      for (final String giftId in row.giftIds) {
        matches.putIfAbsent(giftId, () => <GiftContextMatch>[]).add(match);
      }
    }

    return matches;
  }

  /// The first recorded value this row is keyed by, or `null` when the user has
  /// written nothing that reaches it.
  GiftContextValue? _contextFor(
    GiftIndexRow row,
    GiftContextSnapshot context,
  ) {
    final String key = _normalise(row.value);
    for (final GiftContextValue value in context.values) {
      if (value.kind == row.contextKind && _normalise(value.key) == key) {
        return value;
      }
    }
    return null;
  }

  bool _passesFilter(
    GiftCatalogue catalogue,
    GiftIdea idea,
    GiftFilter filter,
  ) {
    final String? branchId = filter.branchId;
    if (branchId != null && idea.branchId != branchId) {
      return false;
    }

    final String? effortTierId = filter.effortTierId;
    if (effortTierId == null) {
      return true;
    }

    final int? ceiling = catalogue.taxonomyItemById(effortTierId)?.maxMinutes;
    final int? cost = catalogue.taxonomyItemById(idea.effortTierId)?.maxMinutes;
    if (ceiling == null || cost == null) {
      return false;
    }
    return cost <= ceiling;
  }

  String _normalise(String raw) => raw.trim().toLowerCase();
}
