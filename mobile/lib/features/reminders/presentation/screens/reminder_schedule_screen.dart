import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../design_system/design_system.dart';
import '../../domain/synced_reminder.dart';
import '../reminder_schedule_bloc.dart';
import '../reminder_schedule_state.dart';
import '../reminder_strings.dart';
import '../widgets/add_edit_reminder_sheet.dart';
import '../widgets/reminder_confirmed_tick.dart';

const double _maxContentWidth = 480;

/// Entry point providing [ReminderScheduleBloc].
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

/// The Synced Reminder schedule screen: List of synced alarms with mutual consent,
/// time selection, description labels, and recurring repeat days.
class ReminderScheduleView extends StatelessWidget {
  const ReminderScheduleView({super.key});

  void _openAddSheet(BuildContext context) {
    AddEditReminderSheet.show(
      context: context,
      onSave: (time, desc, weekdays) {
        context.read<ReminderScheduleBloc>().add(
          ReminderScheduleCreated(
            time: time,
            description: desc,
            weekdays: weekdays,
            isActive: true,
          ),
        );
      },
    );
  }

  void _openEditSheet(BuildContext context, SyncedReminder reminder) {
    AddEditReminderSheet.show(
      context: context,
      existing: reminder,
      onSave: (time, desc, weekdays) {
        context.read<ReminderScheduleBloc>().add(
          ReminderScheduleUpdated(
            id: reminder.id,
            time: time,
            description: desc,
            weekdays: weekdays,
          ),
        );
      },
      onDelete: () {
        context.read<ReminderScheduleBloc>().add(
          ReminderScheduleDeleteRequested(reminder.id),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens palette = context.cupidColors;
    final CupidTypographyTokens typography = context.cupidType;

    return Scaffold(
      backgroundColor: palette.colorBackground,
      appBar: AppBar(
        backgroundColor: palette.colorBackground.withValues(alpha: 0.8),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: palette.colorText),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          context.reminderScreenTitle,
          style: typography.cardTitle.copyWith(
            fontWeight: FontWeight.w800,
            color: palette.colorText,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            key: const Key('reminder_add_appbar_button'),
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: palette.colorAccentPink.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: palette.colorAccentPink,
                size: 20,
              ),
            ),
            onPressed: () => _openAddSheet(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<ReminderScheduleBloc, ReminderScheduleState>(
        listener: (context, state) {
          if (state.pendingTimeoutNotice) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.reminderTimedOutNotice),
                backgroundColor: palette.colorSurface,
              ),
            );
            context.read<ReminderScheduleBloc>().add(
              const ReminderScheduleTimeoutNoticeAcknowledged(),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.reminders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.failure != null && state.reminders.isEmpty) {
            return _FailureView(
              onRetry: () => context.read<ReminderScheduleBloc>().add(
                const ReminderScheduleRefreshRequested(),
              ),
            );
          }

          final viewerId = state.viewerId ?? '';

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Retry banner if partial failure occurs while list is visible
                  if (state.failure != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FailureBanner(
                        onRetry: () => context.read<ReminderScheduleBloc>().add(
                          const ReminderScheduleRefreshRequested(),
                        ),
                      ),
                    ),

                  // Reminders List or Empty State
                  if (state.reminders.isEmpty)
                    _EmptyStateCard(
                      onAdd: () => _openAddSheet(context),
                    )
                  else ...[
                    for (final reminder in state.reminders)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _AlarmCardItem(
                          key: ValueKey(reminder.id),
                          reminder: reminder,
                          viewerId: viewerId,
                          onTap: () => _openEditSheet(context, reminder),
                          onToggle: (isActive) {
                            context.read<ReminderScheduleBloc>().add(
                              ReminderScheduleToggleRequested(
                                id: reminder.id,
                                isActive: isActive,
                              ),
                            );
                          },
                          onConfirm: () {
                            context.read<ReminderScheduleBloc>().add(
                              ReminderScheduleConfirmRequested(reminder.id),
                            );
                          },
                          onReject: () {
                            context.read<ReminderScheduleBloc>().add(
                              ReminderScheduleRejectRequested(reminder.id),
                            );
                          },
                        ),
                      ),
                    // Quick add button
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: OutlinedButton.icon(
                          key: const Key('reminder_add_button'),
                          onPressed: () => _openAddSheet(context),
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(context.reminderAddNewCta),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: palette.colorAccentPink,
                            side: BorderSide(
                              color: palette.colorAccentPink.withValues(alpha: 0.5),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  const _RuleCard(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A single interactive Alarm card showing time, description, repetition, switch toggle,
/// and partner agreement status banner.
class _AlarmCardItem extends StatelessWidget {
  const _AlarmCardItem({
    super.key,
    required this.reminder,
    required this.viewerId,
    required this.onTap,
    required this.onToggle,
    required this.onConfirm,
    required this.onReject,
  });

  final SyncedReminder reminder;
  final String viewerId;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final VoidCallback onConfirm;
  final VoidCallback onReject;

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatWeekdays(BuildContext context, Set<int> weekdays) {
    if (weekdays.isEmpty) return context.reminderOnce;
    if (weekdays.length == 7) return context.reminderEveryDay;
    if (weekdays.length == 5 &&
        !weekdays.contains(6) &&
        !weekdays.contains(7)) {
      return 'T2 - T6';
    }
    final sorted = weekdays.toList()..sort();
    return sorted.map((d) => context.reminderWeekdayShortLabel(d)).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens palette = context.cupidColors;
    final CupidTypographyTokens typography = context.cupidType;

    final needsConfirm = reminder.needsMyConfirmation(viewerId);
    final awaitingPartner = reminder.isAwaitingPartner(viewerId);

    return Container(
      decoration: BoxDecoration(
        color: palette.colorSurface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: needsConfirm
              ? palette.colorAccentPink.withValues(alpha: 0.6)
              : palette.colorLine.withValues(alpha: 0.35),
          width: needsConfirm ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: needsConfirm
                ? palette.colorAccentPink.withValues(alpha: 0.15)
                : palette.colorBackground.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: palette.colorBackground.withValues(alpha: 0),
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Time Display + Switch Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatTime(reminder.time),
                      style: typography.display.copyWith(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                        color: reminder.isActive
                            ? palette.colorText
                            : palette.colorTextMuted.withValues(alpha: 0.5),
                      ),
                    ),
                    CupertinoSwitch(
                      value: reminder.isActive,
                      activeColor: palette.colorAccentPink,
                      onChanged: (val) => onToggle(val),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Description + Repeat Weekdays
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        reminder.description,
                        style: typography.body.copyWith(
                          fontWeight: FontWeight.w700,
                          color: reminder.isActive
                              ? palette.colorText
                              : palette.colorTextMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: palette.colorSurface.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatWeekdays(context, reminder.weekdays),
                        style: typography.caption.copyWith(
                          fontSize: 11,
                          color: palette.colorTextMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                // Mutual Consent Status / Action Banner
                if (needsConfirm) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: palette.colorAccentPink.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: palette.colorAccentPink.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            reminder.isPendingDeletion
                                ? context.reminderPartnerRequestedDelete
                                : (reminder.isPendingToggle
                                    ? context.reminderPartnerRequestedToggle
                                    : context.reminderPartnerRequestedEdit),
                            style: typography.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: palette.colorText,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Accept Button
                        ElevatedButton(
                          onPressed: onConfirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: palette.colorAccentPink,
                            foregroundColor: palette.colorText,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            minimumSize: const Size(0, 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            context.reminderAcceptCta,
                            style: typography.caption.copyWith(
                              fontWeight: FontWeight.w800,
                              color: palette.colorText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Reject Button
                        OutlinedButton(
                          onPressed: onReject,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: palette.colorTextMuted,
                            side: BorderSide(
                              color: palette.colorLine.withValues(alpha: 0.5),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            minimumSize: const Size(0, 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            context.reminderRejectCta,
                            style: typography.caption.copyWith(
                              fontSize: 11,
                              color: palette.colorTextMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (awaitingPartner) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: palette.colorSurface.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '⏳ ',
                              style: TextStyle(fontSize: 11),
                            ),
                            Text(
                              context.reminderAwaitingPartnerStatus,
                              style: typography.caption.copyWith(
                                fontSize: 11,
                                color: palette.colorTextMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ] else if (reminder.isBothConfirmed && reminder.isActive) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ReminderConfirmedTick(
                        color: palette.colorAccentPink,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        context.reminderPartnerConfirmed,
                        style: typography.caption.copyWith(
                          fontSize: 11,
                          color: palette.colorAccentPink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Empty State shown when no synced reminders exist yet.
class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens palette = context.cupidColors;
    final CupidTypographyTokens typography = context.cupidType;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: palette.colorSurface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: palette.colorLine.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: palette.colorAccentPink.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.alarm,
              size: 40,
              color: palette.colorAccentPink,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            context.reminderNoAlarmsYet,
            style: typography.cardTitle.copyWith(
              fontWeight: FontWeight.w800,
              color: palette.colorText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            context.reminderNoAlarmsSub,
            style: typography.body.copyWith(
              color: palette.colorTextMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            key: const Key('reminder_empty_add_cta'),
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 20),
            label: Text(context.reminderAddNewCta),
            style: ElevatedButton.styleFrom(
              backgroundColor: palette.colorAccentPink,
              foregroundColor: palette.colorText,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rule Card displaying the 5-minute timeout and mutual-dismissal rule.
class _RuleCard extends StatelessWidget {
  const _RuleCard();

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens palette = context.cupidColors;
    final CupidTypographyTokens typography = context.cupidType;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.colorSurface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: palette.colorLine.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.sync,
            size: 20,
            color: palette.colorAccentPink,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: typography.caption.copyWith(
                  color: palette.colorTextMuted,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: context.reminderRuleCardLeadIn,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: palette.colorText,
                    ),
                  ),
                  TextSpan(text: context.reminderRuleCardBeforeEmphasis),
                  TextSpan(
                    text: context.reminderRuleCardEmphasis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: palette.colorText,
                    ),
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

class _FailureView extends StatelessWidget {
  const _FailureView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens palette = context.cupidColors;
    final CupidTypographyTokens typography = context.cupidType;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.reminderLoadFailure,
              style: typography.body.copyWith(color: palette.colorText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(context.reminderRetryCta),
            ),
          ],
        ),
      ),
    );
  }
}

class _FailureBanner extends StatelessWidget {
  const _FailureBanner({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens palette = context.cupidColors;
    final CupidTypographyTokens typography = context.cupidType;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: palette.colorRed.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.reminderLoadFailure,
              style: typography.caption.copyWith(color: palette.colorRed),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(context.reminderRetryCta),
          ),
        ],
      ),
    );
  }
}
