import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/generated/app_l10n.dart';
import '../../data/dream_jar.dart';
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
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    // This screen is always pushed, so `maybePop` is the design source's
    // `back`/`goJarList` action; it is a no-op only in the preview harness,
    // which mounts the screen as a root route.
    void goBack() => Navigator.of(context).maybePop();

    return Scaffold(
      appBar: CupidHeader(title: DreamJarStrings.headerTitle, onBack: goBack),
      body: BlocBuilder<DreamJarDetailCubit, DreamJarDetailState>(
        builder: (context, state) => switch (state) {
          DreamJarDetailLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          DreamJarDetailUnpaired() => const DreamJarUnpairedNotice(),
          DreamJarDetailFailed() => _LoadErrorView(failure: state.failure),
          DreamJarDetailLoaded() => Builder(
            builder: (context) {
              final bool isPending = state.jar.status == DreamJarStatus.pending;
              final bool isRejected = state.jar.status == DreamJarStatus.rejected;
              final bool isCreator =
                  currentUserId != null && state.jar.createdById == currentUserId;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isPending && !isCreator) ...[
                      _PendingPartnerApprovalCard(
                        jar: state.jar,
                        isApproving: state.isApproving,
                        isRejecting: state.isRejecting,
                        onApprove: () =>
                            context.read<DreamJarDetailCubit>().approveJar(),
                        onReject: () =>
                            context.read<DreamJarDetailCubit>().rejectJar(),
                      ),
                      const SizedBox(height: 13),
                    ] else if (isPending && isCreator) ...[
                      _PendingCreatorBanner(jar: state.jar),
                      const SizedBox(height: 13),
                    ] else if (isRejected) ...[
                      _RejectedBanner(),
                      const SizedBox(height: 13),
                    ],
                    DreamJarHeroCard(
                      jar: state.jar,
                      contributionFailure: state.contributionFailure,
                      onSelectJar: goBack,
                    ),
                    const SizedBox(height: 13),
                    DreamJarQuickAddSection(
                      enabled: state.jar.status == DreamJarStatus.active &&
                          !state.isAddingContribution,
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
              );
            },
          ),
        },
      ),
    );
  }
}

class _PendingPartnerApprovalCard extends StatelessWidget {
  const _PendingPartnerApprovalCard({
    required this.jar,
    required this.isApproving,
    required this.isRejecting,
    required this.onApprove,
    required this.onReject,
  });

  final DreamJar jar;
  final bool isApproving;
  final bool isRejecting;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        border: Border.all(
          color: colors.colorAccentPink.withOpacity(0.6),
          width: 1.5,
        ),
        boxShadow: platformTokens.elevationShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.colorAccentPink.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.handshake_outlined,
                  size: 22,
                  color: colors.colorAccentPink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yêu cầu duyệt tạo Hũ mới',
                      style: type.cardTitle.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: colors.colorText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Đối phương muốn cùng bạn để dành cho "${jar.name}". Bấm Đồng ý để kích hoạt hũ và bắt đầu góp tiền.',
                      style: type.caption.copyWith(
                        fontSize: 12.5,
                        height: 1.45,
                        color: colors.colorTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: (isApproving || isRejecting) ? null : onApprove,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF5286), Color(0xFFFF7EB3)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5286).withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: isApproving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                              SizedBox(width: 7),
                              Text(
                                'Đồng ý tạo hũ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: (isApproving || isRejecting) ? null : onReject,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.colorSurfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: isRejecting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Từ chối',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colors.colorRed,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PendingCreatorBanner extends StatelessWidget {
  const _PendingCreatorBanner({required this.jar});

  final DreamJar jar;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.colorAmber.withOpacity(0.12),
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        border: Border.all(
          color: colors.colorAmber.withOpacity(0.35),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 22,
            color: colors.colorAmber,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đang chờ đối phương duyệt',
                  style: type.body.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: colors.colorAmber,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Tạo xong, đối phương phải bấm đồng ý thì hũ mới bắt đầu nhận tiền.',
                  style: type.caption.copyWith(
                    fontSize: 12,
                    height: 1.45,
                    color: colors.colorTextMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RejectedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.colorRed.withOpacity(0.12),
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        border: Border.all(
          color: colors.colorRed.withOpacity(0.35),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cancel_outlined,
            size: 22,
            color: colors.colorRed,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Hũ ước mơ này đã bị đối phương từ chối.',
              style: type.body.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colors.colorRed,
              ),
            ),
          ),
        ],
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
