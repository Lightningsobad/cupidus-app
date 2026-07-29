import 'package:flutter/material.dart';

import '../../features/home/presentation/home_screen.dart';

/// Root navigation shell. Feature routes are added here as they land;
/// v1 boots directly into the placeholder [HomeScreen].
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
