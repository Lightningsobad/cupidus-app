import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../design_system/theme/cupid_theme_context.dart';
import '../../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../../design_system/tokens/cupid_platform_tokens.dart';
import '../../../../design_system/tokens/cupid_spacing.dart';
import '../../../../design_system/tokens/cupid_typography_tokens.dart';
import '../../../gift_ideas/gift_ideas_entry_point.dart';
import '../../../phase_status/data/phase_content_repository.dart';
import '../../../phase_status/presentation/phase_status_cubit.dart';
import '../../../phase_status/presentation/phase_status_line.dart';
import '../../domain/activity_card.dart';
import '../../domain/activity_card_repository.dart';
import '../activity_card_list_cubit.dart';
import '../widgets/activity_card_tile.dart';
import '../widgets/activity_status_filter.dart';
import '../widgets/minute_one_empty_state.dart';
import '../widgets/quick_capture_sheet.dart';
import '../widgets/quick_entry_strip.dart';
import 'activity_card_detail_screen.dart';

/// The solo card hub: quick-entry strip, the five-pane status filter, and the
/// selected pane's card list (`ux/uiux-spec.md` §1). It is the "Muốn làm"
/// destination of the stage-1 tab bar `HomeScreen` mounts for an unpaired
/// session (AC-22, D-3); the bar is the shell's, not this view's.
class ActivityCardHubView extends StatelessWidget {
  const ActivityCardHubView({
    super.key,
    this.repository,
    this.phaseContent,
    this.phaseWidgetPublisher,
    this.today,
  });

  /// Test/preview seam. Left null in production so the hub resolves the same
  /// composition-root registration every other consumer uses.
  final ActivityCardRepository? repository;

  /// Test/preview seam for the content packages the phase line reads.
  final PhaseContentRepository? phaseContent;

  /// Left null until P4 registers the platform implementation; the hub then
  /// publishes the same resolution it draws, on the same pass.
  final PhaseWidgetPublisher? phaseWidgetPublisher;

  /// Clock seam shared by the phase line and the per-card countdown, so both
  /// read the same day and a test can pin it.
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    final ActivityCardRepository resolved =
        repository ?? getIt<ActivityCardRepository>();
    return BlocProvider<ActivityCardListCubit>(
      create: (_) => ActivityCardListCubit(repository: resolved)..load(),
      child: BlocProvider<PhaseStatusCubit>(
        create: (_) => PhaseStatusCubit(
          repository: resolved,
          content: phaseContent,
          widgetPublisher: phaseWidgetPublisher,
          clock: today == null ? null : () => today!,
        ),
        child: _ActivityCardHubBody(repository: repository, today: today),
      ),
    );
  }
}

/// Stateful only to own the refresh loop: the phase line reloads when the hub
/// mounts and when the app comes back to the foreground, and nowhere else
/// (`WIDGET-STALE`). Keeping that in the body rather than in the list item
/// builder means the lazy sliver may build and discard the line as often as it
/// likes without re-running a resolution.
class _ActivityCardHubBody extends StatefulWidget {
  const _ActivityCardHubBody({this.repository, this.today});

  final ActivityCardRepository? repository;
  final DateTime? today;

  @override
  State<_ActivityCardHubBody> createState() => _ActivityCardHubBodyState();
}

class _ActivityCardHubBodyState extends State<_ActivityCardHubBody>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<PhaseStatusCubit>().refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<PhaseStatusCubit>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final ActivityCardListCubit cubit = context.read<ActivityCardListCubit>();

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ActivityCardListCubit, ActivityCardListState>(
          builder: (BuildContext context, ActivityCardListState state) {
            // Minute-1 owns the whole surface: it carries its own copy of the
            // quick-entry strip, and five panes that all read zero are five
            // ways to learn the same thing, so the filter stays off until the
            // store holds something (`ux/uiux-spec.md` §4a).
            final bool minuteOne = !state.loading && state.storeCount == 0;

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
                  if (!minuteOne) ...<Widget>[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: CupidSpacing.md),
                        child: QuickEntryStrip(
                          onCellSelected: (QuickEntryCell cell) =>
                              _openQuickEntryCell(context, cubit, cell),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          CupidSpacing.md,
                          CupidSpacing.md,
                          CupidSpacing.md,
                          0,
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: QuickCaptureAddAction(
                            repository: _repositoryOf(context),
                            storeCount: state.storeCount,
                            onCardCreated: (ActivityCard _) => cubit.load(),
                          ),
                        ),
                      ),
                    ),
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
                  ],
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

  /// The hub resolves the repository once and hands the same instance to every
  /// child, so the capture flows and the detail screen write to the store this
  /// list is reading from.
  ActivityCardRepository _repositoryOf(BuildContext context) =>
      widget.repository ?? getIt<ActivityCardRepository>();

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
        SliverToBoxAdapter(
          child: _EmptyPane(
            state: state,
            cubit: cubit,
            repository: _repositoryOf(context),
          ),
        ),
      ];
    }
    return <Widget>[
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: CupidSpacing.md),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              final ActivityCard card = state.cards[index];
              final Widget tile = Padding(
                padding: const EdgeInsets.only(bottom: CupidSpacing.md),
                child: GestureDetector(
                  key: Key('activity_card_open_${card.id}'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _openDetail(context, cubit, card),
                  child: ActivityCardTile(
                    card: card,
                    replyState: state.replyStateOf(card),
                    today: widget.today,
                    onPrimaryAction: () => _openDetail(context, cubit, card),
                    onToggleReply: () => cubit.toggleReplyState(card.id),
                    onOverflowAction: (ActivityCardOverflowAction action) {
                      if (action == ActivityCardOverflowAction.delete) {
                        cubit.deleteCard(card.id);
                        return;
                      }
                      // "Chuyển trạng thái" and "Sửa" are both modes of the
                      // detail screen (AC-13), not two destinations.
                      _openDetail(context, cubit, card);
                    },
                  ),
                ),
              );
              return BlocBuilder<PhaseStatusCubit, PhaseStatusState>(
                builder: (BuildContext context, PhaseStatusState phase) {
                  if (index != _anchorIndex(state.cards, phase)) {
                    return tile;
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      PhaseStatusLine(
                        primary: phase.primary,
                        secondary: phase.secondary,
                      ),
                      tile,
                    ],
                  );
                },
              );
            },
            childCount: state.cards.length,
          ),
        ),
      ),
    ];
  }

  /// Which card the phase line sits above (`ux/uiux-spec.md` §1: the line
  /// introduces the card it is about). The anchor card is not always in the
  /// selected pane, in which case the line stays at the top of the list rather
  /// than disappearing — it describes the phase, not the pane.
  ///
  /// `-1` when there is no line, so no index ever matches and the list is built
  /// exactly as it was before this phase.
  int _anchorIndex(List<ActivityCard> cards, PhaseStatusState phase) {
    if (!phase.hasLine) {
      return -1;
    }
    final String? anchor = phase.anchorCardId;
    if (anchor == null) {
      return 0;
    }
    final int found = cards.indexWhere((ActivityCard c) => c.id == anchor);
    return found < 0 ? 0 : found;
  }

  /// Every affordance on a tile lands on the same screen, so a card is never a
  /// dead end (SC-5). The pane is reloaded on the way back because the detail
  /// screen may have moved the card to another status or deleted it.
  Future<void> _openDetail(
    BuildContext context,
    ActivityCardListCubit cubit,
    ActivityCard card,
  ) async {
    final ActivityCardRepository repository = _repositoryOf(context);
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => ActivityCardDetailScreen(
          card: card,
          repository: repository,
        ),
      ),
    );
    if (cubit.isClosed) {
      return;
    }
    await cubit.load();
  }
}

/// Only the cell whose story has shipped gets a destination; the other two keep
/// the neutral "sắp có" answer `ux/uiux-spec.md` §6 prescribes for an unfilled
/// entry point, so this stays a routing switch rather than three separate
/// strips.
///
/// Top-level rather than a method because both hub states carry the strip — the
/// populated hub and Minute-1, which is the first hub a new user sees — and they
/// have to route a cell to the same place.
///
/// The pane is reloaded on the way back because screen (5) creates cards in this
/// very store, and a stale list would make the add look like it failed.
Future<void> _openQuickEntryCell(
  BuildContext context,
  ActivityCardListCubit cubit,
  QuickEntryCell cell,
) async {
  if (cell != QuickEntryCell.giftIdeas) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        key: const Key('activity_quick_entry_coming_soon'),
        content: Text(activityHubText(context, 'Sắp có', 'Coming soon')),
      ),
    );
    return;
  }

  await openGiftIdeasScreen(context);
  if (cubit.isClosed) {
    return;
  }
  await cubit.load();
}

class _EmptyPane extends StatelessWidget {
  const _EmptyPane({
    required this.state,
    required this.cubit,
    required this.repository,
  });

  final ActivityCardListState state;
  final ActivityCardListCubit cubit;
  final ActivityCardRepository repository;

  @override
  Widget build(BuildContext context) {
    // An empty store is Minute-1: two invitations and nothing else
    // (`ux/uiux-spec.md` §4a). Creating a card leaves the state, so the hub
    // reloads to pick up the pane and the counts at once.
    if (state.storeCount == 0) {
      return MinuteOneEmptyState(
        repository: repository,
        onCardCreated: (ActivityCard _) => cubit.load(),
        onQuickEntryCellSelected: (QuickEntryCell cell) =>
            _openQuickEntryCell(context, cubit, cell),
      );
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
