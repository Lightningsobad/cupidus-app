---
story_status_recommendation: "DONE"
implementation_status_recommendation: "KEEP_CHECKED"
reviewed_at: 2026-08-25
reviewed_by: Reviewer
---

# Review Report: STORY-001 Anti-Ghost Alert Banner Design Fidelity

Outcome: CLEAN

Reviewer: Iris-QC
Mode: compact-story-review
Flow: parallel-story
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-010_home_dashboard_deferred_scope_completion-STORY-001`
Branch: `codex/REQ-010_home_dashboard_deferred_scope_completion-STORY-001`
First-pass BaseHead: `8fdabddb6f5f59b6f5b3fa1f8860992095c7a338`
Worktree HEAD at first-pass review: `af0061db27e30188e75b8e1a0f520dd49d2970f4`
Re-review BaseHead: `af0061db27e30188e75b8e1a0f520dd49d2970f4`
Worktree HEAD at re-review: `ae787f6873d582ee617f4d9e0d5e0b433030927b`

Implementation code is CLEAN and every claimed gate was independently
reproduced by the Reviewer in the first pass. The one blocking finding from
that pass (F1, missing DONE-gate evidence sections in `story_master.md`) has
been closed by a documentation-only patch, verified below. Story is approved.

## Reviewed Inputs

- Review gate: `compact-story-review`
- Scope Gate: `data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-001_antighost_alert_banner_design_fidelity/review/scope-gate.md`
- Requirements: `data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-001_antighost_alert_banner_design_fidelity/story_master.md`
- Bug Report: `N/A`
- Diagnosis: `N/A`
- Fix Evidence: `N/A`
- UX: `data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-001_antighost_alert_banner_design_fidelity/ux/uiux-spec.md`
- Architecture: `N/A`
- Coding Plan: `data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-001_antighost_alert_banner_design_fidelity/coding-plan/master-plan.md`
- Test Results: `data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-001_antighost_alert_banner_design_fidelity/coding-plan/test-results.md`
- Previous review findings: first-pass F1 (BLOCKING, documentation-only) and F2
  (non-blocking metadata), both carried forward and dispositioned below

## Reviewed Scope

- Story complexity: `trivial` per `story_master.md`; handoff declared
  `Story-Class: standard` (see F2)
- Bug status: `N/A`
- Code scope reviewed:
  - `mobile/lib/features/anti_ghosting/presentation/widgets/anti_ghost_entry_card.dart` (+54 -52)
  - `mobile/lib/design_system/icons/cupid_icons.dart` (+10 -0)
  - `mobile/test/features/anti_ghosting/presentation/anti_ghost_entry_card_test.dart` (+65 -0)
- Evidence reviewed: `coding-plan/test-results.md`,
  `visual-fidelity/visual-fidelity-report.md`,
  `visual-fidelity/design-reference-home-android.png`,
  `visual-fidelity/implemented-home-emulator-5554.png`
- Risk surfaces reviewed: design fidelity of a shipped Home surface, icon
  codepoint sourcing, tap/navigation behaviour, lifecycle copy logic,
  typography tokens, DONE-gate artifact completeness
- Critical gates reviewed: static analysis, targeted tests, regression sweep,
  visual fidelity, icon cmap verification, DONE-gate sections
- Backend targeted verification gates: `NOT_APPLICABLE`
- Story runtime startup smoke: `PASS`
- Frontend targeted verification gates: `NOT_APPLICABLE`
- Frontend discoverability/navigation integration: `NOT_APPLICABLE`
- Requirement frontend visual audit: `NOT_APPLICABLE`
- Mobile targeted verification gates: `PASS`
- Mobile discoverability/navigation integration: `PASS`
- Requirement mobile visual audit: `NOT_APPLICABLE` at story gate (story-level
  visual fidelity verified `PASS`; requirement-level audit belongs to the
  integration gate)
- Story artifacts reviewed: `story_master.md`, `ux/uiux-spec.md`,
  `coding-plan/master-plan.md`, `coding-plan/test-results.md`,
  `visual-fidelity/visual-fidelity-report.md`
- Bug artifacts reviewed: `N/A`
- OQ context reviewed: no open questions blocking this story

## Outcome Summary

- Review outcome: CLEAN
- Rationale: all three acceptance criteria are met; every claimed gate was
  independently re-run by the Reviewer rather than accepted from the report;
  the sole blocking finding was documentation-only and is now closed with no
  code change.
- Blocking findings: 0
- Deferred findings: 0
- Dismissed observations: 1 (D11 typography scope addition — accepted, see
  below)

## Traceability Summary

- Requirements: AC1, AC2, AC3 in `story_master.md` — all MET
- Bug report: `N/A`
- Diagnosis: `N/A`
- Open Questions: none blocking
- UX: `ux/uiux-spec.md` §1 (deviation table D1-D10), §2 (icon codepoint
  constraint), §3 (out-of-scope rulings for copy and `goChat` binding)
- Architecture: `N/A`
- Testing evidence: `coding-plan/test-results.md` and
  `visual-fidelity/visual-fidelity-report.md`, both reproduced by the Reviewer

## Risk Surface Gate Summary

| Risk Surface | Source Of Truth | Critical Gate | Result | Notes |
|--------------|-----------------|---------------|--------|-------|
| Design fidelity | `ux/uiux-spec.md` §1 + `design-reference-home-android.png` | Visual comparison of accepted capture | PASS | D1-D9 corrected; D10 correctly out of scope |
| Icon sourcing | `ux/uiux-spec.md` §2 | `fontTools` cmap check against `MaterialSymbolsRounded-Variable.ttf` | PASS | `0xe811` confirmed, no invented codepoint |
| Tap/navigation | AC3 | 2 pre-existing regression tests | PASS | `AntiGhostScreen` route unchanged |
| Lifecycle copy | AC3 | `_subtitleFor` branch-by-branch read + tests | PASS | Every branch returns the prior string |
| Static analysis | `flutter analyze` (scoped) | Reviewer re-run | PASS | 7 pre-existing infos, none in a changed file |
| Regression | Test suite | Reviewer re-run | PASS | `+168 All tests passed!` |
| Runtime startup | DONE gate | `emulator-5554` launch + capture | PASS | Populated Home frame, splash frame rejected |
| Entry point reachability | DONE gate | Existing mount + passing tap test | PASS | `Reachable: YES` |
| DONE-gate artifact completeness | Story DONE gate | Required sections present | PASS | Closed by the F1 patch |

## Blocking Finding Verification

### F1 — RESOLVED (was BLOCKING, non-code): `story_master.md` was missing the DONE-gate evidence sections

First-pass problem: `story_master.md` declared `System Integration And
Discoverability` with `UI-facing story: YES`, but carried neither a
`## Story Runtime Startup Smoke` section with a `Result:` line nor an
`## Entry Point Reachability` section with a `Reachable:` line. Both are
enforced by the story DONE gate for UI-facing stories — the same omission was
raised as blocking finding `F2` on
`data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/STORY-001_invite_couple_type_picker/story_master.md`
and required a dedicated patch cycle plus two follow-up commits to clear.
Left as-is, Scrum Master's DONE transition would have rejected this story
despite a fully clean implementation.

Closure verification (re-review pass, 2026-08-25):

`git -C <Worktree> diff af0061db --stat` shows exactly two files — this review
report and `story_master.md` (+17 -0), total +192 -0. No source, test, config,
or evidence file changed, so no gate needed re-running.
`git -C <Worktree> status --porcelain` is clean.

`story_master.md` now carries:

- `## Story Runtime Startup Smoke` ending in `Result: PASS`, citing the
  `emulator-5554` / `flutter run -t lib/main_preview.dart` launch
  (`--dart-define=PREVIEW=home --dart-define=PREVIEW_HOME_FIXTURE=true`) and the
  `MOBILE_CAPTURE: OK ... 405x900 171096` populated Home frame, with the
  splash-frame rejection noted.
- `## Entry Point Reachability` ending in `Reachable: YES`, citing
  `AntiGhostEntryCard` already being mounted on `HomeScreen` (no new entry
  point added by this story), its visibility in the accepted capture, and the
  passing test `tapping the card from HomeScreen pushes AntiGhostScreen`
  (`anti_ghost_entry_card_test.dart`).

Both sections restate only facts this report had already independently verified
in the first pass; no new or unverified claim was introduced. F1 is closed.

## Deferred Findings

None.

## Non-Blocking Observations

### F2 — NON-BLOCKING (metadata): Story-Class disagreement

`story_master.md` records `Complexity: trivial` / `Story-Class: trivial`, while
the review handoff declares `Story-Class: standard`. Harmless for this story's
outcome, but worth reconciling so the scheduler and the story artifact agree.

## First-Pass Verification Record

Retained because this re-review deliberately did not re-run these gates.

### Diff scope confirmed (first pass)

`git -C <Worktree> diff 8fdabdd --stat` matched the implementer's declared file
list exactly — no undeclared code changes. Working tree clean, no stray edits
outside the story's write scope.

### Acceptance criteria

- **AC1 — banner matches the design source (layout/spacing/colour/typography/copy):**
  MET. All ten UX-spec deviations are dispositioned: D1-D9 corrected in code,
  D10 (`wiggle` motion) correctly NOT added per the spec's own out-of-scope
  ruling. Verified line-by-line in the diff and confirmed visually against
  `visual-fidelity/design-reference-home-android.png`.
- **AC2 — deviations corrected in the app, not merely documented, and
  re-verified:** MET. Changes are real app-code changes, pinned by a new widget
  test and re-verified by an on-device capture.
- **AC3 — tap behaviour unchanged, no new entry point:** MET. `onTap` still
  builds `MaterialPageRoute(builder: (_) => const AntiGhostScreen())`; the
  design source's `goChat` binding was deliberately not adopted per
  `ux/uiux-spec.md` §3. `AntiGhostCubit` / `_copyFor` lifecycle logic is
  untouched (the `_CardCopy` → `_subtitleFor` refactor drops only the
  now-unused `isPending` flag; every lifecycle branch returns the same string as
  before). Regression-covered by two pre-existing tests, both passing.

### Gates independently re-run by the Reviewer

| Gate | Claimed | Reviewer re-run | Verdict |
| --- | --- | --- | --- |
| Static analysis (`flutter analyze lib/features/anti_ghosting lib/design_system/icons test/features/anti_ghosting`) | 7 pre-existing infos, zero new | `7 issues found` — all `prefer_initializing_formals`, all in `ghost_config_repository.dart` / `anti_ghost_cubit.dart` / `ghost_storm_cubit.dart`, none in a changed file | CONFIRMED |
| Targeted tests | `+9 All tests passed` | `00:01 +9: All tests passed!` | CONFIRMED |
| Regression sweep (`anti_ghosting`, `home`, chat ghost-row mount, `design_system`) | `+168 All tests passed` | `00:29 +168: All tests passed!` | CONFIRMED |
| Visual fidelity | PASS | Both PNGs opened and inspected | CONFIRMED |

### Icon codepoint gate (`ux/uiux-spec.md` §2)

The spec's one hard constraint was "do not invent a codepoint". The Reviewer
re-ran the cmap check against
`mobile/assets/fonts/MaterialSymbolsRounded-Variable.ttf` with `fontTools`:

```
sentiment_dissatisfied gid 6351 codepoints ['0xe811']
sentiment_neutral      gid 6355 codepoints ['0xe812']
sentiment_very_dissatisfied gid 6357 codepoints ['0xe814']
0xe811 -> sentiment_dissatisfied
```

This matches the doc comment on `CupidIcons.sentimentDissatisfied` exactly,
including the gid and the two neighbouring glyphs it warns against. Fix-path
step 2 was correctly taken; no codepoint was invented. `CupidIcons.chevronRight`
used for D9 is pre-existing (already consumed by `VibeEntryCard`).

### Capture integrity — the splash-frame trap was avoided

`implemented-home-emulator-5554.png` was opened and is a genuine, fully
populated Home dashboard (day counter, anti-ghost banner, Vibe/alarm/pet/wallet
cards, bottom nav) — not a Flutter splash frame. The rendered banner shows the
amber wash, amber hairline border, amber tile with the concerned-face glyph,
amber bold "Anti-Ghosting" title, muted `vi` subtitle "Đang chờ đối phương xác
nhận", and the trailing chevron, with no secondary timer badge. The report's
disclosure that a first 16399-byte splash capture was rejected and re-taken with
a uniquely-named script is credible and matches the accepted artifact.

### D11 (typography) — scope addition, justified and verified

D11 was not in the UX spec's §1 table; the implementer changed the title from
`type.cardTitle` (22px/w600) to `type.body` + `w800` (17px) and the subtitle
from `type.body` (17px) to `type.caption` (13px). The Reviewer verified both the
token values in `mobile/lib/design_system/tokens/cupid_typography_tokens.dart`
and the claimed precedent: `mobile/lib/features/vibes/presentation/widgets/vibe_entry_card.dart:59-77`
uses precisely `body.copyWith(fontWeight: FontWeight.w800)` + `caption` +
`SizedBox(width: CupidSpacing.sm)` + `chevronRight` in `colorTextMuted`.

The change is therefore an alignment with an established sibling-card
convention on the same screen, it is materially closer to the design's
14.5px/800 + 12px, and AC1 explicitly puts typography in scope. Accepted, not a
finding.

## Residual Risks (accepted, all pre-dispositioned — none blocking)

1. **Copy divergence.** Design renders `{{ghostAlertTitle}}`/`{{ghostAlertBody}}`
   ("Seen 5 phút rồi đấy" / "Trả lời đi không là bị bắn Storm nha"); the app
   keeps the shipped `l10n.anti_ghost_*` lifecycle strings. Ruled out of scope
   by `ux/uiux-spec.md` §1 and permitted by the story's own "or equivalent"
   wording.
2. **Leading tile size.** 48px (`cupidPlatform.tapTarget`) vs the design's 42px.
   Keeping the platform token is correct — 42px would fall below the Material
   minimum tap target.
3. **`wiggle` motion (D10).** Absent by design; dispositioned to STORY-017 `F1`
   ("motion is not a static-fidelity concern").
4. **Typography approximation.** Title 17px vs design 14.5px, subtitle 13px vs
   design 12px. Consistent with the repo's documented token-rounding convention
   and with the sibling `VibeEntryCard`; the `caption` token's own doc comment
   warns against re-pointing the token for a single 12px consumer.
5. **Uniform amber chrome across all lifecycle states.** Intentional per
   `ux/uiux-spec.md` §3 — the design draws one persistent amber banner and
   lifecycle is now carried entirely by title/subtitle copy, so no accessibility
   regression from colour-only signalling.

## Implementation Action Items

None. Outcome is CLEAN.

## Workflow State Recommendation

- Story status: `DONE`
- Bug status: `N/A`
- `Implementation (Development)`: `KEEP_CHECKED`
- `Review (Reviewer)`: `CHECK`
- Next step: Scrum Master may run the story DONE gate and merge
  `codex/REQ-010_home_dashboard_deferred_scope_completion-STORY-001` into
  `codex/REQ-010_home_dashboard_deferred_scope_completion-integration`.
  Optionally reconcile the F2 `Story-Class` metadata disagreement.
- State update owner: `scrum-master` only. Reviewer does not edit story or
  requirement status files.
