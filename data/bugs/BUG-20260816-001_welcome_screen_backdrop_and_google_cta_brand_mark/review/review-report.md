# Bugfix Review: BUG-20260816-001 Welcome Screen Backdrop + Google CTA Brand Mark

Outcome: DEFERRED_ONLY

Reviewer: Iris-QC
Review type: bugfix-review
Reviewed: 2026-08-16
Bug id: `BUG-20260816-001_welcome_screen_backdrop_and_google_cta_brand_mark`
Scope gate: `data/bugs/BUG-20260816-001_welcome_screen_backdrop_and_google_cta_brand_mark/review/scope-gate.md`
SCOPE_GATE_COMPLETE: YES
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`
Diff reviewed: `10c05c3..fe59592` (3 production/test files, +136/-30)

Blocking findings: 0
Deferred findings: 2

## Rationale

Both reported defects are fixed at the right layer and independently verified.
R2-1 replaced a misused button token with a new design-system backdrop token
whose three stops, 58% midpoint and 165deg vectors I checked character-for-
character against the design source; R2-2 wired the already-existing
`CupidBrandMark.google` through a new optional leading-mark slot on
`_FilledCta`. The recheck is a real before/after device capture, not a
unit-test substitute, which is the correct modality for a design-fidelity bug.
The two deferred items are bookkeeping and forward-audit scope, neither
affecting the correctness of this fix.

## Independent Verification Performed

I did not rely on the fix-evidence verdict tokens for any of the following.

| Check | Method | Result |
|---|---|---|
| Gradient matches the design source | ranged read of `Cupid Screens.dc.html:69` | `linear-gradient(165deg,#7B2FBE 0%,#FF4B8C 58%,#FF3366 100%)` — exact match to the token's colors and `[0.0, 0.58, 1.0]` stops |
| 165deg vector math | `(-sin, cos)` / `(sin, -cos)` with `cos(165°) = -0.9659…` | correct, and consistent with the existing `gradientDream`/`gradientHot` convention |
| Google mark geometry matches the design source | grep `Cupid Screens.dc.html:84` | `<svg … style="width:20px;height:20px…">` and `gap:9px` — exact match to `_googleMarkSize = 20` / `_googleMarkGap = 9` |
| `required` ctor param blast radius | `git grep -c 'CupidColorTokens('` over `mobile/lib` + `mobile/test` | 3 hits, **all inside the token file itself** — zero external construction sites |
| Sibling call-site sweep (rule 12d) | `git grep 'gradientHot'` over `mobile/lib/features` | 28 hits, every one a button/pill/chip/toggle fill; **no remaining `.reversed` or backdrop misuse** |
| No-fork residue | `git grep '0.2588190451\|0.9659258262'` over `mobile/lib/features` | zero hits — the 165deg literals live only in `lib/design_system/` |
| Pre-fix capture really shows the defect | opened `visual-recheck/before-welcome-emulator-5560.png` | pale lavender→pink backdrop, Google CTA is a bare centred label. Both defects visible |
| Post-fix capture matches the design reference | opened `visual-recheck/implemented-welcome-emulator-5560.png` vs `design-reference-welcome-android.png` | saturated purple→pink→red sweep, multicolour "G" left of the label, all white/alpha foreground legible. No screen-content deviation |
| Captures are a genuine pair | status-bar clocks 12:44 → 12:51, same device, same harness | not a relabelled duplicate |

On the design reference's three small decorative dots in the upper area: these
are **not** a fidelity delta. The `isWelcome` block (lines 68-88) contains no
particle elements, so they come from the canvas frame wrapper along with the
device bezel. Their absence from the implemented capture is correct.

## Review Focus Items Raised By The Handoff

**1. `required` vs optional `gradientBrandBackdrop` — `required` is correct.**
Confirmed, and on stronger grounds than "the suite compiled". The unnamed const
constructor has zero call sites outside `cupid_color_tokens.dart`; `.dark()`,
`.light()`, `copyWith` and `lerp` are the only construction paths and all four
were updated. Blast radius is nil, and `required` makes the next token addition
a compile error instead of a silently dropped token — exactly the failure mode
that produced this bug. An optional param with a default would have let a
future token ship half-wired.

**2. Welcome 20px/9px vs login 19px/8px — intended divergence, do not unify.**
Confirmed against the source. Welcome's row really is `20px`/`gap:9px`; login
carries its own per-CTA constants (`_googleMarkSize = 19`/`_googleMarkGap = 8`,
`_facebookMarkSize = 18`/`_facebookMarkGap = 7`). Login already uses two
different geometries between its own two buttons, so per-row constants are the
established, correct pattern here. Unifying to one value would introduce a
fidelity defect on whichever screen lost.

**3. Requirement-level screenshot refresh — performed in this review commit.**
Copied
`data/bugs/BUG-20260816-001_welcome_screen_backdrop_and_google_cta_brand_mark/visual-recheck/implemented-welcome-emulator-5560.png`
over
`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/integration-review/mobile-screenshots/implemented-welcome-emulator-5560.png`
so Round 3 reads current state. Nothing is lost: the pre-fix state is preserved
both at
`data/bugs/BUG-20260816-001_welcome_screen_backdrop_and_google_cta_brand_mark/visual-recheck/before-welcome-emulator-5560.png`
and in git history at
`83d456f`. Storing the recheck under the bug directory was the right call for
Bug Fixer — it must not write `data/requirements/` — and the refresh belongs to
this gate. See DEF-1 for the one pointer that now needs updating.

## Critical Gates

| Risk surface | Gate | Status |
|---|---|---|
| Typed design-token contract | full-suite compile + `flutter analyze` (0 errors / 0 warnings, 80 pre-existing infos) + construction-site sweep | PASS |
| Mobile interaction / rendered UI | same-modality device capture vs design reference, reviewer-inspected | PASS |
| Design-system no-fork (ADR-004) | `no_fork_guard_test.dart` green; no hex/vector residue under `lib/features` | PASS |
| Mobile app lifecycle | registry `mobile-app` readiness probe, `ResumedActivity`, exit 0 | PASS |
| Regression coverage | test no longer pins the defect; asserts token identity, the three source colors, stops, vectors, `isNot(gradientHot.reversed)`, and a new 20x20 mark-before-label assertion | PASS |
| Setup/configuration (rule 12a) | no configuration surface touched | NOT REQUIRED |

Rule 16 gates: `diagnosis.md` carries `## Pre-Fix Reproduction Gate`
(`Result: REPRODUCED`); `fix-evidence.md` carries `BUG_FIX_COMPLETE: YES` and
`## Original Failure Recheck Gate` with `Same modality as original: YES`, and
the modality is a genuine rendered device capture rather than unit tests
standing in for a visual defect.

Test evidence was not re-run. It is fresh, internally consistent, and already
double-sourced (Bug Fixer plus an independent Scrum Master re-run of
`flutter analyze` and the targeted tests), so rule 18 says accept it.

## Deferred Findings

**DEF-1 — stale pointer to the refreshed screenshot. Owner: scrum-master.**
`bug_master.md` § Report and the Round 2 integration review report both cite
`integration-review/mobile-screenshots/implemented-welcome-emulator-5560.png`
as the image *showing* the defect. After this commit that path shows the fixed
state. Redirect those two citations to
`data/bugs/BUG-20260816-001_welcome_screen_backdrop_and_google_cta_brand_mark/visual-recheck/before-welcome-emulator-5560.png`
(or to commit `83d456f`). One-line edit each; Reviewer may not edit
`bug_master.md`. Non-blocking — no evidence was destroyed, only re-pointed.

**DEF-2 — `gradientBrandBackdrop` has a single consumer. Owner: REQ-002
remaining fidelity audit / Round 3.**
The sweep confirms no *current* screen misuses `gradientHot` as a backdrop, so
there is no live defect. Open question for the remaining screen audit: whether
other design-source screens specify the same 165deg brand backdrop and today
paint something else. Adopting the new token is the remedy if so. Out of scope
for this bug, which was scoped to the `welcome` screen only.

## Traceability

| Input | Verified against |
|---|---|
| Bug report R2-1 | `welcome_screen.dart` backdrop now `colors.gradientBrandBackdrop`; local reversed-`gradientHot` construction deleted |
| Bug report R2-2 | Google CTA passes `CupidBrandMark.google` at 20/9 through the new `_FilledCta` mark slot |
| `diagnosis.md` root cause | Matches the diff: the missing token and the missing widget parameter were both added at the design-system / widget-contract layer, not approximated in the feature layer |
| Design source | `Cupid Screens.dc.html` lines 69 and 84, read directly |
| ADR-004 no-fork | Raw hex confined to `lib/design_system/`; guard test green |
| Round 2 "Required To Clear" item 3 | Requirement-level capture refreshed in this commit |

## State Recommendation

- Keep the fix as-is; no rework round.
- Recommend `Review (Reviewer)` checked in `bug_master.md` § Artifacts.
- Recommend bug status `DONE`.
- Carry DEF-1 as an immediate one-line bookkeeping edit by Scrum Master and
  DEF-2 into the REQ-002 Round 3 integration review.
