# Test Results – STORY-011 Bun Pet Đồng Hành (P9 Verification)

## 1. Plan / Phase Hygiene

- `master-plan.md` §5 Phases Overview uses the required table schema. PASS.
- Every phase P1-P9 maps to exactly one canonical `phase-Px-*.md` file
  (`git ls-files coding-plan/`: `phase-P1-pet-contracts.md` ...
  `phase-P9-verification.md`, no duplicates). PASS.

## 2. Static Analysis

- `cd mobile && flutter analyze`: `10992 issues found` overall, but **zero**
  are in `lib/features/pet/**`, `lib/features/home/presentation/home_screen.dart`,
  or any file this story touched. Every reported line is either
  `build/ios/SourcePackages/checkouts/flutterfire/...` (gitignored stale
  Firebase integration-test build cache, confirmed via
  `git check-ignore -v build/ios` → `mobile/.gitignore:33`) or
  `unused_import` warnings in the generated `openapi/cupid_api/lib/src/api/*`
  client. PASS (no new issues).

## 3. Test Suite

- `cd mobile && flutter test` (full suite, required because
  `home_screen.dart` is shared): **212/213 passed.**
- The 1 failure is `test/design_system/no_fork_guard_test.dart` — `AC 4
  no-fork guard`, flagging raw `Colors.` literals in
  `lib/features/pet/presentation/widgets/pet_action_row.dart:67` and
  `pet_reactions_card.dart:81`. Both files are P6 outputs (engagement cards,
  merged and marked `DONE` before P8/P9 started) and are outside P8's and
  P9's Write Scope (`mobile/lib/features/pet/presentation/widgets/pet_preview_card.dart`,
  `pet_route.dart`, `home_screen.dart`, `mobile/test/features/pet/**` only).
  This regression is not introduced by, and cannot be fixed within, P8/P9's
  scope. Recorded here as a **typed BLOCKER for the review gate**, not a P8/P9
  failure:
  - `BLOCKED: no-fork-guard violation in pet_action_row.dart:67 and
    pet_reactions_card.dart:81 (raw `Colors.` literal), owned by P6, requires
    a P6 rework pass before requirement integration review can pass the
    no-fork gate.`
- All 4 new `test/features/pet/presentation/pet_entry_point_test.dart` tests
  pass: ready-variant render, locked-variant render (AC3), tap-navigates
  to `PetScreen`, and the `home_screen_ready_signal` regression assertion.
- No pet test is skipped anywhere in the suite.

## 4. Acceptance Criteria Evidence

| AC | Evidence | Result |
|----|----------|--------|
| AC1 — paired users view the shared pet's current state | `PetRepository.readStatus()` (`mobile/lib/features/pet/data/pet_repository.dart:30`) parses `GET /pets/status` into `PetStatus`; `PetScreen`/`PetHeroCard` (P5) and `PetPreviewCard` (P8) render name, level, mood label, status line, XP, and stats exclusively from that `PetStatus`, never recomputed. `pet_screen_test.dart` and `pet_entry_point_test.dart`'s "ready variant" test assert the rendered text. | PASS |
| AC2 — every pet interaction maps to a real backend capability | `git grep -n "_api.dio\."` in `pet_repository.dart` shows exactly 4 calls: `GET /users/me` (pairing), `GET /pets/status` (read), `PATCH /pets/interact` (Feed/Play, one shared endpoint per D3), `POST /pets/adopt`. No other pet mutation exists anywhere in `lib/features/pet/**`. | PASS |
| AC3 — unpaired users cannot access this feature | `PetCubit.load()` gates on `readPairing()` → `PetLocked` before any pet content renders (P3). Verified independently at both surfaces: `pet_screen_test.dart` — "PetScreen locked state (AC3) renders no adopt CTA and no interact buttons when unpaired"; `pet_entry_point_test.dart` — "renders the compact locked variant with no adopt entry when unpaired (AC3)". Both pass. | PASS |

## 5. Out-Of-Scope Confirmation (`ux/uiux-spec.md` §9)

- `git grep -ni "sleep\|streak\|badge"` under `mobile/lib/features/pet` returns
  only doc-comments explaining why each is *excluded* (`pet_mood.dart:22`,
  `bun_sprite.dart:11`, `pet_reactions_card.dart:13`, `pet_stats_row.dart:9`) —
  none is implemented. PASS.
- No per-species sprite art: `BunSprite` renders bunny art for all three
  species per the P4/P5 design reconciliation note in `story_master.md`. PASS.
- No `pets` endpoint or DTO change anywhere in the diff (confirmed by AC2
  evidence above — 4 calls, all pre-existing contract paths). PASS.

## 6. Freeze / Dependency Checks

- `backend/`: `git diff --stat <merge-base> HEAD -- backend/` is empty. A1
  freeze holds. PASS.
- `mobile/pubspec.yaml`: diff against merge-base shows 3 added lines
  (`socket_io_client`, `firebase_messaging`, `shared_preferences`), but
  `git log -- mobile/pubspec.yaml` attributes all three to prior
  STORY-003/STORY-004 commits, not this story. STORY-011 added no dependency
  and no `assets:` section (only the pre-existing commented-out example at
  lines 81-84). PASS.

## 7. Runtime Readiness Signal

- `Key('home_screen_ready_signal')` still pumps: asserted directly by
  `test/widget_test.dart` (full-suite pass) and by the new regression test in
  `pet_entry_point_test.dart`. PASS.

## 8. Icon Codepoints

- `CupidIcons.lock` (0xe897) and `CupidIcons.pets` (0xe91d), the two glyphs
  P8's compact/locked preview variants use, are documented in
  `mobile/lib/design_system/icons/cupid_icons.dart` as cmap-verified against
  the bundled `MaterialSymbolsRounded-Variable.ttf` (P4 output). PASS.

## 9. Risk Surfaces (`master-plan.md` §3A)

| Risk Surface | Gate | Result |
|---|---|---|
| Untyped `pets` REST parsing | P1/P2 unit tests over stubbed `Dio` | PASS (P1/P2, already DONE) |
| Mood → sprite mapping | P1 unit test, all 5 moods + fallback | PASS (P1, already DONE) |
| Pairing hard gate (AC3) | widget test: locked state, no CTA | PASS — re-verified at P8 surface (§4 above) |
| 5s interaction cooldown | P3 cubit unit test with injected clock | PASS (P3, already DONE) |
| Adopt input validation | P7 widget test: CTA gating 1/30/31 | PASS (P7, already DONE) |
| New icon codepoints | cmap read, not guessed | PASS (§8 above) |
| Entry-point reachability | widget test navigating from preview card; readiness key still pumps | PASS (§3, §7 above) |

## 10. Summary

- `flutter analyze`: no new issues (10992 pre-existing/out-of-scope; 0 in
  story-owned files).
- `flutter test`: 212/213 passed; the 1 failure is a P6-owned no-fork-guard
  violation outside P8/P9 Write Scope, recorded as a typed BLOCKER for the
  review gate to route back to a P6 rework pass.
- AC1, AC2, AC3: all PASS with recorded evidence.
- All risk surfaces: PASS or already gated in an earlier DONE phase.
- A1 freeze and §9 out-of-scope list: confirmed by search evidence.

Last updated: 2026-07-31.
