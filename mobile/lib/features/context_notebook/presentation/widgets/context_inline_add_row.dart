import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

/// One choice on the inline row's segmented control. The notebook passes two
/// (its two fixed groups); the skill screen passes none, because there is only
/// one place a skill can go.
@immutable
class ContextInlineAddOption {
  const ContextInlineAddOption({required this.id, required this.label});

  final String id;
  final String label;
}

/// What the user typed on the inline row.
@immutable
class ContextInlineAddResult {
  const ContextInlineAddResult({
    required this.value,
    this.detail,
    this.optionId,
  });

  final String value;

  /// The optional free-text note. It lives inside the item and nowhere else —
  /// a note is never a third group on the notebook (`ux/uiux-spec.md` Phần B).
  final String? detail;

  /// The selected [ContextInlineAddOption.id], or `null` when the host gave no
  /// options.
  final String? optionId;
}

/// The "+ tự thêm" row, expanded in place (`ux/uiux-spec.md` Phần B/C).
///
/// It is deliberately a row and not a sheet, dialog or pushed composer: the
/// user stays looking at the list they are adding to, so adding one line never
/// becomes a flow with its own screen, progress or confirmation step.
class ContextInlineAddRow extends StatefulWidget {
  const ContextInlineAddRow({
    super.key,
    required this.hintText,
    required this.saveLabel,
    required this.cancelLabel,
    required this.onSubmit,
    required this.onCancel,
    this.options = const <ContextInlineAddOption>[],
    this.selectedOptionId,
    this.initialValue = '',
    this.detailHintText,
    this.initialDetail,
  });

  final String hintText;
  final String saveLabel;
  final String cancelLabel;

  final Future<void> Function(ContextInlineAddResult result) onSubmit;
  final VoidCallback onCancel;

  /// Empty, or exactly the two groups the notebook offers.
  final List<ContextInlineAddOption> options;

  final String? selectedOptionId;

  final String initialValue;

  /// When non-null the row also carries the item's own note field.
  final String? detailHintText;

  final String? initialDetail;

  @override
  State<ContextInlineAddRow> createState() => _ContextInlineAddRowState();
}

class _ContextInlineAddRowState extends State<ContextInlineAddRow> {
  late final TextEditingController _value = TextEditingController(
    text: widget.initialValue,
  );
  late final TextEditingController _detail = TextEditingController(
    text: widget.initialDetail ?? '',
  );
  late String? _optionId =
      widget.selectedOptionId ??
      (widget.options.isEmpty ? null : widget.options.first.id);

  @override
  void dispose() {
    _value.dispose();
    _detail.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String typed = _value.text.trim();
    if (typed.isEmpty) {
      return;
    }
    final String note = _detail.text.trim();
    await widget.onSubmit(
      ContextInlineAddResult(
        value: typed,
        detail: note.isEmpty ? null : note,
        optionId: _optionId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platform = context.cupidPlatform;

    return Container(
      key: const Key('context-inline-add-row'),
      padding: const EdgeInsets.all(CupidSpacing.md),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platform.radiusCard),
        border: Border.all(color: colors.colorLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  key: const Key('context-inline-add-field'),
                  controller: _value,
                  autofocus: true,
                  style: type.body.copyWith(color: colors.colorText),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: widget.hintText,
                    hintStyle: type.body.copyWith(color: colors.colorTextMuted),
                  ),
                  onSubmitted: (String _) => _submit(),
                ),
              ),
              if (widget.options.isNotEmpty) ...<Widget>[
                const SizedBox(width: CupidSpacing.sm),
                ContextInlineSegmented(
                  options: widget.options,
                  selectedId: _optionId,
                  onChanged: (String id) => setState(() => _optionId = id),
                ),
              ],
            ],
          ),
          if (widget.detailHintText != null) ...<Widget>[
            const SizedBox(height: CupidSpacing.xs),
            TextField(
              key: const Key('context-inline-add-detail-field'),
              controller: _detail,
              style: type.caption.copyWith(color: colors.colorTextMuted),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: widget.detailHintText,
                hintStyle: type.caption.copyWith(color: colors.colorTextMuted),
              ),
              onSubmitted: (String _) => _submit(),
            ),
          ],
          const SizedBox(height: CupidSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                key: const Key('context-inline-add-cancel'),
                onPressed: widget.onCancel,
                child: Text(
                  widget.cancelLabel,
                  style: type.caption.copyWith(color: colors.colorTextMuted),
                ),
              ),
              TextButton(
                key: const Key('context-inline-add-save'),
                onPressed: _submit,
                child: Text(
                  widget.saveLabel,
                  style: type.caption.copyWith(color: colors.colorText),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The two-choice group picker that lives in the add row itself, so a user who
/// opened the row under the wrong header can move the line without cancelling.
///
/// Public because the 23h check-in screen asks the same "which group" question
/// about one typed line and must ask it with this control rather than a
/// look-alike of it (`ux/uiux-spec.md` Phần A.2). It already draws a `null`
/// [selectedId] as nothing selected, which is the state AC-3 needs there.
class ContextInlineSegmented extends StatelessWidget {
  const ContextInlineSegmented({
    super.key,
    required this.options,
    required this.selectedId,
    required this.onChanged,
  });

  final List<ContextInlineAddOption> options;
  final String? selectedId;
  final void Function(String id) onChanged;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platform = context.cupidPlatform;

    return Container(
      key: const Key('context-inline-add-segmented'),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: colors.colorSurfaceAlt,
        borderRadius: BorderRadius.circular(platform.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final ContextInlineAddOption option in options)
            InkWell(
              key: Key('context-inline-add-option-${option.id}'),
              borderRadius: BorderRadius.circular(platform.radiusSmall),
              onTap: () => onChanged(option.id),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: CupidSpacing.sm,
                  vertical: CupidSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: option.id == selectedId
                      ? colors.colorSurface
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(platform.radiusSmall),
                ),
                child: Text(
                  option.label,
                  style: type.caption.copyWith(
                    color: option.id == selectedId
                        ? colors.colorText
                        : colors.colorTextMuted,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
