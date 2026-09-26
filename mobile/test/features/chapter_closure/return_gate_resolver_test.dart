import 'dart:io';

import 'package:cupid_mobile/features/chapter_closure/data/stage1_last_opened_store.dart';
import 'package:cupid_mobile/features/chapter_closure/domain/return_gate_resolver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// REQ-016 STORY-013 P6 — the return gate's decision and its type surface.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Stage1LastOpenedStore storeWith(Map<String, Object> seed) {
    SharedPreferences.setMockInitialValues(seed);
    return Stage1LastOpenedStore();
  }

  ReturnGateResolver resolverAt(DateTime now, Map<String, Object> seed) =>
      ReturnGateResolver(store: storeWith(seed), clock: () => now);

  final DateTime now = DateTime(2026, 9, 17, 10);

  Map<String, Object> markedAt(DateTime at) => <String, Object>{
    'flutter.${Stage1LastOpenedStore.preferenceKey}': at.millisecondsSinceEpoch,
  };

  group('ReturnGateResolver.shouldShow (AC-18, AC-19, AC-23)', () {
    test('is false one day below the single threshold', () async {
      final ReturnGateResolver resolver = resolverAt(
        now,
        markedAt(now.subtract(kReturnAbsenceThreshold - const Duration(days: 1))),
      );

      expect(await resolver.shouldShow(), isFalse);
    });

    test('is true exactly at the single threshold', () async {
      final ReturnGateResolver resolver = resolverAt(
        now,
        markedAt(now.subtract(kReturnAbsenceThreshold)),
      );

      expect(await resolver.shouldShow(), isTrue);
    });

    test('is true far above the single threshold', () async {
      final ReturnGateResolver resolver = resolverAt(
        now,
        markedAt(now.subtract(const Duration(days: 400))),
      );

      expect(await resolver.shouldShow(), isTrue);
    });

    test('is false on a fresh install, with no mark yet', () async {
      final ReturnGateResolver resolver = resolverAt(now, <String, Object>{});

      expect(await resolver.shouldShow(), isFalse);
    });

    test('reads exactly one key, so nothing else can feed the decision', () async {
      // Card state, closure state, and the partner's non-arrival all live in
      // other stores; the resolver cannot see them because the only input it
      // has is this one preference key (AC-23).
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final ReturnGateResolver resolver = ReturnGateResolver(
        store: Stage1LastOpenedStore(preferences: () async => prefs),
        clock: () => now,
      );

      await resolver.markOpened();

      expect(prefs.getKeys(), <String>{Stage1LastOpenedStore.preferenceKey});
    });
  });

  group('markOpened (AC-18, AC-24)', () {
    test('moves the mark forward so the next launch is below threshold', () async {
      SharedPreferences.setMockInitialValues(
        markedAt(now.subtract(const Duration(days: 400))),
      );
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final Stage1LastOpenedStore store = Stage1LastOpenedStore(
        preferences: () async => prefs,
      );

      expect(
        await ReturnGateResolver(store: store, clock: () => now).shouldShow(),
        isTrue,
      );
      await ReturnGateResolver(store: store, clock: () => now).markOpened();

      final DateTime nextLaunch = now.add(const Duration(days: 1));
      expect(
        await ReturnGateResolver(
          store: store,
          clock: () => nextLaunch,
        ).shouldShow(),
        isFalse,
      );
    });
  });

  group('type surface (AC-19, AC-20)', () {
    test('no public member of the gate returns a Duration, DateTime, or count', () {
      // `dart:mirrors` is unavailable under `flutter test`, so the check reads
      // the declarations themselves. Each match is one public member signature;
      // the assertion is on what sits to the left of its name.
      final RegExp publicMember = RegExp(
        r'^  (?!static |const |final )([A-Za-z<>?, ]+?) (get )?([a-zA-Z]\w*)[ (<=]',
        multiLine: true,
      );
      const Set<String> forbidden = <String>{
        'Duration',
        'DateTime',
        'int',
        'double',
        'num',
        'Future<Duration>',
        'Future<DateTime>',
        'Future<int>',
        'Future<double>',
        'Future<num>',
      };

      for (final String path in <String>[
        'lib/features/chapter_closure/domain/return_gate_resolver.dart',
        'lib/features/chapter_closure/data/stage1_last_opened_store.dart',
      ]) {
        final String source = File(path).readAsStringSync();
        final List<RegExpMatch> members = publicMember
            .allMatches(source)
            .toList();
        expect(members, isNotEmpty, reason: 'regex matched nothing in $path');

        for (final RegExpMatch member in members) {
          expect(
            forbidden.contains(member.group(1)),
            isFalse,
            reason:
                '${member.group(3)} in $path returns ${member.group(1)}, '
                'which AC-20 keeps inside the gate',
          );
        }
      }
    });

    test('exactly one absence threshold constant exists, at 30 days', () {
      const String path =
          'lib/features/chapter_closure/domain/return_gate_resolver.dart';
      final String source = File(path).readAsStringSync();

      expect(kReturnAbsenceThreshold, const Duration(days: 30));
      expect(
        RegExp(r'^const Duration ', multiLine: true).allMatches(source).length,
        1,
        reason: 'AC-19 allows exactly one threshold, with no second tier',
      );
    });
  });
}
