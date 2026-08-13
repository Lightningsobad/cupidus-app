import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/expenses/data/expense_category.dart';
import 'package:cupid_mobile/features/expenses/data/expense_models.dart';
import 'package:cupid_mobile/features/expenses/data/expenses_repository.dart';
import 'package:cupid_mobile/features/expenses/presentation/screens/expense_history_screen.dart';
import 'package:cupid_mobile/features/expenses/presentation/widgets/expense_list_item.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hand-rolled fake — matches `expense_history_cubit_test.dart`'s convention
/// (no mocking package).
class _FakeExpensesRepository implements ExpensesRepository {
  _FakeExpensesRepository(this._rows);

  final List<Expense> _rows;

  @override
  Future<List<Expense>> fetchPage({int limit = 50, int offset = 0}) async {
    if (offset > 0) return const <Expense>[];
    return _rows;
  }

  @override
  Future<Expense> create({
    required ExpenseCategory category,
    required num amountVnd,
    String? description,
    required DateTime date,
  }) => throw UnimplementedError('not used by fidelity tests');
}

Expense _expense({
  required String id,
  required ExpenseCategory category,
  required num amountVnd,
  String? description,
  required int day,
}) {
  return Expense(
    id: id,
    userId: 'user-1',
    category: category,
    amountVnd: amountVnd,
    description: description,
    date: DateTime.utc(2026, 7, day),
    createdAt: DateTime.utc(2026, 7, day),
  );
}

Widget _harness(CupidPlatform platform, Widget child) {
  return CupidPlatformOverride(
    platform: platform,
    child: MaterialApp(
      theme: buildCupidTheme(platform: platform, brightness: Brightness.dark),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      locale: const Locale('vi'),
      home: child,
    ),
  );
}

void main() {
  late CupidDatabase database;

  final List<Expense> rows = <Expense>[
    _expense(
      id: 'e1',
      category: ExpenseCategory.food,
      amountVnd: 480000,
      description: 'Lẩu ở Nguyễn Huệ',
      day: 27,
    ),
    _expense(
      id: 'e2',
      category: ExpenseCategory.travel,
      amountVnd: 132000,
      day: 24,
    ),
  ];

  setUp(() {
    database = CupidDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  Future<void> pumpScreen(WidgetTester tester, CupidPlatform platform) async {
    await tester.pumpWidget(
      _harness(
        platform,
        ExpenseHistoryScreen(
          repository: _FakeExpensesRepository(rows),
          dao: database.expenseDao,
          backendUserIdStore: BackendUserIdStore(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('AC3 platform-adaptive add-expense action', () {
    testWidgets('Material anchors the FAB in the Scaffold FAB slot', (
      tester,
    ) async {
      await pumpScreen(tester, CupidPlatform.material);

      expect(find.byType(CupidAddAction), findsOneWidget);
      expect(find.byType(CupidPrimaryButton), findsNothing);

      final Scaffold scaffold = tester.widget<Scaffold>(
        find.byType(Scaffold).first,
      );
      expect(scaffold.floatingActionButton, isNotNull);

      // The header must not carry a second, separately-styled add affordance.
      final CupidHeader header = tester.widget<CupidHeader>(
        find.byType(CupidHeader),
      );
      expect(header.actions, isEmpty);
    });

    testWidgets('iOS renders a full-width CTA inside the content, no FAB', (
      tester,
    ) async {
      await pumpScreen(tester, CupidPlatform.ios);

      expect(find.byType(CupidPrimaryButton), findsOneWidget);
      expect(find.byType(CupidAddAction), findsNothing);

      final Scaffold scaffold = tester.widget<Scaffold>(
        find.byType(Scaffold).first,
      );
      expect(scaffold.floatingActionButton, isNull);

      expect(find.text('Ghi một khoản'), findsOneWidget);
    });
  });

  group('AC1 list-row fidelity', () {
    testWidgets('row title is the description, with a tinted icon tile', (
      tester,
    ) async {
      await pumpScreen(tester, CupidPlatform.material);

      expect(find.text('Lẩu ở Nguyễn Huệ'), findsOneWidget);

      final CupidColorTokens colors = const CupidColorTokens.dark();
      final Container tile = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(ExpenseListItem).first,
              matching: find.byType(Container),
            )
            .first,
      );
      final BoxDecoration decoration = tile.decoration! as BoxDecoration;
      expect(decoration.color, colors.colorAmber.withValues(alpha: 0.18));
    });

    testWidgets('every row but the last draws the hairline divider', (
      tester,
    ) async {
      await pumpScreen(tester, CupidPlatform.material);

      final List<ExpenseListItem> items = tester
          .widgetList<ExpenseListItem>(find.byType(ExpenseListItem))
          .toList();
      expect(items, hasLength(2));
      expect(items.first.showDivider, isTrue);
      expect(items.last.showDivider, isFalse);
    });
  });
}
