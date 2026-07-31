import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// AC2 (only "nhắc nhở đồng bộ"/"synced reminder" copy ships), AC3 (this
// guard is the durable compliance gate every future surface must keep
// green), AC4 (no native-alarm/local-notification dependency), ADR-002
// (canonical wording) -- do not delete this test to unblock a copy change.

/// Matches Dart single- and double-quoted string literal *contents*. Applied
/// only to non-comment lines: the canonical copy source
/// `reminder_strings.dart` names these same forbidden phrases inside a `///`
/// doc comment explaining the rule, and that explanation must not itself
/// trip the guard.
final RegExp _singleQuoted = RegExp(r"'([^'\\]*(?:\\.[^'\\]*)*)'");
final RegExp _doubleQuoted = RegExp(r'"([^"\\]*(?:\\.[^"\\]*)*)"');

const List<String> _forbiddenTokens = [
  'báo thức',
  'synced alarm',
  'do not disturb',
];

const List<String> _forbiddenDependencies = [
  'android_alarm_manager',
  'flutter_local_notifications',
  'alarm',
  'awesome_notifications',
];

void main() {
  test(
    'mobile/lib string literals never say '
    '"báo thức"/"Synced Alarm"/"Do Not Disturb" (AC2/AC3, ADR-002)',
    () {
      final offenses = <String>[];
      // Deliberately excludes `mobile/openapi/`, the generated client
      // carrying the frozen `Epic 3 - Synced Alarms` backend tag name.
      final dartFiles = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));

      for (final file in dartFiles) {
        final lines = file.readAsLinesSync();
        for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
          final line = lines[lineIndex];
          if (line.trimLeft().startsWith('//')) continue;
          final literalContents = <String>[
            ..._singleQuoted.allMatches(line).map((m) => m.group(1) ?? ''),
            ..._doubleQuoted.allMatches(line).map((m) => m.group(1) ?? ''),
          ];
          for (final literal in literalContents) {
            final lowered = literal.toLowerCase();
            for (final token in _forbiddenTokens) {
              if (lowered.contains(token)) {
                offenses.add(
                  '${file.path}:${lineIndex + 1}: forbidden token "$token"',
                );
              }
            }
          }
        }
      }

      expect(offenses, isEmpty, reason: offenses.join('\n'));
    },
  );

  test(
    'pubspec.yaml declares no native-alarm/local-notification dependency (AC4)',
    () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      for (final dependency in _forbiddenDependencies) {
        final declared = RegExp(
          '^\\s*$dependency\\s*:',
          multiLine: true,
        ).hasMatch(pubspec);
        expect(
          declared,
          isFalse,
          reason:
              'pubspec.yaml must not declare the "$dependency" dependency '
              '(AC4).',
        );
      }
    },
  );
}
