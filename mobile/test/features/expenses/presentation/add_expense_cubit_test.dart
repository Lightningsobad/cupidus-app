import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/database/daos/expense_dao.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/features/expenses/data/expense_category.dart';
import 'package:cupid_mobile/features/expenses/data/expenses_repository.dart';
import 'package:cupid_mobile/features/expenses/presentation/add_expense_cubit.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// No mocking package is a dependency of this repo: this scripts Dio's own
/// `HttpClientAdapter` seam, mirroring
/// `expenses_repository_test.dart`/`create_entry_cubit_test.dart`. The
/// handler may either return a [ResponseBody] or throw a [DioException]
/// directly, covering both HTTP-status and transport-level failures with
/// one class.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this._respond);

  final FutureOr<ResponseBody> Function(RequestOptions options) _respond;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return _respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonBody(Object? body, int statusCode) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

ExpensesRepository _repositoryWith(_ScriptedAdapter adapter) {
  final api = CupidApiClient.create();
  api.dio.httpClientAdapter = adapter;
  return ExpensesRepository(api: api);
}

AddExpenseDraft _draft({DateTime? date}) => AddExpenseDraft(
  category: ExpenseCategory.food,
  amountVnd: 250000,
  description: 'Bún chả',
  date: date ?? DateTime(2026, 7, 29),
);

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

  test(
    'submit succeeds: emits submitting then success, sends exactly the '
    'four contract fields, and never writes an ExpenseDao row itself',
    () async {
      final adapter = _ScriptedAdapter(
        (options) => _jsonBody({
          'id': 'e2',
          'coupleId': 'c1',
          'userId': 'u1',
          'category': 'food',
          'amount': 250000,
          'description': 'Bún chả',
          'date': '2026-07-29',
          'createdAt': '2026-07-29T09:12:44.101Z',
        }, 201),
      );
      final cubit = AddExpenseCubit(_repositoryWith(adapter));
      addTearDown(cubit.close);

      final emitted = <AddExpenseState>[];
      final subscription = cubit.stream.listen(emitted.add);
      addTearDown(subscription.cancel);

      await cubit.submit(_draft());
      await pumpEventQueue();

      expect(emitted, <Matcher>[
        isA<AddExpenseSubmitting>(),
        isA<AddExpenseSuccess>(),
      ]);
      final body = adapter.lastRequest!.data as Map<String, dynamic>;
      expect(body.keys.toSet(), <String>{
        'category',
        'amount',
        'description',
        'date',
      });
      expect(body['category'], 'food');
      expect(body['amount'], 250000);
      expect(body['date'], '2026-07-29T00:00:00.000Z');
      expect(await dao.countAll(), 0);
    },
  );

  test(
    'a connection failure preserves the draft path, emits '
    'AddExpenseFailedOffline, and writes no ExpenseDao row -- never a '
    'spinner that persists, never an optimistic row (ADR-007 bound (b))',
    () async {
      final adapter = _ScriptedAdapter((options) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      });
      final cubit = AddExpenseCubit(_repositoryWith(adapter));
      addTearDown(cubit.close);

      final emitted = <AddExpenseState>[];
      final subscription = cubit.stream.listen(emitted.add);
      addTearDown(subscription.cancel);

      await cubit.submit(_draft());
      await pumpEventQueue();

      expect(emitted, <Matcher>[
        isA<AddExpenseSubmitting>(),
        isA<AddExpenseFailedOffline>(),
      ]);
      expect(await dao.countAll(), 0);
      expect(await database.select(database.expenses).get(), isEmpty);
    },
  );

  test('a timeout also maps to AddExpenseFailedOffline', () async {
    final adapter = _ScriptedAdapter((options) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionTimeout,
      );
    });
    final cubit = AddExpenseCubit(_repositoryWith(adapter));
    addTearDown(cubit.close);

    await cubit.submit(_draft());

    expect(cubit.state, isA<AddExpenseFailedOffline>());
    expect(await dao.countAll(), 0);
  });

  test('a 404 maps to AddExpensePairingRequired with no Drift write', () async {
    final adapter = _ScriptedAdapter(
      (options) => _jsonBody({'message': 'User not found or not paired'}, 404),
    );
    final cubit = AddExpenseCubit(_repositoryWith(adapter));
    addTearDown(cubit.close);

    await cubit.submit(_draft());

    expect(cubit.state, isA<AddExpensePairingRequired>());
    expect(await dao.countAll(), 0);
  });

  test(
    'a future date is rejected client-side before any request is sent, '
    'emitting AddExpenseFutureDate',
    () async {
      final adapter = _ScriptedAdapter((options) {
        fail('must not send a request for a future date');
      });
      final cubit = AddExpenseCubit(_repositoryWith(adapter));
      addTearDown(cubit.close);

      await cubit.submit(
        _draft(date: DateTime.now().add(const Duration(days: 5))),
      );

      expect(cubit.state, isA<AddExpenseFutureDate>());
      expect(await dao.countAll(), 0);
    },
  );

  test('an unexpected server error maps to AddExpenseFailed', () async {
    final adapter = _ScriptedAdapter(
      (options) => _jsonBody({'message': 'boom'}, 500),
    );
    final cubit = AddExpenseCubit(_repositoryWith(adapter));
    addTearDown(cubit.close);

    await cubit.submit(_draft());

    expect(cubit.state, isA<AddExpenseFailed>());
    expect(await dao.countAll(), 0);
  });

  test('a 401 rethrows rather than emitting a failed state', () async {
    final adapter = _ScriptedAdapter(
      (options) => _jsonBody({'message': 'Unauthorized'}, 401),
    );
    final cubit = AddExpenseCubit(_repositoryWith(adapter));
    addTearDown(cubit.close);

    await expectLater(
      cubit.submit(_draft()),
      throwsA(isA<UnauthorizedFailure>()),
    );
    expect(await dao.countAll(), 0);
  });

  test(
    'Retry is re-invoking submit with the same draft: a second attempt '
    'after a connectivity failure succeeds once connectivity returns, with '
    'exactly one write attempt reaching the network per call',
    () async {
      int attempt = 0;
      final adapter = _ScriptedAdapter((options) {
        attempt++;
        if (attempt == 1) {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
          );
        }
        return _jsonBody({
          'id': 'e2',
          'coupleId': 'c1',
          'userId': 'u1',
          'category': 'food',
          'amount': 250000,
          'description': 'Bún chả',
          'date': '2026-07-29',
          'createdAt': '2026-07-29T09:12:44.101Z',
        }, 201);
      });
      final cubit = AddExpenseCubit(_repositoryWith(adapter));
      addTearDown(cubit.close);

      final draft = _draft();
      await cubit.submit(draft);
      expect(cubit.state, isA<AddExpenseFailedOffline>());

      await cubit.submit(draft);
      expect(cubit.state, isA<AddExpenseSuccess>());
      expect(attempt, 2);
      expect(await dao.countAll(), 0);
    },
  );
}
