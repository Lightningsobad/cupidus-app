import 'package:flutter/material.dart';

/// Chat header presence-chip avatar fill, transcribed from the locked design
/// source (`cupid-app-design-system/project/Cupid Screens.dc.html`,
/// `showPartnerChip` node: `linear-gradient(135deg,#00C9A7,#7B2FBE)`).
///
/// This stop pair exists in no current token: it matches neither
/// `CupidColorTokens.colorMint`/`.colorGreen` nor either pair in
/// `CouplePresencePalette`/`CoupleAvatarGradients`. `#7B2FBE` does appear as
/// `CupidColorTokens.gradientBrandBackdrop`'s first stop, but that token's own
/// dartdoc scopes it to backdrops only. So — mirroring the
/// `couple_presence_palette.dart` / `pet_hero_gradient.dart` precedent — it is
/// declared here as an additive, non-shared token rather than inlined in
/// `lib/features` (ADR-004 / `test/design_system/no_fork_guard_test.dart`) or
/// folded into `CupidColorTokens`.
abstract final class PartnerChipPalette {
  /// CSS `135deg` under the same vector convention
  /// `couple_presence_palette.dart:20-27` derives:
  /// `sin(135deg) = 0.7071067811865476`, `cos(135deg) = -0.7071067811865476`.
  static const LinearGradient avatarGradient = LinearGradient(
    begin: Alignment(-0.7071067811865476, -0.7071067811865476),
    end: Alignment(0.7071067811865476, 0.7071067811865476),
    colors: <Color>[Color(0xFF00C9A7), Color(0xFF7B2FBE)],
  );
}
