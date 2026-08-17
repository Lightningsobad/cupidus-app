# Review Report: STORY-038 Paired Success Design Fidelity Hardening

Outcome: CLEAN

Review type: compact-story-review | Cycle: 1
Story: REQ-002_screen_flow_and_design_fidelity_audit /
STORY-038_paired_success_design_fidelity_hardening
Lane: mobile | Retro-Type RED-PATCH (RWB-20260816-005), fixes
STORY-014_paired_success_design_fidelity
Diff baseline: `141635a920a8bbadde30732551b0f9fa6b2101c5` (Worktree
`/Users/alantravala/workspace/snapsofts/cupid-apps`, branch `main`)

## Scope Gate

Changed files against `BaseHead` (3 tracked, 1 untracked evidence dir):
- `mobile/lib/features/pairing/presentation/screens/paired_screen.dart` (+10 −6)
- `.../STORY-038_.../story_master.md` (artifact)
- `.../STORY-038_.../scrum-master-checkpoint.md` (artifact)
- `.../STORY-038_.../visual-fidelity/` (untracked — see OBS-1)

No closed story's files, boundary, or branch is touched. STORY-014's own
`story_master.md` is untouched, matching the Background reconciliation decision.
No pairing business logic (cubit, repository, poller, state) is touched. No
navigation or entry-point wiring is touched.

Design source re-queried directly, not taken from the report's prose:
`Cupid Screens.dc.html:1600-1614` (`isPaired` block), `:23-27` (tokens),
`:31` (`@keyframes bob`), `:40` (`@keyframes popIn`), `:14-41` (full `<style>`,
to test the content-box premise).

## Per-AC Verdicts

| AC | Verdict | Basis |
| --- | --- | --- |
| AC1 — layout/spacing/colour/typography match, no visible deviation | PASS | Both PNGs opened; independent pixel probes reproduce the report's geometry and backdrop numbers. Residuals A1/R1/R2/R3 are design-source-grounded, see below |
| AC2 — D1-D14 re-confirmed in the render, D15 re-confirmed excluded, none dropped | PASS | 15-row table maps one-for-one onto `story_master.md` In Scope §2's own enumeration; D15 present and correctly dispositioned |
| AC3 — any deviation found is corrected in app code, re-verified with a fresh pair | PASS | F1 is a real box-model fix in the diff, independently confirmed in the rendered pair |
| AC4 — celebration animation matches exact keyframe timing/easing/travel | PASS | `popIn` and `bob` verified line-by-line against `Cupid Screens.dc.html:40`, `:31`, `:1602`, `:1605` |
| AC5 — evidence pair + `VISUAL_FIDELITY: PASS` + D1-D15 disposition in this story's own dir | PASS | Both PNGs present and are the same screen; report header records `VISUAL_FIDELITY: PASS` |
| AC6 — no new entry point required | PASS | Diff contains no routing or navigation change; `onSignContract` stays nullable |

## Evidence Pair Is Real (AC1/AC5)

Both images were opened, not merely listed. They are the same screen in the same
configuration: dark theme, `vi` locale, post-pairing-success state — overlapping
avatar cluster with floating heart, `Ghép đôi thành công!`, the two-line
supporting body, three stat chips (`1 ngày` / `16 tính năng` / `0 lần cãi`), and
the `Ký Love Contract →` pill. This is a genuine rendered-to-rendered pair, not
a placeholder or a duplicated single side.

The report's scale-calibration claim (reference ~0.98330 px per design px,
capture ~0.98301 px per dp, therefore ~1:1) is the load-bearing premise for
every number in its table, and the reference carries an Android device frame
while the capture does not — so I tested it against two hard design-declared
anchors rather than accepting it:

| Anchor | Design | My REF measurement | My APP measurement |
| --- | --- | --- | --- |
| CTA pill (`max-width:300px`, `:1614`) | 300 | 295 px (x 56-350) | 295 px (x 55-349) |
| Avatar cluster visible span | 136 | 133 px (x 137-269) | 133 px (x 136-268) |

300 design px at 0.9833 is 295 — the calibration holds empirically, and the two
sides agree to 0-1 px on both anchors. A 2% scale error would have shown as a
~12 px CTA gap; there is none. My integer thresholds sit inside the report's
sub-pixel figures (300.01/300.10, 135.26/135.30), which is the expected
direction for a coarser edge detector.

## F1 Is a Real Fix, Not a Renumbering (AC3)

I re-derived the root cause from the source rather than checking the report's
arithmetic.

`Cupid Screens.dc.html:1603-1604` declares each avatar as
`width:76px;height:76px;...;border:3px solid var(--bg)` with `margin-left:-22px`
on the second. I read the canvas' entire `<style>` block (`:14-41`): it contains
only `[data-icon]`, `[data-scroll-x]`, the `[data-en]`/lang rules, the
`[data-plat]` token blocks, the two theme blocks and the `@keyframes`. **There is
no `*{box-sizing:border-box}` rule.** The content-box premise is therefore
correct, and the design's avatars really do measure 82x82 with a 76 px visible
disc, second offset 60, cluster 142 wide / 136 visible.

Flutter strokes `Border.all` inward, so the shipped
`Container(width: 76, height: 76, border: Border.all(width: 3))` left only a
70 dp disc in a 130 dp cluster. The diff fixes exactly that, and only that:
`SizedBox` 130x76 → 142x82, second avatar `left: 54` → `60`, `_CoupleAvatar`
76x76 → 82x82. This is a genuine geometry correction with a correctly identified
root cause.

It is also visible in the evidence, which is what separates it from a paper fix.
My own detector measures the cluster's visible span at 133 px on **both** sides.
Pre-fix the app cluster was 124 design px against the design's 136 — at this
render scale that is ~122 px vs ~133 px, a gap my threshold would have shown
plainly. It does not appear. The fix landed and the render proves it.

The floating heart's `top:-16` is relative to the cluster box, which grew from
76 to 82 tall, so it tracks the corrected geometry — consistent with the report's
matching -4.07 dp ink offset on both sides.

## Animation Claims Verified Against Code and Source (AC4)

Checked against the widget, not the report's prose:

| Design source | App code | Match |
| --- | --- | --- |
| `animation:popIn .6s cubic-bezier(.2,1.6,.4,1)` (`:1602`) | `Duration(milliseconds: 600)`, `Cubic(0.2, 1.6, 0.4, 1)` (`paired_screen.dart:136-144`) | exact |
| `popIn{0%{scale(.94) translateY(8px);opacity:0}100%{scale(1) translateY(0);opacity:1}}` (`:40`) | `scale: 0.94 + 0.06 * t`, `Offset(0, 8 * (1 - t))`, `opacity: t.clamp(0,1)` (`:170-179`) | exact |
| `animation:bob 2s ease-in-out infinite` (`:1605`) | 1000 ms controller, `repeat(reverse: true)`, `Curves.easeInOut` (`:148-156`) | equivalent |
| `bob{0%,100%{translateY(0)}50%{translateY(-7px)}}` (`:31`) | `Offset(0, -7 * _bob.value)` (`:206`) | exact |

Two judgment points, both correct:
- Clamping only opacity is right. The `cubic-bezier(.2,1.6,.4,1)` curve
  overshoots past 1; CSS lets `transform` overshoot but clamps `opacity` to
  `[0,1]` by spec. The app reproduces exactly that asymmetry.
- The 1000 ms `repeat(reverse: true)` for a 2 s CSS animation is right, not a
  halved duration. `bob`'s keyframes are symmetric about 50%, so a
  forward/reverse pair spans the full 2 s cycle, and CSS applies its timing
  function per keyframe segment — so each 1 s half is independently eased, which
  is what `CurvedAnimation` with a null `reverseCurve` produces. The claim is
  accurate, and the code comment at `:146-147` states the reasoning correctly.

The 2-second `bob` cycle is also why `paired_screen_test.dart` uses bounded
`pump`s instead of `pumpAndSettle` — consistent, pre-existing, unaffected.

## D1-D15 Completeness (AC2)

All 15 rows are present. Cross-checked against `story_master.md` In Scope §2's
own enumeration — radial wash, screen padding, avatar cluster, floating heart,
pop-in, bob, title copy, title typography, title gap, body line, chip row, CTA,
CTA typography, overflow (D1-D14) plus D15 — and the table matches one-for-one
in the same order. Nothing is silently dropped, merged, or renumbered.

D15 (avatar initials) is correctly handled: the reference renders `M`/`L` inside
the discs, the app renders none, and the report states this plainly as still
out of scope rather than hiding it. It is neither silently fixed with invented
placeholder data nor quietly removed from the record — exactly what
`story_master.md`'s Out of Scope requires.

Two report-integrity signals worth recording, because they are the opposite of
the failure mode this hardening story exists to correct:
- D2 (screen padding) openly states it is **not** directly measurable in the
  render, since the widest child is the 300 dp CTA inside a 412 dp frame with
  360 dp of content width available. That is arithmetically correct and is an
  honest disclosure where a fabricated measurement would have been easy.
- D14 is exercised rather than asserted: the app's body genuinely wraps to a
  third line and still lays out without clipping, visible in the capture.

Spot-verified the remaining design-declared values directly against the source:
padding `40px 26px` (`:1601`), title Nunito 900 / 28 px / `line-height:1.2` /
`margin-top:28px` (`:1607`), body 13.5 px / 1.6 / `margin-top:10px` /
`max-width:275px` (`:1608`), chips `padding:12px 18px` / `border-radius:18px` /
`gap:12px` / value 22 px / label 11 px `margin-top:3px` (`:1609-1612`), CTA
`margin-top:30px` / `max-width:300px` / `height:54px` / `--r-btn` / `--grad-hot`
/ 16.5 px / weight 800 / `--glow` (`:1614`), wash
`circle at 50% 38%,rgba(255,127,182,.3),transparent 62%` (`:1601`, and
`Alignment(0, -0.24)` is the correct mapping of the 38% vertical stop). Every one
matches the widget.

## Backdrop Independently Re-derived (D1)

Rather than trust the report's nine left-edge samples, I sampled my own column
after aligning the two frames by the CTA anchor (REF ≈ APP + 1 px x, + 21 px y,
the device-frame bezel offset):

| y (app) | REF RGB | APP RGB | R−G ref / app |
| --- | --- | --- | --- |
| 100 | (59, 29, 89) | (62, 31, 89) | 30 / 31 |
| 180 | (59, 31, 79) | (61, 33, 79) | 28 / 28 |
| 260 | (57, 32, 68) | (59, 33, 69) | 25 / 26 |
| 340 | (56, 33, 61) | (56, 33, 61) | 23 / 23 |
| 420 | (55, 32, 60) | (53, 31, 59) | 23 / 22 |
| 500 | (48, 29, 56) | (45, 28, 55) | 19 / 17 |

Pink amplitude and falloff agree within 2 units of R−G at every probe, matching
the report's claim. The wash is genuinely reproduced, including the `--sky`
composite behind it.

Worth recording as a positive: `PairedScreen` uses `Scaffold` with **no**
`backgroundColor` override, so it does not carry the `CupidAppBackground`
occlusion defect that blocked STORY-037 cycle 1, and it is correctly absent from
that story's DEF-1 sibling list. The sky and star layers are visible in this
capture.

## Approved Deviations and Residuals — Reasoned, Not Evasion

Each was tested against the design source independently. All four survive.

- **A1 — content block vertical position.** `:1601` is
  `min-height:100%;padding:40px 26px;justify-content:center` with content-box
  sizing, so the container really is viewport + 80 px and its centred children
  really are pushed 40 px down inside the scroller. That is a browser box-model
  artifact of the declared CSS, not a designed offset; the design's stated intent
  is `justify-content:center`, which the app expresses as `Center` in `SafeArea`.
  Reproducing it would mean adding an 80 dp phantom scroll extent to a screen
  that fits. The report's distinction against F1 is the right one and I agree
  with it: content-box on a **visual element** changes its intrinsic rendered
  size and must be reproduced; content-box on the **page container** changes only
  scroll extent. Correct call.
- **R1 — font advance width.** Ink heights match to 0.01 dp and line pitch to
  0.00 dp, so this is advance width only. The visible consequence (trailing `🎀`
  wrapping to a third line) is not fixable without deviating from the locked
  source: `max-width:275px` and the copy are both design-owned at `:1608`, and
  the app implements both exactly. Widening either to force a two-line wrap would
  itself be the deviation. Correct call.
- **R2 — emoji glyph metrics.** `font-size:26px` at `:1605` is implemented
  exactly; Noto Color Emoji and Apple Color Emoji simply differ at the same
  declared size, and positioning is identical (-4.07 dp on both sides).
  Hardcoding a compensating size would deviate from the source. Correct call.
- **R3 — chip height.** Confirmed at `:1610-1612`: the design declares **no**
  `line-height` on either the 22 px value or the 11 px label, so chip height is
  the sum of two font-default line boxes, which differ between Chrome and
  Flutter. Padding, radius, gap, colour and typography all match. Correct call.

These are the same tolerance class accepted for STORY-035/036/037 and are
consistently applied here. None of them is used to avoid work that the app could
actually do.

One observation, non-blocking: R1 and R3 have a cumulative vertical consequence
the report states only in parts. The extra body line (~21.4 dp) plus the taller
chips (~4.1 dp) shift the app's upper block ~25 dp higher relative to the CTA
than the reference — which my probes confirmed independently. Every
design-specified gap still matches individually (28 → 32.59/33.62, pitch
21.36/21.36, 30 → 30.51/30.52), so the drift is entirely attributable to the two
disclosed residuals and introduces no new defect. The underlying numbers are all
present in the report's own table; only the roll-up is left implicit.

## Verification Commands (re-run independently this cycle)

| Command | Result |
| --- | --- |
| `flutter analyze lib/features/pairing/presentation/screens/paired_screen.dart` | `No issues found! (ran in 0.9s)` |
| `flutter test test/features/pairing test/design_system` | `00:03 +159: All tests passed!` |

Both reproduce the reported evidence exactly, including the `+159` test count.
Run from `mobile/` with the SDK at `~/flutter/bin`.

I also checked the falsification risk behind the passing-test claim: no test in
`test/features/pairing` asserts the old 76 / 130 / 54 cluster geometry
(`paired_screen_test.dart` covers arrival paths, semantics/live region, content,
type ramp and the CTA seam), and there is no `paired_screen_design_fidelity_test`
to update. The green suite is therefore genuine coverage, not coverage that
happened to miss a broken change.

## Deferred Findings

None.

## Observations For Scrum Master (not review defects)

- **OBS-1 — evidence dir is still untracked.** `visual-fidelity/` shows as `??`
  in `git status`. Both PNGs and the report must be committed at the story
  boundary, or AC5's evidence will not land on `main` and this story reproduces
  the exact IF-7 gap it was created to close.
- **OBS-2 — story class metadata mismatch.** `story_master.md` records
  `Complexity: trivial` / `Story-Class: trivial`, while the handoff declared
  `Story-Class: standard`. The stricter named-Reviewer gate was run either way,
  so there is no gate risk; the field is Scrum Master's to reconcile.

## Traceability

- AC1-6 from this story's own `story_master.md`; D1-D15 cross-checked against
  its In Scope §2 enumeration.
- Design source verified at `cupid-app-design-system/project/Cupid Screens.dc.html`
  lines 1600-1614 (`isPaired`), 23-27 (tokens), 31 / 40 (`@keyframes`), 14-41
  (full `<style>`, for the box-sizing premise).
- Design-fidelity evidence pair complete in this story's own `visual-fidelity/`
  with `VISUAL_FIDELITY: PASS` warranted by the images.
- Entry point unchanged: no routing in the diff; `onSignContract` remains a
  nullable seam owned by STORY-001/STORY-002.
- Runtime startup smoke not separately required: the emulator capture
  independently shows the app building, launching and reaching the screen
  post-fix.

## State Recommendation

- Keep `Implementation (Development)` checked; check `Review (Reviewer)`.
- Story status: `DONE`.
- Resolve RWB-20260816-005 once the `visual-fidelity/` evidence is committed
  (OBS-1).
