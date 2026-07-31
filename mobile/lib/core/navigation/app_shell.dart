import 'package:flutter/material.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/reminders/presentation/reminder_overlay_host.dart';

/// Root navigation shell. Feature routes are added here as they land;
/// v1 boots directly into the placeholder [HomeScreen].
///
/// STORY-009 P4: [ReminderOverlayHost] is mounted exactly once here so the
/// Synced Reminder firing overlay can render above whatever screen is
/// active, per `ux/uiux-spec.md` §3.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const ReminderOverlayHost(child: HomeScreen());
  }
}
