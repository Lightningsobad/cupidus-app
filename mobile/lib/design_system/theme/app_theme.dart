import 'package:flutter/material.dart';

/// Placeholder app theme. Platform x theme tokens and the adaptive
/// [ThemeExtension] set (ADR-004) land in the `design_system` foundation
/// story (F1); this scaffold only wires a minimal seed theme so the app
/// boots with Material 3 defaults.
class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
      );
}
