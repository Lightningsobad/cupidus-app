import 'dart:io';
import 'dart:ui' as ui;

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/context_notebook/context_notebook_entry_point.dart';
import 'package:cupid_mobile/features/context_notebook/data/context_notebook_dao.dart';
import 'package:cupid_mobile/features/context_notebook/data/context_notebook_repository.dart';
import 'package:cupid_mobile/features/your_view_portrait/data/portrait_answer_dao.dart';
import 'package:cupid_mobile/features/your_view_portrait/data/portrait_answer_repository.dart';
import 'package:cupid_mobile/features/your_view_portrait/domain/portrait_content.dart';
import 'package:cupid_mobile/features/your_view_portrait/presentation/screens/your_view_portrait_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase P4: the screen the user actually touches — one question at a time,
/// then what their own answers add up to.
///
/// The notebook is reached through the real `context_notebook_entry_point.dart`
/// functions against a real in-memory database, so the AC-22/AC-23 assertions
/// below are evidence about the shipped write path rather than about a stub.
const bool kCaptureVisuals = bool.fromEnvironment('CAPTURE_VISUALS');

const Size kIosReferenceViewport = Size(415, 900);

const String _outputDir =
    '../data/requirements/REQ-016_solo_stage1_relationship_assistant/'
    'STORY-009_your_view_portrait/visual-fidelity';

final GlobalKey _captureBoundaryKey = GlobalKey();

/// Widget tests ship no asset bundle, so the shipped content packs and the
/// bundled fonts are read straight off disk.
class _DiskBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final File file = File(key);
    if (!file.existsSync()) {
      throw FlutterError('no shipped asset at "$key"');
    }
    return ByteData.sublistView(file.readAsBytesSync());
  }
}

Future<void> _loadDesignFonts(WidgetTester tester) async {
  await tester.runAsync(() async {
    const Map<String, String> families = <String, String>{
      'Nunito': 'assets/fonts/Nunito-Variable.ttf',
      'Roboto': 'assets/fonts/Roboto-Variable.ttf',
      'Roboto Mono': 'assets/fonts/RobotoMono-Variable.ttf',
      'Material Symbols Rounded':
          'assets/fonts/MaterialSymbolsRounded-Variable.ttf',
    };
    for (final MapEntry<String, String> entry in families.entries) {
      final Uint8List bytes = await File(entry.value).readAsBytes();
      await (FontLoader(entry.key)
            ..addFont(Future<ByteData>.value(ByteData.view(bytes.buffer))))
          .load();
    }

    // `Icons.help_outline` and `Icons.info_outline` ship with the framework,
    // not under `assets/fonts/`; without this the two glyphs that carry the
    // provenance line and the ask row rasterize as notdef boxes.
    final String? flutterRoot = Platform.environment['FLUTTER_ROOT'];
    if (flutterRoot != null) {
      final File materialIcons = File(
        '$flutterRoot/bin/cache/artifacts/material_fonts/'
        'MaterialIcons-Regular.otf',
      );
      if (materialIcons.existsSync()) {
        final Uint8List bytes = await materialIcons.readAsBytes();
        await (FontLoader('MaterialIcons')
              ..addFont(Future<ByteData>.value(ByteData.view(bytes.buffer))))
            .load();
      }
    }
  });
}

/// `CupidHeader`'s iOS band is a `BackdropFilter` with nothing to sample in an
/// offscreen render, so captures use the opaque Material band.
Widget _harness(Widget home, {CupidPlatform platform = CupidPlatform.material}) {
  return RepaintBoundary(
    key: _captureBoundaryKey,
    child: MaterialApp(
      locale: const Locale('vi'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: buildCupidTheme(platform: platform, brightness: Brightness.dark),
      builder: (BuildContext context, Widget? child) => CupidAppBackground(
        enableEffectsOverride: false,
        child: child!,
      ),
      home: CupidPlatformOverride(platform: platform, child: home),
    ),
  );
}

Future<void> _writeCapture(WidgetTester tester, String fileName) async {
  final RenderRepaintBoundary boundary =
      tester.renderObject(find.byKey(_captureBoundaryKey))
          as RenderRepaintBoundary;

  await tester.runAsync(() async {
    final ui.Image image = await boundary.toImage(pixelRatio: 1);
    final ByteData? png = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final File out = File('$_outputDir/$fileName');
    out.parent.createSync(recursive: true);
    out.writeAsBytesSync(png!.buffer.asUint8List());
  });
}

void main() {
  late CupidDatabase database;
  late PortraitAnswerRepository answers;
  late ContentPackage<PortraitQuestion> questions;
  late ContentPackage<PortraitSection> sections;

  /// A fresh bundle per mount, deliberately. `CachingAssetBundle` keeps the
  /// `Future` it first created, and a future created outside a `testWidgets`
  /// fake-async zone never completes inside one — sharing one bundle with the
  /// setUpAll read below leaves the screen mounted on its loading frame
  /// forever.
  ContentPackageLoader freshLoader() =>
      ContentPackageLoader(bundle: _DiskBundle());

  setUpAll(() async {
    final ContentPackageLoader loader = freshLoader();
    questions = await loader.load<PortraitQuestion>(
      portraitQuestionsAssetKey,
      expectedSchemaId: portraitQuestionsSchemaId,
      itemParser: portraitQuestionFromJson,
    );
    sections = await loader.load<PortraitSection>(
      portraitSectionsAssetKey,
      expectedSchemaId: portraitSectionsSchemaId,
      itemParser: portraitSectionFromJson,
    );
  });

  setUp(() {
    database = CupidDatabase(NativeDatabase.memory());
    getIt.registerSingleton<ContextNotebookRepository>(
      ContextNotebookRepository(
        dao: ContextNotebookDao(database),
        ownerKeyStore: BackendUserIdStore()..updateUserId('user-1'),
      ),
    );
    answers = PortraitAnswerRepository(
      dao: PortraitAnswerDao(database),
      ownerKeyStore: BackendUserIdStore()..updateUserId('user-1'),
    );
  });

  tearDown(() async {
    await getIt.unregister<ContextNotebookRepository>();
    await database.close();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      _harness(
        YourViewPortraitScreen(answers: answers, contentLoader: freshLoader()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> answerCurrent(WidgetTester tester, PortraitQuestion question)
      async {
    await tester.tap(find.byKey(Key('portrait-chip-${question.chips.first}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('portrait-next')));
    await tester.pumpAndSettle();
  }

  Future<void> skipCurrent(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('portrait-skip')));
    await tester.pumpAndSettle();
  }

  List<String> visibleText(WidgetTester tester) {
    return tester
        .widgetList<Text>(find.byType(Text))
        .map((Text text) => text.data ?? '')
        .toList();
  }

  group('the question pass', () {
    testWidgets('opens on the first question with the provenance line and a '
        'skip as reachable as the next action (AC-6, AC-25)',
        (WidgetTester tester) async {
      await pumpScreen(tester);

      expect(find.byKey(const Key('portrait-provenance')), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('portrait-question-prompt')))
            .data,
        questions.items.first.prompt,
      );
      expect(find.byKey(const Key('portrait-skip')), findsOneWidget);
      expect(find.byKey(const Key('portrait-next')), findsOneWidget);

      // Same row, so declining costs no more reach than continuing.
      final Offset skip = tester.getCenter(
        find.byKey(const Key('portrait-skip')),
      );
      final Offset next = tester.getCenter(
        find.byKey(const Key('portrait-next')),
      );
      expect(skip.dy, next.dy);
    });

    testWidgets('shows exactly one question at a time (AC-25)',
        (WidgetTester tester) async {
      await pumpScreen(tester);

      expect(find.byKey(const Key('portrait-question-prompt')), findsOneWidget);
      for (final PortraitQuestion question in questions.items.skip(1)) {
        expect(find.text(question.prompt), findsNothing);
      }
    });

    testWidgets('a skip moves on and the pass never comes back to it '
        '(AC-25, AC-27)', (WidgetTester tester) async {
      await pumpScreen(tester);

      await skipCurrent(tester);
      expect(
        tester.widget<Text>(find.byKey(const Key('portrait-question-prompt')))
            .data,
        questions.items[1].prompt,
      );

      for (int i = 1; i < questions.length; i++) {
        await skipCurrent(tester);
      }

      // Everything declined is still a finished pass, not an error state.
      expect(find.byKey(const Key('portrait-result-list')), findsOneWidget);
    });

    testWidgets('reopening lands on the exact unfinished question, with '
        'nothing nagging about the rest (AC-27)',
        (WidgetTester tester) async {
      await pumpScreen(tester);
      await answerCurrent(tester, questions.items[0]);
      await answerCurrent(tester, questions.items[1]);

      // A fresh mount is what reopening the screen does.
      await tester.pumpWidget(const SizedBox.shrink());
      await pumpScreen(tester);

      expect(
        tester.widget<Text>(find.byKey(const Key('portrait-question-prompt')))
            .data,
        questions.items[2].prompt,
      );
      for (final String text in visibleText(tester)) {
        expect(
          text.toLowerCase(),
          isNot(matches(RegExp('chưa xong|hoàn tất|còn thiếu|dở dang'))),
        );
      }
    });

    testWidgets('a question the packs allow free text on accepts typing '
        'instead of a chip', (WidgetTester tester) async {
      final PortraitQuestion first = questions.items.first;
      expect(first.allowFreeText, isTrue);

      await pumpScreen(tester);
      await tester.enterText(
        find.byKey(const Key('portrait-free-text')),
        'Cháo trắng lúc ốm',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('portrait-next')));
      await tester.pumpAndSettle();

      final PortraitAnswer? stored = await answers.answerFor(first.id);
      expect(stored?.state, PortraitAnswerState.answered);
    });
  });

  group('the notebook boundary', () {
    testWidgets('a notebook question lands in the notebook and a guess does '
        'not (AC-22, AC-23)', (WidgetTester tester) async {
      await pumpScreen(tester);
      for (final PortraitQuestion question in questions.items) {
        await answerCurrent(tester, question);
      }

      final List<NotebookEntry> entries = await contextNotebookReader()
          .entries();
      final List<String> notebookQuestionIds = questions.items
          .where((PortraitQuestion q) => q.target.writesToNotebook)
          .map((PortraitQuestion q) => q.id)
          .toList();

      expect(
        entries.map((NotebookEntry e) => e.questionId).toSet(),
        notebookQuestionIds.toSet(),
      );
      expect(entries.length, notebookQuestionIds.length);

      for (final PortraitQuestion question in questions.items) {
        final PortraitAnswer? stored = await answers.answerFor(question.id);
        if (question.target.writesToNotebook) {
          expect(stored?.notebookEntryId, isNotNull);
          expect(stored?.answerValue, isNull);
        } else {
          expect(stored?.notebookEntryId, isNull);
          expect(stored?.answerValue, isNotNull);
        }
      }
    });

    testWidgets('the notebook write happens without asking for confirmation',
        (WidgetTester tester) async {
      await pumpScreen(tester);
      await answerCurrent(tester, questions.items.first);

      expect(find.byType(Dialog), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
      expect((await contextNotebookReader().entries()).length, 1);
    });
  });

  group('the result page', () {
    Future<void> completeEveryQuestion(WidgetTester tester) async {
      await pumpScreen(tester);
      for (final PortraitQuestion question in questions.items) {
        await answerCurrent(tester, question);
      }
    }

    /// The result list builds lazily, so anything below the fold is absent
    /// from the element tree until it is scrolled to.
    Future<Set<String>> readWholeResult(WidgetTester tester) async {
      final Set<String> seen = <String>{...visibleText(tester)};
      for (int i = 0; i < 8; i++) {
        await tester.drag(
          find.byKey(const Key('portrait-result-list')),
          const Offset(0, -400),
        );
        await tester.pumpAndSettle();
        seen.addAll(visibleText(tester));
      }
      return seen;
    }

    testWidgets('renders one block per section, each closed by its own ask '
        'line (AC-20)', (WidgetTester tester) async {
      await completeEveryQuestion(tester);

      for (final PortraitSection section in sections.items) {
        final Finder block = find.byKey(Key('portrait-section-${section.id}'));
        await tester.scrollUntilVisible(
          block,
          200,
          scrollable: find.byType(Scrollable).first,
        );

        expect(block, findsOneWidget);
        expect(
          find.descendant(
            of: block,
            matching: find.byKey(Key('portrait-ask-${section.id}')),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(of: block, matching: find.byIcon(Icons.help_outline)),
          findsOneWidget,
        );
      }
    });

    testWidgets('carries no measure, no progress and no completion badge '
        '(AC-12, AC-26, AC-28)', (WidgetTester tester) async {
      await completeEveryQuestion(tester);

      expect(find.byKey(const Key('portrait-question-position')), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(Slider), findsNothing);

      for (final String text in await readWholeResult(tester)) {
        expect(
          text.toLowerCase(),
          isNot(
            matches(
              RegExp(r'%|/10|điểm|xếp hạng|huy hiệu|streak|hoàn tất'),
            ),
          ),
        );
      }
    });

    testWidgets('offers no export, share or copy at the end (AC-24)',
        (WidgetTester tester) async {
      await completeEveryQuestion(tester);
      final Set<String> everything = await readWholeResult(tester);

      for (final IconData icon in <IconData>[
        Icons.share,
        Icons.ios_share,
        Icons.copy,
        Icons.content_copy,
        Icons.download,
        Icons.save_alt,
      ]) {
        expect(find.byIcon(icon), findsNothing);
      }
      for (final String text in everything) {
        expect(
          text.toLowerCase(),
          isNot(matches(RegExp('chia sẻ|xuất bản|sao chép|lưu ảnh'))),
        );
      }
    });

    testWidgets('keeps the provenance line on screen after scrolling to the '
        'bottom (AC-7)', (WidgetTester tester) async {
      await completeEveryQuestion(tester);

      expect(find.byKey(const Key('portrait-provenance')), findsOneWidget);
      await tester.drag(
        find.byKey(const Key('portrait-result-list')),
        const Offset(0, -2000),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('portrait-provenance')), findsOneWidget);
      expect(
        tester.getTopLeft(find.byKey(const Key('portrait-provenance'))).dy,
        lessThan(
          tester.getTopLeft(find.byKey(const Key('portrait-result-list'))).dy,
        ),
      );
    });

    testWidgets('a pass the user declined outright still renders, reduced to '
        'the ask lines (AC-19)', (WidgetTester tester) async {
      await pumpScreen(tester);
      for (int i = 0; i < questions.length; i++) {
        await skipCurrent(tester);
      }

      expect(find.byKey(const Key('portrait-result-list')), findsOneWidget);
      for (final PortraitSection section in sections.items) {
        expect(find.byKey(Key('portrait-ask-${section.id}')), findsOneWidget);
      }
    });

    testWidgets('renders identically twice over the same answers (AC-29)',
        (WidgetTester tester) async {
      await completeEveryQuestion(tester);
      final List<String> first = visibleText(tester);

      await tester.pumpWidget(const SizedBox.shrink());
      await pumpScreen(tester);

      expect(visibleText(tester), first);
    });
  });

  group('rendered evidence', () {
    testWidgets('captures the open question', (WidgetTester tester) async {
      tester.view.physicalSize = kIosReferenceViewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await _loadDesignFonts(tester);

      await pumpScreen(tester);
      await tester.tap(
        find.byKey(Key('portrait-chip-${questions.items.first.chips.first}')),
      );
      await tester.pumpAndSettle();

      await _writeCapture(
        tester,
        'implemented-8-chan-dung-theo-cach-ban-nhin-cau-hoi-md.png',
      );
    }, skip: !kCaptureVisuals);

    testWidgets('captures the scrolled result page', (WidgetTester tester) async {
      tester.view.physicalSize = kIosReferenceViewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await _loadDesignFonts(tester);

      await pumpScreen(tester);
      for (final PortraitQuestion question in questions.items) {
        await answerCurrent(tester, question);
      }
      await tester.drag(
        find.byKey(const Key('portrait-result-list')),
        const Offset(0, -240),
      );
      await tester.pumpAndSettle();

      await _writeCapture(
        tester,
        'implemented-8-chan-dung-theo-cach-ban-nhin-ket-qua-md.png',
      );
    }, skip: !kCaptureVisuals);
  });
}
