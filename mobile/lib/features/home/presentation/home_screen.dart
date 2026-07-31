import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../vibes/presentation/vibe_screen.dart';
import '../../vibes/presentation/widgets/vibe_entry_card.dart';
import '../../reminders/presentation/reminder_strings.dart';
import '../../reminders/presentation/screens/reminder_schedule_screen.dart';
import '../../../design_system/design_system.dart';
import '../../anti_ghosting/anti_ghosting.dart';

/// Bootable placeholder screen for the Runnable Project Foundation gate.
/// Replaced by real feature routing once F1-F6 foundation stories land.
///
/// Mounts [VibeEntryCard] as the discoverable entry point to the `vibe`
/// screen (`architecture/solution.md` §4 D-010-5); v1 passes no mood
/// snapshot so no duplicate fetch happens ahead of `VibeScreen`'s own load.
/// Additive only — no `AppShell`/tab-bar restructure (out of this phase's
/// scope).
///
/// STORY-009 P4 mounts the Synced Reminder entry card here as the feature's
/// second discoverable navigation edge (`ux/uiux-spec.md` entry-point
/// paragraph before §1.1) -- additive only, no bottom nav bar or router
/// package introduced. The pre-existing readiness `Text` below is left
/// exactly as it was.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cupid')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(CupidSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Center(
                child: Text(
                  'Cupid mobile scaffold is running.',
                  key: Key('home_screen_ready_signal'),
                ),
              ),
              SizedBox(height: CupidSpacing.lg),
              // STORY-008 P2: additive discoverable entry point.
              const AntiGhostEntryCard(),
              SizedBox(height: CupidSpacing.lg),
              VibeEntryCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const VibeScreen()),
                ),
              ),
              SizedBox(height: CupidSpacing.lg),
              _ReminderEntryCard(
                key: const Key('home_reminder_entry_card'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ReminderScheduleScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
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
