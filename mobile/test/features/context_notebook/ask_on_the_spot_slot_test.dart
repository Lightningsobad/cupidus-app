import 'dart:convert';
import 'dart:io';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/context_notebook/context_notebook_entry_point.dart';
import 'package:cupid_mobile/features/context_notebook/data/context_notebook_dao.dart';
import 'package:cupid_mobile/features/context_notebook/data/context_notebook_repository.dart';
import 'package:cupid_mobile/features/context_notebook/domain/ask_cadence_policy.dart';
import 'package:cupid_mobile/features/context_notebook/domain/context_content.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Serves the two packs from memory so the assertions below are about the
/// slot's behaviour, not about what the shipped copy happens to say today.
class _FakeBundle extends CachingAssetBundle {
  _FakeBundle(this._sources);

  final Map<String, String> _sources;

  @override
  Future<ByteData> load(String key) async {
    final String? source = _sources[key];
    if (source == null) {
      throw FlutterError('no fixture for asset "$key"');
    }
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(source)));
  }
}

String _askQuestionsJson(List<Map<String, Object?>> items) => jsonEncode(
      <String, Object?>{
        'id': 'req016.ask_questions',
        'version': '1.0.0',
        'schema_id': askQuestionsSchemaId,
        'items': items,
      },
    );

Map<String, Object?> _question({
  required String id,
  required String prompt,
  required String target,
  required List<String> chips,
  bool allowFreeText = true,
}) =>
    <String, Object?>{
      'id': id,
      'prompt': prompt,
      'target': target,
      'chips': chips,
      'allow_free_text': allowFreeText,
    };

/// Built from [requiredSkillSeedIds] so the AC-11 assertions track the real
/// required-seed list rather than a copy of it.
final String _skillSeedsJson = jsonEncode(<String, Object?>{
  'id': 'req016.skill_seeds',
  'version': '1.0.0',
  'schema_id': skillSeedsSchemaId,
  'items': <Map<String, Object?>>[
    for (final String id in requiredSkillSeedIds)
      <String, Object?>{'id': id, 'label': 'Mồi $id'},
    <String, Object?>{'id': 'skill.chup_anh.v1', 'label': 'Chụp ảnh'},
  ],
});

const List<Map<String, Object?>> _twoInterestQuestions = <Map<String, Object?>>[
  <String, Object?>{
    'id': 'ask.interest.food.v1',
    'prompt': 'Người ấy hợp gu ăn uống kiểu nào?',
    'target': 'notebook.interest',
    'chips': <String>['Món Việt', 'Đồ nướng'],
    'allow_free_text': true,
  },
  <String, Object?>{
    'id': 'ask.interest.hobby.v1',
    'prompt': 'Lúc rảnh người ấy hay làm gì?',
    'target': 'notebook.interest',
    'chips': <String>['Đọc sách', 'Chạy bộ'],
    'allow_free_text': true,
  },
];

void main() {
  late CupidDatabase database;
  late ContextNotebookRepository repository;
  late AskSessionSkips session;
  late int contextChangedCount;

  setUp(() {
    database = CupidDatabase(NativeDatabase.memory());
    repository = ContextNotebookRepository(
      dao: ContextNotebookDao(database),
      ownerKeyStore: BackendUserIdStore()..updateUserId('user-1'),
    );
    session = AskSessionSkips();
    contextChangedCount = 0;
    getIt.registerSingleton<ContextNotebookRepository>(repository);
  });

  tearDown(() async {
    getIt.unregister<ContextNotebookRepository>();
    await database.close();
  });

  ContentPackageLoader loaderFor(List<Map<String, Object?>> questions) =>
      ContentPackageLoader(
        bundle: _FakeBundle(<String, String>{
          askQuestionsAssetKey: _askQuestionsJson(questions),
          skillSeedsAssetKey: _skillSeedsJson,
        }),
      );

  /// The caller's side of the contract: a flow that drops the slot into its
  /// own body and re-runs itself when the context changes. No caller-side
  /// "should I ask?" check exists here on purpose (AC-2 is the widget's job).
  Widget harness({
    required List<Map<String, Object?>> questions,
    List<String> neededFieldIds = const <String>['notebook.interest'],
    int slots = 1,
  }) {
    final ContentPackageLoader loader = loaderFor(questions);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildCupidTheme(
        platform: CupidPlatform.material,
        brightness: Brightness.dark,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              for (int i = 0; i < slots; i++)
                AskOnTheSpotSlot(
                  key: ValueKey<int>(i),
                  entryPointId: 'gift_ideas',
                  neededFieldIds: neededFieldIds,
                  onContextChanged: () => contextChangedCount++,
                  repository: repository,
                  contentLoader: loader,
                  sessionSkips: session,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Lets the drift/asset futures the slot started actually complete.
  Future<void> settle(WidgetTester tester) async {
    for (int i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
  }

  Future<void> tapAndSettle(WidgetTester tester, Key key) async {
    await tester.runAsync(() async {
      await tester.tap(find.byKey(key));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    await settle(tester);
  }

  final Finder card = find.byKey(const Key('ask-on-the-spot-card'));

  group('trả lời tại chỗ, không xác nhận (AC-1)', () {
    testWidgets('the answer disappears with no toast, dialog or save button',
        (WidgetTester tester) async {
      await tester.pumpWidget(harness(questions: _twoInterestQuestions));
      await settle(tester);

      expect(card, findsOneWidget);
      expect(find.text('Người ấy hợp gu ăn uống kiểu nào?'), findsOneWidget);
      expect(find.textContaining('Lưu vào hồ sơ'), findsNothing);

      await tapAndSettle(tester, const Key('ask-chip-Món Việt'));

      expect(card, findsNothing);
      expect(find.byType(SnackBar), findsNothing);
      expect(find.byType(Dialog), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.textContaining('Đã lưu'), findsNothing);
    });

    testWidgets('the answer is written straight through and the flow re-runs',
        (WidgetTester tester) async {
      await tester.pumpWidget(harness(questions: _twoInterestQuestions));
      await settle(tester);
      await tapAndSettle(tester, const Key('ask-chip-Món Việt'));

      final List<NotebookEntry> entries = await tester.runAsync(
        () => repository.entries(),
      ) as List<NotebookEntry>;

      expect(entries.single.value, 'Món Việt');
      expect(entries.single.kind, NotebookKind.interest);
      expect(entries.single.questionId, 'ask.interest.food.v1');
      expect(contextChangedCount, 1);
    });

    testWidgets('a free-text answer is opt-in, never the default box (AC-10)',
        (WidgetTester tester) async {
      await tester.pumpWidget(harness(questions: _twoInterestQuestions));
      await settle(tester);

      expect(find.byType(TextField), findsNothing);

      await tester.tap(find.byKey(const Key('ask-other-chip')));
      await tester.pump();
      expect(find.byType(TextField), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('ask-free-text-field')),
        'Bún bò Huế',
      );
      await tapAndSettle(tester, const Key('ask-free-text-submit'));

      final List<NotebookEntry> entries = await tester.runAsync(
        () => repository.entries(),
      ) as List<NotebookEntry>;
      expect(entries.single.value, 'Bún bò Huế');
    });
  });

  group('đúng một câu một lần (AC-2/BR-2)', () {
    testWidgets('two slots on one route render one card, not two',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        harness(questions: _twoInterestQuestions, slots: 2),
      );
      await settle(tester);

      expect(card, findsOneWidget);
      expect(find.text('Người ấy hợp gu ăn uống kiểu nào?'), findsOneWidget);
      expect(find.text('Lúc rảnh người ấy hay làm gì?'), findsNothing);
    });

    testWidgets('the muted slot stays empty after the first one is answered',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        harness(questions: _twoInterestQuestions, slots: 2),
      );
      await settle(tester);
      await tapAndSettle(tester, const Key('ask-chip-Món Việt'));

      expect(card, findsNothing);
    });
  });

  group('bỏ qua trả lại luồng ngay (AC-3/BR-3)', () {
    testWidgets('skipping hides the card without blocking or scolding',
        (WidgetTester tester) async {
      await tester.pumpWidget(harness(questions: _twoInterestQuestions));
      await settle(tester);

      await tester.tap(find.byKey(const Key('ask-skip')));
      await tester.pump();

      expect(card, findsNothing);
      expect(find.byType(Dialog), findsNothing);
      expect(find.textContaining('chưa'), findsNothing);
      expect(find.textContaining('Hãy'), findsNothing);
      await settle(tester);
    });

    testWidgets('the skipped question is not asked again this session',
        (WidgetTester tester) async {
      await tester.pumpWidget(harness(questions: _twoInterestQuestions));
      await settle(tester);
      await tester.tap(find.byKey(const Key('ask-skip')));
      await settle(tester);

      // Leaving the screen and coming back is the "lần cần tiếp theo" AC-2
      // talks about, so the slot is torn down and rebuilt from scratch.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.pumpWidget(harness(questions: _twoInterestQuestions));
      await settle(tester);

      expect(find.text('Người ấy hợp gu ăn uống kiểu nào?'), findsNothing);
      expect(find.text('Lúc rảnh người ấy hay làm gì?'), findsOneWidget);
    });
  });

  group('mục vừa trả lời đọc lại được qua mặt tiền (AC-4)', () {
    testWidgets('ContextNotebookReader sees what the card just wrote',
        (WidgetTester tester) async {
      await tester.pumpWidget(harness(questions: _twoInterestQuestions));
      await settle(tester);
      await tapAndSettle(tester, const Key('ask-chip-Đồ nướng'));

      final List<NotebookEntry> entries = await tester.runAsync(
        () => contextNotebookReader().entries(kind: NotebookKind.interest),
      ) as List<NotebookEntry>;

      expect(entries.single.value, 'Đồ nướng');
    });
  });

  group('hỏi kỹ năng bằng mồi, không bằng ô trống (AC-10/AC-11)', () {
    testWidgets('every required soft-skill seed is on screen before any typing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        harness(
          questions: <Map<String, Object?>>[
            _question(
              id: 'ask.skill.everyday.v1',
              prompt: 'Việc nhỏ nào bạn hay làm mà người khác thấy tiện?',
              target: 'skill',
              chips: <String>['bị bỏ qua'],
            ),
          ],
          neededFieldIds: const <String>['skill'],
        ),
      );
      await settle(tester);

      expect(card, findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      for (final String id in requiredSkillSeedIds) {
        expect(find.byKey(Key('ask-chip-$id')), findsOneWidget);
      }
      expect(requiredSkillSeedIds.length, greaterThanOrEqualTo(4));
    });

    testWidgets('tapping a seed stores it with its stable seed id',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        harness(
          questions: <Map<String, Object?>>[
            _question(
              id: 'ask.skill.everyday.v1',
              prompt: 'Việc nhỏ nào bạn hay làm mà người khác thấy tiện?',
              target: 'skill',
              chips: <String>['bị bỏ qua'],
            ),
          ],
          neededFieldIds: const <String>['skill'],
        ),
      );
      await settle(tester);
      await tapAndSettle(
        tester,
        Key('ask-chip-${requiredSkillSeedIds.first}'),
      );

      final List<SkillEntry> skills = await tester.runAsync(
        () => contextNotebookReader().skills(),
      ) as List<SkillEntry>;

      expect(skills.single.seedId, requiredSkillSeedIds.first);
      expect(skills.single.label, 'Mồi ${requiredSkillSeedIds.first}');
    });
  });

  group('không có bước bắt điền trước (AC-5/BR-1)', () {
    testWidgets('nothing left to ask renders nothing, not an empty prompt',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        harness(
          questions: _twoInterestQuestions,
          neededFieldIds: const <String>['notebook.event'],
        ),
      );
      await settle(tester);

      expect(card, findsNothing);
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(Dialog), findsNothing);
    });
  });

  group('biên giới import của feature', () {
    test('no file outside features/context_notebook imports an internal', () {
      // The composition root is the one carve-out: it must name the concrete
      // repository to register it, exactly as it does for the journal.
      const String compositionRoot = 'lib/core/di/service_locator.dart';
      const List<String> internalDirs = <String>[
        'lib/features/context_notebook/data/',
        'lib/features/context_notebook/domain/',
        'lib/features/context_notebook/presentation/',
      ];
      final RegExp directive =
          RegExp(r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
              multiLine: true);

      // Resolving the URI is the whole point: this codebase writes intra-lib
      // imports in the relative form, so a matcher that only understands
      // `package:` URIs passes while an internal is being imported.
      String resolve(String fromFile, String uri) {
        const String selfPackage = 'package:cupid_mobile/';
        if (uri.startsWith(selfPackage)) {
          return 'lib/${uri.substring(selfPackage.length)}';
        }
        final List<String> segments = fromFile.split('/')..removeLast();
        for (final String part in uri.split('/')) {
          if (part == '.') {
            continue;
          }
          if (part == '..') {
            segments.removeLast();
            continue;
          }
          segments.add(part);
        }
        return segments.join('/');
      }

      final List<String> offenders = <String>[];
      for (final FileSystemEntity entity
          in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) {
          continue;
        }
        final String path = entity.path;
        if (path.startsWith('lib/features/context_notebook/') ||
            path == compositionRoot) {
          continue;
        }
        for (final RegExpMatch match
            in directive.allMatches(entity.readAsStringSync())) {
          final String uri = match.group(1)!;
          if (uri.startsWith('dart:') ||
              (uri.startsWith('package:') &&
                  !uri.startsWith('package:cupid_mobile/'))) {
            continue;
          }
          final String target = resolve(path, uri);
          if (internalDirs.any(target.startsWith)) {
            offenders.add('$path -> $uri');
          }
        }
      }

      expect(offenders, isEmpty);
    });
  });
}
