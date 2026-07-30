import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../../anti_ghosting/anti_ghosting.dart';

/// Bootable placeholder screen for the Runnable Project Foundation gate.
/// Replaced by real feature routing once F1-F6 foundation stories land.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cupid')),
      // STORY-008 P2: additive discoverable entry point. The pre-existing
      // readiness `Center`/`Text` below is left exactly as it was.
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(CupidSpacing.md),
            child: const AntiGhostEntryCard(),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Cupid mobile scaffold is running.',
                key: Key('home_screen_ready_signal'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
