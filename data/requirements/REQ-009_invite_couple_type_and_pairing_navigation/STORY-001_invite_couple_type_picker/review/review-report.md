---
story_status_recommendation: "IN_PROGRESS"
implementation_status_recommendation: "UNCHECK"
reviewed_at: 2026-08-24
reviewed_by: Reviewer
review_cycle: 2
---

# Review Report: STORY-001 Invite Couple-Type Picker

Outcome: PATCH_REQUIRED

## Scope Gate

- Review type: `compact-story-review`, cycle 2 (re-review after the F1/F2 patch)
- Diff baseline: `git -C <worktree> diff 90f531f1` (16 files, +2502/-20)
- Source/test files in scope (6): `mobile/lib/features/pairing/presentation/couple_type.dart`,
  `mobile/lib/features/pairing/presentation/invite_cubit.dart`,
  `mobile/lib/features/pairing/presentation/screens/invite_screen.dart`,
  `mobile/lib/main_preview.dart`,
  `mobile/test/features/pairing/presentation/invite_cubit_test.dart`,
  `mobile/test/features/pairing/presentation/invite_screen_test.dart`
- Evidence files in scope: `coding-plan/test-results.md`, `ux/ux-spec.md` §4/§6.3/§6.5/§6.8,
  `visual-fidelity/design-reference-invite-couple-type-android.png`,
  `cupid-app-design-system/Cupid Screens.dc.html` §`isInvite`,
  `cupid-app-design-system/Cupid App.dc.html`,
  `data/devops/system/design-fidelity-config.json`
- Focused query keys: AC1-AC7, `_CoupleTypeCell`, `_coupleIconSize`,
  `Entry Point Reachability`, `design_sources`, `cupid-screens`, `Cupid Screens`

## Prior-Cycle Findings — Disposition

| Prior finding | Disposition |
| --- | --- |
| F1 — the §6.8 "no design source exists" exemption is factually wrong | **PARTIALLY RESOLVED.** The source question is now correctly answered and a real render exists. The *deltas that the render exposed were documented but never fixed*, and §6.8 itself picked up three new false statements. See F3 and F4. |
| F2 — missing `## Entry Point Reachability` evidence section | **RESOLVED.** See below. |
| D1 — card 4 semantic drift (`LIVING_TOGETHER`) | Still deferred; basis unchanged (no code changed). |
| D2 — `submitCoupleType()` returns `false` with a null save seam | Still deferred; basis unchanged. |

### F2 is genuinely closed

`coding-plan/test-results.md:310-343` now carries `## Entry Point Reachability`
with `Reachable: YES` and a four-link chain. I did not take the cited lines on
trust:

- `_CoupleTypeSection`/`_CoupleTypeGrid`/`_CoupleTypeRow`/`_CoupleTypeCell` are
  indeed library-private classes in `invite_screen.dart` (`:531`, `:565`, `:593`,
  `:634`), so the "isolated mounting is impossible by construction, only
  real-navigation reachability is meaningful" argument is correct, not an excuse.
- I re-ran the cited suites unfiltered:
  `flutter test --no-pub --reporter compact invite_screen_test.dart invite_cubit_test.dart screens/pairing_choice_screen_test.dart`
  → `00:03 +38: All tests passed!`, including
  `renders both entry actions under the pairing stack key`,
  `the primary action opens invite`, and all six `AC*:` widget cases.

## Independent Verification Performed

| Check | Reviewer result |
| --- | --- |
| Which commits touched `mobile/` in `90f531f1..HEAD` | **only `708935f`** — the original implementation commit. The five later commits (`6eadeb7`, `f30a17a`, `c2f800d`, `dc8f0a1`, `f122ae1`) are `data/` only |
| `flutter test` on the three AC-bearing suites | `00:03 +38: All tests passed!` |
| Design markup, read directly | `Cupid Screens.dc.html:180-196` — verified line by line |
| Rendered reference PNG, viewed | `visual-fidelity/design-reference-invite-couple-type-android.png` — genuine, 406x900, android/dark/vi, shows the couple-type grid with card 2 selected |
| `design_sources[]` contents | `design-fidelity-config.json:38-80` — exactly two entries, `cupid-app` (`:51`) and `cupid-web` (`:75`). **No `cupid-screens`** |
| `Cupid App.dc.html` composes the screen library | grep reports 2 occurrences of `Cupid Screens` inside it — consistent with `screens_from: "dom"` and with the render output |

## Outcome Summary

- Review outcome: PATCH_REQUIRED
- Rationale: the patch cycle resolved the *evidence* half of F1 and closed F2
  properly. It did not resolve the *substance*: the design comparison ran,
  confirmed four real deltas plus eight further metric divergences, and then
  landed no code. The build now contradicts its own patched, authoritative
  `ux/ux-spec.md` on every one of those four points, so AC6 is further from
  satisfied than it was last cycle — the spec moved toward the design and the
  build stayed put.
- Blocking findings: 2 (F3, F4)
- Deferred findings: 2 (D1, D2, both carried forward unchanged)
- Behavioural gates: AC1-AC5, AC7 PASS. AC6 FAIL.

## Blocking Findings

### F3 — AC6: the confirmed deltas were documented, not fixed; the build now contradicts its own spec

`coding-plan/test-results.md:218-220` states the position plainly: *"Evidence-only:
no `mobile/lib/` file was modified by this pass. Every delta below is a finding
for the review gate / a follow-up story, not a fix landed here."* The git history
confirms it — only `708935f` touched `mobile/` across the entire story range.

But `ux/ux-spec.md` is the authoritative design artifact and it was rewritten in
this same cycle to prescribe the corrected design. `ux-spec.md:227-228` is
explicit about what it expects: *"mobile-dev must patch layout, not just
re-capture a screenshot."* That instruction was not executed. No owner ever
recorded a decision to defer it; mobile-dev proposed deferral in `test-results.md`
and nothing accepted it.

I verified both sides of each delta myself rather than reading the delta table:

| # | `ux-spec.md` now requires | `invite_screen.dart` actually does | Design source |
| --- | --- | --- | --- |
| 1 | Supporting subtext line directly under the heading, above the grid (`§6.3:107`, `§6.5:132`) | `:547-558` — heading `Text` → `SizedBox(height: CupidSpacing.md)` → `_CoupleTypeGrid`. No second `Text` exists | `Cupid Screens.dc.html:181` — `font-size:12.5px;color:var(--tx2);margin-bottom:12px`, "Cupid sẽ bật/tắt tính năng phù hợp cho kiểu của bạn." |
| 2 | 38x38 tile, radius 13, `gradientHot` selected / muted fill unselected, 21px glyph, glyph color state-driven (`§6.5:140`, `§6.8:256`, `§6.8:265`) | `:715-721` — bare `CupidIcon(coupleType.icon, size: _coupleIconSize, color: colors.colorText)`, no wrapping `Container`. `_coupleIconSize = 28` (`:72`). Glyph color is `colorText` in **both** states, so the tile-fill selection signal is absent entirely | `:186` selected — `width:38px;height:38px;border-radius:13px;background:var(--grad-hot)` + `font-size:21px;color:#fff`; `:193` unselected — same box, `var(--surf2)`, `color:var(--tx2)` |
| 3 | Left-aligned top-to-bottom block, explicitly "not centered" (`§6.5:139-142`) | `:712-714` — `Column(mainAxisSize: MainAxisSize.min)` at default `CrossAxisAlignment.center`, reinforced by `textAlign: TextAlign.center` on label `:725` and subtext `:738` | `:185`-`:196` — plain block `div`s, no `text-align`, no flex centering |
| 4 | `14`px horizontal / `16`px vertical cell padding (`§6.8:255`) | `:677-680` — `EdgeInsets.symmetric(vertical: CupidSpacing.md, horizontal: CupidSpacing.sm)` = 16 vertical / **8** horizontal | `:185`/`:192` — `padding:16px 14px` |

Beyond those four, `test-results.md`'s own R1-R8 remain unreconciled and I
confirmed the load-bearing ones against the markup: icon→label gap 4 vs `:187`
`margin-top:10px`; label→subtext gap `_coupleLabelGap = 2` (`:73`) vs `:188`
`margin-top:3px`; grid gutter `CupidSpacing.sm` = 8 (`:582`, `:616`) vs `:182`
`gap:10px`; heading `type.body` = 17 (`:552-555`) vs `:180` `font-size:16px`;
section rhythm 24 vs `:169` `gap:20px`; selected fill `0.3`/`0.26` (`:88-89`) vs
`:185` **both `.22`**.

AC6 requires "no visible deviation in layout, spacing, colour, typography, or
state." There are confirmed deviations in all five categories. R9/R10/R11 I agree
are correctly classified as non-defects (glyph substitution per §6.7, PO catalog
copy supersedes canvas placeholders, CTA destination is STORY-002's) — those are
sound calls and I am not reopening them.

**Two of the "11 refinements" were mischaracterised as landed.** `story_master.md:70-71`
says "11 further R1-R11 refinements (2 are corrections to `ux-spec.md` itself, not
the build)". R1 and R2 are those two, and neither correction was actually made:
`ux-spec.md:256` still reads "icon-tile-to-label gap `CupidSpacing.xs` (4px);
label-to-subtext gap 2px", and `§6.5:141-142` still says the same. They were
*identified* in `test-results.md`, not *corrected* in the spec. Fold both into the
same rework.

### F4 — `ux-spec.md` §6.8 carries a false present-tense claim, a false blocker, and an unexecutable render command

The §6.8 rewrite fixed the original wrong premise but introduced three new
statements that do not survive checking. This matters because §6.8 is what the
next story touching this screen will read.

1. **False registration claim.** `:205-206`: *"This source has been registered as
   an additional entry in `design-fidelity-config.json`'s `design_sources[]`
   (`id: "cupid-screens"`)"* — asserted in the present perfect, as fact. It was
   not. `design-fidelity-config.json:38-80` contains exactly two entries,
   `cupid-app` and `cupid-web`. The paragraph then contradicts itself three lines
   later (`:207-212`, guard rejected the edit 3 times). The leading sentence must
   be retracted, not merely qualified downstream.

2. **False blocker.** `:211-215`: *"Scrum Master/DevOps must land the
   `design_sources[]` registration for `Cupid Screens.dc.html` ... **before the
   rendered-fidelity gate below can run automated capture**."* Disproven within
   the same cycle. mobile-dev rendered the node with no config change at all
   (`test-results.md:260-262`), because the invocation used the **already-registered,
   locked** source: `design-fidelity-config.json:43` `entry: "Cupid App.dc.html"`,
   `:44` `screens_from: "dom"`, `:48` `locked: true`, `:52` `surface: "mobile"`.
   No registration was ever required, and none is required now. Leaving this in
   the spec parks a phantom DevOps dependency on the next story.

3. **Unexecutable render command.** `:246-249` names `Cupid Screens.dc.html` as
   the thing to render via `render-design-canvas.js --screen=invite`. That cannot
   work: rendered standalone it enumerates `screens: []` / `screens_from: "none"`
   and `--theme=dark` fails with `DESIGN_CANVAS_TOGGLE_MISSING`
   (`test-results.md:250-254`). The working invocation is
   `--entry="Cupid App.dc.html" --screen=invite`.

**On the entry-file question specifically: mobile-dev is right and the ux-spec is
wrong.** These two facts are both true and are not in tension —
`Cupid Screens.dc.html:168-203` is the authoritative *markup* for the `isInvite`
node, and `Cupid App.dc.html` is the composing shell that owns the
`screen`/`platform`/`theme`/`lang` toggles and is the registered `entry` (grep
finds 2 references to `Cupid Screens` inside it, consistent with
`screens_from: "dom"`). The spec's only error is prescribing the library file as
a render *entry*. mobile-dev's entry choice, its stated reason, and the resulting
PNG all check out — I viewed the render and it shows exactly the markup at
`:180`-`:196`.

**One further internal inconsistency in the rewrite.** `§6.5:132` prescribes a
"`2`px gap below the heading" while citing, in the same parenthesis, the design's
`margin-bottom:4px`. Design `:180` is `margin-bottom:4px` (heading→subtext) and
`:181` is `margin-bottom:12px` (subtext→grid), but `§6.3:107` specifies
`CupidSpacing.md` (16px) for the latter. Three numbers for two gaps, none
reconciled. Settle them against `:180`/`:181` when the subtext line is built.

## Deferred Findings

- **D1** — Card 4 semantic drift ("Gắn bó lâu dài" → `LIVING_TOGETHER`) remains
  properly recorded in `architecture/solution.md` §6, `story_master.md`, and at
  `couple_type.dart:55-58`. No code changed; basis unchanged. Carried forward.
- **D2** — `InviteCubit.submitCoupleType()` returns `false` when `_saveCoupleType`
  is null, so a composition omitting the seam shows the retry snackbar rather
  than a no-op. Production wires the seam; preview/test-only. Carried forward.

## Residual Risks

- `visual-fidelity/` holds only the reference PNG — there is no
  `visual-fidelity-report.md` and no `VISUAL_FIDELITY:` verdict line anywhere in
  the story (confirmed via `git ls-files`). The comparison *substance* is present
  and is good work, but it lives in `test-results.md` with no verdict, so no
  automated gate can read a pass/fail from it.
- Implemented-side capture remains `DEVICE_CAPTURE_BLOCKED`. Accepted as a known
  environment constraint under DevOps remediation, and not load-bearing for this
  outcome: F3 is established from source-vs-markup comparison, which does not
  need a device screenshot.
- `design-fidelity-config.json:24`, `:61`, `:78` all carry
  `drifted_at: 2026-08-24T09:53:10Z` — the design bundle's content fingerprint is
  currently flagged as drifted repo-wide. Not this story's defect, but any pixel
  comparison run today inherits it. Worth a DevOps note.

## Implementation Action Items

- `[mobile-dev] invite_screen.dart` — implement what `ux-spec.md` §6.5/§6.8 now
  specifies, in `_CoupleTypeSection`/`_CoupleTypeCell`: (1) add the supporting
  subtext line under the heading; (2) wrap the glyph in a 38x38 / radius-13 tile
  with `gradientHot` selected and muted-surface unselected fill, glyph 21px with
  state-driven color; (3) switch the cell `Column` to
  `CrossAxisAlignment.start` and drop both `textAlign: TextAlign.center`;
  (4) set cell padding to 14 horizontal / 16 vertical. Then re-run the AC suite —
  the AC1 dx/dy ordering assertions will need updating for the new alignment.
- `[mobile-dev or ui-ux-designer] ux-spec.md §6.5/§6.8` — land the R1/R2
  corrections that `story_master.md` already claims landed: icon-tile→label gap
  10px (not `CupidSpacing.xs`), label→subtext gap 3px (not 2px). Decide R3/R7/R8
  (gutter 8 vs 10, heading 17 vs 16, section rhythm 24 vs 20) explicitly — either
  transcribe the design value or record the token-scale deviation as accepted,
  but do not leave them unstated. R6 (`0.3`/`0.26` vs the design's `.22` on both
  stops) needs the same explicit call, since it is currently an inherited
  `_MoodCell` value rather than a decision.
- `[ui-ux-designer] ux-spec.md §6.8` — retract the "has been registered"
  sentence (`:205-206`); delete the "must land the registration before the gate
  can run" blocker (`:211-215`), which the render already disproved; correct the
  "Visual reference(s)" render instruction (`:246-249`) to
  `--entry="Cupid App.dc.html" --screen=invite`, keeping
  `Cupid Screens.dc.html:168-203` named as the authoritative markup. Reconcile the
  §6.5:132 / §6.3:107 gap numbers against design `:180`/`:181`.
- `[mobile-dev] visual-fidelity/visual-fidelity-report.md` — after the patch,
  write the report with the resolved `Design-Screen`, the per-state comparison,
  and an explicit `VISUAL_FIDELITY:` verdict. Device capture may stay
  `DEVICE_CAPTURE_BLOCKED` with that reason recorded.

## Workflow State Recommendation

- Story status: `IN_PROGRESS`
- `Implementation (Development)`: **`UNCHECK`** — changed from last cycle's
  `KEEP_CHECKED`, deliberately. Last cycle the rework was evidence-only and the
  code was complete against the then-current spec. It no longer is: `ux-spec.md`
  §6.5/§6.8 now specifies a card composition the build does not implement, so the
  remaining work is a real `invite_screen.dart` change plus test updates, not
  documentation.
- `Review (Reviewer)`: `LEAVE_UNCHECKED`
- Next step: route to `mobile-dev` for the four layout fixes plus the spec-metric
  reconciliation and the fidelity report; `ui-ux-designer` (or mobile-dev, if
  Scrum Master prefers a single lane) for the three §6.8 retractions; then
  re-review.
- Note for Scrum Master: STORY-002's branch also wrote
  `mobile/test/features/pairing/presentation/invite_screen_test.dart`. The F3 fix
  will touch that same file's AC1 ordering assertions, so the merge-time conflict
  on it gets slightly larger. Not a defect in this story.
- This report does not edit `story_master.md`; state updates are
  `scrum-master`-owned.
- State update owner: `scrum-master` only.
