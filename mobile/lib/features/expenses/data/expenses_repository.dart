import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:dio/dio.dart';

import 'expense_category.dart';
import 'expense_models.dart';
import 'expenses_failure.dart';

/// `architecture/solution.md` §2, ADR-015.1: Dio-direct — the generated
/// `Epic5ExpensesApi` methods return `Future<Response<void>>` and cannot
/// decode a body, so this repository calls `CupidApi.dio` by hand, following
/// the `AuthRepository` precedent (rethrow `DioException.error`, never the
/// raw exception).
class ExpensesRepository {
  ExpensesRepository({required this._api});

  final CupidApi _api;

  Future<List<Expense>> fetchPage({int limit = 50, int offset = 0}) async {
    try {
      final response = await _api.dio.get<Object?>(
        '/expenses',
        queryParameters: {'limit': '$limit', 'offset': '$offset'},
      );
      final rows = (response.data as List<Object?>).cast<Map<String, dynamic>>();
      return rows.map(Expense.fromJson).toList(growable: false);
    } on DioException catch (e) {
      throw _mapFailure(e);
    }
  }

  /// Sends the local calendar date at `T00:00:00.000Z` (R-015.6) and rejects
  /// a future date before the request is issued.
  Future<Expense> create({
    required ExpenseCategory category,
    required num amountVnd,
    String? description,
    required DateTime date,
  }) async {
    final calendarDate = DateTime(date.year, date.month, date.day);
    final today = DateTime.now();
    final todayCalendarDate = DateTime(today.year, today.month, today.day);
    if (calendarDate.isAfter(todayCalendarDate)) {
      throw const ExpensesFutureDateFailure();
    }
    try {
      final response = await _api.dio.post<Object?>(
        '/expenses',
        data: {
          'category': category.wireValue,
          'amount': amountVnd,
          'description': ?description,
          'date': _wireDate(calendarDate),
        },
      );
      return Expense.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapFailure(e);
    }
  }

  Object _mapFailure(DioException e) {
    final failure = e.error;
    if (failure is HttpStatusFailure && failure.statusCode == 404) {
      return const ExpensesNotPairedFailure();
    }
    return failure ?? const UnexpectedFailure();
  }

  String _wireDate(DateTime calendarDate) {
    String pad2(int n) => n.toString().padLeft(2, '0');
    return '${calendarDate.year}-${pad2(calendarDate.month)}-'
        '${pad2(calendarDate.day)}T00:00:00.000Z';
  }
}
