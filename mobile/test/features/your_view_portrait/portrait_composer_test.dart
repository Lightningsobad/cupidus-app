import 'dart:io';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/core/content/invariant_terms.dart';
import 'package:cupid_mobile/features/your_view_portrait/domain/portrait_composer.dart';
import 'package:cupid_mobile/features/your_view_portrait/domain/portrait_content.dart';
import 'package:cupid_mobile/features/your_view_portrait/domain/portrait_content_gate.dart';
import 'package:flutter_test/flutter_test.dart';

const String _composerSourcePath =
    'lib/features/your_view_portrait/domain/portrait_composer.dart';

PortraitSection _section({
  String id = 'portrait.section.fixture.v1',
  String heading = 'Những điều dễ chịu',
  Map<String, String> bindings = const <String, String>{
    'mon_an': 'q.food',
    'cuoi_tuan': 'q.rest',
  },
  List<PortraitClause> clauses = const <PortraitClause>[
    PortraitClause(
      text: 'Theo cách bạn kể, người ấy hay nghiêng về {mon_an}.',
      requires: <String>['mon_an'],
    ),
    PortraitClause(
      text: 'Bạn đang thấy những khoảng rảnh gắn với {cuoi_tuan}.',
      requires: <String>['cuoi_tuan'],
    ),
    PortraitClause(
      text: 'Bạn kể rằng {mon_an} và {cuoi_tuan} thường đi cùng nhau.',
      requires: <String>['mon_an', 'cuoi_tuan'],
    ),
  ],
  List<String> askIds = const <String>['ask.one', 'ask.two'],
}) =>
    PortraitSection(
      id: id,
      heading: heading,
      bindings: bindings,
      clauses: clauses,
      askIds: askIds,
    );

ContentPackage<PortraitSection> _sections(List<PortraitSection> items) =>
    ContentPackage<PortraitSection>(
      id: 'portrait.sections.fixture',
      version: '1.0.0',
      schemaId: portraitSectionsSchemaId,
      items: items,
    );

ContentPackage<PortraitAsk> _asks([
  List<String> ids = const <String>['ask.one', 'ask.two'],
]) =>
    ContentPackage<PortraitAsk>(
      id: 'portrait.asks.fixture',
      version: '1.0.0',
      schemaId: portraitAsksSchemaId,
      items: <PortraitAsk>[
        for (final String id in ids) PortraitAsk(id: id, text: 'Câu $id?'),
      ],
    );

PortraitSettledAnswer _guess(String value) =>
    PortraitSettledAnswer(skipped: false, answerValue: value);

PortraitSettledAnswer _fromNotebook(String entryId) =>
    PortraitSettledAnswer(skipped: false, notebookEntryId: entryId);

const PortraitSettledAnswer _skipped = PortraitSettledAnswer(skipped: true);

List<ComposedSection> _compose({
  required ContentPackage<PortraitSection> sections,
  ContentPackage<PortraitAsk>? asks,
  Map<String, PortraitSettledAnswer> answers =
      const <String, PortraitSettledAnswer>{},
  Map<String, String> notebookValues = const <String, String>{},
  int askCursor = 0,
}) =>
    composePortrait(
      sections: sections,
      asks: asks ?? _asks(),
      answers: answers,
      notebookValues: notebookValues,
      askCursor: askCursor,
    );

void main() {
  group('clause survival (contract-summary.md §4)', () {
    test('a clause whose variables are all bound renders with them substituted',
        () {
      final List<ComposedSection> composed = _compose(
        sections: _sections(<PortraitSection>[_section()]),
        answers: <String, PortraitSettledAnswer>{
          'q.food': _guess('món Việt'),
          'q.rest': _guess('đi bộ buổi sáng'),
        },
      );

      expect(composed.single.clauses, <String>[
        'Theo cách bạn kể, người ấy hay nghiêng về món Việt.',
        'Bạn đang thấy những khoảng rảnh gắn với đi bộ buổi sáng.',
        'Bạn kể rằng món Việt và đi bộ buổi sáng thường đi cùng nhau.',
      ]);
    });

    test('an unbound variable drops its clause whole, leaving the others '
        'untouched', () {
      final List<ComposedSection> composed = _compose(
        sections: _sections(<PortraitSection>[_section()]),
        answers: <String, PortraitSettledAnswer>{
          'q.food': _guess('món Việt'),
        },
      );

      expect(composed.single.clauses, <String>[
        'Theo cách bạn kể, người ấy hay nghiêng về món Việt.',
      ]);
    });

    test('no dropped clause leaves a visible placeholder or a half sentence',
        () {
      final List<ComposedSection> composed = _compose(
        sections: _sections(<PortraitSection>[_section()]),
        answers: <String, PortraitSettledAnswer>{'q.rest': _guess('ở nhà')},
      );

      for (final String clause in composed.single.clauses) {
        expect(clause, isNot(contains('{')));
        expect(clause, isNot(contains('}')));
      }
      expect(composed.single.paragraph, 'Bạn đang thấy những khoảng rảnh gắn '
          'với ở nhà.');
    });

    test('surviving clauses are joined by exactly one space, with punctuation '
        'left as authored', () {
      final ComposedSection section = _compose(
        sections: _sections(<PortraitSection>[_section()]),
        answers: <String, PortraitSettledAnswer>{
          'q.food': _guess('món Việt'),
          'q.rest': _guess('ở nhà'),
        },
      ).single;

      expect(section.paragraph, section.clauses.join(' '));
      expect(section.paragraph, isNot(contains('  ')));
      expect(section.paragraph.endsWith('.'), isTrue);
    });

    test('a clause carrying a placeholder no binding declares is dropped '
        'rather than rendered raw', () {
      final List<ComposedSection> composed = _compose(
        sections: _sections(<PortraitSection>[
          _section(
            clauses: const <PortraitClause>[
              PortraitClause(
                text: 'Theo cách bạn kể, {mon_an} đi cùng {khong_khai_bao}.',
                requires: <String>['mon_an'],
              ),
            ],
          ),
        ]),
        answers: <String, PortraitSettledAnswer>{'q.food': _guess('món Việt')},
      );

      expect(composed.single.clauses, isEmpty);
    });

    test('an answer containing braces is substituted in, never substituted '
        'into', () {
      final List<ComposedSection> composed = _compose(
        sections: _sections(<PortraitSection>[
          _section(
            clauses: const <PortraitClause>[
              PortraitClause(
                text: 'Theo cách bạn kể, người ấy hay nghiêng về {mon_an}.',
                requires: <String>['mon_an'],
              ),
            ],
          ),
        ]),
        answers: <String, PortraitSettledAnswer>{
          'q.food': _guess('{cuoi_tuan}'),
          'q.rest': _guess('đi bộ'),
        },
      );

      expect(
        composed.single.clauses.single,
        'Theo cách bạn kể, người ấy hay nghiêng về {cuoi_tuan}.',
      );
    });
  });

  group('the invariant rules are measured on composed text (AC-4 story)', () {
    test('an answer that turns an authored clause into a denylisted claim '
        'drops that clause', () {
      final List<ComposedSection> composed = _compose(
        sections: _sections(<PortraitSection>[
          _section(
            clauses: const <PortraitClause>[
              PortraitClause(
                text: 'Bạn kể rằng {mon_an} là ngày người ấy giữ cho riêng '
                    'mình.',
                requires: <String>['mon_an'],
              ),
              PortraitClause(
                text: 'Bạn đang thấy những khoảng rảnh gắn với {cuoi_tuan}.',
                requires: <String>['cuoi_tuan'],
              ),
            ],
          ),
        ]),
        answers: <String, PortraitSettledAnswer>{
          // "... người ấy" + " là ..." reads back as "người ấy là", which no
          // side of the seam contains on its own.
          'q.food': _guess('Sinh nhật người ấy'),
          'q.rest': _guess('đi bộ buổi sáng'),
        },
      );

      expect(composed.single.clauses, <String>[
        'Bạn đang thấy những khoảng rảnh gắn với đi bộ buổi sáng.',
      ]);
    });

    test('free text carrying a denylisted term never reaches the reader', () {
      final List<ComposedSection> composed = _compose(
        sections: _sections(<PortraitSection>[
          _section(
            clauses: const <PortraitClause>[
              PortraitClause(
                text: 'Theo cách bạn kể, người ấy hay nghiêng về {mon_an}.',
                requires: <String>['mon_an'],
              ),
            ],
          ),
        ]),
        answers: <String, PortraitSettledAnswer>{
          'q.food': _guess('mấy quán 5 sao hoàn hảo'),
        },
      );

      expect(composed.single.clauses, isEmpty);
    });
  });

  group('variable resolution (phase P3 §3)', () {
    test('a notebook answer reads its text from the notebook, not from the '
        'answer row (AC-22)', () {
      final List<ComposedSection> composed = _compose(
        sections: _sections(<PortraitSection>[
          _section(
            clauses: const <PortraitClause>[
              PortraitClause(
                text: 'Theo cách bạn kể, người ấy hay nghiêng về {mon_an}.',
                requires: <String>['mon_an'],
              ),
            ],
          ),
        ]),
        answers: <String, PortraitSettledAnswer>{
          'q.food': _fromNotebook('entry-1'),
        },
        notebookValues: <String, String>{'entry-1': 'bún bò'},
      );

      expect(
        composed.single.clauses.single,
        'Theo cách bạn kể, người ấy hay nghiêng về bún bò.',
      );
    });

    test('deleting the notebook entry thins the portrait instead of leaving a '
        'stale copy (AC-22)', () {
      final List<ComposedSection> composed = _compose(
        sections: _sections(<PortraitSection>[_section()]),
        answers: <String, PortraitSettledAnswer>{
          'q.food': _fromNotebook('entry-gone'),
          'q.rest': _guess('ở nhà'),
        },
        notebookValues: const <String, String>{},
      );

      expect(composed.single.clauses, <String>[
        'Bạn đang thấy những khoảng rảnh gắn với ở nhà.',
      ]);
    });

    test('a skipped question reads exactly like a question never reached '
        '(AC-27)', () {
      final ComposedSection afterSkip = _compose(
        sections: _sections(<PortraitSection>[_section()]),
        answers: <String, PortraitSettledAnswer>{
          'q.food': _guess('món Việt'),
          'q.rest': _skipped,
        },
      ).single;
      final ComposedSection neverReached = _compose(
        sections: _sections(<PortraitSection>[_section()]),
        answers: <String, PortraitSettledAnswer>{'q.food': _guess('món Việt')},
      ).single;

      expect(afterSkip.paragraph, neverReached.paragraph);
      expect(afterSkip.clauses, <String>[
        'Theo cách bạn kể, người ấy hay nghiêng về món Việt.',
      ]);
    });

    test('an empty answer value binds nothing rather than rendering a gap', () {
      final List<ComposedSection> composed = _compose(
        sections: _sections(<PortraitSection>[_section()]),
        answers: <String, PortraitSettledAnswer>{'q.food': _guess('')},
      );

      expect(composed.single.clauses, isEmpty);
    });
  });

  group('a thin portrait is a valid result (AC-19 / BR-9)', () {
    test('a section with nothing left to say still ends with its ask line, '
        'and carries no paragraph', () {
      final ComposedSection section = _compose(
        sections: _sections(<PortraitSection>[_section()]),
      ).single;

      expect(section.clauses, isEmpty);
      expect(section.paragraph, isEmpty);
      expect(section.heading, isNotEmpty);
      expect(section.askText, endsWith('?'));
    });

    test('skipping every question leaves ask lines, never a dead-end screen '
        '(§6)', () {
      final List<ComposedSection> composed = _compose(
        sections: _sections(<PortraitSection>[
          _section(),
          _section(id: 'portrait.section.second.v1'),
        ]),
        answers: <String, PortraitSettledAnswer>{
          'q.food': _skipped,
          'q.rest': _skipped,
        },
      );

      expect(composed, hasLength(2));
      for (final ComposedSection section in composed) {
        expect(section.clauses, isEmpty);
        expect(section.askText, endsWith('?'));
      }
    });

    test('nothing composed reads as a reproach, a count, or a prompt to answer '
        'more', () {
      final List<ComposedSection> composed = _compose(
        sections: _sections(<PortraitSection>[_section()]),
      );

      final String everything = composed
          .map((ComposedSection s) => '${s.heading} ${s.paragraph} ${s.askText}')
          .join(' ');
      expect(everything, isNot(contains('chưa đủ')));
      expect(everything, isNot(contains('còn thiếu')));
      expect(everything, isNot(contains('hoàn thành')));
    });
  });

  group('ask rotation is data-driven for every N (R-15b / AC-35)', () {
    test('a store of one ask returns that ask at every cursor', () {
      for (int cursor = 0; cursor < 5; cursor++) {
        final ComposedSection section = _compose(
          sections: _sections(<PortraitSection>[
            _section(askIds: const <String>['ask.one']),
          ]),
          asks: _asks(const <String>['ask.one']),
          askCursor: cursor,
        ).single;

        expect(section.askId, 'ask.one');
      }
    });

    test('a store of two asks alternates and wraps at the end', () {
      final List<String> seen = <String>[
        for (int cursor = 0; cursor < 5; cursor++)
          _compose(
            sections: _sections(<PortraitSection>[_section()]),
            askCursor: cursor,
          ).single.askId,
      ];

      expect(seen, <String>[
        'ask.one',
        'ask.two',
        'ask.one',
        'ask.two',
        'ask.one',
      ]);
    });

    test('a store of n asks wraps on its own length, with no assumed size', () {
      const List<String> ids = <String>['a.1', 'a.2', 'a.3', 'a.4', 'a.5'];
      final List<String> seen = <String>[
        for (int cursor = 0; cursor < ids.length * 2; cursor++)
          _compose(
            sections: _sections(<PortraitSection>[_section(askIds: ids)]),
            asks: _asks(ids),
            askCursor: cursor,
          ).single.askId,
      ];

      expect(seen, <String>[...ids, ...ids]);
    });

    test('each section rotates over its own ask ids', () {
      final List<ComposedSection> composed = _compose(
        sections: _sections(<PortraitSection>[
          _section(askIds: const <String>['ask.one', 'ask.two']),
          _section(
            id: 'portrait.section.second.v1',
            askIds: const <String>['ask.three'],
          ),
        ]),
        asks: _asks(const <String>['ask.one', 'ask.two', 'ask.three']),
        askCursor: 1,
      );

      expect(composed[0].askId, 'ask.two');
      expect(composed[1].askId, 'ask.three');
    });

    test('a section pointing at an ask the store does not have fails loudly',
        () {
      expect(
        () => _compose(
          sections: _sections(<PortraitSection>[
            _section(askIds: const <String>['ask.missing']),
          ]),
        ),
        throwsStateError,
      );
    });
  });

  group('deterministic and offline (AC-29 / AC-30)', () {
    test('the same inputs compose the same strings, character for character',
        () {
      ContentPackage<PortraitSection> sections() =>
          _sections(<PortraitSection>[_section()]);
      final Map<String, PortraitSettledAnswer> answers =
          <String, PortraitSettledAnswer>{
        'q.food': _fromNotebook('entry-1'),
        'q.rest': _guess('đi bộ buổi sáng'),
      };
      const Map<String, String> notebookValues = <String, String>{
        'entry-1': 'bún bò',
      };

      final List<ComposedSection> first = _compose(
        sections: sections(),
        answers: answers,
        notebookValues: notebookValues,
        askCursor: 3,
      );
      final List<ComposedSection> second = _compose(
        sections: sections(),
        answers: answers,
        notebookValues: notebookValues,
        askCursor: 3,
      );

      expect(first, hasLength(second.length));
      for (int i = 0; i < first.length; i++) {
        expect(first[i].heading, second[i].heading);
        expect(first[i].clauses, second[i].clauses);
        expect(first[i].paragraph, second[i].paragraph);
        expect(first[i].askId, second[i].askId);
        expect(first[i].askText, second[i].askText);
      }
    });

    test('the composer source reaches no clock, no network, and no randomness',
        () {
      final String source = File(_composerSourcePath).readAsStringSync();

      expect(source, isNot(contains('dart:io')));
      expect(source, isNot(contains('dart:math')));
      expect(source, isNot(contains('package:http')));
      expect(source, isNot(contains('Random')));
      expect(source, isNot(contains('DateTime.now()')));
      expect(source, isNot(contains('rootBundle')));
      expect(source, isNot(contains('await ')));
    });

    test('composing writes nothing back: the answers map is left as it was',
        () {
      final Map<String, PortraitSettledAnswer> answers =
          <String, PortraitSettledAnswer>{'q.food': _guess('món Việt')};

      _compose(
        sections: _sections(<PortraitSection>[_section()]),
        answers: answers,
      );

      expect(answers.keys, <String>['q.food']);
    });
  });

  group('the shipped packs compose clean output (AC-4 story, R-1g)', () {
    late ContentPackage<PortraitQuestion> questions;
    late ContentPackage<PortraitSection> sections;
    late ContentPackage<PortraitAsk> asks;

    setUpAll(() {
      questions = ContentPackage.parse<PortraitQuestion>(
        File(portraitQuestionsAssetKey).readAsStringSync(),
        expectedSchemaId: portraitQuestionsSchemaId,
        itemParser: portraitQuestionFromJson,
        source: portraitQuestionsAssetKey,
      );
      sections = ContentPackage.parse<PortraitSection>(
        File(portraitSectionsAssetKey).readAsStringSync(),
        expectedSchemaId: portraitSectionsSchemaId,
        itemParser: portraitSectionFromJson,
        source: portraitSectionsAssetKey,
      );
      asks = ContentPackage.parse<PortraitAsk>(
        File(portraitAsksAssetKey).readAsStringSync(),
        expectedSchemaId: portraitAsksSchemaId,
        itemParser: portraitAskFromJson,
        source: portraitAsksAssetKey,
      );
    });

    /// Answers every shipped question with a plain, user-sounding value, so the
    /// composed strings below are the fullest portrait the packs can produce.
    Map<String, PortraitSettledAnswer> fullyAnswered() {
      final Map<String, PortraitSettledAnswer> answers =
          <String, PortraitSettledAnswer>{};
      for (final PortraitQuestion question in questions.items) {
        answers[question.id] = question.target.writesToNotebook
            ? _fromNotebook('entry-${question.id}')
            : _guess(question.chips.first);
      }
      return answers;
    }

    Map<String, String> notebookValuesFor(
      Map<String, PortraitSettledAnswer> answers,
    ) =>
        <String, String>{
          for (final MapEntry<String, PortraitSettledAnswer> entry
              in answers.entries)
            if (entry.value.notebookEntryId != null)
              entry.value.notebookEntryId!:
                  questions.itemById(entry.key)!.chips.first,
        };

    test('every composed string passes the same invariant rules as the packs',
        () {
      final Map<String, PortraitSettledAnswer> answers = fullyAnswered();
      final List<ComposedSection> composed = composePortrait(
        sections: sections,
        asks: asks,
        answers: answers,
        notebookValues: notebookValuesFor(answers),
        askCursor: 0,
      );

      final List<String> hits = <String>[
        for (final ComposedSection section in composed)
          for (final String text in <String>[
            section.heading,
            ...section.clauses,
            section.askText,
          ])
            for (final InvariantTermHit hit in invariantHitsIn(text))
              '${section.sectionId} [${hit.rule.wireValue}]: ${hit.detail}',
      ];

      expect(hits, isEmpty);
    });

    test('a fully answered portrait still says something in every section', () {
      final Map<String, PortraitSettledAnswer> answers = fullyAnswered();
      final List<ComposedSection> composed = composePortrait(
        sections: sections,
        asks: asks,
        answers: answers,
        notebookValues: notebookValuesFor(answers),
        askCursor: 0,
      );

      for (final ComposedSection section in composed) {
        expect(section.clauses, isNotEmpty, reason: section.sectionId);
      }
    });

    test('every composed clause still opens with a legal frame once its '
        'neighbours are dropped', () {
      for (int keep = 0; keep < questions.items.length; keep++) {
        final Map<String, PortraitSettledAnswer> answers =
            <String, PortraitSettledAnswer>{
          questions.items[keep].id: _guess(questions.items[keep].chips.first),
        };
        final List<ComposedSection> composed = composePortrait(
          sections: sections,
          asks: asks,
          answers: answers,
          notebookValues: notebookValuesFor(answers),
          askCursor: keep,
        );

        for (final ComposedSection section in composed) {
          for (final String clause in section.clauses) {
            expect(
              portraitLegalOpeningFrames
                  .any((String frame) => clause.startsWith(frame)),
              isTrue,
              reason: clause,
            );
          }
        }
      }
    });

    test('every section ends with exactly one line to ask, and it is a '
        'question (AC-3 story)', () {
      final Map<String, PortraitSettledAnswer> answers = fullyAnswered();
      final List<ComposedSection> composed = composePortrait(
        sections: sections,
        asks: asks,
        answers: answers,
        notebookValues: notebookValuesFor(answers),
        askCursor: 0,
      );

      expect(composed, hasLength(sections.items.length));
      for (final ComposedSection section in composed) {
        expect(section.askText.trimRight(), endsWith('?'));
        expect(section.paragraph, isNot(contains(section.askText)));
      }
    });

    test('the shipped packs compose the same portrait twice in a row', () {
      final Map<String, PortraitSettledAnswer> answers = fullyAnswered();
      final Map<String, String> notebookValues = notebookValuesFor(answers);

      String render(int cursor) => composePortrait(
            sections: sections,
            asks: asks,
            answers: answers,
            notebookValues: notebookValues,
            askCursor: cursor,
          )
              .map((ComposedSection s) =>
                  '${s.heading}|${s.paragraph}|${s.askText}')
              .join('||');

      expect(render(2), render(2));
      expect(render(2), isNot(render(3)));
    });
  });
}
