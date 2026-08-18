# STORY-051 — Review Report (compact-story-review)

Outcome: DEFERRED_ONLY

- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Story: STORY-051 (RED-PATCH of STORY-018, source RWB-20260816-016)
- Complexity: trivial · Implementation Lane: shared · Story-Class: standard
- Reviewer: Iris-QC · Date: 2026-08-18
- Pass 1 diff: `7d8fc62..8d5b3cf` → `PATCH_REQUIRED` (B1)
- Pass 2 diff (this pass): `8d5b3cf..0d8b9bc` → B1 resolved
- Blocking findings: 0 · Deferred findings: 1

## Scope Gate

- Review type: `compact-story-review`, re-review pass (no separate
  `scope-gate.md`, per skill 5a)
- Report path: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-051_chat_inverse_text_token_hardening/review/review-report.md`
- Files in scope this pass (2 code, within the 8-file compact budget):
  - `mobile/lib/features/chat/presentation/widgets/message_bubble.dart`
  - `mobile/test/features/chat/presentation/chat_design_fidelity_test.dart`
- Evidence in scope: `visual-fidelity/visual-fidelity-report.md` (§`Correction
  (Reviewer B1)`, §`Regression guard`, §`Verification`), `story_master.md`
  §`Artifacts`
- Not re-read per handoff (unchanged since pass 1, verdicts on record):
  `cupid_color_tokens.dart` (AC1 PASS), `chat_composer.dart` (AC2 send-glyph
  branch PASS), `ux/uiux-spec.md`
- Query keys: `isMine`, `colorOnAccent`, `colorText`, `_light`, `brightness`,
  AC2

## Acceptance Criteria

| AC | Verdict | Basis |
| --- | --- | --- |
| AC1 — per-theme `colorOnAccent` token, all six touch points | PASS | Carried from pass 1; token file unchanged in `8d5b3cf..0d8b9bc`. |
| AC2 — `message_bubble.dart:99` + `chat_composer.dart:310` consume the token | **PASS** (was FAIL) | Guard applied exactly as specified. `colorOnAccent` is now confined to the `gradientHot` fill on both call sites, matching the token's own dartdoc scope. See "B1 resolved". |
| AC3 — dark-theme render visually unchanged | PASS | Still holds, and the patch is provably render-neutral in dark — see "No recapture required". |
| AC4 — light-theme value adequate on the gradient | PASS | Carried from pass 1; all four contrast ratios were independently recomputed then and nothing in this pass alters the light value or the gradient. |

## B1 Resolved

`message_bubble.dart:99` now reads exactly the specified fix, verified against
the diff rather than the summary:

```dart
color: isMine ? colors.colorOnAccent : colors.colorText,
```

One line, nothing else changed in that file. Light-theme partner-bubble text
returns to `colorText` `#3E2645` on `colorSurface` `#FFFFFF` (13.39:1), from
the `#FFFFFF`-on-`#FFFFFF` 1.00:1 of pass 1.

### The regression guard is genuinely non-tautological

Verified analytically from the assertions themselves, not from the documented
revert-and-rerun:

| Case | Assertion that catches a revert | Why it must fail without the guard |
| --- | --- | --- |
| `partner bubble text is never its own fill colour` (light iteration) | `expect(body.style!.color, _light.colorText)` | Reverted code yields `_light.colorOnAccent` `#FFFFFF`; expected `#3E2645`. Mismatch is forced. |
| same, second assertion | `isNot(_bubbleDecoration(tester).color)` | Partner fill is `colorSurface` `#FFFFFF`; reverted text is `#FFFFFF`. `isNot` is forced to fail. |
| `light theme keeps the two on-fill text roles distinct` | `expect(_light.colorOnAccent, isNot(_light.colorText))`, then partner renders `_light.colorText` | Pins the token-level divergence first, so the guard cannot be defeated by collapsing the two light values instead of fixing the call site. |

The dark iteration is tautological by construction (`colorOnAccent` and
`colorText` are the same hex there) and the test's own inline comment says so
rather than implying dark coverage it does not have. That is the correct
framing: the light iteration carries all the signal.

Corroborating, and consistent with the above: the documented revert output
reports `Color(red: 0.2431, green: 0.1490, blue: 0.2706)` expected vs
`Color(red: 1.0000, ...)` actual. Those components are `62/255`, `38/255`,
`69/255` — `#3E2645` exactly, i.e. real captured output, not a paraphrase.

`_hostOn`'s new `brightness` parameter defaults to `Brightness.dark`, so no
pre-existing call site changes behaviour. The `pumpAndSettle` after each
re-pump is required and correct: `AnimatedTheme` lerps between themes on a
tree rebuild, and `Tween.transform` short-circuits to `end` at `t == 1.0`, so
the settled frame reports exactly `_light`'s token values with no interpolation
residue.

### No recapture required

The dark-theme captures from pass 1 remain valid evidence for this commit, and
the decision not to re-capture is sound rather than a shortcut:

| State | Own bubble text | Partner bubble text |
| --- | --- | --- |
| pre-story | `colorText` `#F7EEFB` | `colorText` `#F7EEFB` |
| `8d5b3cf` (pass 1) | `colorOnAccent` `#F7EEFB` | `colorOnAccent` `#F7EEFB` |
| `0d8b9bc` (this pass) | `colorOnAccent` `#F7EEFB` | `colorText` `#F7EEFB` |

All three resolve identically in dark theme, so AC3's equality claim is
unaffected by the patch. `VISUAL_FIDELITY: PASS` still stands on the pass-1
images, which I opened and confirmed in that pass as the real chat screen
against the correct `--screen=chat` reference.

### D1 correction is accurate and adds no new unsound claim

The withdrawn inference is replaced, not deleted: the delta-0 measurement row
is retained with only its false "control — not touched by this story" label
removed, and the new §`Correction (Reviewer B1)` states plainly that the
partner bubble was inside the changed code path and measured delta 0 only
because the two dark values are byte-identical. Every factual claim in the
replacement matches what I verified in source, including the 1.00:1
light-theme figure. The added line "AC3 covers the dark-theme render only; the
`isMine` scoping AC2 requires is covered by the tests below, not by AC3" is a
correct statement of what each gate can and cannot prove. The
changes-delivered note was also corrected from "no other … test was modified"
to acknowledge the new tests.

## Deferred Findings

- **D2 (carried from pass 1, unchanged) — no explicit `Design-Screen:` line in
  `story_master.md`.** The resolved id is recoverable from
  `visual-fidelity-report.md` (`render-design-canvas.js --screen=chat`,
  reference reused byte-identically from STORY-040), and I confirmed by opening
  `design-reference-chat-android.png` in pass 1 that it depicts this story's
  chat screen. Substance of skill 12e2 is met; only the explicit field is
  absent, so a future reader must re-derive the choice from the evidence report
  instead of reading it off the story. Non-blocking, does not gate closure.

## Touched Risk Surfaces And Critical Gates

| Surface | Gate | Result |
| --- | --- | --- |
| Mobile interaction / theming | `flutter analyze --no-fatal-infos lib test` | PASS — 80 info, 0 errors, 0 warnings (baseline unchanged) |
| Mobile interaction / theming | targeted `flutter test test/features/chat/ test/design_system/` | PASS — 133 (131 + the two new cases) |
| Mobile interaction / theming | full `flutter test` | PASS — 1287 passed / 2 skipped / 0 failed (1285 + 2) |
| Light-theme token consumption | light-theme widget regression, revert-checked | PASS — guard proven to fail without the fix |
| Mobile build | debug APK build | PASS |
| Mobile runtime startup smoke | cold launch `cupidpreview://screen/chat`, no ErrorWidget | PASS (not mandatory for a `trivial` story under 12g; supplied anyway) |
| Mobile design fidelity (12e3) | images opened, correct screen, verdict not contradicted | PASS (pass 1); patch is render-neutral in dark, so unaffected |
| Typed contract (`ThemeExtension`) | `copyWith` + `lerp` completeness | PASS (pass 1) |

Sibling call-site sweep (skill 12d) is complete by construction: `colorOnAccent`
was introduced by this story, so its only consumers are the two files it
touched, and `7d8fc62..0d8b9bc` changes no other feature file.

Entry-point reachability (12e1): not applicable — no new user-facing capability
or surface. Configuration-guide impact (12a): none.

## Traceability

- ACs: `story_master.md` §`Acceptance Criteria`, §`In Scope`, §`Out of Scope`
- Architecture: `SKIPPED:trivial`; the Tech Lead `ThemeExtension`/`lerp`
  invariant was verified met in pass 1 and is untouched here
- Evidence: `visual-fidelity/visual-fidelity-report.md` §`Correction (Reviewer
  B1)`, §`Regression guard`, §`Verification`; test source read directly
- OQ discipline: OQ5 triage in §`Open Question Impact` remains sound. The new
  tests assert light-theme token *values* only and enable no light-theme
  surface, so the story's OQ5 scope boundary holds.

## State Recommendation

- Keep `Implementation (Development)` checked
- Check `Review (Reviewer)`
- Story status: `DONE`
- D2 is recorded here for traceability only and requires no follow-up story
