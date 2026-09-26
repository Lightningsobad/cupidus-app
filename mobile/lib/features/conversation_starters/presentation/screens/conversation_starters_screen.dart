import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/database/cupid_database.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/realtime/backend_user_id_store.dart';
import '../../../../design_system/design_system.dart';
import '../../../activity_cards/domain/activity_card_repository.dart';
import '../../../context_notebook/context_notebook_entry_point.dart';
import '../../data/calendar_event_state_repository.dart';
import '../../domain/calendar_event_service.dart';
import '../../domain/event_date_label.dart';
import '../../domain/starter_selector.dart';
import '../cubit/conversation_starters_cubit.dart';
import '../widgets/starter_hero_card.dart';
import '../widgets/starter_line.dart';

/// This screen's entry point id for the inline ask mechanism
/// (`STORY-004/architecture/contract-summary.md` §2). A label the slot claims a
/// route with — `AskOnTheSpotSlot` branches on nothing else because of it.
const String conversationStartersEntryPointId = 'conversation_starters';

/// The ask targets a starter line can be personalised from, most wanted first.
///
/// Exactly the two slots `StarterContextSlot` declares. The skill profile is
/// not here: no shipped starter is keyed by a skill, so asking for one would be
/// a question whose answer this screen could not use (AC-6).
final List<String> conversationStartersNeededFieldIds =
    List<String>.unmodifiable(<String>[
  AskTarget.notebookInterest.wireValue,
  AskTarget.notebookEvent.wireValue,
]);

/// How long the copy confirmation stays up (`ux/uiux-spec.md` §2: 2 giây, tự
/// biến mất, không phải hộp thoại chặn).
const Duration kStarterCopiedToastDuration = Duration(seconds: 2);

/// Builds the one inline ask card for screen (6). Same seam as screen (5): the
/// screen owns the ask's identity and passes it in, so a test can substitute
/// the surface without this feature naming a context notebook internal.
typedef ConversationStartersAskSlotBuilder = Widget Function({
  required String entryPointId,
  required List<String> neededFieldIds,
  required VoidCallback onContextChanged,
});

/// "Mồi chuyện", screen (6) of `ux/uiux-spec.md`.
///
/// Top to bottom: a round of starter lines, one inline ask card, a thin
/// divider, and the upcoming-events strip. [today] is injected rather than read
/// here, so the rendered round is a function of its inputs (AC-17).
class ConversationStartersScreen extends StatelessWidget {
  const ConversationStartersScreen({
    super.key,
    required this.today,
    this.cubitBuilder,
    this.askSlotBuilder,
  });

  final String today;

  /// Test/preview seam. Left null in production so the screen resolves the
  /// same composition-root registrations every other consumer uses.
  @visibleForTesting
  final ConversationStartersCubit Function()? cubitBuilder;

  @visibleForTesting
  final ConversationStartersAskSlotBuilder? askSlotBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConversationStartersCubit>(
      create: (_) => (cubitBuilder?.call() ?? _resolveCubit(today))..load(),
      child: _ConversationStartersBody(askSlotBuilder: askSlotBuilder),
    );
  }
}

ConversationStartersCubit _resolveCubit(String today) =>
    ConversationStartersCubit(
      notebook: contextNotebookReader(),
      cardRepository: getIt<ActivityCardRepository>(),
      eventStateRepository: CalendarEventStateRepository(getIt<CupidDatabase>()),
      ownerKeyStore: getIt<BackendUserIdStore>(),
      today: today,
    );

Widget _defaultAskSlot({
  required String entryPointId,
  required List<String> neededFieldIds,
  required VoidCallback onContextChanged,
}) {
  return AskOnTheSpotSlot(
    entryPointId: entryPointId,
    neededFieldIds: neededFieldIds,
    onContextChanged: onContextChanged,
  );
}

class _ConversationStartersBody extends StatelessWidget {
  const _ConversationStartersBody({required this.askSlotBuilder});

  final ConversationStartersAskSlotBuilder? askSlotBuilder;

  @override
  Widget build(BuildContext context) {
    final ConversationStartersCubit cubit =
        context.read<ConversationStartersCubit>();

    return Scaffold(
      appBar: CupidHeader(
        title: starterText(context, 'Mồi chuyện', 'Conversation starters'),
        onBack: Navigator.of(context).canPop()
            ? () => Navigator.of(context).maybePop()
            : null,
      ),
      body: SafeArea(
        top: false,
        child:
            BlocBuilder<ConversationStartersCubit, ConversationStartersState>(
          builder: (BuildContext context, ConversationStartersState state) {
            if (state.loading) {
              return const SizedBox(key: Key('conversation-starters-loading'));
            }

            return ListView(
              key: const Key('conversation-starters-list'),
              padding: const EdgeInsets.all(CupidSpacing.md),
              children: <Widget>[
                if (state.starters.isNotEmpty)
                  StarterHeroCard(
                    starter: state.starters.first,
                    onCopied: () => _showCopied(context),
                    onNextRound: cubit.nextPage,
                  ),
                if (state.starters.length > 1) ...<Widget>[
                  const SizedBox(height: CupidSpacing.md),
                  const _TopicCaption(),
                  for (final RenderedStarter starter
                      in state.starters.skip(1))
                    _SecondaryStarterCard(
                      starter: starter,
                      onCopied: () => _showCopied(context),
                    ),
                ],
                const SizedBox(height: CupidSpacing.sm),
                (askSlotBuilder ?? _defaultAskSlot)(
                  entryPointId: conversationStartersEntryPointId,
                  neededFieldIds: conversationStartersNeededFieldIds,
                  onContextChanged: cubit.refreshContext,
                ),
                const _ThinDivider(),
                _EventStrip(events: state.events),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Transient, self-dismissing, and non-blocking — a `SnackBar`, not a dialog
  /// (`ux/uiux-spec.md` §2). It confirms the clipboard write and nothing else:
  /// no card is created and no "đã copy" list is kept (AC-2/AC-3).
  void _showCopied(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        key: const Key('starter_copied_toast'),
        duration: kStarterCopiedToastDuration,
        content: Text(starterText(context, 'Đã copy', 'Copied')),
      ),
    );
  }
}

/// "CÙNG CHỦ ĐỀ": the eyebrow the round's remaining starters sit under.
///
/// Drawn only when there is at least one such starter — a one-item pack gets
/// the hero card alone, with no empty box and no placeholder under it (AC-28).
class _TopicCaption extends StatelessWidget {
  const _TopicCaption();

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Padding(
      padding: const EdgeInsets.only(bottom: CupidSpacing.sm),
      child: Text(
        starterText(context, 'CÙNG CHỦ ĐỀ', 'SAME TOPIC'),
        key: const Key('starter_topic_caption'),
        style: type.caption.copyWith(
          color: colors.colorTextMuted,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

/// One of the round's non-hero starters, in its own rounded box.
class _SecondaryStarterCard extends StatelessWidget {
  const _SecondaryStarterCard({required this.starter, required this.onCopied});

  final RenderedStarter starter;

  final VoidCallback onCopied;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;

    return Padding(
      padding: const EdgeInsets.only(bottom: CupidSpacing.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.colorSurfaceAlt,
          borderRadius: BorderRadius.circular(platform.radiusCard),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: CupidSpacing.md,
            vertical: CupidSpacing.sm,
          ),
          child: StarterLine(starter: starter, onCopied: onCopied),
        ),
      ),
    );
  }
}

class _ThinDivider extends StatelessWidget {
  const _ThinDivider();

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: CupidSpacing.sm),
      child: Divider(height: 0, color: colors.colorLine),
    );
  }
}

/// "CÓ LỊCH SẴN · RỦ ĐI ĐƯỢC": the upcoming-events strip.
///
/// Empty is a defined state with a neutral line, not an invitation and not a
/// repeat of the Minute-1 voice — only the absolutely empty hub of screen (1)
/// gets that (`ux/uiux-spec.md` §3).
class _EventStrip extends StatelessWidget {
  const _EventStrip({required this.events});

  final List<VisibleCalendarEvent> events;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            CupidIcon(
              CupidIcons.event,
              variant: CupidIconVariant.line,
              size: CupidSpacing.md,
              color: colors.colorAccentLilac,
            ),
            const SizedBox(width: CupidSpacing.xs),
            Flexible(
              child: Text(
                starterText(
                  context,
                  'CÓ LỊCH SẴN · RỦ ĐI ĐƯỢC',
                  'ALREADY DATED · EASY TO ASK',
                ),
                key: const Key('starter_events_heading'),
                style: type.caption.copyWith(
                  color: colors.colorAccentLilac,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: CupidSpacing.sm),
        if (events.isEmpty)
          Text(
            starterText(
              context,
              'Chưa có sự kiện nào sắp tới',
              'No upcoming events yet',
            ),
            key: const Key('starter_events_empty'),
            style: type.body.copyWith(color: colors.colorTextMuted),
          )
        else
          for (final VisibleCalendarEvent event in events)
            _EventRow(event: event),
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event});

  final VisibleCalendarEvent event;

  @override
  Widget build(BuildContext context) {
    final ConversationStartersCubit cubit =
        context.read<ConversationStartersCubit>();
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Padding(
      key: Key('starter_event_${event.id}'),
      padding: const EdgeInsets.symmetric(vertical: CupidSpacing.xs),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '${event.event.name} — ${eventDateLabel(event.date)}',
                  key: Key('starter_event_name_${event.id}'),
                  style: type.body.copyWith(color: colors.colorText),
                ),
                if (event.reason case final String reason) ...<Widget>[
                  const SizedBox(height: CupidSpacing.xs),
                  Text(
                    reason,
                    key: Key('starter_event_reason_${event.id}'),
                    style: type.caption.copyWith(color: colors.colorTextMuted),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: CupidSpacing.sm),
          _AddToStorePill(
            key: Key('starter_event_add_${event.id}'),
            onTap: () => cubit.addEventToStore(event),
          ),
          const SizedBox(width: CupidSpacing.xs),
          _DismissControl(
            key: Key('starter_event_dismiss_${event.id}'),
            onTap: () => cubit.dismissEvent(event),
          ),
        ],
      ),
    );
  }
}

/// The small pink pill, not a full-width button (`ux/uiux-spec.md` §2).
class _AddToStorePill extends StatelessWidget {
  const _AddToStorePill({super.key, required this.onTap});

  static const double _height = kStarterCopyTapTarget;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final String label =
        starterText(context, 'Thêm vào Muốn làm', 'Add to Muốn làm');

    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: _height,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: CupidSpacing.md),
          decoration: BoxDecoration(
            color: colors.colorAccentPink,
            borderRadius: BorderRadius.circular(platform.radiusButton),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CupidIcon(
                CupidIcons.add,
                variant: CupidIconVariant.line,
                size: CupidSpacing.md,
                color: colors.colorOnAccent,
              ),
              const SizedBox(width: CupidSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  style: type.caption.copyWith(color: colors.colorOnAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The `close` icon-button beside the pill: removes the row immediately, with
/// no confirmation dialog and no reason asked (AC-14).
class _DismissControl extends StatelessWidget {
  const _DismissControl({super.key, required this.onTap});

  static const double _size = kStarterCopyTapTarget;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Semantics(
      button: true,
      label: starterText(context, 'Bỏ qua', 'Skip'),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: _size,
          height: _size,
          child: Center(
            child: CupidIcon(
              CupidIcons.close,
              variant: CupidIconVariant.line,
              size: CupidSpacing.lg,
              color: colors.colorTextMuted,
            ),
          ),
        ),
      ),
    );
  }
}
