import 'package:flutter/material.dart';

/// Predefined color constants and palettes for vector Emoji Stickers and Emoji Store.
class EmojiPalette {
  const EmojiPalette._();

  // Cat Palette
  static const Color catFur = Color(0xFFFFF9F5);
  static const Color catEarInner = Color(0xFFFFD9C0);
  static const Color catLine = Color(0xFF533B30);
  static const Color catBlush = Color(0xFFFF8FA3);
  static const Color catNose = Color(0xFFFFB3C1);
  static const Color catEye = Color(0xFF3B2820);

  // Dino Palette
  static const Color dinoSkin = Color(0xFF81C784);
  static const Color dinoBelly = Color(0xFFC8E6C9);
  static const Color dinoSpines = Color(0xFFFFB74D);
  static const Color dinoLine = Color(0xFF2E5E35);
  static const Color dinoBlush = Color(0xFFFF8A80);
  static const Color dinoEye = Color(0xFF1B3820);

  // Expression Accent Colors
  static const Color accentHeart = Color(0xFFFF3366);
  static const Color accentTear = Color(0xFF64B5F6);
  static const Color accentSweat = Color(0xFF81D4FA);
  static const Color accentMouth = Color(0xFFFF5252);
  static const Color accentSunglasses = Color(0xFF212121);
  static const Color accentZzz = Color(0xFF7E57C2);
  static const Color accentPartyHat = Color(0xFFFFCA28);
  static const Color accentPartyPompom = Color(0xFFFF4081);
  static const Color accentGiftRibbon = Color(0xFFFFEB3B);
  static const Color accentFire = Color(0xFFFF7043);
  static const Color accentAnger = Color(0xFFFF1744);
  static const Color accentDark = Color(0xFF1B1B1B);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color pureBlack = Color(0xFF000000);
  static const Color black10 = Color(0x1A000000);
  static const Color textDark = Color(0xFF2E1C2B);
  static const Color textMutedDark = Color(0xFF5A4052);

  // Banner Gradients
  static const List<Color> mochiCatBanner = <Color>[
    Color(0xFFFFF0F5),
    Color(0xFFFFD1DC),
    Color(0xFFFF9AA2),
  ];

  static const List<Color> babyDinoBanner = <Color>[
    Color(0xFFE8F5E9),
    Color(0xFFC8E6C9),
    Color(0xFF81C784),
  ];

  static Color parseHex(String hexCode) {
    try {
      final clean = hexCode.replaceAll('#', '').trim();
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      } else if (clean.length == 8) {
        return Color(int.parse(clean, radix: 16));
      }
      return const Color(0xFFFF9AA2);
    } catch (_) {
      return const Color(0xFFFF9AA2);
    }
  }
}
