import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' show Tristate;

import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/database/daos/expense_dao.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/expenses/data/expenses_repository.dart';
import 'package:cupid_mobile/features/expenses/presentation/widgets/add_expense_sheet.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mirrors `create_memory_sheet_test.dart`'s transport fake: a real
/// [ExpensesRepository] over a real in-memory Drift database, with the
/// [Dio] transport swapped for a handler-driven fake so no live network
/// call is made and no mocking package is a dependency of this repo.
class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => _handler(options);
}

ResponseBody _jsonResponse(Object? body, int statusCode) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

ExpensesRepository _repositoryWithHandler(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final api = CupidApiClient.create();
  api.dio.httpClientAdapter = _FakeHttpClientAdapter(handler);
  return ExpensesRepository(api: api);
}

bool _online() => false;

Object? _successJson({
  String id = 'e2',
  String category = 'food',
  num amount = 250000,
  String description = 'Bún chả',
  String date = '2026-07-29',
}) => {
  'id': id,
  'coupleId': 'c1',
  'userId': 'u1',
  'category': category,
  'amount': amount,
  'description': description,
  'date': date,
  'createdAt': '2026-07-29T09:12:44.101Z',
};

/// A harness exposing a self-contained trigger affordance, mirroring
/// `create_memory_sheet_test.dart`'s harness -- isolates the sheet itself
/// so these tests don't depend on `ExpenseHistoryScreen`/`CupidAddAction`
/// wiring.
Widget _harness({
  required ExpensesRepository repository,
  bool Function() isOffline = _online,
  VoidCallback? onSaved,
  FocusNode? triggerFocusNode,
}) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.light,
    ),
    locale: const Locale('en'),
    home: Builder(
      builder: (BuildContext context) {
        return Scaffold(
          body: Center(
            child: TextButton(
              focusNode: triggerFocusNode,
              onPressed: () => AddExpenseSheet.show(
                context,
                repository: repository,
                isOffline: isOffline,
                onSaved: onSaved ?? () {},
              ),
              child: const Text('Open'),
            ),
          ),
        );
      },
    ),
  );
}

void main() {
  late CupidDatabase database;
  late ExpenseDao dao;

  setUp(() {
    database = CupidDatabase(NativeDatabase.memory());
    dao = database.expenseDao;
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> openSheet(
    WidgetTester tester,
    ExpensesRepository repository, {
    bool Function() isOffline = _online,
    VoidCallback? onSaved,
    FocusNode? triggerFocusNode,
  }) async {
    await tester.pumpWidget(
      _harness(
        repository: repository,
        isOffline: isOffline,
        onSaved: onSaved,
        triggerFocusNode: triggerFocusNode,
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  CupidPrimaryButton saveButton(WidgetTester tester) =>
      tester.widget<CupidPrimaryButton>(find.byType(CupidPrimaryButton));

  Future<void> fillValidFields(WidgetTester tester) async {
    await tester.enterText(
      find.byKey(const Key('addExpenseAmountField')),
      '250000',
    );
    await tester.enterText(
      find.byKey(const Key('addExpenseDescriptionField')),
      'Bún chả',
    );
    await tester.tap(find.text('Food'));
    await tester.pump();
  }

  /// The sheet's content can exceed the default test viewport height, so
  /// `SingleChildScrollView` must be scrolled before a widget below the
  /// fold can be hit-tested.
  Future<void> tapSave(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
  }

  testWidgets('the sheet is reachable and shows its fields', (
    WidgetTester tester,
  ) async {
    final ExpensesRepository repository = _repositoryWithHandler(
      (_) async => _jsonResponse(<Object?>[], 200),
    );

    await openSheet(tester, repository);

    expect(find.text('Log an expense'), findsOneWidget);
    expect(find.text('Amount (₫)'), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets(
    'Save is disabled until amount, description, and category are all set',
    (WidgetTester tester) async {
      final ExpensesRepository repository = _repositoryWithHandler(
        (_) async => _jsonResponse(<Object?>[], 200),
      );

      await openSheet(tester, repository);
      expect(saveButton(tester).onPressed, isNull);

      await tester.enterText(
        find.byKey(const Key('addExpenseAmountField')),
        '250000',
      );
      await tester.pump();
      expect(saveButton(tester).onPressed, isNull);

      await tester.enterText(
        find.byKey(const Key('addExpenseDescriptionField')),
        'Bún chả',
      );
      await tester.pump();
      expect(saveButton(tester).onPressed, isNull);

      await tester.tap(find.text('Food'));
      await tester.pump();
      expect(saveButton(tester).onPressed, isNotNull);
    },
  );

  testWidgets('an offline banner is shown non-blockingly when offline', (
    WidgetTester tester,
  ) async {
    final ExpensesRepository repository = _repositoryWithHandler(
      (_) async => _jsonResponse(<Object?>[], 200),
    );

    await openSheet(tester, repository, isOffline: () => true);

    expect(find.text('Saving requires a connection'), findsOneWidget);
  });

  testWidgets('no offline banner is shown while online', (
    WidgetTester tester,
  ) async {
    final ExpensesRepository repository = _repositoryWithHandler(
      (_) async => _jsonResponse(<Object?>[], 200),
    );

    await openSheet(tester, repository, isOffline: () => false);

    expect(find.text('Saving requires a connection'), findsNothing);
  });

  testWidgets(
    'Save is gated only on field validity, never on offline status -- the '
    'sheet is not disabled while offline (`ux/uiux-spec.md` §5)',
    (WidgetTester tester) async {
      final ExpensesRepository repository = _repositoryWithHandler(
        (_) async => _jsonResponse(<Object?>[], 200),
      );

      await openSheet(tester, repository, isOffline: () => true);
      await fillValidFields(tester);

      expect(saveButton(tester).onPressed, isNotNull);
    },
  );

  testWidgets(
    'a failed offline submit keeps the entered data, shows inline retry '
    'copy, and writes no Drift row (ADR-007 bound (b))',
    (WidgetTester tester) async {
      final ExpensesRepository repository = _repositoryWithHandler((
        options,
      ) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      });

      await openSheet(tester, repository, isOffline: () => true);
      await fillValidFields(tester);

      await tapSave(tester);
      await tester.pumpAndSettle();

      expect(find.text('No connection — try again'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('250000'), findsOneWidget);
      expect(find.text('Bún chả'), findsOneWidget);
      expect(await dao.countAll(), 0);
    },
  );

  testWidgets('a 404 shows the pairing-required message with data intact', (
    WidgetTester tester,
  ) async {
    final ExpensesRepository repository = _repositoryWithHandler(
      (options) async =>
          _jsonResponse({'message': 'User not found or not paired'}, 404),
    );

    await openSheet(tester, repository);
    await fillValidFields(tester);

    await tapSave(tester);
    await tester.pumpAndSettle();

    expect(
      find.text('This feature is only available to paired couples'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
    expect(await dao.countAll(), 0);
  });

  testWidgets('the "Paid by" row is non-interactive (ADR-015.2)', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    final ExpensesRepository repository = _repositoryWithHandler(
      (_) async => _jsonResponse(<Object?>[], 200),
    );

    await openSheet(tester, repository);

    final Finder paidByRow = find.bySemanticsLabel('Paid by: You');
    expect(paidByRow, findsOneWidget);
    final SemanticsNode node = tester.getSemantics(paidByRow);
    expect(node.flagsCollection.isButton, isFalse);
    expect(node.flagsCollection.isToggled, isNot(Tristate.isTrue));
    handle.dispose();
  });

  testWidgets(
    'the date field defaults to today and the calendar cannot navigate to '
    'a future month',
    (WidgetTester tester) async {
      final ExpensesRepository repository = _repositoryWithHandler(
        (_) async => _jsonResponse(<Object?>[], 200),
      );

      await openSheet(tester, repository);
      await tester.ensureVisible(find.byKey(const Key('addExpenseDateField')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('addExpenseDateField')));
      await tester.pumpAndSettle();

      // Flutter's Material calendar picker removes the tooltip entirely
      // (rather than keeping a disabled-but-labelled button) once the
      // displayed month reaches `lastDate`'s month, so this identifies the
      // "next month" control by its disabled state instead of by tooltip.
      expect(find.byTooltip('Previous month'), findsOneWidget);
      final Finder disabledNav = find.byWidgetPredicate(
        (Widget widget) => widget is IconButton && widget.onPressed == null,
      );
      expect(disabledNav, findsOneWidget);
    },
  );

  testWidgets(
    'focus returns to the trigger affordance after the sheet is dismissed',
    (WidgetTester tester) async {
      final ExpensesRepository repository = _repositoryWithHandler(
        (_) async => _jsonResponse(<Object?>[], 200),
      );
      final FocusNode triggerFocusNode = FocusNode();
      addTearDown(triggerFocusNode.dispose);

      await tester.pumpWidget(
        _harness(repository: repository, triggerFocusNode: triggerFocusNode),
      );
      triggerFocusNode.requestFocus();
      await tester.pump();
      expect(triggerFocusNode.hasFocus, isTrue);

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(triggerFocusNode.hasFocus, isFalse);

      // Dismiss by tapping the modal barrier, the same way a real user
      // taps outside the sheet (`showModalBottomSheet`'s default
      // `isDismissible: true`) -- not a programmatic Navigator.pop.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.byType(AddExpenseSheet), findsNothing);
      expect(triggerFocusNode.hasFocus, isTrue);
    },
  );

  testWidgets(
    'a successful submit sends exactly the four contract fields and pops '
    'the sheet',
    (WidgetTester tester) async {
      Map<String, dynamic>? sentBody;
      final ExpensesRepository repository = _repositoryWithHandler((
        options,
      ) async {
        sentBody = options.data as Map<String, dynamic>;
        return _jsonResponse(_successJson(), 201);
      });

      bool saved = false;
      await openSheet(tester, repository, onSaved: () => saved = true);
      await fillValidFields(tester);

      await tapSave(tester);
      await tester.pumpAndSettle();

      expect(saved, isTrue);
      expect(find.byType(AddExpenseSheet), findsNothing);
      expect(sentBody!.keys.toSet(), <String>{
        'category',
        'amount',
        'description',
        'date',
      });
      expect(await dao.countAll(), 0);
    },
  );
}
