import 'package:flutter/widgets.dart';

import '../../domain/vibe_mood.dart';
import '../vibe_strings.dart';

/// The mood glyph reused by the grid, partner card and history strip
/// (`ux/uiux-spec.md` §3, §5, §6 — design source's `Mood Face` component).
/// Renders the `none`/waiting state for `null` (no check-in yet, or the
/// UX §7 partner-unpair defensive fallback).
///
/// Always exposes [mood]'s label as its accessible name (UX §8: never the
/// emoji glyph alone). Composite callers that build their own combined
/// semantics (for example the selectable grid cell) should wrap this widget
/// in `ExcludeSemantics` to avoid a duplicate announcement.
class VibeMoodFace extends StatelessWidget {
  const VibeMoodFace({super.key, required this.mood, this.size = 36});

  final VibeMood? mood;
  final double size;

  static const Map<VibeMood, String> _emoji = <VibeMood, String>{
    VibeMood.happy: '😊',
    VibeMood.sad: '🥺',
    VibeMood.angry: '😤',
    VibeMood.horny: '😳',
    VibeMood.tired: '😴',
  };

  /// The "no check-in yet" glyph; there is no frozen [VibeMood] value for
  /// this state (R-010-5 is about unknown *server* values, not the absence
  /// of one).
  static const String _noneEmoji = '😶';

  @override
  Widget build(BuildContext context) {
    final VibeMood? mood = this.mood;
    final String label = mood == null
        ? context.waitingLabel
        : context.moodLabel(mood);

    return Semantics(
      label: label,
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            mood == null ? _noneEmoji : _emoji[mood]!,
            style: TextStyle(fontSize: size * 0.72),
          ),
        ),
      ),
    );
  }
}
