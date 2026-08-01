import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../design_system/design_system.dart';
import '../../../auth/presentation/auth_strings.dart';
import '../../domain/reminder_stage.dart';
import '../reminder_schedule_bloc.dart';
import '../reminder_schedule_state.dart';
import '../reminder_strings.dart';
import '../widgets/reminder_time_stepper.dart';
import '../widgets/reminder_weekday_chips.dart';

/// Existing mobile max content width reused for the responsive rule
/// (`ux/uiux-spec.md` §6: "cap card content at the existing mobile max
/// width and center it").
const double _maxContentWidth = 480;

/// Computes the next single absolute occurrence (ASSUMPTION-1: the frozen
/// `Alarm` entity has no recurrence column, so this is the one timestamp
/// `ReminderScheduleTimeSubmitted` carries over the wire) for [timeOfDay] on
/// one of [weekdays], or the next occurrence of that clock time when
/// [weekdays] is empty. Scans up to 14 days ahead so a weekday whose next
/// occurrence has already passed this week wraps correctly into next week.
/// Deferred here from P1 per that phase's completion notes, since this is
/// the time-picker interaction this calculation depends on.
@visibleForTesting
DateTime nextReminderOccurrence({
  required TimeOfDay timeOfDay,
  required Set<int> weekdays,
  required DateTime now,
}) {
  DateTime candidateForDayOffset(int dayOffset) => DateTime(
    now.year,
    now.month,
    now.day,
    timeOfDay.hour,
    timeOfDay.minute,
  ).add(Duration(days: dayOffset));

  if (weekdays.isEmpty) {
    final DateTime today = candidateForDayOffset(0);
    return (today.isAfter(now) ? today : candidateForDayOffset(1)).toUtc();
  }

  for (int dayOffset = 0; dayOffset < 14; dayOffset++) {
    final DateTime candidate = candidateForDayOffset(dayOffset);
    if (weekdays.contains(candidate.weekday) && candidate.isAfter(now)) {
      return candidate.toUtc();
    }
  }
  // Unreachable in practice: every weekday value recurs within 7 days.
  return candidateForDayOffset(7).toUtc();
}

/// DI entry point (`architecture/solution.md` §4 Mobile Lane Handoff):
/// provides the already-registered [ReminderScheduleBloc] and starts
/// hydration. [ReminderScheduleView] is the plain, provider-agnostic UI and
/// is what widget tests pump directly under a seeded
/// `BlocProvider<ReminderScheduleBloc>.value`.
class ReminderScheduleScreen extends StatelessWidget {
  const ReminderScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReminderScheduleBloc>(
      create: (_) =>
          getIt<ReminderScheduleBloc>()..add(const ReminderScheduleStarted()),
      child: const ReminderScheduleView(),
    );
  }
}

/// The Synced Reminder schedule screen (`ux/uiux-spec.md` §2): hero card
/// (eyebrow, time + steppers, weekday chips), the two-up partner
/// confirmation row, the three mutually exclusive primary-action states,
/// and the rule card.
class ReminderScheduleView extends StatefulWidget {
  const ReminderScheduleView({super.key});

  @override
  State<ReminderScheduleView> createState() => _ReminderScheduleViewState();
}

class _ReminderScheduleViewState extends State<ReminderScheduleView> {
  /// Local draft clock time. `null` until the user first adjusts a stepper,
  /// so the display otherwise always mirrors the server-synced
  /// `state.reminder.time` (dual-confirmation ritual: both partners must see
  /// the same time).
  TimeOfDay? _draftTimeOfDay;

  TimeOfDay _resolveTimeOfDay(DateTime? reminderTime) {
    final TimeOfDay? draft = _draftTimeOfDay;
    if (draft != null) return draft;
    final DateTime anchor = (reminderTime ?? DateTime.now()).toLocal();
    return TimeOfDay(hour: anchor.hour, minute: anchor.minute);
  }

  void _submitTime(
    ReminderScheduleBloc bloc,
    TimeOfDay timeOfDay,
    Set<int> weekdays,
  ) {
    bloc.add(
      ReminderScheduleTimeSubmitted(
        nextReminderOccurrence(
          timeOfDay: timeOfDay,
          weekdays: weekdays,
          now: DateTime.now(),
        ),
      ),
    );
  }

  void _onTimeChanged(
    ReminderScheduleBloc bloc,
    Set<int> weekdays,
    TimeOfDay next,
  ) {
    setState(() => _draftTimeOfDay = next);
    _submitTime(bloc, next, weekdays);
  }

  void _onWeekdaysChanged(
    ReminderScheduleBloc bloc,
    DateTime? reminderTime,
    Set<int> next,
  ) {
    bloc.add(ReminderScheduleWeekdaysChanged(next));
    _submitTime(bloc, _resolveTimeOfDay(reminderTime), next);
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Scaffold(
      backgroundColor: colors.colorBackground,
      appBar: CupidHeader(
        title: context.viEn('Nhắc nhở đồng bộ', 'Synced Reminder'),
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: SafeArea(
        child: BlocBuilder<ReminderScheduleBloc, ReminderScheduleState>(
          builder: (context, state) {
            final ReminderScheduleBloc bloc = context.read<ReminderScheduleBloc>();
            final TimeOfDay timeOfDay = _resolveTimeOfDay(state.reminder?.time);

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(CupidSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (state.failure != null) ...[
                        _RetryBanner(
                          onRetry: () => bloc.add(
                            const ReminderScheduleRefreshRequested(),
                          ),
                        ),
                        SizedBox(height: CupidSpacing.md),
                      ],
                      _HeroCard(
                        timeOfDay: timeOfDay,
                        weekdays: state.weekdays,
                        onTimeChanged: (next) =>
                            _onTimeChanged(bloc, state.weekdays, next),
                        onWeekdaysChanged: (next) => _onWeekdaysChanged(
                          bloc,
                          state.reminder?.time,
                          next,
                        ),
                      ),
                      if (state.reminder != null && state.stage != null) ...[
                        SizedBox(height: CupidSpacing.lg),
                        _ConfirmationRow(stage: state.stage!),
                        SizedBox(height: CupidSpacing.lg),
                        _PrimaryAction(
                          stage: state.stage!,
                          isSubmitting: state.isSubmitting,
                          onConfirm: () => bloc.add(
                            const ReminderScheduleConfirmPressed(),
                          ),
                        ),
                      ] else if (!state.isLoading) ...[
                        SizedBox(height: CupidSpacing.lg),
                        Text(
                          context.reminderEmptyState,
                          textAlign: TextAlign.center,
                          style: context.cupidType.body.copyWith(
                            color: colors.colorTextMuted,
                          ),
                        ),
                      ],
                      SizedBox(height: CupidSpacing.lg),
                      _RuleCard(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.timeOfDay,
    required this.weekdays,
    required this.onTimeChanged,
    required this.onWeekdaysChanged,
  });

  final TimeOfDay timeOfDay;
  final Set<int> weekdays;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final ValueChanged<Set<int>> onWeekdaysChanged;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Container(
      padding: EdgeInsets.all(CupidSpacing.lg),
      decoration: BoxDecoration(
        gradient: colors.gradientDream,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        boxShadow: colors.glowShadow,
      ),
      child: Column(
        children: [
          Text(
            context.reminderHeroEyebrow,
            textAlign: TextAlign.center,
            style: type.caption.copyWith(
              color: colors.colorBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: CupidSpacing.sm),
          ReminderTimeStepper(time: timeOfDay, onChanged: onTimeChanged),
          SizedBox(height: CupidSpacing.md),
          ReminderWeekdayChips(selected: weekdays, onChanged: onWeekdaysChanged),
        ],
      ),
    );
  }
}

class _ConfirmationRow extends StatelessWidget {
  const _ConfirmationRow({required this.stage});

  final ReminderStage stage;

  @override
  Widget build(BuildContext context) {
    final bool youConfirmed =
        stage == ReminderStage.awaitingPartner ||
        stage == ReminderStage.bothConfirmed;
    final bool partnerConfirmed =
        stage == ReminderStage.needsMyConfirmation ||
        stage == ReminderStage.bothConfirmed;

    return Row(
      children: [
        Expanded(
          child: _ConfirmationCard(
            label: context.viEn('Bạn', 'You'),
            confirmed: youConfirmed,
            confirmedText: context.reminderYouConfirmed,
          ),
        ),
        SizedBox(width: CupidSpacing.sm),
        Expanded(
          child: _ConfirmationCard(
            label: context.viEn('Đối tác', 'Partner'),
            confirmed: partnerConfirmed,
            confirmedText: context.reminderPartnerConfirmed,
          ),
        ),
      ],
    );
  }
}

class _ConfirmationCard extends StatelessWidget {
  const _ConfirmationCard({
    required this.label,
    required this.confirmed,
    required this.confirmedText,
  });

  final String label;
  final bool confirmed;
  final String confirmedText;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;
    // Accessibility (`ux/uiux-spec.md` §7): confirmation state is conveyed
    // by this text label plus `stateColor` below -- never colour alone.
    final Color stateColor = confirmed ? colors.colorMint : colors.colorTextMuted;

    return Container(
      padding: EdgeInsets.all(CupidSpacing.md),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
        border: Border.all(color: colors.colorLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: type.body.copyWith(color: colors.colorText)),
          SizedBox(height: CupidSpacing.xs),
          Text(
            confirmed ? confirmedText : context.reminderNotConfirmedYet,
            style: type.caption.copyWith(color: stateColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.stage,
    required this.isSubmitting,
    required this.onConfirm,
  });

  final ReminderStage stage;
  final bool isSubmitting;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return switch (stage) {
      ReminderStage.needsMyConfirmation => CupidPrimaryButton(
        label: context.reminderConfirmCta,
        onPressed: isSubmitting ? null : onConfirm,
      ),
      ReminderStage.awaitingPartner => _WaitingPill(
        label: context.reminderWaitingPartnerCta,
      ),
      ReminderStage.bothConfirmed => _TryItNowButton(
        label: context.reminderTryItNowCta,
      ),
      ReminderStage.firing || ReminderStage.cleared => const SizedBox.shrink(),
    };
  }
}

class _WaitingPill extends StatelessWidget {
  const _WaitingPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: CupidSpacing.md,
        vertical: CupidSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.colorSurfaceAlt,
        borderRadius: BorderRadius.circular(platformTokens.radiusButton),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupidIcon(CupidIcons.hourglass, size: 18, color: colors.colorTextMuted),
          SizedBox(width: CupidSpacing.sm),
          Flexible(
            child: Text(
              label,
              style: type.body.copyWith(color: colors.colorTextMuted),
            ),
          ),
        ],
      ),
    );
  }
}

/// The "Try it now (demo)" secondary CTA (`ux/uiux-spec.md` §2,
/// `bothConfirmed` state). No outbound wire event exists for a
/// client-triggered demo firing (`architecture/solution.md` §4 lists only
/// `setAlarm`/`confirmAlarm`/`stopAlarm`, and `ReminderFiringCubit` (P3)
/// opens only on the server-sent `triggerAlarm` event), so this phase
/// renders the button per the UX spec but leaves it inert (`onPressed:
/// null`) rather than fabricating a wire event or reaching into P3's
/// not-yet-built cubit. Wiring a real "demo" trigger is a follow-up decision
/// for whichever phase/story adds that capability.
class _TryItNowButton extends StatelessWidget {
  const _TryItNowButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return OutlinedButton(
      onPressed: null,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: colors.colorMint),
        foregroundColor: colors.colorMint,
      ),
      child: Text(label),
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard();

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Container(
      padding: EdgeInsets.all(CupidSpacing.md),
      decoration: BoxDecoration(
        color: colors.colorSurfaceAlt,
        borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupidIcon(CupidIcons.swipeRight, size: 20, color: colors.colorTextMuted),
          SizedBox(width: CupidSpacing.sm),
          Expanded(
            child: Text(
              context.reminderRuleCard,
              style: type.caption.copyWith(color: colors.colorTextMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _RetryBanner extends StatelessWidget {
  const _RetryBanner({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Row(
      children: [
        Expanded(
          child: Text(
            context.reminderLoadFailure,
            style: type.caption.copyWith(color: colors.colorRed),
          ),
        ),
        TextButton(onPressed: onRetry, child: Text(context.reminderRetryCta)),
      ],
    );
  }
}
