import 'dart:convert';

import 'package:cupid_mobile/features/zodiac_shell/data/zodiac_rotation_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  Future<SharedPreferences> openPrefs() async => prefs;

  /// A fresh store over the *same* preferences — what the next app launch sees.
  ZodiacRotationStore relaunch() => ZodiacRotationStore(preferences: openPrefs);

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
  });

  group('one question per round (N = 7)', () {
    test('rounds walk the set one step at a time', () async {
      final ZodiacRotationStore store = relaunch();

      final List<int> seen = <int>[];
      for (int round = 0; round < 7; round += 1) {
        seen.addAll(await store.nextWindow(setId: 'set.a', total: 7, perRound: 1));
      }

      expect(seen, <int>[0, 1, 2, 3, 4, 5, 6]);
    });

    test('past the last question it wraps to the first in the same order '
        '(AC-32)', () async {
      final ZodiacRotationStore store = relaunch();

      final List<int> seen = <int>[];
      for (int round = 0; round < 16; round += 1) {
        seen.addAll(await store.nextWindow(setId: 'set.a', total: 7, perRound: 1));
      }

      expect(seen.sublist(0, 7), seen.sublist(7, 14));
      expect(seen.sublist(14), <int>[0, 1]);
    });
  });

  group('two questions per round', () {
    test('a window that runs off the end wraps inside itself', () async {
      final ZodiacRotationStore store = relaunch();

      expect(await store.nextWindow(setId: 'set.b', total: 5, perRound: 2),
          <int>[0, 1]);
      expect(await store.nextWindow(setId: 'set.b', total: 5, perRound: 2),
          <int>[2, 3]);
      expect(await store.nextWindow(setId: 'set.b', total: 5, perRound: 2),
          <int>[4, 0]);
      expect(await store.nextWindow(setId: 'set.b', total: 5, perRound: 2),
          <int>[1, 2]);
    });

    test('a set whose round is its whole length repeats the same window',
        () async {
      // Every set in `zodiac_quiz.v1.json` ships exactly `questions_per_round`
      // questions today, so this is the shape the shipped data exercises.
      final ZodiacRotationStore store = relaunch();

      expect(await store.nextWindow(setId: 'set.c', total: 2, perRound: 2),
          <int>[0, 1]);
      expect(await store.nextWindow(setId: 'set.c', total: 2, perRound: 2),
          <int>[0, 1]);
    });
  });

  group('one question, one round (N = 1)', () {
    test('the only question keeps coming back rather than running out',
        () async {
      final ZodiacRotationStore store = relaunch();

      for (int round = 0; round < 4; round += 1) {
        expect(await store.nextWindow(setId: 'set.d', total: 1, perRound: 1),
            <int>[0]);
      }
    });
  });

  test('the cursor survives a relaunch (AC-32)', () async {
    expect(await relaunch().nextWindow(setId: 'set.e', total: 4, perRound: 1),
        <int>[0]);
    expect(await relaunch().nextWindow(setId: 'set.e', total: 4, perRound: 1),
        <int>[1]);
    expect(await relaunch().nextWindow(setId: 'set.e', total: 4, perRound: 1),
        <int>[2]);
  });

  test('each set rotates on its own cursor', () async {
    final ZodiacRotationStore store = relaunch();

    await store.nextWindow(setId: 'set.f', total: 4, perRound: 1);
    await store.nextWindow(setId: 'set.f', total: 4, perRound: 1);

    expect(await store.nextWindow(setId: 'set.g', total: 4, perRound: 1),
        <int>[0]);
    expect(await store.nextWindow(setId: 'set.f', total: 4, perRound: 1),
        <int>[2]);
  });

  group('what is on disk', () {
    test('it is the contract key, holding a JSON object of positions', () async {
      await relaunch().nextWindow(setId: 'set.h', total: 4, perRound: 1);

      final String? raw = prefs.getString(zodiacRotationCursorKey);
      expect(zodiacRotationCursorKey, 'zodiac_shell.rotation_cursor.v1');
      expect(raw, isNotNull);
      expect(jsonDecode(raw!), <String, Object?>{'set.h': 1});
    });

    test('the stored number never grows past the set, so it cannot be read as '
        'a play count (AC-18/AC-31)', () async {
      final ZodiacRotationStore store = relaunch();

      for (int round = 0; round < 20; round += 1) {
        await store.nextWindow(setId: 'set.i', total: 3, perRound: 1);
        final Map<String, Object?> stored = jsonDecode(
          prefs.getString(zodiacRotationCursorKey)!,
        ) as Map<String, Object?>;
        expect(stored['set.i'], lessThan(3));
      }
    });

    test('nothing else is written', () async {
      await relaunch().nextWindow(setId: 'set.j', total: 3, perRound: 1);

      expect(prefs.getKeys(), <String>{zodiacRotationCursorKey});
    });
  });

  group('a value this store did not write', () {
    test('unparseable text restarts the rotation instead of failing the round',
        () async {
      await prefs.setString(zodiacRotationCursorKey, 'not json at all');

      expect(await relaunch().nextWindow(setId: 'set.k', total: 3, perRound: 1),
          <int>[0]);
    });

    test('a cursor beyond the set folds back into range', () async {
      await prefs.setString(
        zodiacRotationCursorKey,
        jsonEncode(<String, int>{'set.l': 11}),
      );

      // A pack that lost questions leaves an out-of-range cursor behind; it has
      // to land on a real index rather than throw a range error.
      expect(await relaunch().nextWindow(setId: 'set.l', total: 3, perRound: 1),
          <int>[2]);
    });

    test('a non-integer cursor is ignored', () async {
      await prefs.setString(
        zodiacRotationCursorKey,
        jsonEncode(<String, Object>{'set.m': 'two'}),
      );

      expect(await relaunch().nextWindow(setId: 'set.m', total: 3, perRound: 1),
          <int>[0]);
    });
  });

  group('impossible arguments', () {
    test('an empty set is rejected', () {
      expect(
        () => relaunch().nextWindow(setId: 'set.n', total: 0, perRound: 1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('a round longer than the set is rejected', () {
      expect(
        () => relaunch().nextWindow(setId: 'set.o', total: 2, perRound: 3),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
