import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_event_dto.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_repository.dart';
import 'package:cupid_mobile/features/timeline/presentation/create_entry_cubit.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;

/// `close` glyph codepoint, confirmed against the bundled
/// `MaterialSymbolsRounded-Variable.ttf` cmap via fontTools (0xe5cd ->
/// `close`). `TimelineGlyphs` (`widgets/timeline_entry_card.dart`) is out of
/// this phase's write scope, so this stays a locally-scoped constant rather
/// than a shared addition.
const IconData _closeGlyph = IconData(
  0xe5cd,
  fontFamily: 'Material Symbols Rounded',
);

/// Backend DTO field limits (`../story_master.md` AC1; `coding-plan/phase-P6-
/// create-memory-sheet.md` task 2), enforced client-side via `maxLength` so a
/// create cannot fail on a validation error the UI could have prevented.
const int _titleMaxLength = 100;
const int _descriptionMaxLength = 500;

/// Bottom sheet for AC1 (create a timeline entry). Text-only per
/// architecture D-012-7 -- no photo field, no `image_picker` dependency.
class CreateMemorySheet extends StatelessWidget {
  const CreateMemorySheet({
    super.key,
    required this.repository,
    required this.isOffline,
  });

  final TimelineRepository repository;

  /// Reads `TimelineCubit.isOffline` (P4) so Save can be gated proactively,
  /// in addition to the cubit's own fail-fast check.
  final bool Function() isOffline;

  /// Opens the sheet, e.g. from the P5 "Add a memory" affordance.
  static Future<void> show(
    BuildContext context, {
    required TimelineRepository repository,
    required bool Function() isOffline,
  }) {
    final double radiusSheet = context.cupidPlatform.radiusSheet;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusSheet)),
      ),
      builder: (BuildContext _) =>
          CreateMemorySheet(repository: repository, isOffline: isOffline),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateEntryCubit>(
      create: (_) => CreateEntryCubit(repository, isOffline: isOffline),
      child: _CreateMemorySheetBody(isOffline: isOffline),
    );
  }
}

class _CreateMemorySheetBody extends StatefulWidget {
  const _CreateMemorySheetBody({required this.isOffline});

  final bool Function() isOffline;

  @override
  State<_CreateMemorySheetBody> createState() =>
      _CreateMemorySheetBodyState();
}

class _CreateMemorySheetBodyState extends State<_CreateMemorySheetBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    if (widget.isOffline()) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final String description = _descriptionController.text.trim();
    context.read<CreateEntryCubit>().submit(
      TimelineDraft(
        title: _titleController.text.trim(),
        date: _date,
        description: description.isEmpty ? null : description,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return BlocConsumer<CreateEntryCubit, CreateEntryState>(
      listener: (BuildContext context, CreateEntryState state) {
        // Dismiss on success only; a failure/blocked state must never
        // auto-dismiss so the user's input and the inline copy stay visible.
        if (state is CreateEntrySuccess) {
          Navigator.of(context).pop();
        }
      },
      builder: (BuildContext context, CreateEntryState state) {
        final bool proactivelyOffline = widget.isOffline();
        final bool isSubmitting = state is CreateEntrySubmitting;
        final String? inlineMessage = switch (state) {
          CreateEntryBlockedOffline() => l10n.timeline_sheet_offline_blocked,
          CreateEntryPairingRequired() => l10n.timeline_sheet_pairing_required,
          CreateEntryFailed() => l10n.timeline_error_body,
          _ => proactivelyOffline ? l10n.timeline_sheet_offline_blocked : null,
        };

        return Padding(
          padding: EdgeInsets.only(
            left: CupidSpacing.lg,
            right: CupidSpacing.lg,
            top: CupidSpacing.md,
            bottom: MediaQuery.of(context).viewInsets.bottom + CupidSpacing.lg,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          l10n.timeline_sheet_title,
                          style: type.cardTitle.copyWith(
                            color: colors.colorText,
                          ),
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: l10n.timeline_sheet_cancel_label,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          constraints: BoxConstraints(
                            minWidth: platformTokens.tapTarget,
                            minHeight: platformTokens.tapTarget,
                          ),
                          icon: CupidIcon(
                            _closeGlyph,
                            size: 20,
                            color: colors.colorTextMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: CupidSpacing.sm),
                  TextFormField(
                    controller: _titleController,
                    maxLength: _titleMaxLength,
                    decoration: InputDecoration(
                      labelText: l10n.timeline_sheet_field_title_label,
                    ),
                    validator: (String? value) =>
                        (value == null || value.trim().isEmpty)
                        ? l10n.timeline_sheet_validation_title_required
                        : null,
                  ),
                  SizedBox(height: CupidSpacing.sm),
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.timeline_sheet_field_date_label,
                      ),
                      child: Text(
                        _dateFormat.format(_date),
                        style: type.body.copyWith(color: colors.colorText),
                      ),
                    ),
                  ),
                  SizedBox(height: CupidSpacing.sm),
                  TextFormField(
                    controller: _descriptionController,
                    maxLength: _descriptionMaxLength,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: l10n.timeline_sheet_field_description_label,
                    ),
                  ),
                  if (inlineMessage != null) ...<Widget>[
                    SizedBox(height: CupidSpacing.sm),
                    Text(
                      inlineMessage,
                      style: type.caption.copyWith(
                        color: colors.colorTextMuted,
                      ),
                    ),
                  ],
                  SizedBox(height: CupidSpacing.md),
                  CupidPrimaryButton(
                    label: l10n.timeline_sheet_save_label,
                    onPressed: (isSubmitting || proactivelyOffline)
                        ? null
                        : _submit,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

final intl.DateFormat _dateFormat = intl.DateFormat.yMMMd();
