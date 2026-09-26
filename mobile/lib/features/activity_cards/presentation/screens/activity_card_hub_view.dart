import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../design_system/theme/cupid_theme_context.dart';
import '../../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../../design_system/tokens/cupid_platform_tokens.dart';
import '../../../../design_system/tokens/cupid_spacing.dart';
import '../../../../design_system/tokens/cupid_typography_tokens.dart';
import '../../../chapter_closure/data/chapter_closure_service.dart';
import '../../../chapter_closure/data/stage1_wipe_service.dart';
import '../../../chapter_closure/presentation/widgets/close_chapter_dialog.dart';
import '../../../chapter_closure/presentation/widgets/closed_archive_actions.dart';
import '../../../conversation_starters/conversation_starters_entry_point.dart';
import '../../../gift_ideas/gift_ideas_entry_point.dart';
import '../../../phase_status/data/home_widget_bridge.dart';
import '../../../phase_status/data/phase_content_repository.dart';
import '../../../phase_status/data/phase_status_prefs.dart';
import '../../../phase_status/domain/drip_cadence_policy.dart';
import '../../../phase_status/domain/milestone_resolver.dart';
import '../../../phase_status/presentation/evening_check_in_sheet.dart';
import '../../../phase_status/presentation/gift_progress_block.dart';
import '../../../phase_status/presentation/phase_status_cubit.dart';
import '../../../phase_status/presentation/phase_status_line.dart';
import '../../../phase_status/presentation/wealth_counter_line.dart';
import '../../../zodiac_shell/zodiac_shell_entry_point.dart';
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
    this.chapterClosureService,
    this.closedArchive,
    this.stage1WipeService,
    this.phaseContent,
    this.phaseWidgetPublisher,
    this.phaseStatusPrefs,
    this.today,
  });

  /// Test/preview seam. Left null in production so the hub resolves the same
  /// composition-root registration every other consumer uses.
  final ActivityCardRepository? repository;

  /// Same seam for the STORY-013 closure writer, so the entry-point test can
  /// assert that confirming calls it exactly once without a composition root.
  final ChapterClosureService? chapterClosureService;

  /// The "Đã đóng" pane's reader and the purge writer. Both stay optional all
  /// the way down: a hub without them simply never grows a sixth pane, which is
  /// exactly the pre-closure state the app must look like anyway (AC-16).
  final ClosedArchiveReader? closedArchive;
  final Stage1WipeService? stage1WipeService;

  /// Test/preview seam for the content packages the phase line reads.
  final PhaseContentRepository? phaseContent;

  /// Test/preview seam. Left null in production so the hub publishes through
  /// the real bridge, on the same pass it draws the line.
  final PhaseWidgetPublisher? phaseWidgetPublisher;

  /// Test/preview seam for the milestone and drip cursors, which are the only
  /// two device-local stores screen (1) reads.
  final PhaseStatusPrefs? phaseStatusPrefs;

  /// Clock seam shared by the phase line and the per-card countdown, so both
  /// read the same day and a test can pin it.
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    final ActivityCardRepository resolved =
        repository ?? getIt<ActivityCardRepository>();
    return BlocProvider<ActivityCardListCubit>(
      create: (_) => ActivityCardListCubit(
        repository: resolved,
        closedArchive: closedArchive ??
            (getIt.isRegistered<ClosedArchiveReader>()
                ? getIt<ClosedArchiveReader>()
                : null),
      )..load(),
      child: BlocProvider<PhaseStatusCubit>(
        create: (_) => PhaseStatusCubit(
          repository: resolved,
          content: phaseContent,
          widgetPublisher: phaseWidgetPublisher ??
              HomeWidgetPhasePublisher(
                resolved,
                content: phaseContent,
                clock: today == null ? null : () => today!,
              ),
          eveningCheckIn: buildEveningCheckInScheduler(
            content: phaseContent,
            cards: resolved,
          ),
          milestone: MilestoneResolver(phaseStatusPrefs ?? PhaseStatusPrefs()),
          drip: DripCadencePolicy(phaseStatusPrefs ?? PhaseStatusPrefs()),
          clock: today == null ? null : () => today!,
        ),
        child: _ActivityCardHubBody(
          repository: repository,
          chapterClosureService: chapterClosureService,
          stage1WipeService: stage1WipeService,
          today: today,
        ),
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
  const _ActivityCardHubBody({
    this.repository,
    this.chapterClosureService,
    this.stage1WipeService,
    this.today,
  });

  final ActivityCardRepository? repository;
  final ChapterClosureService? chapterClosureService;
  final Stage1WipeService? stage1WipeService;
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
            // A closure can empty every ordinary pane. That is not Minute-1:
            // hiding the filter then would hide the only way back into the
            // closed archive (AC-30).
            final bool minuteOne = !state.loading &&
                state.storeCount == 0 &&
                !state.hasClosedArchive;

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
                  // The overflow sits in the hub's own header row rather than
                  // in an app bar: the stage-1 shell deliberately has none
                  // (AC-22/D-3), and this story may not grow one back.
                  SliverToBoxAdapter(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _CloseChapterOverflow(
                        chapterClosureService: widget.chapterClosureService,
                        onClosed: cubit.load,
                      ),
                    ),
                  ),
                  if (!minuteOne) ...<Widget>[
                    // Above the quick-entry strip and outside the sticky
                    // header, which is where `ux/uiux-spec.md` §6 puts the
                    // counter: a static line under the screen title, not a
                    // chrome element that follows the user down the list.
                    SliverToBoxAdapter(
                      child: BlocBuilder<PhaseStatusCubit, PhaseStatusState>(
                        builder: (BuildContext context, PhaseStatusState phase) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              WealthCounterLine(
                                label: phase.counterLabel,
                                milestone: phase.milestone,
                              ),
                              GiftProgressBlock(line: phase.giftProgress),
                              DripCaptionLine(line: phase.drip),
                            ],
                          );
                        },
                      ),
                    ),
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
                          showClosedPane: state.hasClosedArchive,
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
    return <Widget>[
      // The two archive actions sit above the archive itself, so they are
      // reachable whether it still holds cards or not (AC-30).
      if (state.pane.isClosedArchive && !state.loading)
        SliverToBoxAdapter(
          child: ClosedArchiveActions(
            closureService: widget.chapterClosureService,
            wipeService: widget.stage1WipeService,
            onChanged: cubit.load,
          ),
        ),
      ..._paneSlivers(context, state, cubit),
    ];
  }

  List<Widget> _paneSlivers(
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
              return BlocBuilder<PhaseStatusCubit, PhaseStatusState>(
                builder: (BuildContext context, PhaseStatusState phase) {
                  // D-1: the phase block belongs to the card it is about, so
                  // the anchor card is handed the block and draws it inside
                  // itself. Every other card is handed `null` and is built
                  // exactly as it was.
                  final bool anchored =
                      index == _anchorIndex(state.cards, phase);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: CupidSpacing.md),
                    child: GestureDetector(
                      key: Key('activity_card_open_${card.id}'),
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _openDetail(context, cubit, card),
                      child: ActivityCardTile(
                        card: card,
                        replyState: state.replyStateOf(card),
                        today: widget.today,
                        phaseBlock: anchored
                            ? PhaseStatusLine(
                                primary: phase.primary,
                                secondary: phase.secondary,
                                actionLabel: phase.actionLabel,
                                // The preparation area lives inside the card
                                // detail (survey 4 note 5): the action names
                                // the intent, it does not open a route of its
                                // own.
                                onActionTap: () =>
                                    _openDetail(context, cubit, card),
                              )
                            : null,
                        onPrimaryAction: () => _openDetail(context, cubit, card),
                        onToggleReply: () => cubit.toggleReplyState(card.id),
                        onOverflowAction: (ActivityCardOverflowAction action) {
                          if (action == ActivityCardOverflowAction.delete) {
                            cubit.deleteCard(card.id);
                            return;
                          }
                          // "Chuyển trạng thái" and "Sửa" are both modes of
                          // the detail screen (AC-13), not two destinations.
                          _openDetail(context, cubit, card);
                        },
                      ),
                    ),
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
    if (context.mounted) {
      // The detail screen is the only place a card changes status, and a
      // status change is the third and last moment the widget payload may move
      // (`WIDGET-STALE`) — there is no watcher and no background job behind it.
      await context.read<PhaseStatusCubit>().refresh();
    }
  }
}

/// All three cells now lead somewhere, each through its own feature's single
/// entry-point function, so this stays a routing switch rather than three
/// separate strips. No cell carries an unlock condition: none of the three
/// destinations is gated on location, paid tier, or onboarding progress.
///
/// Top-level rather than a method because both hub states carry the strip — the
/// populated hub and Minute-1, which is the first hub a new user sees — and they
/// have to route a cell to the same place.
///
/// The pane is reloaded on the way back because screens (5) and (7) create cards
/// in this very store, and a stale list would make the add look like it failed.
Future<void> _openQuickEntryCell(
  BuildContext context,
  ActivityCardListCubit cubit,
  QuickEntryCell cell,
) async {
  switch (cell) {
    case QuickEntryCell.giftIdeas:
      await openGiftIdeasScreen(context);
    case QuickEntryCell.conversationStarters:
      await openConversationStartersScreen(context);
    case QuickEntryCell.zodiacShell:
      await openZodiacShellScreen(context);
  }

  if (cubit.isClosed) {
    return;
  }
  await cubit.load();
}

/// The only way into a chapter closure (AC-16): one overflow item, reached on
/// purpose, never offered by a banner, a hint, or a floating button anywhere
/// else in the app (`ux/uiux-spec.md` §1).
class _CloseChapterOverflow extends StatefulWidget {
  const _CloseChapterOverflow({
    required this.chapterClosureService,
    required this.onClosed,
  });

  final ChapterClosureService? chapterClosureService;
  final Future<void> Function() onClosed;

  @override
  State<_CloseChapterOverflow> createState() => _CloseChapterOverflowState();
}

class _CloseChapterOverflowState extends State<_CloseChapterOverflow> {
  bool _closing = false;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return PopupMenuButton<String>(
      key: const Key('activity_card_hub_overflow'),
      icon: Icon(Icons.more_vert, color: colors.colorTextMuted),
      color: colors.colorSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(platform.radiusCard),
      ),
      onSelected: (String _) => _confirmAndClose(),
      itemBuilder: (BuildContext _) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          key: const Key('activity_card_hub_close_chapter'),
          value: 'close_chapter',
          child: Text(
            activityHubText(context, 'Đóng ngăn gọn gàng', 'Close the chapter'),
            style: type.body.copyWith(color: colors.colorText),
          ),
        ),
      ],
    );
  }

  /// Confirming once is the whole ceremony (AC-1, AC-2): no second prompt, no
  /// reason field, no consolation. `_closing` only keeps a double tap from
  /// writing twice, it is not another step the user has to pass.
  Future<void> _confirmAndClose() async {
    if (_closing) {
      return;
    }
    final bool confirmed = await showCloseChapterDialog(context);
    if (!confirmed || !mounted) {
      return;
    }
    setState(() => _closing = true);
    final ChapterClosureService service =
        widget.chapterClosureService ?? getIt<ChapterClosureService>();
    await service.close();
    if (!mounted) {
      setState(() => _closing = false);
      return;
    }
    // Neutral and self-dismissing (AC-3): it states what happened and where
    // things went, and offers no way back in (AC-16).
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        key: const Key('close_chapter_done'),
        content: Text(
          activityHubText(
            context,
            'Đã đóng ngăn. Mục đã đóng nằm trong kho đã đóng.',
            'Chapter closed. Closed items live in the closed drawer.',
          ),
        ),
      ),
    );
    await widget.onClosed();
    if (mounted) {
      setState(() => _closing = false);
    }
  }
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
