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
  // Vietnamese rendering of "Do Not Disturb": the English-only ban let a
  // translated form of the same unhonourable capability claim through
  // (REQ-002 review finding E-2, STORY-062 AC1).
  'không làm phiền',
];

const List<String> _forbiddenDependencies = [
  'android_alarm_manager',
  'alarm',
  'awesome_notifications',
];

// narrowed 2026-09-17 per user decision, cross-requirement conflict with
// REQ-016 STORY-012 P6 -- see phase-P6-evening-check-in.md §8. AC4's intent is
// that the synced-reminder feature never becomes a real device alarm, so the
// ban on this one package moved from "not declared in pubspec.yaml" to "not
// imported under lib/features/reminders/", leaving another feature free to
// schedule its own local notification.
const String _remindersForbiddenImport = 'flutter_local_notifications';

void main() {
  test(
    'mobile/lib string literals never say '
    '"báo thức"/"Synced Alarm"/"Do Not Disturb"/"không làm phiền" '
    '(AC2/AC3, ADR-002)',
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

  test(
    'lib/features/reminders never imports a local-notification plugin (AC4)',
    () {
      final offenses = <String>[];
      final dartFiles = Directory('lib/features/reminders')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));

      for (final file in dartFiles) {
        final lines = file.readAsLinesSync();
        for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
          final line = lines[lineIndex].trimLeft();
          if (!line.startsWith('import ') && !line.startsWith('export ')) {
            continue;
          }
          if (line.contains(_remindersForbiddenImport)) {
            offenses.add('${file.path}:${lineIndex + 1}: $line');
          }
        }
      }

      expect(
        offenses,
        isEmpty,
        reason:
            'the synced-reminder feature must never schedule a device alarm or '
            'local notification, so nothing under lib/features/reminders may '
            'import "$_remindersForbiddenImport" (AC4).\n'
            '${offenses.join('\n')}',
      );
    },
  );
}
