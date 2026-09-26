import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../design_system/icons/cupid_icons.dart';
import '../../../../../design_system/theme/cupid_theme_context.dart';
import '../../../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../../../design_system/tokens/cupid_platform_tokens.dart';
import '../../../../../design_system/tokens/cupid_spacing.dart';
import '../../../../../design_system/tokens/cupid_typography_tokens.dart';
import '../../../domain/activity_card.dart';
import '../../../domain/activity_type.dart';
import '../../domain/next_plan_suggestion_service.dart';
import '../next_plan_cubit.dart';

/// Same file-local bilingual helper the rest of the block uses: `mobile/lib/l10n/`
/// is outside this story's write scope. Only chrome goes through here — every
/// suggestion's wording is read off the shipped pack (BR-15/BR-16).
String _text(BuildContext context, String vi, String en) =>
    Localizations.localeOf(context).languageCode == 'vi' ? vi : en;

/// Phần 3 — "chốt việc kế tiếp" (`ux/uiux-spec.md` mục 3).
///
/// Every row is the same width, the same height and the same decoration, so no
/// suggestion is presented as the recommended one, and the section sits at the
/// secondary-action tier: the card's "Ghi lại" keeps its gradient fill and stays
/// the one card-level CTA (AC-6, BR-1).
///
/// The section is only ever built with a non-empty [suggestions]; an empty pack
/// leaves the whole slot out of the widget tree rather than drawing a header
/// over nothing (AC-35).
class NextPlanSection extends StatelessWidget {
  const NextPlanSection({super.key, required this.suggestions});

  final List<NextPlanSuggestion> suggestions;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Column(
      key: const Key('next_plan_section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          _text(
            context,
            'HẸN NHAU LẦN TỚI · KHÔNG BẮT BUỘC',
            'NEXT TIME TOGETHER · OPTIONAL',
          ),
          style: type.caption.copyWith(
            color: colors.colorTextMuted,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
          ),
        ),
        for (final NextPlanSuggestion suggestion in suggestions)
          Padding(
            padding: const EdgeInsets.only(top: CupidSpacing.xs),
            child: _SuggestionChip(suggestion: suggestion),
          ),
      ],
    );
  }
}

/// One suggestion. Tapping it is the confirmation step — there is no dialog in
/// between (AC-20) — and skipping every chip costs nothing: no chip is marked
/// pending, and closing the block leaves no trace of the ones not taken
/// (AC-22/AC-23).
class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.suggestion});

  final NextPlanSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;
    final NextPlanCubit cubit = context.read<NextPlanCubit>();

    return Semantics(
      button: true,
      child: GestureDetector(
        key: Key('next_plan_chip_${suggestion.id}'),
        behavior: HitTestBehavior.opaque,
        onTap: () => unawaited(_accept(context, cubit)),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: CupidSpacing.sm),
          decoration: BoxDecoration(
            color: colors.colorSurface,
            border: Border.all(color: colors.colorLine),
            borderRadius: BorderRadius.circular(platform.radiusSmall),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                activityTypeIcon(suggestion.activityType),
                size: 20,
                color: colors.colorTextMuted,
              ),
              const SizedBox(width: CupidSpacing.sm),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      suggestion.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: type.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.colorText,
                      ),
                    ),
                    Text(
                      _countdown(context, cubit.today, suggestion.date),
                      style: type.caption.copyWith(color: colors.colorTextMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: CupidSpacing.sm),
              Icon(CupidIcons.add, size: 20, color: colors.colorAccentPink),
            ],
          ),
        ),
      ),
    );
  }

  /// Creates the card, then offers five seconds to take it back.
  ///
  /// The undo goes back through the repository's `deleteCard`, the same
  /// contract the card came in through, so the row and its cascade leave
  /// together and no orphan is left behind (`contract-summary.md` mục 4).
  Future<void> _accept(BuildContext context, NextPlanCubit cubit) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String added =
        _text(context, 'Đã thêm vào kho hoạt động', 'Added to your activities');
    final String undo = _text(context, 'Hoàn tác', 'Undo');

    final ActivityCard card = await cubit.accept(suggestion);

    messenger.showSnackBar(
      SnackBar(
        key: const Key('next_plan_undo_snackbar'),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.fixed,
        content: Text(added),
        action: SnackBarAction(
          label: undo,
          onPressed: () => unawaited(cubit.undo(card)),
        ),
      ),
    );
  }

  /// How far off the occasion is, read off the two civil dates. A date, not a
  /// score: nothing here counts what the user did or did not do (AC-25/AC-28).
  String _countdown(BuildContext context, String today, String date) {
    final int days = daysUntil(today: today, date: date);
    if (days <= 0) {
      return _text(context, 'hôm nay', 'today');
    }
    if (days == 1) {
      return _text(context, 'ngày mai', 'tomorrow');
    }
    return _text(context, 'còn $days ngày', 'in $days days');
  }
}
