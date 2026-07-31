import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../../reminders/presentation/reminder_strings.dart';
import '../../reminders/presentation/screens/reminder_schedule_screen.dart';

/// Bootable placeholder screen for the Runnable Project Foundation gate.
/// Replaced by real feature routing once F1-F6 foundation stories land.
///
/// STORY-009 P4 mounts the Synced Reminder entry card here as the feature's
/// sole discoverable navigation edge (`ux/uiux-spec.md` entry-point
/// paragraph before §1.1) -- additive only, no bottom nav bar or router
/// package introduced. The pre-existing readiness `Text` below is left
/// exactly as it was.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cupid')),
      body: Column(
        children: [
          const Expanded(
            child: Center(
              child: Text(
                'Cupid mobile scaffold is running.',
                key: Key('home_screen_ready_signal'),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(CupidSpacing.lg),
            child: _ReminderEntryCard(
              key: const Key('home_reminder_entry_card'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ReminderScheduleScreen(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Labelled, tappable affordance into [ReminderScheduleScreen]
/// (`../../coding-plan/phase-P4-entry-point-and-copy-guard.md`: "discoverable
/// navigation affordance ... not direct-route-only access"). Kept private to
/// this file since P4's write scope is `home_screen.dart` plus `app_shell.dart`
/// only -- not a new design-system or feature widget file.
class _ReminderEntryCard extends StatelessWidget {
  const _ReminderEntryCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Material(
      color: colors.colorSurface,
      borderRadius: BorderRadius.circular(platformTokens.radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        child: Padding(
          padding: EdgeInsets.all(CupidSpacing.md),
          child: Row(
            children: [
              CupidIcon(
                CupidIcons.notificationsActive,
                size: 24,
                color: colors.colorText,
              ),
              SizedBox(width: CupidSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.reminderNotificationsRowTitle,
                      style: type.body.copyWith(
                        color: colors.colorText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: CupidSpacing.xs),
                    Text(
                      context.reminderNotificationsRowSubtitle,
                      style: type.caption.copyWith(color: colors.colorTextMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
