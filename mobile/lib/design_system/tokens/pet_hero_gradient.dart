import 'package:flutter/material.dart';

/// The `pet` tab hero-card gradient (`ux/uiux-spec.md` §2.1 item 1:
/// `#7B4FBE → #B0518C → #5E7E96`). Neither `CupidColorTokens.gradientDream`
/// nor `.gradientHot` matches this exact stop set, and adding a new
/// shared/reusable color token for a single feature's hero card is out of
/// scope (STORY-001 owns the shared token layer). This value cannot live in
/// `lib/features/pet/presentation/widgets/pet_hero_card.dart` itself without
/// tripping `test/design_system/no_fork_guard_test.dart` (D3/ADR-004 forbids
/// a raw color literal in `lib/features`), so — mirroring the
/// `bun_sprite_palette.dart` precedent (`coding-plan/phase-P4-bun-sprite.md`
/// Write Scope deviation) — it is declared here as an additive,
/// non-shared design-system token consumed only by `PetHeroCard`.
///
/// Alignment vectors are derived the same way `cupid_color_tokens.dart`
/// derives its 120deg vectors, but for this gradient's own `178deg` angle
/// (`sin(178deg)`/`cos(178deg)`) — a near-vertical top-to-bottom sweep, not
/// the shared diagonal.
abstract final class PetHeroGradient {
  static const Alignment _begin = Alignment(-0.03489949670250097, -0.9993908270190958);
  static const Alignment _end = Alignment(0.03489949670250097, 0.9993908270190958);

  static const LinearGradient gradient = LinearGradient(
    begin: _begin,
    end: _end,
    colors: <Color>[Color(0xFF7B4FBE), Color(0xFFB0518C), Color(0xFF5E7E96)],
    stops: <double>[0.0, 0.52, 1.0],
  );
}
