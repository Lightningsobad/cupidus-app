import 'dart:io';

import 'package:cupid_mobile/core/config/cupid_api_config.dart';
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

    test('local-dev defaults are unchanged (AC2)', () {
      expect(CupidApiConfig.environment, CupidApiConfig.localEnvironment);
      expect(CupidApiConfig.baseUrl, 'http://localhost:3000');
    });

    test('assertValidConfig is a no-op on the default local build', () {
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
