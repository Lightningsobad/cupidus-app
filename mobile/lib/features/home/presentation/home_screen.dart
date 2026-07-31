import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar_repository.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/screens/dream_jar_list_screen.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/widgets/dream_jar_entry_card.dart';
import 'package:flutter/material.dart';

/// Bootable placeholder screen for the Runnable Project Foundation gate.
/// Replaced by real feature routing once F1-F6 foundation stories land.
///
/// STORY-014 P5 mounts the Dream Jar entry card here as the feature's sole
/// discoverable navigation edge (`ux/uiux-spec.md` entry-point paragraph
/// before §1.1) — no bottom nav bar or router package is introduced.
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
            child: DreamJarEntryCard(
              key: const Key('home_dream_jar_entry_card'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DreamJarListScreen(
                    repository: getIt<DreamJarRepository>(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
