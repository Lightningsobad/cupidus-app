import '../../../core/content/content_package.dart';
import 'activity_card.dart';
import 'activity_card_repository.dart';

/// The shipped occasion package (`architecture/contract-summary.md` §2).
const String occasionsAssetKey = 'assets/data/req016/occasions.v1.json';
const String occasionsSchemaId = 'req016.occasions.v1';

/// AC-3 offers "1–2 gợi ý". The cap comes from that acceptance criterion, not
/// from the package size, so it stays correct at any N (R-15b).
const int maxOccasionSuggestions = 2;

/// One ready-to-create activity idea attached to an occasion.
class OccasionSuggestion {
  const OccasionSuggestion({
    required this.id,
    required this.title,
    this.activityType,
  });

  final String id;
  final String title;
  final String? activityType;
}

/// One occasion in the package. [dates] are civil `YYYY-MM-DD` dates resolved
/// by the content author for every calendar the occasion follows, so nothing
/// in this file converts between the lunar and solar calendars — [calendar] is
/// provenance only.
class Occasion implements ContentItem {
  const Occasion({
    required this.id,
    required this.name,
    required this.calendar,
    required this.dates,
    required this.suggestions,
  });

  @override
  final String id;

  /// Display label ("Rằm tháng Tám"). Comes from the package, never from Dart
  /// or l10n: occasion names are content, and content is data (R-15a).
  final String name;
  final String calendar;
  final List<String> dates;
  final List<OccasionSuggestion> suggestions;
}

Occasion occasionFromJson(Map<String, Object?> json, String source) {
  final suggestions = requireContentObjectList(json, 'suggestions', source)
      .map(
        (entry) => OccasionSuggestion(
          id: requireContentString(entry, 'id', source),
          title: requireContentString(entry, 'title', source),
          activityType: optionalContentString(entry, 'activity_type', source),
        ),
      )
      .toList(growable: false);
  if (suggestions.isEmpty) {
    throw ContentPackageFormatException(
      source,
      'occasion "${json['id']}" must carry at least one suggestion',
    );
  }
  return Occasion(
    id: requireContentString(json, 'id', source),
    name: requireContentString(json, 'name', source),
    calendar: requireContentString(json, 'calendar', source),
    dates: requireContentStringList(json, 'dates', source),
    suggestions: suggestions,
  );
}

Future<ContentPackage<Occasion>> loadOccasionPackage([
  ContentPackageLoader loader = const ContentPackageLoader(),
]) => loader.load<Occasion>(
  occasionsAssetKey,
  expectedSchemaId: occasionsSchemaId,
  itemParser: occasionFromJson,
);

/// The nearest upcoming occasion plus the suggestions offered for it.
class OccasionPrompt {
  const OccasionPrompt({
    required this.occasion,
    required this.date,
    required this.suggestions,
  });

  /// Carried whole so the screen reads `name` and `calendar` off the package
  /// instead of re-deriving either in Dart.
  final Occasion occasion;

  /// Civil `YYYY-MM-DD` date in the device calendar.
  final String date;
  final List<OccasionSuggestion> suggestions;

  String get occasionId => occasion.id;
}

/// AC-3/AC-5: picks occasion suggestions out of the shipped package and turns
/// a chosen one into an `idea` card, asking for no further field.
class OccasionSuggestionService {
  const OccasionSuggestionService({required ActivityCardRepository repository})
    : _repository = repository;

  final ActivityCardRepository _repository;

  /// Pure over (device date, package): same inputs always give the same
  /// prompt. Returns `null` when the package holds no date on or after
  /// [deviceDate], including for an empty package.
  static OccasionPrompt? nearestOccasion({
    required DateTime deviceDate,
    required ContentPackage<Occasion> package,
  }) {
    final today = civilDate(deviceDate);
    Occasion? bestOccasion;
    String? bestDate;
    for (final occasion in package.items) {
      for (final date in occasion.dates) {
        if (date.compareTo(today) < 0) {
          continue;
        }
        if (bestDate == null ||
            date.compareTo(bestDate) < 0 ||
            (date == bestDate && occasion.id.compareTo(bestOccasion!.id) < 0)) {
          bestOccasion = occasion;
          bestDate = date;
        }
      }
    }
    if (bestOccasion == null || bestDate == null) {
      return null;
    }
    return OccasionPrompt(
      occasion: bestOccasion,
      date: bestDate,
      suggestions: bestOccasion.suggestions
          .take(maxOccasionSuggestions)
          .toList(growable: false),
    );
  }

  /// Creates the card for a chosen suggestion. No extra field is requested and
  /// no network or model call happens on this path (AC-3, AC-5).
  Future<ActivityCard> acceptSuggestion(OccasionSuggestion suggestion) =>
      _repository.createCard(
        NewActivityCard(
          title: suggestion.title,
          origin: ActivityCardOrigin.occasionSuggestion,
          activityType: suggestion.activityType,
        ),
      );
}

/// Device-calendar civil date, deliberately not an instant or a UTC shift
/// (`architecture/contract-summary.md` §3).
String civilDate(DateTime deviceDate) {
  final month = deviceDate.month.toString().padLeft(2, '0');
  final day = deviceDate.day.toString().padLeft(2, '0');
  return '${deviceDate.year.toString().padLeft(4, '0')}-$month-$day';
}
