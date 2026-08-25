# Test Results — STORY-003 Pet Preview Card Design Fidelity

Phase: P1 (pet preview card fidelity and fixture)
Lane: mobile
Runtime: `mobile-app` (`data/devops/system/runtime-command-registry.json`)
Worktree: `.ai-team-worktrees/cupid-apps/story-REQ-010_home_dashboard_deferred_scope_completion-STORY-003`
Date: 2026-08-25

Result: PASS

## Commands and counts

| # | Command | Result |
|---|---|---|
| 1 | `flutter analyze lib/features/pet/presentation/widgets/pet_preview_card.dart lib/features/home/presentation/home_screen.dart lib/main_preview.dart` | PASS — `No issues found! (ran in 2.8s)` |
| 2 | `flutter test test/features/pet/presentation/widgets/pet_preview_card_design_fidelity_test.dart test/features/home/home_screen_test.dart` | PASS — `+32: All tests passed!` (22 new fidelity + 10 home) |
| 3 | `flutter test test/features/pet/ test/features/home/` | PASS — `+142: All tests passed!` |
| 4 | `flutter build apk --debug` (registry `buildCommand`) | PASS — `✓ Built build/app/outputs/flutter-apk/app-local-debug.apk` |
| 5 | Preview build for capture: `flutter build apk --debug --flavor local -t lib/main_preview.dart --dart-define=PREVIEW=home --dart-define=PREVIEW_HOME_FIXTURE=true --dart-define=PREVIEW_PET_FIXTURE=true` | PASS — `✓ Built .../app-local-debug.apk` |
| 6 | `capture-mobile-screen.sh --label=home-android --device=emulator-5554` | PASS — `MOBILE_CAPTURE: OK .../implemented-home-android-emulator-5554.png 405x900 174214` |

All commands were run in this session, inside the story worktree, with
`PATH="$HOME/flutter/bin:$PATH"` (Flutter is not on the default shell PATH).

## Approved Write Scope extension — `pet_entry_point_test.dart`

Command 3 first reported `+141 -1`. The single failure was
`test/features/pet/presentation/pet_entry_point_test.dart:79`:

```
expect(find.text('Lv.4 · Happy'), findsOneWidget);

Expected: exactly one matching candidate
  Actual: _TextWidgetFinder:<Found 0 widgets with text "Lv.4 · Happy": []>
```

That failure was mandated by this phase's own scope, not caused by a defect.
Phase §3 task 3 and `../ux/uiux-spec.md` §3 item 3 require the level chip to
read `'Lv.${status.pet.level}'` ONLY — the design source's chip is a bare
`Lv.3` with no mood suffix, and the mood now reaches the card exclusively
through the caption line below the name. The combined `Lv.N · Mood` string
cannot exist in any design-conformant build, so line 79 was stale by
construction, and phase §6's "existing `pet_entry_point_test.dart` … stays
green" contradicted phase §3 for that one line.

Scrum Master resolved the contradiction by extending this run's Write Scope to
include the file, approving a one-line fix only (see `scrum_master_note` in
`data/runtime/parallel-runs/RUN-REQ-010_home_dashboard_deferred_scope_completion-STORY-003-mobile-dev.json`).
Applied exactly as approved:

```diff
-        expect(find.text('Lv.4 · Happy'), findsOneWidget);
+        expect(find.text('Lv.4'), findsOneWidget);
```

The mood half of the old assertion is not lost: the caption line is asserted
directly by the new `pet_preview_card_design_fidelity_test.dart`
("the status caption states its own 12px role, not caption 13", and "the chip
reads Lv.N only, with no mood suffix"). Entry-point reachability coverage in
`pet_entry_point_test.dart` is otherwise untouched.

After the fix, command 3 reports `+142: All tests passed!`.

## New coverage added by this phase

`mobile/test/features/pet/presentation/widgets/pet_preview_card_design_fidelity_test.dart`
(22 tests, all passing), grouped against the risk surfaces in
`../architecture/solution.md` section 4:

- **AC1/AC2 §1 ready-state card chrome** (3) — the 130° pink/mint wash built
  from named tokens, the 1px `colorLine` border at `radiusCard`, and the
  `ClipRRect` that stops the glow bleeding past the corner.
- **AC1/AC2 §2 decorative glow circle** (2) — 74x74, `BoxShape.circle`, white
  `alpha 66` → `alpha 0` at `stops: [0.0, 0.7]`; anchored at `top: -14` and
  12% of the *card's* width rather than a transcribed pixel value.
- **AC1/AC2 §3 content layout** (6) — Nunito 17/w900 name on `colorText`;
  name and chip on one `TextBaseline.alphabetic` row; sprite centered against
  the text block; chip reads `Lv.N` with no `·` anywhere; chip fill
  `colorAccentPink.withAlpha(56)` at radius 6 with 10px pink Roboto Mono;
  caption states its own 12px role rather than inheriting `caption`'s 13;
  a 120-character name ellipsizes instead of overflowing.
- **AC1/AC2 §3.5 XP bar** (3) — no `LinearProgressIndicator` (it cannot paint
  a gradient), `colorSurface` track, `gradientDream` fill, `widthFactor`
  exactly `levelProgress` (0.62); the bar spans the text column with its left
  edge on the caption's left edge; `widthFactor` collapses to 0.0 at a level
  boundary.
- **§0 the four undepicted states keep their flat chrome** (4) —
  `PetLoading`, `PetLocked`, `PetNoPet`, `PetFailure` each still render flat
  `colorSurface` with no gradient, border, or glow.
- **AC4 the tap contract survives the shell split** (3) — the ready card
  reaches `PetScreen` even when tapped through the glow, the locked card
  still reaches it, and both shells share one
  `Semantics(button: true, label: 'Mở Bún')`.

`mobile/test/features/home/home_screen_test.dart` gained the group
**"STORY-003: the pet preview fixture seam"** (2 tests): a default
`HomeScreen` passes no repository override (`card.repository` is null, so
production still resolves from the service locator), and an injected
repository reaches the card and renders it ready (`Lv.3` visible).

## Notes on two assertions that were corrected mid-phase

1. `_xpTrack()` first matched two widgets, because `CupidSpacing.sm` is also 8
   and the spacer above the bar has the same height. The finder now also
   requires `widget.child is Stack`, which is what makes it the track.
2. `'spans the full card width…'` originally asserted `cardWidth - 32`. That
   encoded the wrong layout: the design source nests the bar in the
   `flex:1;min-width:0` text column, not full-bleed across the card. The
   rendered capture caught it; the widget and the assertion were both
   corrected. Details in `../visual-fidelity/visual-fidelity-report.md`.

## Visual evidence

`../visual-fidelity/visual-fidelity-report.md` — `VISUAL_FIDELITY: PASS`,
`Design-Screen: home`, with a 17-row per-property comparison against the
design source's `isHome` pet node.
