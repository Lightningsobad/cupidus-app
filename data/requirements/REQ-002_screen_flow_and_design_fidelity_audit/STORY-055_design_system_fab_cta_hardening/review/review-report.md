# Review Report: STORY-055 Hardening - Design System FAB/CTA Shape and Sizing Fidelity

Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Story: STORY-055_design_system_fab_cta_hardening (Complexity: trivial, Lane: mobile, Retro-Type: RED-PATCH, RWB-20260816-021)
Review mode: compact-story-review
Reviewed commit: `72bf3dff2719b2122a1e2d44ea9124f199b7ccfc` (parent `029390757fc077eac20792996a1eb583b172cff5`)
Reviewer: Iris-QC
Date: 2026-08-19

Outcome: DEFERRED_ONLY

(Verdict history: this report reached `PATCH_REQUIRED` on the first pass (F-1) and again on the
second (F-2). Both are now resolved — see the two addenda at the end. The line above is the
final verdict and the only one workflow gates should read.)

## Scope Gate

Phase: SCOPE_GATE (inline, per compact-story-review)

- Review type: compact-story-review, mobile lane, UI-bearing, design source configured.
- Report path: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-055_design_system_fab_cta_hardening/review/review-report.md`
- Source/test files in scope (4, from the single implementation commit):
  `mobile/lib/design_system/adaptive/cupid_add_action.dart`,
  `mobile/lib/design_system/adaptive/cupid_primary_button.dart`,
  `mobile/lib/features/expenses/presentation/screens/expense_history_screen.dart` (1 line),
  `mobile/test/design_system/adaptive_widgets_test.dart`
- Evidence files in scope: `visual-fidelity/visual-fidelity-report.md` and the 6 PNGs in `visual-fidelity/`
- Independent source check: `cupid-app-design-system/project/Cupid Screens.dc.html` lines 875-889
- Query keys: AC1-AC5, `_materialFabSize`/`_materialFabRadius`/`_materialFabGlyphSize`, `_primaryCtaHeight`, `_primaryCtaFontSize`, `leadingIcon`, `_leadingIconGap`, M-1
- Diff note: `BaseHead` equals current worktree HEAD, so the diff was taken from `git show 72bf3df` per the handoff instruction.
- Phase 2 proceeded; no scope blocker.

## Acceptance Criteria

| AC | Verdict | Evidence |
|---|---|---|
| AC1 D-1 FAB shape/fill/glow/size/glyph | PASS | `cupid_add_action.dart` 60x60 `SizedBox` + `DecoratedBox(gradient: colors.gradientHot, borderRadius: 20, boxShadow: colors.glowShadow)`, transparent/zero-elevation FAB, `Icon(size: 27)`; matches design source line 881 verbatim (independently read); visible in `implemented-expense-emulator-5560.png` vs `design-reference-expense-android.png` |
| AC2 D-2 height/font/leading glyph | PASS | `_primaryCtaHeight` 54→52, `_primaryCtaFontSize` 15.5, `leadingIcon` optional (default `null`), glyph 21 + `SizedBox(width: 8)`; matches design source line 884 verbatim, including the 21px glyph the requirements left unspecified. Sole call site is `expense_history_screen.dart:227`, inside the existing `if (isIos)` branch (verified in code). Rendered in `implemented-expense-ios-cta-emulator-5560.png` |
| AC3 No regression across every real consumer | PARTIAL — see F-1 (superseded by F-2 in the resume pass below) | Compile/analyze/test half PASS (`flutter analyze`: 0 errors/0 warnings, touched files `No issues found!`; `flutter test`: 1313 passed / 2 skipped / 0 failed). Rendered spot-check half: `CupidPrimaryButton` closed in the resume pass; `CupidAddAction` unresolved |
| AC4 M-1 re-confirmed, not fixed | PASS | `implemented-expense-fab-overlap-emulator-5560.png` shows the last row `Nồi chiên không đầu` amount clipped to `1.20`, matching the report's claim; iOS capture at the same row renders the full `1.200.000₫`, so Material-only is confirmed by observation, not inference. Only `expense_history_screen.dart` edit in the diff is the one-line `leadingIcon:` — no scroll/padding change, as AC4 requires |
| AC5 Rendered visual-fidelity evidence | PASS | 4 `implemented-*` + 2 reused reference PNGs present; `visual-fidelity-report.md` records `VISUAL_FIDELITY: PASS` with per-property tables and named states, not a bare token; `Design-Screen: expense` recorded |

## Touched Risk Surfaces And Critical Gates

| Surface | Critical gate | Result |
|---|---|---|
| Mobile interaction / shared design-system component (25 call sites) | Targeted widget tests on both platform silhouettes | PASS — new FAB test asserts size/gradient/glow/radius/glyph; CTA tests assert 52/15.5/w800, 21pt glyph, measured 8pt gap, and no `Icon` descendant when `leadingIcon` is omitted |
| Mobile static analysis / build | `flutter analyze`, `flutter test` | PASS (evidence in `visual-fidelity-report.md` AC3 section; not rerun per prefer-existing-evidence) |
| Mobile design fidelity (12e2/12e3) | Implementer capture + comparison, verified by reading the images | PASS — both images open, both depict this story's Expense History screen in the built app, no error/blank/wrong-screen frame, and what is visible does not contradict the `PASS` for D-1/D-2 |
| Mobile navigation / discoverability (12e1) | Reachable entry point | PASS — no new capability or entry point; both components sit on already-reachable existing screens. Verified in code: the CTA is inside the existing Expense History `if (isIos)` sliver and the FAB is that screen's `Scaffold.floatingActionButton`; the screen is behind the `Ví chung` bottom-nav tab |
| Runtime startup smoke (12g) | Not required | Story `Complexity: trivial`, so 12g does not apply. The captures independently show the app launching on `emulator-5560` and reaching the screen without a crash or error frame |
| Setup/configuration | Not required | No env, dependency, runtime-registry, or infra surface touched; `deployment/configuration-guide.md` needs no update |

OQ discipline: `requirements.md` `## Open Question Impact` records no blocking OQ, OQ5 as RESOLVED (dark + `vi` only), and R8 as not applicable. Captures were taken in the shipped dark + `vi` configuration, matching the OQ5 resolution. No scope was blocked or over-blocked.

## Blocking Findings

### F-1 (AC3) — the rendered spot-check on non-anchor consumers was substituted, not performed

AC3 requires, verbatim: "a rendered spot-check across at least one full-screen consumer and one modal-sheet consumer other than the Expense History anchor (e.g. Dream Jar List and Add Expense Sheet) shows no overflow, clipping, or layout breakage".

`visual-fidelity-report.md` lines 139-142 answer this with: "Rendered spot-check beyond the anchor is covered by the widget tests, which build both components on both platform silhouettes; the height/font-size change is a 2pt shrink inside an already-`SizedBox`-constrained band and introduces no overflow or clipping." All 6 evidence files are the Expense History anchor plus STORY-043's two reused references — there is no non-anchor capture.

A widget test that builds the component in isolation is not a rendered check of the component inside a real consumer's layout, so this is a substitution for the AC's stated evidence, not a form of it, and no approved scope change or waiver permits it.

This is not purely formal. The story's own AC4 evidence establishes the mechanism: growing the FAB from 56x56 to 60x60 measurably worsened the clipping on the one screen that was rendered ("marginally wider than STORY-043 recorded", `visual-fidelity-report.md` lines 152-156). The other two `CupidAddAction` consumers — `dream_jar_list_screen.dart` and `gallery_empty_view.dart` — inherited the same 4pt growth and were never rendered, so the exact defect class this story confirmed on the anchor is unexamined everywhere else it ships. The reasoning offered in place of the capture ("a 2pt shrink … introduces no overflow") also addresses only the D-2 shrink and not the D-1 growth.

Per rule 12c the gate is `PATCH_REQUIRED` rather than deferred, because implementation can still supply it: `emulator-5560` and the preview build/capture procedure recorded in `visual-fidelity-report.md` lines 39-51 are the same ones needed, and this is the primary proof of the changed behavior on the 24 consumers outside the anchor.

## Deferred Findings

- D-1 (deferred, non-blocking): the FAB's design-source glow is hardcoded `0 8px 24px rgba(255,127,182,.45)` while the implementation uses the `glowShadow` token (`0 8px 28px rgba(255,107,168,.34)`). AC1 mandates the token, the implementation follows AC1, and the divergence is measured and recorded rather than silently substituted (`visual-fidelity-report.md` lines 81-90). Leave for a future FAB-glow token decision; do not change under this story.
- D-2 (deferred, non-blocking): `design-reference-expense-ios.png` does not show the iOS CTA — it falls below the reference render's visible area — so AC2's CTA comparison rests on the design-source HTML at line 884 rather than on the reference image. I re-read that line independently and the report's transcription (`height:52px`, `gap:8px`, `font-size:15.5px`, `font-weight:800`, glyph `font-size:21px`) is exact, so the evidence chain holds. Worth noting for any future story that reuses this reference pair for CTA work.
- D-3 (deferred, pre-existing, out of scope): the anchor captures differ from the reference on several screen-level points unrelated to these two components (summary caption wording, category chip count, absent back arrow, and the preview harness rendering without the bottom nav shell). These belong to the Expense History screen's own scope from STORY-028/STORY-043, not to `design_system/adaptive/**`, and this story did not make them worse. The `VISUAL_FIDELITY: PASS` here should be read as component-scoped to D-1/D-2, which is what the report's own verdict section states.

## Action Items

1. `[owner: mobile-dev]` (F-1) Capture and record the AC3 rendered spot-check: one full-screen non-anchor consumer (Dream Jar List — it carries both `CupidAddAction` and `CupidPrimaryButton`) and one modal-sheet consumer (Add Expense Sheet), using the same preview build and `capture-mobile-screen.sh` procedure already recorded in `visual-fidelity-report.md`. Add the captures to this story's `visual-fidelity/` and a short AC3 subsection stating, per capture, whether any overflow, clipping, or layout breakage is present — including whether the 56→60 FAB growth clips the last content row on Dream Jar List the way it does on the anchor. If clipping is found on a non-anchor screen, record it as an M-1-class screen-level finding with its disposition; do not fix it here, since consumer screen files are out of this story's write scope.
2. No other rework is required. AC1, AC2, AC4, and AC5 are met; do not re-capture the Expense History anchor and do not re-render the reused STORY-043 references.

## Traceability

- Requirements: `requirements/requirements.md` AC1-AC5, `## In Scope` items 1-5, `## Business Rules And Guardrails`, `## Open Question Impact`
- Story master: `story_master.md` `## Background` (D-1 corrected scope, D-2 verification, M-1 non-goal), write scope `design_system/adaptive/**`
- UX / Architecture: `SKIPPED:trivial` per `story_master.md` `## Artifacts` — consistent with rule 9 for trivial stories
- Design source: `cupid-app-design-system/project/Cupid Screens.dc.html` lines 881 (`isMD` FAB) and 884 (`isIOS` CTA), read independently; both transcriptions in the evidence are exact
- Implementation: commit `72bf3df`, 4 source/test files
- Evidence: `visual-fidelity/visual-fidelity-report.md` and the 6 PNGs in that directory
- Write-scope discipline: honored. The only non-`design_system/adaptive/**` lib edit is the single `leadingIcon:` argument AC2 explicitly sanctions; no scroll, padding, or behavior change anywhere.

## State Recommendation (superseded — see the final addendum)

- Uncheck `Implementation (Development)` in `story_master.md`
- Leave `Review (Reviewer)` unchecked
- Story status: `IN_PROGRESS`
- Return to `mobile-dev` with action item 1 only; re-review should be a `completion/resume` pass against F-1, not a fresh full review.

---

# Addendum — completion/resume pass (F-1 re-check)

Reviewer: Iris-QC (same reviewer, continuation)
Date: 2026-08-19
Reviewed commits since the verdict above: `d1d914d` (3 captures + AC3 subsection, mobile-dev) and `65d588c` (Scrum Master disposition paragraph)
Scope of this pass: F-1 / AC3 only. AC1, AC2, AC4, AC5 and deferred findings D-1/D-2/D-3 were not re-checked and are unchanged — no `mobile/lib` file changed in either commit.

The verdict line at the top of this report still stands. F-1 is **partially** resolved: the `CupidPrimaryButton` half is closed; the `CupidAddAction` half is not, for a reason the disposition does not address. Detail below as F-2.

## What is now closed

The three new captures exist, open as real images, and independently show what the AC3 subsection claims:

| Capture | What I see | Verdict |
|---|---|---|
| `implemented-jarlist-emulator-5560.png` | Dream Jar List in its `_LoadErrorView` state; the "Thử lại" CTA renders as a full 52pt gradient pill with its glow, label on one line, no truncation, no overflow stripe | PASS |
| `implemented-addexpense-sheet-emulator-5560.png` | A genuine `showModalBottomSheet` — drag handle present, Expense History dimmed behind it — with the "Lưu" CTA as a full 52pt gradient pill, both ends rounded, clear of the gesture inset, no leading glyph | PASS |
| `implemented-jarnew-sheet-emulator-5560.png` | Create Dream Jar form, three fields intact above a full-width 52pt "Tạo Dream Jar" gradient pill, no leading glyph | PASS |

AC3's "at least one full-screen consumer and one modal-sheet consumer other than the anchor" is satisfied for `CupidPrimaryButton`: Dream Jar List supplies the full-screen consumer and Add Expense Sheet the modal sheet. The absent leading glyph on both sheet CTAs is correct and confirms `leadingIcon` defaults to `null` in real consumers, not just under test.

The placement table is accurate. I re-read both call sites myself rather than accepting the citation:

- `dream_jar_list_screen.dart:67-82` — `Scaffold(appBar: CupidHeader(actions: [Semantics(child: CupidAddAction(...))]))`, supplied only for `DreamJarListEmpty`/`DreamJarListReady`. Not `Scaffold.floatingActionButton`. This also confirms why the FAB is absent from the error-state capture.
- `gallery_empty_view.dart:34-79` — the widget's build root is `Center > Padding > Column(mainAxisSize: MainAxisSize.min, children: [..., CupidAddAction])`. No `Stack`, no overlay.

So the disposition's core claim is correct as far as it goes: **M-1's overlay-versus-scroll-padding mechanism cannot recur at either non-anchor call site.** I accept that specific conclusion, and I do not require a rendered capture to re-prove it.

## F-2 (blocking) — the placement argument closes the wrong half of the risk

The disposition answers "can the FAB overlay and clip content?" (no). AC3's other half — "no overflow, clipping, or **layout breakage**" — and AC1's mandated 60x60 turn on a different question the placement check cannot see: **does the enlarged FAB fit the slot it was placed in?**

At `dream_jar_list_screen.dart:75` it does not:

- `cupid_header.dart:63` — `Size get preferredSize => const Size.fromHeight(kToolbarHeight)`, i.e. 56.
- `_MaterialHeader` (`cupid_header.dart:210-251`) passes `actions` straight into a Material `AppBar`, whose toolbar band is that same 56 and which lays its actions out in a height-constrained row.
- `cupid_add_action.dart` now requests `SizedBox(width: 60, height: 60)`. A 60pt-tall box inside a 56pt toolbar cannot render at 60: the incoming constraint clamps it to 56.

The FAB at that call site therefore renders about **60x56, not the 60x60 AC1 mandates**, with `BorderRadius.circular(20)` applied to a non-square box. Before this story it was the Material default 56x56 — square, and an exact fit for the toolbar. So D-1 changed that call site from a correct square to a squashed rectangle, at one of the three sites AC1 names explicitly ("observed on Expense History, Dream Jar List, and Gallery Empty View").

`gallery_empty_view.dart:78` is unaffected: a shrink-wrapped `Column` child receives loose constraints, so 60x60 renders as intended there.

Two things to be clear about:

1. This is analysis, not observation — I have not rendered Dream Jar List in `Empty`/`Ready`. That is precisely the point. It is a concrete, mechanism-named consequence of the D-1 change that is invisible both to the three captures (the FAB is absent from the error state) and to the placement argument (which reasons about overlay geometry, not about fit). A gate that misses it is not closing AC3.
2. It would not show up as an analyzer error or an overflow exception, so the passing `flutter analyze` and 1313-test run do not speak to it either. A constraint clamp is silent.

I therefore do not accept the disposition as sufficient closure of F-1/AC3, and the outcome does not change. To be explicit about where I agree and disagree with the Scrum Master call: accepting source verification *in lieu of a device capture* is a sound trade here, and I would not have blocked on the missing capture alone given the credential/write-scope constraint. What I cannot accept is the specific inference drawn from it — that non-overlay placement means "no further verification required". Non-overlay placement rules out one failure mode and creates a second one, because an app-bar action slot is height-constrained in a way a floating overlay is not.

## Action Item (supersedes action item 1 above)

`[owner: mobile-dev]` Verify the rendered size of `CupidAddAction` inside `CupidHeader.actions` on the Material silhouette. This does **not** need a device capture, credentials, or a `main_preview.dart` write-scope extension: add a widget-test case to `mobile/test/design_system/adaptive_widgets_test.dart` (already this story's write scope) that pumps `CupidHeader(title: ..., actions: [CupidAddAction(onPressed: () {})])` inside a `Scaffold(appBar: ...)` on `CupidPlatform.material`, and assert `tester.getSize(find.byType(FloatingActionButton))`.

- If it is 60x60, F-2 is disproved, AC1/AC3 close, and this story goes to a passing outcome with no code change.
- If it is 60x56 (or anything else), record the measured value and route the disposition to Scrum Master. The fix options touch `cupid_header.dart`, which `story_master.md` excludes from this story's write scope ("`cupid_add_action.dart` and `cupid_primary_button.dart` only"), so closing it is a scope decision, not something to absorb here. Documenting the deviation and raising a follow-up item against the header's toolbar height is an acceptable resolution; silently shipping a 60x56 FAB under an AC that says 60x60 is not.

Also worth correcting while there, both non-blocking:

- The AC3 subsection calls `implemented-jarnew-sheet-emulator-5560.png` a modal-sheet data point, but the capture renders as a full-page route (no drag handle, no dimmed backdrop). AC3's modal-sheet requirement is still met — `implemented-addexpense-sheet-emulator-5560.png` is a genuine sheet — so this is a caption fix, not an evidence gap.
- `implemented-jarlist-emulator-5560.png` shows a small flat-pink rounded-square control at the lower right, above the nav bar. It is not a `CupidAddAction` (post-fix those render with the hot gradient and glow, and the AC3 text correctly states the FAB is absent in this state), so it is outside this story. Noting it only so a future reader of this evidence does not mistake it for an unfixed FAB.

## State Recommendation (resume pass — superseded, see the final addendum)

Unchanged from above: `Implementation (Development)` unchecked, `Review (Reviewer)` unchecked, story `IN_PROGRESS`, return to `mobile-dev` for the single F-2 action item. The next re-review is again a `completion/resume` pass against F-2 alone — do not re-verify AC1, AC2, AC4, AC5, the three new captures, or the placement table, all of which are settled.

---

# Addendum 2 — completion/resume pass (F-2 disposition), final

Reviewer: Iris-QC (same reviewer, continuation)
Date: 2026-08-19
Reviewed since Addendum 1: `38bb1c3` (F-2 widget test + `RWB-20260816-027` backlog entry) and `9e1f7db` (doc cleanup: token, disposition paragraph, 2 caption corrections)
Scope of this pass: the F-2 disposition only. F-1, AC1-AC5 and the deferred findings were not re-checked; no `mobile/lib` file changed in either commit.

## F-2 is confirmed, then correctly disposed

The widget test added in `38bb1c3` measures what I predicted from the constraint analysis, so F-2 is now an observed fact rather than a reviewer inference:

```
expect(size, const Size(60, 56));
expect(size.height, kToolbarHeight);
```

Pinning `size.height == kToolbarHeight` alongside the literal size is the right call — it locks the mechanism, not just the number, so the follow-up item cannot "fix" the symptom while leaving the cause.

I verified all three cleanup items directly rather than from the commit message:

| Item | State |
|---|---|
| `VISUAL_FIDELITY` token | Plain `PASS` at both occurrences (line 3 and line 347); the non-standard `PASS_WITH_DOCUMENTED_DEVIATION (F-2)` is gone. Correct — the token reports the rendered comparison verdict for the anchor screen pair, which does match with no visible deviation; the 60x56 is an AC-text deviation at a call site with no rendered design reference of its own, and it stays visible in the F-2 section and the `## Verdict` list rather than being folded into the token |
| Scrum Master disposition paragraph | Present verbatim at lines 318-329, immediately after the F-2 section and before `## Verdict`, citing `RWB-20260816-027` and its owners |
| 2 caption corrections | Both present — evidence table (line 27) and per-capture verdict table (line 158) now describe `implemented-jarnew-sheet-emulator-5560.png` as a full-page route, not a modal sheet. The added prose also explains why (`_buildJarnew` wraps `CreateDreamJarSheet` in a bare `Scaffold`) and correctly notes AC3's modal-sheet requirement is met by the Add Expense Sheet capture. The flat-pink-control note I raised was also added |

`RWB-20260816-027` exists and is real — I read it rather than trusting the citation. It carries both a registry row and a full detail section in `data/retro-audit/rework-backlog.md`, `Status: PENDING`, owner UI/UX Designer + Tech Lead, with the mechanism, the measurement, the affected call site, the unaffected one, the test that pins it, and the instruction to flip that assertion to `Size(60, 60)` once fixed. That is the condition my Addendum 1 acceptance rested on, and it is met.

## Why DEFERRED_ONLY rather than CLEAN or PATCH_REQUIRED

Not `CLEAN`: AC1 states 60x60 "observed on Expense History, Dream Jar List, and Gallery Empty View", and at Dream Jar List the shipped box measures 60x56 with a 20px radius meant for a square. That is a real, confirmed deviation from exact acceptance-criterion text, and a `CLEAN` verdict would assert nothing is outstanding when something is.

Not `PATCH_REQUIRED`: the deviation cannot be fixed inside this story. Every available fix edits `cupid_header.dart`, which `story_master.md` excludes from write scope, and the right fix is genuinely a UX question — whether a header action slot should carry the full 60x60 gradient-glow FAB treatment at all, or a toolbar-sized variant — not a mechanical height bump. Forcing it into this story would either break the declared write scope or hard-code a design decision that belongs to UI/UX and Tech Lead.

`DEFERRED_ONLY` is what that combination means: the story can close, with the deviation preserved as a note rather than dissolved. This is not a deferred *critical gate* in the 12c sense — D-1's primary proof (the rendered 60x60 anchor capture with gradient, glow, 20px radius and 27px glyph) is present and passing, as is the 60x60 standalone measurement. What is deferred is one secondary call site's conformance, and it is deferred with a measurement, a pinned test, and an owned backlog item rather than with a promise.

## Deferred Findings (final list)

D-1, D-2 and D-3 from the original report stand unchanged, plus:

- **D-4 (from F-2)** — `CupidAddAction` renders 60x56 instead of AC1's 60x60 inside `CupidHeader.actions` (`dream_jar_list_screen.dart:75`), clamped by the Material `AppBar` toolbar band at `kToolbarHeight`. `gallery_empty_view.dart:78` and the Expense History anchor are unaffected. Documented in `visual-fidelity/visual-fidelity-report.md` F-2 section, pinned by `mobile/test/design_system/adaptive_widgets_test.dart` ("Material FAB is clamped to 60x56 inside CupidHeader.actions"), and tracked as `RWB-20260816-027` for UI/UX Designer + Tech Lead. No action inside STORY-055.

## Operational note for Scrum Master

`RWB-20260816-027` is `PENDING` in `data/retro-audit/rework-backlog.md` as of this pass. Under the pending-retro rule that gates plain ordinary `continue`, opening it has queue consequences beyond this story. That is a scheduling decision for you, not a review finding — flagging it only so the new item is not a surprise at the next continuation.

## State Recommendation (final)

- Keep `Implementation (Development)` checked
- Check `Review (Reviewer)`
- Story status: `DONE`
- Carry D-4 forward via `RWB-20260816-027`; no further Reviewer pass is needed for STORY-055.
