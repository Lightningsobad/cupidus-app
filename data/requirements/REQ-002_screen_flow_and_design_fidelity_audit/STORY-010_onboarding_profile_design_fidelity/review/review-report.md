# Review Report: STORY-010 — Design Fidelity, Onboarding Profile Setup

## Outcome: DEFERRED_ONLY

Review type: compact-story-review — **round 4, closure** (supersedes rounds 1-3)
Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Story: STORY-010 | Lane: mobile (single lane)
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-010`
BaseHead: `dffa9611` | Reviewed HEAD: `4826055`
Recommended story status: DONE-eligible (merge-eligible into
`codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`)

All three round-3 blocking findings are closed. F1 was a routing gap and is now
closed by a governing artifact, not by a self-recorded deferral. F2 and F3 were
closed by mobile-dev in commit `4826055` and are verified here against the
repository, not against the commit message.

## Scope Gate

Round-4 changeset (`git diff dffa9611`, 5 files):

| File | Change |
|---|---|
| `coding-plan/test-results.md` | new, 164 lines (F3) |
| `visual-fidelity/visual-fidelity-report.md` | re-issued `PASS` (F1 / Action Item #2) |
| `mobile/lib/features/account/presentation/screens/profile_edit_screen.dart` | reverted, −279 (F2) |
| `mobile/test/features/account/presentation/screens/profile_edit_screen_test.dart` | reverted, −168 (F2) |
| `story_master.md` | +27, Scrum Master disposition addendum |

Round 4 authored **no** new product source. The only executable change is a
revert to merge-base content.

Whole-branch source surface against merge-base `bf80848`
(`git diff --stat bf80848 -- mobile/`) is now exactly seven files — the three
new `features/onboarding/` sources, the three new `test/features/onboarding/`
tests, and `main_preview.dart`. **Zero `features/account/` files.** That is the
declared write scope, exactly.

`review/scope-gate.md` in this directory is still round 2's and still stale (it
scopes `profile_edit_screen.dart`, a file this branch no longer touches). It is
outside this run's WriteScope, so it is left as found; treat this section as the
round-4 scope of record and see R-2 below.

## Round-3 Finding Closure

### F1 — unratified `VISUAL_FIDELITY: FAIL` — **CLOSED**

Round 3 did not call the `FAIL` wrong; it called it *unratified* — the four
deltas were real but no governing artifact scoped them out, and a self-recorded
deferral cannot move an AC. Both halves of that gap are now closed, and the two
halves agree with each other:

- **Governing artifact.** `story_master.md` carries a "Product Owner Ruling —
  2026-08-14" adopting route (a). It names the four exclusions, gives the
  rationale, assigns them to STORY-033, and adds an explicit scope disclaimer
  that the ruling rescopes the acceptance bar only and does **not** authorize
  anyone to fix the four under STORY-010.
- **ACs rewritten, not merely annotated.** AC1 and AC2 in `story_master.md` now
  carry the exclusions in their own text. This matters: round 3's objection was
  that AC1 read "no visible deviation" unqualified. It no longer does.
- **Report re-issued honestly.** `visual-fidelity-report.md` is now
  `VISUAL_FIDELITY: PASS`, and it does not hide the four. §4 keeps every
  measurement in full and states why: *"a `PASS` verdict that hid them would be
  dishonest."* Its "Verdict basis" table maps each of the four ruled exclusions
  to the section that documents it, and the mapping is 1:1 with the ruling:

  | Ruling exclusion | Report section |
  |---|---|
  | 1 — ambient `skyGradient` backdrop | §4.4 |
  | 2 — `CupidHeader` back-arrow ink | §4.4 |
  | 3 — `caption` sub-13px sizing **and its wrap** | §4.2 |
  | 4 — CTA gradient axis 120deg vs 95deg | §4.3 |

  The report is also explicit that `PASS` means "no deviation remains inside
  this story's correction scope", **not** pixel-identity — and it names the
  backdrop as "the largest visible difference between the two frames by area,
  and the one an integration reviewer will notice first — it is excluded, not
  overlooked." That is the right disclosure; an integration reviewer opening
  these frames will not be surprised.
- **Action Item #2 satisfied.** §4.2 now names the zodiac helper-text two-line
  wrap explicitly as a *layout consequence* of the excluded `caption` sizing,
  with the mechanism (11.5px authored, 13px rendered, exceeds card content
  width, pushes the NGÀY SINH card taller) and the note that it resolves by
  itself when STORY-033 lands the sub-13px step. Round 3 asked for exactly this
  so it would not be mistaken for an unexplained deviation. Done.
- **Round-3 Action Item #5 satisfied.** The owner story exists as a real
  artifact on this branch —
  `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-033_app_shell_design_system_deltas/story_master.md`
  — and is registered in `req_master.md` (`| STORY-033 | App Shell Design System
  Deltas | standard | PENDING | ... |`). Round 2 and round 3 both asked for this
  and were both ignored; it is now real and it merges with this branch. The
  ID-collision renumber from STORY-032 is documented in the ruling's "ID note".

The render did not change between rounds 3 and 4, and it did not need to. Round
3 independently opened both frames and confirmed the §3 element table is
accurate and that the implemented frame is a genuine device render of this
story's screen. Nothing in round 4 invalidates that.

### F2 — undecided `ProfileEditScreen` merge payload — **CLOSED, verified at blob level**

I did not take the commit message's word for the revert. Comparing Git object
ids for both paths at the merge-base, at `HEAD`, and in the working tree:

| Path | `bf80848` | `HEAD` (`4826055`) | worktree |
|---|---|---|---|
| `mobile/lib/.../profile_edit_screen.dart` | `71de0004` | `71de0004` | `71de0004` |
| `mobile/test/.../profile_edit_screen_test.dart` | `f1229c9c` | `f1229c9c` | `f1229c9c` |

All nine ids identical; `git diff bf80848 -- <both paths>` produces no output.
Byte-identical, as claimed, and clean in the working tree as well as in the
commit.

The sharper half of F2 is also resolved. I read the reverted test file: it
contains one `group('ProfileEditScreen', ...)` with exactly three tests — the
pre-STORY-010 baseline. The six-test group
`STORY-010 design fidelity against the 'profile' canvas`, whose hard-coded
canvas-`profile` geometry assertions would have pre-empted STORY-029's own
fidelity-target decision, is gone. STORY-029 inherits the screen and its test
unencumbered, which is what `story_master.md` reserves to it.

The Scrum Master disposition recording route (a) is committed to
`story_master.md`, so the branch carries its own rationale rather than leaving
the decision in chat.

### F3 — missing `coding-plan/test-results.md` — **CLOSED, both sections substantive**

`coding-plan/test-results.md` now exists with both mandatory sections, and
neither is a stub:

- `## Entry Point Reachability` — states `Reachable: NO` **by explicit product
  decision, not omission**, names `OnboardingProfileSetupRoute`
  (`/onboarding/profile`) as the declared-but-unwired entry with its file path,
  attributes the wiring to STORY-002, and then does the thing a stub would not:
  it tables the five pieces of evidence for AC4's actual bar (renders standalone
  on its own route), including the route test pinning `RouteSettings.name` so the
  contract cannot drift before STORY-002 consumes it. It also records that
  nothing is gated behind a build flag.
- `## Story Runtime Startup Smoke` — `Runtime-Smoke: PERFORMED`, scoped to
  `mobile-app` per `runtime-command-registry.json`, with the exact
  `flutter run`/`adb screencap` invocation, the capture path and byte size, and
  the confirmation of a genuine device render. It states plainly that the smoke
  was performed in round 3 and is *restated* here because F3's complaint was
  that it was filed in the wrong artifact — and it gives a real reason round 4
  did not re-run it (round 4 changed no file the running app loads). It closes
  with a registry-conformance note explaining why
  `Key('home_screen_ready_signal')` is not usable as this screen's gate.

## Independent Verification

Re-run by me in the story worktree (`mobile/`, Flutter 3.44.1 / Dart 3.12.1):

| Gate | Command | Result |
|---|---|---|
| Analyze, branch-touched | `flutter analyze` over all 5 changed items incl. both reverted files | `No issues found! (ran in 2.4s)` |
| Analyze, project-wide | `flutter analyze lib test` | `77 issues found` — **all `info`**, zero errors/warnings, none in a file this branch touches |
| Targeted story scope | `flutter test test/features/onboarding test/design_system/no_fork_guard_test.dart test/features/account/.../profile_edit_screen_test.dart` | `+19: All tests passed!` |

`+19` reconciles exactly with the claim, and the per-test output confirms the
composition: 16 onboarding + guard tests, then exactly three
`ProfileEditScreen` tests. Round 3's own independent run of the same command
returned `+25`; `25 − 19 = 6`, which is precisely the six removed tests and
nothing else. The `+941 → +935` full-suite claim is the same arithmetic on the
same delta and is accepted as plausible; I did not re-run the full suite from
scratch, per this round's handoff, and nothing in the diff or the targeted run
gives a reason to.

**No regression from the revert.** The project-wide analyze above is the check
that matters here — a revert that removed 279 lines of `ProfileEditScreen` would
surface any dangling reference as an *error*, and there are none. I also read
the `main_preview.dart` diff directly: commit `a8d0fed` had already dropped
`import '...profile_edit_screen.dart';` and rewired `_buildProfile` to build
`OnboardingProfileSetupScreen`, so the revert left nothing pointing at removed
behavior. The `_PreviewAccountRepository` fixture override is contained to the
preview harness and inert without `PREVIEW_PROFILE=fixture`.

## Acceptance Criteria

Read against AC1/AC2 **as amended** by the Product Owner Ruling — 2026-08-14.

| AC | Verdict |
|---|---|
| AC1 — exact match to canvas `profile` in dark + `vi`, except the four ratified shared `design_system/` deltas | **MET.** Every element the canvas authors is present, correctly ordered and pixel-accurate (§3, independently verified in round 3 against the frames; the render is unchanged). The deltas that remain are exactly the four the ruling excludes — no more, no fewer. I checked the ruling's list against §4 item by item; there is no fifth delta hiding under the exclusion and none of the four was quietly fixed outside scope. |
| AC2 — in-scope deviations corrected in the app, not merely documented | **MET.** In-scope deltas were corrected in the rendered app and re-verified by re-capture. The four excluded deltas sit in shared files the ruling explicitly forbids this story from touching, so they are outside AC2's correction scope by construction rather than by convenience. The seven-file diff confirms `mobile/lib/design_system/` was never entered. |
| AC3 — avatar slot, empty and populated | **MET.** Unchanged since round 3, which verified it against the render: 104dp circle, `elevationShadow`, 36dp gradient badge at `right:-10/bottom:-6` with ring and glow, crop caption; populated state asserted on `DecorationImage`/`BoxFit.cover`. |
| AC4 — renders standalone, adds no live navigation | **MET.** No nav-graph, shell, or router file appears in `git diff bf80848 --name-status`; the route factory is declared and uncalled. Now also documented where the DONE gate reads it (`test-results.md` § Entry Point Reachability). |

## Deferred Findings

D-1 through D-4 carry forward unchanged from round 3 — round 4 neither
addressed nor worsened them, and none blocks merge.

| # | Finding | Disposition |
|---|---|---|
| D-1 | `_ProfileSetupLocaleText` keeps vi/en copy file-local instead of in `app_vi.arb`, deliberately, because ARB is a shared cross-story surface in this parallel wave (precedent: `invite_screen.dart`). Correct call now; fold into ARB once the wave closes. | DEFERRED — post-wave cleanup |
| D-2 | The language card renders `profile.language` (correct) but is inert, while the canvas also gives it no `onClick` — the chevron promises an interaction nothing delivers. | DEFERRED — locale-switcher story |
| D-3 | `ZodiacGlyph` lives under `features/onboarding/presentation/widgets/`; the file names its own promotion path to `design_system/icons/` once a second screen needs it. | DEFERRED — accepted, no action |
| D-4 | The canvas CTA targets `contract` (`goContract`) while STORY-002's chain text says `invite`/`join-code`. Worth resolving before STORY-002 wires it. | DEFERRED — `product-owner`, STORY-002 |
| D-5 | The `profile` preview canvas id is repointed to this story's screen, so `ProfileEditScreen` no longer has a preview entry of its own. Disclosed in the visual report §7; accepted in round 3 as contained and honest, and not a consequence of the round-4 revert. | DEFERRED — STORY-029, if it wants a canvas |

## Residual Risks

These are for `scrum-master` and the requirement integration gate. None blocks
this story's merge.

- **R-1 — STORY-033 is the load-bearing counterparty of this PASS.** This
  story's AC1/AC2 are met *because* four visible deltas were moved to STORY-033,
  including the backdrop, which is the single largest visual difference between
  the reference and the build. STORY-033 exists and is registered
  (`PENDING`), which is what round 3 required. But if STORY-033 is deferred out
  of REQ-002, the requirement ships a screen that visibly does not match its
  canvas, and no story is accountable. The requirement integration review should
  treat STORY-033 as required scope, not optional follow-up.
- **R-2 — `review/scope-gate.md` is stale** (round 2, scopes
  `profile_edit_screen.dart` — a file this branch no longer touches). Round 3
  flagged it; it is outside every subsequent review's WriteScope, so it will not
  self-correct. Delete or regenerate it before the requirement closes, or the
  next reader will scope this story against the wrong screen.
- **R-3 — the screen ships unreachable until STORY-002 lands.** This is round
  3's Action Item #6 and is correctly out of this story's scope by AC4, but it
  is a requirement-level completeness risk, not a resolved one. REQ-002 cannot
  close on this screen alone.
- **R-4 — `ProfileEditScreen`'s own design fidelity now has no owner.** After
  the F2 revert, no REQ-002 Scope B story covers `ProfileEditScreen` against
  `Cupid Screens.dc.html:982`; STORY-029 covers only the `me` hub tab. This is
  correctly flagged for `product-owner` in `story_master.md` as a
  backlog-completeness question and is correctly *not* absorbed by this story.
- **R-5 — story state fields are not yet transitioned.** `story_master.md`
  still reads `Status: PENDING` with the Implementation and Review artifact
  checkboxes unchecked. Those are `scrum-master`-owned transitions and are
  expected to move with the DONE gate; noted so they are not missed.

## Action Items

1. `scrum-master` — mark STORY-010 `DONE` and make the branch merge-eligible
   into `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`; update
   `Status`, the Implementation/Review checkboxes (R-5), and run the story
   boundary `complete` step.
2. `scrum-master` — carry R-1 into the requirement integration review: STORY-033
   is required scope for REQ-002, not optional follow-up.
3. `scrum-master` — remove or regenerate the stale `review/scope-gate.md` (R-2);
   no review round has had it in WriteScope.
4. `product-owner` — R-4: decide whether `ProfileEditScreen`'s own fidelity
   needs a story, and R-3/D-4: confirm STORY-002's CTA destination against the
   canvas' `goContract` before STORY-002 wires this screen.

REVIEW_COMPLETE
