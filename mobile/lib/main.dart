import 'package:flutter/material.dart';

import 'core/navigation/app_shell.dart';
import 'design_system/theme/app_theme.dart';

void main() {
  runApp(const CupidApp());
}

class CupidApp extends StatelessWidget {
  const CupidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cupid',
      theme: AppTheme.light,
      home: const AppShell(),
    );
  }
}
