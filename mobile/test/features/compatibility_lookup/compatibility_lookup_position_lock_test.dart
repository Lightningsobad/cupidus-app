import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Screen (10) is position-locked: it exists only at the end of a surface that
/// already knows why the reader is there (AC-2/AC-3). That is a property of the
/// whole `lib/` tree, not of any one widget, so it is asserted by reading the
/// tree.
const String _entryPoint =
    'lib/features/compatibility_lookup/compatibility_lookup_entry_point.dart';
const String _screen = 'lib/features/compatibility_lookup/presentation/screens/'
    'compatibility_lookup_screen.dart';
const String _feature = 'lib/features/compatibility_lookup';
const String _appRoot = 'lib/app/cupid_app.dart';

List<File> _dartFilesUnder(String directory) => Directory(directory)
    .listSync(recursive: true)
    .whereType<File>()
    .where((File file) => file.path.endsWith('.dart'))
    .toList();

/// The repo-relative path an `import` in [fromFile] actually points at, or null
/// for an import that leaves this package (`dart:`, third-party `package:`).
///
/// Resolving is the whole point: `lib/` imports its neighbours relatively, so a
/// substring check for `features/context_notebook/` matches nothing and passes
/// while a real violation sits in the file.
String? _resolveImport(String fromFile, String importUri) {
  const String packagePrefix = 'package:cupid_mobile/';
  if (importUri.startsWith(packagePrefix)) {
    return 'lib/${importUri.substring(packagePrefix.length)}';
  }
  if (importUri.contains(':')) {
    return null;
  }
  final String resolved = Uri.file(File(fromFile).absolute.path)
      .resolve(importUri)
      .toFilePath();
  final String root = Directory.current.absolute.path;
  return resolved.startsWith('$root${Platform.pathSeparator}')
      ? resolved.substring(root.length + 1)
      : resolved;
}

/// Source with comments removed.
///
/// The bans below are about what the code does, and the files that implement
/// the position lock are precisely the files that have to explain it: the entry
/// point's own doc comment names `routeName` and `pushNamed` to say they are
/// absent.
String _code(String source) => source
    .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '')
    .split('\n')
    .where((String line) => !line.trimLeft().startsWith('//'))
    .join('\n');

final RegExp _importPattern = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

void main() {
  test('the entry point is the only file that constructs the screen', () {
    final List<String> constructors = <String>[
      for (final File file in _dartFilesUnder('lib'))
        if (file.path != _entryPoint &&
            file.path != _screen &&
            file.readAsStringSync().contains('CompatibilityLookupScreen('))
          file.path,
    ];

    expect(
      constructors,
      isEmpty,
      reason: 'screen (10) is built by openCompatibilityLookup and nowhere else',
    );
  });

  test('gift ideas is the only call site of the entry point in lib/', () {
    final List<String> callers = <String>[
      for (final File file in _dartFilesUnder('lib'))
        if (file.path != _entryPoint &&
            file.readAsStringSync().contains('openCompatibilityLookup('))
          file.path,
    ];

    expect(callers, <String>[
      'lib/features/gift_ideas/presentation/screens/gift_ideas_screen.dart',
    ]);
  });

  test('the app shell does not know the screen exists', () {
    final String app = File(_appRoot).readAsStringSync();

    // No import, no `routes:` entry, no typed route: adding any one of them
    // would turn a door at the end of one surface into an address anything can
    // reach (AC-3).
    expect(app.contains('compatibility_lookup'), isFalse);
    expect(app.contains('CompatibilityLookupScreen'), isFalse);
    expect(app.contains('openCompatibilityLookup'), isFalse);
  });

  test('the feature declares no route name and pushes no named route', () {
    for (final File file in _dartFilesUnder(_feature)) {
      final String source = _code(file.readAsStringSync());
      expect(
        source.contains('routeName'),
        isFalse,
        reason: '${file.path} declares a route name for a position-locked '
            'screen',
      );
      expect(
        source.contains('settings:'),
        isFalse,
        reason: '${file.path} names the route it pushes, which makes the '
            'screen reachable by pushNamed',
      );
    }
  });

  test('nothing in lib/ reaches the screen through pushNamed', () {
    for (final File file in _dartFilesUnder('lib')) {
      final String source = _code(file.readAsStringSync());
      if (!source.contains('pushNamed')) {
        continue;
      }
      expect(
        source.contains('compatibility'),
        isFalse,
        reason: '${file.path} pushes a named route into the compatibility '
            'table',
      );
    }
  });

  test('the feature never imports the context notebook (BR-10)', () {
    int resolved = 0;
    for (final File file in _dartFilesUnder(_feature)) {
      final List<String> imported = <String>[
        for (final RegExpMatch match
            in _importPattern.allMatches(file.readAsStringSync()))
          if (_resolveImport(file.path, match.group(1)!) case final String path)
            path,
      ];

      // Resolved paths, not raw URIs. The screen may not write to the notebook
      // (BR-10, STORY-004's contract), and the cheapest way to keep that true
      // is to have no path to it at all.
      for (final String target in imported) {
        resolved += 1;
        expect(
          target.startsWith('lib/features/context_notebook/'),
          isFalse,
          reason: '${file.path} imports $target',
        );
      }
    }

    // A resolver that silently returned nothing would make every assertion
    // above vacuous, which is exactly how this class of test rots.
    expect(resolved, greaterThan(0));
  });

  test('the import resolver actually resolves, so the check above can fail', () {
    expect(
      _resolveImport(_screen, '../../../context_notebook/x.dart'),
      'lib/features/context_notebook/x.dart',
    );
    expect(
      _resolveImport(_screen, 'package:cupid_mobile/features/y.dart'),
      'lib/features/y.dart',
    );
    expect(_resolveImport(_screen, 'package:flutter/material.dart'), isNull);
    expect(_code('/// pushNamed\n// routeName\nvoid f() {}'), isNot(contains('pushNamed')));
  });
}
