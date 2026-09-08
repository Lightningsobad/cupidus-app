import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cupid_mobile/core/database/cupid_database.dart' as db;
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/journal/journal_media_store.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/journal/data/journal_repository.dart';
import 'package:cupid_mobile/features/journal/domain/journal_entry.dart';
import 'package:cupid_mobile/features/journal/journal_entry_point.dart';
import 'package:cupid_mobile/features/journal/presentation/screens/journal_composer_screen.dart';
import 'package:cupid_mobile/features/journal/presentation/screens/journal_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// A real, opaque 2x2 PNG: the composer decodes what it is handed, so a random
/// byte blob would fall through `errorBuilder` and misreport the attachment.
final Uint8List _fixturePng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91JpzAAAAF0lEQVR42mN4UblyWsI+'
  'hoqAVS+m7QMAM5sHbVdDd/4AAAAASUVORK5CYII=',
);

/// The real repository, with only the two members that reach outside a single
/// call stubbed. `watchEntries` is a live drift query stream whose cancellation
/// schedules a timer that outlives the disposed tree, which `testWidgets` fails
/// on; `sweepOrphans` would delete under it. Everything the entry point's
/// contract depends on — `saveEntry`, `entryById`, the photo copy — stays real.
class _EntryPointRepository extends JournalRepository {
  _EntryPointRepository({
    required super.database,
    required super.mediaStore,
    required super.backendUserIdStore,
  });

  @override
  Stream<List<JournalEntry>> watchEntries({int limit = 50, int offset = 0}) =>
      Stream<List<JournalEntry>>.value(const <JournalEntry>[]);

  @override
  Future<void> sweepOrphans() async {}
}

void main() {
  late db.CupidDatabase database;
  late Directory baseDir;
  late Directory callerDir;
  late JournalMediaStore mediaStore;
  late _EntryPointRepository repository;
  String? composerResult;

  setUp(() {
    database = db.CupidDatabase(NativeDatabase.memory());
    baseDir = Directory.systemTemp.createTempSync('journal_entry_point');
    callerDir = Directory.systemTemp.createTempSync('journal_entry_point_src');
    mediaStore = JournalMediaStore(
      baseDirectory: () async => baseDir,
      ownerUserId: () => 'user-a',
    );
    repository = _EntryPointRepository(
      database: database,
      mediaStore: mediaStore,
      backendUserIdStore: BackendUserIdStore()..updateUserId('user-a'),
    );
    composerResult = null;

    // The entry point resolves its own dependencies, because its callers
    // (`me_screen.dart` today, STORY-007/008 later) must not have to hold a
    // journal repository to reach the journal.
    getIt.registerSingleton<JournalMediaStore>(mediaStore);
    getIt.registerSingleton<JournalRepository>(repository);
  });

  tearDown(() async {
    getIt.unregister<JournalRepository>();
    getIt.unregister<JournalMediaStore>();
    await database.close();
    for (final Directory dir in <Directory>[baseDir, callerDir]) {
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    }
  });

  File sourcePhoto(String name) =>
      File(p.join(callerDir.path, name))..writeAsBytesSync(_fixturePng);

  var appSeq = 0;

  /// The caller's side of the contract: a screen holding nothing but a button
  /// and the entry-point call, which is exactly what STORY-007/008 will have.
  Widget harness({JournalComposerSeed? seed}) {
    return MaterialApp(
      key: ValueKey<int>(appSeq++),
      locale: const Locale('en'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: buildCupidTheme(
        platform: CupidPlatform.material,
        brightness: Brightness.dark,
      ),
      home: Builder(
        builder: (BuildContext context) => Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextButton(
                  key: const Key('call-open-composer'),
                  onPressed: () async {
                    composerResult = await openJournalComposer(
                      context,
                      seed: seed ?? const JournalComposerSeed(),
                    );
                  },
                  child: const Text('compose'),
                ),
                TextButton(
                  key: const Key('call-open-journal'),
                  onPressed: () => openJournalScreen(context),
                  child: const Text('journal'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> flushIo(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
  }

  Future<void> tapOpen(WidgetTester tester, Key key) async {
    await tester.tap(find.byKey(key));
    await tester.pumpAndSettle();
    await flushIo(tester);
  }

  Future<List<db.JournalEntry>> savedRows() =>
      database.select(database.journalEntries).get();

  String bodyFieldText(WidgetTester tester) {
    return tester
        .widget<TextField>(find.byKey(const Key('journal-composer-body-field')))
        .controller!
        .text;
  }

  group('openJournalComposer', () {
    testWidgets('with no seed opens a blank composer', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(harness());
      await tapOpen(tester, const Key('call-open-composer'));

      expect(find.byType(JournalComposerScreen), findsOneWidget);
      expect(bodyFieldText(tester), '');
      expect(find.byKey(const Key('journal-composer-attachments')), findsNothing);
    });

    testWidgets('with a text seed opens pre-filled and still editable', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        harness(
          seed: const JournalComposerSeed(seedText: 'Buổi tối ở CGV Vincom'),
        ),
      );
      await tapOpen(tester, const Key('call-open-composer'));

      expect(bodyFieldText(tester), 'Buổi tối ở CGV Vincom');

      await tester.enterText(
        find.byKey(const Key('journal-composer-body-field')),
        'Mình sửa lại câu này',
      );
      await tester.pump();
      expect(bodyFieldText(tester), 'Mình sửa lại câu này');
    });

    testWidgets('with a photo seed opens with that photo attached', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        harness(
          seed: JournalComposerSeed(
            seedPhotoPaths: <String>[sourcePhoto('ticket.png').path],
          ),
        ),
      );
      await tapOpen(tester, const Key('call-open-composer'));

      expect(find.byKey(const Key('journal-composer-photo-0')), findsOneWidget);
    });

    testWidgets('leaving without saving completes with null and writes nothing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        harness(seed: const JournalComposerSeed(seedText: 'Không lưu đâu')),
      );
      await tapOpen(tester, const Key('call-open-composer'));

      await tester.tap(find.byIcon(CupidIcons.arrowBack));
      await tester.pumpAndSettle();

      expect(find.byType(JournalComposerScreen), findsNothing);
      expect(composerResult, isNull);
      expect(await savedRows(), isEmpty);
    });

    testWidgets('saving completes with the id of the entry it created', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        harness(
          seed: const JournalComposerSeed(
            seedText: 'Ghi lại buổi hẹn',
            originRef: 'story-008:date-plan-42',
          ),
        ),
      );
      await tapOpen(tester, const Key('call-open-composer'));

      await tester.runAsync(() async {
        await tester.tap(find.byKey(const Key('journal-composer-save')));
        await Future<void>.delayed(const Duration(milliseconds: 400));
      });
      await tester.pumpAndSettle();

      final List<db.JournalEntry> rows = await savedRows();
      expect(rows, hasLength(1));
      expect(composerResult, rows.single.id);
      expect(rows.single.bodyText, 'Ghi lại buổi hẹn');
      // The caller's tag is stored verbatim and the row is marked `external`,
      // lowercase, exactly as `architecture/contract-summary.md` §2 states it.
      expect(rows.single.origin, 'external');
      expect(rows.single.originRef, 'story-008:date-plan-42');
    });

    testWidgets('an unreadable seed photo path is dropped, not raised', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        harness(
          seed: JournalComposerSeed(
            seedText: 'Ảnh kia mất rồi',
            seedPhotoPaths: <String>[
              p.join(callerDir.path, 'deleted-before-the-call.png'),
            ],
          ),
        ),
      );
      await tapOpen(tester, const Key('call-open-composer'));

      expect(tester.takeException(), isNull);
      expect(find.byType(JournalComposerScreen), findsOneWidget);
      expect(bodyFieldText(tester), 'Ảnh kia mất rồi');
      expect(find.byKey(const Key('journal-composer-attachments')), findsNothing);
    });

    testWidgets('the saved entry keeps its own copy of the seed photo', (
      WidgetTester tester,
    ) async {
      final File source = sourcePhoto('receipt.png');
      await tester.pumpWidget(
        harness(
          seed: JournalComposerSeed(
            seedText: 'Giữ lại tấm này',
            seedPhotoPaths: <String>[source.path],
          ),
        ),
      );
      await tapOpen(tester, const Key('call-open-composer'));

      await tester.runAsync(() async {
        await tester.tap(find.byKey(const Key('journal-composer-save')));
        await Future<void>.delayed(const Duration(milliseconds: 400));
      });
      await tester.pumpAndSettle();

      final JournalEntry? entry = await tester.runAsync<JournalEntry?>(
        () => repository.entryById(composerResult!),
      );
      expect(entry!.photos, hasLength(1));

      final File stored = await mediaStore.resolvePhoto(
        entry.photos.single.relativePath,
      );
      source.deleteSync();
      expect(stored.existsSync(), isTrue);
      expect(stored.path, isNot(source.path));
    });
  });

  group('openJournalScreen', () {
    testWidgets('pushes the journal full-screen', (WidgetTester tester) async {
      await tester.pumpWidget(harness());
      await tapOpen(tester, const Key('call-open-journal'));

      expect(find.byType(JournalScreen), findsOneWidget);
      expect(find.text('Private journal'), findsOneWidget);
    });

    testWidgets("the list's own CTA opens the composer", (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(harness());
      await tapOpen(tester, const Key('call-open-journal'));

      await tester.tap(find.byKey(const Key('journal-compose-cta')));
      await tester.pumpAndSettle();
      await flushIo(tester);

      expect(find.byType(JournalComposerScreen), findsOneWidget);
    });
  });
}
