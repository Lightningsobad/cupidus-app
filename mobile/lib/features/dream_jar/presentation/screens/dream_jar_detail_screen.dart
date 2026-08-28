import 'dart:math' as math;

import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/generated/app_l10n.dart';
import '../../data/dream_jar.dart';
import '../../data/dream_jar_amount_format.dart';
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

  Future<void> _confirmAndAddContribution(
    BuildContext context,
    num amount,
    DreamJar jar,
  ) async {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.colorSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Xác nhận thêm tiền',
          style: type.cardTitle.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.colorText,
          ),
        ),
        content: Text(
          'Bạn có chắc chắn muốn thêm ${DreamJarAmountFormat.vnd(amount)} vào hũ "${jar.name}" không?',
          style: type.body.copyWith(
            fontSize: 14.5,
            height: 1.45,
            color: colors.colorTextMuted,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Huỷ',
              style: type.body.copyWith(
                color: colors.colorTextMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Xác nhận',
              style: type.body.copyWith(
                color: colors.colorAccentPink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final cubit = context.read<DreamJarDetailCubit>();
      final contribution = await cubit.addContribution(amount);

      if (contribution != null && context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: colors.colorSurface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: colors.colorAccentPink.withOpacity(0.35),
                width: 1,
              ),
            ),
            duration: const Duration(seconds: 8),
            content: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: colors.colorMint,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Đã thêm ${DreamJarAmountFormat.vnd(amount)} vào hũ!',
                    style: type.caption.copyWith(
                      color: colors.colorText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            action: SnackBarAction(
              label: 'Hoàn tác',
              textColor: colors.colorAccentPink,
              onPressed: () {
                cubit.undoContribution(contribution.id);
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _showCustomAmountDialog(
    BuildContext context,
    DreamJar jar,
  ) async {
    final TextEditingController amountController = TextEditingController();
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final num remaining = math.max(0, jar.targetAmount - jar.currentAmount);

    final num? customAmount = await showDialog<num>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            final raw = amountController.text.replaceAll(
              RegExp(r'[^0-9]'),
              '',
            );
            final num val = num.tryParse(raw) ?? 0;
            final bool isValid = val > 0;

            return AlertDialog(
              backgroundColor: colors.colorSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Nhập số tiền muốn thêm',
                style: type.cardTitle.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.colorText,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (remaining > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Còn thiếu: ${DreamJarAmountFormat.vnd(remaining)} để đạt mục tiêu',
                        style: type.caption.copyWith(
                          fontSize: 12.5,
                          color: colors.colorAccentPink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    style: type.body.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: colors.colorText,
                    ),
                    decoration: InputDecoration(
                      suffixText: '₫',
                      hintText: 'Ví dụ: 50.000',
                      hintStyle: type.body.copyWith(
                        color: colors.colorTextMuted.withOpacity(0.6),
                      ),
                      filled: true,
                      fillColor: colors.colorSurfaceAlt,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Huỷ',
                    style: type.body.copyWith(
                      color: colors.colorTextMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: isValid
                      ? () => Navigator.of(dialogContext).pop(val)
                      : null,
                  child: Text(
                    'Tiếp tục',
                    style: type.body.copyWith(
                      color: isValid
                          ? colors.colorAccentPink
                          : colors.colorTextMuted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (customAmount != null && customAmount > 0 && context.mounted) {
      await _confirmAndAddContribution(context, customAmount, jar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    // This screen is always pushed, so `maybePop` is the design source's
    // `back`/`goJarList` action; it is a no-op only in the preview harness,
    // which mounts the screen as a root route.
    void goBack() => Navigator.of(context).maybePop();

    final String? effectiveUserId = currentUserId ??
        (getIt.isRegistered<BackendUserIdStore>()
            ? getIt<BackendUserIdStore>().backendUserId
            : null);

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
                  effectiveUserId != null && state.jar.createdById == effectiveUserId;

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
                      _RejectedBanner(isCreator: isCreator),
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
                          !state.isAddingContribution &&
                          !state.isUndoing,
                      onQuickAdd: (amount) =>
                          _confirmAndAddContribution(context, amount, state.jar),
                      onCustomAdd: () =>
                          _showCustomAmountDialog(context, state.jar),
                    ),
                    const SizedBox(height: 13),
                    PartnerSplitCard(
                      contributions: state.contributions,
                      currentUserId: effectiveUserId,
                    ),
                    const SizedBox(height: 13),
                    CupidPrimaryButton(
                      label: l10n.dream_jar_contribution_history_title,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ContributionHistoryScreen(
                            jarId: jarId,
                            repository: repository,
                            currentUserId: effectiveUserId,
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
                      gradient: colors.gradientHot,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: colors.colorAccentPink.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: isApproving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: colors.colorOnAccent,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 18,
                                color: colors.colorOnAccent,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                'Đồng ý tạo hũ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: colors.colorOnAccent,
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
  const _RejectedBanner({required this.isCreator});

  final bool isCreator;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    final String message = isCreator
        ? 'Hũ ước mơ này đã bị đối phương từ chối.'
        : 'Bạn đã từ chối tạo hũ ước mơ này.';

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
              message,
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
