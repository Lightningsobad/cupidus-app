import 'package:flutter/widgets.dart';

/// One row in `main_preview.dart`'s screen registry (STORY-018 P6 DEC-4).
///
/// [wrapInShell] opts a screen into the real `AppShell`/`CupidTabBar` chrome
/// per DEC-4's rule (it is an `AppShell` tab destination, or its P5 design
/// reference visibly shows the bottom tab bar) — P8 sets this per screen
/// after reading the P5 reference for the screens it wires.
/// [seedNote] records what backend state (DEC-3/P7) the screen needs to
/// render meaningfully; `null` until P7 seeds it and P8 fills this in.
@immutable
class PreviewScreenEntry {
  const PreviewScreenEntry({
    required this.builder,
    this.wrapInShell = false,
    this.seedNote,
  });

  final WidgetBuilder builder;
  final bool wrapInShell;
  final String? seedNote;
}
