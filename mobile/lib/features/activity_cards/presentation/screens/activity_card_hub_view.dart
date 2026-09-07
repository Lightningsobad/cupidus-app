import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../design_system/theme/cupid_theme_context.dart';
import '../../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../../design_system/tokens/cupid_platform_tokens.dart';
import '../../../../design_system/tokens/cupid_spacing.dart';
import '../../../../design_system/tokens/cupid_typography_tokens.dart';
import '../../domain/activity_card.dart';
import '../../domain/activity_card_repository.dart';
import '../activity_card_list_cubit.dart';
import '../widgets/activity_card_tile.dart';
import '../widgets/activity_status_filter.dart';

/// The solo card hub: quick-entry strip, the five-pane status filter, and the
/// selected pane's card list (`ux/uiux-spec.md` §1). It is the "Muốn làm"
/// destination of the stage-1 tab bar `HomeScreen` mounts for an unpaired
/// session (AC-22, D-3); the bar is the shell's, not this view's.
class ActivityCardHubView extends StatelessWidget {
  const ActivityCardHubView({super.key, this.repository});

  /// Test/preview seam. Left null in production so the hub resolves the same
  /// composition-root registration every other consumer uses.
  final ActivityCardRepository? repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ActivityCardListCubit>(
      create: (_) => ActivityCardListCubit(
        repository: repository ?? getIt<ActivityCardRepository>(),
      )..load(),
      child: const _ActivityCardHubBody(),
    );
  }
}

class _ActivityCardHubBody extends StatelessWidget {
  const _ActivityCardHubBody();

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final ActivityCardListCubit cubit = context.read<ActivityCardListCubit>();

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ActivityCardListCubit, ActivityCardListState>(
          builder: (BuildContext context, ActivityCardListState state) {
            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                final ScrollMetrics metrics = notification.metrics;
                if (metrics.axis == Axis.vertical &&
                    metrics.extentAfter < 200) {
                  cubit.loadMore();
                }
                return false;
              },
              child: CustomScrollView(
                key: const Key('activity_card_hub'),
                slivers: <Widget>[
                  const SliverToBoxAdapter(child: _QuickEntryStrip()),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickyFilterHeader(
                      height: platform.tapTarget + CupidSpacing.md,
                      background: colors.colorBackground,
                      child: ActivityStatusFilter(
                        selected: state.pane,
                        countOf: state.countForPane,
                        onSelected: cubit.selectPane,
                      ),
                    ),
                  ),
                  ..._contentSlivers(context, state, cubit),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: CupidSpacing.xl),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _contentSlivers(
    BuildContext context,
    ActivityCardListState state,
    ActivityCardListCubit cubit,
  ) {
    if (state.loading) {
      return const <Widget>[
        SliverToBoxAdapter(
          child: SizedBox(key: Key('activity_card_hub_loading')),
        ),
      ];
    }
    if (state.cards.isEmpty) {
      return <Widget>[
        SliverToBoxAdapter(child: _EmptyPane(state: state, cubit: cubit)),
      ];
    }
    return <Widget>[
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: CupidSpacing.md),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              final ActivityCard card = state.cards[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: CupidSpacing.md),
                child: ActivityCardTile(
                  card: card,
                  replyState: state.replyStateOf(card),
                  onPrimaryAction: () => _showComingSoon(context),
                  onToggleReply: () => cubit.toggleReplyState(card.id),
                  onDelete: () => cubit.deleteCard(card.id),
                  onOverflowAction: (ActivityCardOverflowAction action) {
                    if (action == ActivityCardOverflowAction.delete) {
                      cubit.deleteCard(card.id);
                      return;
                    }
                    // "Chuyển trạng thái" and "Sửa" open the card detail,
                    // which P6 owns; until then they answer with the same
                    // neutral message every unbuilt path here uses.
                    _showComingSoon(context);
                  },
                ),
              );
            },
            childCount: state.cards.length,
          ),
        ),
      ),
    ];
  }

  /// The four primary actions open flows owned by later stories. Until those
  /// ship, the tap answers with the same neutral "sắp có" message
  /// `ux/uiux-spec.md` §6 prescribes for an unfilled entry point, so no pane
  /// becomes a dead end (SC-5).
  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(activityHubText(context, 'Sắp có', 'Coming soon')),
      ),
    );
  }
}

/// The three-cell quick-entry frame (`ux/uiux-spec.md` §6). P4 owns the frame
/// only: STORY-004/005/011 fill the cells through P5, so the slots carry no
/// label, no icon, and deliberately no count badge or "new" dot.
class _QuickEntryStrip extends StatelessWidget {
  const _QuickEntryStrip();

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;

    return Padding(
      key: const Key('activity_quick_entry_strip'),
      padding: const EdgeInsets.fromLTRB(
        CupidSpacing.md,
        CupidSpacing.md,
        CupidSpacing.md,
        0,
      ),
      child: Row(
        children: <Widget>[
          for (int slot = 0; slot < 3; slot++) ...<Widget>[
            if (slot > 0) const SizedBox(width: CupidSpacing.sm),
            Expanded(
              child: SizedBox(
                key: Key('activity_quick_entry_slot_$slot'),
                // The empty frame is exactly one tap target tall; P5 sets the
                // final height from the icon + one-line label it drops in.
                height: platform.tapTarget,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.colorSurface,
                    borderRadius: BorderRadius.circular(platform.radiusSmall),
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

class _EmptyPane extends StatelessWidget {
  const _EmptyPane({required this.state, required this.cubit});

  final ActivityCardListState state;
  final ActivityCardListCubit cubit;

  @override
  Widget build(BuildContext context) {
    // An empty store is the Minute-1 state, whose two invitations belong to
    // P5. P4 leaves the slot untouched rather than repeating them here.
    if (state.storeCount == 0) {
      return const SizedBox(key: Key('activity_card_hub_minute1_slot'));
    }

    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Padding(
      key: const Key('activity_card_hub_empty_pane'),
      padding: const EdgeInsets.symmetric(
        horizontal: CupidSpacing.md,
        vertical: CupidSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            activityHubText(
              context,
              'Chưa có thẻ nào ở đây.',
              'Nothing in this pane yet.',
            ),
            style: type.body.copyWith(color: colors.colorTextMuted),
          ),
          const SizedBox(height: CupidSpacing.sm),
          Semantics(
            button: true,
            child: GestureDetector(
              key: const Key('activity_card_hub_empty_pane_link'),
              behavior: HitTestBehavior.opaque,
              onTap: () => cubit.selectPane(ActivityCardPane.all),
              child: Text(
                activityPaneLabel(context, ActivityCardPane.all),
                style: type.body.copyWith(
                  color: colors.colorAccentPink,
                  decoration: TextDecoration.underline,
                  decorationColor: colors.colorAccentPink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyFilterHeader extends SliverPersistentHeaderDelegate {
  const _StickyFilterHeader({
    required this.height,
    required this.background,
    required this.child,
  });

  final double height;
  final Color background;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: background,
      child: SizedBox(height: height, child: child),
    );
  }

  @override
  bool shouldRebuild(_StickyFilterHeader oldDelegate) =>
      oldDelegate.height != height ||
      oldDelegate.background != background ||
      oldDelegate.child != child;
}
