import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/generated/app_l10n.dart';
import '../../data/dream_jar_repository.dart';
import '../dream_jar_detail_cubit.dart';
import '../widgets/dream_jar_hero_card.dart';
import '../widgets/dream_jar_unpaired_notice.dart';
import 'contribution_history_screen.dart';

/// STORY-014 P2 jar detail screen (`ux/uiux-spec.md` §1.1). [jarId] and
/// [repository] are passed in directly rather than resolved via `getIt`: P5
/// (Home entry point) owns the `getIt` registration and navigation route.
class DreamJarDetailScreen extends StatelessWidget {
  const DreamJarDetailScreen({
    super.key,
    required this.jarId,
    required this.repository,
  });

  final String jarId;
  final DreamJarRepository repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DreamJarDetailCubit>(
      create: (_) =>
          DreamJarDetailCubit(repository: repository, jarId: jarId)
            ..loadJar(),
      child: _DreamJarDetailView(jarId: jarId, repository: repository),
    );
  }
}

class _DreamJarDetailView extends StatelessWidget {
  const _DreamJarDetailView({required this.jarId, required this.repository});

  final String jarId;
  final DreamJarRepository repository;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<DreamJarDetailCubit, DreamJarDetailState>(
          builder: (context, state) => switch (state) {
            DreamJarDetailLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            DreamJarDetailUnpaired() => const DreamJarUnpairedNotice(),
            DreamJarDetailFailed() => _LoadErrorView(failure: state.failure),
            DreamJarDetailLoaded() => SingleChildScrollView(
              padding: EdgeInsets.all(CupidSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DreamJarHeroCard(
                    jar: state.jar,
                    isAddingContribution: state.isAddingContribution,
                    contributionFailure: state.contributionFailure,
                    onQuickAdd: (amount) =>
                        context.read<DreamJarDetailCubit>().addContribution(
                          amount,
                        ),
                  ),
                  SizedBox(height: CupidSpacing.md),
                  CupidPrimaryButton(
                    label: l10n.dream_jar_contribution_history_title,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ContributionHistoryScreen(
                          jarId: jarId,
                          repository: repository,
                          currentUserId: null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          },
        ),
      ),
    );
  }
}

class _LoadErrorView extends StatelessWidget {
  const _LoadErrorView({required this.failure});

  final Object failure;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final AppL10n l10n = AppL10n.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(CupidSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.dream_jar_load_error,
              textAlign: TextAlign.center,
              style: type.body.copyWith(color: colors.colorText),
            ),
            SizedBox(height: CupidSpacing.md),
            CupidPrimaryButton(
              label: l10n.common_actions_retry,
              onPressed: () => context.read<DreamJarDetailCubit>().loadJar(),
            ),
          ],
        ),
      ),
    );
  }
}
