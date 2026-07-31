import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../pet/presentation/widgets/pet_preview_card.dart';

/// Bootable placeholder screen for the Runnable Project Foundation gate.
/// Replaced by real feature routing once F1-F6 foundation stories land.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cupid')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Cupid mobile scaffold is running.',
                key: Key('home_screen_ready_signal'),
              ),
              SizedBox(height: CupidSpacing.lg),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: CupidSpacing.lg),
                child: PetPreviewCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
