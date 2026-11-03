import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cupid_mobile/core/database/cupid_database.dart' as db;
import 'package:cupid_mobile/core/journal/journal_media_store.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/journal/data/journal_repository.dart';
import 'package:cupid_mobile/features/journal/domain/journal_entry.dart';
import 'package:cupid_mobile/features/journal/presentation/journal_composer_cubit.dart';
import 'package:cupid_mobile/features/journal/presentation/screens/journal_composer_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

/// Rendered-evidence capture for the story's visual-fidelity gate, same switch
/// and same output directory as `journal_screen_test.dart`:
///
/// `flutter test test/features/journal/journal_composer_screen_test.dart --dart-define=CAPTURE_VISUALS=true`
const bool kCaptureVisuals = bool.fromEnvironment('CAPTURE_VISUALS');

const Size kIosReferenceViewport = Size(393, 852);

const String _captureOutputDir =
    '../data/requirements/REQ-016_solo_stage1_relationship_assistant/'
    'STORY-003_private_journal/visual-fidelity';

final GlobalKey _captureBoundaryKey = GlobalKey();

/// A real, opaque 2x2 PNG. The strip decodes what it is given, so a random
/// byte blob would fall through `errorBuilder` and misreport the frame; a
/// transparent one would leave the capture's preview tile invisible.
final Uint8List _fixturePng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91JpzAAAAF0lEQVR42mN4UblyWsI+'
  'hoqAVS+m7QMAM5sHbVdDd/4AAAAASUVORK5CYII=',
);

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

/// Lets real file I/O and the image codec run: `FileImage` and
/// `JournalMediaStore` both touch the disk, and neither resolves inside the
/// test's fake-async zone.
Future<void> _flushIo(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump();
  }
}

void main() {
  late db.CupidDatabase database;
  late Directory baseDir;
  late Directory callerDir;
  late JournalMediaStore mediaStore;
  late JournalRepository repository;
  String? popResult;

  setUp(() {
    database = db.CupidDatabase(NativeDatabase.memory());
    baseDir = Directory.systemTemp.createTempSync('journal_composer_screen');
    callerDir = Directory.systemTemp.createTempSync('journal_composer_source');
    mediaStore = JournalMediaStore(
      baseDirectory: () async => baseDir,
      ownerUserId: () => 'user-a',
    );
    repository = JournalRepository(
      database: database,
      mediaStore: mediaStore,
      backendUserIdStore: BackendUserIdStore()..updateUserId('user-a'),
    );
    popResult = null;
  });

  tearDown(() async {
    await database.close();
    for (final Directory dir in <Directory>[baseDir, callerDir]) {
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    }
  });

  File sourcePhoto(String name) {
    return File(p.join(callerDir.path, name))..writeAsBytesSync(_fixturePng);
  }

  Widget composer({
    String? entryId,
    String? seedText,
    List<String> seedPhotoPaths = const <String>[],
    String? originRef,
    JournalImagePicker? pickImages,
  }) {
    return JournalComposerScreen(
      repository: repository,
      mediaStore: mediaStore,
      entryId: entryId,
      seedText: seedText,
      seedPhotoPaths: seedPhotoPaths,
      originRef: originRef,
      pickImages: pickImages,
    );
  }

  /// The composer is a pushed route in the product, and the tests push it the
  /// same way: its back affordance and its pop-with-id both depend on there
  /// being a route underneath.
  ///
  /// Each call carries a fresh key so a test that opens the composer more than
  /// once gets a new navigator rather than pumping into the one still holding
  /// the previous route.
  var appSeq = 0;
  Widget harness(
    Widget child, {
    Locale locale = const Locale('en'),
    CupidPlatform platform = CupidPlatform.material,
    bool withAppBackground = false,
  }) {
    return MaterialApp(
      key: ValueKey<int>(appSeq++),
      locale: locale,
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: buildCupidTheme(platform: platform, brightness: Brightness.dark),
      // The app shell paints `colorBackground` and the sky wash behind every
      // route from `MaterialApp.builder`; a route rendered without it sits on
      // the framework's default white. Only the capture needs that, and the
      // FX layer is off so nothing animates under the shutter.
      builder: withAppBackground
          ? (BuildContext context, Widget? routes) => CupidAppBackground(
                enableEffectsOverride: false,
                child: routes!,
              )
          : null,
      home: Builder(
        builder: (BuildContext context) => Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: TextButton(
              key: const Key('open-composer'),
              onPressed: () async {
                popResult = await Navigator.of(context).push<String>(
                  MaterialPageRoute<String>(builder: (_) => child),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> open(WidgetTester tester, Widget app) async {
    await tester.pumpWidget(app);
    await tester.tap(find.byKey(const Key('open-composer')));
    await tester.pumpAndSettle();
    await _flushIo(tester);
  }

  Future<void> tapSave(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('journal-composer-save')));
    await tester.pump();
    await _flushIo(tester);
    await tester.pumpAndSettle();
  }

  /// Row reads go straight at the tables rather than through
  /// `watchEntries()`: cancelling a drift query stream schedules a timer that
  /// outlives the disposed widget tree, which `testWidgets` fails on.
  /// Saving an entry that carries photos copies files, and a `File.copy`
  /// started inside the test's fake-async zone never resumes. The tap itself
  /// is dispatched from the real zone so the copy can complete.
  Future<void> tapSaveWithMedia(WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('journal-composer-save')));
      await Future<void>.delayed(const Duration(milliseconds: 400));
    });
    await tester.pumpAndSettle();
  }

  Future<List<String>> savedIds() async {
    final List<db.JournalEntry> rows =
        await database.select(database.journalEntries).get();
    return <String>[for (final db.JournalEntry row in rows) row.id];
  }

  /// The one saved entry, as the domain object the assertions are written
  /// against. Fails loudly rather than returning null when there is not
  /// exactly one.
  Future<JournalEntry> onlyEntry() async {
    final List<String> ids = await savedIds();
    expect(ids, hasLength(1));
    return (await repository.entryById(ids.single))!;
  }

  String hintText(WidgetTester tester) {
    final TextField field = tester.widget<TextField>(
      find.byKey(const Key('journal-composer-body-field')),
    );
    return field.decoration!.hintText!;
  }

  List<String> readableStrings(WidgetTester tester) {
    return <String>[
      for (final Text widget in tester.widgetList<Text>(find.byType(Text)))
        if (widget.data != null) widget.data!,
      for (final Tooltip widget
          in tester.widgetList<Tooltip>(find.byType(Tooltip)))
        if (widget.message != null) widget.message!,
      for (final Semantics widget
          in tester.widgetList<Semantics>(find.byType(Semantics)))
        if (widget.properties.label != null) widget.properties.label!,
      for (final Image widget in tester.widgetList<Image>(find.byType(Image)))
        if (widget.semanticLabel != null) widget.semanticLabel!,
    ];
  }

  group('renders the three entry modes', () {
    testWidgets('blank opens on the writing prompt with save unavailable',
        (WidgetTester tester) async {
      await open(tester, harness(composer()));

      expect(find.text('New entry'), findsOneWidget);
      expect(hintText(tester), 'Anything you want to keep from today?');
      expect(find.byKey(const Key('journal-composer-attach')), findsOneWidget);
      expect(find.byKey(const Key('journal-composer-attachments')), findsNothing);

      final TextButton save = tester.widget<TextButton>(
        find.byKey(const Key('journal-composer-save')),
      );
      expect(save.onPressed, isNull);
    });

    testWidgets('editing opens on the saved text under the edit title',
        (WidgetTester tester) async {
      await repository.saveEntry(id: 'entry-1', bodyText: 'Bản đầu.');

      await open(tester, harness(composer(entryId: 'entry-1')));

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('New entry'), findsNothing);
      expect(find.text('Bản đầu.'), findsOneWidget);
    });

    testWidgets('seeded opens pre-filled and its photo is already attached',
        (WidgetTester tester) async {
      final File photo = sourcePhoto('seed.png');

      await open(
        tester,
        harness(
          composer(
            seedText: 'Câu mồi từ màn khác',
            seedPhotoPaths: <String>[photo.path],
            originRef: 'story-007:thankyou-42',
          ),
        ),
      );

      expect(find.text('Câu mồi từ màn khác'), findsOneWidget);
      expect(find.byKey(const Key('journal-composer-photo-0')), findsOneWidget);
      // AC-9: `originRef` is stored, never shown.
      expect(find.textContaining('story-007'), findsNothing);
      expect(find.textContaining('thankyou'), findsNothing);
    });
  });

  group('writing and saving', () {
    testWidgets('typing enables save, and the tap writes the entry and pops it',
        (WidgetTester tester) async {
      await open(tester, harness(composer()));

      await tester.enterText(
        find.byKey(const Key('journal-composer-body-field')),
        'Chiều nay trời mát.',
      );
      await tester.pump();

      final TextButton save = tester.widget<TextButton>(
        find.byKey(const Key('journal-composer-save')),
      );
      expect(save.onPressed, isNotNull);

      await tapSave(tester);

      final JournalEntry saved = await onlyEntry();
      expect(saved.bodyText, 'Chiều nay trời mát.');
      expect(saved.origin, JournalEntryOrigin.manual);
      expect(popResult, saved.id);
      expect(find.byKey(const Key('journal-composer-body-field')), findsNothing);
    });

    testWidgets('a picked photo previews, then saves into the journal\'s own '
        'storage', (WidgetTester tester) async {
      final File picked = sourcePhoto('picked.png');

      await open(
        tester,
        harness(
          composer(pickImages: () async => <XFile>[XFile(picked.path)]),
        ),
      );

      await tester.tap(find.byKey(const Key('journal-composer-attach')));
      await tester.pumpAndSettle();
      await _flushIo(tester);

      expect(find.byKey(const Key('journal-composer-photo-0')), findsOneWidget);

      await tapSaveWithMedia(tester);

      final JournalEntry saved = await onlyEntry();
      expect(saved.photos, hasLength(1));
      final File stored =
          await mediaStore.resolvePhoto(saved.photos.single.relativePath);
      // AC-4: every attachment is the journal's own copy, inside its media root.
      expect(p.isWithin(baseDir.path, stored.path), isTrue);
      expect(stored.existsSync(), isTrue);
    });

    testWidgets('an attached photo can be taken back off before saving',
        (WidgetTester tester) async {
      final File picked = sourcePhoto('regret.png');

      await open(
        tester,
        harness(
          composer(
            seedText: 'Giữ chữ, bỏ ảnh',
            seedPhotoPaths: <String>[picked.path],
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('journal-composer-remove-photo-0')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('journal-composer-attachments')), findsNothing);

      await tapSave(tester);

      final JournalEntry saved = await onlyEntry();
      expect(saved.photos, isEmpty);
      expect(saved.bodyText, 'Giữ chữ, bỏ ảnh');
    });
  });

  group('editing overwrites the same entry (AC-3)', () {
    testWidgets('saving an edit leaves one row, not a second one',
        (WidgetTester tester) async {
      await repository.saveEntry(id: 'entry-1', bodyText: 'Bản đầu.');

      await open(tester, harness(composer(entryId: 'entry-1')));

      await tester.enterText(
        find.byKey(const Key('journal-composer-body-field')),
        'Bản đã sửa.',
      );
      await tester.pump();
      await tapSave(tester);

      final JournalEntry saved = await onlyEntry();
      expect(saved.id, 'entry-1');
      expect(saved.bodyText, 'Bản đã sửa.');
      expect(popResult, 'entry-1');
    });

    testWidgets('leaving the composer without saving writes nothing (BR-5)',
        (WidgetTester tester) async {
      await open(
        tester,
        harness(composer(seedText: 'Không bao giờ được lưu')),
      );

      await tester.enterText(
        find.byKey(const Key('journal-composer-body-field')),
        'Vẫn không lưu',
      );
      await tester.pump();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await _flushIo(tester);

      expect(await savedIds(), isEmpty);
      expect(popResult, isNull);
      // No draft survives anywhere the composer could reach (AC-13).
      expect(baseDir.listSync(), isEmpty);
    });
  });

  group('the absences the story is about', () {
    testWidgets('no share, export or copy affordance anywhere (AC-6)',
        (WidgetTester tester) async {
      final File photo = sourcePhoto('with-photo.png');

      for (final Locale locale in const <Locale>[Locale('vi'), Locale('en')]) {
        await open(
          tester,
          harness(
            composer(
              seedText: 'Một dòng có ảnh',
              seedPhotoPaths: <String>[photo.path],
            ),
            locale: locale,
          ),
        );

        const List<IconData> forbiddenIcons = <IconData>[
          // The design system's own share glyphs first: the composer draws
          // from `CupidIcons`, so a share affordance would come from here
          // rather than from Material.
          CupidIcons.share,
          CupidIcons.iosShare,
          CupidIcons.link,
          Icons.share,
          Icons.share_outlined,
          Icons.ios_share,
          Icons.copy,
          Icons.copy_all,
          Icons.content_copy,
          Icons.download,
          Icons.file_download,
          Icons.file_upload,
          Icons.cloud_upload,
          Icons.send,
          Icons.print,
          Icons.picture_as_pdf,
          Icons.link,
        ];
        for (final IconData icon in forbiddenIcons) {
          expect(find.byIcon(icon), findsNothing, reason: '$locale: $icon');
        }

        final RegExp shareLike = RegExp(
          r'chia sẻ|xuất|sao chép|gửi|in ra|share|export|copy|send|'
          r'download|back ?up|pdf',
          caseSensitive: false,
        );
        for (final String text in readableStrings(tester)) {
          expect(shareLike.hasMatch(text), isFalse,
              reason: '$locale: "$text" reads as a share/export affordance');
        }
      }
    });

    testWidgets('the writing prompt is one fixed string, not a generated one '
        '(BR-8)', (WidgetTester tester) async {
      await repository.saveEntry(id: 'entry-1', bodyText: 'Bản đầu.');
      final List<String> prompts = <String>[];

      await open(tester, harness(composer()));
      prompts.add(hintText(tester));

      await tester.enterText(
        find.byKey(const Key('journal-composer-body-field')),
        'gõ rồi xoá',
      );
      await tester.pump();
      prompts.add(hintText(tester));

      await tester.enterText(
        find.byKey(const Key('journal-composer-body-field')),
        '',
      );
      await tester.pump();
      prompts.add(hintText(tester));

      // A second, independent open — and an edit-mode one, which takes a
      // different code path to the same field.
      await open(tester, harness(composer()));
      prompts.add(hintText(tester));

      await open(tester, harness(composer(entryId: 'entry-1')));
      prompts.add(hintText(tester));

      expect(prompts.first, isNotEmpty);
      expect(prompts.toSet(), hasLength(1));
    });

    testWidgets('no counter, streak or progress reading (BR-4)',
        (WidgetTester tester) async {
      await open(tester, harness(composer(), locale: const Locale('vi')));

      final RegExp countLike =
          RegExp(r'\d+\s*(mục|dòng|ngày|bài|chữ|từ|entr(y|ies)|days?|words?)\b');
      final RegExp streakLike =
          RegExp(r'chuỗi|liên tục|streak|mục tiêu|goal', caseSensitive: false);
      for (final String text in readableStrings(tester)) {
        expect(countLike.hasMatch(text), isFalse, reason: '"$text"');
        expect(streakLike.hasMatch(text), isFalse, reason: '"$text"');
      }
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  });

  group('visual capture', () {
    Future<void> capture(
      WidgetTester tester,
      Widget app,
      String fileName, {
      File? attachedPhoto,
    }) async {
      tester.view.physicalSize = kIosReferenceViewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await _loadDesignFonts(tester);
      await tester.pumpWidget(
        RepaintBoundary(key: _captureBoundaryKey, child: app),
      );

      if (attachedPhoto != null) {
        // A `FileImage` first resolved by the widget reads and decodes inside
        // the test's fake-async zone and never finishes, so the preview would
        // capture blank. Warming the shared image cache from the real zone
        // first means the strip's own resolve is a completed cache hit.
        await tester.runAsync(() async {
          await precacheImage(
            FileImage(attachedPhoto),
            tester.element(find.byKey(const Key('open-composer'))),
          );
        });
        await tester.pump();
      }

      await tester.tap(find.byKey(const Key('open-composer')));
      await tester.pumpAndSettle();
      await _flushIo(tester);
      await tester.pump(const Duration(milliseconds: 250));

      final RenderRepaintBoundary boundary =
          tester.renderObject(find.byKey(_captureBoundaryKey))
              as RenderRepaintBoundary;

      await tester.runAsync(() async {
        final ui.Image image = await boundary.toImage(pixelRatio: 1);
        final ByteData? png =
            await image.toByteData(format: ui.ImageByteFormat.png);
        image.dispose();
        final File out = File('$_captureOutputDir/$fileName');
        out.parent.createSync(recursive: true);
        out.writeAsBytesSync(png!.buffer.asUint8List());
      });
    }

    testWidgets('empty composer at the iOS reference viewport',
        (WidgetTester tester) async {
      await capture(
        tester,
        harness(
          composer(),
          locale: const Locale('vi'),
          platform: CupidPlatform.ios,
          withAppBackground: true,
        ),
        'implemented-s1-diary-compose-empty-ios.png',
      );
    }, skip: !kCaptureVisuals);

    testWidgets('composer with text and an attached photo',
        (WidgetTester tester) async {
      final File photo = sourcePhoto('capture.png');
      await capture(
        tester,
        harness(
          composer(
            seedText: 'Chiều nay hai đứa đi bộ vòng hồ, trời mát, '
                'mình muốn giữ lại cảm giác này.',
            seedPhotoPaths: <String>[photo.path],
          ),
          locale: const Locale('vi'),
          platform: CupidPlatform.ios,
          withAppBackground: true,
        ),
        'implemented-s1-diary-compose-photo-ios.png',
        attachedPhoto: photo,
      );
    }, skip: !kCaptureVisuals);
  });
}
