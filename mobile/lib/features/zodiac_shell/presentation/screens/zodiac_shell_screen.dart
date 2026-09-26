import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../design_system/design_system.dart';
import '../../../../l10n/generated/app_l10n.dart';
import '../../../activity_cards/domain/activity_card.dart';
import '../../domain/zodiac_shell_content.dart';
import '../cubit/zodiac_shell_cubit.dart';
import '../widgets/zodiac_result_surface.dart';

/// Screen (7), "Cung & trắc nghiệm".
///
/// Three surfaces behind one route: the picker, one question at a time, and the
/// result. They are stages of the same cubit rather than three routes, so
/// walking away mid-round is a single `backToPicker` that leaves no partial
/// answer and no count of the leaving (AC-3), and so the result can never be
/// reached without its three suggestions coming with it (AC-5).
class ZodiacShellScreen extends StatelessWidget {
  const ZodiacShellScreen({super.key, this.createCubit});

  /// Test seam. In the app this stays null: the cubit's own defaults read the
  /// shipped packs off the asset bundle, the rotation cursor off
  /// `SharedPreferences`, and the card hub off the service locator, so the
  /// shell needs no registration of its own.
  final ZodiacShellCubit Function()? createCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ZodiacShellCubit>(
      create: (_) => (createCubit?.call() ?? ZodiacShellCubit())..load(),
      child: const _ZodiacShellBody(),
    );
  }
}

class _ZodiacShellBody extends StatelessWidget {
  const _ZodiacShellBody();

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CupidHeader(
        title: l10n.zodiac_shell_screen_title,
        onBack: Navigator.of(context).canPop()
            ? () => Navigator.of(context).maybePop()
            : null,
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<ZodiacShellCubit, ZodiacShellState>(
          builder: (BuildContext context, ZodiacShellState state) {
            switch (state.stage) {
              // No spinner and no "đang tính" copy while the packs load: the
              // wait is an asset read, and staging it as deliberation is
              // exactly the fortune-teller theatre R-7 rules out.
              case ZodiacShellStage.loading:
                return const SizedBox.shrink();
              case ZodiacShellStage.picker:
                return _PickerList(sets: state.sets);
              case ZodiacShellStage.asking:
                return _QuestionView(question: state.question!);
              case ZodiacShellStage.result:
                return _ResultView(state: state);
            }
          },
        ),
      ),
    );
  }
}

/// Every set, always open. There is no "hôm nay mới mở khoá" section, no badge
/// and no count beside a title, because nothing in the state could fill one
/// (AC-18/AC-19).
class _PickerList extends StatelessWidget {
  const _PickerList({required this.sets});

  final List<ZodiacQuizSet> sets;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('zodiac_picker_list'),
      padding: const EdgeInsets.all(CupidSpacing.md),
      children: <Widget>[
        for (final ZodiacQuizSet set in sets)
          Padding(
            padding: const EdgeInsets.only(bottom: CupidSpacing.sm),
            child: _SetCard(set: set),
          ),
      ],
    );
  }
}

class _SetCard extends StatelessWidget {
  const _SetCard({required this.set});

  final ZodiacQuizSet set;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platform = context.cupidPlatform;

    return GestureDetector(
      key: Key('zodiac_set_card_${set.id}'),
      behavior: HitTestBehavior.opaque,
      onTap: () => context.read<ZodiacShellCubit>().startSet(set.id),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.colorSurface,
          borderRadius: BorderRadius.circular(platform.radiusSmall),
          border: Border.all(color: colors.colorLine),
        ),
        child: Padding(
          padding: const EdgeInsets.all(CupidSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CupidIcon(
                CupidIcons.autoAwesome,
                variant: CupidIconVariant.line,
                size: 20,
                color: colors.colorAccentPurple,
              ),
              const SizedBox(width: CupidSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      set.title,
                      style: type.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.colorText,
                      ),
                    ),
                    if (set.blurb.isNotEmpty) ...<Widget>[
                      const SizedBox(height: CupidSpacing.xs),
                      Text(
                        set.blurb,
                        style:
                            type.caption.copyWith(color: colors.colorTextMuted),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: CupidSpacing.sm),
              CupidIcon(
                CupidIcons.chevronRight,
                variant: CupidIconVariant.line,
                size: 20,
                color: colors.colorTextMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One question, and nothing that says which one of how many it is.
class _QuestionView extends StatelessWidget {
  const _QuestionView({required this.question});

  final ZodiacQuestion question;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final AppL10n l10n = AppL10n.of(context);
    final bool aboutOther =
        question.subject == ZodiacQuestionSubject.guessAboutOther;

    return ListView(
      key: const Key('zodiac_question_view'),
      padding: const EdgeInsets.all(CupidSpacing.md),
      children: <Widget>[
        // AC-12: an answer given on the other person's behalf is framed as the
        // reader's guess *before* they give it, not annotated afterwards.
        if (aboutOther) ...<Widget>[
          Text(
            key: const Key('zodiac_question_guess_label'),
            l10n.zodiac_shell_guess_label,
            style: type.caption.copyWith(color: colors.colorTextMuted),
          ),
          const SizedBox(height: CupidSpacing.sm),
        ],
        Text(
          key: const Key('zodiac_question_prompt'),
          question.prompt,
          style: type.body.copyWith(color: colors.colorText),
        ),
        const SizedBox(height: CupidSpacing.md),
        for (final ZodiacOption option in question.options)
          Padding(
            padding: const EdgeInsets.only(bottom: CupidSpacing.sm),
            child: _OptionButton(option: option),
          ),
        const SizedBox(height: CupidSpacing.sm),
        const _LeaveRoundAction(),
      ],
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({required this.option});

  final ZodiacOption option;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platform = context.cupidPlatform;

    return Semantics(
      button: true,
      child: GestureDetector(
        key: Key('zodiac_option_${option.id}'),
        behavior: HitTestBehavior.opaque,
        onTap: () => context.read<ZodiacShellCubit>().answer(option.id),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.colorSurface,
            borderRadius: BorderRadius.circular(platform.radiusSmall),
            border: Border.all(color: colors.colorLine),
          ),
          child: Padding(
            padding: const EdgeInsets.all(CupidSpacing.md),
            child: Text(
              option.label,
              style: type.body.copyWith(color: colors.colorText),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.state});

  final ZodiacShellState state;

  /// The card is created first and announced afterwards — no confirmation
  /// dialog stands between the tap and the card (`ux/uiux-spec.md` §3.2). The
  /// screen stays where it is, so a reader can add a second and a third
  /// suggestion from the same surface.
  Future<void> _addToCards(
    BuildContext context,
    ZodiacSuggestion suggestion,
  ) async {
    final ZodiacShellCubit cubit = context.read<ZodiacShellCubit>();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppL10n l10n = AppL10n.of(context);

    final ActivityCard card = await cubit.addToCards(suggestion);

    messenger.showSnackBar(
      SnackBar(
        key: const Key('zodiac_card_created_snackbar'),
        duration: const Duration(seconds: 5),
        content: Text(l10n.zodiac_shell_card_created_snackbar),
        action: SnackBarAction(
          label: l10n.zodiac_shell_card_created_undo,
          onPressed: () => cubit.undoAddToCards(card),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ZodiacResultSurface(
            result: state.result!,
            onAddToCards: (ZodiacSuggestion suggestion) =>
                _addToCards(context, suggestion),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: CupidSpacing.md),
          child: _BackToPickerAction(),
        ),
      ],
    );
  }
}

/// AC-3: leaving a round half-answered is a plain exit. No "bạn sắp xong rồi",
/// no tally of abandoned rounds, and the next visit starts clean.
class _LeaveRoundAction extends StatelessWidget {
  const _LeaveRoundAction();

  @override
  Widget build(BuildContext context) {
    return _NeutralTextAction(
      actionKey: const Key('zodiac_leave_round'),
      label: AppL10n.of(context).zodiac_shell_leave_round_action,
    );
  }
}

/// A reader who picked none of the three leaves with no consequence and no
/// second ask.
class _BackToPickerAction extends StatelessWidget {
  const _BackToPickerAction();

  @override
  Widget build(BuildContext context) {
    return _NeutralTextAction(
      actionKey: const Key('zodiac_back_to_picker'),
      label: AppL10n.of(context).zodiac_shell_back_to_picker_action,
    );
  }
}

class _NeutralTextAction extends StatelessWidget {
  const _NeutralTextAction({required this.actionKey, required this.label});

  final Key actionKey;
  final String label;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Align(
      alignment: Alignment.centerLeft,
      child: Semantics(
        button: true,
        child: GestureDetector(
          key: actionKey,
          behavior: HitTestBehavior.opaque,
          onTap: () => context.read<ZodiacShellCubit>().backToPicker(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: CupidSpacing.sm),
            child: Text(
              label,
              style: type.body.copyWith(color: colors.colorTextMuted),
            ),
          ),
        ),
      ),
    );
  }
}
