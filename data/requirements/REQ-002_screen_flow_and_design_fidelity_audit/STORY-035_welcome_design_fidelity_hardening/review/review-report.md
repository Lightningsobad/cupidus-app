# Review Report — STORY-035 Welcome Design Fidelity Hardening

Outcome: CLEAN

- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Story: STORY-035_welcome_design_fidelity_hardening (RED-PATCH, RWB-20260816-002)
- Review type: `story-review` — cycle 3 (Phase P1, gradient-axis fix)
- Reviewer: Iris-QC (`reviewer`)
- Date: 2026-08-17
- BaseHead: `e28a6c2793149c7920387f34646e55f87454cda6`
- Cycle 3 blocking findings: 0 | Cycle 3 deferred findings: 0
- Cycle history: cycle 1 `PATCH_REQUIRED` (F1, F2) -> cycle 2 `DEFERRED_ONLY`
  (F1/F2 resolved, D1 deferred) -> cycle 3 `CLEAN` (D1 resolved). The cycle 1 and
  cycle 2 records below stand as history and were not re-litigated.

---

# Cycle 3 — Phase P1 (D1 gradient-axis fix)

Scope of this cycle is P1 only. F1 and F2 were re-verified in cycle 2 and are
not reopened.

## Scope Gate

- Scope gate path: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-035_welcome_design_fidelity_hardening/review/scope-gate.md`
  (`Phase: SCOPE_GATE`, `SCOPE_GATE_COMPLETE: YES`)
- Cycle 3 additions to the reviewed surface:
  `mobile/lib/design_system/tokens/cupid_css_angle_gradient.dart` (new),
  `mobile/test/design_system/gradient_axis_test.dart` (new),
  `mobile/lib/design_system/tokens/cupid_color_tokens.dart` (modified),
  `coding-plan/master-plan.md` §6, `coding-plan/test-results.md` §6-8,
  `visual-fidelity/visual-fidelity-report.md` §4.3 / §7,
  `architecture/solution.md` `REVISION 2026-08-17` carve-out.

## D1 — RESOLVED, independently re-measured

I did not accept the new axis test or mobile-dev's analyzer as proof of the
render, for the same reason as cycle 2: a passing assertion under a wrong render
is exactly the IF-7 defect class this story exists to remove. I re-measured the
rendered pair myself using a **different** method from mobile-dev's sub-pixel
iso-colour-line analyzer — a robust least-squares plane fit of the blue channel
over clean patches with outlier rejection. This is valid because for a colour
field `f(u(x, y))` with `u` the axis coordinate, `grad f = f'(u) * d`, so the
local image-gradient direction is the gradient axis direction regardless of the
ramp's shape.

| Side | Patch | Measured tilt off vertical |
|---|---|---|
| Design reference | upper | 14.99 deg |
| Design reference | mid | 15.01 deg |
| Implementation (post-P1) | upper | 15.00 deg |
| Implementation (post-P1) | mid | 14.98 deg |

Mean reference 15.00 deg, mean implementation 14.99 deg; CSS
`linear-gradient(165deg)` expects 15.00 deg. Pre-fix the implementation measured
6.86 deg. My independent numbers agree with mobile-dev's reported 15.01 vs 14.98
to within 0.03 deg, by a different method — which is the opposite of the
single-method, single-observer weakness that produced IF-7.

**D1 is RESOLVED.**

## Extent half of the CSS contract — independently verified

`architecture/solution.md` correctly states that a fix which corrects the angle
but leaves the gradient-line length box-normalised is not a fix, because every
declared stop percentage slides. The evidence report proves this with a
four-corner colour check. I ran a stronger check along the whole ramp.

I computed the exact CSS gradient line on the 1080x2400 capture:
`d = (sin 165, -cos 165)`, `L = |W*sin0| + |H*cos0| = 2597.7` device px, start
`(203.8, -54.6)`. I then sampled 19 points at `t = 0.05 .. 0.95` (7x7 patch
average at each) against the declared 3-stop ramp
`#7B2FBE 0% / #FF4B8C 58% / #FF3366 100%`.

**17 of 19 points match the CSS ramp exactly — `+0 +0 +0` on all three
channels.** The two outliers are UI content occluding the backdrop, not gradient
error:

| t | Point | Measured | Cause |
|---|---|---|---|
| 0.80 | (742, 1953) | (247, 238, 251) | the white Google CTA pill (top edge ~724 logical px x 2.625 = ~1901 device px) |
| 0.50 | (540, 1200) | (238, 96, 162) vs expected (237, 71, 147) | the sub-copy text band at y ~457 logical px |

The 58% stop therefore lands exactly where CSS puts it along the full ramp, not
merely at the corners. Both halves of the contract hold.

## Diff scope — zero consumer widget files

| File | State vs BaseHead | Note |
|---|---|---|
| `mobile/lib/design_system/tokens/cupid_color_tokens.dart` | M +14/-4 | one import, two doc comments, four `const LinearGradient(` -> `const CupidCssAngleGradient(` construction sites |
| `mobile/lib/design_system/tokens/cupid_css_angle_gradient.dart` | new, **untracked** | 81 lines |
| `mobile/test/design_system/gradient_axis_test.dart` | new, **untracked** | 196 lines, 15 tests |
| `mobile/lib/features/auth/presentation/screens/welcome_screen.dart` | M +33/-11 | P0 work, cleared in cycle 2 |
| `mobile/test/features/auth/presentation/screens/welcome_screen_test.dart` | M +67 | P0 work, cleared in cycle 2 |

Confirmed by `git diff e28a6c2 --stat -- mobile` plus `git status --porcelain --
mobile`. No consumer widget file is touched. `gradientDream` / `_gradient120*`,
every other token, every other design-system file, `mobile/assets/**` and
`mobile/pubspec.yaml` are untouched. Field types stay `LinearGradient`, so the
`ThemeExtension` shape and all ~20 call sites compile with no consumer edit —
this is the property that makes "zero consumer widget files" achievable rather
than suspicious.

## Verification-sizing decision (master-plan §6) — ACCEPTED, and quantified

The P1 request asked for a fresh rendered pair per affected screen. Tech Lead
substituted an exhaustive token-level box-shape matrix test, arguing the
`gradientHot` error is sub-5-degree on wide pills and below what a screenshot
resolves. I evaluated this independently rather than deferring to it, by
computing the actual rendered delta.

On a 380x52 pill for `gradientHot` (95 deg, `#FF7FB6` -> `#B78CF5`):

- pre-fix (box-normalised): line `(0.72, 23.73)` -> `(379.28, 28.27)`,
  `L = 378.58`, axis **90.69 deg**
- post-fix (CSS): centre `(190, 26)`, `d = (0.99619, 0.08716)`, `L = 383.08`,
  axis **95.000 deg**

Projecting the four pill corners onto each line, the largest change in ramp
position is `|dt| ~ 0.013`. The token's colour span is
`(255,127,182)` -> `(183,140,245)`, largest channel range 72. So the largest
colour change any pixel of a 380x52 pill can undergo is **~0.9/255 — below one
8-bit level**.

Per-screen captures of those ~20 consumers would therefore have been essentially
byte-identical and could not have detected either the fix landing or a
regression. The token-level matrix is **strictly stronger** evidence than the
captures originally requested, not a weaker substitute. Decision accepted, and
keeping rendered evidence mandatory for `welcome` — the one high-aspect consumer
where the error is large and resolvable — is the correct split.

I verified both of the test's discriminator values by hand:

| Assertion | Test expects | My computation |
|---|---|---|
| `gradientBrandBackdrop` box-normalised on 412x915 | `closeTo(173.12, 0.01)` | begin `(152.7, 15.60)`, end `(259.3, 899.4)` -> **173.123 deg** = 180 - 6.877 |
| `gradientHot` box-normalised on 380x52 | `closeTo(90.69, 0.01)` | **90.687 deg** |

Both are arithmetically sound, and 6.877 deg reproduces the 6.86 deg measured on
a real pre-fix capture. The non-vacuity group would genuinely fail if
`CupidCssAngleGradient` were reverted.

Test-quality note: including the 400x400 square case — where both maths agree, so
a square-only matrix would have passed against the original defect — is exactly
the right instinct for an IF-7 story: the test proves it discriminates rather
than merely passing. The `LinearGradient.lerp` test is also well-aimed. It passes
today only because both `const` tokens are byte-identical and canonicalise to the
same instance, so it will fail loudly the moment dark and light diverge, which is
precisely when the subclass would otherwise be silently dropped mid-animation.

**Scope limit I want on record:** shell grep over source is blocked for my role
and no search tool was exposed to me in this session, so I could not enumerate
the ~20 `gradientHot` consumers myself. "Almost all are short, wide pills" rests
on Tech Lead's enumeration in `architecture/solution.md`. This is not
load-bearing for correctness — the matrix asserts angle and extent to `1e-9` on
all four aspect classes including 52x380 tall-narrow, so a consumer of any shape
now renders its declared CSS angle. It bears only on whether captures would have
added value, which the sub-LSB computation above answers for the wide-pill class.

## Critical gates (cycle 3)

Confirmed against `coding-plan/test-results.md` §6-8 and
`visual-fidelity/visual-fidelity-report.md` §7.

| Gate | Status |
|---|---|
| New axis test | PASS — 15 passed / 0 failed |
| Fork guard (`no_fork_guard_test.dart`) | PASS — 1 passed |
| Design fidelity suites (7 files) | PASS — 50 passed / 0 failed, incl. `waiting_screen` which exercises the direct `createShader(bounds)` path |
| Full regression suite | PASS — `+1264 ~2`, 0 failures (1249 -> 1264 = the 15 new tests; skips unchanged) |
| Mobile static analysis | PASS — 0 issues attributable to the three changed/new files |
| Build gate | PASS — `flutter build apk --debug` exit 0 on both the real and preview entry points |
| Design fidelity — rendered pair present and real | PASS — both PNGs present and opened by reviewer |
| Design fidelity — rendered deviations | PASS — all four fixed and re-verified; reviewer re-measured axis and ramp independently |
| Visual fidelity token | PASS — `visual-fidelity-report.md` §7 now records `VISUAL_FIDELITY: PASS` |
| Entry point reachability | PASS — `Reachable: YES`, `splash_screen.dart:113`, independently code-verified in cycle 1 |
| Story runtime startup smoke | PASS — real `lib/main.dart`, `Status: ok`, `LaunchState: COLD`, no `AndroidRuntime` entries |
| Configuration guide | Not applicable — no setup/configuration impact |

The cycle-2 gate note below is **resolved**: the `VISUAL_FIDELITY` token now
reads `PASS` because D1 was actually fixed, which was the first of the two routes
I offered. No auditable-deferral workaround was needed.

## AC findings (cycle 3, final)

| AC | Verdict | Evidence |
|---|---|---|
| AC1 rendered-to-rendered method | PASS | Both sides are real rasters; verbatim commands recorded; reviewer measured the PNGs directly |
| AC2 matched pair physically present + `VISUAL_FIDELITY: PASS` | PASS | Both PNGs present; §7 records `PASS` |
| AC3 no visible deviation | PASS | All four rendered deviations fixed; the last one (D1) independently re-measured at 14.99 deg vs the design's 15.00 deg |
| AC4 deviations fixed in code, not documented | PASS | 4.1/4.2/4.4 in `welcome_screen.dart`; 4.3 in the shared token helper under the Tech Lead carve-out; all re-verified by re-capture |
| AC5 CTA styling | PASS | Verified by reading both images in cycle 2; unchanged by P1 |

## Residual risk (accepted, not a finding)

If any `gradientHot` consumer is tall-and-narrow rather than a wide pill, P1
changes its appearance materially — on a 52x380 box the pre-fix math renders
122.66 deg against a declared 95 deg. That change moves the consumer **toward**
the design source, not away from it, and the full suite plus all seven
`*_design_fidelity_test.dart` files pass unchanged. I do not treat it as a
defect; recording it so a future cross-screen visual audit knows where to look.

## Commit hygiene — action required before the DONE gate

Both P1 source files are untracked in the working tree:

```
?? mobile/lib/design_system/tokens/cupid_css_angle_gradient.dart
?? mobile/test/design_system/gradient_axis_test.dart
```

`cupid_color_tokens.dart` imports `cupid_css_angle_gradient.dart`, so a
`git add -u` or `git commit -a` at the story boundary would commit a tree that
**does not compile**. Both new files must be staged explicitly. This is not a
code defect — I am flagging it because it is invisible to `git diff --stat`,
which is the command both `master-plan.md` and the evidence report cite when
asserting the diff scope.

## State recommendation (cycle 3)

- Keep `Implementation (Development)` and `Implementation P1` checked
- Check `Review (Reviewer)` for cycle 3
- Story status: `DONE` — no blocking findings, no open deferred findings, and the
  `VISUAL_FIDELITY` token now genuinely reads `PASS`
- No follow-up backlog item is needed for D1; it was fixed inline rather than
  routed separately, per the user's explicit scope-widening decision
- Stage the two untracked P1 files explicitly in the story-boundary commit

---

# Cycle 2 — history (verdict `DEFERRED_ONLY`, 2026-08-16)

Preserved unchanged. F1 and F2 were resolved and independently re-verified here;
D1 was correctly deferred at the time and was subsequently fixed in P1.

- Review type: `compact-story-review` — cycle 2 (re-review after rework)
- Blocking findings: 0 | Deferred findings: 1
- Cycle 1 verdict was `PATCH_REQUIRED` (findings F1, F2); both resolved and
  independently re-verified.
- Changed files vs BaseHead at that time (independently confirmed): exactly 2 —
  `mobile/lib/features/auth/presentation/screens/welcome_screen.dart` (+33/-11)
  and `mobile/test/features/auth/presentation/screens/welcome_screen_test.dart`
  (+67). Nothing under `mobile/lib/design_system/**`, `mobile/assets/**`, or
  `mobile/pubspec.yaml`.

## Cycle-1 findings — re-verification

### F1 — twinkle star particles absent from the render: RESOLVED (independently verified)

The fix is exactly the recommended one and does not touch a prohibited path:
`welcome_screen.dart` now wraps the body in `Stack(fit: StackFit.expand)` with
`const Positioned.fill(child: CupidStarField())` as the last child, mirroring
`vow_screen.dart:270-272`. `CupidStarField` resolves through the existing
`package:cupid_mobile/design_system/design_system.dart` barrel already imported
at line 5, so no new dependency was introduced. The `StackFit.expand` choice is
load-bearing and correctly reasoned in-code: a loose stack would let the body
shrink-wrap and would regress the cycle-1 hero-stretch fix.

I did not accept the widget test as proof, because a passing widget-tree
assertion under a wrong render is the exact defect class (IF-7) this story
exists to eliminate. I re-ran my own bright-blob detection on the re-captured
`implemented-welcome-emulator-5560.png`:

| Side | Blobs in upper region | Peak contrast |
|---|---|---|
| Design reference | 3 | +129, +81, +78 |
| Implementation, cycle 1 | **0** | — |
| Implementation, cycle 2 | **3** | +124, +83, +42 |

Placement verified independently by contrast-weighted centroid, expressed as a
fraction of each side's own screen box. The implementation lands within 0.1% of
the `Cupid Screens.dc.html:45-47` declarations:

| Particle | CSS declaration | Implementation centroid | Match |
|---|---|---|---|
| white d=6 | `left:8%` `top:14%` | (8.7%, 14.3%) | exact (centroid = edge + r) |
| pink d=4 | `right:16%` `top:9%` | (83.5%, 9.2%) | exact |
| lavender d=5 | `right:7%` `top:26%` | (92.3%, 26.3%) | exact |

I also independently reproduced the report's §5.4 explanation of the absolute-y
offset. Solving for the reference's screen rect from its three star centroids
yields `(8.0, 47.3, 389.0, 827.5)`, which reproduces all three reference
positions to within 1.6 px and confirms both sides place the particles at the
same fractions of their own container. The residual absolute offset is the
bezel/safe-area chrome difference already documented in §5.6, not a placement
difference. The report's decision not to assert instantaneous per-particle alpha
is correct: `twinkle` runs continuously at 0.25-1.0 opacity with three different
periods, so any two captures sample different phases.

The new test `the shared twinkle star field paints over the backdrop` is a
reasonable structural guard — it pins presence, last-child `Positioned` ordering,
`StackFit.expand`, and the `IgnorePointer` that keeps the full-bleed particle
layer from swallowing CTA taps. The render itself is proven separately by the
capture above, which is the right division of evidence.

### F2 — missing mandatory evidence sections: RESOLVED

- `## Entry Point Reachability` now records `Reachable: YES` citing
  `mobile/lib/features/auth/presentation/screens/splash_screen.dart:113`
  (`SessionGateUnauthenticated()`), which matches my own cycle-1 independent
  code verification.
- `## Story Runtime Startup Smoke` is now run against the real `lib/main.dart`
  entrypoint rather than the `main_preview.dart` capture harness — this was the
  specific gap I raised. Recorded: build/install exit 0, `Status: ok`,
  `LaunchState: COLD`, resumed activity confirmed, no `AndroidRuntime` entries,
  no Dart exception or error screen, welcome reached through the session gate.
  No waiver needed.

## Deferred findings (cycle 2 — since RESOLVED in P1)

### D1 — Backdrop gradient axis: 6.86 deg rendered vs 14.98 deg design

Unchanged from cycle 1, re-confirmed still correctly out of scope at the time,
and not re-litigated in cycle 2:

- Token: `gradientBrandBackdrop`, via `_gradient165Begin` / `_gradient165End`
- File: `mobile/lib/design_system/tokens/cupid_color_tokens.dart` lines 28-38
- Measured: implementation axis 6.86 deg off vertical vs design reference
  14.98 deg (CSS `linear-gradient(165deg, ...)` expects 15.00 deg); stable
  across three iso-blue levels (B=170, 150, 130)
- Corroboration: gradient endpoints match exactly — TL (123,47,189) vs
  (123,47,190), BR (255,51,102) on both — while the two off-axis corners carry
  the error (TR dR -18 dB +8; BL dG -4 dB -7). A correct colour ramp swept along
  the wrong direction, not a palette defect
- Cause: `sin/cos(165deg)` used directly as `Alignment` components. Flutter
  normalises `Alignment` to the box aspect ratio; CSS `linear-gradient(<angle>)`
  is a true geometric angle. On a 412x915 box,
  `atan((0.2588 * 412) / (0.9659 * 915))` = 6.88 deg, matching the 6.86 measured
- Blast radius: `_gradient95Begin` / `_gradient95End` behind `gradientHot` share
  the same defect, so the fix is cross-screen by construction

Deferring was correct at the time: the only correct fix lay under
`mobile/lib/design_system/**`, prohibited by that phase's Write Scope and by
`architecture/solution.md` §4 (WriteScope Boundary Decision); the root cause was
diagnosed to exact file/lines with measured deltas; the blast radius was known;
and the implementer correctly declined both to widen scope and to mask it with a
screen-local literal colour.

**Cycle 3 disposition: RESOLVED.** The user elected to widen this story's Write
Scope instead of routing D1 separately; P1 fixed it and cycle 3 verified it
independently. The recommended follow-up backlog item is no longer needed.

## Gate note for Scrum Master (cycle 2 — RESOLVED in cycle 3)

At cycle 2, `visual-fidelity/visual-fidelity-report.md` §7 still recorded
`VISUAL_FIDELITY: BLOCKED` with the `SCOPE_BOUNDARY_BLOCKED` block, because D1
was a real remaining visible deviation and the implementer was being honest
rather than typing `PASS` over it. That was the correct engineering call, but the
token is machine-read independently by the visual-fidelity and DONE gates, so it
would likely have blocked story closure even with a `DEFERRED_ONLY` review.

I offered two routes: land the D1 fix so the token becomes a genuine `PASS`, or
have the owning role record an explicit auditable deferral. **The first route was
taken.** §7 now reads `VISUAL_FIDELITY: PASS` on merit, so this note is closed.

## Critical gates (as recorded at cycle 2)

| Gate | Status |
|---|---|
| Mobile static analysis | PASS — 0 issues in changed files |
| Targeted widget tests | PASS — 10 passed (`welcome_screen_test.dart` + `no_fork_guard_test.dart`) |
| Full regression suite | PASS — 1249 passed / 2 skipped / 0 failed |
| Build gate | PASS — `flutter build apk --debug` exit 0, real and preview targets |
| Design fidelity — rendered pair present and real | PASS — both images opened by reviewer |
| Design fidelity — in-scope deviations | PASS — reviewer re-measured the re-capture, all three particles render at design fractions |
| Entry point reachability | PASS — evidence recorded and independently code-verified |
| Story runtime startup smoke | PASS — real `lib/main.dart` entrypoint, cold start, no error screen |
| Configuration guide | Not applicable — no setup/configuration impact |
