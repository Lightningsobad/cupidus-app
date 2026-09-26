import '../../../core/content/content_package.dart';
import 'zodiac_shell_content.dart';
import 'zodiac_shell_content_gate.dart';

/// One answered question, carried in the order the question was asked.
///
/// The question id travels with the option id so a caller cannot silently
/// reorder the answers relative to the round: [ZodiacShellResolver.resolve]
/// joins `outcome_key`s in *this* list's order, and that order is the mapping
/// key (`architecture/contract-summary.md` §3 row 7).
class ZodiacAnswer {
  const ZodiacAnswer({required this.questionId, required this.optionId});

  final String questionId;
  final String optionId;
}

/// Everything one finished round resolves to.
class ZodiacShellResult {
  const ZodiacShellResult({required this.outcome, required this.suggestions});

  final ZodiacOutcome outcome;

  /// Exactly [minimumSuggestionsPerOutcome] of [ZodiacOutcome.suggestions], in
  /// pack order within each of the two tiers (`contract-summary.md` §4).
  final List<ZodiacSuggestion> suggestions;
}

/// Answers in, result out — a total function of its four arguments (AC-21).
///
/// No clock, no `Random`, no I/O, and no rotation cursor: which questions get
/// asked is `ZodiacRotationStore`'s business, and it never reaches this
/// mapping. The notebook is an *input*, so a notebook that gained an entry
/// legitimately changes the three suggestions without breaking AC-21
/// (`solution.md` §3).
abstract final class ZodiacShellResolver {
  static ZodiacShellResult resolve({
    required ZodiacQuizSet set,
    required List<ZodiacAnswer> answers,
    required ContentPackage<ZodiacOutcome> outcomes,
    required List<String> notebookTags,
  }) {
    final ZodiacOutcome outcome = _outcomeFor(set, answers, outcomes);
    return ZodiacShellResult(
      outcome: outcome,
      suggestions: _suggestionsFor(outcome, notebookTags),
    );
  }

  static ZodiacOutcome _outcomeFor(
    ZodiacQuizSet set,
    List<ZodiacAnswer> answers,
    ContentPackage<ZodiacOutcome> outcomes,
  ) {
    final String? key = _outcomeKeyFor(set, answers);
    String outcomeId = set.fallbackOutcomeId;
    if (key != null) {
      for (final ZodiacOutcomeMapping entry in set.mapping) {
        if (entry.key == key) {
          outcomeId = entry.outcomeId;
          break;
        }
      }
    }

    final ZodiacOutcome? outcome =
        outcomes.itemById(outcomeId) ?? outcomes.itemById(set.fallbackOutcomeId);
    if (outcome == null) {
      // Unreachable for a pair that passed `validateZodiacPacks`, which an
      // out-of-repo CMS can hand us in memory (R-15c). Loud beats a half-built
      // result surface.
      throw ContentPackageFormatException(
        outcomes.schemaId,
        'set "${set.id}" resolves to "$outcomeId" and falls back to '
        '"${set.fallbackOutcomeId}"; the outcomes package declares neither',
      );
    }
    return outcome;
  }

  /// The `mapping[].key` these answers spell, or `null` when an answer names a
  /// question or option this set does not declare — which resolves to the
  /// fallback rather than throwing, because a stale answer is a reason to show
  /// the generic outcome, not to lose the round.
  static String? _outcomeKeyFor(ZodiacQuizSet set, List<ZodiacAnswer> answers) {
    final List<String> tokens = <String>[];
    for (final ZodiacAnswer answer in answers) {
      final String? token = _outcomeKeyOf(set, answer);
      if (token == null) {
        return null;
      }
      tokens.add(token);
    }
    return tokens.join(zodiacOutcomeKeySeparator);
  }

  static String? _outcomeKeyOf(ZodiacQuizSet set, ZodiacAnswer answer) {
    for (final ZodiacQuestion question in set.questions) {
      if (question.id != answer.questionId) {
        continue;
      }
      for (final ZodiacOption option in question.options) {
        if (option.id == answer.optionId) {
          return option.outcomeKey;
        }
      }
      return null;
    }
    return null;
  }

  /// Notebook-matching suggestions first in pack order, then pack order fills
  /// up to exactly [minimumSuggestionsPerOutcome] (AC-24/AC-25).
  static List<ZodiacSuggestion> _suggestionsFor(
    ZodiacOutcome outcome,
    List<String> notebookTags,
  ) {
    final Set<String> tags = notebookTags.toSet();
    final List<ZodiacSuggestion> chosen = <ZodiacSuggestion>[];
    final Set<String> chosenIds = <String>{};

    void take(ZodiacSuggestion suggestion) {
      if (chosen.length < minimumSuggestionsPerOutcome &&
          chosenIds.add(suggestion.id)) {
        chosen.add(suggestion);
      }
    }

    for (final ZodiacSuggestion suggestion in outcome.suggestions) {
      if (suggestion.notebookTags.any(tags.contains)) {
        take(suggestion);
      }
    }
    for (final ZodiacSuggestion suggestion in outcome.suggestions) {
      take(suggestion);
    }

    if (chosen.length != minimumSuggestionsPerOutcome) {
      throw ContentPackageFormatException(
        zodiacOutcomesSchemaId,
        'outcome "${outcome.id}" offers ${outcome.suggestions.length} '
        'suggestions; the result surface renders '
        '$minimumSuggestionsPerOutcome and has no branch for fewer',
      );
    }
    return List<ZodiacSuggestion>.unmodifiable(chosen);
  }
}

/// How many words a `notebook_tags` value may join (`di_bo`, `ke_hoach`). Three
/// is one more than anything the shipped packages use, so a CMS can add a
/// three-word tag without a code change (R-15a).
const int _maxTagWords = 3;

/// Every `notebook_tags` value [text] could stand for.
///
/// The notebook holds whatever the user typed — "Cà phê sáng", "Đi bộ" — while
/// the packages address it in ASCII slugs, so the two only meet after folding
/// the diacritics away and emitting each contiguous run of up to [_maxTagWords]
/// words. The caller unions these over the notebook and hands the result to
/// [ZodiacShellResolver.resolve], which then does a plain set intersection.
Set<String> zodiacNotebookTagsIn(String text) {
  final Set<String> tags = <String>{};
  for (final List<String> words in _foldedSegmentsIn(text)) {
    for (int start = 0; start < words.length; start += 1) {
      for (int span = 1;
          span <= _maxTagWords && start + span <= words.length;
          span += 1) {
        tags.add(words.sublist(start, start + span).join('_'));
      }
    }
  }
  return tags;
}

/// Words grouped by the phrase they were typed in.
///
/// Spaces separate words inside one phrase, but a comma, a slash or a newline
/// starts a new one: "cà phê, sách" is two things the user likes, so joining
/// them into `phe_sach` would invent a tag nobody wrote.
List<List<String>> _foldedSegmentsIn(String text) {
  final List<List<String>> segments = <List<String>>[];
  List<String> words = <String>[];
  final StringBuffer word = StringBuffer();

  void flushWord() {
    if (word.isNotEmpty) {
      words.add(word.toString());
      word.clear();
    }
  }

  void flushSegment() {
    flushWord();
    if (words.isNotEmpty) {
      segments.add(words);
      words = <String>[];
    }
  }

  for (final int rune in text.toLowerCase().runes) {
    final String character = String.fromCharCode(rune);
    final String folded = _diacriticFolds[character] ?? character;
    if (_isTagCharacter(folded)) {
      word.write(folded);
    } else if (_isWordSeparator(character)) {
      flushWord();
    } else {
      flushSegment();
    }
  }
  flushSegment();
  return segments;
}

bool _isWordSeparator(String character) =>
    character == ' ' || character == '\t';

bool _isTagCharacter(String character) {
  if (character.length != 1) {
    return false;
  }
  final int code = character.codeUnitAt(0);
  return (code >= 0x61 && code <= 0x7a) || (code >= 0x30 && code <= 0x39);
}

final Map<String, String> _diacriticFolds = <String, String>{
  for (final MapEntry<String, String> entry in <String, String>{
    'a': 'àáạảãâầấậẩẫăằắặẳẵ',
    'e': 'èéẹẻẽêềếệểễ',
    'i': 'ìíịỉĩ',
    'o': 'òóọỏõôồốộổỗơờớợởỡ',
    'u': 'ùúụủũưừứựửữ',
    'y': 'ỳýỵỷỹ',
    'd': 'đ',
  }.entries)
    for (final int rune in entry.value.runes)
      String.fromCharCode(rune): entry.key,
};
