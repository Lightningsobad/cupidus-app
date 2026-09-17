import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Phase P5: the location lock (R-13, AC-2/AC-3) asserted as evidence about the
/// shipped source, not as a convention anyone has to remember.
///
/// These are static checks on purpose. A navigation test can only prove that
/// one door works; only reading every import can prove no second door exists.
const String _featureDir = 'lib/features/your_view_portrait';
const String _entryPoint =
    '$_featureDir/your_view_portrait_entry_point.dart';

/// Import URIs resolved to repo-relative paths. Substring matching on
/// `features/your_view_portrait/` would pass vacuously, because `lib/` imports
/// its neighbours relatively: `'../../your_view_portrait/...'` contains the
/// feature name in neither the form the matcher expects nor a stable one.
List<String> _resolvedDartDependencies(File file) {
  final RegExp directive = RegExp(
    r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
    multiLine: true,
  );
  final Uri base = Uri.file(file.absolute.path);
  final String root = Directory.current.absolute.path;

  final List<String> resolved = <String>[];
  for (final RegExpMatch match in directive.allMatches(file.readAsStringSync())) {
    final String uri = match.group(1)!;
    String absolute;
    if (uri.startsWith('dart:')) {
      continue;
    } else if (uri.startsWith('package:cupid_mobile/')) {
      absolute = '$root/lib/${uri.substring('package:cupid_mobile/'.length)}';
    } else if (uri.startsWith('package:')) {
      continue;
    } else {
      absolute = base.resolve(uri).toFilePath();
    }
    resolved.add(
      absolute.startsWith('$root/') ? absolute.substring(root.length + 1) : absolute,
    );
  }
  return resolved;
}

/// Comments stripped: these files explain in prose why they do not use
/// `routeName` or `pushReplacement`, and a matcher that counts those sentences
/// as violations would force the explanation out of the code.
String _codeOnly(String source) => source
    .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '')
    .replaceAll(RegExp(r'^\s*//.*$', multiLine: true), '');

List<File> _dartFilesUnder(String directory) => Directory(directory)
    .listSync(recursive: true)
    .whereType<File>()
    .where((File file) => file.path.endsWith('.dart'))
    .toList();

void main() {
  group('khoá vị trí R-13', () {
    test('no route table entry can reach the portrait (AC-2, AC-3)', () {
      final String source = File('lib/app/cupid_app.dart').readAsStringSync();
      final int start = source.indexOf('routes: <String, WidgetBuilder>{');
      expect(start, isNot(-1), reason: 'the real routes map moved');
      final int end = source.indexOf('},', start);
      final String routes = source.substring(start, end);

      expect(routes.toLowerCase(), isNot(contains('portrait')));
      // And the screen has no name a route table could be given later.
      final String screen = _codeOnly(
        File(
          '$_featureDir/presentation/screens/your_view_portrait_screen.dart',
        ).readAsStringSync(),
      );
      expect(screen, isNot(contains('routeName')));
    });

    test('only the feature itself imports the portrait internals (AC-3)', () {
      final List<String> violations = <String>[];

      for (final File file in _dartFilesUnder('lib')) {
        final String path = file.path;
        if (path.startsWith(_featureDir)) {
          continue;
        }
        for (final String dependency in _resolvedDartDependencies(file)) {
          if (!dependency.startsWith(_featureDir)) {
            continue;
          }
          if (dependency == _entryPoint) {
            continue;
          }
          violations.add('$path -> $dependency');
        }
      }

      expect(violations, isEmpty);
    });

    test('the door itself widens nothing (AC-3)', () {
      final String entry = _codeOnly(File(_entryPoint).readAsStringSync());

      // No `export` at all: re-exporting the screen, the cubit, or the
      // repository would hand every caller a second way in.
      expect(RegExp(r'^\s*export\s', multiLine: true).hasMatch(entry), isFalse);
      expect(entry, contains('enum PortraitEntrySource'));
      expect(entry, contains('Future<void> openYourViewPortrait('));
      // Closing the portrait must return the source flow untouched (AC-4).
      expect(entry, isNot(contains('pushReplacement')));
      expect(entry, isNot(contains('rootNavigator')));
      expect(entry, isNot(contains('popUntil')));
    });

    test('no menu, tab, or shell surface names the screen (AC-2)', () {
      final List<String> mentions = <String>[];

      for (final File file in _dartFilesUnder('lib')) {
        if (file.path.startsWith(_featureDir)) {
          continue;
        }
        if (file.readAsStringSync().contains('YourViewPortraitScreen')) {
          mentions.add(file.path);
        }
      }

      expect(mentions, isEmpty);
    });
  });
}
