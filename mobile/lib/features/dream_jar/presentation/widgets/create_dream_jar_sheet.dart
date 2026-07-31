import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/generated/app_l10n.dart';
import '../../data/dream_jar_amount_format.dart';
import '../../data/dream_jar_repository.dart';
import '../create_dream_jar_cubit.dart';

/// STORY-014 P3 create-jar bottom sheet (`ux/uiux-spec.md` §1.3). Pops
/// `true` once a jar was created so the caller can refresh the list; pops
/// `false`/`null` on cancel/dismiss.
///
/// The optional deadline field uses Flutter's built-in `showDatePicker` on
/// both platforms rather than a platform-branched picker: only the four
/// widgets in `design_system/adaptive/` are allowed to branch on
/// `CupidPlatform` (ADR-004/D3), and adding a fifth adaptive widget is
/// outside this phase's write scope.
class CreateDreamJarSheet extends StatefulWidget {
  const CreateDreamJarSheet({super.key, required this.repository});

  final DreamJarRepository repository;

  @override
  State<CreateDreamJarSheet> createState() => _CreateDreamJarSheetState();
}

class _CreateDreamJarSheetState extends State<CreateDreamJarSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  DateTime? _deadline;

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  num? get _targetAmount {
    final String digits = _targetController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    return digits.isEmpty ? null : num.tryParse(digits);
  }

  Future<void> _pickDeadline(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 20),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final AppL10n l10n = AppL10n.of(context);

    return BlocProvider<CreateDreamJarCubit>(
      create: (_) => CreateDreamJarCubit(widget.repository),
      child: BlocConsumer<CreateDreamJarCubit, CreateDreamJarState>(
        listener: (context, state) {
          if (state is CreateDreamJarSuccess) {
            Navigator.of(context).pop(true);
          }
        },
        builder: (context, state) {
          final bool isSubmitting = state is CreateDreamJarSubmitting;
          final bool nameInvalid =
              state is CreateDreamJarValidationFailed && state.nameInvalid;
          final bool targetInvalid =
              state is CreateDreamJarValidationFailed &&
              state.targetAmountInvalid;

          return Padding(
            padding: EdgeInsets.only(
              left: CupidSpacing.lg,
              right: CupidSpacing.lg,
              top: CupidSpacing.lg,
              bottom:
                  MediaQuery.of(context).viewInsets.bottom + CupidSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.dream_jar_create_sheet_title,
                  style: type.cardTitle.copyWith(color: colors.colorText),
                ),
                SizedBox(height: CupidSpacing.lg),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.dream_jar_create_name_label,
                    hintText: l10n.dream_jar_create_name_hint,
                    errorText: nameInvalid
                        ? l10n.dream_jar_create_name_required
                        : null,
                  ),
                ),
                SizedBox(height: CupidSpacing.md),
                TextField(
                  controller: _targetController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    _ThousandsInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    labelText: l10n.dream_jar_create_target_label,
                    errorText: targetInvalid
                        ? l10n.dream_jar_create_target_invalid
                        : null,
                  ),
                ),
                SizedBox(height: CupidSpacing.md),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: platformTokens.tapTarget,
                  ),
                  child: InkWell(
                    onTap: () => _pickDeadline(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.dream_jar_create_deadline_label,
                      ),
                      child: Text(
                        _deadline == null
                            ? l10n.dream_jar_create_deadline_none
                            : DateFormat.yMd(
                                Localizations.localeOf(context).toString(),
                              ).format(_deadline!),
                        style: type.body.copyWith(color: colors.colorTextMuted),
                      ),
                    ),
                  ),
                ),
                if (state is CreateDreamJarFailed) ...[
                  SizedBox(height: CupidSpacing.sm),
                  Text(
                    l10n.dream_jar_create_error,
                    style: type.caption.copyWith(color: colors.colorRed),
                  ),
                ],
                SizedBox(height: CupidSpacing.lg),
                CupidPrimaryButton(
                  label: l10n.dream_jar_create_submit,
                  onPressed: isSubmitting
                      ? null
                      : () => context.read<CreateDreamJarCubit>().submit(
                          name: _nameController.text,
                          targetAmount: _targetAmount,
                          deadline: _deadline,
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// As-you-type VND grouping for the target-amount field
/// (`DreamJarAmountFormat.grouped`); non-digit characters are stripped
/// before formatting so pasted or partially-typed input never produces an
/// invalid intermediate value.
class _ThousandsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String grouped = DreamJarAmountFormat.grouped(newValue.text);
    return TextEditingValue(
      text: grouped,
      selection: TextSelection.collapsed(offset: grouped.length),
    );
  }
}
