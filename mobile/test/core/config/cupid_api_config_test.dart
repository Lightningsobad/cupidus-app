import 'dart:io';

import 'package:cupid_mobile/core/config/cupid_api_config.dart';
import 'package:flutter/services.dart' show appFlavor;
import 'package:flutter_test/flutter_test.dart';

List<File> _libDartFiles() => Directory('lib')
    .listSync(recursive: true)
    .whereType<File>()
    .where((File f) => f.path.endsWith('.dart'))
    .toList();

void main() {
  group('CupidApiConfig constants', () {
    test('production origin is the live TLS origin', () {
      expect(CupidApiConfig.productionBaseUrl, 'https://api.cupidus.app');
    });

    // Pinned as constants rather than as the current build's resolved values:
    // those now follow the build flavor, and are asserted per flavor below.
    test('local-dev values are unchanged (AC2)', () {
      expect(CupidApiConfig.localEnvironment, 'local');
      expect(CupidApiConfig.localBaseUrl, 'http://localhost:3000');
    });

    test('assertValidConfig is a no-op on any flavor default', () {
      expect(CupidApiConfig.assertValidConfig, returnsNormally);
    });
  });

  group('CupidApiConfig.validationError', () {
    test('accepts the default local pair', () {
      expect(
        CupidApiConfig.validationError('local', 'http://localhost:3000'),
        isNull,
      );
    });

    test('accepts the production pair', () {
      expect(
        CupidApiConfig.validationError(
          CupidApiConfig.productionEnvironment,
          CupidApiConfig.productionBaseUrl,
        ),
        isNull,
      );
    });

    test('rejects an unknown environment value', () {
      expect(
        CupidApiConfig.validationError('staging', 'https://api.cupidus.app'),
        contains('CUPID_ENV'),
      );
    });

    test('rejects production paired with the local-dev origin', () {
      expect(
        CupidApiConfig.validationError('production', 'http://localhost:3000'),
        contains('https://api.cupidus.app'),
      );
    });

    test('rejects a cleartext production origin', () {
      expect(
        CupidApiConfig.validationError('production', 'http://api.cupidus.app'),
        isNotNull,
      );
    });

    test('rejects a wrong production host', () {
      expect(
        CupidApiConfig.validationError('production', 'https://api.example.com'),
        isNotNull,
      );
    });

    test('rejects production with an empty origin', () {
      expect(CupidApiConfig.validationError('production', ''), isNotNull);
    });
  });

  group('flavor-derived defaults (AC2, AC3, AC4)', () {
    test('only the prod flavor constrains the environment', () {
      expect(
        CupidApiConfig.requiredEnvironmentForFlavor(
          CupidApiConfig.productionFlavor,
        ),
        CupidApiConfig.productionEnvironment,
      );
      expect(
        CupidApiConfig.requiredEnvironmentForFlavor(CupidApiConfig.localFlavor),
        isNull,
      );
      expect(CupidApiConfig.requiredEnvironmentForFlavor(null), isNull);
      expect(CupidApiConfig.requiredEnvironmentForFlavor('staging'), isNull);
    });

    // `pubspec.yaml`'s `default-flavor: local` also applies to the test host,
    // so a bare `flutter test` sees `local`. Re-run this file with
    // `--flavor prod` and `--flavor local` to exercise the other branches.
    test('the flavor alone selects the backend, with no dart-define '
        '(AC2, AC3, AC5)', () {
      switch (appFlavor) {
        case CupidApiConfig.productionFlavor:
          expect(
            CupidApiConfig.environment,
            CupidApiConfig.productionEnvironment,
          );
          expect(CupidApiConfig.baseUrl, CupidApiConfig.productionBaseUrl);
        case CupidApiConfig.localFlavor:
        case null:
          expect(CupidApiConfig.environment, CupidApiConfig.localEnvironment);
          expect(CupidApiConfig.baseUrl, CupidApiConfig.localBaseUrl);
        default:
          fail('unexpected build flavor "$appFlavor"');
      }
      expect(CupidApiConfig.assertValidConfig, returnsNormally);
    });

    test('local flavor accepts the local pair with no dart-define', () {
      expect(
        CupidApiConfig.validationError(
          CupidApiConfig.localEnvironment,
          CupidApiConfig.localBaseUrl,
          flavor: CupidApiConfig.localFlavor,
        ),
        isNull,
      );
    });

    test('prod flavor accepts the production pair with no dart-define', () {
      expect(
        CupidApiConfig.validationError(
          CupidApiConfig.productionEnvironment,
          CupidApiConfig.productionBaseUrl,
          flavor: CupidApiConfig.productionFlavor,
        ),
        isNull,
      );
    });

    test('prod flavor silently resolving to local fails loudly (AC4)', () {
      expect(
        CupidApiConfig.validationError(
          CupidApiConfig.localEnvironment,
          CupidApiConfig.localBaseUrl,
          flavor: CupidApiConfig.productionFlavor,
        ),
        contains(CupidApiConfig.productionFlavor),
      );
    });

    test('a local-declared build pointed at production fails loudly', () {
      for (final String? flavor in <String?>[
        null,
        CupidApiConfig.localFlavor,
      ]) {
        expect(
          CupidApiConfig.validationError(
            CupidApiConfig.localEnvironment,
            CupidApiConfig.productionBaseUrl,
            flavor: flavor,
          ),
          isNotNull,
          reason: 'flavor $flavor must not silently reach production',
        );
      }
    });

    // The `default-flavor: local` entry means this REQ-007 invocation now
    // carries the `local` flavor. It must keep working unchanged.
    test("REQ-007's define-only production build still validates", () {
      expect(
        CupidApiConfig.validationError(
          CupidApiConfig.productionEnvironment,
          CupidApiConfig.productionBaseUrl,
          flavor: CupidApiConfig.localFlavor,
        ),
        isNull,
      );
    });

    test('a null flavor keeps the pre-flavor validation behaviour', () {
      expect(
        CupidApiConfig.validationError(
          CupidApiConfig.localEnvironment,
          CupidApiConfig.localBaseUrl,
          flavor: null,
        ),
        isNull,
      );
      expect(
        CupidApiConfig.validationError(
          CupidApiConfig.productionEnvironment,
          CupidApiConfig.localBaseUrl,
          flavor: null,
        ),
        isNotNull,
      );
    });
  });

  group('source guards', () {
    test('production origin appears in lib/ only as the named constant', () {
      final Map<String, int> hits = <String, int>{};
      for (final File file in _libDartFiles()) {
        final int count = 'https://api.cupidus.app'
            .allMatches(file.readAsStringSync())
            .length;
        if (count > 0) {
          hits[file.path.replaceAll(r'\', '/')] = count;
        }
      }
      expect(hits, <String, int>{'lib/core/config/cupid_api_config.dart': 1});
    });

    test('no writable API origin is exposed anywhere in lib/ (AC5)', () {
      final List<String> offenders = <String>[];
      for (final File file in _libDartFiles()) {
        final String source = file.readAsStringSync();
        if (source.contains(RegExp(r'set\s+(baseUrl|apiBaseUrl|environment)\b')) ||
            source.contains(RegExp(r'CupidApiConfig\.(baseUrl|environment)\s*='))) {
          offenders.add(file.path);
        }
      }
      expect(offenders, isEmpty);
    });

    test('AppConfig stays unreferenced scaffolding', () {
      final List<String> referencing = <File>[
        ..._libDartFiles(),
      ]
          .where((File f) =>
              !f.path.replaceAll(r'\', '/').endsWith('lib/core/config/app_config.dart'))
          .where((File f) => f.readAsStringSync().contains('AppConfig'))
          .map((File f) => f.path)
          .toList();
      expect(referencing, isEmpty);
    });
  });
}
