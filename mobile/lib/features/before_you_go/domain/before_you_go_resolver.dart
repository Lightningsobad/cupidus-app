import '../../../core/content/content_package.dart';
import '../../activity_cards/domain/activity_card.dart';
import 'before_you_go_content.dart';

/// The closed fact set a checklist row is evaluated against. Every field is
/// nullable on purpose: a clause over a `null` fact is FALSE, so a sparse card
/// drops rows instead of inheriting defaults (BR-4/AC-9).
class BeforeYouGoFacts {
  const BeforeYouGoFacts({
    this.priceVnd,
    this.distanceKm,
    this.needsBooking,
    this.indoorOutdoor,
    this.rainySeason,
    this.regionId,
  });

  /// Builds the fact set from a card and a civil date. [today] is a parameter
  /// rather than a clock read inside this module, so the same inputs always
  /// resolve to the same rows (AC-10).
  factory BeforeYouGoFacts.fromCard(
    ActivityCard card, {
    required DateTime today,
    required List<RegionEntry> regions,
  }) {
    final RegionEntry? region = regionForLocation(card.location, regions);
    return BeforeYouGoFacts(
      priceVnd: card.priceVnd,
      distanceKm: card.distanceKm,
      needsBooking: card.needsBooking,
      indoorOutdoor: card.indoorOutdoor?.wireValue,
      rainySeason: region?.rainyMonths.contains(today.month),
      regionId: region?.id,
    );
  }

  final int? priceVnd;
  final double? distanceKm;
  final bool? needsBooking;
  final String? indoorOutdoor;

  /// `null` when no region could be derived from the card's free-text
  /// location — the app never guesses the weather (AC-11/BR-6).
  final bool? rainySeason;

  final String? regionId;

  Object? operator [](HintFact fact) {
    switch (fact) {
      case HintFact.always:
        return true;
      case HintFact.priceVnd:
        return priceVnd;
      case HintFact.distanceKm:
        return distanceKm;
      case HintFact.needsBooking:
        return needsBooking;
      case HintFact.indoorOutdoor:
        return indoorOutdoor;
      case HintFact.rainySeason:
        return rainySeason;
    }
  }
}

/// Derives a region by matching whole normalised token runs of [location]
/// against the shipped alias table. The longest matching alias wins, so a
/// province name is never shadowed by a shorter alias that happens to sit
/// inside the same string; ties fall to declaration order.
RegionEntry? regionForLocation(String? location, List<RegionEntry> regions) {
  if (location == null) {
    return null;
  }
  final String haystack = ' ${normalizeRegionText(location)} ';
  if (haystack.trim().isEmpty) {
    return null;
  }

  RegionEntry? best;
  int bestLength = 0;
  for (final RegionEntry region in regions) {
    for (final String alias in region.aliases) {
      if (alias.length > bestLength && haystack.contains(' $alias ')) {
        best = region;
        bestLength = alias.length;
      }
    }
  }
  return best;
}

/// Returns the rows that hold for [facts], ordered by `order` and stable when
/// two rows share one. Pure: no clock, no I/O, no network (AC-22/AC-23).
List<ChecklistHint> resolveHints({
  required ContentPackage<ChecklistHint> hints,
  required BeforeYouGoFacts facts,
}) {
  final List<ChecklistHint> matched = <ChecklistHint>[];
  final Map<String, int> declarationIndex = <String, int>{};
  for (int index = 0; index < hints.items.length; index++) {
    final ChecklistHint hint = hints.items[index];
    declarationIndex[hint.id] = index;
    if (hint.when.every((HintClause clause) => _clauseHolds(clause, facts))) {
      matched.add(hint);
    }
  }

  matched.sort((ChecklistHint a, ChecklistHint b) {
    final int byOrder = a.order.compareTo(b.order);
    if (byOrder != 0) {
      return byOrder;
    }
    return declarationIndex[a.id]!.compareTo(declarationIndex[b.id]!);
  });

  return List<ChecklistHint>.unmodifiable(matched);
}

bool _clauseHolds(HintClause clause, BeforeYouGoFacts facts) {
  final Object? factValue = facts[clause.field];
  if (factValue == null) {
    return false;
  }

  switch (clause.op) {
    case HintOp.isTrue:
      return factValue == true;
    case HintOp.isPresent:
      return true;
    case HintOp.eq:
      return factValue == clause.value;
    case HintOp.gt:
      return factValue is num &&
          clause.value is num &&
          factValue > (clause.value! as num);
    case HintOp.gte:
      return factValue is num &&
          clause.value is num &&
          factValue >= (clause.value! as num);
  }
}

/// `SharedPreferences` key holding the civil date on which the user dismissed
/// the block for one card (`contract-summary.md` §2). Nothing outside this
/// module reads it; STORY-012 reads [BeforeYouGoPhase] instead.
String beforeYouGoDismissedOnKey(String cardId) =>
    'before_you_go.dismissed_on.$cardId';

/// The readable "trước giờ đi" phase state STORY-012 draws
/// (`contract-summary.md` §4). A plain value object: no widget, no
/// `BuildContext`, and no drawing here (AC-24/BR-11).
class BeforeYouGoPhase {
  const BeforeYouGoPhase({
    required this.cardId,
    required this.dateIso,
    required this.isActive,
    required this.isDismissed,
  });

  factory BeforeYouGoPhase.fromCard(
    ActivityCard card, {
    required DateTime today,
    String? dismissedOnIso,
  }) {
    final String dateIso = civilDateIso(today);
    return BeforeYouGoPhase(
      cardId: card.id,
      dateIso: dateIso,
      isActive: card.status == ActivityCardStatus.scheduled &&
          card.scheduledOn == dateIso,
      isDismissed: dismissedOnIso == dateIso,
    );
  }

  final String cardId;
  final String dateIso;
  final bool isActive;
  final bool isDismissed;

  @override
  bool operator ==(Object other) =>
      other is BeforeYouGoPhase &&
      other.cardId == cardId &&
      other.dateIso == dateIso &&
      other.isActive == isActive &&
      other.isDismissed == isDismissed;

  @override
  int get hashCode => Object.hash(cardId, dateIso, isActive, isDismissed);

  @override
  String toString() => 'BeforeYouGoPhase($cardId, $dateIso, '
      'active: $isActive, dismissed: $isDismissed)';
}

/// `YYYY-MM-DD` in the device calendar, the same convention as
/// `ActivityCard.scheduledOn` — a civil date, never an instant.
String civilDateIso(DateTime date) {
  final String month = date.month.toString().padLeft(2, '0');
  final String day = date.day.toString().padLeft(2, '0');
  return '${date.year.toString().padLeft(4, '0')}-$month-$day';
}
