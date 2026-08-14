# STORY-032 Review Report — Final Synthesis

Story: STORY-032 Design System — App-Shell Background, Button & Header Follow-Up
Requirement: REQ-002 (Scope B, Full Design Fidelity Audit) · Lane: mobile
Complexity: standard · Story-Class: standard
Review type: Tier-3 scoped-slice, 4 slices + final synthesis
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-032`
BaseHead: `079d4801831037e2540a813f66efe5e4258eaae4`
Worktree HEAD at synthesis: `e86b8ca958a592d396cd1e057c02ccd07dcb0b06`
MergeTarget: `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`
Design source: `cupid-app-design-system` (locked)
Reviewed: 2026-08-14

Outcome: DEFERRED_ONLY

All three blocking findings raised by the slice passes (F1, F2, F3) are closed
and independently verified below. No blocking finding remains. Everything else
is deferred follow-up or a merge-time instruction for Scrum Master.

## Slice Roll-Up

| Slice | Scope | Slice verdict | Blocking findings | Status now |
| --- | --- | --- | --- | --- |
| 1 `phase1-foundation` | AC1 (shared layer) | PASS | none | closed |
| 2 `phase2-screens-a` | AC1, AC4[Forgot], AC5 | PATCH_REQUIRED | F1 | F1 closed |
| 3 `phase2-screens-b` | AC1 (9 screens) | PASS | none | closed |
| 4 `phase3-shared-components` | AC1-AC5 | PATCH_REQUIRED | F2, F3 | both closed |

The closing patch is commit `e86b8ca`. I confirmed it is evidence-only: its
tree touches six files, all under
`STORY-032_design_system_app_shell_follow_up/visual-fidelity/`, and no
application source. The `source_changed: false` claim holds.

## (a) F1 / F2 / F3 Closure Against Reviewer Rule 12e3

Rule 12e3 requires, per screen: a resolved `Design-Screen` id, a
design-reference render, an app render, and an explicit
`VISUAL_FIDELITY: PASS|FAIL` verdict. All three screens now carry all four.

| Screen | `Design-Screen` | App render | Design reference | Verdict line | Closes |
| --- | --- | --- | --- | --- | --- |
| Forgot Password | `forgot` | `ac4-forgot-password-dark-vi.png` | `design-reference-forgot-android.png` | present, PASS | F1 |
| Waiting For Pairing | `waiting` | `ac4-waiting-for-pairing-dark-vi.png` | `design-reference-waiting-android.png` | present, PASS | F3 |
| Vibe Check (`CupidHeader` carrier) | `vibe` | `ac3-vibe-header-dark-vi.png` | `design-reference-vibe-android.png` | present, PASS | F2 |

The non-conforming "CONFIRMED AT RENDER" verdict line that slice 2 and slice 4
both rejected is gone; the report now carries a document-level verdict plus one
per-screen verdict each.

**F1 — closed.** The Forgot Password package now has all four elements. I did
not take the provenance on faith: the three design references are asserted to be
byte-identical copies of the `REQ-001/STORY-018_design_fidelity_capture` set at
commit `124d816`. Verified three ways — `shasum -a 256` on all three files
reproduces the exact digests recorded in the report; `cmp` against the blobs read
out of `124d816` reports byte-identical for all three; and
`git merge-base --is-ancestor 5ea820c 124d816` confirms the design-bundle commit
is an ancestor of those renders, so they come from the locked export checked out
now. Reuse is legitimate, not stale. I also opened
`design-reference-forgot-android.png` directly: it is the correct screen and
matches the report's description down to the seeded `minh@gmail.com` field and
the gradient "Gửi link đặt lại" CTA with its pink glow.

**F2 — closed.** This was the weakest point in the whole package (AC3 had zero
visual evidence), so I verified it by inspection rather than by report text. I
opened `ac3-vibe-header-dark-vi.png`: it is a genuine dark + `vi` render of
`VibeScreen`, which mounts an unmodified `CupidHeader`. The purple lobe of the
sky wash continues unbroken straight through the header strip with no opaque
band and no seam at the header's bottom boundary — which is the specific
deviation AC3 forbids — and the back glyph renders as a pink left-pointing
arrow. Compared against `design-reference-vibe-android.png`, the header
treatment corresponds on surface transparency and back-glyph colour/size. AC3
now has real rendered proof, not only widget-tree assertions.

**F3 — closed.** Same three elements now present for `waiting`. I opened
`design-reference-waiting-android.png` and it matches the report's declared
out-of-scope deviation exactly: the reference carries the hourglass-in-ring
glyph, "Đang đợi Linh vào…", the `CPD-8F2K` invite-code card and a "Gửi lại"
gradient CTA, none of which the app's generic state renders. That deviation is
screen-content scope, already recorded as a STORY-018 `waiting` DEVIATION, and
untouched by this story's one-line `backgroundColor` removal.

**Slice 3's O-1 hypothesis stays refuted.** Slice 3 proposed that
`main_preview.dart` never mounting `CupidAppBackground` was the root cause of
F1. Slice 4 refuted it; I confirm the refutation from the committed harness.
`capture_cupid_header.dart:95-96` builds its own `MaterialApp` with
`builder: (context, child) => CupidAppBackground(child: child!)`, bypassing
`main_preview.dart` entirely, and the resulting render visibly carries the wash.
F1/F2/F3 were documentation-completeness gaps, and the patch that closed them was
correctly editorial-plus-renders rather than a code fix.

## (b) Disposition Of Every Non-Blocking Item

| ID | Origin | Subject | Disposition |
| --- | --- | --- | --- |
| N-1 | slice 1 | Composition-root wiring not asserted by any test | Substantively resolved; residual DEFERRED |
| N-2 | slice 1 | Root ticker never settles, `pumpAndSettle` hangs | Accepted, no action |
| N-3 | slice 1 | `shouldRepaint` compares layers by list identity | DEFERRED, not reachable today |
| N-4 | slice 4 | CTA label uses `--tx` where design says `#fff` | DEFERRED as a decision |
| N-5 | slice 4 | One new iOS assertion is vacuous | DEFERRED cleanup |
| N-6 | slice 4 | `BackdropFilter` is inert but costs a `saveLayer` | Accepted, no action |
| F4 | slice 4 | AC4 captures not reproducible | Largely resolved; residual DEFERRED |
| O-1 | slice 3 | `main_preview.dart` never mounts `CupidAppBackground` | Refuted for this story; DEFERRED as requirement-level follow-up |
| O-2 | slice 3 | Three wrong handoff paths | Informational, no defect |

**N-1 — substantively resolved, small residual deferred.** The concern was that
`CupidAppBackground` might be an unconsumed abstraction, since nothing asserted
that booting `CupidApp` mounts it. The three renders answer this in the way AC4
intended: all three were produced through a composition root that mirrors
`CupidApp`'s (`builder: … CupidAppBackground(child: child!)`,
`buildCupidTheme(material, dark)`, `locale: vi`), and all three visibly carry the
wash on real screens. The abstraction is demonstrably consumed. The residual is
narrow and worth keeping: no test asserts the wiring in `cupid_app.dart:43-44`
itself, so a future edit could delete that line and every test would still pass.
Deferred follow-up, near-zero cost — one
`expect(find.byType(CupidAppBackground), findsOneWidget)` in `widget_test.dart`.

**N-2 — accepted.** The continuous twinkle ticker is inherent to the design
source's animation, and the two affected tests were switched to explicit `pump`
calls with an inline reason. AC5 asks for intentional test changes to be called
out rather than silently changed; they are called out in `story_master.md`'s
Phase 1 bullet and in the test files. Worth noting the constraint is now
inherited by any future test that boots `CupidApp`.

**N-3 — deferred.** Correct for both current callers (the `darkLayers` /
`lightLayers` const statics have distinct identities, so a brightness flip
repaints). Only a latent trap if someone later passes an equal-but-newly-built
list. Not reachable today; no change requested.

**N-4 — deferred as a recorded decision, not an oversight.** The CTA label uses
`colors.colorText` (`--tx` = `#F7EEFB`) where the design source CTA blocks say
`color:#fff` — three units per channel. This sits below AC2's stated bar ("no
visible flat-color deviation") and is disclosed in the visual-fidelity report. I
agree with slice 4 that using the token is the more defensible choice than
hard-coding `#fff`; leaving it is deliberate.

**N-5 — deferred cleanup.** The iOS header assertion
`isNot(contains(dark.colorBackground))` over `Container` descendants now runs
against an empty iterable, because `_IosHeader` contains no `Container` after the
restyle (confirmed: it is `ClipRect > BackdropFilter > Padding`). It would pass
even if the header were deleted. Real coverage is carried by the sibling
`BackdropFilter` `findsOneWidget` assertion in the same test, so this is dead
weight rather than a coverage hole.

**N-6 — accepted.** Both headers force a `saveLayer` plus a 16-sigma blur per
frame while sampling a smooth gradient. Faithful to the design source, which is
likewise `flex:none` in normal flow. Note only, if header jank is ever reported
on low-end Android.

**F4 — largely resolved, residual deferred.** Slice 4 asked Final Synthesis to
decide explicitly whether prose parameters are an acceptable reproducibility
standard. They are no longer the standard: `capture_cupid_header.dart` is now
committed next to the evidence, and I read it — it is a genuine runnable harness,
not a sketch. It pins every parameter that matters: `FontLoader` for the four
bundled families in `setUpAll` (without which `flutter test` renders the
placeholder font), the 2600 ms capture frame with the reasoning for that instant,
`Size(390, 844)` at `pixelRatio: 3`, and `tester.runAsync()` around `toImage`
because the fake-async zone never completes the engine future. My decision: this
clears the substance of F4. The residual, deferred rather than blocking, is that
the harness captures only the AC3 vibe render; the two AC4 PNGs predate it and
re-running it will not regenerate them. It is the executable record of their
parameters, not a regenerator for them.

**O-1 — refuted for this story, deferred as requirement-level follow-up.** It is
not the cause of F1/F3 (see above) and `main_preview.dart` is untouched by this
story's diff, so it is out of STORY-032's scope. But the underlying observation
stays true and now matters more than it did: because `cupid_theme.dart:45` makes
every `Scaffold` transparent, any screen rendered through `main_preview.dart`
composites over nothing rather than over the sky wash. Any future REQ-002 story
that captures visual evidence via the preview harness will produce a misleading
render. Worth an owner at requirement level.

**O-2 — informational.** Three handoff paths did not match the tracked layout
(`pairing_required_gate.dart` under `features/expenses/presentation/widgets/`;
both love-contract files under `features/love_contracts/`, plural; `pet_screen.dart`
and `vibe_screen.dart` with no `screens/` segment). Slices 3 and 4 both resolved
against `git ls-files` before reviewing and no file was skipped. No defect.

## New Findings From Synthesis

These were not visible to any single slice, because each needed either the merge
target or two slices' scope at once. None is blocking.

### S-1 — the report's AC3 title-typography row claims a match that does not exist (Low, deferred)

`visual-fidelity-report.md:197` compares the design source's
`title Nunito 800 21px` against the app render and records "Vibe Check", same
weight and face". That is not accurate. The Material header sets
`titleTextStyle: type.cardTitle.copyWith(color: colors.colorText)`
(`cupid_header.dart:180`), and `cardTitle` is
`fontFamily: uiFontFamily, fontWeight: w600, fontSize: 22`
(`cupid_typography_tokens.dart:36-40`) — the platform UI font, not Nunito, at
w600 rather than w800. The face and the weight both differ from the design source.

I am not raising this to blocking, for two reasons. AC3 enumerates
"transparent/blurred surface, glyph styling" and "no visible opaque-band
deviation", and every element it names does match; title typography is not among
them. And the correct fix already exists on the merge target — see S-2 — so
demanding a patch here would duplicate another story's landed work. The defect is
that the report asserts a match rather than recording a delta, which matters
because the report opens by promising nothing is absorbed into the PASS silently.
Recording it here discharges that promise.

### S-2 — merging this branch will revert two of STORY-033's landed header fixes unless the conflict is resolved deliberately (Medium, merge-time instruction for Scrum Master)

Slice 4 flagged a STORY-033 collision on the back-arrow ink and asked synthesis
to confirm it. I checked the merge target directly. The back-arrow ink is a
non-issue: both branches converged on `colorAccentPink` at `size: 26`, so that
change is idempotent. The real collision is elsewhere, and slice 4 could not have
seen it from inside the story branch.

`git diff <integration> HEAD -- mobile/lib/design_system/adaptive/cupid_header.dart`
shows the integration branch's `_MaterialHeader` already carries STORY-033's
work, which STORY-032's version does **not** have:

- `scrolledUnderElevation: 0`
- `titleTextStyle: type.display.copyWith(fontSize: 21, fontWeight: FontWeight.w800, letterSpacing: -0.21)`
  — `display` is Nunito (`cupid_typography_tokens.dart:31-35`), so this is the
  exact `Nunito 800 21px` the design source specifies, and it is precisely what
  S-1 says STORY-032's `cardTitle` does not deliver.

Taking STORY-032's side wholesale at merge would silently revert both on an
already-closed story. I ran a read-only trial merge
(`git merge-tree --write-tree`) against the integration tip: it conflicts in 8
files, `cupid_header.dart` among them. The good news is that the conflict is
loud, not a silent overwrite — Scrum Master will be forced to resolve it rather
than lose the change unnoticed.

Required resolution for `cupid_header.dart`, so neither story's work is lost:

- Keep from integration/STORY-033: `scrolledUnderElevation: 0` and the
  `type.display.copyWith(fontSize: 21, fontWeight: w800, letterSpacing: -0.21)`
  `titleTextStyle`. Do **not** let `type.cardTitle` win.
- Keep from STORY-032: the `flexibleSpace: ClipRect > BackdropFilter(sigma 16)`
  on the Material branch, and the whole `_IosHeader` rewrite
  (`Container(color: colorBackground)` → `ClipRect > BackdropFilter > Padding`),
  which STORY-033 never touched and which merges cleanly in substance.
- Both sides already agree on `backgroundColor: Colors.transparent`,
  `elevation: 0`, and the pink 26px back glyph.

The other seven conflicted paths (`req_master.md`, `cupid_app.dart`,
`design_system.dart`, `forgot_screen.dart`, `dream_jar_detail_screen.dart`,
`waiting_screen.dart`, `feature_flags_test.dart`, `widget_test.dart`) are ordinary
parallel-delivery integration conflicts and belong to the merge step, not to this
gate.

I confirmed the current `cupid_header.dart` on this branch is itself clean: no
conflict markers, one coherent implementation per platform, exactly one
`BackdropFilter` per branch, and no duplicated or contradictory back-arrow logic.

### S-3 — one out-of-scope deviation on the vibe capture is not listed (Low, deferred)

The report's "Deviations Outside STORY-032 Scope" section names two items and
states that each per-screen deviation is named there too. For the vibe capture it
records the missing bottom `CupidTabBar` and seeded partner card. Comparing the
two renders myself, there is a third difference it does not name: the design
reference shows six mood tiles including "Mềm lòng", while the app render shows
five and omits it. This is screen-content scope, owned by whichever Scope B story
covers Vibe Check, and entirely untouched by this story's one-line
`backgroundColor` removal — so it changes no verdict here. Listing it only so the
requirement-level audit picks it up and so the report's completeness claim holds.

## Acceptance Criteria Roll-Up

| AC | Verdict | Basis |
| --- | --- | --- |
| AC1 — shared wash reaches every screen | MET | Slice 1 PASS on the layer (incl. a rasterized pixel assertion, not a tree-shape check); slices 2+3+4 PASS on all 21 screens; confirmed at render on three screens |
| AC2 — `CupidPrimaryButton` gradient + glow | MET | Every value traced to the design source CTA block; visible on the Forgot Password render as a gradient pill with pink bloom. N-4 delta deferred |
| AC3 — `CupidHeader` transparent/blurred | MET | Code matches on all four changed values; now backed by the `ac3-vibe-header-dark-vi.png` render showing no opaque band. S-1 title delta deferred, not an AC3-enumerated element |
| AC4 — Forgot Password + Waiting re-rendered | MET | Both screens carry a full rule-12e3 package; both renders show the wash. F1/F3 closed |
| AC5 — existing contract tests pass, intentional edits disclosed | MET | Slice-level reruns green; the one narrowing is disclosed in `story_master.md` and `test-results.md`, and preserves the original intent rather than weakening it. N-5 deferred |

Test position: the closing patch reports `flutter analyze lib test` at 77 info /
0 error / 0 warning (all pre-existing) and `flutter test` at 1007/1007. Since
`e86b8ca` touches no application source, and each slice independently reran its
own scope green against earlier HEADs, I did not re-run the full suite. Nothing
in the evidence looked inconsistent enough to warrant it.

## Residual Risks

1. **Merge regression on `cupid_header.dart`** (S-2) — the highest-value item in
   this report. Mitigated by the conflict being loud and by the exact resolution
   above, but it does need a deliberate hand.
2. **No on-device capture.** All evidence is headless `flutter test`
   rasterization. It exercises the real widget tree and theme, but cannot show
   platform compositing of `BackdropFilter`, so the 16-sigma blur is confirmed
   structurally and by token, never on a real target. Disclosed in the report's
   "Known Gap". If REQ-002 wants the blur confirmed on-device, that is separate
   scheduled verification.
3. **`main_preview.dart` will mis-render future visual evidence** (O-1) —
   requirement-level, now that all Scaffolds are transparent.
4. **Composition-root wiring is one unasserted line** (N-1).
5. **Scope B screens closed before this story** — `story_master.md` Out of Scope
   explicitly excludes re-verifying already-DONE Scope B screens (STORY-005,
   006, 011, 014, 015, 028) against this shared fix. That re-verification
   decision is Scrum Master scheduling, still open.

## Notes For Scrum Master

Not reviewer-owned, flagged so the DONE gate is not reached on stale artifacts:

- `story_master.md:3` still reads `Status: PENDING`, `:18` leaves Architecture
  unchecked although `architecture/solution.md` is tracked, and `:21` leaves
  Review unchecked. Per the handoff I did not edit `story_master.md`.
- The S-2 merge resolution must be applied when this branch merges to
  `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`.
- S-1, S-3, N-1, N-3, N-4, N-5, F4-residual and O-1 are deferred follow-ups; none
  gates this story.

REVIEW_COMPLETE: YES
