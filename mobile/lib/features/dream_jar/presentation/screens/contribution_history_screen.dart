import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/generated/app_l10n.dart';
import '../../data/dream_jar.dart';
import '../../data/dream_jar_amount_format.dart';
import '../../data/dream_jar_repository.dart';
import '../contribution_history_cubit.dart';
import '../widgets/dream_jar_unpaired_notice.dart';
import '../widgets/partner_split_card.dart';

/// STORY-014 P4 contribution-history screen (`ux/uiux-spec.md` §1.6).
/// [jarId], [repository] and [currentUserId] are passed in directly rather
/// than resolved via `getIt`/a couple-profile lookup: mirrors the P2/P3
/// precedent that the entry-point phase owns wiring, and no partner-name
/// lookup exists yet in this app, so [PartnerSplitCard] labels columns
/// "You"/"Partner" rather than by name.
class ContributionHistoryScreen extends StatelessWidget {
  const ContributionHistoryScreen({
    super.key,
    required this.jarId,
    required this.repository,
    required this.currentUserId,
  });

  final String jarId;
  final DreamJarRepository repository;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ContributionHistoryCubit>(
      create: (_) =>
          ContributionHistoryCubit(repository: repository, jarId: jarId)
            ..loadFirstPage(),
      child: _ContributionHistoryView(currentUserId: currentUserId),
    );
  }
}

class _ContributionHistoryView extends StatefulWidget {
  const _ContributionHistoryView({required this.currentUserId});

  final String? currentUserId;

  @override
  State<_ContributionHistoryView> createState() =>
      _ContributionHistoryViewState();
}

class _ContributionHistoryViewState extends State<_ContributionHistoryView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ContributionHistoryCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return Scaffold(
      appBar: CupidHeader(
        title: l10n.dream_jar_contribution_history_title,
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: SafeArea(
        child: BlocBuilder<ContributionHistoryCubit, ContributionHistoryState>(
          builder: (context, state) => switch (state) {
            ContributionHistoryLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            ContributionHistoryUnpaired() => const DreamJarUnpairedNotice(),
            ContributionHistoryFailed() => _LoadErrorView(
              failure: state.failure,
            ),
            ContributionHistoryLoaded(contributions: final contributions)
                when contributions.isEmpty =>
              _EmptyHistoryView(currentUserId: widget.currentUserId),
            ContributionHistoryLoaded() => _HistoryList(
              state: state,
              currentUserId: widget.currentUserId,
              scrollController: _scrollController,
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
              l10n.dream_jar_contribution_history_load_error,
              textAlign: TextAlign.center,
              style: type.body.copyWith(color: colors.colorText),
            ),
            SizedBox(height: CupidSpacing.md),
            CupidPrimaryButton(
              label: l10n.common_actions_retry,
              onPressed: () =>
                  context.read<ContributionHistoryCubit>().loadFirstPage(),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistoryView extends StatelessWidget {
  const _EmptyHistoryView({required this.currentUserId});

  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final AppL10n l10n = AppL10n.of(context);

    return ListView(
      padding: EdgeInsets.all(CupidSpacing.lg),
      children: [
        PartnerSplitCard(
          contributions: const <Contribution>[],
          currentUserId: currentUserId,
        ),
        SizedBox(height: CupidSpacing.xl),
        Text(
          l10n.dream_jar_contribution_history_empty,
          textAlign: TextAlign.center,
          style: type.body.copyWith(color: colors.colorTextMuted),
        ),
      ],
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({
    required this.state,
    required this.currentUserId,
    required this.scrollController,
  });

  final ContributionHistoryLoaded state;
  final String? currentUserId;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final List<Contribution> contributions = state.contributions;

    return ListView.separated(
      controller: scrollController,
      padding: EdgeInsets.all(CupidSpacing.lg),
      itemCount:
          contributions.length + 1 + (state.hasMore || state.loadMoreFailed ? 1 : 0),
      separatorBuilder: (_, _) => SizedBox(height: CupidSpacing.sm),
      itemBuilder: (context, index) {
        if (index == 0) {
          return PartnerSplitCard(
            contributions: contributions,
            currentUserId: currentUserId,
          );
        }
        final int rowIndex = index - 1;
        if (rowIndex == contributions.length) {
          return state.loadMoreFailed
              ? Center(
                  child: TextButton(
                    onPressed: () =>
                        context.read<ContributionHistoryCubit>().loadMore(),
                    child: Text(l10n.common_actions_retry),
                  ),
                )
              : Semantics(
                  label: l10n.dream_jar_contribution_history_loading_more,
                  child: const Center(child: CircularProgressIndicator()),
                );
        }
        return _ContributionRow(
          contribution: contributions[rowIndex],
          currentUserId: currentUserId,
        );
      },
    );
  }
}

class _ContributionRow extends StatelessWidget {
  const _ContributionRow({required this.contribution, required this.currentUserId});

  final Contribution contribution;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final AppL10n l10n = AppL10n.of(context);

    final bool isSelf =
        currentUserId != null && contribution.userId == currentUserId;
    final String contributorLabel = isSelf
        ? l10n.dream_jar_partner_split_you_label
        : l10n.dream_jar_partner_split_partner_label;

    return ClipRRect(
      borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
      child: Container(
        color: colors.colorSurface,
        padding: EdgeInsets.all(CupidSpacing.md),
        child: Row(
          children: [
            ExcludeSemantics(
              child: CircleAvatar(
                backgroundColor: colors.colorSurfaceAlt,
                foregroundColor: colors.colorText,
                child: Text(contributorLabel.substring(0, 1)),
              ),
            ),
            SizedBox(width: CupidSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$contributorLabel · ${DreamJarAmountFormat.vnd(contribution.amount)}',
                    style: type.body.copyWith(color: colors.colorText),
                  ),
                  if (contribution.note != null &&
                      contribution.note!.isNotEmpty) ...[
                    SizedBox(height: CupidSpacing.xs),
                    Text(
                      contribution.note!,
                      style: type.caption.copyWith(
                        color: colors.colorTextMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              _relativeTime(l10n, contribution.createdAt),
              style: type.caption.copyWith(color: colors.colorTextMuted),
            ),
            if (isSelf) ...[
              const SizedBox(width: 6),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: colors.colorRed.withOpacity(0.7),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Hoàn tác',
                onPressed: () async {
                  final bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (dialogCtx) => AlertDialog(
                      backgroundColor: colors.colorSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Text(
                        'Hoàn tác đóng góp?',
                        style: type.cardTitle.copyWith(
                          color: colors.colorText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      content: Text(
                        'Bạn có chắc chắn muốn huỷ khoản đóng góp ${DreamJarAmountFormat.vnd(contribution.amount)} này không?',
                        style: type.body.copyWith(
                          color: colors.colorTextMuted,
                          height: 1.45,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogCtx).pop(false),
                          child: Text(
                            'Huỷ',
                            style: type.body.copyWith(
                              color: colors.colorTextMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(dialogCtx).pop(true),
                          child: Text(
                            'Hoàn tác',
                            style: type.body.copyWith(
                              color: colors.colorRed,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    context
                        .read<ContributionHistoryCubit>()
                        .deleteContribution(contribution.id);
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// `ux/uiux-spec.md` §1.6 "relative timestamp". Buckets below 30 days;
/// beyond that, falls back to an absolute locale-formatted date rather than
/// an ever-growing "N days ago" string.
String _relativeTime(AppL10n l10n, DateTime createdAt) {
  final Duration age = DateTime.now().difference(createdAt);
  if (age.inMinutes < 1) return l10n.dream_jar_contribution_time_just_now;
  if (age.inHours < 1) {
    return l10n.dream_jar_contribution_time_minutes_ago(age.inMinutes);
  }
  if (age.inDays < 1) {
    return l10n.dream_jar_contribution_time_hours_ago(age.inHours);
  }
  if (age.inDays < 30) {
    return l10n.dream_jar_contribution_time_days_ago(age.inDays);
  }
  return DateFormat.yMMMd().format(createdAt);
}
