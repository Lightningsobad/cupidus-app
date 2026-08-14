# Review Report — STORY-027 Design Fidelity: Dream Jar

Outcome: DEFERRED_ONLY

Review type: `compact-story-review` (round 3, verifying round-2 rework)
Scope gate: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-027_dream_jar_design_fidelity/review/scope-gate.md`
Story: STORY-027 — Complexity `trivial`, Story-Class `standard`, Implementation Lane `mobile`
Diff baseline: `cda60734a0f32d2ce9da347d933ca038dc65e08a` → `7382e9e9317a95f89e6a95c5a0b141fb9d45d7c0`
Files reviewed: 8 (3 `mobile/lib`, 3 `mobile/test`, 2 evidence)
Round-1 report: superseded, see git history at `73c6414`.
Round-2 report: superseded by this file, see git history at `cda6073`.

## Rationale

Round 2 raised exactly two blocking findings. Both are genuinely fixed, and both
fixes were verified against the code they depend on rather than against the
implementation lane's claims.

B3 is fixed the way round 2 asked and explicitly not the way round 2 forbade:
the test registers the real store, mirroring the production composition root. No
`isRegistered` fallback was added to production code, so the fix cannot mask
B1/B4.

B4 is fixed with the correct reasoning, not just the correct output. The new
dartdoc's load-bearing claim — that only an explicit sign-in populates
`BackendUserIdStore`, so the `null` window lasts a whole session — was
re-derived independently this round and is accurate. The degraded state follows
the `AntiGhostPendingUnknownRole` precedent: nothing is attributed, nothing is
guessed, and the card stops rendering a confident wrong comparison.

What remains is not rework. The root cause is the app-wide session-restore gap
(R1), which no design-fidelity story can close from the mobile Dream Jar lane.
This round delivers the correct in-lane mitigation and records the limitation
honestly in the evidence, so the story closes with deferred findings rather than
another patch cycle.

## Round-2 action item verification

Each item was verified against code, not against the task list.

| # | Claim | Verified | Result |
| --- | --- | --- | --- |
| A6 | `BackendUserIdStore` registered in `home_screen_test.dart` `setUp` | `home_screen_test.dart:32` calls `getIt.registerLazySingleton<BackendUserIdStore>(BackendUserIdStore.new)` — byte-identical registration form to production at `core/di/service_locator.dart:118`. `tearDown(() => getIt.reset())` at `:35` is unchanged, so no cross-test leakage. The screen resolves it at `dream_jar_list_screen.dart:36`, so the test now exercises the real lookup instead of avoiding it | DONE |
| A7 | `PartnerSplitCard` degrades on `null`, dartdoc corrected, `null` case pinned by test | `PartnerSplitTotals.isAttributed` added (`partner_split_card.dart:14-25`); the `null` branch returns zeroed, unattributed totals before the loop (`:41-47`); `PartnerSplitCard.build` swaps the two-column comparison for a single muted line (`:91-168`). Inverted dartdoc replaced (`:27-36`). New `partner_split_card_test.dart` pins both directions | DONE |
| A8 | `visual-fidelity-report.md` row 17 restated | Row 17 no longer claims an unconditional fix ("only while that id is populated — it is not an unconditional fix; see row 18"); new row 18 records the warm-restart cause and the A7 degradation; header note explains why the existing capture is still valid evidence | DONE |
| A9 | Gate command widened and re-run | Report records `flutter test test/features/dream_jar test/design_system test/features/home` → 123 passing, and the widened `flutter analyze` command | DONE — re-run independently this round, see gates table |

## Blocking findings

None.

### B3 — verified fixed

`home_screen_test.dart:26-33` now registers `DreamJarRepository` and
`BackendUserIdStore` in `setUp`. The registration is the real class via
`BackendUserIdStore.new`, identical to `service_locator.dart:118`, not a stub or
a mock. The test therefore passes because the composition root it bypasses is
now correctly reproduced, not because the failing path was removed: the tap-through
at `:60-63` still mounts `DreamJarListScreen`, which still calls
`getIt<BackendUserIdStore>()` unguarded at `dream_jar_list_screen.dart:36`.

Round 2's explicit anti-pattern was avoided. No `getIt.isRegistered<...>()`
fallback exists anywhere in `mobile/lib/features/dream_jar`.

Side effect worth recording: with a freshly constructed store, that test's
Dream Jar screen now renders the unattributed state. That is the correct
behaviour for a test that never signs in, and it is what makes the fix a real
reproduction of production rather than a green-washing change.

### B4 — verified fixed, with correct reasoning

The mechanism is right. `PartnerSplitTotals.of` returns early for a `null` id
(`partner_split_card.dart:41-47`) with `selfTotal: 0`, `partnerTotal: 0`,
`isAttributed: false`, so no contribution is credited to anyone. `build` branches
on `isAttributed` (`:92-168`): the attributed branch is the round-2 comparison
verbatim (bars, avatars, semantic labels, and the mandatory accessible delta
copy all unchanged); the unattributed branch renders only
`dream_jar_partner_split_unresolved` in the same muted caption style. The
`Container`, gradient, radius, padding and the card heading are outside the
branch, so the card's own design fidelity is untouched in both states.

The reasoning is right. I re-derived the round-2 claim rather than trusting the
new comment: `BackendUserIdStore` holds a plain in-memory field
(`backend_user_id_store.dart:10`), its only writer is
`updateFromLoginResponse`, and the only shipped caller is
`AuthRepository._syncBackendProfile()` (`auth_repository.dart:122, :127`), which
is reached only from the five explicit sign-in/register entry points
(`auth_repository.dart:52, :66, :72, :78, :84`). No startup, token-refresh, or
session-restore path calls it. So the new dartdoc at `partner_split_card.dart:30-36`
is factually correct, and the round-2 inverted reasoning is gone.

The precedent is honoured. `AntiGhostPendingUnknownRole`
(`anti_ghost_cubit.dart:103-110`, selected at `:158-166`) exists because
"mine-vs-partner cannot be derived", and degrades to a read-only summary rather
than guessing. `PartnerSplitTotals.isAttributed` is the same decision expressed
for a totals aggregate: an explicit "not derivable" signal on the model, consumed
by the widget to suppress the comparison. Not byte-identical, correctly analogous.

Blast radius is contained. Every construction of `PartnerSplitTotals` in
`mobile/lib` and `mobile/test` goes through the `.of` factory
(`partner_split_card.dart:93` is the only production call site), so the new
required `isAttributed` field cannot be set inconsistently by a caller.

## Scope check on the supporting changes

| Change | In service of | Verdict |
| --- | --- | --- |
| `app_vi.arb` — `dream_jar_partner_split_unresolved` + `@` metadata | The B4 degraded state needs copy. `app_vi.arb` is the template ARB (`mobile/l10n.yaml:2`), so metadata belongs here | In scope |
| `app_en.arb` — same key, translation only | l10n completeness for a newly added key; `untranslated-messages-file` is configured (`l10n.yaml:7`), so omitting it would leave a reported gap. This is not the dedicated light-theme/`en` visual pass that OQ5 puts out of scope | In scope |
| `contribution_history_cubit_test.dart:246-256` | The old test asserted `partnerTotal == 130000` for a `null` id — it pinned the exact defect B4 removes. Rewritten to assert `isAttributed == false` and both totals `0`; the adjacent empty-list test gains an `isAttributed == true` assertion | In scope, and necessary |
| `partner_split_card_test.dart` (new) | Pins both directions, including the negative assertions that the whole-jar `3,9tr` figure and the "partner is ahead" line are absent, so a revert of B4 fails loudly | In scope |
| `home_screen_test.dart:1-33` | B3 only — one import, one registration, one comment | In scope |
| `visual-fidelity-report.md` | A8 evidence restatement | In scope |

No unrelated production code, no new dependency, no widened public API, no
behaviour change on the attributed path.

## Residual risks

| # | Risk | Disposition |
| --- | --- | --- |
| R1 | `BackendUserIdStore` is never repopulated on session restore, so `backendUserId` is `null` for the whole session after a warm restart. Confirmed again this round: five explicit sign-in call sites are its only shipped writers. The store is also the realtime room-key source (`realtime_coordinator.dart:118`, `socket_transport.dart:108`) and is read by anti-ghosting (`anti_ghost_cubit.dart:159`), so the blast radius is wider than Dream Jar and its realtime impact needs its own diagnosis. | App-wide, pre-existing, not created by this story, and not fixable from the mobile Dream Jar lane. File through `add-bug` at wave close alongside the other REQ-002 cross-story findings. A7 only stops Dream Jar from rendering confidently wrong data because of it. |

## Deferred findings

Round-1 D1-D4 were re-confirmed as correctly deferred and are not re-argued
here. D5 and D6 are new this round.

| # | Finding | Why deferred |
| --- | --- | --- |
| D1 | `_loadContributions()` swallows every error silently. | Deliberate best-effort behaviour for a cosmetic aggregate. |
| D2 | Comparison totals reflect only the loaded contributions page. | Pre-existing backend-aggregate gap. |
| D3 | Capture shows the 3-tab shell bar and shell FAB versus the design's 5 tabs. | App-shell surfaces owned by other REQ-002 stories. |
| D4 | `DreamJarAmountFormat.vnd` dropped the space before `₫` app-wide. | Matches the design source's global `fmt()`. |
| D5 | The unattributed notice is a rendered state that does not exist in the locked design source, which the story's Out of Scope #1 reads against. | Accepted as the least-bad resolution of a real correctness defect: the alternative in the design source's vocabulary is a comparison that credits the user's own money to the partner. It reuses an established in-repo pattern and adds no new interaction or entry point. Recommend Designer sign-off on the copy and treatment when R1 is fixed or during a later fidelity pass; not worth blocking a correctness fix on. |
| D6 | `contribution_history_screen.dart:244` computes `isSelf` as `currentUserId != null && ...`, so when the id is unresolved every history row silently renders the partner variant — the same defect class as B4, on a different screen. | Same R1 root cause. Out of this story's design scope (`Design-Screen: jar`), pre-existing, and not a regression from any round of this story — round 2 improved it for fresh-sign-in sessions and round 3 did not touch it. Fold into the R1 bug so both surfaces are fixed together. |

## Risk surfaces and critical gates

All gates re-run independently this round in the story worktree, unfiltered.

| Surface | Gate | Result |
| --- | --- | --- |
| Mobile interaction | `flutter test test/features/dream_jar test/features/home` | PASS — `All tests passed!`, 90 tests, exit 0. Includes both new `partner_split_card_test.dart` cases and the repaired `home_screen_test.dart`. |
| Regression outside the story's gate scope | `flutter test test/features/home/home_screen_test.dart` | PASS — round-2 B3 red is gone; covered by the run above. |
| Mobile rendering / token usage | `flutter analyze lib/features/dream_jar test/features/dream_jar test/features/home` | PASS — 2 issues, both pre-existing `prefer_initializing_formals` infos in `contribution_history_cubit.dart:70-71`, a file this round did not touch. Nothing new. |
| Full mobile suite | `flutter test` | 1076 passed, 2 failed, both confirmed outside this story's diff: `splash_design_fidelity_test.dart` (compilation error against `splash_screen.dart:33` `resolvePairingStatus`, unrelated file, new cross-story finding) and `reminder_copy_guard_test.dart` (the known REQ-002 Cross-Story Finding 11 guard-red owned by sibling scope). Neither is caused by round 3. |
| Mobile navigation / discoverability (rule 12e1, AC5) | Entry point verified in code | PASS — the round-3 diff adds and moves no entry point; `dream_jar_list_screen.dart` navigation is untouched. |
| Design fidelity, mobile lane (rules 12e2/12e3) | Captured state versus design reference | PASS — round 3 changes no pixel of the attributed state, which is what the capture records; the comparison branch is the round-2 code verbatim. The new branch is pinned by test rather than by image, which is the right instrument for a data-dependent degraded state. |
| Runtime startup smoke (rule 12g) | App launches to first screen | NOT REQUIRED — `Complexity: trivial`. |
| Setup/configuration (rule 12a) | `deployment/configuration-guide.md` | NOT REQUIRED — no env, dependency, or runtime-config surface in the round-3 diff. |

Not touched, therefore not gated: persistence/schema/migration, security/auth,
external integration, async job/workflow, payment provider, deep link/push,
permissions/device API, local storage/offline, operational command,
generated/typed contract, local Docker/Compose/registry.

## Traceability

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC1 — layout/spacing/colour/typography match exactly | PASS | Round-1's copy deviations remain corrected; round 3 changes no styling on the designed state. Card container, gradient, radius, padding and heading sit outside the new branch. |
| AC2 — every deviation corrected, not merely documented | PASS | All recorded deviations corrected in code; rows 17-18 of the fidelity report now state the real, verified behaviour instead of an overstated fix. |
| AC3 — animated SVG fill-level component | PASS | Untouched this round; verified in round 1. |
| AC4 — quick-add presets and per-partner comparison, every design state | PASS with D5 | Quick-add unchanged and matching. Every state present in the design source renders exactly as designed whenever the signed-in id is resolved — verified by `partner_split_card_test.dart` and by `dream_jar_list_screen_test.dart:104-107`, which drives the production wiring through the real `updateFromLoginResponse` path. When the id is unresolved the card degrades honestly instead of rendering a false comparison; that state is design-unsourced (D5) and its trigger is R1, not this story. |
| AC5 — reached through the existing navigation path, no new entry point | PASS | Verified in code; unchanged this round and still covered by the round-2 tests. |
| OQ5 (light theme / `en`) | Correctly applied | The `app_en.arb` edit is the translation of one newly added key, required for l10n completeness. No light-theme or `en` visual pass was performed or claimed, which is what OQ5 puts out of scope. |

## State recommendation

- Check `Implementation (Development)` in `story_master.md`.
- Check `Review (Reviewer)` in `story_master.md`.
- Story status: eligible for `DONE` (Scrum Master owns the transition).
- Story is merge-eligible into
  `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`.
- Carry R1 and D6 into the wave-close `add-bug` filing as one bug; they share a
  root cause and should be fixed together.
- Carry D5 to the Designer for copy/treatment sign-off in a later pass; it does
  not gate this story.
