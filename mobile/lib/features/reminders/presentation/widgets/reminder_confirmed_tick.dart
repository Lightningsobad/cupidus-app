import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

/// Glyph size for the trailing tick, matching the caption text it follows
/// (design source `Cupid Screens.dc.html` lines 512/1664).
const double _tickSize = 13;

/// The trailing tick on a confirmed/awake state label.
///
/// The design source writes it as a literal U+2713, but Nunito has no glyph for
/// that codepoint and the app declares no fallback family, so a raw `✓` renders
/// as a missing-glyph box in a capture and on any device without a system
/// fallback. [CupidIcons.check] comes from the bundled Material Symbols Rounded
/// font, so the tick is guaranteed present.
///
/// Rendered through an [InlineSpan] rather than as a sibling `Row` child so the
/// label keeps wrapping normally and the tick stays glued to its last word.
class ReminderConfirmedTick extends StatelessWidget {
  const ReminderConfirmedTick({super.key, required this.color});

  final Color color;

  static InlineSpan span(Color color) => WidgetSpan(
    alignment: PlaceholderAlignment.middle,
    child: ReminderConfirmedTick(color: color),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 3),
      child: Icon(CupidIcons.check, size: _tickSize, color: color),
    );
  }
}
