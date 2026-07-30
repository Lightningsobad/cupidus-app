import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../vibes/presentation/vibe_screen.dart';
import '../../vibes/presentation/widgets/vibe_entry_card.dart';

/// Bootable placeholder screen for the Runnable Project Foundation gate.
/// Replaced by real feature routing once F1-F6 foundation stories land.
///
/// Mounts [VibeEntryCard] as the discoverable entry point to the `vibe`
/// screen (`architecture/solution.md` §4 D-010-5); v1 passes no mood
/// snapshot so no duplicate fetch happens ahead of `VibeScreen`'s own load.
/// Additive only — no `AppShell`/tab-bar restructure (out of this phase's
/// scope).
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
              VibeEntryCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const VibeScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
