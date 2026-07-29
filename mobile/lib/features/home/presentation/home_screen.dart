import 'package:flutter/material.dart';

/// Bootable placeholder screen for the Runnable Project Foundation gate.
/// Replaced by real feature routing once F1-F6 foundation stories land.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cupid')),
      body: const Center(
        child: Text(
          'Cupid mobile scaffold is running.',
          key: Key('home_screen_ready_signal'),
        ),
      ),
    );
  }
}
