import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/features/expenses/data/expense_category.dart';
import 'package:cupid_mobile/features/expenses/data/expenses_failure.dart';
import 'package:cupid_mobile/features/expenses/data/expenses_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// A scripted [HttpClientAdapter] fake so these tests never touch the
/// network: no mocking package is a dependency of this repo, so this
/// follows the same seam Dio itself exposes for swapping the transport.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this._respond);

  final ResponseBody Function(RequestOptions options) _respond;
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

void main() {
  group('ExpensesRepository.fetchPage', () {
    test('sends string limit/offset query params and decodes rows', () async {
      final adapter = _ScriptedAdapter(
        (options) => _jsonBody([
          {
            'id': 'e1',
            'coupleId': 'c1',
            'userId': 'u1',
            'category': 'food',
            'amount': '250000.00',
            'description': 'Bún chả',
            'date': '2026-07-30',
            'createdAt': '2026-07-30T09:12:44.101Z',
          },
        ], 200),
      );
      final repository = _repositoryWith(adapter);

      final result = await repository.fetchPage(limit: 20, offset: 10);

      expect(adapter.lastRequest!.path, '/expenses');
      expect(
        adapter.lastRequest!.queryParameters,
        {'limit': '20', 'offset': '10'},
      );
      expect(result, hasLength(1));
      expect(result.single.amountVnd, 250000.0);
      expect(result.single.category, ExpenseCategory.food);
    });

    test('maps a 404 to ExpensesNotPairedFailure', () async {
      final adapter = _ScriptedAdapter(
        (options) =>
            _jsonBody({'message': 'User not found or not paired'}, 404),
      );
      final repository = _repositoryWith(adapter);

      await expectLater(
        repository.fetchPage(),
        throwsA(isA<ExpensesNotPairedFailure>()),
      );
    });
  });

  group('ExpensesRepository.create', () {
    test('sends exactly the four contract fields', () async {
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
      final repository = _repositoryWith(adapter);

      final created = await repository.create(
        category: ExpenseCategory.food,
        amountVnd: 250000,
        description: 'Bún chả',
        date: DateTime(2026, 7, 29),
      );

      final body = adapter.lastRequest!.data as Map<String, dynamic>;
      expect(
        body.keys,
        containsAll(['category', 'amount', 'description', 'date']),
      );
      expect(body.length, 4);
      expect(body['category'], 'food');
      expect(body['amount'], 250000);
      expect(body['date'], '2026-07-29T00:00:00.000Z');
      expect(created.id, 'e2');
    });

    test('omits description when absent, sending only three fields', () async {
      final adapter = _ScriptedAdapter(
        (options) => _jsonBody({
          'id': 'e3',
          'coupleId': 'c1',
          'userId': 'u1',
          'category': 'other',
          'amount': 5000,
          'description': null,
          'date': '2026-07-29',
          'createdAt': '2026-07-29T09:12:44.101Z',
        }, 201),
      );
      final repository = _repositoryWith(adapter);

      await repository.create(
        category: ExpenseCategory.other,
        amountVnd: 5000,
        date: DateTime(2026, 7, 29),
      );

      final body = adapter.lastRequest!.data as Map<String, dynamic>;
      expect(body.length, 3);
      expect(body.containsKey('description'), isFalse);
    });

    test('rejects a future date before any request is sent', () async {
      final adapter = _ScriptedAdapter((options) {
        fail('must not send a request for a future date');
      });
      final repository = _repositoryWith(adapter);

      await expectLater(
        repository.create(
          category: ExpenseCategory.food,
          amountVnd: 1000,
          date: DateTime.now().add(const Duration(days: 5)),
        ),
        throwsA(isA<ExpensesFutureDateFailure>()),
      );
    });

    test('maps a 404 to ExpensesNotPairedFailure', () async {
      final adapter = _ScriptedAdapter(
        (options) =>
            _jsonBody({'message': 'User not found or not paired'}, 404),
      );
      final repository = _repositoryWith(adapter);

      await expectLater(
        repository.create(
          category: ExpenseCategory.food,
          amountVnd: 1000,
          date: DateTime(2026, 1, 1),
        ),
        throwsA(isA<ExpensesNotPairedFailure>()),
      );
    });
  });
}
