import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Directories that must consume the design system through its public
/// contract instead of forking screen code per platform/theme (AC 4,
/// `architecture/solution.md` D3/ADR-004). Only `design_system/` itself may
/// contain a raw color literal or a `Platform.is*`/`defaultTargetPlatform`
/// branch.
const List<String> _guardedDirs = <String>[
  'lib/features',
  'lib/app',
  'lib/core',
];

/// Substrings that indicate a forked, non-token-driven implementation if
/// found in a guarded directory.
const List<String> _forbiddenPatterns = <String>[
  'Color(0x',
  'Colors.',
  'Platform.is',
  'defaultTargetPlatform',
];

void main() {
  test(
    'AC 4 no-fork guard: features/app/core never fork on a raw color '
    'literal or Platform.is*/defaultTargetPlatform',
    () {
      final List<String> violations = <String>[];

      for (final String dirPath in _guardedDirs) {
        final Directory dir = Directory(dirPath);
        if (!dir.existsSync()) {
          continue;
        }

        for (final FileSystemEntity entity in dir.listSync(recursive: true)) {
          if (entity is! File || !entity.path.endsWith('.dart')) {
            continue;
          }

          final List<String> lines = entity.readAsLinesSync();
          for (int i = 0; i < lines.length; i++) {
            final String line = lines[i];
            for (final String pattern in _forbiddenPatterns) {
              if (line.contains(pattern)) {
                violations.add(
                  '${entity.path}:${i + 1}: forbidden pattern "$pattern"',
                );
              }
            }
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Screens must consume the design system through ThemeExtension '
            'tokens and the named adaptive widgets, never a raw color '
            'literal or Platform.is*/defaultTargetPlatform branch '
            '(architecture/solution.md D3/ADR-004):\n'
            '${violations.join('\n')}',
      );
    },
  );
}
