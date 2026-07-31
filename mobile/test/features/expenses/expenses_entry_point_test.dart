import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';
import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/expenses/data/expense_category.dart';
import 'package:cupid_mobile/features/expenses/data/expense_models.dart';
import 'package:cupid_mobile/features/expenses/data/expenses_failure.dart';
import 'package:cupid_mobile/features/expenses/data/expenses_repository.dart';
import 'package:cupid_mobile/features/expenses/data/pairing_state_reader.dart';
import 'package:cupid_mobile/features/expenses/expenses_route.dart';
import 'package:cupid_mobile/features/expenses/presentation/screens/expense_history_screen.dart';
import 'package:cupid_mobile/features/expenses/presentation/widgets/pairing_required_gate.dart';
import 'package:cupid_mobile/features/home/presentation/home_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hand-rolled fake — matches `expense_history_cubit_test.dart`'s
/// `_FakeExpensesRepository` convention (no mocking package). [throwsNotPaired]
/// simulates ADR-015.7's secondary corroborating signal: a 404 surfaced by a
/// wrapped repository call while the screen is already open.
class _FakeExpensesRepository implements ExpensesRepository {
  _FakeExpensesRepository({this.throwsNotPaired = false});

  final bool throwsNotPaired;

  @override
  Future<List<Expense>> fetchPage({int limit = 50, int offset = 0}) async {
    if (throwsNotPaired) throw const ExpensesNotPairedFailure();
    return const <Expense>[];
  }

  @override
  Future<Expense> create({
    required ExpenseCategory category,
    required num amountVnd,
    String? description,
    required DateTime date,
  }) => throw UnimplementedError('not used by ExpensesEntryPoint tests');
}

/// Dart implicit interfaces (`pairing_state_reader.dart`'s only public
/// member is `isPaired()`) let this stand in for a real `CouplePairingStore`
/// without any network/prefs setup.
class _FakePairingStateReader implements PairingStateReader {
  _FakePairingStateReader(this._value);

  final bool _value;

  @override
  Future<bool> isPaired() async => _value;
}

Widget _harness(Widget home) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    locale: const Locale('en'),
    home: home,
  );
}

void main() {
  group('ExpensesEntryPoint (ADR-015.7 AC4 gate)', () {
    testWidgets(
      'unpaired: shows PairingRequiredGate, never ExpenseHistoryScreen',
      (tester) async {
        await tester.pumpWidget(
          _harness(
            ExpensesEntryPoint(
              pairingStateReader: _FakePairingStateReader(false),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(PairingRequiredGate), findsOneWidget);
        expect(find.byType(ExpenseHistoryScreen), findsNothing);
      },
    );

    testWidgets('paired: shows ExpenseHistoryScreen, not the gate', (
      tester,
    ) async {
      final database = CupidDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      await tester.pumpWidget(
        _harness(
          ExpensesEntryPoint(
            pairingStateReader: _FakePairingStateReader(true),
            repository: _FakeExpensesRepository(),
            dao: database.expenseDao,
            backendUserIdStore: BackendUserIdStore(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ExpenseHistoryScreen), findsOneWidget);
      expect(find.byType(PairingRequiredGate), findsNothing);
    });

    testWidgets(
      'a mid-session ExpensesNotPairedFailure flips an already-open screen '
      'to the gate (ADR-015.7 secondary corroborating signal)',
      (tester) async {
        final database = CupidDatabase(NativeDatabase.memory());
        addTearDown(database.close);

        await tester.pumpWidget(
          _harness(
            ExpensesEntryPoint(
              pairingStateReader: _FakePairingStateReader(true),
              repository: _FakeExpensesRepository(throwsNotPaired: true),
              dao: database.expenseDao,
              backendUserIdStore: BackendUserIdStore(),
            ),
          ),
        );
        // ExpenseHistoryCubit's construction-time fetch surfaces the wrapped
        // repository's ExpensesNotPairedFailure before this first settle
        // returns, so the gate flip is already reflected by the time this
        // resolves -- an intermediate "still showing ExpenseHistoryScreen"
        // assertion would race the same microtask queue this drains.
        await tester.pumpAndSettle();

        expect(find.byType(PairingRequiredGate), findsOneWidget);
        expect(find.byType(ExpenseHistoryScreen), findsNothing);
      },
    );
  });

  group('HomeScreen expenses entry affordance (R-015.2)', () {
    setUp(() {
      getIt.registerLazySingleton<PairingStateReader>(
        () => _FakePairingStateReader(false),
      );
    });

    tearDown(() => getIt.reset());

    testWidgets(
      'the readiness signal keeps pumping and tapping the card navigates '
      'into ExpensesEntryPoint',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildCupidTheme(
              platform: CupidPlatform.material,
              brightness: Brightness.dark,
            ),
            localizationsDelegates: AppL10n.localizationsDelegates,
            supportedLocales: AppL10n.supportedLocales,
            // Skips CouplePairingStore/DreamJarRepository/etc. registration:
            // this test only exercises the expenses entry card, matching
            // `home_screen_test.dart`'s `resolvePairingStatus` override
            // precedent.
            home: HomeScreen(
              resolvePairingStatus: () async => PairingStatus.unknown,
            ),
          ),
        );

        expect(
          find.byKey(const Key('home_screen_ready_signal')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('home_expenses_entry_card')),
          findsOneWidget,
        );

        // The card sits below the fold in `SingleChildScrollView`'s default
        // test viewport once enough entry cards accumulate (`home_screen.dart`
        // doc comment), so it must be scrolled into view before it can be hit
        // tested.
        await tester.ensureVisible(
          find.byKey(const Key('home_expenses_entry_card')),
        );
        await tester.tap(find.byKey(const Key('home_expenses_entry_card')));
        await tester.pumpAndSettle();

        expect(find.byType(ExpensesEntryPoint), findsOneWidget);
        expect(find.byType(PairingRequiredGate), findsOneWidget);
      },
    );
  });
}
