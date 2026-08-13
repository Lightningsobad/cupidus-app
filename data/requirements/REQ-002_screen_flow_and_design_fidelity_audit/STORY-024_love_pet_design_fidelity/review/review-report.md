# Review Report — STORY-024 Love Pet ("Bún") Design Fidelity (Round 2)

- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Story: STORY-024_love_pet_design_fidelity
- Reviewer role: reviewer (compact-story-review)
- Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-024`
- BaseHead: `8396273e6a5e6a2798557aa68864f0ef24cd939b`
- Round-1 reviewed HEAD: `64a2defcd8e6983bade20f8907d028b6124f9e7d`
- Round-2 reviewed HEAD: `deeb22cf3e95aecf65aefa32b2c4f803f9034da7` (clean tree)

## Verdict

**Outcome: PATCH_REQUIRED**

All three round-1 findings are substantively closed. F1 is genuinely fixed in
code, test, and render; F2's rendered evidence now exists and is a real capture
of the correct screen; F3's rationale is restated on a citation I verified.

What still blocks is narrow and mechanical: `visual-fidelity-report.md` carries
no machine-readable verdict token and no resolved design-screen id, and the
design reference it compares against is not co-located with the capture. These
are the exact fields the reviewer stop gate and the DONE gate read
independently, so the story cannot close without them. Round 3 should be a
report edit plus one file copy — no code change.

## Scope Gate

| Field | Value |
| --- | --- |
| Review type | `compact-story-review`, round 2 (re-review of a `PATCH_REQUIRED`) |
| Report path | `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-024_love_pet_design_fidelity/review/review-report.md` |
| Diff baseline | `git -C <Worktree> diff 64a2def` (round-2 delta) over `git diff 8396273` (full story) |
| Source/test files in scope | `pet_screen.dart`, `pet_xp_card.dart`, `pet_design_fidelity_test.dart`, `pet_capture_entry.dart` (4 — round-2 delta only) |
| Evidence files in scope | `visual-fidelity/visual-fidelity-report.md`, `visual-fidelity/implemented-pet-emulator-5554.png`, `design-reference-pet-android.png` (REQ-001/STORY-018), round-1 `review-report.md` |
| Governing artifact | `story_master.md` (small; full read) |
| Config | `data/devops/system/design-fidelity-config.json` |
| Touched risk surfaces | mobile interaction, mobile design fidelity (rendered), widget composition |
| Critical gates | rendered visual fidelity (12e2/12e3), targeted widget tests, static analysis |
| Query keys | F1 action-row placement, F2 rendered evidence, F3 D3 rationale, `VISUAL_FIDELITY`, `Design-Screen`, `/pets/*` contract |
| Not re-derived | The 32 round-1 deviations and D1–D7, already verified line-for-line in round 1 |

## Round-1 Finding Closure

| ID | Round-1 requirement | Status | How I verified |
| --- | --- | --- | --- |
| F1 | Move Feed/Play inside the XP card (design L653–671) or defer it explicitly | **CLOSED** | `pet_xp_card.dart` gained a `footer` slot rendered inside its own container after a `CupidSpacing.md` gap; `pet_screen.dart:97-105` passes `PetActionRow` into it instead of appending a sibling. `CrossAxisAlignment.stretch` is the correct companion change — the footer and bar both need the tight full-card-padding width. New test asserts `PetActionRow` is a `descendant` of `PetXpCard`. Confirmed visually in the capture: Feed/Play sits on the same card surface as the XP header and bar. Documented as deviation 33 |
| F2 | Produce rendered evidence for dark + `vi`, compared to the design baseline | **SUBSTANTIVELY CLOSED, 3 gate fields missing** | See F7–F9 below. The capture itself is good — see "Rendered Evidence" |
| F3 | Restate D3 on accurate authority | **CLOSED** | D3 now argues the picker is contract-unbacked rather than citing `uiux-spec.md` §2.1. I spot-verified the anchor: `mobile/openapi/cupid-api.json:750` is `POST /pets/adopt` tagged `Epic 4 - Love Pet`, and the pet test suite exercises exactly `readPairing`, `readStatus`, `interact`, `adopt` — no species-mutation route exists. The 409 one-pet-per-couple behaviour is asserted in `pet_repository_test.dart`. The rationale is now correct |

Round-1 F4 (`en` string assertion) and F5 (near-token spacing roundings not
listed) were non-blocking and remain open by choice; F5's values are still
absent from §5. Neither affects this outcome.

## Rendered Evidence — Verified By Opening Both Images

I opened both PNGs rather than counting files.

- `visual-fidelity/implemented-pet-emulator-5554.png` — a real 1080×2400 device
  capture showing **this story's screen in its ready state**: dark theme, `vi`
  copy, Bún sprite on the purple→pink→blue-grey hero, `Lv.3 · Vui phơi phới`
  pill, XP card at `26%` with Feed/Play inside it, 2-tile stats row, and the
  reaction tiles. Not a launcher, not an error frame, not another story's
  screen. This is the first genuine render of this screen's ready branch in
  the repo — round-1's concern is answered.
- `design-reference-pet-android.png` (REQ-001/STORY-018) — depicts the Love
  Pet screen of the design canvas. **Correct screen**, so the comparison is
  against the right target even though the id was never written down.

The §7 delta narration is honest and matches what I see. Every residual delta
it lists is really there, and each maps to a deferral: D3 (species grid), D4
(2 vs 3 stat tiles), D1 (hero radius), D2 (sparkles / breathe glow / ground
shadow), D9 (XP label copy), D8 (screen title + bottom tab bar). I found no
delta the report failed to disclose, and nothing in the two images contradicts
the implementer's account.

D8 deserves note: it is new, it was surfaced only because someone finally
rendered the screen, and the implementer correctly identified it as app-shell
scope walled off by AC4 rather than quietly absorbing it. That is the right
call and the right escalation.

### F7 — BLOCKING — No `VISUAL_FIDELITY:` verdict token

`visual-fidelity-report.md` contains no `VISUAL_FIDELITY:` line anywhere (0
matches across all 280 lines). Design fidelity spec requires a top-level
`VISUAL_FIDELITY: PASS` or `FAIL` verdict, and both the reviewer stop gate and
`validate-done-gate.sh` read that exact token independently of this report.
Excellent prose analysis with no verdict token does not satisfy either gate.

Recommended text, so round 3 does not have to guess. The in-scope audit
dimensions do match; the residual deltas are all block-level omissions that are
out of this story's lane:

```
VISUAL_FIDELITY: PASS
Scope of verdict: the five audit dimensions named in story_master.md In Scope
item 1 (pet vector placeholder rendering, growth-state indicator styling,
spacing, colour/token usage, typography), on the components present in the
build. Six block-level deltas remain and are carried as deferrals D1, D2, D3,
D4, D8, D9 in §5 — see §7 for each one as seen in the render.
```

Do not write a bare `PASS`. The verdict must state its scope and point at the
deltas, otherwise it claims something the images disprove.

### F8 — BLOCKING — Resolved `Design-Screen: <id>` not recorded

`design-fidelity-config.json` sets `screens_from: "canvas"`, so design screens
are named canvas states rendered via `render-design-canvas.js --screen=<id>`.
The report never records which id was resolved (0 matches for `Design-Screen`).

This one matters more than it looks: a story compared against the wrong canvas
screen produces a confident PASS that certifies nothing, and it is
indistinguishable from a correct one in a file listing. I closed the gap by
opening the reference myself and confirming it is the Love Pet screen — but
that check has to be re-runnable by the next reader without re-deriving it.

Add `Design-Screen: <id>` to §1 (the id behind `design-reference-pet-android.png`,
i.e. the canvas state this story's screen corresponds to).

### F9 — BLOCKING — Design reference not co-located with the capture

`<story>/visual-fidelity/` holds only `implemented-pet-emulator-5554.png`. The
design fidelity contract expects the matching
`design-reference-<screen>-<device>.png` beside it; here the baseline is only
referenced by path into `REQ-001/STORY-018`. The gates check the story's own
`visual-fidelity/` directory, and a cross-requirement reference also means this
story's evidence silently changes meaning if REQ-001's artifacts are ever
re-rendered or moved.

Copy `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-018_design_fidelity_capture/visual-fidelity/design-reference-pet-android.png`
to `<story>/visual-fidelity/design-reference-pet-android.png`, keeping the
filename, and note in §7 that it originates from STORY-018.

## Acceptance Criteria

| AC | Status | Basis |
| --- | --- | --- |
| AC1 | **PARTIAL** | Within the five named audit dimensions the render matches — hero gradient ramp, pill treatment, Nunito display name, XP bar geometry and `--grad` fill, card surfaces/radii/shadows, uppercase muted eyebrow, mint/amber/peach reaction tints all confirmed in the image, not just in code. "No visible deviation" is not literally true: the species grid, screen title and tab bar are absent. All are governed deferrals outside the mobile lane — see Residual Risks |
| AC2 | **MET** | 33 deviations corrected in the app and now re-verified at the rendered level, which is what round-1 F2 demanded. The correction is real, not documentary |
| AC3 | **MET** | Sprite untouched; no animation added. Confirmed in the round-2 diff and in the capture |
| AC4 | **MET** | Round-2 diff touches two presentation widgets and two test files. No route, tab, or navigation change. The implementer explicitly declined to add the tab shell on AC4 grounds (D8) |

## Verification (re-run by reviewer)

| Command | Reviewer result | Report claim | Match |
| --- | --- | --- | --- |
| `flutter analyze lib/features/pet lib/design_system/tokens/pet_hero_gradient.dart test/features/pet` | `Analyzing 3 items... No issues found! (ran in 2.8s)` | 0 errors, 0 warnings | Yes |
| `flutter test test/features/pet test/design_system` | `+138: All tests passed!` | 138 passed | Yes |
| `git -C <Worktree> diff 64a2def` | 4 code/test files, +92/−5; tree clean at `deeb22c` | 4 files | Yes |

Run from the story worktree's `mobile/` with
`PATH="/Users/alantravala/flutter/bin:$PATH"`. Full-suite `+929` was verified in
round 1 and the round-2 delta is confined to the pet feature, so I did not
re-run it.

`pet_capture_entry.dart` sits under `test/` but is a `flutter run -t`
entrypoint, not a test. It imports no `flutter_test`, is excluded from
`flutter test` by the `*_test.dart` convention, and is analyzer-clean. Placing
it there to reuse `FakePetRepository` is reasonable; its header comment says so.
No action.

## Required To Clear PATCH_REQUIRED

Owner: **mobile-dev**. All three are edits to
`visual-fidelity/visual-fidelity-report.md` plus one file copy. No code change,
no re-capture, no re-test.

1. **F7** — Add the scoped `VISUAL_FIDELITY:` verdict block to the top of the
   report (text supplied above).
2. **F8** — Record `Design-Screen: <id>` in §1's comparison-basis table.
3. **F9** — Copy `design-reference-pet-android.png` into the story's
   `visual-fidelity/` and reference the local copy in §7.

Optional while in the file (round-1 F5, still non-blocking): add the near-token
spacing roundings (`gap:13`→16, `padding:17`→16, `padding-bottom:40`→32,
stats `gap:11`→8) to the §5 deferral table so the next audit does not
re-litigate them.

## Deferred Findings

D1–D9 as recorded in the implementer's §5 are all accepted. Round-1 accepted
D1, D2, D4, D5, D6, D7 and rejected only D3's citation, which is now fixed. The
two new ones:

| ID | Item | Reviewer position |
| --- | --- | --- |
| D8 | No "Love Pet" screen title, no 5-tab bottom nav | Accept. Verified real, not a harness artifact — `PetRoute` pushes a plain `MaterialPageRoute` and `PetScreen` builds a bare `Scaffold` with no `AppBar`. AC4 forbids changing how this screen is reached, so this cannot be closed here. Correctly escalated to app-shell scope |
| D9 | XP label `Kinh nghiệm` vs design `Kinh nghiệm tới Lv.4` | Accept. Copy/i18n in `pet_strings.dart`, outside this story's write scope and outside its five audit dimensions |

## Residual Risks

- **AC1 as written cannot be satisfied by this story.** "No visible deviation"
  is contradicted by D3 (needs a backend species-mutation endpoint), D8 (needs
  an app-shell decision) and D2 (explicitly Out of Scope in the story's own
  text). Each deferral is individually correct, so this is a wording problem,
  not an implementation one — but left as-is it will re-block every future
  re-audit of this screen. Recommend Scrum Master either narrow AC1 to the five
  named audit dimensions or accept the story with the deltas carried forward.
  Flagging rather than deciding: AC wording is Product Owner scope.
- **D8 is requirement-level work that this wave has not scheduled.** The Love
  Pet screen ships with no title and no bottom navigation while the design
  shows both. If REQ-002 Scope A's navigation/shell stories do not cover it,
  it will fall through the gap between them and this story.
- **D3 + D4 + D8 together** make the delivered screen substantially shorter
  than the reference. Integration review should confirm it still reads as
  intentional rather than truncated.
- D1 (hero radius, no 34px token) and D5 (hero copy `colorText` becomes a
  contrast defect the moment light theme is enabled) remain design-system token
  debts worth raising at requirement integration rather than losing at close.

## State Recommendation

- Leave `Implementation (Development)` unchecked in `story_master.md`
- Leave `Review (Reviewer)` unchecked
- Story status: `IN_PROGRESS`
- Return to **mobile-dev** for F7, F8, F9 — an evidence-artifact patch only
