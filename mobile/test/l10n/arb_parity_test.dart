import 'dart:convert';
import 'dart:io';

import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Reads the ARB message keys for [arbFileName], excluding the `@@locale`
/// meta key and per-message `@key` metadata entries (ADR-004e).
Set<String> _arbKeys(String arbFileName) {
  final File file = File('lib/l10n/arb/$arbFileName');
  final Map<String, Object?> decoded =
      jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
  return decoded.keys
      .where((String key) => key != '@@locale' && !key.startsWith('@'))
      .toSet();
}

void main() {
  test('app_vi.arb and app_en.arb declare identical key sets', () {
    final Set<String> viKeys = _arbKeys('app_vi.arb');
    final Set<String> enKeys = _arbKeys('app_en.arb');

    expect(viKeys, isNotEmpty);
    expect(
      enKeys,
      viKeys,
      reason:
          'app_vi.arb is the template locale (ADR-004e); every key must '
          'have an app_en.arb counterpart, not a silent fallback.',
    );
  });

  test('l10n-untranslated.json is empty after flutter gen-l10n', () {
    final File untranslated = File('l10n-untranslated.json');
    expect(
      untranslated.existsSync(),
      isTrue,
      reason:
          'flutter gen-l10n (via flutter pub get) must have run before '
          'this test suite so the drift-gate file exists.',
    );
    final Object? decoded = jsonDecode(untranslated.readAsStringSync());
    expect(
      decoded,
      isEmpty,
      reason: 'A non-empty file means app_en.arb is missing a translation '
          'that app_vi.arb (the template locale) declares.',
    );
  });

  group('AppL10n resolution', () {
    testWidgets('resolves the smoke keys under Locale(vi)', (
      WidgetTester tester,
    ) async {
      late AppL10n l10n;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              l10n = AppL10n.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(l10n.app_root_title, isNotEmpty);
      expect(l10n.home_screen_greeting, isNotEmpty);
      expect(l10n.common_actions_continue, isNotEmpty);
    });

    testWidgets('resolves the smoke keys under Locale(en), distinct from vi', (
      WidgetTester tester,
    ) async {
      late AppL10n viL10n;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              viL10n = AppL10n.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      final String viGreeting = viL10n.home_screen_greeting;

      late AppL10n enL10n;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              enL10n = AppL10n.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(enL10n.home_screen_greeting, isNotEmpty);
      expect(
        enL10n.home_screen_greeting,
        isNot(viGreeting),
        reason: 'Both locales must resolve through the ARB pipeline to '
            'distinct, non-empty translations, not a shared fallback.',
      );
    });
  });
}
