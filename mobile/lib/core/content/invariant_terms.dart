/// The one home of the R-15c invariant rules, deliberately outside every
/// feature and every package family.
///
/// The rules live in Dart and only in Dart. Putting them in a package would let
/// an out-of-repo CMS relax the rules it is being measured against (R-15c/D-15)
/// — the point is that the gate does not travel with the content it judges. A
/// second copy of these lists next to a second package family would be the same
/// failure one step later: two rule sets, content judged by whichever runs
/// first, relaxing one leaving the other green.
///
/// Terms are matched as whole words, so `điểm số` never fires on `địa điểm`.
library;

/// Display-surface invariant rules. Every string a reader can see, in any
/// package family, is measured against these (R-1b, R-1g, AC-35/BR-18).
enum InvariantRule {
  flattery('flattery'),
  percentDisplay('percent_display'),
  streakDisplay('streak_display'),
  scoreOrRatio('score_or_ratio'),
  recipientBehaviour('recipient_behaviour'),
  manipulativeTone('manipulative_tone'),
  assertiveClaim('assertive_claim');

  const InvariantRule(this.wireValue);

  final String wireValue;
}

/// The R-1f notebook boundary at the *input* layer: what a question is allowed
/// to ask for. A wrong question dirties the notebook from the first write and
/// cannot be repaired downstream (AC-36/BR-4).
enum NotebookBoundaryRule {
  frequencyProbe('frequency_probe'),
  behaviourProbe('behaviour_probe'),
  judgementProbe('judgement_probe');

  const NotebookBoundaryRule(this.wireValue);

  final String wireValue;
}

const Map<InvariantRule, List<String>> invariantDeniedTerms =
    <InvariantRule, List<String>>{
  InvariantRule.flattery: <String>[
    'xinh',
    'đẹp trai',
    'dễ thương',
    'quyến rũ',
    'hoàn hảo',
    'tuyệt vời',
    'số một',
  ],
  InvariantRule.percentDisplay: <String>['phần trăm'],
  InvariantRule.streakDisplay: <String>[
    'streak',
    'chuỗi ngày',
    'liên tiếp',
  ],
  InvariantRule.scoreOrRatio: <String>[
    'điểm số',
    'chấm điểm',
    'xếp hạng',
    'thứ hạng',
    'tỉ lệ',
    'tỷ lệ',
    'score',
    'rank',
  ],
  InvariantRule.recipientBehaviour: <String>[
    'đã xem',
    'đã đọc',
    'seen',
    'online',
    'hoạt động lần cuối',
    'truy cập lần cuối',
  ],
  InvariantRule.manipulativeTone: <String>[
    'chiêu',
    'cưa',
    'thả thính',
    'tán tỉnh',
    'thao túng',
  ],
  InvariantRule.assertiveClaim: <String>[
    'người ấy là',
    'chắc chắn thích',
    'chắc chắn là',
    'rõ ràng là',
    'thực ra',
    'thật ra là',
    'vốn dĩ',
  ],
};

/// Disjoint from [invariantDeniedTerms] by construction: a term that already
/// fails a display rule is not repeated here, so there is exactly one list a
/// given string can be found in.
const Map<NotebookBoundaryRule, List<String>> notebookBoundaryTerms =
    <NotebookBoundaryRule, List<String>>{
  NotebookBoundaryRule.frequencyProbe: <String>[
    'tần suất',
    'bao lâu một lần',
    'mấy lần',
    'mấy ngày một lần',
    'thường xuyên',
    'đều đặn',
  ],
  NotebookBoundaryRule.behaviourProbe: <String>[
    'trả lời tin',
    'rep tin',
    'hồi âm',
    'nhắn trước',
    'cư xử',
    'đối xử',
    'phản ứng',
  ],
  NotebookBoundaryRule.judgementProbe: <String>[
    'đánh giá',
    'nhận xét',
    'tính cách',
    'xứng đáng',
    'điểm mạnh',
    'điểm yếu',
    'ưu điểm',
    'khuyết điểm',
  ],
};

const String _percentSymbol = '%';

final Map<String, RegExp> _termPatterns = <String, RegExp>{};

RegExp _patternFor(String term) => _termPatterns.putIfAbsent(
      term,
      () => RegExp(
        '(?<![\\p{L}\\p{N}])${RegExp.escape(term)}(?![\\p{L}\\p{N}])',
        unicode: true,
        caseSensitive: false,
      ),
    );

/// One denylisted term found in one string, with the wording a gate reports.
class InvariantTermHit {
  const InvariantTermHit(this.rule, this.detail);

  final InvariantRule rule;
  final String detail;
}

class NotebookBoundaryHit {
  const NotebookBoundaryHit(this.rule, this.detail);

  final NotebookBoundaryRule rule;
  final String detail;
}

Iterable<InvariantTermHit> invariantHitsIn(String text) sync* {
  final String haystack = text.toLowerCase();

  if (haystack.contains(_percentSymbol)) {
    yield const InvariantTermHit(
      InvariantRule.percentDisplay,
      'text shows a "$_percentSymbol" figure',
    );
  }

  for (final MapEntry<InvariantRule, List<String>> entry
      in invariantDeniedTerms.entries) {
    for (final String term in entry.value) {
      if (_patternFor(term).hasMatch(haystack)) {
        yield InvariantTermHit(
          entry.key,
          'text uses the denylisted term "$term"',
        );
      }
    }
  }
}

Iterable<NotebookBoundaryHit> notebookBoundaryHitsIn(String text) sync* {
  final String haystack = text.toLowerCase();

  for (final MapEntry<NotebookBoundaryRule, List<String>> entry
      in notebookBoundaryTerms.entries) {
    for (final String term in entry.value) {
      if (_patternFor(term).hasMatch(haystack)) {
        yield NotebookBoundaryHit(
          entry.key,
          'question asks past the notebook boundary via "$term"',
        );
      }
    }
  }
}
