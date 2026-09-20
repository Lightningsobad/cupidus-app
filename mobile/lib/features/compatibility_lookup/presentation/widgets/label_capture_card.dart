import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../../../l10n/generated/app_l10n.dart';
import '../../data/relationship_label_repository.dart';
import '../../domain/compat_content.dart';

/// Asks for one side of one label system, in place, on screen (10).
///
/// It deliberately copies the *shape* of the notebook's ask-on-the-spot slot —
/// one question, one row of chips, one card — and deliberately does not use
/// that widget. The notebook slot writes what it collects into the context
/// notebook; this one must not (BR-10, STORY-004's contract), so sharing the
/// class would mean sharing a store that this screen is forbidden to touch.
/// The resemblance is a UX promise, not a code dependency.
class LabelCaptureCard extends StatefulWidget {
  const LabelCaptureCard({
    super.key,
    required this.system,
    required this.subject,
    required this.values,
    required this.selected,
    required this.onSelect,
    required this.onClear,
  });

  final LabelSystem system;
  final LabelSubject subject;

  /// The axis values shipped by the pack, in pack order. The card renders
  /// exactly this list and knows no vocabulary of its own.
  final List<CompatAxisValue> values;

  /// The label already declared for this side, or null. When it is null no
  /// chip is selected and no value is suggested: an empty partner field must
  /// stay empty until the reader says something (AC-6).
  final RelationshipLabel? selected;

  final void Function(String valueId, LabelCertainty certainty) onSelect;
  final VoidCallback onClear;

  @override
  State<LabelCaptureCard> createState() => _LabelCaptureCardState();
}

class _LabelCaptureCardState extends State<LabelCaptureCard> {
  late bool _guessing = widget.selected?.certainty == LabelCertainty.guess;

  @override
  void didUpdateWidget(LabelCaptureCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final LabelCertainty? certainty = widget.selected?.certainty;
    if (certainty != null) {
      _guessing = certainty == LabelCertainty.guess;
    }
  }

  String get _slotId => '${widget.system.wireValue}_${widget.subject.wireValue}';

  LabelCertainty get _certainty =>
      _guessing ? LabelCertainty.guess : LabelCertainty.known;

  String _prompt(AppL10n l10n) => switch ((widget.system, widget.subject)) {
    (LabelSystem.zodiac, LabelSubject.self) => l10n.compat_label_prompt_zodiac_self,
    (LabelSystem.zodiac, LabelSubject.partner) =>
      l10n.compat_label_prompt_zodiac_partner,
    (LabelSystem.mbti, LabelSubject.self) => l10n.compat_label_prompt_mbti_self,
    (LabelSystem.mbti, LabelSubject.partner) =>
      l10n.compat_label_prompt_mbti_partner,
  };

  /// Re-declaring the same value with the other certainty is what the guess
  /// toggle does once a value exists, so flipping "mình chỉ đoán thôi" never
  /// costs the reader the value they already chose (AC-9).
  void _toggleGuess(bool value) {
    setState(() => _guessing = value);
    final RelationshipLabel? selected = widget.selected;
    if (selected != null) {
      widget.onSelect(
        selected.value,
        value ? LabelCertainty.guess : LabelCertainty.known,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final AppL10n l10n = AppL10n.of(context);
    final RelationshipLabel? selected = widget.selected;

    return Container(
      key: Key('compat_label_card_$_slotId'),
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
          Text(
            _prompt(l10n),
            style: type.body.copyWith(color: colors.colorText),
          ),
          const SizedBox(height: CupidSpacing.md),
          Wrap(
            spacing: CupidSpacing.sm,
            runSpacing: CupidSpacing.sm,
            children: <Widget>[
              for (final CompatAxisValue value in widget.values)
                _ValueChip(
                  key: Key('compat_label_chip_${_slotId}_${value.id}'),
                  label: value.label,
                  selected: selected?.value == value.id,
                  onTap: () => widget.onSelect(value.id, _certainty),
                ),
            ],
          ),
          const SizedBox(height: CupidSpacing.sm),
          Row(
            children: <Widget>[
              Semantics(
                checked: _guessing,
                child: Switch(
                  key: Key('compat_label_guess_toggle_$_slotId'),
                  value: _guessing,
                  onChanged: _toggleGuess,
                ),
              ),
              const SizedBox(width: CupidSpacing.xs),
              Expanded(
                child: Text(
                  l10n.compat_label_guess_toggle,
                  style: type.caption.copyWith(color: colors.colorTextMuted),
                ),
              ),
            ],
          ),
          if (selected != null) ...<Widget>[
            if (selected.certainty == LabelCertainty.guess)
              Padding(
                padding: const EdgeInsets.only(top: CupidSpacing.xs),
                child: _GuessMarker(key: Key('compat_label_guess_marker_$_slotId')),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: Semantics(
                button: true,
                child: GestureDetector(
                  key: Key('compat_label_clear_$_slotId'),
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onClear,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: CupidSpacing.xs,
                    ),
                    child: Text(
                      l10n.compat_label_clear_action,
                      style: type.caption.copyWith(color: colors.colorTextMuted),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ValueChip extends StatelessWidget {
  const _ValueChip({
    super.key,
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

    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? colors.colorSurfaceAlt : colors.colorSurface,
            borderRadius: BorderRadius.circular(platform.radiusSmall),
            border: Border.all(
              color: selected ? colors.colorText : colors.colorLine,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: CupidSpacing.sm,
              vertical: CupidSpacing.xs,
            ),
            child: Text(
              label,
              style: type.body.copyWith(color: colors.colorText),
            ),
          ),
        ),
      ),
    );
  }
}

/// The "bạn đang đoán" provenance marker, in STORY-009's style: a small line
/// icon and muted caption beside the value, never the bold treatment a
/// confirmed field gets (AC-8).
class _GuessMarker extends StatelessWidget {
  const _GuessMarker({super.key});

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final AppL10n l10n = AppL10n.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        CupidIcon(
          CupidIcons.help,
          variant: CupidIconVariant.line,
          size: CupidSpacing.md,
          color: colors.colorTextMuted,
        ),
        const SizedBox(width: CupidSpacing.xs),
        Text(
          l10n.compat_label_guess_marker,
          style: type.caption.copyWith(color: colors.colorTextMuted),
        ),
      ],
    );
  }
}
