import 'package:flutter/material.dart';

import 'pet_screen.dart';

/// Single navigation entry point into [PetScreen] (`coding-plan/
/// phase-P8-entry-point.md` §3: "a single named-route/`MaterialPageRoute`
/// helper so `HomeScreen` and future surfaces push `PetScreen` the same
/// way"). There is no direct-URL-only access path — [PetPreviewCard] is the
/// only discoverable surface that calls [push].
class PetRoute {
  const PetRoute._();

  static const String name = '/pet';

  static Route<void> route() {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: name),
      builder: (_) => const PetScreen(),
    );
  }

  static Future<void> push(BuildContext context) {
    return Navigator.of(context).push(route());
  }
}
