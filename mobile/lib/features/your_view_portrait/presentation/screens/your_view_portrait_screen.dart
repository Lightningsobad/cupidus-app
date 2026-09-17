import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/content/content_package.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/generated/app_l10n.dart';
import '../../data/portrait_answer_repository.dart';
import '../cubit/your_view_portrait_cubit.dart';
import '../widgets/portrait_question_step.dart';
import '../widgets/portrait_section_block.dart';

/// The portrait screen. It has no `routeName` and appears in no route table on
/// purpose: it is reachable only through the entry point that also carries
/// where the user came from, so the surface cannot be linked to from anywhere
/// that has not passed a source (P5 owns that door and the test that locks it).
class YourViewPortraitScreen extends StatelessWidget {
  const YourViewPortraitScreen({
    super.key,
    required this.answers,
    this.contentLoader = const ContentPackageLoader(),
  });

  final PortraitAnswerRepository answers;
  final ContentPackageLoader contentLoader;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return BlocProvider<YourViewPortraitCubit>(
      create: (_) => YourViewPortraitCubit(
        answers: answers,
        contentLoader: contentLoader,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CupidHeader(
          title: l10n.portrait_screen_title,
          onBack: Navigator.of(context).canPop()
              ? () => Navigator.of(context).maybePop()
              : null,
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: const <Widget>[
              _ProvenanceBanner(),
              Expanded(child: _PortraitBody()),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sits between the app bar and the scrolling area rather than inside it, so
/// no amount of scrolling can take it off screen (AC-7). It renders in the
/// question state and in the result state alike: where the words came from is
/// true of both (AC-6, AC-8).
class _ProvenanceBanner extends StatelessWidget {
  const _ProvenanceBanner();

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platform = context.cupidPlatform;

    return Container(
      key: const Key('portrait-provenance'),
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        CupidSpacing.md,
        CupidSpacing.sm,
        CupidSpacing.md,
        0,
      ),
      padding: const EdgeInsets.all(CupidSpacing.sm),
      decoration: BoxDecoration(
        color: colors.colorPeach.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(platform.radiusSmall),
        border: Border.all(color: colors.colorPeach.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.info_outline, size: 18, color: colors.colorPeach),
          const SizedBox(width: CupidSpacing.sm),
          Expanded(
            child: Text(
              l10n.portrait_provenance_label,
              style: type.caption.copyWith(color: colors.colorText),
            ),
          ),
        ],
      ),
    );
  }
}

class _PortraitBody extends StatelessWidget {
  const _PortraitBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YourViewPortraitCubit, YourViewPortraitState>(
      builder: (BuildContext context, YourViewPortraitState state) {
        switch (state.stage) {
          // Packs and answers resolve within a frame or two off local storage.
          // An empty area is the honest intermediate state; a spinner would
          // promise that something is being worked out about the other person,
          // and nothing is (AC-30).
          case PortraitStage.loading:
            return const SizedBox.shrink();
          case PortraitStage.questioning:
            return PortraitQuestionStep(
              key: ValueKey<String>(state.question!.id),
              question: state.question!,
              position: state.questionPosition,
              total: state.questionCount,
              onAnswer: ({required String value, String? optionId}) =>
                  context.read<YourViewPortraitCubit>().answer(
                        value: value,
                        optionId: optionId,
                      ),
              onSkip: () => context.read<YourViewPortraitCubit>().skip(),
            );
          case PortraitStage.portrait:
            // The list ends with the last section. No export, no share, no
            // copy, and no "you finished your portrait" banner: the way out is
            // the back affordance the user came in with (AC-24, AC-28).
            return ListView(
              key: const Key('portrait-result-list'),
              padding: const EdgeInsets.all(CupidSpacing.md),
              children: <Widget>[
                for (final section in state.sections)
                  PortraitSectionBlock(section: section),
              ],
            );
        }
      },
    );
  }
}
