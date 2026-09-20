import 'dart:convert';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/context_notebook/data/context_notebook_dao.dart';
import 'package:cupid_mobile/features/context_notebook/data/context_notebook_repository.dart';
import 'package:cupid_mobile/features/context_notebook/domain/ask_cadence_policy.dart';
import 'package:cupid_mobile/features/context_notebook/domain/context_content.dart';
import 'package:cupid_mobile/features/context_notebook/domain/context_notebook_models.dart';
import 'package:cupid_mobile/features/context_notebook/presentation/screens/skill_profile_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Serves the two packs from memory, so the four-seed assertion tracks
/// [requiredSkillSeedIds] rather than whatever the shipped copy says today.
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

final String _askQuestionsJson = jsonEncode(<String, Object?>{
  'id': 'req016.ask_questions',
  'version': '1.0.0',
  'schema_id': askQuestionsSchemaId,
  'items': <Map<String, Object?>>[
    <String, Object?>{
      'id': 'ask.skill.everyday.v1',
      'prompt': 'Bạn làm được thứ nào trong đây?',
      'target': 'skill',
      'chips': <String>['Nhớ dai'],
      'allow_free_text': true,
    },
  ],
});

/// A level, star, score, tier badge or streak has to render as one of these.
/// None of them may exist on this screen, in any state (AC-12).
const List<IconData> _bannedIcons = <IconData>[
  Icons.star,
  Icons.star_border,
  Icons.star_half,
  Icons.grade,
  Icons.military_tech,
  Icons.emoji_events,
  Icons.workspace_premium,
  Icons.local_fire_department,
  Icons.share,
  Icons.ios_share,
  Icons.share_outlined,
  Icons.copy,
  Icons.content_copy,
  Icons.download,
  Icons.file_download,
  CupidIcons.share,
  CupidIcons.iosShare,
  CupidIcons.militaryTech,
  CupidIcons.localFireDepartment,
];

const List<String> _bannedCopy = <String>[
  'Cấp',
  'Điểm',
  'Hạng',
  'Chia sẻ',
  'Sao chép',
  'Xuất',
  'chuỗi ngày',
  'Huy hiệu',
  'Nâng cấp',
  'Mở khoá',
];

void expectNoBannedSurfaces() {
  for (final IconData icon in _bannedIcons) {
    expect(
      find.byIcon(icon, skipOffstage: false),
      findsNothing,
      reason: 'level/badge/share glyph $icon is forbidden on this screen',
    );
  }
  for (final String copy in _bannedCopy) {
    expect(
      find.textContaining(copy, skipOffstage: false),
      findsNothing,
      reason: 'copy "$copy" is forbidden on this screen',
    );
  }
  expect(find.byType(LinearProgressIndicator, skipOffstage: false), findsNothing);
  expect(
    find.byType(CircularProgressIndicator, skipOffstage: false),
    findsNothing,
  );
  expect(find.byType(Slider, skipOffstage: false), findsNothing);
}

void main() {
  late CupidDatabase database;
  late ContextNotebookRepository repository;
  late AskSessionSkips session;

  setUp(() {
    database = CupidDatabase(NativeDatabase.memory());
    repository = ContextNotebookRepository(
      dao: ContextNotebookDao(database),
      ownerKeyStore: BackendUserIdStore()..updateUserId('user-1'),
    );
    session = AskSessionSkips();
  });

  tearDown(() async {
    await database.close();
  });

  ContentPackageLoader loader() => ContentPackageLoader(
    bundle: _FakeBundle(<String, String>{
      askQuestionsAssetKey: _askQuestionsJson,
      skillSeedsAssetKey: _skillSeedsJson,
    }),
  );

  Widget harness() => MaterialApp(
    locale: const Locale('vi'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    debugShowCheckedModeBanner: false,
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    home: SkillProfileScreen(
      repository: repository,
      contentLoader: loader(),
      sessionSkips: session,
    ),
  );

  group('màn hình rỗng mời bằng mồi, không bằng ô trống (AC-10/AC-11)', () {
    testWidgets('at least four seed chips render before any input box', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      for (final String seedId in requiredSkillSeedIds) {
        expect(
          find.byKey(Key('ask-chip-$seedId')),
          findsOneWidget,
          reason: 'required seed $seedId must be tappable before typing',
        );
      }
      expect(requiredSkillSeedIds.length, greaterThanOrEqualTo(4));

      // The user meets chips first. The only text field on this screen opens
      // behind a deliberate tap ("Khác..." or "+ tự thêm"), never on arrival.
      expect(find.byType(TextField), findsNothing);
      expectNoBannedSurfaces();
    });

    testWidgets('"+ tự thêm" is present and neutral in the empty state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      expect(find.text('Những gì bạn giỏi'), findsOneWidget);
      expect(find.byKey(const Key('skill-profile-add')), findsOneWidget);
      expect(find.text('+ tự thêm'), findsOneWidget);
    });

    testWidgets('tapping a seed chip writes the skill and refreshes the list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('ask-chip-${requiredSkillSeedIds.first}')));
      await tester.pumpAndSettle();

      final SkillEntry stored = (await repository.skills()).single;
      expect(stored.seedId, requiredSkillSeedIds.first);
      expect(stored.source, ContextEntrySource.askOnTheSpot);
      expect(find.text(stored.label), findsOneWidget);
    });
  });

  group('hàng kỹ năng chỉ có tên (AC-12)', () {
    testWidgets('a row renders exactly one Text and no level affordance', (
      WidgetTester tester,
    ) async {
      final SkillEntry saved = await repository.addSkill(
        label: 'Nhớ dai',
        source: ContextEntrySource.manual,
      );
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(Key('skill-entry-${saved.id}')),
          matching: find.byType(Text),
        ),
        findsOneWidget,
        reason: 'name only — a score, level or tier badge would be a second '
            'Text in the row',
      );
      expectNoBannedSurfaces();
    });

    testWidgets('no sub-group splits the list once it has entries', (
      WidgetTester tester,
    ) async {
      await repository.addSkill(
        label: 'Nhớ dai',
        source: ContextEntrySource.manual,
      );
      await repository.addSkill(
        label: 'Gói quà đẹp',
        source: ContextEntrySource.manual,
      );
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      expect(find.text('Nhớ dai'), findsOneWidget);
      expect(find.text('Gói quà đẹp'), findsOneWidget);
      // The design reference's "THỨ KHÔNG AI GỌI LÀ KỸ NĂNG" sub-group is a
      // ranking of the user's own answers, which Phần C rules out.
      expect(find.textContaining('KHÔNG AI GỌI'), findsNothing);
      // The ask card stands down once the list has content.
      expect(find.byKey(const Key('ask-on-the-spot-card')), findsNothing);
      expectNoBannedSurfaces();
    });

    testWidgets('the "..." menu carries exactly Sửa and Xoá', (
      WidgetTester tester,
    ) async {
      final SkillEntry saved = await repository.addSkill(
        label: 'Nhớ dai',
        source: ContextEntrySource.manual,
      );
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('skill-entry-menu-${saved.id}')));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((Widget w) => w is PopupMenuItem),
        findsNWidgets(2),
      );
      expect(find.text('Sửa'), findsOneWidget);
      expect(find.text('Xoá'), findsOneWidget);
      expectNoBannedSurfaces();
    });

    testWidgets('Xoá removes the skill immediately, with no confirmation', (
      WidgetTester tester,
    ) async {
      final SkillEntry saved = await repository.addSkill(
        label: 'Nhớ dai',
        source: ContextEntrySource.manual,
      );
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('skill-entry-menu-${saved.id}')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xoá'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
      expect(await repository.skills(), isEmpty);
    });

    testWidgets('Sửa renames in place, with no dialog and no segmented control', (
      WidgetTester tester,
    ) async {
      final SkillEntry saved = await repository.addSkill(
        label: 'Nhớ dai',
        source: ContextEntrySource.manual,
      );
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('skill-entry-menu-${saved.id}')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sửa'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      // One destination, so no group picker on this screen.
      expect(
        find.byKey(const Key('context-inline-add-segmented')),
        findsNothing,
      );

      await tester.enterText(
        find.byKey(const Key('context-inline-add-field')),
        'Nhớ rất dai',
      );
      await tester.tap(find.byKey(const Key('context-inline-add-save')));
      await tester.pumpAndSettle();

      expect((await repository.skills()).single.label, 'Nhớ rất dai');
    });
  });

  group('"+ tự thêm" trên màn kỹ năng', () {
    testWidgets('typing a skill writes it as a manual entry', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('skill-profile-add')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('context-inline-add-field')),
        'Chọn nhạc hợp cảnh',
      );
      await tester.tap(find.byKey(const Key('context-inline-add-save')));
      await tester.pumpAndSettle();

      final SkillEntry stored = (await repository.skills()).single;
      expect(stored.label, 'Chọn nhạc hợp cảnh');
      expect(stored.source, ContextEntrySource.manual);
      expect(stored.seedId, isNull);
      expectNoBannedSurfaces();
    });
  });
}
