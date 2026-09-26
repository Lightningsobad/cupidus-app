import 'dart:io';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/features/zodiac_shell/domain/zodiac_shell_content.dart';
import 'package:cupid_mobile/features/zodiac_shell/domain/zodiac_shell_content_gate.dart';
import 'package:cupid_mobile/features/zodiac_shell/domain/zodiac_shell_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('outcome mapping', () {
    test('one answer resolves through its mapping key', () {
      final ZodiacShellResult result = ZodiacShellResolver.resolve(
        set: _sliceSet,
        answers: const <ZodiacAnswer>[
          ZodiacAnswer(questionId: 'q.1', optionId: 'o.nhanh'),
        ],
        outcomes: _outcomes,
        notebookTags: const <String>[],
      );

      expect(result.outcome.id, 'out.nhanh');
    });

    test('two answers join their outcome keys in question order', () {
      final ZodiacShellResult first = ZodiacShellResolver.resolve(
        set: _quizSet,
        answers: const <ZodiacAnswer>[
          ZodiacAnswer(questionId: 'q.a', optionId: 'o.a.left'),
          ZodiacAnswer(questionId: 'q.b', optionId: 'o.b.right'),
        ],
        outcomes: _outcomes,
        notebookTags: const <String>[],
      );
      final ZodiacShellResult swapped = ZodiacShellResolver.resolve(
        set: _quizSet,
        answers: const <ZodiacAnswer>[
          ZodiacAnswer(questionId: 'q.b', optionId: 'o.b.right'),
          ZodiacAnswer(questionId: 'q.a', optionId: 'o.a.left'),
        ],
        outcomes: _outcomes,
        notebookTags: const <String>[],
      );

      // "left+right" is a declared mapping key; "right+left" is not, so the
      // order of the answers has to be the order of the questions.
      expect(first.outcome.id, 'out.mix');
      expect(swapped.outcome.id, 'out.chung');
    });

    test('a combination no mapping covers falls back', () {
      final ZodiacShellResult result = ZodiacShellResolver.resolve(
        set: _quizSet,
        answers: const <ZodiacAnswer>[
          ZodiacAnswer(questionId: 'q.a', optionId: 'o.a.right'),
          ZodiacAnswer(questionId: 'q.b', optionId: 'o.b.right'),
        ],
        outcomes: _outcomes,
        notebookTags: const <String>[],
      );

      expect(result.outcome.id, 'out.chung');
    });

    test('an answer naming an option this set does not declare falls back', () {
      final ZodiacShellResult result = ZodiacShellResolver.resolve(
        set: _sliceSet,
        answers: const <ZodiacAnswer>[
          ZodiacAnswer(questionId: 'q.1', optionId: 'o.deleted_by_the_cms'),
        ],
        outcomes: _outcomes,
        notebookTags: const <String>[],
      );

      expect(result.outcome.id, 'out.chung');
    });

    test('an outcomes package missing both targets throws rather than '
        'building a partial result', () {
      expect(
        () => ZodiacShellResolver.resolve(
          set: _sliceSet,
          answers: const <ZodiacAnswer>[
            ZodiacAnswer(questionId: 'q.1', optionId: 'o.nhanh'),
          ],
          outcomes: _outcomePackage(const <ZodiacOutcome>[]),
          notebookTags: const <String>[],
        ),
        throwsA(isA<ContentPackageFormatException>()),
      );
    });
  });

  group('determinism (AC-21)', () {
    test('the same set, answers and notebook resolve identically every time',
        () {
      const List<ZodiacAnswer> answers = <ZodiacAnswer>[
        ZodiacAnswer(questionId: 'q.a', optionId: 'o.a.left'),
        ZodiacAnswer(questionId: 'q.b', optionId: 'o.b.left'),
      ];
      const List<String> tags = <String>['ca_phe'];

      final List<String> outcomeIds = <String>[];
      final List<List<String>> suggestionIds = <List<String>>[];
      for (int run = 0; run < 5; run += 1) {
        final ZodiacShellResult result = ZodiacShellResolver.resolve(
          set: _quizSet,
          answers: answers,
          outcomes: _outcomes,
          notebookTags: tags,
        );
        outcomeIds.add(result.outcome.id);
        suggestionIds.add(<String>[
          for (final ZodiacSuggestion suggestion in result.suggestions)
            suggestion.id,
        ]);
      }

      expect(outcomeIds.toSet(), hasLength(1));
      expect(suggestionIds.map((List<String> ids) => ids.join('|')).toSet(),
          hasLength(1));
    });

    test('no source file under features/zodiac_shell reads the clock or rolls '
        'dice', () {
      final Directory module = Directory('lib/features/zodiac_shell');
      expect(module.existsSync(), isTrue);

      final List<String> offenders = <String>[];
      for (final FileSystemEntity entity in module.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) {
          continue;
        }
        final String source = entity.readAsStringSync();
        for (final String token in const <String>[
          'DateTime.now',
          'Random(',
          'Random.secure',
          'Stopwatch',
        ]) {
          if (source.contains(token)) {
            offenders.add('${entity.path}: $token');
          }
        }
      }

      expect(
        offenders,
        isEmpty,
        reason: 'a shell that reads the clock becomes a daily ritual, and one '
            'that rolls dice stops being reproducible (AC-18/AC-21)',
      );
    });
  });

  group('picking three suggestions', () {
    test('an empty notebook takes the first three in pack order (AC-25)', () {
      final ZodiacShellResult result = ZodiacShellResolver.resolve(
        set: _sliceSet,
        answers: const <ZodiacAnswer>[
          ZodiacAnswer(questionId: 'q.1', optionId: 'o.cham'),
        ],
        outcomes: _outcomes,
        notebookTags: const <String>[],
      );

      expect(_ids(result), <String>['sg.1', 'sg.2', 'sg.3']);
      expect(result.suggestions, hasLength(minimumSuggestionsPerOutcome));
    });

    test('notebook matches come first, then pack order fills to three (AC-24)',
        () {
      final ZodiacShellResult result = ZodiacShellResolver.resolve(
        set: _sliceSet,
        answers: const <ZodiacAnswer>[
          ZodiacAnswer(questionId: 'q.1', optionId: 'o.cham'),
        ],
        outcomes: _outcomes,
        notebookTags: const <String>['cay_coi'],
      );

      // "sg.5" carries `cay_coi` and sits last in the pool, so a notebook the
      // resolver ignored would leave it out entirely.
      expect(_ids(result), <String>['sg.5', 'sg.1', 'sg.2']);
    });

    test('two matches keep pack order between themselves', () {
      final ZodiacShellResult result = ZodiacShellResolver.resolve(
        set: _sliceSet,
        answers: const <ZodiacAnswer>[
          ZodiacAnswer(questionId: 'q.1', optionId: 'o.cham'),
        ],
        outcomes: _outcomes,
        notebookTags: const <String>['cay_coi', 'ca_phe'],
      );

      expect(_ids(result), <String>['sg.2', 'sg.5', 'sg.1']);
    });

    test('more matches than the surface renders still yields exactly three',
        () {
      final ZodiacShellResult result = ZodiacShellResolver.resolve(
        set: _sliceSet,
        answers: const <ZodiacAnswer>[
          ZodiacAnswer(questionId: 'q.1', optionId: 'o.cham'),
        ],
        outcomes: _outcomes,
        notebookTags: const <String>['ca_phe', 'cay_coi', 'di_bo', 'sach'],
      );

      expect(result.suggestions, hasLength(minimumSuggestionsPerOutcome));
      expect(_ids(result), <String>['sg.2', 'sg.4', 'sg.5']);
    });

    test('a pool the gate would have rejected throws instead of rendering two',
        () {
      expect(
        () => ZodiacShellResolver.resolve(
          set: _sliceSet,
          answers: const <ZodiacAnswer>[
            ZodiacAnswer(questionId: 'q.1', optionId: 'o.tuy_luc'),
          ],
          outcomes: _outcomes,
          notebookTags: const <String>[],
        ),
        throwsA(isA<ContentPackageFormatException>()),
      );
    });
  });

  group('folding the notebook into tags', () {
    test('diacritics fold away so Vietnamese text meets an ASCII tag', () {
      expect(zodiacNotebookTagsIn('Cà phê sáng'), contains('ca_phe'));
      expect(zodiacNotebookTagsIn('Đi bộ buổi tối'), contains('di_bo'));
      expect(zodiacNotebookTagsIn('Cây cối trong nhà'), contains('cay_coi'));
      expect(zodiacNotebookTagsIn('Nấu ăn'), contains('nau_an'));
    });

    test('single words and runs up to three words are both offered', () {
      final Set<String> tags = zodiacNotebookTagsIn('đi chợ cùng nhau');

      expect(tags, containsAll(<String>['di', 'cho', 'di_cho', 'di_cho_cung']));
      expect(tags, isNot(contains('di_cho_cung_nhau')));
    });

    test('punctuation separates words rather than joining them', () {
      expect(zodiacNotebookTagsIn('cà phê, sách'), isNot(contains('phe_sach')));
      expect(zodiacNotebookTagsIn('cà phê, sách'), contains('sach'));
    });

    test('text with nothing to fold yields no tags', () {
      expect(zodiacNotebookTagsIn('   '), isEmpty);
      expect(zodiacNotebookTagsIn('!!!'), isEmpty);
    });
  });
}

List<String> _ids(ZodiacShellResult result) => <String>[
      for (final ZodiacSuggestion suggestion in result.suggestions)
        suggestion.id,
    ];

const ZodiacEditorialReview _review = ZodiacEditorialReview(
  layer1: 'a',
  layer2: 'b',
  approvedAt: '2026-09-24',
);

/// One question, three options — the `questions_per_round: 1` shape.
final ZodiacQuizSet _sliceSet = ZodiacQuizSet(
  id: 'set.slice',
  kind: ZodiacSetKind.slice,
  title: 'Lát thử',
  blurb: '',
  questionsPerRound: 1,
  questions: const <ZodiacQuestion>[
    ZodiacQuestion(
      id: 'q.1',
      prompt: 'Nhịp nào hợp bạn hơn?',
      subject: ZodiacQuestionSubject.self,
      options: <ZodiacOption>[
        ZodiacOption(id: 'o.nhanh', label: 'Nhanh', outcomeKey: 'nhanh'),
        ZodiacOption(id: 'o.cham', label: 'Chậm', outcomeKey: 'cham'),
        ZodiacOption(id: 'o.tuy_luc', label: 'Tuỳ lúc', outcomeKey: 'tuy_luc'),
      ],
    ),
  ],
  mapping: const <ZodiacOutcomeMapping>[
    ZodiacOutcomeMapping(key: 'nhanh', outcomeId: 'out.nhanh'),
    ZodiacOutcomeMapping(key: 'cham', outcomeId: 'out.cham'),
    ZodiacOutcomeMapping(key: 'tuy_luc', outcomeId: 'out.thieu_the'),
  ],
  fallbackOutcomeId: 'out.chung',
  declaredKeys: const <String>{},
  editorialReview: _review,
);

/// Two questions, `questions_per_round: 2` — the joined-key shape.
final ZodiacQuizSet _quizSet = ZodiacQuizSet(
  id: 'set.quiz',
  kind: ZodiacSetKind.quiz,
  title: 'Bộ thử',
  blurb: '',
  questionsPerRound: 2,
  questions: const <ZodiacQuestion>[
    ZodiacQuestion(
      id: 'q.a',
      prompt: 'Câu một?',
      subject: ZodiacQuestionSubject.self,
      options: <ZodiacOption>[
        ZodiacOption(id: 'o.a.left', label: 'Trái', outcomeKey: 'left'),
        ZodiacOption(id: 'o.a.right', label: 'Phải', outcomeKey: 'right'),
      ],
    ),
    ZodiacQuestion(
      id: 'q.b',
      prompt: 'Câu hai?',
      subject: ZodiacQuestionSubject.self,
      options: <ZodiacOption>[
        ZodiacOption(id: 'o.b.left', label: 'Trái', outcomeKey: 'left'),
        ZodiacOption(id: 'o.b.right', label: 'Phải', outcomeKey: 'right'),
      ],
    ),
  ],
  mapping: const <ZodiacOutcomeMapping>[
    ZodiacOutcomeMapping(key: 'left+left', outcomeId: 'out.nhanh'),
    ZodiacOutcomeMapping(key: 'left+right', outcomeId: 'out.mix'),
  ],
  fallbackOutcomeId: 'out.chung',
  declaredKeys: const <String>{},
  editorialReview: _review,
);

final ContentPackage<ZodiacOutcome> _outcomes = _outcomePackage(<ZodiacOutcome>[
  _outcome('out.nhanh'),
  _outcome('out.cham'),
  _outcome('out.mix'),
  _outcome('out.chung'),
  // What a CMS export that skipped the gate looks like: a pool of two.
  ZodiacOutcome(
    id: 'out.thieu_the',
    insight: 'Thiếu thẻ.',
    aboutOther: false,
    askLine: null,
    suggestions: const <ZodiacSuggestion>[
      ZodiacSuggestion(
        id: 'sg.a',
        title: 'Một',
        note: null,
        notebookTags: <String>[],
      ),
      ZodiacSuggestion(
        id: 'sg.b',
        title: 'Hai',
        note: null,
        notebookTags: <String>[],
      ),
    ],
    declaredKeys: const <String>{},
    editorialReview: _review,
  ),
]);

/// A five-suggestion pool, so "pick three of the pool" is observable: `sg.2`
/// and `sg.4` and `sg.5` carry tags, and `sg.5` sits behind the untagged ones.
ZodiacOutcome _outcome(String id) => ZodiacOutcome(
      id: id,
      insight: 'Một nhận định.',
      aboutOther: false,
      askLine: null,
      suggestions: const <ZodiacSuggestion>[
        ZodiacSuggestion(
          id: 'sg.1',
          title: 'Đi dạo một vòng',
          note: null,
          notebookTags: <String>[],
        ),
        ZodiacSuggestion(
          id: 'sg.2',
          title: 'Hẹn cà phê sáng',
          note: null,
          notebookTags: <String>['ca_phe'],
        ),
        ZodiacSuggestion(
          id: 'sg.3',
          title: 'Nấu thử một món',
          note: null,
          notebookTags: <String>[],
        ),
        ZodiacSuggestion(
          id: 'sg.4',
          title: 'Đọc chung một cuốn',
          note: null,
          notebookTags: <String>['sach'],
        ),
        ZodiacSuggestion(
          id: 'sg.5',
          title: 'Trồng thêm một chậu cây',
          note: null,
          notebookTags: <String>['cay_coi'],
        ),
      ],
      declaredKeys: const <String>{},
      editorialReview: _review,
    );

ContentPackage<ZodiacOutcome> _outcomePackage(List<ZodiacOutcome> items) =>
    ContentPackage<ZodiacOutcome>(
      id: 'zodiac_outcomes',
      version: '1',
      schemaId: zodiacOutcomesSchemaId,
      items: items,
    );
