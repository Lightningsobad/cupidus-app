import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/generated/app_l10n.dart';
import '../../data/dream_jar_repository.dart';
import '../dream_jar_detail_cubit.dart';
import '../dream_jar_strings.dart';
import '../widgets/dream_jar_hero_card.dart';
import '../widgets/dream_jar_quick_add_section.dart';
import '../widgets/dream_jar_unpaired_notice.dart';
import '../widgets/partner_split_card.dart';
import 'contribution_history_screen.dart';

/// STORY-014 P2 jar detail screen (`ux/uiux-spec.md` §1.1), restyled in
/// STORY-027 against the locked design source's `jar` screen. [jarId] and
/// [repository] are passed in directly rather than resolved via `getIt`: P5
/// (Home entry point) owns the `getIt` registration and navigation route.
class DreamJarDetailScreen extends StatelessWidget {
  const DreamJarDetailScreen({
    super.key,
    required this.jarId,
    required this.repository,
    this.currentUserId,
  });

  final String jarId;
  final DreamJarRepository repository;

  /// The signed-in user's backend id, used to attribute contributions in the
  /// per-partner comparison. `null` until the caller can resolve it.
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DreamJarDetailCubit>(
      create: (_) =>
          DreamJarDetailCubit(repository: repository, jarId: jarId)
            ..loadJar(),
      child: _DreamJarDetailView(
        jarId: jarId,
        repository: repository,
        currentUserId: currentUserId,
      ),
    );
  }
}

class _DreamJarDetailView extends StatelessWidget {
  const _DreamJarDetailView({
    required this.jarId,
    required this.repository,
    required this.currentUserId,
  });

  final String jarId;
  final DreamJarRepository repository;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final AppL10n l10n = AppL10n.of(context);
    // This screen is always pushed, so `maybePop` is the design source's
    // `back`/`goJarList` action; it is a no-op only in the preview harness,
    // which mounts the screen as a root route.
    void goBack() => Navigator.of(context).maybePop();

    return Scaffold(
      backgroundColor: colors.colorBackground,
      appBar: CupidHeader(title: DreamJarStrings.headerTitle, onBack: goBack),
      body: BlocBuilder<DreamJarDetailCubit, DreamJarDetailState>(
        builder: (context, state) => switch (state) {
          DreamJarDetailLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          DreamJarDetailUnpaired() => const DreamJarUnpairedNotice(),
          DreamJarDetailFailed() => _LoadErrorView(failure: state.failure),
          // `padding:8px 16px 40px;gap:13px` on the design source's jar body.
          DreamJarDetailLoaded() => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DreamJarHeroCard(
                  jar: state.jar,
                  contributionFailure: state.contributionFailure,
                  onSelectJar: goBack,
                ),
                const SizedBox(height: 13),
                DreamJarQuickAddSection(
                  enabled: !state.isAddingContribution,
                  onQuickAdd: (amount) =>
                      context.read<DreamJarDetailCubit>().addContribution(
                        amount,
                      ),
                ),
                const SizedBox(height: 13),
                PartnerSplitCard(
                  contributions: state.contributions,
                  currentUserId: currentUserId,
                ),
                const SizedBox(height: 13),
                CupidPrimaryButton(
                  label: l10n.dream_jar_contribution_history_title,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ContributionHistoryScreen(
                        jarId: jarId,
                        repository: repository,
                        currentUserId: currentUserId,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        },
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
