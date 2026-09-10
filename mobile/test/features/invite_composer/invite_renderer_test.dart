import 'dart:convert';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/features/invite_composer/domain/invite_preset.dart';
import 'package:cupid_mobile/features/invite_composer/domain/invite_renderer.dart';
import 'package:cupid_mobile/features/invite_composer/domain/mad_libs.dart';
import 'package:flutter_test/flutter_test.dart';

const String _schemaId = 'req016.presets.v1';

const Map<String, Object?> _declineDoor = <String, Object?>{
  'text': 'Bận thì nhắn "để hôm khác" là tớ hiểu ngay.',
  'requires': <String>[],
  'targets': 'neutral',
  'role': 'decline_door',
};

InvitePreset _parsePreset(List<Map<String, Object?>> clauses) {
  final ContentPackage<InvitePreset> package =
      ContentPackage.parse<InvitePreset>(
        jsonEncode(<String, Object?>{
          'id': 'presets.invite',
          'version': '1.0.0',
          'schema_id': _schemaId,
          'locale': 'vi',
          'items': <Map<String, Object?>>[
            <String, Object?>{
              'id': 'invite.rap_phim.v1',
              'frame': 'Rạp phim',
              'clauses': clauses,
            },
          ],
        }),
        expectedSchemaId: _schemaId,
        itemParser: invitePresetFromJson,
        source: 'test.presets.json',
      );
  return package.items.single;
}

InvitePreset _fullPreset() => _parsePreset(<Map<String, Object?>>[
  <String, Object?>{
    'text': '{date} tớ có suất {activity} mà chưa rủ được ai.',
    'requires': <String>['date', 'activity'],
    'targets': 'sender',
  },
  <String, Object?>{
    'text': 'Ở {place} nhé.',
    'requires': <String>['place'],
    'targets': 'neutral',
  },
  <String, Object?>{
    'text': 'Chắc {duration} là xong.',
    'requires': <String>['duration'],
    'targets': 'neutral',
  },
  _declineDoor,
]);

MadLibsValues _values(Set<MadLibsVariable> present) =>
    MadLibsValues(<MadLibsVariable, String>{
      for (final MadLibsVariable variable in present)
        variable: switch (variable) {
          MadLibsVariable.activity => 'phim Dune',
          MadLibsVariable.date => 'Thứ Bảy 15/8',
          MadLibsVariable.time => 'tối',
          MadLibsVariable.place => 'CGV Vincom',
          MadLibsVariable.duration => '2 tiếng',
        },
    });

void main() {
  group('invitePresetFromJson', () {
    test('parses the contract example shape', () {
      final InvitePreset preset = _fullPreset();

      expect(preset.id, 'invite.rap_phim.v1');
      expect(preset.frame, 'Rạp phim');
      expect(preset.clauses, hasLength(4));
      expect(preset.clauses.first.targets, ClauseTarget.sender);
      expect(preset.clauses.first.requires, <MadLibsVariable>[
        MadLibsVariable.date,
        MadLibsVariable.activity,
      ]);
      expect(preset.clauses.last.role, ClauseRole.declineDoor);
      expect(preset.clauses.last.requires, isEmpty);
    });

    test('rejects targets "recipient"', () {
      expect(
        () => _parsePreset(<Map<String, Object?>>[
          <String, Object?>{
            'text': 'Cậu hay quên lắm.',
            'requires': <String>[],
            'targets': 'recipient',
          },
          _declineDoor,
        ]),
        throwsA(isA<ContentPackageFormatException>()),
      );
    });

    test('rejects an unknown clause role', () {
      expect(
        () => _parsePreset(<Map<String, Object?>>[
          <String, Object?>{
            'text': 'Đi nhé.',
            'requires': <String>[],
            'targets': 'neutral',
            'role': 'nudge',
          },
        ]),
        throwsA(isA<ContentPackageFormatException>()),
      );
    });

    test('rejects a requires entry outside the closed variable set', () {
      expect(
        () => _parsePreset(<Map<String, Object?>>[
          <String, Object?>{
            'text': 'Đi nhé.',
            'requires': <String>['mood'],
            'targets': 'neutral',
          },
        ]),
        throwsA(isA<ContentPackageFormatException>()),
      );
    });

    test('rejects a placeholder outside the closed variable set', () {
      expect(
        () => _parsePreset(<Map<String, Object?>>[
          <String, Object?>{
            'text': 'Ở {địa_điểm} nhé.',
            'requires': <String>[],
            'targets': 'neutral',
          },
        ]),
        throwsA(isA<ContentPackageFormatException>()),
      );
    });

    test('rejects a placeholder that is not gated by requires', () {
      expect(
        () => _parsePreset(<Map<String, Object?>>[
          <String, Object?>{
            'text': 'Ở {place} nhé.',
            'requires': <String>[],
            'targets': 'neutral',
          },
        ]),
        throwsA(isA<ContentPackageFormatException>()),
      );
    });

    test('rejects a missing mandatory field instead of defaulting', () {
      expect(
        () => _parsePreset(<Map<String, Object?>>[
          <String, Object?>{'text': 'Đi nhé.', 'requires': <String>[]},
        ]),
        throwsA(isA<ContentPackageFormatException>()),
      );
      expect(
        () => _parsePreset(<Map<String, Object?>>[]),
        throwsA(isA<ContentPackageFormatException>()),
      );
    });

    test('ignores unknown keys at clause level', () {
      final InvitePreset preset = _parsePreset(<Map<String, Object?>>[
        <String, Object?>{
          'text': 'Đi nhé.',
          'requires': <String>[],
          'targets': 'neutral',
          'tone': 'playful',
        },
      ]);

      expect(preset.clauses.single.role, isNull);
    });
  });

  group('renderInvite', () {
    test('is deterministic across repeated renders', () {
      final InvitePreset preset = _fullPreset();
      final MadLibsValues values = _values(MadLibsVariable.values.toSet());

      expect(renderInvite(preset, values), renderInvite(preset, values));
    });

    test('fills every placeholder when all five variables are present', () {
      final String rendered = renderInvite(
        _fullPreset(),
        _values(MadLibsVariable.values.toSet()),
      );

      expect(
        rendered,
        'Thứ Bảy 15/8 tớ có suất phim Dune mà chưa rủ được ai. '
        'Ở CGV Vincom nhé. Chắc 2 tiếng là xong. '
        'Bận thì nhắn "để hôm khác" là tớ hiểu ngay.',
      );
    });

    test('drops the whole clause when place is missing', () {
      final String rendered = renderInvite(
        _fullPreset(),
        _values(<MadLibsVariable>{
          MadLibsVariable.activity,
          MadLibsVariable.date,
          MadLibsVariable.time,
          MadLibsVariable.duration,
        }),
      );

      expect(rendered, isNot(contains('CGV')));
      expect(rendered, isNot(contains('Ở ')));
      expect(rendered, contains('Chắc 2 tiếng là xong.'));
    });

    test(
      'reads cleanly for every subset of the five variables',
      () {
        final InvitePreset preset = _fullPreset();
        final List<MadLibsVariable> all = MadLibsVariable.values;

        for (int mask = 0; mask < 1 << 5; mask++) {
          final Set<MadLibsVariable> present = <MadLibsVariable>{
            for (int i = 0; i < all.length; i++)
              if (mask & (1 << i) != 0) all[i],
          };
          final String rendered = renderInvite(preset, _values(present));
          final String reason = 'present: $present';

          expect(rendered, isNot(contains('{')), reason: reason);
          expect(rendered, isNot(contains('}')), reason: reason);
          expect(rendered, isNot(contains('  ')), reason: reason);
          expect(rendered, rendered.trim(), reason: reason);
          expect(rendered, isNotEmpty, reason: reason);
        }
      },
    );

    test('keeps the decline door for every subset', () {
      final InvitePreset preset = _fullPreset();
      final List<MadLibsVariable> all = MadLibsVariable.values;

      for (int mask = 0; mask < 1 << 5; mask++) {
        final Set<MadLibsVariable> present = <MadLibsVariable>{
          for (int i = 0; i < all.length; i++)
            if (mask & (1 << i) != 0) all[i],
        };

        expect(
          renderInvite(preset, _values(present)),
          contains('Bận thì nhắn "để hôm khác" là tớ hiểu ngay.'),
          reason: 'present: $present',
        );
      }
    });

    test('renders nothing but the decline door when every variable is absent', () {
      expect(
        renderInvite(_fullPreset(), _values(const <MadLibsVariable>{})),
        'Bận thì nhắn "để hôm khác" là tớ hiểu ngay.',
      );
    });

    test('keeps clause order and does not edit case or punctuation', () {
      final InvitePreset preset = _parsePreset(<Map<String, Object?>>[
        <String, Object?>{
          'text': 'buổi {time} nhé',
          'requires': <String>['time'],
          'targets': 'neutral',
        },
        <String, Object?>{
          'text': 'Ở {place}.',
          'requires': <String>['place'],
          'targets': 'neutral',
        },
      ]);

      expect(
        renderInvite(
          preset,
          _values(<MadLibsVariable>{
            MadLibsVariable.time,
            MadLibsVariable.place,
          }),
        ),
        'buổi tối nhé Ở CGV Vincom.',
      );
    });
  });
}
