import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../design_system/design_system.dart';
import '../../data/expense_category.dart';
import '../../data/expenses_repository.dart';
import '../add_expense_cubit.dart';
import '../expense_strings.dart';

final DateFormat _dateFormat = DateFormat.yMMMd();

/// Add-Expense bottom sheet (AC1,
/// `coding-plan/phase-P4-add-expense-sheet.md`). Not disabled while
/// offline -- connectivity can change mid-form (`ux/uiux-spec.md` §5) -- so
/// [isOffline] only drives an informational banner, never the Save
/// button's enabled state and never [AddExpenseCubit] itself.
class AddExpenseSheet extends StatelessWidget {
  const AddExpenseSheet({
    super.key,
    required this.repository,
    required this.isOffline,
    required this.onSaved,
  });

  final ExpensesRepository repository;
  final bool Function() isOffline;

  /// Invoked once, after the sheet pops on success, so the caller can run
  /// P3's `ExpenseHistoryCubit.refresh()` without this file importing that
  /// cubit directly.
  final VoidCallback onSaved;

  /// Opens the sheet from the history screen's `CupidAddAction`.
  static Future<void> show(
    BuildContext context, {
    required ExpensesRepository repository,
    required bool Function() isOffline,
    required VoidCallback onSaved,
  }) {
    final double radiusSheet = context.cupidPlatform.radiusSheet;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusSheet)),
      ),
      builder: (BuildContext _) => AddExpenseSheet(
        repository: repository,
        isOffline: isOffline,
        onSaved: onSaved,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AddExpenseCubit>(
      create: (_) => AddExpenseCubit(repository),
      child: _AddExpenseSheetBody(isOffline: isOffline, onSaved: onSaved),
    );
  }
}

class _AddExpenseSheetBody extends StatefulWidget {
  const _AddExpenseSheetBody({required this.isOffline, required this.onSaved});

  final bool Function() isOffline;
  final VoidCallback onSaved;

  @override
  State<_AddExpenseSheetBody> createState() => _AddExpenseSheetBodyState();
}

class _AddExpenseSheetBodyState extends State<_AddExpenseSheetBody> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  ExpenseCategory? _category;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    _amountController
      ..removeListener(_onFieldChanged)
      ..dispose();
    _descriptionController
      ..removeListener(_onFieldChanged)
      ..dispose();
    super.dispose();
  }

  num? get _amountVnd => num.tryParse(_amountController.text.trim());

  bool get _fieldsValid {
    final num? amount = _amountVnd;
    return amount != null &&
        amount > 0 &&
        _descriptionController.text.trim().isNotEmpty &&
        _category != null;
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(now) ? now : _date,
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    final num? amount = _amountVnd;
    final ExpenseCategory? category = _category;
    if (amount == null || category == null) return;
    final String description = _descriptionController.text.trim();
    context.read<AddExpenseCubit>().submit(
      AddExpenseDraft(
        category: category,
        amountVnd: amount,
        description: description.isEmpty ? null : description,
        date: _date,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return BlocConsumer<AddExpenseCubit, AddExpenseState>(
      listener: (BuildContext context, AddExpenseState state) {
        // Dismiss on success only; every failure state must leave the
        // sheet open with the user's entered data intact (`ux/uiux-spec.md`
        // §5, ADR-007).
        if (state is AddExpenseSuccess) {
          widget.onSaved();
          Navigator.of(context).pop();
        }
      },
      builder: (BuildContext context, AddExpenseState state) {
        final bool proactivelyOffline = widget.isOffline();
        final bool isSubmitting = state is AddExpenseSubmitting;
        final bool isFailure =
            state is AddExpenseFailedOffline ||
            state is AddExpensePairingRequired ||
            state is AddExpenseFutureDate ||
            state is AddExpenseFailed;
        final String? inlineMessage = switch (state) {
          AddExpenseFailedOffline() => ExpenseStrings.addSaveFailedOffline(
            context,
          ),
          AddExpensePairingRequired() =>
            ExpenseStrings.addSaveFailedPairingRequired(context),
          AddExpenseFutureDate() => ExpenseStrings.addSaveFailedGeneric(
            context,
          ),
          AddExpenseFailed() => ExpenseStrings.addSaveFailedGeneric(context),
          _ => null,
        };

        return Padding(
          padding: EdgeInsets.only(
            left: CupidSpacing.lg,
            right: CupidSpacing.lg,
            top: CupidSpacing.md,
            bottom: MediaQuery.of(context).viewInsets.bottom + CupidSpacing.lg,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  ExpenseStrings.addSheetTitle(context),
                  style: type.cardTitle.copyWith(color: colors.colorText),
                ),
                SizedBox(height: CupidSpacing.sm),
                if (proactivelyOffline) ...<Widget>[
                  _OfflineBanner(colors: colors, type: type),
                  SizedBox(height: CupidSpacing.sm),
                ],
                TextField(
                  key: const Key('addExpenseAmountField'),
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    labelText: ExpenseStrings.addFieldAmountLabel(context),
                  ),
                ),
                SizedBox(height: CupidSpacing.sm),
                TextField(
                  key: const Key('addExpenseDescriptionField'),
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: ExpenseStrings.addFieldDescriptionLabel(
                      context,
                    ),
                  ),
                ),
                SizedBox(height: CupidSpacing.sm),
                Text(
                  ExpenseStrings.addFieldCategoryLabel(context),
                  style: type.caption.copyWith(color: colors.colorTextMuted),
                ),
                SizedBox(height: CupidSpacing.xs),
                Wrap(
                  spacing: CupidSpacing.xs,
                  runSpacing: CupidSpacing.xs,
                  children: <Widget>[
                    for (final ExpenseCategory category
                        in ExpenseCategory.values)
                      _ExpenseCategoryChip(
                        label: ExpenseStrings.category(context, category),
                        isSelected: _category == category,
                        onTap: () => setState(() => _category = category),
                      ),
                  ],
                ),
                SizedBox(height: CupidSpacing.sm),
                _PaidByRow(colors: colors, type: type),
                SizedBox(height: CupidSpacing.sm),
                InkWell(
                  key: const Key('addExpenseDateField'),
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: ExpenseStrings.addFieldDateLabel(context),
                    ),
                    child: Text(
                      _dateFormat.format(_date),
                      style: type.body.copyWith(color: colors.colorText),
                    ),
                  ),
                ),
                if (inlineMessage != null) ...<Widget>[
                  SizedBox(height: CupidSpacing.sm),
                  Text(
                    inlineMessage,
                    style: type.caption.copyWith(color: colors.colorRed),
                  ),
                ],
                SizedBox(height: CupidSpacing.md),
                CupidPrimaryButton(
                  label: isFailure
                      ? ExpenseStrings.addRetryLabel(context)
                      : ExpenseStrings.addSaveLabel(context),
                  onPressed: (_fieldsValid && !isSubmitting) ? _submit : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.colors, required this.type});

  final CupidColorTokens colors;
  final CupidTypographyTokens type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: CupidSpacing.sm,
        vertical: CupidSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.colorSurfaceAlt,
        borderRadius: BorderRadius.circular(context.cupidPlatform.radiusSmall),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.cloud_off, size: 14, color: colors.colorTextMuted),
          SizedBox(width: CupidSpacing.xs),
          Expanded(
            child: Text(
              ExpenseStrings.addOfflineBanner(context),
              style: type.caption.copyWith(color: colors.colorTextMuted),
            ),
          ),
        ],
      ),
    );
  }
}

/// Non-interactive "Paid by" row (ADR-015.2). Deliberately not a toggle --
/// the server derives `userId` from the JWT and the contract has no
/// `paidBy` field, so this is a display-only attribution label. The
/// `Semantics` wrapper exposes no `button`/`toggled` trait, and
/// `ExcludeSemantics` on the child prevents the plain `Text` nodes from
/// leaking a redundant, separately-focusable reading.
class _PaidByRow extends StatelessWidget {
  const _PaidByRow({required this.colors, required this.type});

  final CupidColorTokens colors;
  final CupidTypographyTokens type;

  @override
  Widget build(BuildContext context) {
    final String label = ExpenseStrings.addPaidByLabel(context);
    final String value = ExpenseStrings.whoYou(context);
    return Semantics(
      label: '$label: $value',
      child: ExcludeSemantics(
        child: Row(
          children: <Widget>[
            Text(
              label,
              style: type.caption.copyWith(color: colors.colorTextMuted),
            ),
            const Spacer(),
            Text(value, style: type.body.copyWith(color: colors.colorText)),
          ],
        ),
      ),
    );
  }
}

/// Mirrors `expense_history_screen.dart`'s private `_CategoryChip` visual
/// style (`ux/uiux-spec.md` §3: "reusing the exact filter-chip visual style
/// from `expense` screen"). Not literally reused: that class is private to
/// its own file and this phase's write scope does not extend to extracting
/// it into a shared widget, so the same look is rebuilt here from the same
/// design tokens instead.
class _ExpenseCategoryChip extends StatelessWidget {
  const _ExpenseCategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: platformTokens.tapTarget),
        child: Material(
          color: isSelected ? colors.colorAccentPink : colors.colorSurfaceAlt,
          borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: CupidSpacing.sm,
                vertical: CupidSpacing.xs,
              ),
              child: Center(
                child: Text(
                  label,
                  style: type.caption.copyWith(
                    color: isSelected
                        ? colors.colorBackground
                        : colors.colorText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
