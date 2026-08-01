import 'package:cupid_mobile/core/database/daos/expense_dao.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:flutter/material.dart';

import 'data/expense_category.dart';
import 'data/expense_models.dart';
import 'data/expenses_failure.dart';
import 'data/expenses_repository.dart';
import 'data/pairing_state_reader.dart';
import 'presentation/screens/expense_history_screen.dart';
import 'presentation/widgets/pairing_required_gate.dart';

/// Named route for the expenses feature (`coding-plan/phase-P5-...md` §3).
/// `home_screen.dart`'s entry affordance navigates here directly (no
/// `MaterialApp` routes table exists anywhere in this codebase); this
/// constant documents the stable route identity the eventual Money-tab
/// entry point (§1C) will target once the 5-tab shell lands.
const String expensesRoute = '/expenses';

/// AC4 gate + P3 screen composition root (ADR-015.7). Resolves pairing state
/// once per mount (mirrors `SplashScreen`/`HomeScreen`'s
/// `_TimelineEntryPointGate` seam pattern) and shows [PairingRequiredGate]
/// instead of [ExpenseHistoryScreen] when unpaired. Also wires the secondary
/// corroborating signal: an `ExpensesNotPairedFailure` surfaced by any
/// wrapped repository call while the screen is open flips this gate too, so
/// a stale cached "paired" state cannot leave the feature open.
class ExpensesEntryPoint extends StatefulWidget {
  const ExpensesEntryPoint({
    super.key,
    PairingStateReader? pairingStateReader,
    ExpensesRepository? repository,
    ExpenseDao? dao,
    BackendUserIdStore? backendUserIdStore,
  }) : _pairingStateReader = pairingStateReader, // ignore: prefer_initializing_formals
       // ignore: prefer_initializing_formals
       _repository = repository,
       // ignore: prefer_initializing_formals
       _dao = dao,
       // ignore: prefer_initializing_formals
       _backendUserIdStore = backendUserIdStore;

  final PairingStateReader? _pairingStateReader;
  final ExpensesRepository? _repository;
  final ExpenseDao? _dao;
  final BackendUserIdStore? _backendUserIdStore;

  @override
  State<ExpensesEntryPoint> createState() => _ExpensesEntryPointState();
}

class _ExpensesEntryPointState extends State<ExpensesEntryPoint> {
  late final PairingStateReader _pairingStateReader =
      widget._pairingStateReader ?? getIt<PairingStateReader>();
  late final ExpensesRepository _repository =
      widget._repository ?? getIt<ExpensesRepository>();
  late final ExpenseDao _dao = widget._dao ?? getIt<ExpenseDao>();
  late final BackendUserIdStore _backendUserIdStore =
      widget._backendUserIdStore ?? getIt<BackendUserIdStore>();
  late final _NotPairedWatchingRepository _watchingRepository =
      _NotPairedWatchingRepository(_repository, _flipToGate);
  late final Future<bool> _isPairedFuture = _pairingStateReader.isPaired();

  bool _flippedToGate = false;

  void _flipToGate() {
    if (!mounted || _flippedToGate) return;
    setState(() => _flippedToGate = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_flippedToGate) {
      return const PairingRequiredGate();
    }
    return FutureBuilder<bool>(
      future: _isPairedFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.data!) {
          return const PairingRequiredGate();
        }
        return ExpenseHistoryScreen(
          repository: _watchingRepository,
          dao: _dao,
          backendUserIdStore: _backendUserIdStore,
        );
      },
    );
  }
}

/// ADR-015.7's secondary corroborating signal: wraps [ExpensesRepository]
/// (implements rather than extends -- its `_api` field is private to
/// `data/expenses_repository.dart` and unreachable from this file) so any
/// call that surfaces [ExpensesNotPairedFailure] also notifies
/// [_ExpensesEntryPointState] to flip to the gate, then rethrows so
/// `ExpenseHistoryCubit`/`AddExpenseCubit` keep handling the failure exactly
/// as they already do.
class _NotPairedWatchingRepository implements ExpensesRepository {
  _NotPairedWatchingRepository(this._inner, this._onNotPaired);

  final ExpensesRepository _inner;
  final VoidCallback _onNotPaired;

  @override
  Future<List<Expense>> fetchPage({int limit = 50, int offset = 0}) async {
    try {
      return await _inner.fetchPage(limit: limit, offset: offset);
    } on ExpensesNotPairedFailure {
      _onNotPaired();
      rethrow;
    }
  }

  @override
  Future<Expense> create({
    required ExpenseCategory category,
    required num amountVnd,
    String? description,
    required DateTime date,
  }) async {
    try {
      return await _inner.create(
        category: category,
        amountVnd: amountVnd,
        description: description,
        date: date,
      );
    } on ExpensesNotPairedFailure {
      _onNotPaired();
      rethrow;
    }
  }
}
