import 'package:flutter/painting.dart' show Color;

/// Fixed illustration-art palette for the `VibeMoodFace` vector widget
/// (`cupid-app-design-system/project/Mood Face.dc.html`). These are literal
/// design-source colors for one hand-illustrated component rather than
/// theme-varying tokens — the drawn face looks identical in light and dark —
/// so they are named constants here instead of inline literals inside
/// `lib/features` (`architecture/solution.md` D3/ADR-004 no-fork guard
/// forbids a raw color literal outside `design_system/`).
///
/// Same additive, single-consumer shape as [BunSpritePalette]
/// (`bun_sprite_palette.dart`); deliberately not re-exported from
/// `design_system.dart` so no existing shared file changes.
abstract final class MoodFacePalette {
  // happy — `mfA`
  static const Color happyFaceTop = Color(0xFFFFE9A8);
  static const Color happyFaceBottom = Color(0xFFFFC46B);
  static const Color happyInk = Color(0xFF5A3A1F);
  static const Color happyBlush = Color(0xFFFF7A9E);
  static const Color happySparkle = Color(0xFFFFF3C4);

  // soft — `mfB`
  static const Color softFaceTop = Color(0xFFFFC2DC);
  static const Color softFaceBottom = Color(0xFFFF7FB6);
  static const Color softInk = Color(0xFFC62F63);
  static const Color softBlush = Color(0xFFE03C7A);
  static const Color softHeart = Color(0xFFFFB1D3);

  // sad — `mfC`
  static const Color sadFaceTop = Color(0xFFDCC9FF);
  static const Color sadFaceBottom = Color(0xFFAE8CE8);
  static const Color sadInk = Color(0xFF3D2760);
  static const Color sadTear = Color(0xFF8FD8F0);

  // angry — `mfD`
  static const Color angryFaceTop = Color(0xFFFFB39B);
  static const Color angryFaceBottom = Color(0xFFF4735F);
  static const Color angryInk = Color(0xFF61251C);
  static const Color angrySteam = Color(0xFFFFE0D6);

  // tired — `mfE`
  static const Color tiredFaceTop = Color(0xFFC9D6F5);
  static const Color tiredFaceBottom = Color(0xFF94A6D8);
  static const Color tiredInk = Color(0xFF2E3A5E);
  static const Color tiredBlush = Color(0xFF7C8DBF);
  static const Color tiredSleepMark = Color(0xFFEEF3FF);

  // spicy — `mfF`
  static const Color spicyFaceTop = Color(0xFFFFD3C4);
  static const Color spicyFaceBottom = Color(0xFFFF9FAE);
  static const Color spicyInk = Color(0xFF6B2438);
  static const Color spicyBlush = Color(0xFFFF5C7A);
  static const Color spicySteam = Color(0xFFFFF0EA);

  // none — the dashed "no check-in yet" outline.
  static const Color noneOutline = Color(0xFFB4A6CE);

  /// Shared eye highlight, hardcoded `#FFFFFF` in every face's SVG.
  static const Color eyeHighlight = Color(0xFFFFFFFF);
}
