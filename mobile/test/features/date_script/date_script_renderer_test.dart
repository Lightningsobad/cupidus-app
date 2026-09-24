import 'dart:io';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_type.dart';
import 'package:cupid_mobile/features/activity_cards/domain/time_of_day_slot.dart';
import 'package:cupid_mobile/features/context_notebook/context_notebook_entry_point.dart';
// Fixture-only. `NotebookEntry.source` is a required field whose enum the entry
// point does not re-export, so a test cannot build one through the entry point
// alone. The renderer under test still reaches the notebook only through the
// entry point (`architecture/contract-summary.md` §5).
import 'package:cupid_mobile/features/context_notebook/domain/context_notebook_models.dart'
    show ContextEntrySource;
import 'package:cupid_mobile/features/date_script/domain/date_script_content.dart';
import 'package:cupid_mobile/features/date_script/domain/date_script_renderer.dart';
import 'package:cupid_mobile/features/date_script/domain/date_script_selector.dart';
import 'package:flutter_test/flutter_test.dart';

ContentPackage<DateScriptPreset> _shippedPack() {
  final File file = File(dateScriptAssetKey);
  expect(file.existsSync(), isTrue, reason: '$dateScriptAssetKey is missing');
  return ContentPackage.parse<DateScriptPreset>(
    file.readAsStringSync(),
    expectedSchemaId: dateScriptSchemaId,
    itemParser: dateScriptPresetFromJson,
    source: dateScriptAssetKey,
  );
}

ActivityCard _card({
  String id = 'card-1',
  String title = 'Đi cà phê',
  ActivityType? activityType = ActivityType.dining,
  String? scheduledOn = '2026-08-15',
  TimeOfDaySlot? timeOfDaySlot = TimeOfDaySlot.evening,
  String? location = 'quán góc phố',
  int? durationMinutes = 90,
}) =>
    ActivityCard(
      id: id,
      ownerKey: 'owner',
      title: title,
      status: ActivityCardStatus.scheduled,
      origin: ActivityCardOrigin.manual,
      activityType: activityType,
      scheduledOn: scheduledOn,
      timeOfDaySlot: timeOfDaySlot,
      location: location,
      durationMinutes: durationMinutes,
      invited: false,
      replyState: ActivityCardReplyState.notAnswered,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

NotebookEntry _entry(String id, NotebookKind kind, String value) => NotebookEntry(
      id: id,
      ownerKey: 'owner',
      kind: kind,
      value: value,
      source: ContextEntrySource.manual,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

DateScriptSentence _sentence(
  String text, {
  List<DateScriptVariable> requires = const <DateScriptVariable>[],
}) =>
    DateScriptSentence(text: text, requires: requires, aboutPartner: false);

/// One preset whose `before` part carries an unconditional sentence plus one
/// sentence per variable, so a single render exercises the whole drop matrix.
DateScriptPreset _matrixPreset() => DateScriptPreset(
      id: 'matrix.v1',
      activityTypes: const <ActivityType>[],
      parts: <DateScriptPartContent>[
        DateScriptPartContent(
          part: DateScriptPart.before,
          sentences: <DateScriptSentence>[
            _sentence('Neo.'),
            for (final DateScriptVariable variable in DateScriptVariable.values)
              _sentence(
                '${variable.wireValue}=<{${variable.wireValue}}>',
                requires: <DateScriptVariable>[variable],
              ),
          ],
        ),
        DateScriptPartContent(
          part: DateScriptPart.during,
          sentences: <DateScriptSentence>[_sentence('Trong.')],
        ),
        DateScriptPartContent(
          part: DateScriptPart.after,
          sentences: <DateScriptSentence>[_sentence('Sau.')],
        ),
      ],
    );

void main() {
  group('bindVariables', () {
    test('reads the five card fields and the two notebook kinds', () {
      final Map<DateScriptVariable, String> values = bindVariables(
        _card(),
        <NotebookEntry>[
          _entry('n-1', NotebookKind.interest, 'nhạc indie'),
          _entry('n-2', NotebookKind.event, 'sinh nhật 20/9'),
        ],
      );

      expect(values[DateScriptVariable.activity], 'Đi cà phê');
      expect(values[DateScriptVariable.date], 'Thứ Bảy 15/8');
      expect(values[DateScriptVariable.time], 'tối');
      expect(values[DateScriptVariable.place], 'quán góc phố');
      expect(values[DateScriptVariable.duration], '1 tiếng 30 phút');
      expect(values[DateScriptVariable.interest], 'nhạc indie');
      expect(values[DateScriptVariable.event], 'sinh nhật 20/9');
    });

    test('omits a missing card field rather than binding an empty string', () {
      final Map<DateScriptVariable, String> values = bindVariables(
        _card(
          scheduledOn: null,
          timeOfDaySlot: null,
          location: null,
          durationMinutes: null,
        ),
        const <NotebookEntry>[],
      );

      expect(values.containsKey(DateScriptVariable.date), isFalse);
      expect(values.containsKey(DateScriptVariable.time), isFalse);
      expect(values.containsKey(DateScriptVariable.place), isFalse);
      expect(values.containsKey(DateScriptVariable.duration), isFalse);
      expect(values.values, isNot(contains('')));
    });

    test('omits a whitespace-only location', () {
      final Map<DateScriptVariable, String> values =
          bindVariables(_card(location: '   '), const <NotebookEntry>[]);

      expect(values.containsKey(DateScriptVariable.place), isFalse);
    });

    test('trims the value it does bind', () {
      final Map<DateScriptVariable, String> values =
          bindVariables(_card(location: '  quán góc phố  '), const <NotebookEntry>[]);

      expect(values[DateScriptVariable.place], 'quán góc phố');
    });

    test('an empty notebook binds neither interest nor event', () {
      final Map<DateScriptVariable, String> values =
          bindVariables(_card(), const <NotebookEntry>[]);

      expect(values.containsKey(DateScriptVariable.interest), isFalse);
      expect(values.containsKey(DateScriptVariable.event), isFalse);
    });

    test('picks the lowest notebook id regardless of the order passed in', () {
      final List<NotebookEntry> shuffled = <NotebookEntry>[
        _entry('n-7', NotebookKind.interest, 'bóng rổ'),
        _entry('n-2', NotebookKind.interest, 'nhạc indie'),
        _entry('n-5', NotebookKind.interest, 'cà phê'),
      ];

      expect(
        bindVariables(_card(), shuffled)[DateScriptVariable.interest],
        'nhạc indie',
      );
      expect(
        bindVariables(_card(), shuffled.reversed.toList())[
            DateScriptVariable.interest],
        'nhạc indie',
      );
    });

    test('an entry of the other kind never fills a variable', () {
      final Map<DateScriptVariable, String> values = bindVariables(
        _card(),
        <NotebookEntry>[_entry('n-1', NotebookKind.event, 'sinh nhật 20/9')],
      );

      expect(values.containsKey(DateScriptVariable.interest), isFalse);
      expect(values[DateScriptVariable.event], 'sinh nhật 20/9');
    });

    test('is deterministic across repeated calls', () {
      final ActivityCard card = _card();
      final List<NotebookEntry> notebook = <NotebookEntry>[
        _entry('n-1', NotebookKind.interest, 'nhạc indie'),
      ];

      final Map<DateScriptVariable, String> first =
          bindVariables(card, notebook);
      for (int i = 0; i < 20; i++) {
        expect(bindVariables(card, notebook), first);
      }
    });
  });

  group('renderPart', () {
    test('drops exactly the sentences that need the one missing variable', () {
      final DateScriptPreset preset = _matrixPreset();
      final Map<DateScriptVariable, String> full = <DateScriptVariable, String>{
        for (final DateScriptVariable variable in DateScriptVariable.values)
          variable: 'V-${variable.wireValue}',
      };

      for (final DateScriptVariable missing in DateScriptVariable.values) {
        final Map<DateScriptVariable, String> values =
            Map<DateScriptVariable, String>.from(full)..remove(missing);
        final List<String> rendered =
            renderPart(preset, DateScriptPart.before, values);

        expect(
          rendered,
          isNot(contains(startsWith('${missing.wireValue}='))),
          reason: '${missing.wireValue} sentence survived without its value',
        );
        for (final DateScriptVariable kept in DateScriptVariable.values) {
          if (kept == missing) {
            continue;
          }
          expect(
            rendered,
            contains('${kept.wireValue}=<V-${kept.wireValue}>'),
            reason: '${kept.wireValue} sentence was dropped by mistake',
          );
        }
        expect(rendered, contains('Neo.'));
      }
    });

    test('keeps the unconditional sentence when nothing is bound', () {
      expect(
        renderPart(
          _matrixPreset(),
          DateScriptPart.before,
          const <DateScriptVariable, String>{},
        ),
        <String>['Neo.'],
      );
    });

    test('substitutes every placeholder of a surviving sentence', () {
      final DateScriptPreset preset = DateScriptPreset(
        id: 'two.v1',
        activityTypes: const <ActivityType>[],
        parts: <DateScriptPartContent>[
          DateScriptPartContent(
            part: DateScriptPart.before,
            sentences: <DateScriptSentence>[
              _sentence(
                '{place} tầm {time} thường vắng hơn.',
                requires: <DateScriptVariable>[
                  DateScriptVariable.place,
                  DateScriptVariable.time,
                ],
              ),
            ],
          ),
        ],
      );

      expect(
        renderPart(preset, DateScriptPart.before, <DateScriptVariable, String>{
          DateScriptVariable.place: 'quán góc phố',
          DateScriptVariable.time: 'tối',
        }),
        <String>['quán góc phố tầm tối thường vắng hơn.'],
      );
    });

    test('reads only the part it was asked for', () {
      final DateScriptPreset preset = _matrixPreset();

      expect(renderPart(preset, DateScriptPart.during,
          const <DateScriptVariable, String>{}), <String>['Trong.']);
      expect(renderPart(preset, DateScriptPart.after,
          const <DateScriptVariable, String>{}), <String>['Sau.']);
    });

    test('preserves the authored order of the surviving sentences', () {
      final DateScriptPreset preset = DateScriptPreset(
        id: 'order.v1',
        activityTypes: const <ActivityType>[],
        parts: <DateScriptPartContent>[
          DateScriptPartContent(
            part: DateScriptPart.before,
            sentences: <DateScriptSentence>[
              _sentence('Một.'),
              _sentence('Hai {place}.',
                  requires: <DateScriptVariable>[DateScriptVariable.place]),
              _sentence('Ba.'),
            ],
          ),
        ],
      );

      expect(
        renderPart(preset, DateScriptPart.before,
            const <DateScriptVariable, String>{DateScriptVariable.place: 'X'}),
        <String>['Một.', 'Hai X.', 'Ba.'],
      );
    });
  });

  group('renderScript', () {
    test('joins surviving sentences with exactly one space', () {
      final Map<DateScriptPart, String> script = renderScript(
        _matrixPreset(),
        const <DateScriptVariable, String>{DateScriptVariable.place: 'X'},
      );

      expect(script[DateScriptPart.before], 'Neo. place=<X>');
      expect(script[DateScriptPart.during], 'Trong.');
      expect(script[DateScriptPart.after], 'Sau.');
    });

    test('carries all three parts', () {
      expect(
        renderScript(_matrixPreset(), const <DateScriptVariable, String>{}).keys,
        DateScriptPart.values,
      );
    });
  });

  group('the shipped pack end to end', () {
    test('leaves no brace behind for any card/notebook combination', () {
      final ContentPackage<DateScriptPreset> pack = _shippedPack();
      final List<List<NotebookEntry>> notebooks = <List<NotebookEntry>>[
        const <NotebookEntry>[],
        <NotebookEntry>[_entry('n-1', NotebookKind.interest, 'nhạc indie')],
        <NotebookEntry>[_entry('n-1', NotebookKind.event, 'sinh nhật 20/9')],
        <NotebookEntry>[
          _entry('n-1', NotebookKind.interest, 'nhạc indie'),
          _entry('n-2', NotebookKind.event, 'sinh nhật 20/9'),
        ],
      ];
      final List<ActivityCard> cards = <ActivityCard>[
        for (final ActivityType? type in <ActivityType?>[
          ...ActivityType.values,
          null,
        ]) ...<ActivityCard>[
          _card(id: 'full-$type', activityType: type),
          _card(
            id: 'bare-$type',
            activityType: type,
            scheduledOn: null,
            timeOfDaySlot: null,
            location: null,
            durationMinutes: null,
          ),
        ],
      ];

      for (final ActivityCard card in cards) {
        for (final List<NotebookEntry> notebook in notebooks) {
          final Map<DateScriptPart, String> script = renderScript(
            selectPreset(pack, card),
            bindVariables(card, notebook),
          );
          for (final DateScriptPart part in DateScriptPart.values) {
            final String body = script[part]!;
            expect(body, isNot(contains('{')), reason: '${card.id} / $part');
            expect(body, isNot(contains('}')), reason: '${card.id} / $part');
          }
        }
      }
    });

    test('every part still reads with an empty notebook and a bare card', () {
      final ContentPackage<DateScriptPreset> pack = _shippedPack();

      for (final ActivityType? type in <ActivityType?>[
        ...ActivityType.values,
        null,
      ]) {
        final ActivityCard card = _card(
          id: 'bare-$type',
          activityType: type,
          scheduledOn: null,
          timeOfDaySlot: null,
          location: null,
          durationMinutes: null,
        );
        final Map<DateScriptPart, String> script = renderScript(
          selectPreset(pack, card),
          bindVariables(card, const <NotebookEntry>[]),
        );

        for (final DateScriptPart part in DateScriptPart.values) {
          expect(
            script[part],
            isNotEmpty,
            reason: '${type?.wireValue ?? 'null'} lost its ${part.wireValue}',
          );
        }
      }
    });

    test('the same card and notebook render identically twice', () {
      final ContentPackage<DateScriptPreset> pack = _shippedPack();
      final ActivityCard card = _card();
      final List<NotebookEntry> notebook = <NotebookEntry>[
        _entry('n-1', NotebookKind.interest, 'nhạc indie'),
      ];

      Map<DateScriptPart, String> render() => renderScript(
            selectPreset(pack, card),
            bindVariables(card, notebook),
          );

      final Map<DateScriptPart, String> first = render();
      for (int i = 0; i < 20; i++) {
        expect(render(), first);
      }
    });
  });
}
