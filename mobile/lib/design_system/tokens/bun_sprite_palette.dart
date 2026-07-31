import 'package:flutter/painting.dart' show Color;

/// Fixed illustration-art palette for the `BunSprite` vector widget
/// (`cupid-mobile-design/Bun Pet Art.dc.html` "Bảng màu của Bún"). These are
/// literal design-source colors for one hand-illustrated character rather
/// than theme-varying tokens, so they are named constants here instead of
/// inline literals inside `lib/features` (`architecture/solution.md`
/// D3/ADR-004 no-fork guard forbids a raw color literal outside
/// `design_system/`).
abstract final class BunSpritePalette {
  // Standard body palette — happy/inlove/neutral/sulk share one body.
  static const Color furTop = Color(0xFFFFF3E9);
  static const Color furBottom = Color(0xFFFFCFB2);
  static const Color tail = Color(0xFFF9C6A8);
  static const Color earOuter = Color(0xFFFFE7D6);
  static const Color earInner = Color(0xFFFFB6CE);
  static const Color belly = Color(0xFFFFF8F1);
  static const Color feet = Color(0xFFFFDFC8);

  // Sick-state paler body palette.
  static const Color sickFurTop = Color(0xFFFBF0EA);
  static const Color sickFurBottom = Color(0xFFEFCDBE);
  static const Color sickTail = Color(0xFFE9C0AC);
  static const Color sickEarOuter = Color(0xFFF5E0D6);
  static const Color sickEarInner = Color(0xFFE9B4C6);
  static const Color sickBelly = Color(0xFFFDF6F2);
  static const Color sickFeet = Color(0xFFF2D8C8);

  // Shared face tones.
  static const Color darkFace = Color(0xFF4A2E52);
  static const Color nosePinkDefault = Color(0xFFF08BA8);
  static const Color blushPink = Color(0xFFFF8FB8);
  static const Color highlightWhite = Color(0xFFFFFFFF);

  // Inlove-state accents.
  static const Color heart = Color(0xFFFF5C97);
  static const Color inloveBlush = Color(0xFFFF6FA0);
  static const Color inloveMouth = Color(0xFFE8558F);

  // Sulk-state accents.
  static const Color sulkNose = Color(0xFFE39BB0);
  static const Color sulkCloud = Color(0xFFB4A6CE);
  static const Color sulkRain = Color(0xFF8FE6D3);

  // Sick-state accents.
  static const Color sickNose = Color(0xFFD49AAB);
  static const Color sickBlush = Color(0xFFB0A2C6);
  static const Color sickSweatDrop = Color(0xFF8FD8F0);
}
