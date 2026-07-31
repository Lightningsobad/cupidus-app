# STORY-011 Slice Review — Slice B: P3-P9 (state, sprite, screen, engagement, adopt, entry point, verification)

- Reviewer: Iris-QC (reviewer)
- Scope: P3 (`pet_cubit.dart`, `pet_state.dart`, `adopt_cubit.dart`, `adopt_state.dart` +
  tests), P4 (`bun_sprite.dart`, `cupid_icons.dart` additions, `bun_sprite_palette.dart` +
  test), P5 (`pet_screen.dart`, `pet_hero_card.dart`, `pet_guard_states.dart` + test), P6
  (`pet_xp_card.dart`, `pet_stats_row.dart`, `pet_action_row.dart`, `pet_reactions_card.dart`
  + test, including the no-fork-guard fix), P7 (`adopt_sheet.dart`, `species_picker.dart` +
  test), P8 (`pet_preview_card.dart`, `pet_route.dart`, `home_screen.dart` + test), P9
  (`coding-plan/test-results.md`).
- Diff baseline: `0a467d03babf1ed4102c3fab09c61b2dec941a0b`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-001_cupid_flutter_mobile_app-STORY-011`
- Not re-reviewed: P1/P2 pet-data-di files, already covered by `review/slice-a.md`
  (Outcome: CLEAN).

## 1. AC1 — paired users can view the shared pet's current state

**PASS.**

- `PetCubit.load()` (`pet_cubit.dart:41-59`) gates on `readPairing()`, then
  `readStatus()`, emitting `PetReady(status, cooldownRemaining)` only from real
  server data — no client-side recomputation of mood/level/happiness anywhere in
  this slice.
- `PetHeroCard` (name, `Lv.{level} · {moodLabel}` pill, status line, 206px
  `BunSprite`), `PetXpCard` (`status.levelProgress` only, no re-derivation),
  `PetStatsRow` (`interactionsTowardNextMilestone` record, never the raw
  English `milestone` string), and `PetPreviewCard`'s `_PreviewReady` (dashboard
  variant, same data mapping, same `PetXpCard`-equivalent progress bar) all read
  exclusively from the `PetStatus` passed down from the cubit.
- `pet_screen_test.dart` asserts rendered name/pill/status-line/sprite-state for
  both `ecstatic` and `sick` moods; `pet_entry_point_test.dart` asserts the same
  for the dashboard preview card. Both pass per `test-results.md`.
- `BunSprite` (`bun_sprite.dart`) renders all 5 allowed `BunSpriteState` values
  (`happy`, `inlove`, `neutral`, `sulk`, `sick`) at all three fixed UX sizes
  (206/74/46); `bun_sprite_test.dart` parametrizes over every state × size
  combination and asserts no exception and correct rendered size. The widget is
  wrapped in `ExcludeSemantics` (decorative per UX §7) with mood conveyed via
  the text pill/status line instead — verified directly by
  `bun_sprite_test.dart`'s "excluded from semantics tree" test and
  `pet_screen_test.dart`'s "mood label as reachable semantics text" test.
- No `sleep` state is declared in `BunSpriteState` or reachable from any mood
  mapping (confirmed in slice-a for P1; this slice's P4/P5/P6 consumers never
  reference a 6th state).

## 2. AC2 — every pet interaction maps to a real backend capability

**PASS.**

- `PetActionRow` (`pet_action_row.dart`): both "Feed" and "Play" buttons call
  the identical `context.read<PetCubit>().interact()` — no separate handler,
  no client-invented distinct effect, matching UX §5 Open Item 1 and
  architecture's "single client-side action handler bound to both buttons."
  `pet_engagement_test.dart` asserts both buttons increment
  `repository.interactCalls` identically.
- `PetCubit.interact()` (`pet_cubit.dart:64-88`) guards against double-taps
  both client-side (`current is! PetReady || cooldownRemaining != null` and an
  `_isInteracting` in-flight flag) and re-arms the cooldown from a `400`
  response rather than surfacing a raw error — covered by
  `pet_cubit_test.dart`'s cooldown-arm/tick-down/400-rearm/no-second-call
  tests, all using an injected clock + manual ticker (no real-time waits).
  `pet_engagement_test.dart`'s "disables both buttons and suppresses taps
  during cooldown" test additionally verifies at the widget layer that no
  network call reaches the repository while disabled, plus the
  `Semantics(enabled: false)` + live-region announcement UX §7 requires.
- `AdoptCubit.submit()` calls only `_repository.adopt(species, name)`
  (`adopt_cubit.dart:30-49`), mapping `400`→`AdoptRejectedNotYet` (attempt-based
  gate, D3 — no client-computed countdown, confirmed by `adopt_sheet.dart`'s
  `_rejectedBody` comment and matching `adopt_cubit_test.dart` test) and
  `409`→`AdoptConflict` with a regex-parsed existing name
  (`_existingNamePattern`), falling back to `null` when unparseable — both
  branches and the null-message edge case are unit-tested.
- `AdoptSheet`/`SpeciesPicker` gate the CTA on `AdoptEditing.isValid` (species
  selected AND trimmed name 1-30 chars); `adopt_sheet_test.dart` widget-tests
  the CTA disabled/enabled boundary at name lengths 1/30/31 and species
  presence, matching `AdoptPetDto`. `SpeciesPicker` exposes each card as
  `Semantics(inMutuallyExclusiveGroup: true, button: true, selected: ...)` — a
  proper radio-group semantic per UX §7, not unlabelled tappable cards.
- No new call to any pet endpoint beyond the four named in
  architecture/solution.md is introduced anywhere in this slice — confirmed by
  reading every widget/cubit file in scope; all mutations route through
  `PetCubit.interact()` or `AdoptCubit.submit()`, both of which call only the
  already-reviewed `PetRepository` methods (slice-a §2).

## 3. AC3 — unpaired users cannot access this feature

**PASS.**

- `PetCubit.load()` emits `PetLocked` before ever calling `readStatus()`
  (`pet_cubit.dart:46-49`) when `!pairing.isPaired`; `interact()` is a no-op
  whenever `state is! PetReady` (`pet_cubit.dart:66`), so an unpaired user
  cannot reach `interact()` even via a stale reference.
- `PetLockedCard` (`pet_guard_states.dart`) renders only a lock icon + headline
  — no CTA, no route into the adopt sheet, matching the `_GuardStateShell`'s
  optional `cta` being omitted for this variant.
- `_PetView` in `pet_screen.dart` switches on `PetState` and only ever builds
  `PetAdoptPromptCard`'s `onAdopt` (which opens the sheet) in the `PetNoPet`
  branch — `PetLocked` never has a path to `showAdoptSheet`.
- `PetPreviewCard`'s compact locked variant (`_PreviewCompact`) likewise shows
  only icon + headline, and its tap target always routes to `PetScreen`
  (`PetRoute.push`), which independently re-derives and enforces the same AC3
  gate — so there is no dashboard-card shortcut that bypasses the gate, and no
  deep-link-only path exists since `PetRoute` is the sole route registration
  point.
- Verified directly by `pet_screen_test.dart` ("renders no adopt CTA and no
  interact buttons when unpaired", asserting absence of `CupidPrimaryButton`
  and both action icons) and `pet_entry_point_test.dart` ("renders the compact
  locked variant with no adopt entry when unpaired (AC3)").

## 4. No-fork-guard fix (P6 rework) correctness

**PASS.**

- Confirmed by direct read of `pet_action_row.dart` and `pet_reactions_card.dart`:
  both now declare `final CupidColorTokens colors = context.cupidColors;` once
  per `build()` and reference `colors.colorTextMuted` thereafter — no raw
  `Colors.` or `Color(0x` literal remains in either file, and the local
  `colors` variable is used (not dead code) in both.
- The no-fork guard (`test/design_system/no_fork_guard_test.dart`) does a plain
  substring scan for `"Colors."` over every `.dart` file under
  `lib/features`/`lib/app`/`lib/core` — confirmed by reading the guard's
  source: it would indeed false-positive on `context.cupidColors.` (the tail
  substring `Colors.` appears inside `cupidColors.`), so the diagnosis recorded
  in `test-results.md` is accurate, and the extract-a-local-variable fix is the
  correct, minimal way to avoid the substring match without changing any
  rendered behavior.
- No other file in this slice trips the same pattern — confirmed no bare
  `context.cupidColors.<field>` inline reference remains anywhere else in the
  P4-P8 diff (all files use the same local-variable pattern already, e.g.
  `pet_hero_card.dart`, `pet_stats_row.dart`, `pet_xp_card.dart`,
  `pet_preview_card.dart`).

## 5. Resolution of slice-a's two carried-over notes

1. **`pet_hero_gradient.dart` duplication check — resolved, not a duplicate.**
   `PetHeroGradient.gradient` (`#7B4FBE → #B0518C → #5E7E96`) is a distinct
   3-stop gradient that does not match `CupidColorTokens.gradientDream` or
   `.gradientHot` (confirmed by reading both the new token file and its own
   dartdoc, which states this explicitly). It is consumed only by
   `PetHeroCard` (`pet_hero_card.dart:30`), not re-declared inline anywhere
   else, and not reused by any other widget in the diff.
   - One nuance worth recording (not a defect): the literal architecture text
     in `architecture/solution.md` §4 Mobile Lane Handoff said to declare this
     gradient as a **private const inside `pet_hero_card.dart`**, not as a new
     design-system token. The implementation deviated from that literal text
     because doing so verbatim would trip `no_fork_guard_test.dart`'s raw
     `Color(0x...)` substring scan (the guard scans `lib/features` for exactly
     that pattern). This deviation is transparently documented in
     `coding-plan/phase-P5-pet-screen.md` §1B ("Deviation (implementation-time,
     additive only)"), mirrors the already-accepted P4
     `bun_sprite_palette.dart` precedent for the identical guard constraint,
     and keeps the token additive/single-consumer rather than a shared
     reusable token. This is a reasonable, disclosed technical necessity, not
     an unreviewed scope drift — no action needed.
2. **`Package.resolved` unrelated-file check — resolved, explained, not a
   story-content risk.** `git log` shows this file was introduced in the same
   commit as `coding-plan/test-results.md` (commit `7b36139`, "complete story
   boundary"), i.e. it landed as a side effect of the local `flutter
   test`/build toolchain run that produced the P9 verification evidence (macOS
   iOS-target dependency resolution, consistent with `test-results.md` §2's
   own note about a gitignored `build/ios/SourcePackages/checkouts/flutterfire`
   cache appearing during the same run). It is a generated Xcode SwiftPM
   lockfile with no hand-authored logic, does not touch `lib/features/pet/**`,
   `home_screen.dart`, or any pet-feature contract, and does not affect any AC,
   the no-fork gate, or `flutter analyze`/`flutter test` results. Non-blocking,
   but flag to Scrum Master: confirm the story-boundary-sealing step should not
   be sweeping incidental local build-tool output into the story commit going
   forward, since it adds unreviewable-by-content diff noise to future slices.

## 6. Test/verification evidence spot-check (P9)

- Directly verified (not just trusted from `test-results.md`): no remaining
  `Color(0x`, `Colors.`, `Platform.is`, or `defaultTargetPlatform` substrings in
  any file this slice covers — read every P3-P8 source file myself and
  confirmed the no-fork-guard fix is complete and localized.
- `pet_cubit_test.dart`, `adopt_cubit_test.dart`, `pet_engagement_test.dart`,
  `bun_sprite_test.dart`, `pet_screen_test.dart`, and `adopt_sheet_test.dart`
  (sampled) all use injected clocks/manual tickers/fakes — no real-time waits,
  no flaky sleep-based assertions, matching the phase risk-surface gates in
  `master-plan.md` §3A.
- `home_screen.dart` diff is a minimal additive change: keeps
  `Key('home_screen_ready_signal')` verbatim, only adds a `SizedBox` +
  `PetPreviewCard` beneath the existing signal text inside the same `Column`.
  `PetPreviewCard.build()` also degrades to `SizedBox.shrink()` when
  `PetRepository` isn't registered (documented as only ever engaging in the
  DI-less `widget_test.dart` smoke test), so the readiness signal cannot be
  starved by a missing registration in production.
- No pub dependency added, no `assets:` section added — confirmed by the
  earlier P1/P2 slice-a check plus no further pubspec touch anywhere in this
  slice's diff (`git diff --stat` shows no `pubspec.yaml` entry for the P3-P9
  file set).

## Summary

| Point | Result |
|---|---|
| AC1 — view shared pet state | PASS |
| AC2 — interactions map to real backend capability | PASS |
| AC3 — unpaired hard gate | PASS |
| No-fork-guard fix correctness | PASS |
| Slice-a note 1 (`pet_hero_gradient.dart` duplication) | Resolved — not a duplicate, deviation documented |
| Slice-a note 2 (`Package.resolved` origin) | Resolved — explained, non-blocking |

**Outcome: CLEAN** for slice-b (P3-P9).

Non-blocking note for Scrum Master: consider tightening the story-boundary
sealing step so incidental local build-tool artifacts (e.g. iOS
`Package.resolved`) aren't swept into story commits alongside evidence docs.

REVIEW_SLICE_COMPLETE: YES
