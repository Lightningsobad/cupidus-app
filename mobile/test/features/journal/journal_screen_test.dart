import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

// Prefixed: drift generates its own row class named `JournalEntry`, and this
// test asserts against the domain one.
import 'package:cupid_mobile/core/database/cupid_database.dart' as db;
import 'package:cupid_mobile/core/journal/journal_media_store.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/journal/data/journal_repository.dart';
import 'package:cupid_mobile/features/journal/domain/journal_entry.dart';
import 'package:cupid_mobile/features/journal/presentation/screens/journal_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rendered-evidence capture for the story's visual-fidelity gate, following
/// `test/features/reminders/visual_capture_support.dart`. Off by default so the
/// ordinary scoped suite stays hermetic:
///
/// `flutter test test/features/journal/journal_screen_test.dart --dart-define=CAPTURE_VISUALS=true`
const bool kCaptureVisuals = bool.fromEnvironment('CAPTURE_VISUALS');

/// iOS reference viewport. `design-reference-s1:diary-ios.png` is 416x900,
/// i.e. this frame bounded by the capture tool's `--max-edge=900`, so the two
/// images share an aspect ratio and compare without distorting either.
const Size kIosReferenceViewport = Size(393, 852);

const String _captureOutputDir =
    '../data/requirements/REQ-016_solo_stage1_relationship_assistant/'
    'STORY-003_private_journal/visual-fidelity';

final GlobalKey _captureBoundaryKey = GlobalKey();

/// Widget tests ship no asset bundle, so the bundled variable fonts are read
/// off disk; without this every glyph rasterizes as a fallback box.
Future<void> _loadDesignFonts(WidgetTester tester) async {
  await tester.runAsync(() async {
    const Map<String, String> families = <String, String>{
      'Nunito': 'assets/fonts/Nunito-Variable.ttf',
      'Roboto': 'assets/fonts/Roboto-Variable.ttf',
      'Material Symbols Rounded':
          'assets/fonts/MaterialSymbolsRounded-Variable.ttf',
    };
    for (final MapEntry<String, String> entry in families.entries) {
      final Uint8List bytes = await File(entry.value).readAsBytes();
      await (FontLoader(entry.key)
            ..addFont(Future<ByteData>.value(ByteData.view(bytes.buffer))))
          .load();
    }
  });
}

Future<void> _captureAtReferenceViewport(
  WidgetTester tester,
  Widget app,
  String fileName,
) async {
  tester.view.physicalSize = kIosReferenceViewport;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await _loadDesignFonts(tester);
  await tester.pumpWidget(RepaintBoundary(key: _captureBoundaryKey, child: app));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));

  final RenderRepaintBoundary boundary =
      tester.renderObject(find.byKey(_captureBoundaryKey))
          as RenderRepaintBoundary;

  await tester.runAsync(() async {
    final ui.Image image = await boundary.toImage(pixelRatio: 1);
    final ByteData? png = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final File out = File('$_captureOutputDir/$fileName');
    out.parent.createSync(recursive: true);
    out.writeAsBytesSync(png!.buffer.asUint8List());
  });
}

/// In-memory stand-in for the journal rows.
///
/// The real drift-backed repository is exercised by `journal_repository_test`
/// and by `journal_list_cubit_test`, which both run it against a real database.
/// It cannot also drive these widget tests: drift schedules a timer when a
/// query stream is cancelled, and that timer outlives the disposed widget tree,
/// which `testWidgets` fails on. So this fake supplies the same surface the
/// screen depends on, with no timers of its own.
class _FakeJournalRepository extends JournalRepository {
  _FakeJournalRepository({
    required super.database,
    required super.mediaStore,
    required super.backendUserIdStore,
  });

  final List<JournalEntry> entries = <JournalEntry>[];
  final StreamController<void> _changes = StreamController<void>.broadcast();

  int sweepCount = 0;

  void seedAll(List<JournalEntry> seeded) {
    entries
      ..clear()
      ..addAll(seeded);
  }

  Future<void> dispose() => _changes.close();

  List<JournalEntry> _window(int limit, int offset) {
    // Mirrors the real query: newest first, one page window.
    final sorted = entries.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.skip(offset).take(limit).toList();
  }

  @override
  Stream<List<JournalEntry>> watchEntries({int limit = 50, int offset = 0}) async* {
    yield _window(limit, offset);
    yield* _changes.stream.map((_) => _window(limit, offset));
  }

  @override
  Future<JournalEntry?> entryById(String id) async {
    for (final JournalEntry entry in entries) {
      if (entry.id == id) {
        return entry;
      }
    }
    return null;
  }

  @override
  Future<void> deleteEntry(String id) async {
    entries.removeWhere((JournalEntry entry) => entry.id == id);
    _changes.add(null);
  }

  @override
  Future<void> deleteAll() async {
    entries.clear();
    _changes.add(null);
  }

  @override
  Future<void> sweepOrphans() async {
    sweepCount++;
  }
}

void main() {
  late db.CupidDatabase database;
  late Directory baseDir;
  late JournalMediaStore mediaStore;
  late _FakeJournalRepository repository;

  setUp(() {
    database = db.CupidDatabase(NativeDatabase.memory());
    baseDir = Directory.systemTemp.createTempSync('journal_screen_test');
    mediaStore = JournalMediaStore(baseDirectory: () async => baseDir);
    repository = _FakeJournalRepository(
      database: database,
      mediaStore: mediaStore,
      backendUserIdStore: BackendUserIdStore()..updateUserId('user-a'),
    );
  });

  tearDown(() async {
    await repository.dispose();
    await database.close();
    if (baseDir.existsSync()) {
      baseDir.deleteSync(recursive: true);
    }
  });

  void seed(int count) {
    repository.seedAll(<JournalEntry>[
      for (var i = 0; i < count; i++)
        JournalEntry(
          id: 'e-$i',
          ownerUserId: 'user-a',
          bodyText: 'Buổi tối thứ $i, mình đã viết vài dòng ở đây.',
          createdAt: DateTime.utc(2026, 9, 1 + i).millisecondsSinceEpoch,
          updatedAt: DateTime.utc(2026, 9, 1 + i).millisecondsSinceEpoch,
        ),
    ]);
  }

  Widget harness() {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      theme: buildCupidTheme(
        platform: CupidPlatform.material,
        brightness: Brightness.dark,
      ),
      home: JournalScreen(repository: repository, mediaStore: mediaStore),
    );
  }

  /// Pumps until the widget under [finder] exists, so a test never depends on a
  /// fixed frame count between the repository write and the stream emission the
  /// list rebuilds from. `pumpAndSettle` alone cannot do this: the drift stream
  /// resolves on the real event loop, not the test's frame scheduler.
  Future<void> pumpUntil(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      if (finder.evaluate().isNotEmpty) {
        await tester.pumpAndSettle();
        return;
      }
    }
    fail('never found $finder');
  }

  /// Rows in whichever popup menu is currently open. Typed against the base
  /// [PopupMenuEntry] so a row added with a different value type still counts.
  int openMenuRows(WidgetTester tester) {
    return find
        .byWidgetPredicate((Widget widget) => widget is PopupMenuEntry)
        .evaluate()
        .length;
  }

  List<String> visibleText(WidgetTester tester) {
    return tester
        .widgetList<Text>(find.byType(Text))
        .map((Text widget) => widget.data ?? '')
        .where((String text) => text.isNotEmpty)
        .toList();
  }

  group('renders', () {
    testWidgets('the neutral empty state and the single compose CTA',
        (WidgetTester tester) async {
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('journal-empty-body')), findsOneWidget);
      expect(find.byKey(const Key('journal-compose-cta')), findsOneWidget);
      expect(find.byKey(const Key('journal-entry-list')), findsNothing);
    });

    testWidgets('two entries as rows in the list', (WidgetTester tester) async {
      seed(2);
      await tester.pumpWidget(harness());
      await pumpUntil(tester, find.byKey(const Key('journal-entry-list')));

      expect(find.byKey(const Key('journal-entry-e-0')), findsOneWidget);
      expect(find.byKey(const Key('journal-entry-e-1')), findsOneWidget);
      expect(find.byKey(const Key('journal-empty-body')), findsNothing);
    });
  });

  group('absence gates', () {
    // AC-1, BR-4: the screen must carry no entry count, no day streak and no
    // goal progress. These run over both states because a counter that only
    // appears once there is data would still be the drift being gated against.
    final RegExp countLike = RegExp(
      r'\d+\s*(mục|dòng|ngày|bài|entr(y|ies)|days?|notes?)\b',
      caseSensitive: false,
    );
    final RegExp streakLike = RegExp(
      r'chuỗi|liên tiếp|mục tiêu|streak|goal|progress|in a row',
      caseSensitive: false,
    );

    for (final int seedCount in <int>[0, 3]) {
      testWidgets('no counter, streak or progress with $seedCount entries',
          (WidgetTester tester) async {
        seed(seedCount);
        await tester.pumpWidget(harness());
        if (seedCount == 0) {
          await tester.pumpAndSettle();
        } else {
          await pumpUntil(tester, find.byKey(const Key('journal-entry-list')));
        }

        for (final String text in visibleText(tester)) {
          expect(countLike.hasMatch(text), isFalse, reason: 'counter in "$text"');
          expect(streakLike.hasMatch(text), isFalse, reason: 'streak in "$text"');
        }
        expect(find.byType(LinearProgressIndicator), findsNothing);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    }

    testWidgets('no share, export or copy affordance anywhere, menus included',
        (WidgetTester tester) async {
      const List<IconData> forbiddenIcons = <IconData>[
        Icons.share,
        Icons.ios_share,
        Icons.share_outlined,
        Icons.content_copy,
        Icons.copy,
        Icons.download,
        Icons.file_download,
        Icons.upload_file,
        Icons.send,
        Icons.link,
      ];
      final RegExp shareLike = RegExp(
        r'chia sẻ|xuất|sao chép|gửi|share|export|copy|send|download|back ?up',
        caseSensitive: false,
      );

      void assertClean(WidgetTester tester, String where) {
        for (final Icon icon in tester.widgetList<Icon>(find.byType(Icon))) {
          expect(
            forbiddenIcons.contains(icon.icon),
            isFalse,
            reason: 'share-like icon ${icon.icon} in $where',
          );
        }
        for (final String text in visibleText(tester)) {
          expect(
            shareLike.hasMatch(text),
            isFalse,
            reason: 'share-like label "$text" in $where',
          );
        }
      }

      seed(2);
      await tester.pumpWidget(harness());
      await pumpUntil(tester, find.byKey(const Key('journal-entry-list')));
      assertClean(tester, 'the list');

      await tester.tap(find.byKey(const Key('journal-entry-menu')).first);
      await tester.pumpAndSettle();
      assertClean(tester, 'the entry menu');
      // The entry menu holds exactly one row, and it is the delete row.
      expect(openMenuRows(tester), 1);
      expect(find.byKey(const Key('journal-delete-entry-action')), findsOneWidget);
    });

    testWidgets('the header menu holds only the delete-everything row',
        (WidgetTester tester) async {
      seed(2);
      await tester.pumpWidget(harness());
      await pumpUntil(tester, find.byKey(const Key('journal-entry-list')));

      await tester.tap(find.byKey(const Key('journal-header-menu')));
      await tester.pumpAndSettle();

      expect(openMenuRows(tester), 1);
      expect(find.byKey(const Key('journal-delete-all-action')), findsOneWidget);
    });
  });

  group('delete one entry (AC-11)', () {
    testWidgets('removes it through the repository after confirmation',
        (WidgetTester tester) async {
      seed(2);
      await tester.pumpWidget(harness());
      await pumpUntil(tester, find.byKey(const Key('journal-entry-list')));

      // Newest first, so the first row's menu belongs to e-1.
      await tester.tap(find.byKey(const Key('journal-entry-menu')).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('journal-delete-entry-action')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('journal-delete-confirm')), findsOneWidget);
      await tester.tap(find.byKey(const Key('journal-delete-confirm')));
      await tester.pumpAndSettle();

      expect(await repository.entryById('e-1'), isNull);
      expect(await repository.entryById('e-0'), isNotNull);

      await pumpUntil(tester, find.byKey(const Key('journal-entry-e-0')));
      expect(find.byKey(const Key('journal-entry-e-1')), findsNothing);
    });

    testWidgets('cancelling keeps the entry', (WidgetTester tester) async {
      seed(1);
      await tester.pumpWidget(harness());
      await pumpUntil(tester, find.byKey(const Key('journal-entry-list')));

      await tester.tap(find.byKey(const Key('journal-entry-menu')).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('journal-delete-entry-action')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('journal-delete-cancel')));
      await tester.pumpAndSettle();

      expect(await repository.entryById('e-0'), isNotNull);
      expect(find.byKey(const Key('journal-entry-e-0')), findsOneWidget);
    });
  });

  group('delete the whole journal (AC-12)', () {
    testWidgets('empties the list and returns to the empty state',
        (WidgetTester tester) async {
      seed(3);
      await tester.pumpWidget(harness());
      await pumpUntil(tester, find.byKey(const Key('journal-entry-list')));

      await tester.tap(find.byKey(const Key('journal-header-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('journal-delete-all-action')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('journal-delete-confirm')));
      await tester.pumpAndSettle();

      expect(await repository.watchEntries().first, isEmpty);
      await pumpUntil(tester, find.byKey(const Key('journal-empty-body')));
      expect(find.byKey(const Key('journal-entry-list')), findsNothing);
      // No undo affordance survives the delete (AC-13).
      expect(find.byType(SnackBar), findsNothing);
    });
  });

  group('visual capture', () {
    // The design reference is an iOS frame, so the capture uses the iOS theme
    // and viewport rather than the material one the behavioural tests run under.
    Widget iosHarness() {
      return MaterialApp(
        locale: const Locale('vi'),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        // The banner sits over the header menu and would read as a layout
        // difference against the design reference.
        debugShowCheckedModeBanner: false,
        theme: buildCupidTheme(
          platform: CupidPlatform.ios,
          brightness: Brightness.dark,
        ),
        home: Builder(
          // Without this the page renders on MaterialApp's white default and
          // the capture misreports every surface contrast.
          builder: (BuildContext context) => ColoredBox(
            color: context.cupidColors.colorBackground,
            child: JournalScreen(
              repository: repository,
              mediaStore: mediaStore,
            ),
          ),
        ),
      );
    }

    testWidgets('empty state at the iOS reference viewport',
        (WidgetTester tester) async {
      await _captureAtReferenceViewport(
        tester,
        iosHarness(),
        'implemented-s1:diary-empty-ios.png',
      );
    }, skip: !kCaptureVisuals);

    testWidgets('populated state at the iOS reference viewport',
        (WidgetTester tester) async {
      seed(3);
      await _captureAtReferenceViewport(
        tester,
        iosHarness(),
        'implemented-s1:diary-ios.png',
      );
    }, skip: !kCaptureVisuals);
  });
}
