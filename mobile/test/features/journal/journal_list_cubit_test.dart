import 'dart:io';

import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/journal/journal_media_store.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/features/journal/data/journal_repository.dart';
import 'package:cupid_mobile/features/journal/presentation/journal_list_cubit.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// The real repository over an in-memory database, with only [sweepOrphans]
/// instrumented. Faking the whole repository would let the cubit pass against
/// a paging contract the real one does not have.
class _CountingRepository extends JournalRepository {
  _CountingRepository({
    required super.database,
    required super.mediaStore,
    required super.backendUserIdStore,
  });

  int sweepCount = 0;

  @override
  Future<void> sweepOrphans() {
    sweepCount++;
    return super.sweepOrphans();
  }
}

void main() {
  late CupidDatabase database;
  late Directory baseDir;
  late _CountingRepository repository;

  setUp(() {
    database = CupidDatabase(NativeDatabase.memory());
    baseDir = Directory.systemTemp.createTempSync('journal_list_cubit_test');
    repository = _CountingRepository(
      database: database,
      mediaStore: JournalMediaStore(
        baseDirectory: () async => baseDir,
        ownerUserId: () => 'user-a',
      ),
      backendUserIdStore: BackendUserIdStore()..updateUserId('user-a'),
    );
  });

  tearDown(() async {
    await database.close();
    if (baseDir.existsSync()) {
      baseDir.deleteSync(recursive: true);
    }
  });

  Future<void> seed(int count) async {
    for (var i = 0; i < count; i++) {
      await repository.saveEntry(
        id: 'e-$i',
        bodyText: 'mục $i',
        now: DateTime.utc(2026, 9, 1 + i),
      );
    }
  }

  /// Pumps the event loop until [predicate] holds, so a test never depends on
  /// a fixed number of microtask turns between a write and the drift stream
  /// emission it causes.
  Future<JournalListReady> settle(
    JournalListCubit cubit,
    bool Function(JournalListReady state) predicate,
  ) async {
    for (var i = 0; i < 200; i++) {
      final state = cubit.state;
      if (state is JournalListReady && predicate(state)) {
        return state;
      }
      await Future<void>.delayed(Duration.zero);
    }
    fail('cubit never reached the expected state; last was ${cubit.state}');
  }

  test('emits the neutral empty state when the journal has no entries', () async {
    final cubit = JournalListCubit(repository: repository);
    addTearDown(cubit.close);

    expect(cubit.state, isA<JournalListLoading>());

    final ready = await settle(cubit, (s) => true);
    expect(ready.entries, isEmpty);
    expect(ready.hasMore, isFalse);
  });

  test('emits entries newest first once the repository has data', () async {
    await seed(3);
    final cubit = JournalListCubit(repository: repository);
    addTearDown(cubit.close);

    final ready = await settle(cubit, (s) => s.entries.length == 3);
    expect(
      ready.entries.map((e) => e.id).toList(),
      <String>['e-2', 'e-1', 'e-0'],
    );
  });

  test('sweeps orphaned media exactly once, on open', () async {
    final cubit = JournalListCubit(repository: repository);
    addTearDown(cubit.close);

    await settle(cubit, (s) => true);
    await seed(2);
    await settle(cubit, (s) => s.entries.length == 2);

    expect(repository.sweepCount, 1);
  });

  group('pagination', () {
    test('holds one page window, not the whole journal', () async {
      await seed(5);
      final cubit = JournalListCubit(repository: repository, pageSize: 2);
      addTearDown(cubit.close);

      final first = await settle(cubit, (s) => s.entries.isNotEmpty);
      expect(first.entries, hasLength(2));
      expect(first.hasMore, isTrue);
    });

    test('loadMore widens the window by one page', () async {
      await seed(5);
      final cubit = JournalListCubit(repository: repository, pageSize: 2);
      addTearDown(cubit.close);

      await settle(cubit, (s) => s.entries.length == 2);
      cubit.loadMore();
      final widened = await settle(cubit, (s) => s.entries.length == 4);

      expect(widened.hasMore, isTrue);
      cubit.loadMore();
      final all = await settle(cubit, (s) => s.entries.length == 5);
      expect(all.hasMore, isFalse);
    });

    test('loadMore on the last page is a no-op', () async {
      await seed(2);
      final cubit = JournalListCubit(repository: repository, pageSize: 5);
      addTearDown(cubit.close);

      await settle(cubit, (s) => s.entries.length == 2);
      cubit.loadMore();
      final after = await settle(cubit, (s) => true);

      expect(after.entries, hasLength(2));
      expect(after.hasMore, isFalse);
    });
  });

  group('deleteEntry', () {
    test('removes the row through the repository and updates the list',
        () async {
      await seed(2);
      final cubit = JournalListCubit(repository: repository);
      addTearDown(cubit.close);
      await settle(cubit, (s) => s.entries.length == 2);

      await cubit.deleteEntry('e-0');

      final after = await settle(cubit, (s) => s.entries.length == 1);
      expect(after.entries.single.id, 'e-1');
      expect(await repository.entryById('e-0'), isNull);
    });
  });

  group('deleteAll', () {
    test('empties the repository and returns to the first-open empty state',
        () async {
      await seed(4);
      final cubit = JournalListCubit(repository: repository, pageSize: 2);
      addTearDown(cubit.close);
      await settle(cubit, (s) => s.entries.length == 2);
      cubit.loadMore();
      await settle(cubit, (s) => s.entries.length == 4);

      await cubit.deleteAll();

      final after = await settle(cubit, (s) => s.entries.isEmpty);
      expect(after.hasMore, isFalse);
      expect(await repository.watchEntries().first, isEmpty);

      // The window is back to one page: re-seeding shows a first page again
      // rather than the four rows the pre-delete window had grown to.
      await seed(4);
      final reseeded = await settle(cubit, (s) => s.entries.isNotEmpty);
      expect(reseeded.entries, hasLength(2));
    });
  });

  group('privacy egress gate', () {
    const forbidden = <String>[
      'share_plus',
      'dio',
      'cupid_api',
      'RealtimeCoordinator',
      'Clipboard',
      'hydrated_bloc',
      'cached_network_image',
    ];

    for (final path in const <String>[
      'lib/features/journal/presentation/journal_list_cubit.dart',
      'lib/features/journal/presentation/screens/journal_screen.dart',
    ]) {
      test('$path imports nothing that could carry journal content off device '
          '(AC-6, AC-7, AC-10)', () {
        final imports = File(path)
            .readAsLinesSync()
            .where((line) => line.startsWith('import '));

        for (final token in forbidden) {
          expect(
            imports.where((line) => line.contains(token)),
            isEmpty,
            reason: '$path must not import $token',
          );
        }
      });
    }
  });
}
