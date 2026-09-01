import 'package:flutter/painting.dart' show Color;

/// Fixed illustration-art palette for the companion pet vector widgets
/// (`BunSprite` / `PetSprite`), supporting all 6 companions:
/// - Bún (Cat)
/// - Bơ (Shiba / Dog)
/// - Sữa (Bunny)
/// - Mochi (Bear)
/// - Xoài (Chick)
/// - Kem (Panda)
///
/// These are literal design-source colors for illustrated characters rather
/// than theme-varying tokens, so they are named constants here instead of
/// inline literals inside `lib/features` (`architecture/solution.md`
/// D3/ADR-004 no-fork guard forbids a raw color literal outside
/// `design_system/`).
abstract final class BunSpritePalette {
  // =========================================================================
  // SHARED BASE & ACCENT TONES
  // =========================================================================
  static const Color highlightWhite = Color(0xFFFFFFFF);
  static const Color darkFace = Color(0xFF4A2E52);
  static const Color blushPink = Color(0xFFFF8FB8);
  static const Color nosePinkDefault = Color(0xFFF08BA8);
  static const Color heart = Color(0xFFFF5C97);
  static const Color inloveBlush = Color(0xFFFF8FB8);
  static const Color inloveMouth = Color(0xFFE8558F);
  static const Color inloveHeartSmall = Color(0xFFFFB1D3);
  static const Color sparkleYellow = Color(0xFFFFE9A8);
  static const Color sulkCloud = Color(0xFFB4A6CE);
  static const Color sulkRain = Color(0xFF8FE6D3);
  static const Color sulkNose = Color(0xFFE39BB0);
  static const Color sickBlush = Color(0xFFB0A2C6);
  static const Color sickSweatDrop = Color(0xFF8FD8F0);
  static const Color sickNose = Color(0xFFD49AAB);

  // =========================================================================
  // 1. BUN (CAT)
  // =========================================================================
  static const Color furTop = Color(0xFFFFFBFF);
  static const Color furBottom = Color(0xFFDCD0F5);
  static const Color tail = Color(0xFFF0E6FF);
  static const Color earOuter = Color(0xFFF2EAFF);
  static const Color earInner = Color(0xFFFFB6CE);
  static const Color belly = Color(0xFFFFFCFF);
  static const Color feet = Color(0xFFEFE6FF);

  static const Color sickFurTop = Color(0xFFF8F5FA);
  static const Color sickFurBottom = Color(0xFFCFC6DE);
  static const Color sickTail = Color(0xFFE4DCEF);
  static const Color sickEarOuter = Color(0xFFE7E1F0);
  static const Color sickEarInner = Color(0xFFE9B4C6);
  static const Color sickBelly = Color(0xFFFBF9FD);
  static const Color sickFeet = Color(0xFFE4DCEF);

  // =========================================================================
  // 2. BO (SHIBA / DOG)
  // =========================================================================
  static const Color boFurTop = Color(0xFFFFF6E6);
  static const Color boFurBottom = Color(0xFFFFCE8C);
  static const Color boTail = Color(0xFFF5C078);
  static const Color boEar = Color(0xFFEFB973);
  static const Color boPatch = Color(0xFFF3C78C);
  static const Color boMuzzle = Color(0xFFFFF8EC);
  static const Color boFeet = Color(0xFFFFE2B8);
  static const Color boTongue = Color(0xFFFF7FA8);
  static const Color boDarkFace = Color(0xFF4A3320);
  static const Color boNose = Color(0xFF5A3D28);
  static const Color boSulkNose = Color(0xFF6B5040);

  static const Color boSickFurTop = Color(0xFFFAF3E8);
  static const Color boSickFurBottom = Color(0xFFE8C69C);
  static const Color boSickTail = Color(0xFFDEB893);
  static const Color boSickEar = Color(0xFFDFB48E);
  static const Color boSickPatch = Color(0xFFE4C2A0);
  static const Color boSickMuzzle = Color(0xFFFBF5EC);
  static const Color boSickFeet = Color(0xFFEFD8BE);
  static const Color boSickNose = Color(0xFF8A6E56);

  // =========================================================================
  // 3. SUA (BUNNY)
  // =========================================================================
  static const Color suaToothLine = Color(0xFFE4D6F0);
  static const Color suaSickNose = Color(0xFFD49AAB);

  // =========================================================================
  // 4. MOCHI (BEAR)
  // =========================================================================
  static const Color mochiFurTop = Color(0xFFF7DFC6);
  static const Color mochiFurBottom = Color(0xFFC9986F);
  static const Color mochiTail = Color(0xFFD9A87E);
  static const Color mochiEarOuter = Color(0xFFDDAF85);
  static const Color mochiEarInner = Color(0xFFE8B7A6);
  static const Color mochiMuzzle = Color(0xFFFFF3E4);
  static const Color mochiFeet = Color(0xFFE8C4A0);
  static const Color mochiInloveMouth = Color(0xFFC4553F);

  static const Color mochiSickFurTop = Color(0xFFEFDDD0);
  static const Color mochiSickFurBottom = Color(0xFFB79880);
  static const Color mochiSickTail = Color(0xFFC4A38C);
  static const Color mochiSickEarOuter = Color(0xFFCBAC96);
  static const Color mochiSickEarInner = Color(0xFFD6AFA6);
  static const Color mochiSickMuzzle = Color(0xFFF8F0E9);
  static const Color mochiSickFeet = Color(0xFFDCC4B4);

  // =========================================================================
  // 5. XOAI (CHICK)
  // =========================================================================
  static const Color xoaiFurTop = Color(0xFFFFF0B8);
  static const Color xoaiFurBottom = Color(0xFFFFC53D);
  static const Color xoaiCrest = Color(0xFFFFD75E);
  static const Color xoaiWing = Color(0xFFFFD75E);
  static const Color xoaiFeet = Color(0xFFFF9A3D);
  static const Color xoaiBeak = Color(0xFFFF9A3D);
  static const Color xoaiSulkBeak = Color(0xFFE0842F);
  static const Color xoaiDarkFace = Color(0xFF6B4A12);
  static const Color xoaiHeart = Color(0xFFE8437C);
  static const Color xoaiSparkleYellow = Color(0xFFFFF3C4);

  static const Color xoaiSickFurTop = Color(0xFFF5EBCC);
  static const Color xoaiSickFurBottom = Color(0xFFE0B96B);
  static const Color xoaiSickCrest = Color(0xFFE7C777);
  static const Color xoaiSickWing = Color(0xFFE7C777);
  static const Color xoaiSickFeet = Color(0xFFDE9A5E);
  static const Color xoaiSickBeak = Color(0xFFD08A48);

  // =========================================================================
  // 6. KEM (PANDA)
  // =========================================================================
  static const Color kemFurTop = Color(0xFFFFFFFF);
  static const Color kemFurBottom = Color(0xFFE6E4EF);
  static const Color kemDarkPatch = Color(0xFF3A3346);
  static const Color kemEyePupil = Color(0xFF2A2434);
  static const Color kemSparkleMint = Color(0xFFA8F0DF);
  static const Color kemSulkNose = Color(0xFF4C4458);

  static const Color kemSickFurTop = Color(0xFFF7F6FA);
  static const Color kemSickFurBottom = Color(0xFFD5D2E0);
  static const Color kemSickDarkPatch = Color(0xFF4E4859);
  static const Color kemSickNose = Color(0xFF6B6478);
}

typedef PetSpritePalette = BunSpritePalette;
