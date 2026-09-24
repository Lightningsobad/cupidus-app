/// The zodiac shell's whole contact surface with the rest of the app
/// (`architecture/contract-summary.md` §3).
///
/// The activity hub reaches screen (7) through this file and nothing else.
/// Deliberately absent: the cubit, the resolver, the rotation store, the
/// content packs and every internal widget, plus anything that would let a
/// caller read an outcome without the screen — a headless "cung của bạn hôm
/// nay" helper here is how a reading surfaces outside the one place the user
/// asked for it, which is exactly what AC-20 rules out.
library;

import 'package:flutter/material.dart';

import 'presentation/screens/zodiac_shell_screen.dart';

/// Pushes "Cung & trắc nghiệm", full-screen and on its own route
/// (`ux/uiux-spec.md` §1: a destination with a back button, not a sheet).
///
/// Open to every session unconditionally: no location check (R-13 is not this
/// story's), no paid-tier check (R-14), no onboarding-progress check. A round
/// is playable the moment the cell is visible (AC-2).
///
/// The screen builds the round's cubit itself, off its own shipped-pack,
/// rotation-cursor and card-store defaults, so nothing has to be registered or
/// passed in from the hub.
Future<void> openZodiacShellScreen(BuildContext context) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (BuildContext _) => const ZodiacShellScreen(),
    ),
  );
}
