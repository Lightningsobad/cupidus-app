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
import '../../domain/starter_selector.dart';
import '../cubit/conversation_starters_cubit.dart';
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
                for (final RenderedStarter starter in state.starters)
                  StarterLine(
                    starter: starter,
                    onCopied: () => _showCopied(context),
                  ),
                const SizedBox(height: CupidSpacing.xs),
                _NextRoundButton(onPressed: cubit.nextPage),
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

/// "Xem câu khác": a text button, never disabled.
///
/// There is no exhausted state to disable it into — the selector wraps — so
/// this widget has no `enabled` flag to get wrong, and the screen ships no
/// "x/N", no progress bar and no "đã xem hết" line beside it (AC-4/AC-27).
class _NextRoundButton extends StatelessWidget {
  const _NextRoundButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        key: const Key('starter_next_round'),
        onPressed: onPressed,
        child: Text(
          starterText(context, 'Xem câu khác', 'Show other lines'),
          style: type.body.copyWith(
            color: colors.colorAccentPink,
            fontWeight: FontWeight.w400,
          ),
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

/// "Sự kiện có lịch": the upcoming-events strip.
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
        Text(
          starterText(context, 'Sự kiện có lịch', 'Dated events'),
          key: const Key('starter_events_heading'),
          style: type.body.copyWith(
            color: colors.colorText,
            fontWeight: FontWeight.w600,
          ),
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

  /// `YYYY-MM-DD` read as `dd/mm`. A substring of the pinned civil date the
  /// pack ships, so the badge cannot drift from the date the card is given.
  String get _dayMonthBadge =>
      '${event.date.substring(8, 10)}/${event.date.substring(5, 7)}';

  @override
  Widget build(BuildContext context) {
    final ConversationStartersCubit cubit =
        context.read<ConversationStartersCubit>();
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platform = context.cupidPlatform;

    return Padding(
      key: Key('starter_event_${event.id}'),
      padding: const EdgeInsets.symmetric(vertical: CupidSpacing.xs),
      child: Row(
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.colorSurfaceAlt,
              borderRadius: BorderRadius.circular(platform.radiusButton),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CupidSpacing.sm,
                vertical: CupidSpacing.xs,
              ),
              child: Text(
                _dayMonthBadge,
                key: Key('starter_event_date_${event.id}'),
                style: type.caption.copyWith(color: colors.colorAccentLilac),
              ),
            ),
          ),
          const SizedBox(width: CupidSpacing.sm),
          Expanded(
            child: Text(
              event.event.name,
              key: Key('starter_event_name_${event.id}'),
              style: type.body.copyWith(color: colors.colorText),
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
    final String label = starterText(context, 'Thêm vào kho', 'Add to store');

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
          child: Text(
            label,
            style: type.caption.copyWith(color: colors.colorOnAccent),
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
