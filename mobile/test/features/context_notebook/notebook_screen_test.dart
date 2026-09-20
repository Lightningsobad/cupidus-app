import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/context_notebook/data/context_notebook_dao.dart';
import 'package:cupid_mobile/features/context_notebook/data/context_notebook_repository.dart';
import 'package:cupid_mobile/features/context_notebook/domain/context_notebook_models.dart';
import 'package:cupid_mobile/features/context_notebook/presentation/screens/notebook_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Affordances that must not exist anywhere on this screen, in any state, and
/// not inside the "..." menu either (AC-9, AC-25, `contract-summary.md` §6).
const List<IconData> _bannedIcons = <IconData>[
  Icons.share,
  Icons.ios_share,
  Icons.share_outlined,
  Icons.copy,
  Icons.content_copy,
  Icons.download,
  Icons.file_download,
  Icons.local_fire_department,
  Icons.military_tech,
  Icons.emoji_events,
  Icons.star,
  Icons.star_border,
  CupidIcons.share,
  CupidIcons.iosShare,
  CupidIcons.localFireDepartment,
  CupidIcons.militaryTech,
];

const List<String> _bannedCopy = <String>[
  'Chia sẻ',
  'Sao chép',
  'Xuất',
  'chuỗi ngày',
  'Huy hiệu',
  'Nâng cấp',
  'Mở khoá',
  'hoàn thiện',
];

void expectNoBannedSurfaces() {
  for (final IconData icon in _bannedIcons) {
    expect(
      find.byIcon(icon, skipOffstage: false),
      findsNothing,
      reason: 'share/export/gamification glyph $icon is forbidden here',
    );
  }
  for (final String copy in _bannedCopy) {
    expect(
      find.textContaining(copy, skipOffstage: false),
      findsNothing,
      reason: 'copy "$copy" is forbidden here',
    );
  }
  expect(find.byType(LinearProgressIndicator, skipOffstage: false), findsNothing);
  expect(
    find.byType(CircularProgressIndicator, skipOffstage: false),
    findsNothing,
  );
  expect(find.byType(Slider, skipOffstage: false), findsNothing);
}

NotebookEntry _entry({
  required String id,
  required NotebookKind kind,
  required String value,
  String? detail,
}) {
  final DateTime at = DateTime.utc(2026, 9, 10);
  return NotebookEntry(
    id: id,
    ownerKey: 'user-1',
    kind: kind,
    value: value,
    detail: detail,
    source: ContextEntrySource.manual,
    createdAt: at,
    updatedAt: at,
  );
}

void main() {
  late CupidDatabase database;
  late ContextNotebookRepository repository;

  setUp(() {
    database = CupidDatabase(NativeDatabase.memory());
    repository = ContextNotebookRepository(
      dao: ContextNotebookDao(database),
      ownerKeyStore: BackendUserIdStore()..updateUserId('user-1'),
    );
  });

  tearDown(() async {
    await database.close();
  });

  Widget harness() => MaterialApp(
    locale: const Locale('vi'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    debugShowCheckedModeBanner: false,
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    home: NotebookScreen(repository: repository),
  );

  group('gom nhóm (unit)', () {
    test('both fixed groups are always present, even when empty', () {
      final Map<NotebookKind, List<NotebookEntry>> grouped =
          groupNotebookEntries(const <NotebookEntry>[]);

      expect(grouped.keys, notebookGroupOrder);
      expect(grouped[NotebookKind.interest], isEmpty);
      expect(grouped[NotebookKind.event], isEmpty);
    });

    test('entries land in their own group and keep the repository order', () {
      final Map<NotebookKind, List<NotebookEntry>> grouped =
          groupNotebookEntries(<NotebookEntry>[
            _entry(id: 'a', kind: NotebookKind.interest, value: 'Trà sữa'),
            _entry(id: 'b', kind: NotebookKind.event, value: 'Sinh nhật'),
            _entry(id: 'c', kind: NotebookKind.interest, value: 'Đi bộ'),
          ]);

      expect(
        grouped[NotebookKind.interest]!.map((NotebookEntry e) => e.id),
        <String>['a', 'c'],
      );
      expect(
        grouped[NotebookKind.event]!.map((NotebookEntry e) => e.id),
        <String>['b'],
      );
    });

    test('the group order is exactly the two fixed groups', () {
      expect(notebookGroupOrder, <NotebookKind>[
        NotebookKind.interest,
        NotebookKind.event,
      ]);
    });
  });

  group('trạng thái rỗng trung tính (AC-8)', () {
    testWidgets('empty renders both headers and both "+ tự thêm", nothing else', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      expect(find.text('Sổ tay người yêu'), findsOneWidget);
      expect(find.text('Sở thích'), findsOneWidget);
      expect(find.text('Sự kiện'), findsOneWidget);
      expect(find.text('+ tự thêm'), findsNWidgets(2));

      // Neutral means neutral: no inviting subtitle, no urging banner, and no
      // input box waiting for the user before they asked for one.
      expect(find.byType(TextField), findsNothing);
      expectNoBannedSurfaces();
    });

    testWidgets('there are exactly two group headers, never a third', (
      WidgetTester tester,
    ) async {
      await repository.addEntry(
        kind: NotebookKind.interest,
        value: 'Trà sữa ít đường',
        detail: 'Ghi chú nằm trong chính mục này',
        source: ContextEntrySource.manual,
      );
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      // The note rendered under the entry, not as a group of its own (AC-6).
      expect(find.text('Ghi chú nằm trong chính mục này'), findsOneWidget);
      expect(find.byKey(const Key('notebook-group-interest')), findsOneWidget);
      expect(find.byKey(const Key('notebook-group-event')), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (Widget w) =>
              w is Column &&
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith('notebook-group-'),
        ),
        findsNWidgets(2),
      );
    });
  });

  group('hàng và menu "..." (AC-9)', () {
    testWidgets('entries render inside their own group', (
      WidgetTester tester,
    ) async {
      await repository.addEntry(
        kind: NotebookKind.interest,
        value: 'Trà sữa ít đường',
        source: ContextEntrySource.manual,
      );
      await repository.addEntry(
        kind: NotebookKind.event,
        value: 'Sinh nhật',
        eventOn: '2026-11-02',
        source: ContextEntrySource.manual,
      );
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      expect(find.text('Trà sữa ít đường'), findsOneWidget);
      expect(find.text('Sinh nhật'), findsOneWidget);
      expectNoBannedSurfaces();
    });

    testWidgets('the "..." menu carries exactly Sửa and Xoá', (
      WidgetTester tester,
    ) async {
      final NotebookEntry saved = await repository.addEntry(
        kind: NotebookKind.interest,
        value: 'Trà sữa ít đường',
        source: ContextEntrySource.manual,
      );
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('notebook-entry-menu-${saved.id}')));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((Widget w) => w is PopupMenuItem),
        findsNWidgets(2),
        reason: 'exactly Sửa and Xoá — a third row here would be the share or '
            'export affordance AC-9 forbids',
      );
      expect(find.text('Sửa'), findsOneWidget);
      expect(find.text('Xoá'), findsOneWidget);
      expectNoBannedSurfaces();
    });

    testWidgets('Xoá removes the row immediately, with no confirmation step', (
      WidgetTester tester,
    ) async {
      final NotebookEntry saved = await repository.addEntry(
        kind: NotebookKind.interest,
        value: 'Trà sữa ít đường',
        source: ContextEntrySource.manual,
      );
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('notebook-entry-menu-${saved.id}')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xoá'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
      expect(find.text('Trà sữa ít đường'), findsNothing);
      expect(await repository.entries(), isEmpty);
    });

    testWidgets('Sửa edits in place and saves without a dialog', (
      WidgetTester tester,
    ) async {
      final NotebookEntry saved = await repository.addEntry(
        kind: NotebookKind.interest,
        value: 'Trà sữa ít đường',
        source: ContextEntrySource.manual,
      );
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('notebook-entry-menu-${saved.id}')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sửa'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byKey(const Key('context-inline-add-row')), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('context-inline-add-field')),
        'Trà sữa không đường',
      );
      await tester.tap(find.byKey(const Key('context-inline-add-save')));
      await tester.pumpAndSettle();

      expect((await repository.entries()).single.value, 'Trà sữa không đường');
      expect(find.text('Trà sữa không đường'), findsOneWidget);
    });
  });

  group('"+ tự thêm" mở hàng thêm tại chỗ (AC-7)', () {
    testWidgets('the add row carries a two-way segmented control in that row', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('notebook-add-interest')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('context-inline-add-row')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('context-inline-add-row')),
          matching: find.byKey(const Key('context-inline-add-segmented')),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('context-inline-add-option-interest')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('context-inline-add-option-event')),
        findsOneWidget,
      );
      // Two choices, not three: the note is a field inside the item, never a
      // third destination (AC-6).
      expect(
        find.descendant(
          of: find.byKey(const Key('context-inline-add-segmented')),
          matching: find.byType(InkWell),
        ),
        findsNWidgets(2),
      );
      // Never a pushed composer: the hub stays on screen underneath.
      expect(find.byType(NotebookScreen), findsOneWidget);
      expectNoBannedSurfaces();
    });

    testWidgets('typing and saving writes into the group that was tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('notebook-add-event')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('context-inline-add-field')),
        'Kỷ niệm quen nhau',
      );
      await tester.tap(find.byKey(const Key('context-inline-add-save')));
      await tester.pumpAndSettle();

      final NotebookEntry stored = (await repository.entries()).single;
      expect(stored.kind, NotebookKind.event);
      expect(stored.value, 'Kỷ niệm quen nhau');
      expect(stored.source, ContextEntrySource.manual);
      expect(find.text('Kỷ niệm quen nhau'), findsOneWidget);
    });

    testWidgets('the segmented control moves the new line to the other group', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('notebook-add-interest')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('context-inline-add-option-event')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('context-inline-add-field')),
        'Đám cưới bạn thân',
      );
      await tester.tap(find.byKey(const Key('context-inline-add-save')));
      await tester.pumpAndSettle();

      expect((await repository.entries()).single.kind, NotebookKind.event);
    });

    testWidgets('the note field is part of the item, not a separate group', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('notebook-add-interest')));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(const Key('context-inline-add-row')),
          matching: find.byKey(const Key('context-inline-add-detail-field')),
        ),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const Key('context-inline-add-field')),
        'Cà phê muối',
      );
      await tester.enterText(
        find.byKey(const Key('context-inline-add-detail-field')),
        'Quán gần nhà',
      );
      await tester.tap(find.byKey(const Key('context-inline-add-save')));
      await tester.pumpAndSettle();

      final NotebookEntry stored = (await repository.entries()).single;
      expect(stored.detail, 'Quán gần nhà');
      expect(stored.kind, NotebookKind.interest);
    });
  });
}
