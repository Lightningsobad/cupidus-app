import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../design_system/design_system.dart';
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

/// Direction vectors for the hero card's `linear-gradient(160deg, ...)`, using
/// the same CSS-angle convention as `CupidColorTokens`' 120deg pair:
/// begin = (-sin, cos), end = (sin, -cos), with sin(160deg) = 0.342020 and
/// cos(160deg) = -0.939693.
const Alignment _heroGradientBegin = Alignment(-0.3420201433256687, -0.9396926207859084);
const Alignment _heroGradientEnd = Alignment(0.3420201433256687, 0.9396926207859084);

/// Shared CTA height for the three mutually exclusive primary-action states
/// (design source `Cupid Screens.dc.html` lines 519/522/525: `height:54px`).
const double _ctaHeight = 54;

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
        title: context.reminderScreenTitle,
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
                  padding: EdgeInsets.fromLTRB(
                    CupidSpacing.md,
                    CupidSpacing.sm,
                    CupidSpacing.md,
                    CupidSpacing.xl + CupidSpacing.sm,
                  ),
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
                        SizedBox(height: CupidSpacing.md),
                        _ConfirmationRow(stage: state.stage!),
                        SizedBox(height: CupidSpacing.md),
                        _PrimaryAction(
                          stage: state.stage!,
                          isSubmitting: state.isSubmitting,
                          onConfirm: () => bloc.add(
                            const ReminderScheduleConfirmPressed(),
                          ),
                        ),
                      ] else if (!state.isLoading) ...[
                        SizedBox(height: CupidSpacing.md),
                        Text(
                          context.reminderEmptyState,
                          textAlign: TextAlign.center,
                          style: context.cupidType.body.copyWith(
                            color: colors.colorTextMuted,
                          ),
                        ),
                      ],
                      SizedBox(height: CupidSpacing.md),
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
      padding: EdgeInsets.symmetric(
        horizontal: CupidSpacing.md + CupidSpacing.xs,
        vertical: CupidSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: _heroGradientBegin,
          end: _heroGradientEnd,
          colors: <Color>[
            colors.colorAmber.withValues(alpha: 0.22),
            colors.colorAccentPurple.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        border: Border.all(color: colors.colorLine),
      ),
      child: Column(
        children: [
          Text(
            context.reminderHeroEyebrow,
            textAlign: TextAlign.center,
            style: type.caption.copyWith(color: colors.colorTextMuted),
          ),
          SizedBox(height: CupidSpacing.md),
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
            label: context.reminderYouLabel,
            confirmed: youConfirmed,
            confirmedText: context.reminderYouConfirmed,
          ),
        ),
        SizedBox(width: CupidSpacing.sm),
        Expanded(
          child: _ConfirmationCard(
            label: context.reminderPartnerLabel,
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
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        boxShadow: platformTokens.elevationShadow,
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: type.caption.copyWith(
              color: colors.colorText,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: CupidSpacing.xs),
          Text(
            confirmed ? confirmedText : context.reminderNotConfirmedYet,
            textAlign: TextAlign.center,
            style: type.caption.copyWith(color: stateColor),
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
      ReminderStage.needsMyConfirmation => SizedBox(
        height: _ctaHeight,
        child: CupidPrimaryButton(
          label: context.reminderConfirmCta,
          onPressed: isSubmitting ? null : onConfirm,
        ),
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
      height: _ctaHeight,
      padding: EdgeInsets.symmetric(horizontal: CupidSpacing.md),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusButton),
        border: Border.all(color: colors.colorLine),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupidIcon(CupidIcons.hourglass, size: 20, color: colors.colorTextMuted),
          SizedBox(width: CupidSpacing.sm),
          Flexible(
            child: Text(
              label,
              style: type.body.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.colorTextMuted,
              ),
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
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    // The design source renders this CTA in its enabled treatment; the
    // disabled* slots carry the same values so the inert button above still
    // matches the locked visual instead of rendering a greyed-out variant.
    final BorderSide side = BorderSide(color: colors.colorMint, width: 1.5);

    return SizedBox(
      height: _ctaHeight,
      child: OutlinedButton(
        onPressed: null,
        style: OutlinedButton.styleFrom(
          backgroundColor: colors.colorMint.withValues(alpha: 0.16),
          disabledBackgroundColor: colors.colorMint.withValues(alpha: 0.16),
          foregroundColor: colors.colorMint,
          disabledForegroundColor: colors.colorMint,
          side: side,
          disabledIconColor: colors.colorMint,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(platformTokens.radiusButton),
            side: side,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CupidIcon(
              CupidIcons.notificationsActive,
              size: 21,
              color: colors.colorMint,
            ),
            SizedBox(width: CupidSpacing.sm),
            Flexible(
              child: Text(
                label,
                style: type.body.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: colors.colorMint,
                ),
              ),
            ),
          ],
        ),
      ),
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

    final TextStyle bodyStyle = type.caption.copyWith(
      color: colors.colorTextMuted,
      height: 1.55,
    );
    final TextStyle emphasisStyle = bodyStyle.copyWith(
      color: colors.colorText,
      fontWeight: FontWeight.w700,
    );

    return Container(
      padding: EdgeInsets.all(CupidSpacing.md),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        boxShadow: platformTokens.elevationShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupidIcon(CupidIcons.swipeRight, size: 20, color: colors.colorPeach),
          SizedBox(width: CupidSpacing.sm),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: bodyStyle,
                children: [
                  TextSpan(
                    text: context.reminderRuleCardLeadIn,
                    style: emphasisStyle,
                  ),
                  TextSpan(text: context.reminderRuleCardBeforeEmphasis),
                  TextSpan(
                    text: context.reminderRuleCardEmphasis,
                    style: emphasisStyle,
                  ),
                  TextSpan(text: context.reminderRuleCardAfterEmphasis),
                ],
              ),
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
