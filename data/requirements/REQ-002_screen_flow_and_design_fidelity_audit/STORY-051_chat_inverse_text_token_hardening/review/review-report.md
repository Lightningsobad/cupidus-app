# STORY-051 — Review Report (compact-story-review)

Outcome: PATCH_REQUIRED

- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Story: STORY-051 (RED-PATCH of STORY-018, source RWB-20260816-016)
- Complexity: trivial · Implementation Lane: shared · Story-Class: standard
- Reviewer: Iris-QC · Date: 2026-08-18
- Review diff range: `7d8fc62..8d5b3cf` (single commit, whole story contribution)
- Blocking findings: 1 · Deferred findings: 2

## Scope Gate

- Review type: `compact-story-review` (no separate `scope-gate.md`, per skill 5a)
- Report path: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-051_chat_inverse_text_token_hardening/review/review-report.md`
- Source files in scope (3, within the 8-file compact budget):
  - `mobile/lib/design_system/tokens/cupid_color_tokens.dart`
  - `mobile/lib/features/chat/presentation/widgets/message_bubble.dart`
  - `mobile/lib/features/chat/presentation/widgets/chat_composer.dart`
- Evidence files in scope: `visual-fidelity/visual-fidelity-report.md`,
  `visual-fidelity/implemented-chat-emulator-5560.png`,
  `visual-fidelity/design-reference-chat-android.png`, `story_master.md`
- Query keys: `colorOnAccent`, `colorText`, `colorSurface`, `gradientHot`,
  `isMine`, `wrapInShell`, AC1–AC4
- Retro discipline: this IS the retro rework item (RWB-20260816-016), so skill
  rule 1a does not bar the handoff.

## Acceptance Criteria

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC1 — new per-theme `colorOnAccent` token, no raw literal in `features/**` | PASS | `cupid_color_tokens.dart` L61 (ctor), L89 dark `#F7EEFB`, L159 light `#FFFFFF`, L230 field decl, L306/L332 `copyWith`, L367 `lerp`. All six `colorText` touch points mirrored — the Tech Lead `ThemeExtension`/`lerp` invariant is satisfied, verified directly against the diff. |
| AC2 — `message_bubble.dart:99` and `chat_composer.dart:310` consume the token | **FAIL** | `chat_composer.dart:312` is correct (`enabled` branch only; disabled keeps `colorTextMuted`). `message_bubble.dart:99` is **unconditional** and therefore also repaints the partner bubble, which AC2 does not scope. See B1. |
| AC3 — dark-theme render visually unchanged | PASS | Dark `colorOnAccent` is a byte-verbatim copy of dark `colorText` (`0xFFF7EEFB`), so equality holds by construction; the pixel evidence independently agrees. All four differing row bands are clock / background particles / `ghostFade` phase — none deterministic, none story-touched. Send-button region byte-identical (`getbbox() -> None`). Caveat on the report's stated rationale in D1. |
| AC4 — light-theme value adequate on the gradient, by value inspection | PASS | All four contrast figures independently recomputed and confirmed: `#FFFFFF`/`#FF7FB6` 2.34:1, `#FFFFFF`/`#B78CF5` 2.60:1, `#F7EEFB`/`#FF7FB6` 2.07:1, `#F7EEFB`/`#B78CF5` 2.30:1. `gradientHot` confirmed theme-invariant in source (`cupid_color_tokens.dart` L124-128 dark, L201-205 light — literal stops, not `colorAccentPink`/`Purple` refs), so the comparison is apples-to-apples. White is the maximum achievable lightness on that gradient and strictly better than the already-shipped dark value; the sub-AA carry-forward is disclosed with ADR-004b/c precedent rather than hidden. |

## Blocking Findings

### B1 — `colorOnAccent` is applied to partner bubbles too; white-on-white text in light theme

`mobile/lib/features/chat/presentation/widgets/message_bubble.dart` is a single
widget that renders **both** bubble kinds off `isMine`. The background is
branched, the text colour is not:

```dart
decoration: BoxDecoration(
  gradient: isMine ? colors.gradientHot : null,   // L87
  color: isMine ? null : colors.colorSurface,     // L88
...
child: Text(
  message.content,
  style: type.body.copyWith(
    color: colors.colorOnAccent,                  // L99 — no isMine guard
```

So the partner bubble now paints `colorOnAccent` on a `colorSurface`
background. In light theme both resolve to pure white:

| Theme | Partner bubble bg | Partner bubble text | Contrast |
| --- | --- | --- | --- |
| dark | `colorSurface` `#241B42` | `colorOnAccent` `#F7EEFB` | 12.8:1 — unchanged, defect masked |
| light — before | `colorSurface` `#FFFFFF` | `colorText` `#3E2645` | 13.39:1 — correct |
| light — after | `colorSurface` `#FFFFFF` | `colorOnAccent` `#FFFFFF` | **1.00:1 — invisible** |

Why this is blocking, not deferred:

1. **It contradicts the token contract authored in this same commit.**
   `cupid_color_tokens.dart:227-229` states `colorOnAccent` is "rendered on top
   of `gradientHot`. Scoped to that accent-fill surface only; general body/label
   text keeps using `colorText`." The partner bubble is on `colorSurface`, not
   `gradientHot`.
2. **It exceeds AC2's stated surface.** AC2 names "`message_bubble.dart:99`
   (own-message bubble text)". Per skill rule 14, exact AC text controls; the
   parenthetical identifies the surface, and an unguarded edit at that line
   covers a second surface the AC does not authorise.
3. **It is in scope despite OQ5.** The story's own `## Product Owner Triage`
   rests on "build token infrastructure correct for all 4 combinations now",
   quoting STORY-019: "token-level fixes should stay correct for all 4
   combinations since tokens are shared." AC4 exists precisely to check
   light-theme correctness without a render. Light-theme correctness is the
   story's premise, not out of its scope.
4. **The story made it worse.** This is a RED-PATCH created to close a
   light-theme contrast defect (`#3E2645` on gradient). It closes that one and
   opens a strictly more severe one (1.00:1, fully invisible) on the adjacent
   surface — skill rule 7's "current story made it worse" test.

Fix (owner: **Mobile Developer**), one line, no token change needed:

```dart
color: isMine ? colors.colorOnAccent : colors.colorText,
```

Add a light-theme widget regression assertion alongside it (the existing
`test/design_system/` + `test/features/chat/` suites cannot catch this: every
dark-theme assertion passes either way because dark `colorOnAccent` and dark
`colorText` are the same hex — which is exactly how this reached review).

## Deferred Findings

- **D1 — the AC3 "control region" argument is invalid, though AC3 itself
  holds.** `visual-fidelity-report.md:73-77` uses the partner bubble as a
  control, asserting it "still consumes `colorText` … confirming the edit did
  not leak past the `isMine` branch." The partner bubble is inside the changed
  code path, so it is not a control, and the observed delta 0 is produced by the
  identical dark hex values rather than by scoping. The pixel measurements are
  real and AC3 stands; only this inference must be struck. Worth correcting when
  B1 is patched, because this sentence is what asserted the absence of B1.
- **D2 — no explicit `Design-Screen:` line in `story_master.md`.** The
  resolved id is recoverable from the report (`render-design-canvas.js
  --screen=chat`, reference reused from STORY-040), and I confirmed by opening
  `design-reference-chat-android.png` that it depicts this story's chat screen.
  Non-blocking; recording the id explicitly would remove the re-derivation.

## Touched Risk Surfaces And Critical Gates

| Surface | Gate | Result |
| --- | --- | --- |
| Typed/generated contract (`ThemeExtension` field) | `copyWith` + `lerp` completeness | PASS — verified in diff at L332 and L367 |
| Mobile interaction / theming | `flutter analyze --no-fatal-infos lib test` | PASS — 0 errors, 0 warnings, 80 infos matching STORY-040 baseline |
| Mobile interaction / theming | `flutter test` full suite | PASS — 1285 passed / 2 skipped / 0 failed |
| Mobile build | debug APK build + install | PASS |
| Mobile runtime startup smoke | cold launch `cupidpreview://screen/chat`, no ErrorWidget | PASS (not mandatory for a `trivial` story under 12g; supplied anyway) |
| Mobile design fidelity (12e3) | both images open as real images, show this story's chat screen, reference is the right screen, no visible contradiction of `PASS` | PASS — verified by opening both, not by counting files |
| Light-theme token consumption | value inspection per AC4 | **FAIL for the partner-bubble surface** — see B1 |

Entry-point reachability (12e1): not applicable — no new user-facing capability
or surface; the chat screen's entry point is unchanged by this story.
Configuration-guide impact (12a): none — no setup, env, or runtime configuration
touched.

## Specifically Verified On Request

- **`lerp`/`ThemeExtension` completeness** — all six touch points mirrored,
  confirmed against the diff, not against the report's claim.
- **Preview-registry flag restored** — confirmed independently:
  `git diff --stat HEAD -- mobile/lib/main_preview.dart` is empty,
  `main_preview.dart` is absent from the story commit's file list, and every
  `wrapInShell:` entry in the registry reads `true` (no `false` remains). The
  report's claim is accurate.
- **Contrast math** — all four ratios recomputed from WCAG 2.x relative
  luminance and matched; `gradientHot`'s theme-invariance verified in source
  rather than accepted from the spec's loose parenthetical.
- **Pixel-equality methodology** — sound for what it measured (real per-row
  band analysis, byte-identical send region); the only unsound step is the
  control-region inference recorded as D1.

## Traceability

- Requirements / ACs: `story_master.md` §`Acceptance Criteria`, §`In Scope`,
  §`Out of Scope`, §`Product Owner Triage (2026-08-18)`
- UX: `ux/uiux-spec.md` (token values, contrast rationale)
- Architecture: `SKIPPED:trivial`, recorded in `story_master.md` with the
  `ThemeExtension` `lerp` invariant — invariant verified as met
- Evidence: `visual-fidelity/visual-fidelity-report.md` §`Verification`,
  §`AC3`, §`AC4`; both rendered PNGs opened and inspected
- OQ discipline: OQ5 triaged in `story_master.md` §`Open Question Impact`;
  triage is sound and no AC is blocked by it. B1 is not an OQ over-application —
  it is an unguarded call site.

## Action Items

1. **Mobile Developer** — guard `message_bubble.dart:99` on `isMine`
   (`isMine ? colors.colorOnAccent : colors.colorText`), so `colorOnAccent`
   stays on the `gradientHot` surface its own dartdoc scopes it to.
2. **Mobile Developer** — add a light-theme widget regression assertion that a
   partner bubble's text colour is not `colorSurface`, so a dark-theme-only
   suite can no longer mask this class of defect.
3. **Mobile Developer** — strike or correct the "control region" inference in
   `visual-fidelity-report.md:73-77` (D1); keep the pixel measurements, which
   remain valid.

## State Recommendation

- Uncheck `Implementation (Development)`
- Leave `Review (Reviewer)` unchecked
- Story status: `IN_PROGRESS` — return to the mobile lane for the B1 patch
- Do not mark `DONE`
