import 'dart:convert';
import 'dart:io';

import 'package:cupid_mobile/core/database/cupid_database.dart' as db;
import 'package:cupid_mobile/core/database/daos/activity_card_dao.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/journal/journal_media_store.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/thank_you/data/attachable_photos.dart';
import 'package:cupid_mobile/features/activity_cards/thank_you/presentation/widgets/photo_attach_section.dart';
import 'package:cupid_mobile/features/journal/data/journal_repository.dart';
import 'package:cupid_mobile/features/journal/journal_entry_point.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// A real, opaque 2x2 PNG. The thumbnails hand these files to `Image.file`, so
/// a random byte blob would fall through `errorBuilder` and the row would
/// report a decode failure instead of the case under test.
final Uint8List _fixturePng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91JpzAAAAF0lEQVR42mN4UblyWsI+'
  'hoqAVS+m7QMAM5sHbVdDd/4AAAAASUVORK5CYII=',
);

const String _entryPointPath = 'lib/features/journal/journal_entry_point.dart';
const String _projectionPath =
    'lib/features/activity_cards/thank_you/data/attachable_photos.dart';

/// Names declared at column zero, ignoring directives, comments and closers.
List<String> _topLevelNames(String source) {
  final RegExp name = RegExp(r'(\w+)\s*[({=]');
  return <String>[
    for (final String line in const LineSplitter().convert(source))
      if (RegExp(r'^[A-Za-z_]').hasMatch(line) &&
          !RegExp(r'^(import|export|part|library)\b').hasMatch(line))
        if (name.firstMatch(line) case final RegExpMatch match)
          match.group(1)!,
  ];
}

Widget _host(Widget child) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildCupidTheme(
        platform: CupidPlatform.material,
        brightness: Brightness.dark,
      ),
      locale: const Locale('vi'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: CupidPlatformOverride(
        platform: CupidPlatform.material,
        child: Scaffold(body: Center(child: child)),
      ),
    );

void main() {
  late db.CupidDatabase database;
  late Directory mediaDir;
  late Directory sourceDir;
  late JournalMediaStore mediaStore;
  late JournalRepository journal;
  late ActivityCardDao cards;

  setUp(() async {
    database = db.CupidDatabase(NativeDatabase.memory());
    mediaDir = Directory.systemTemp.createTempSync('photo_attach_media');
    sourceDir = Directory.systemTemp.createTempSync('photo_attach_src');
    final BackendUserIdStore userIds = BackendUserIdStore()
      ..updateUserId('user-a');
    mediaStore = JournalMediaStore(
      baseDirectory: () async => mediaDir,
      ownerUserId: () => userIds.backendUserId,
    );
    journal = JournalRepository(
      database: database,
      mediaStore: mediaStore,
      backendUserIdStore: userIds,
    );
    cards = ActivityCardDao(database);

    // `loadAttachablePhotos` resolves both halves itself, exactly as the block
    // calls it: the caller holds neither store.
    getIt.registerSingleton<JournalRepository>(journal);
    getIt.registerSingleton<ActivityCardDao>(cards);

    await database.into(database.activityCards).insert(
          db.ActivityCardsCompanion.insert(
            id: 'card-1',
            ownerKey: 'owner-1',
            title: 'Đi ăn lẩu ở Trúc Bạch',
            origin: 'manual',
            status: const Value('done'),
            createdAt: DateTime.utc(2026, 9, 20),
            updatedAt: DateTime.utc(2026, 9, 20),
          ),
        );
  });

  tearDown(() async {
    getIt.unregister<ActivityCardDao>();
    getIt.unregister<JournalRepository>();
    await database.close();
    for (final Directory dir in <Directory>[mediaDir, sourceDir]) {
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    }
  });

  File sourcePhoto(String name) =>
      File(p.join(sourceDir.path, name))..writeAsBytesSync(_fixturePng);

  Future<void> seedCardPhoto(String id, String path, {int sortIndex = 0}) {
    return cards.upsertPhoto(
      db.ActivityCardPhotosCompanion.insert(
        id: id,
        cardId: 'card-1',
        localPath: path,
        sortIndex: Value(sortIndex),
      ),
    );
  }

  /// The journal half is seeded through the entry point's own write path with
  /// an `originRef`, never through a journal screen: no UI in the app writes a
  /// tagged entry yet (STORY-008 does), and the read has to be provable now.
  Future<void> seedJournalEntry(
    String id, {
    required String originRef,
    List<String> photoSourcePaths = const <String>[],
  }) async {
    await journal.saveEntry(
      id: id,
      bodyText: 'buổi tối hôm qua vui lắm',
      photoSourcePaths: photoSourcePaths,
      originRef: originRef,
      now: DateTime.utc(2026, 9, 20, 22),
    );
  }

  group('cổng ra của nhật ký — chỉ đường dẫn ảnh (AC-17, BR-8)', () {
    test('entry point vẫn chỉ có bốn khai báo, thêm đúng một hàm đọc', () {
      final List<String> names = _topLevelNames(
        File(_entryPointPath).readAsStringSync(),
      );

      expect(names, <String>[
        'JournalComposerSeed',
        'openJournalComposer',
        'journalPhotoPathsForOrigin',
        'openJournalScreen',
      ]);
    });

    test('hàm đọc chỉ trả đường dẫn, không trả nội dung hay thời gian', () {
      // Compile-time: the file would not build if the projection widened to an
      // entry, a record or anything carrying text.
      final Future<List<String>> Function(String) projection =
          journalPhotoPathsForOrigin;
      expect(projection, same(journalPhotoPathsForOrigin));

      final String source = File(_entryPointPath).readAsStringSync();
      for (final String leak in <String>[
        'JournalEntry ',
        'bodyText',
        'createdAt',
        'updatedAt',
        'JournalPhoto',
      ]) {
        expect(
          source.contains(leak),
          isFalse,
          reason: 'entry point không được nhắc tới $leak',
        );
      }
    });

    test('kiểu chiếu chỉ mang một trường đường dẫn', () {
      final String source = File(_projectionPath).readAsStringSync();
      final String body = source.substring(
        source.indexOf('class AttachablePhoto {'),
        source.indexOf('\n}\n', source.indexOf('class AttachablePhoto {')),
      );
      final List<String> fields = <String>[
        for (final String line in const LineSplitter().convert(body))
          if (line.startsWith('  final ')) line.trim(),
      ];

      expect(fields, <String>['final String filePath;']);
    });

    test('không có hàm liệt kê, đếm, tìm hay xem trước', () {
      final String source = File(_entryPointPath).readAsStringSync();
      for (final String banned in <String>[
        'listEntries',
        'countEntries',
        'searchEntries',
        'previewEntry',
        'watchEntries',
      ]) {
        expect(source.contains('$banned('), isFalse, reason: banned);
      }
    });
  });

  group('gộp hai nguồn ảnh (AC-14)', () {
    test('ảnh ở trường thẻ và ở nhật ký cùng hiện, thẻ trước', () async {
      final File cardShot = sourcePhoto('card.png');
      final File journalShot = sourcePhoto('journal.png');
      await seedCardPhoto('photo-1', cardShot.path);
      await seedJournalEntry(
        'entry-1',
        originRef: 'card-1',
        photoSourcePaths: <String>[journalShot.path],
      );

      final List<AttachablePhoto> photos = await loadAttachablePhotos('card-1');

      expect(photos, hasLength(2));
      expect(photos.first.filePath, cardShot.path);
      expect(photos.last.filePath, isNot(journalShot.path));
      expect(File(photos.last.filePath).existsSync(), isTrue);
    });

    test('cùng một file ở hai nguồn chỉ hiện một lần', () {
      final File shot = sourcePhoto('shared.png');

      final List<AttachablePhoto> photos = mergeAttachablePhotos(
        cardPaths: <String>[shot.path],
        journalPaths: <String>[shot.path],
      );

      expect(photos.map((AttachablePhoto photo) => photo.filePath), <String>[
        shot.path,
      ]);
    });

    test('file đã biến mất thì bị bỏ, không thành ô trống', () {
      final File kept = sourcePhoto('kept.png');

      final List<AttachablePhoto> photos = mergeAttachablePhotos(
        cardPaths: <String>[p.join(sourceDir.path, 'gone.png'), kept.path],
        journalPaths: const <String>[],
      );

      expect(photos.map((AttachablePhoto photo) => photo.filePath), <String>[
        kept.path,
      ]);
    });

    test('thẻ chưa có ảnh nào thì danh sách rỗng', () async {
      expect(await loadAttachablePhotos('card-1'), isEmpty);
    });
  });

  group('truy vấn nhật ký theo originRef', () {
    test('chỉ mục nào mang đúng thẻ mới trả về', () async {
      await seedJournalEntry(
        'entry-mine',
        originRef: 'card-1',
        photoSourcePaths: <String>[sourcePhoto('mine.png').path],
      );
      await seedJournalEntry(
        'entry-other',
        originRef: 'card-2',
        photoSourcePaths: <String>[sourcePhoto('other.png').path],
      );

      expect(await journalPhotoPathsForOrigin('card-1'), hasLength(1));
      expect(await journalPhotoPathsForOrigin('card-2'), hasLength(1));
      expect(await journalPhotoPathsForOrigin('card-3'), isEmpty);
    });

    test('mục không gắn thẻ nào thì không lọt ra (BR-8)', () async {
      await journal.saveEntry(
        id: 'entry-manual',
        bodyText: 'chuyện riêng',
        photoSourcePaths: <String>[sourcePhoto('private.png').path],
        now: DateTime.utc(2026, 9, 20, 22),
      );

      expect(await journalPhotoPathsForOrigin('card-1'), isEmpty);
    });

    test('xoá mục nhật ký thì app không giữ lại bản sao nào (AC-18)', () async {
      await seedJournalEntry(
        'entry-1',
        originRef: 'card-1',
        photoSourcePaths: <String>[sourcePhoto('receipt.png').path],
      );
      final List<String> before = await journalPhotoPathsForOrigin('card-1');
      expect(before, hasLength(1));

      await journal.deleteEntry('entry-1');

      expect(File(before.single).existsSync(), isFalse);
      expect(await journalPhotoPathsForOrigin('card-1'), isEmpty);
    });
  });

  group('phần 2 — hàng ảnh đính kèm', () {
    late ValueNotifier<List<String>> selection;
    late List<AttachablePhoto> photos;

    setUp(() {
      selection = ValueNotifier<List<String>>(const <String>[]);
      photos = <AttachablePhoto>[
        AttachablePhoto(sourcePhoto('a.png').path),
        AttachablePhoto(sourcePhoto('b.png').path),
      ];
      addTearDown(selection.dispose);
    });

    Future<void> pumpRow(WidgetTester tester) async {
      await tester.pumpWidget(
        _host(PhotoAttachSection(photos: photos, selection: selection)),
      );
      await tester.pump();
    }

    testWidgets('mặc định chưa chọn tấm nào (AC-16)', (
      WidgetTester tester,
    ) async {
      await pumpRow(tester);

      expect(find.byKey(const Key('photo_attach_row')), findsOneWidget);
      expect(find.byKey(const Key('photo_attach_thumb_0')), findsOneWidget);
      expect(find.byKey(const Key('photo_attach_thumb_1')), findsOneWidget);
      expect(find.byKey(const Key('photo_attach_tick_0')), findsNothing);
      expect(selection.value, isEmpty);
    });

    testWidgets('chạm để chọn, chạm lại để bỏ chọn', (
      WidgetTester tester,
    ) async {
      await pumpRow(tester);

      await tester.tap(find.byKey(const Key('photo_attach_thumb_0')));
      await tester.pump();
      expect(find.byKey(const Key('photo_attach_tick_0')), findsOneWidget);
      expect(selection.value, <String>[photos.first.filePath]);

      await tester.tap(find.byKey(const Key('photo_attach_thumb_1')));
      await tester.pump();
      expect(selection.value, <String>[
        photos.first.filePath,
        photos.last.filePath,
      ]);

      await tester.tap(find.byKey(const Key('photo_attach_thumb_0')));
      await tester.pump();
      expect(find.byKey(const Key('photo_attach_tick_0')), findsNothing);
      expect(find.byKey(const Key('photo_attach_tick_1')), findsOneWidget);
      expect(selection.value, <String>[photos.last.filePath]);
    });

    testWidgets('hàng ảnh không kèm chữ nào của nhật ký (AC-17)', (
      WidgetTester tester,
    ) async {
      await pumpRow(tester);

      expect(
        find.descendant(
          of: find.byKey(const Key('photo_attach_row')),
          matching: find.byType(Text),
        ),
        findsNothing,
      );
    });

    testWidgets('không có nút thêm ảnh mới trong hàng', (
      WidgetTester tester,
    ) async {
      await pumpRow(tester);

      expect(
        find.descendant(
          of: find.byKey(const Key('photo_attach_row')),
          matching: find.byIcon(CupidIcons.add),
        ),
        findsNothing,
      );
    });
  });
}
