import 'package:test/test.dart';
import 'package:cupid_api/cupid_api.dart';


/// tests for Epic5ExpensesApi
void main() {
  final instance = CupidApi().getEpic5ExpensesApi();

  group(Epic5ExpensesApi, () {
    // Log a new shared expense
    //
    //Future expensesControllerCreate(CreateExpenseDto createExpenseDto) async
    test('test expensesControllerCreate', () async {
      // TODO
    });

    // Get all expenses
    //
    //Future expensesControllerFindAll(String limit, String offset) async
    test('test expensesControllerFindAll', () async {
      // TODO
    });

    // Get expense summary report (week/month)
    //
    //Future expensesControllerGetReport(String period) async
    test('test expensesControllerGetReport', () async {
      // TODO
    });

    // Delete an expense log
    //
    //Future expensesControllerRemove(String id) async
    test('test expensesControllerRemove', () async {
      // TODO
    });

  });
}
