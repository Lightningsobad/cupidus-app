import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `HARDCODED-COPY`: the Android half of AC-37/BR-15.
///
/// The widget is the surface where a display string is easiest to embed and
/// hardest to notice, so this scans the real source tree rather than reviewing
/// it by eye. Swapping the content packages for an out-of-repo CMS must not
/// require touching a single `.kt` or `.xml` file, and the enforceable form of
/// that promise is: outside comments, the native sources are pure ASCII
/// identifiers.
const String _nativeRoot = 'android/app/src/main';

const String _providerPath =
    '$_nativeRoot/kotlin/com/snapsofts/cupid/CupidPhaseWidgetProvider.kt';
const String _layoutPath = '$_nativeRoot/res/layout/cupid_phase_widget.xml';
const String _infoPath = '$_nativeRoot/res/xml/cupid_phase_widget_info.xml';
const String _manifestPath = '$_nativeRoot/AndroidManifest.xml';

List<File> _nativeSources() => Directory(_nativeRoot)
    .listSync(recursive: true)
    .whereType<File>()
    .where((File file) =>
        file.path.endsWith('.kt') || file.path.endsWith('.xml'))
    .toList(growable: false);

/// Comment bodies are not shipped copy, so they are removed before the scan.
/// Block comments go whole; line comments go only when the line is nothing but
/// a comment, which keeps a URL inside a string literal intact and leaves a
/// trailing `// ...` note subject to the same ASCII rule as the code.
String _withoutComments(String source) => source
    .replaceAll(RegExp(r'<!--[\s\S]*?-->'), '')
    .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '')
    .split('\n')
    .where((String line) {
      final String trimmed = line.trimLeft();
      return !trimmed.startsWith('//') && !trimmed.startsWith('*');
    })
    .join('\n');

Iterable<String> _stringLiterals(String source) =>
    RegExp(r'"([^"\\\n]*)"').allMatches(source).map((Match m) => m.group(1)!);

void main() {
  group('no native file carries a display string (AC-37/BR-15)', () {
    test('the scan actually reaches the widget sources', () {
      final List<String> paths =
          _nativeSources().map((File file) => file.path).toList();
      expect(paths, contains(_providerPath));
      expect(paths, contains(_layoutPath));
      expect(paths, contains(_infoPath));
      expect(paths, contains(_manifestPath));
    });

    test('stripping comments leaves the code, and catches Vietnamese in it',
        () {
      final String stripped = _withoutComments(
        File(_providerPath).readAsStringSync(),
      );
      expect(stripped, contains('class CupidPhaseWidgetProvider'));
      expect(_stringLiterals(stripped).length, greaterThan(5));
      expect(
        RegExp(r'[^\x00-\x7F]')
            .hasMatch(_withoutComments('val a = "kỷ niệm" // ghi chú')),
        isTrue,
      );
      expect(
        RegExp(r'[^\x00-\x7F]').hasMatch(_withoutComments('<!-- ghi chú -->')),
        isFalse,
      );
    });

    test('every .kt and .xml file is pure ASCII once comments are removed', () {
      for (final File file in _nativeSources()) {
        final String code = _withoutComments(file.readAsStringSync());
        final Match? offender = RegExp(r'[^\x00-\x7F]').firstMatch(code);
        expect(
          offender,
          isNull,
          reason: '${file.path} carries a non-ASCII character '
              '"${offender?.group(0)}" outside a comment — Vietnamese copy '
              'belongs in the content packages',
        );
      }
    });

    test('the widget layout declares no text, hint or spoken string', () {
      final String layout = File(_layoutPath).readAsStringSync();
      expect(layout.contains('android:text='), isFalse);
      expect(layout.contains('android:hint='), isFalse);
      expect(layout.contains('android:contentDescription='), isFalse);
      expect(layout.contains('@string/'), isFalse);
    });

    test('the widget metadata borrows no label or description', () {
      final String info = File(_infoPath).readAsStringSync();
      expect(info.contains('android:label='), isFalse);
      expect(info.contains('android:description='), isFalse);
      expect(info.contains('@string/'), isFalse);
    });

    test('every string literal in the provider is a technical identifier', () {
      final String provider = _withoutComments(
        File(_providerPath).readAsStringSync(),
      );
      for (final String literal in _stringLiterals(provider)) {
        expect(
          RegExp(r'^[a-z0-9_]*$').hasMatch(literal),
          isTrue,
          reason: '"$literal" is not a contract key or a URI component',
        );
      }
    });
  });

  group('the provider reads the contract and nothing else', () {
    late String provider;

    setUpAll(() {
      provider = File(_providerPath).readAsStringSync();
    });

    test('it reads exactly the three payload keys a drawing needs', () {
      expect(provider.contains('"primary_line"'), isTrue);
      expect(provider.contains('"secondary_line"'), isTrue);
      expect(provider.contains('"card_id"'), isTrue);
    });

    test('it derives nothing from a date or a clock of its own', () {
      for (final String forbidden in <String>[
        'computed_on',
        'Calendar',
        'LocalDate',
        'System.currentTimeMillis',
        'AlarmManager',
        'WorkManager',
        'Handler',
      ]) {
        expect(provider.contains(forbidden), isFalse, reason: forbidden);
      }
    });

    test('it opens one deep link and offers no second action', () {
      expect(provider.contains('setOnClickPendingIntent'), isTrue);
      expect(
        'setOnClickPendingIntent'.allMatches(provider).length,
        1,
        reason: 'a widget has exactly one tap target (uiux-spec 2)',
      );
      expect(provider.contains('DEEP_LINK_SCHEME = "cupidapp"'), isTrue);
      expect(provider.contains('DEEP_LINK_CARD_HOST = "card"'), isTrue);
      expect(provider.contains('DEEP_LINK_HOME_HOST = "home"'), isTrue);
    });

    test('it never reads the card store or the database', () {
      for (final String forbidden in <String>[
        'sqlite',
        'SQLite',
        'activity_cards',
        'cupid.sqlite',
      ]) {
        expect(provider.contains(forbidden), isFalse, reason: forbidden);
      }
    });
  });

  group('the widget is registered and never wakes itself', () {
    test('the manifest declares the provider and its metadata', () {
      final String manifest = File(_manifestPath).readAsStringSync();
      expect(
        manifest.contains(
          'android:name="com.snapsofts.cupid.CupidPhaseWidgetProvider"',
        ),
        isTrue,
      );
      expect(
        manifest.contains('android:resource="@xml/cupid_phase_widget_info"'),
        isTrue,
      );
    });

    test('the manifest adds no permission for the widget', () {
      final String manifest = File(_manifestPath).readAsStringSync();
      expect(
        RegExp(r'<uses-permission').allMatches(manifest).length,
        3,
        reason: 'READ_MEDIA_IMAGES, POST_NOTIFICATIONS and CAMERA only',
      );
    });

    test('the system is told never to poll this provider (WIDGET-STALE)', () {
      final String info = File(_infoPath).readAsStringSync();
      expect(info.contains('android:updatePeriodMillis="0"'), isTrue);
    });
  });
}
