/// The gift flow's whole contact surface with the rest of the app
/// (`architecture/contract-summary.md` §3).
///
/// The activity hub reaches screen (5) through this file and nothing else.
/// Deliberately absent: the repository, the selector, the cubit and every
/// internal widget, plus anything that would let a caller read or rank
/// suggestions without the screen — a headless "top gift for you" helper here
/// is how a suggestion surfaces outside the one place the user asked for it.
library;

import 'package:flutter/material.dart';

import 'presentation/screens/gift_ideas_screen.dart';

export 'presentation/screens/gift_ideas_screen.dart'
    show GiftIdeasScreen, giftIdeasEntryPointId;

/// Pushes "Gợi ý quà", full-screen and on its own route.
///
/// Its own route rather than a tab of the hub: the hub keeps its five status
/// panes and gains no sixth surface, and a chosen idea comes back to the hub as
/// an ordinary card (SC-1'/AC-22).
Future<void> openGiftIdeasScreen(BuildContext context) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (BuildContext _) => const GiftIdeasScreen(),
    ),
  );
}
