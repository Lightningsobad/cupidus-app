# Scrum Master Checkpoint: BUG-20260814-003

Bug id: BUG-20260814-003_caption_typography_token_mismatch
Status: REVIEW_REQUIRED
Attempt count: 1
Continuation count: 0

## Artifact Paths
- Bug master: `data/bugs/BUG-20260814-003_caption_typography_token_mismatch/bug_master.md`
- Diagnosis: `data/bugs/BUG-20260814-003_caption_typography_token_mismatch/diagnosis.md`
- Fix evidence: `data/bugs/BUG-20260814-003_caption_typography_token_mismatch/fix-evidence.md`
- Review: `data/bugs/BUG-20260814-003_caption_typography_token_mismatch/review/review-report.md`

## Failure Anchors
- `login_screen_test.dart:91`
- `waiting_screen_design_fidelity_test.dart:238`
- `joincode_screen_design_test.dart:107`
- All 3: Expected caption size `13`, Actual `11.5`
- Uncovered (no assertion yet, per I-5): Love Pet eyebrow muted-alpha
  `0.65` → `0.575` drift, same shared token surface
- Shared token surface: `mobile/lib/design_system`, touched across 14
  commits / 14 REQ-002 stories

## Expected Behavior Source
Design-fidelity test assertions (caption typography token spec);
broadened and reconfirmed RED by REQ-002 requirement integration review
(Iris-QC), finding I-5.

Suspected impacted runtime/service/app: mobile-app (Flutter)
Runtime registry: `data/devops/system/runtime-command-registry.json`

Query keys for future bug-fixer handoff: "caption", "typography token", "11.5",
"muted-alpha", "0.575", "0.65", "design_system", "Love Pet eyebrow"

Active Bug Fixer Agent Id: Justin-BugFixer@session-0463b8e0
Bug Fixer Status: COMPLETE (BUG_FIX_COMPLETE: YES)

## Fix Summary (for Reviewer handoff)

One shared root cause, confirmed not assumed: `CupidTypographyTokens.caption`
(`cupid_typography_tokens.dart:46-50`) was `fontSize: 11.5`. The Love Pet
eyebrow's `letterSpacing` at `pet_reactions_card.dart:41` is
`0.05 × type.caption.fontSize!`, so `0.05 × 11.5 = 0.575` exactly reproduces
the "muted-alpha" symptom — it is derived `letterSpacing`, not an alpha
value, and no `0.575`/`0.65` literal exists anywhere in `mobile/lib`.

History: `eeaeeae` (REQ-001/STORY-001) created `caption` at `13`; `bf01450`
(REQ-002/STORY-033, "Delta 2") deliberately changed it to `11.5` for a
zodiac inline-helper's 2-line-wrap fix, a reviewed/merged change, not an
accidental regression. STORY-033 itself flagged the hazard and deferred a
role-split (`ux/ux-spec.md:161-171`) — this bug is that follow-up. The design
source draws small text at 4 distinct sizes (11/11.5/12/12.5/13px) all
served by the one `caption` token; the 3 RED sub-copy assertions transcribe
the 13px rows verbatim (design-source lines 1429/1554/1580), matching
`uiux-spec.md:96`.

Fix: token restored to `13`. A plain revert was rejected — no test pinned
the zodiac helper's size/wrap, so reverting alone would silently re-break
STORY-033's AC3. A new ThemeExtension field was also rejected as
disproportionate (2 call sites). Instead the 11.5px inline-helper role now
states its own local size at its 2 consumers
(`onboarding_profile_setup_screen.dart`, `profile_edit_screen.dart`),
matching the repo's existing idiom for design-source-specific local sizes.

Coverage added: `theme_matrix_test.dart` (pins the shared token itself,
previously unpinned despite 179 call sites / 60 files) and
`onboarding_profile_setup_screen_test.dart` (pins STORY-033's AC3 zodiac
helper size, which previously rode entirely on the shared token with no
assertion of its own). The Love Pet eyebrow drift needed no new assertion —
`pet_design_fidelity_test.dart:150` already covered it and is now green.

Anchor corrections: `waiting_screen_design_fidelity_test.dart:238` is now
`:188` (BUG-20260815-002's merged patch shortened the file above it, same
assertion). The eyebrow drift was NOT uncovered as I-5 stated —
`pet_design_fidelity_test.dart:150` already asserted it and was RED (4 RED
assertions total, not 3 + 1 uncovered).

Changes: 5 files, `+57 -3`. `cupid_typography_tokens.dart` (token value +
role-documentation comment), `onboarding_profile_setup_screen.dart` +
`profile_edit_screen.dart` (stated local `_zodiacHelperFontSize = 11.5`),
`theme_matrix_test.dart` + `onboarding_profile_setup_screen_test.dart` (new
regression assertions).

Gates: Pre-Fix Reproduction REPRODUCED (4 assertions, 2 commands). Recheck
PASS same modality (`+36: All tests passed!`, all 4 anchors green). Analyze
PASS (5 changed files, no issues). Build PASS (`flutter build apk --debug`
exit 0). Runtime Startup PASS (emulator-5560, `READY_OK` attempt 1, 0 fatal
log lines, clean shutdown) + rendered-screenshot recheck (no overflow, no
error box). Regression PASS — FULL suite run (not scoped: 179 call sites /
60 files made a subset unprovable): `+1240 ~2 -2` of 1242; both remaining
failures are BUG-20260814-002's `home_screen_ready_signal` pair (present in
BUG-20260815-001's and BUG-20260815-002's baselines). Net: 4 fixed, 0
introduced.

Not-in-scope findings for Scrum Master triage (recorded in `bug_master.md`,
not created as new bugs): F-1/F-2/F-3 pre-existing non-RED design-source
deltas on the same token (STORY-033's own flagged small-text role-split
follow-up); a `runtime-command-registry.json` `mobile-app` start-command
defect (wrong launcher class) found and worked around, out of bug-fixer's
write scope, for DevOps.

Work location: fix directly in the REQ-002 integration worktree
(`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`,
branch `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`).
Changes left uncommitted for Scrum Master (5 modified/new mobile files + 2
new bug-record files: `diagnosis.md`, `fix-evidence.md`).

Work location: fix directly in the REQ-002 integration worktree
(`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`,
branch `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`), not
a fresh story worktree — the shared token surface is only visible once all 14
owning stories are merged together.

Priority: blocking REQ-002 DONE (SKILL 12c test-gate reasoning). The earlier
"accepted baseline, not blocking" disposition was a per-story review
exception and does not survive requirement-level integration review, which
treats the RED `flutter test` suite as the primary proof gate.
