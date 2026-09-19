import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `HARDCODED-COPY`: AC-37/BR-15 on both native surfaces.
///
/// The widget is the surface where a display string is easiest to embed and
/// hardest to notice, so this scans the real source tree rather than reviewing
/// it by eye. Swapping the content packages for an out-of-repo CMS must not
/// require touching a single `.kt`, `.xml` or `.swift` file, and the
/// enforceable form of that promise is: outside comments, the native sources
/// are pure ASCII identifiers.
const String _nativeRoot = 'android/app/src/main';

const String _providerPath =
    '$_nativeRoot/kotlin/com/snapsofts/cupid/CupidPhaseWidgetProvider.kt';
const String _layoutPath = '$_nativeRoot/res/layout/cupid_phase_widget.xml';
const String _infoPath = '$_nativeRoot/res/xml/cupid_phase_widget_info.xml';
const String _manifestPath = '$_nativeRoot/AndroidManifest.xml';

const String _iosWidgetRoot = 'ios/CupidPhaseWidget';
const String _widgetSwiftPath = '$_iosWidgetRoot/CupidPhaseWidget.swift';
const String _widgetPlistPath = '$_iosWidgetRoot/Info.plist';
const String _widgetEntitlementsPath =
    '$_iosWidgetRoot/CupidPhaseWidget.entitlements';
const String _runnerEntitlementsPath = 'ios/Runner/Runner.entitlements';
const String _runnerPlistPath = 'ios/Runner/Info.plist';
const String _pbxprojPath = 'ios/Runner.xcodeproj/project.pbxproj';

const String _bridgePath =
    'lib/features/phase_status/data/home_widget_bridge.dart';

List<File> _swiftSources() => <String>['ios/Runner', _iosWidgetRoot]
    .map((String dir) => Directory(dir))
    .expand((Directory dir) => dir.listSync(recursive: true))
    .whereType<File>()
    .where((File file) => file.path.endsWith('.swift'))
    .toList(growable: false);

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

/// The identifiers Dart declares are the whole vocabulary the extension is
/// allowed to name. Reading them out of the bridge rather than restating them
/// here is what makes this a contract test: renaming a key on the Dart side
/// turns the Swift file red instead of silently blanking the widget.
Map<String, String> _dartWidgetConstants() {
  final String source = File(_bridgePath).readAsStringSync();
  return <String, String>{
    for (final Match m in RegExp(
      r"const\s+String\s+(widget[A-Za-z0-9]*)\s*=\s*'([^'\\\n]*)'",
    ).allMatches(source))
      m.group(1)!: m.group(2)!,
  };
}

/// The scheme both native sides mint their tap URL with, read from the source
/// that mints it so a rename cannot leave the app registered for the old one.
String _deepLinkScheme() => RegExp(r'DEEP_LINK_SCHEME\s*=\s*"([^"\\\n]*)"')
    .firstMatch(File(_providerPath).readAsStringSync())!
    .group(1)!;

Set<String> _deepLinkVocabulary() => RegExp(r'DEEP_LINK_[A-Z_]+\s*=\s*"([^"\\\n]*)"')
    .allMatches(File(_providerPath).readAsStringSync())
    .map((Match m) => m.group(1)!)
    .toSet();

/// The build configuration names attached to one target in `project.pbxproj`.
Set<String> _targetConfigurations(String pbxproj, String target) {
  final RegExpMatch? list = RegExp(
    'Build configuration list for PBXNativeTarget "$target" \\*/ = \\{'
    '[\\s\\S]*?buildConfigurations = \\(([\\s\\S]*?)\\);',
  ).firstMatch(pbxproj);
  if (list == null) {
    return const <String>{};
  }
  return RegExp(r'/\* (.+?) \*/')
      .allMatches(list.group(1)!)
      .map((Match m) => m.group(1)!)
      .toSet();
}

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

  group('the iOS extension carries no copy either (AC-37/BR-15)', () {
    test('the scan reaches every Swift source, including the extension', () {
      final List<String> paths =
          _swiftSources().map((File file) => file.path).toList();
      expect(paths, contains(_widgetSwiftPath));
      expect(paths, contains('ios/Runner/AppDelegate.swift'));
    });

    test('every Swift file is pure ASCII once comments are removed', () {
      for (final File file in _swiftSources()) {
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

    test('the bridge really does declare the identifiers this test reads', () {
      final Map<String, String> constants = _dartWidgetConstants();
      expect(constants['widgetIosName'], 'CupidPhaseWidget');
      expect(constants['widgetAppGroupId'], 'group.com.snapsofts.cupid');
      expect(constants['widgetKeyPrimaryLine'], 'primary_line');
      expect(_deepLinkVocabulary(), <String>{'cupidapp', 'card', 'home'});
    });

    test('every string literal in the extension comes from the contract', () {
      final Set<String> allowed = <String>{
        ..._dartWidgetConstants().values,
        ..._deepLinkVocabulary(),
        '',
        '/',
      };
      final String swift = _withoutComments(
        File(_widgetSwiftPath).readAsStringSync(),
      );
      final List<String> literals = _stringLiterals(swift).toList();
      expect(literals.length, greaterThan(8));
      for (final String literal in literals) {
        expect(
          allowed,
          contains(literal),
          reason: '"$literal" is not declared by $_bridgePath or by the '
              'Android deep link vocabulary',
        );
      }
    });

    test('it reads the same three payload keys the Android provider does', () {
      final String swift = File(_widgetSwiftPath).readAsStringSync();
      expect(swift.contains('"primary_line"'), isTrue);
      expect(swift.contains('"secondary_line"'), isTrue);
      expect(swift.contains('"card_id"'), isTrue);
      expect(swift.contains('UserDefaults(suiteName:'), isTrue);
    });

    test('it derives nothing from a date, a clock or a store of its own', () {
      final String swift = _withoutComments(
        File(_widgetSwiftPath).readAsStringSync(),
      );
      for (final String forbidden in <String>[
        'computed_on',
        'DateFormatter',
        'Calendar',
        'dateComponents',
        'Timer',
        'sqlite',
        'activity_cards',
      ]) {
        expect(swift.contains(forbidden), isFalse, reason: forbidden);
      }
    });

    test('it draws only payload values and never a literal of its own', () {
      final String swift = _withoutComments(
        File(_widgetSwiftPath).readAsStringSync(),
      );
      final List<String> drawn = RegExp(r'Text\(([^)]*)\)')
          .allMatches(swift)
          .map((Match m) => m.group(1)!.trim())
          .toList();
      // Since D-11 the primary line is drawn in three pieces so the run of
      // digits inside it can be re-sized, so the allowed set is wider than one
      // expression per line — but it is still a closed set of payload-derived
      // expressions, which is the property this test exists for. `split` is
      // `CupidPhaseSplit.of(entry.primaryLine)` and holds no string of its own:
      // `lead + number + trail` reassembles the payload character for
      // character, and the `never a literal of its own` test above already
      // rejects any Swift literal outside the contract set.
      expect(
        drawn,
        <String>[
          'split.lead',
          'split.number',
          'split.trail',
          'entry.secondaryLine',
        ],
      );
      expect(
        swift.contains('configurationDisplayName'),
        isFalse,
        reason: 'the widget gallery entry would be a display string (AC-37), '
            'and the Android side deliberately omits android:label too',
      );
      expect(swift.contains('.description('), isFalse);
      expect(
        swift.contains('CupidPhaseSplit.of(entry.primaryLine)'),
        isTrue,
        reason: 'the three pieces must come from the payload line itself',
      );
    });

    test('the widget paints brand colours, never the device theme (D-12)', () {
      final String layout = _withoutComments(
        File(_layoutPath).readAsStringSync(),
      );
      expect(
        layout.contains('?android:attr/'),
        isFalse,
        reason: 'a system colour makes the widget read as the launcher, not '
            'as this app',
      );
      final String swift = _withoutComments(
        File(_widgetSwiftPath).readAsStringSync(),
      );
      expect(swift.contains('Color.clear'), isFalse);
      expect(swift.contains('CupidWidgetPalette'), isTrue);
    });

    test('nothing wakes the extension on its own (WIDGET-STALE)', () {
      final String swift = _withoutComments(
        File(_widgetSwiftPath).readAsStringSync(),
      );
      expect(swift.contains('policy: .never'), isTrue);
      expect(swift.contains('.after('), isFalse);
      expect(swift.contains('.atEnd'), isFalse);
    });

    test('it opens one deep link and offers no second action', () {
      final String swift = File(_widgetSwiftPath).readAsStringSync();
      expect('widgetURL'.allMatches(swift).length, 1);
      expect(swift.contains('Link('), isFalse);
      expect(swift.contains('Button('), isFalse);
    });
  });

  group('the extension is wired into the Xcode project', () {
    late String pbxproj;

    setUpAll(() {
      pbxproj = File(_pbxprojPath).readAsStringSync();
    });

    test('both sides declare the same App Group', () {
      final String groupId = _dartWidgetConstants()['widgetAppGroupId']!;
      for (final String path in <String>[
        _widgetEntitlementsPath,
        _runnerEntitlementsPath,
      ]) {
        final String entitlements = File(path).readAsStringSync();
        expect(entitlements.contains('com.apple.security.application-groups'),
            isTrue);
        expect(entitlements.contains('<string>$groupId</string>'), isTrue,
            reason: path);
      }
    });

    test('the extension declares itself a WidgetKit extension', () {
      final String plist = File(_widgetPlistPath).readAsStringSync();
      expect(plist.contains('com.apple.widgetkit-extension'), isTrue);
      expect(RegExp(r'[^\x00-\x7F]').hasMatch(plist), isFalse);
    });

    test('the extension carries every build configuration Runner has', () {
      final Set<String> runner = _targetConfigurations(pbxproj, 'Runner');
      expect(runner, contains('Debug-local'));
      expect(runner, contains('Release-prod'));
      expect(
        _targetConfigurations(pbxproj, 'CupidPhaseWidget'),
        runner,
        reason: 'a missing flavor configuration fails the build only on the '
            'flavor nobody ran locally',
      );
    });

    test('both targets sign with their entitlements on every flavor', () {
      final int configurations =
          _targetConfigurations(pbxproj, 'Runner').length;
      expect(
        RegExp('CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;')
            .allMatches(pbxproj)
            .length,
        configurations,
      );
      expect(
        RegExp('CODE_SIGN_ENTITLEMENTS = '
                'CupidPhaseWidget/CupidPhaseWidget.entitlements;')
            .allMatches(pbxproj)
            .length,
        configurations,
      );
    });

    test('the app registers the scheme the widget tap opens', () {
      // Without this registration iOS has nobody to hand `cupidapp://` to, so
      // `widgetURL` resolves to nothing and the widget's only affordance is
      // dead on the device while every build and test still passes.
      final String plist = File(_runnerPlistPath).readAsStringSync();
      expect(plist.contains('<key>CFBundleURLTypes</key>'), isTrue);
      final RegExpMatch? schemes = RegExp(
        r'<key>CFBundleURLSchemes</key>\s*<array>([\s\S]*?)</array>',
      ).firstMatch(plist);
      expect(schemes, isNotNull);
      expect(
        RegExp(r'<string>([^<]*)</string>')
            .allMatches(schemes!.group(1)!)
            .map((Match m) => m.group(1)!)
            .toSet(),
        contains(_deepLinkScheme()),
      );
    });

    test('the extension ships inside the app under the app bundle id', () {
      expect(
        pbxproj.contains(
          'PRODUCT_BUNDLE_IDENTIFIER = com.snapsofts.cupid.CupidPhaseWidget;',
        ),
        isTrue,
      );
      expect(pbxproj.contains('Embed App Extensions'), isTrue);
    });
  });
}
