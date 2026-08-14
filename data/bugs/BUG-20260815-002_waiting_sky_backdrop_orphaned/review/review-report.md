# Bugfix Review: BUG-20260815-002 Waiting Screen `_SkyBackdrop` Orphaned After STORY-032 Supersede

Review type: `bugfix-review`
Reviewer: Iris-QC
Date: 2026-08-15
Bug id: BUG-20260815-002_waiting_sky_backdrop_orphaned
Scope gate: `data/bugs/BUG-20260815-002_waiting_sky_backdrop_orphaned/review/scope-gate.md`
Work location: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`
Diff baseline: uncommitted working tree vs branch HEAD

Outcome: DEFERRED_ONLY

## Rationale

The patch is correct and minimally scoped. Both of the bug-fixer's load-bearing
claims were independently re-derived rather than accepted, and both hold:

1. **Visual-equivalence (delete vs restore).** Confirmed. I read the deleted
   `_SkyBackdrop` subtree from `git show HEAD:` and compared it against
   `CupidSkyPalette` / `CupidSkyPainter` directly, not against the diagnosis
   tables. All three wash layers (color, stops, ellipse radii, centers), all
   three star particles (position factors, size, color, period), and the twinkle
   curve (`0.25→1.0` opacity, `0.85→1.15` scale, `Curves.easeInOut` over a
   symmetric triangle) match value for value. The successor is a strict
   improvement on light-theme layer selection and reduce-motion
   (`disableAnimations` stops the ticker and holds stars at rest), neither of
   which `_SkyBackdrop` had. One axis the diagnosis did not check does differ —
   see D-1 — but it is sub-perceptual and lives in untouched STORY-032 code, so
   it does not overturn the delete decision. Restoring `_SkyBackdrop` would
   double-paint the sky on this one screen, which *would* be visible.
2. **Scope attribution (1 RED test, not 2).** Confirmed from the other bug's own
   artifact, not from the diagnosis:
   `data/bugs/BUG-20260814-003_caption_typography_token_mismatch/bug_master.md`
   lists `waiting_screen_design_fidelity_test.dart:238` verbatim under
   `Failure anchors` and is `Status: REPORTED` (unfixed). The caption `13` vs
   `11.5` failure is therefore genuinely not this bug's, and correctly stays RED.

Deletion scope is right-sized: the six helpers removed alongside `_SkyBackdrop`
(`_CssEllipse`, the three wash constants, `_TwinkleStar`, `_TwinkleStarState`)
were file-private and exclusively its consumers — proven by the post-patch
analyzer reporting zero `unused_element` warnings rather than six new ones. The
same-named `_TwinkleStar` in `design_system/decorations/cupid_star_field.dart`
is a separate live class and is untouched.

## Reviewed Inputs And Code Scope

| Input | Use |
| --- | --- |
| `bug_master.md`, `diagnosis.md`, `fix-evidence.md` | Governing scope, gates |
| `mobile/lib/features/pairing/presentation/screens/waiting_screen.dart` | Changed (−218) |
| `mobile/test/features/pairing/presentation/screens/waiting_screen_design_fidelity_test.dart` | Changed (+32/−82) |
| `git show HEAD:…/waiting_screen.dart` lines 244-461 | Deleted subtree, source of truth for equivalence |
| `mobile/lib/design_system/tokens/cupid_sky_palette.dart` | Successor values (read-only) |
| `mobile/lib/design_system/theme/cupid_app_background.dart` | Painter, twinkle, theme/reduce-motion (read-only) |
| `mobile/lib/design_system/tokens/cupid_color_tokens.dart:84-88` | CSS `skyGradient` token, layer order |
| `mobile/lib/app/cupid_app.dart:59` | Confirms successor mounts at composition root |
| `data/bugs/BUG-20260814-003…/bug_master.md`, `BUG-20260814-002…/bug_master.md` | Independent failure attribution |
| `data/devops/system/runtime-command-registry.json` (`mobile-app`) | Runtime gate is registry-backed |

## Touched Risk Surfaces And Critical Gates

| Risk surface | Gate | Result | Basis |
| --- | --- | --- | --- |
| Mobile UI rendering (dead-code removal) | Removed code provably unreferenced | PASS | `git grep` for all 7 symbols returns nothing in the patched tree; symbols were file-private |
| Static analysis | 0 warnings, no new `unused_element` | PASS | **Rerun by reviewer**: `flutter analyze lib test` → 80 `info`, 0 `warning`, 0 `error` |
| Mobile regression suite (stale test retarget) | Same-modality test recheck | PASS | **Rerun by reviewer**: changed suite + `waiting_screen_test.dart` → `+11 -1`; sole failure is the caption assertion at `:188` owned by BUG-20260814-003 (pre-fix baseline was `+10 -2`) |
| Design-system contract (visual intent) | Successor preserves deleted painter's values | PASS (see D-1) | Independent value-by-value read of both implementations |
| Build | `flutter build apk --debug` | PASS | `fix-evidence.md` Build Gate, exit 0; not rerun (rule 18 — evidence is current, specific, and not contradicted) |
| App lifecycle / runtime startup | App installs, launches, reaches foreground, shuts down | PASS | `fix-evidence.md` Runtime Startup Gate on `emulator-5560`; commands match `runtime-command-registry.json` `mobile-app.readiness` verbatim, including the 30×2s `ResumedActivity` poll and `am force-stop` shutdown |

Design-fidelity rendered screenshot (SKILL 12e2/12e3): **not required**. This is
a bugfix review, and the patch's production change deletes only code with no
call site — rendered output is provably unchanged. No screen was re-laid out.

Configuration guide: **not required**. No env, dependency, infrastructure, port,
or registry change in scope.

`## Pre-Fix Reproduction Gate` present in `diagnosis.md` with both anchors
reproduced. `## Original Failure Recheck Gate` present in `fix-evidence.md` with
`Same modality as original: YES` on both rechecks — analyzer for the analyzer
warning, test execution for the RED test. Both are the reported failures' native
modalities, so SKILL 16's UI-recheck escalation does not apply.

## Non-Vacuity Of The Retargeted Test

The bug-fixer disclosed that the retargeted assertion was not executed against a
reverted harness. Verified by construction instead:
`…whereType<CupidSkyPainter>().single` throws `StateError` on an empty iterable,
so removing `builder: … CupidAppBackground(…)` fails the test rather than
skipping it; and no `CupidSkyPainter` exists anywhere in `waiting_screen.dart`
after the patch, so the only possible source is the app-shell background. The
harness also uses the real `buildCupidTheme(...)`, so the
`scaffoldBackgroundColor.a == 0` non-occlusion assertion is a real check.
Claim accepted.

Coverage mapping verified, not trusted: all six successor tests named in
`diagnosis.md` § Coverage Mapping exist in
`mobile/test/design_system/cupid_app_background_test.dart` (`renders its child`,
`selects the sky layer set from the theme brightness`, `holds the stars at rest…`,
`twinkles the stars when animations are enabled`, `never intercepts a tap landing
on a star`, `paints the wash over the flat background fill`).

## Deferred Findings

**D-1 — Sky layer compositing order is inverted relative to the CSS source
(STORY-032 code, not this patch).**
`CupidColorTokens.skyGradient` declares the layers purple → magenta → teal, and
CSS paints the *first-listed* background layer on **top**. `_SkyBackdrop`
honoured that by reversing its `Stack` (explicit comment at the deleted
`waiting_screen.dart`). `CupidSkyPainter.paint` instead iterates
`CupidSkyPalette.darkLayers` in declaration order back-to-front, so purple ends
up at the **back** and teal on top — the reverse of both the CSS source and
`_SkyBackdrop`. Measured impact is sub-perceptual: the two strong layers barely
overlap (where purple peaks, magenta's alpha is 0, and vice versa), and in the
overlap band the srcOver order swap shifts the composite by roughly 2/255 in
red. Not visible, not introduced here, and not in this bug's scope — but the
diagnosis's "value-for-value … exactly, it does not approximate it" phrasing
overstates on this axis. Route to the design-system/STORY-032 owner to confirm
intent or reverse the iteration; do not reopen this bug for it.

**D-2 — Design-source literals are no longer pinned by any value assertion.**
STORY-013's test asserted the concrete wash colors, stops, ellipse transform and
star geometry against the design source. After the retarget, those values live
only as `CupidSkyPalette` constants; `cupid_app_background_test.dart` asserts
*which layer set* is selected (identity), not *what the values are*. The
diagnosis's rationale for not duplicating them in a feature test is sound — that
would re-create the design-source fork STORY-032 removed — but the correct home
for a value-pinning test is the design-system suite, where it currently does not
exist. Note that effective coverage did not regress here: the STORY-013 test was
already RED and therefore protecting nothing. Candidate follow-up for the
design-system owner.

**D-3 — `fix-evidence.md` carries no explicit `BUG_FIX_COMPLETE: YES` line.**
Every gate records an explicit `Result: PASS` and the artifact is otherwise
complete, so this is administrative rather than substantive, and it is not
treated as blocking here (SKILL 16 escalates only on a recorded
`BUG_FIX_COMPLETE: NO` / instrumentation-only handoff). Flagged because the
handoff schema names the marker for bugfix flows — Scrum Master should add it
before closure if the DONE gate reads it.

## Blocking Findings

None.

## Residual Risk

Two of the four suite failures remaining on this branch
(`waiting_screen_design_fidelity_test.dart:188`,
`joincode_screen_design_test.dart`) belong to `BUG-20260814-003`, and two
(`widget_test.dart`, `app/feature_flags_test.dart`) to `BUG-20260814-002`. Both
are `Status: REPORTED` and both are recorded as blocking REQ-002 closure. This
bugfix does not and cannot clear them; REQ-002 integration review stays
`PATCH_REQUIRED` until they are fixed.

## State Recommendation

- Bug status: `DONE` (Scrum Master applies; Reviewer does not edit workflow state)
- Mark `- [x] Review (Reviewer)` in `bug_master.md`
- Integration-review finding I-3 can be recorded as resolved
- Do not treat REQ-002 as unblocked: BUG-20260814-002 and BUG-20260814-003 remain open
