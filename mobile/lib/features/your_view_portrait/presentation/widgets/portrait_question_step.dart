import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../../../l10n/generated/app_l10n.dart';
import '../../domain/portrait_content.dart';

/// One question, on its own, with an equally reachable way out.
///
/// Every word the user reads as content — the prompt and the options — arrives
/// from the pack through [question]; this widget contributes chrome only.
class PortraitQuestionStep extends StatefulWidget {
  const PortraitQuestionStep({
    super.key,
    required this.question,
    required this.position,
    required this.total,
    required this.onAnswer,
    required this.onSkip,
  });

  final PortraitQuestion question;
  final int position;
  final int total;
  final void Function({required String value, String? optionId}) onAnswer;
  final VoidCallback onSkip;

  @override
  State<PortraitQuestionStep> createState() => _PortraitQuestionStepState();
}

class _PortraitQuestionStepState extends State<PortraitQuestionStep> {
  final TextEditingController _freeText = TextEditingController();
  String? _selectedChip;

  @override
  void didUpdateWidget(covariant PortraitQuestionStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _freeText.clear();
      _selectedChip = null;
    }
  }

  @override
  void dispose() {
    _freeText.dispose();
    super.dispose();
  }

  String get _value {
    final String typed = _freeText.text.trim();
    return typed.isNotEmpty ? typed : (_selectedChip ?? '');
  }

  void _submit() {
    final String value = _value;
    if (value.isEmpty) {
      return;
    }
    widget.onAnswer(
      value: value,
      optionId: value == _selectedChip ? _selectedChip : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platform = context.cupidPlatform;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: CupidSpacing.md,
              vertical: CupidSpacing.md,
            ),
            child: Container(
              padding: const EdgeInsets.all(CupidSpacing.md),
              decoration: BoxDecoration(
                color: colors.colorSurface,
                borderRadius: BorderRadius.circular(platform.radiusCard),
                border: Border.all(color: colors.colorLine),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.portrait_question_position(
                      widget.position,
                      widget.total,
                    ),
                    key: const Key('portrait-question-position'),
                    style: type.caption.copyWith(color: colors.colorTextMuted),
                  ),
                  const SizedBox(height: CupidSpacing.sm),
                  Text(
                    widget.question.prompt,
                    key: const Key('portrait-question-prompt'),
                    style: type.cardTitle.copyWith(color: colors.colorText),
                  ),
                  const SizedBox(height: CupidSpacing.md),
                  for (final String chip in widget.question.chips)
                    Padding(
                      padding: const EdgeInsets.only(bottom: CupidSpacing.sm),
                      child: _ChipRow(
                        label: chip,
                        selected: _selectedChip == chip,
                        onTap: () => setState(
                          () => _selectedChip = _selectedChip == chip
                              ? null
                              : chip,
                        ),
                      ),
                    ),
                  if (widget.question.allowFreeText) ...<Widget>[
                    const SizedBox(height: CupidSpacing.xs),
                    TextField(
                      key: const Key('portrait-free-text'),
                      controller: _freeText,
                      style: type.body.copyWith(color: colors.colorText),
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: l10n.portrait_free_text_hint,
                        hintStyle: type.body.copyWith(
                          color: colors.colorTextMuted,
                        ),
                        filled: true,
                        fillColor: colors.colorSurfaceAlt,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            platform.radiusSmall,
                          ),
                          borderSide: BorderSide(color: colors.colorLine),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            CupidSpacing.md,
            0,
            CupidSpacing.md,
            CupidSpacing.md,
          ),
          child: Row(
            children: <Widget>[
              TextButton(
                key: const Key('portrait-skip'),
                onPressed: widget.onSkip,
                child: Text(
                  l10n.portrait_skip_action,
                  style: type.body.copyWith(color: colors.colorTextMuted),
                ),
              ),
              const SizedBox(width: CupidSpacing.sm),
              Expanded(
                child: CupidPrimaryButton(
                  key: const Key('portrait-next'),
                  label: l10n.portrait_next_action,
                  onPressed: _value.isEmpty ? null : _submit,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platform = context.cupidPlatform;

    return InkWell(
      key: Key('portrait-chip-$label'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(platform.radiusSmall),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: platform.tapTarget),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(
          horizontal: CupidSpacing.md,
          vertical: CupidSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? colors.colorSurfaceAlt : colors.colorBackground,
          borderRadius: BorderRadius.circular(platform.radiusSmall),
          border: Border.all(
            color: selected ? colors.colorAccentPink : colors.colorLine,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: type.body.copyWith(color: colors.colorText),
        ),
      ),
    );
  }
}
