# 035_welcome-design-fidelity-hardening-solution.md

## 0. Metadata

- Complexity: standard
- Date: 2026-08-16

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: AC1 forces a rendered-to-rendered comparison method
  (closing IF-7); AC2 forces a physically present, same-story evidence pair;
  AC4 forces any surfaced deviation to be fixed in app code, not documented.
- Architectural invariants / non-goals: `welcome` screen only; dark + `vi`
  only; no new copy, CTA, or screen state; no shared design-system or asset
  change; STORY-004 / STORY-033 / BUG-20260816-001 artifacts and git
  boundaries stay closed.
- Proposed technical direction: single mobile-lane phase that runs the
  existing preview-harness capture path (`lib/main_preview.dart` +
  `--dart-define=PREVIEW=welcome` + `adb exec-out screencap`) against the
  existing canvas renderer (`render-design-canvas.js --screen=welcome`), then
  compares region-by-region, fixes only inside the welcome screen widget if a
  real deviation appears, and re-renders both sides to confirm.
- Why this fits: both render paths already exist and were already exercised on
  this exact screen by BUG-20260816-001. This story adds no new mechanism — it
  applies the correct method and leaves the evidence behind.

### Key Discovery

**The current implementation already satisfies every match criterion in
`../ux/uiux-spec.md`. The deviation list that spec carries is drawn from a
stale, pre-fix capture and must be treated as a hypothesis to disprove, not a
work list.**

`mobile/lib/features/auth/presentation/screens/welcome_screen.dart` at BaseHead
`e28a6c2` reads:

- background `colors.gradientBrandBackdrop` — a dedicated token whose value is
  verbatim the design source's `linear-gradient(165deg,#7B2FBE 0%,#FF4B8C 58%,
  #FF3366 100%)`, introduced by BUG-20260816-001
  (`mobile/lib/design_system/tokens/cupid_color_tokens.dart`);
- hero left-aligned (`CrossAxisAlignment.start`), accent rule 52x4 / radius 2 /
  alpha 0.55 with 18px-above and 16px-below gaps, tagline 23px w700 h1.3 at
  maxWidth 280, sub-copy 14px h1.55 alpha 0.78 at maxWidth 270;
- CTA block bottom-pinned via `Expanded` hero + sibling CTA column, 52px rows,
  `context.cupidPlatform.radiusButton`, 10px gaps, 16px/w600 labels; Apple
  gated on `CupidPlatform.ios`; Google filled `colorText` with `colorBackground`
  label, `elevation: 2`, and a real `CupidBrandMark.google` glyph; Email as a
  1.5px `colorText`-alpha-0.5 `OutlinedButton`; footnote 11.5px h1.5 alpha 0.65,
  center-aligned.

Two consequences for implementation:

1. The UX spec's "target implementation is `colors.gradientHot` with its stops
   reversed on a `165deg` axis" describes the *value*, which the codebase now
   carries as the purpose-built `gradientBrandBackdrop` token. Re-deriving a
   reversed `gradientHot` would be a regression, not a fix. `gradientHot` is
   the two-stop 95deg **button** fill and must not paint this backdrop.
2. STORY-033's `implemented-welcome-emulator-5554.png` was captured before
   BUG-20260816-001 landed. It may not be reused as this story's baseline and
   must not be used to justify a code change.

The realistic outcome of this story is therefore: fresh evidence pair captured,
`VISUAL_FIDELITY: PASS` recorded, zero or near-zero app-code change. That is a
valid completion — AC4 is conditional on a deviation actually being found.

## 3. Scope And Assumptions

- In Scope: `mobile/lib/features/auth/presentation/screens/welcome_screen.dart`
  and its widget test; this story's `visual-fidelity/` and `coding-plan/`
  evidence directories.
- Out Of Scope: `mobile/lib/design_system/**`, `mobile/assets/**`,
  `mobile/pubspec.yaml`, any other screen, navigation/entry-point behavior.
- Assumptions affecting design: the emulator + `adb` capture path and the
  canvas renderer both work as exercised in
  `data/bugs/BUG-20260816-001_welcome_screen_backdrop_and_google_cta_brand_mark/fix-evidence.md`;
  `PREVIEW_BRIGHTNESS` defaults to `dark` and app default locale is `vi`, so no
  extra define is needed for AC3's configuration.

### Open Question Constraints

| OQ ID | Status | Technical Scope Blocked | Technical Scope Allowed | Architecture Decision |
|-------|--------|-------------------------|-------------------------|-----------------------|
| OQ5 | UNRESOLVED | Light-theme and `en`-locale rendering or capture | Dark + `vi` rendering and capture only | Capture and render exactly one configuration on both sides; do not add a second theme/locale pass |

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module: `mobile/lib/features/auth/presentation/` (welcome screen).
- New or changed boundaries: none. This story consumes existing design-system
  tokens and the existing preview harness; it does not extend either.
- Shared patterns reused: `context.cupidColors` / `context.cupidType` /
  `context.cupidPlatform` token access bound to a local (required by
  `no_fork_guard_test.dart`'s forbidden-literal-color scan); `PreviewScreenEntry`
  registration for `welcome`, which already exists in `mobile/lib/main_preview.dart`.

### Affected Modules

- Mobile: `features/auth/presentation/screens` only.

### WriteScope Boundary Decision (resolves the UX spec's deferred question)

`mobile/lib/design_system/**` and `mobile/assets/**` are **OUT** of this story's
WriteScope. STORY-004 D12/D13 stay deferred, and the reason has changed since
they were written:

- D12 (Google "G" glyph) is **already delivered** — `CupidBrandMark.google` and
  `CupidBrandMarkIcon` exist in
  `mobile/lib/design_system/icons/cupid_icons.dart` and are already wired into
  the Google CTA row. No asset or `pubspec.yaml` change is needed or permitted.
- D13 (literal brand hex tokens) stays deferred because the design source's
  `isWelcome` block specifies a monochrome per-provider treatment
  (`#000` / `#fff` / `#1A1A2E`), already token-mapped. Adding official brand
  hexes would be a new deviation from the locked design source, not a fix.
- A token edit is cross-screen by construction and would breach this story's
  `welcome`-only boundary.

Escalation path: if the fresh rendered comparison surfaces a deviation whose
only correct fix lives under `mobile/lib/design_system/` or `mobile/assets/`,
mobile-dev must stop and report a blocker to Scrum Master with the exact token
or asset and the exact rendered difference. It must not widen WriteScope, and
it must not work around the boundary with a screen-local literal color —
`no_fork_guard_test.dart` enforces that.

#### REVISION 2026-08-17 — narrow carve-out for the D1 gradient-axis defect

The escalation path above fired as designed. P0's rendered comparison surfaced
D1, corroborated independently by mobile-dev and Reviewer
(`../review/review-report.md`, "Deferred findings"): a measured axis error in
`gradientBrandBackdrop` (implementation 6.86 deg off vertical vs. the design
reference's 14.98 deg; CSS `linear-gradient(165deg,...)` requires 15.00 deg).
**The user was consulted and explicitly chose to fix D1 inside this story by
widening Write Scope rather than opening a follow-up item.** That decision is
the sole authority for the carve-out below; nothing else in the prior boundary
changes.

Newly authorized for Phase P1 only:

- `mobile/lib/design_system/tokens/cupid_color_tokens.dart`, restricted to the
  gradient-axis direction helpers `_gradient165Begin` / `_gradient165End`
  (behind `gradientBrandBackdrop`) and `_gradient95Begin` / `_gradient95End`
  (behind `gradientHot`), plus their doc comments and whatever construction
  those two token fields need to consume the corrected axis.
- One new sibling helper file under `mobile/lib/design_system/tokens/` **if and
  only if** the accepted mechanism (section 6) requires a `Gradient` subclass
  that cannot live inside the token file.
- `mobile/test/design_system/` for the new gradient-axis test.

Still excluded, unchanged: `mobile/assets/**`, `mobile/pubspec.yaml`, every
other token/field in `cupid_color_tokens.dart` (`gradientDream` and its
`_gradient120*` pair are **not** in scope — no measured defect and no consumer
in this story), every other design-system file, other screens' own widget
files, and all STORY-004 / STORY-033 / BUG-20260816-001 artifacts. This is a
defect-scoped carve-out, not a general design-system opening: any change here
that is not required to make the two named axis pairs geometrically correct is
out of scope.

#### D1 root cause and the invariant the fix must satisfy

Flutter's `Alignment(x, y)` is normalized to the painted box — it resolves to
`(centerX + x·width/2, centerY + y·height/2)`, so its components are scaled by
the box's aspect ratio. CSS `linear-gradient(<angle>)` is a true geometric
angle, independent of the box. Feeding raw `sin(θ)` / `cos(θ)` into `Alignment`
therefore only produces the CSS angle on a square box. On welcome's 412x915
box the error reproduces exactly:
`atan((0.2588·412)/(0.9659·915)) = 6.88 deg` against the 6.86 deg measured.

The corrected implementation must satisfy both halves of the CSS contract, not
just the first:

1. **Axis**: the rendered gradient line must sit at the declared CSS angle on
   any box, measured geometrically in device pixels.
2. **Extent**: the gradient line length must match the CSS definition,
   `|W·sin θ| + |H·cos θ|`, so declared stop percentages land where the design
   source puts them. A fix that corrects the angle but leaves the extent wrong
   moves `gradientBrandBackdrop`'s 58% pink band and is not a fix.

Colors and stop values on both tokens are already exactly correct and must not
be touched.

#### D1 blast radius (measured, and why the two tokens verify differently)

- `gradientBrandBackdrop`: exactly **one** consumer,
  `mobile/lib/features/auth/presentation/screens/welcome_screen.dart:148`, a
  full-screen backdrop. Aspect ratio is far from 1, so the error is large
  (8.1 deg) and plainly visible. This is the case rendered evidence can prove.
- `gradientHot`: roughly **20 consumers** across ~15 surfaces (auth, onboarding,
  pairing, chat, pet, reminders, expenses, account, vibes, dream jar,
  anti-ghosting, love contracts, plus `design_system/adaptive/cupid_primary_button.dart`
  and a direct `createShader(bounds)` call at
  `features/pairing/presentation/screens/waiting_screen.dart:281`). Almost all
  are short, wide pills/chips/toggles, where a 95deg axis on e.g. a 380x52 box
  renders 0.69 deg off horizontal against a CSS-correct 5.00 deg — a sub-5-deg
  error on a two-stop gradient across a 52px-tall pill, at or below the
  threshold a screenshot comparison can resolve.

This asymmetry drives the verification design in section 4's risk table: the
defect is a single math error in a shared helper, so a token-level axis test
that asserts the CSS angle and extent across a matrix of box shapes proves
correctness for **all** consumers more conclusively than eyeballing PNGs where
the error is sub-degree. Rendered evidence stays mandatory for `welcome`, where
it is both required by AC1/AC2 and actually resolvable.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|------------|-------------------|----------------------------|
| Evidence method (IF-7 recurrence) | AC1; `../requirements/requirements.md` | Both sides must be rendered artifacts; reading `.dc.html` source against the widget tree is prohibited as the comparison basis | Both PNGs physically present in this story's `visual-fidelity/`, each with its generating command recorded verbatim | `VISUAL_EVIDENCE_BLOCKED` naming the failing renderer or device step |
| Stale-baseline misread | This section 1 `Key Discovery` | STORY-033's pair and the UX spec's deviation list are hypotheses only; every claimed deviation must be visible in *this story's fresh* capture | Report cites only the fresh pair for each finding; no finding is sourced from STORY-033's PNGs | `EVIDENCE_AMBIGUOUS` when the fresh capture cannot be produced |
| Design-system scope creep | This section's WriteScope Boundary Decision | `mobile/lib/design_system/**` and `mobile/assets/**` excluded from WriteScope; escalate instead of widening | `git -C <Worktree> diff e28a6c2 --stat` shows no path outside the declared Write Scope; `flutter test` includes `no_fork_guard_test.dart` green | `SCOPE_BOUNDARY_BLOCKED` naming the token/asset and the rendered difference |
| Capture configuration drift | AC3; OQ5 row above | Both sides fixed to android / dark / `vi`; renderer flags and preview defines recorded verbatim in the report | Renderer invoked with `--platform=android --theme=dark --lang=vi`; APK built from `lib/main_preview.dart` with `--dart-define=PREVIEW=welcome` | `CAPTURE_CONFIG_BLOCKED` naming the flag that could not be honored |
| Regression from a fix that was not needed | AC4 | Change app code only when the fresh pair shows the deviation; otherwise record PASS with zero code change | If `welcome_screen.dart` changed: full `flutter test` green plus a re-captured post-fix `implemented-*.png` | `REVERIFY_BLOCKED` when re-capture after a fix is impossible |
| Gradient axis geometry (D1) | This section's `D1 root cause` subheading; `../review/review-report.md` D1 | Correct the axis at the shared helper so both the CSS angle and the CSS gradient-line extent hold on any box; colors and stops stay untouched | New `mobile/test/design_system/` axis test asserting resolved shader endpoints reproduce the declared CSS angle and extent across a box-shape matrix that spans every consumer's aspect class (tall full-screen, square, wide pill); plus welcome's fresh rendered pair measuring ~15.0 deg | `GRADIENT_AXIS_UNVERIFIABLE` naming the box shape whose expected geometry could not be asserted |
| Shared-helper regression across `gradientHot` consumers | This section's `D1 blast radius` subheading | Fix lives in one shared helper, so every consumer changes together; no per-screen overrides and no screen-local literals | Full `flutter test` green, including `no_fork_guard_test.dart` and every existing `*_design_fidelity_test.dart`; the axis test above covers the wide-pill aspect class that these ~20 consumers occupy | `CROSS_SCREEN_REGRESSION` naming the failing test and consumer |

### Lane Handoff

#### Mobile Lane

- Responsibilities: render both sides, compare, fix inside the welcome screen
  only if the fresh pair shows a deviation, re-verify, write the evidence pair
  and `visual-fidelity-report.md`.
- Authoritative inputs: `../ux/uiux-spec.md` match criteria; the design source
  `cupid-app-design-system/project/Cupid Screens.dc.html` `isWelcome` block
  (lines 68-91) as the render input only, never as the comparison basis.
- Guardrails:
  - Do not write outside the phase `Write Scope`. For P0 that excludes all of
    `mobile/lib/design_system/**`; for P1 the exclusion narrows only by the
    `REVISION 2026-08-17` carve-out above. `mobile/assets/**` and
    `mobile/pubspec.yaml` stay prohibited in both phases.
  - Do not replace `gradientBrandBackdrop` with `gradientHot` or any reversal of
    it; do not introduce a screen-local literal hex.
  - In P1, do not change any gradient's colors or stop values, and do not touch
    `gradientDream` / the `_gradient120*` pair — only the two named axis pairs
    have a measured defect.
  - Do not touch STORY-004, STORY-033, or BUG-20260816-001 artifacts.
  - Do not record `VISUAL_FIDELITY: PASS` without both PNGs physically present
    in this story's own `visual-fidelity/` directory **and** the D1 gradient
    axis confirmed correct — the current report honestly records
    `VISUAL_FIDELITY: BLOCKED` and must not be flipped to PASS before P1 lands.
  - Do not treat renderer-vs-Flutter font anti-aliasing, the device status bar,
    or the reference image's device bezel as deviations.

## 5. Non-Functional Impact

- Capture requires a booted Android emulator visible to `adb`; if none can be
  booted, the story is blocked rather than downgraded to a source-read
  comparison — that downgrade is precisely the IF-7 defect this story exists to
  remove.
- P1's fix is size-dependent by nature: a geometrically correct CSS angle cannot
  be expressed as a `const Alignment` pair, because the correction depends on the
  painted box. Whatever mechanism is chosen must therefore keep
  `CupidColorTokens`'s `LinearGradient`-typed fields, `copyWith`, and `lerp`
  compiling unchanged — the `ThemeExtension` shape is consumed by ~20 call
  sites and is not part of this defect.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| Per-rect CSS-correct endpoint computation inside a `LinearGradient` subclass (override `createShader(Rect, {TextDirection})`) | The only place the painted box is known, and the one hook every consumer already funnels through — including the direct `colors.gradientHot.createShader(bounds)` call at `waiting_screen.dart:281` | ACCEPTED | Keeps the field type `LinearGradient`, so `copyWith`/`lerp`/`ThemeExtension` and all ~20 consumers compile untouched; stays `const`-constructible; satisfies both the axis and extent halves of the CSS contract. Watch one edge: `LinearGradient.lerp` returns a plain `LinearGradient` and would drop the override mid-theme-animation — acceptable here only because both tokens are byte-identical in dark and light (confirmed in the token file), so no visible lerp occurs. If mobile-dev finds a cleaner mechanism that satisfies the two invariants and the compile constraint above, it may substitute it and record why. |
| `transform: GradientRotation(θ)` on the existing `LinearGradient` | The obvious built-in, and named as a candidate in the P1 request | REJECTED | Fixes the axis but not the extent. `GradientRotation` rotates a `topCenter`→`bottomCenter` line about the box centre without rescaling it to the CSS gradient-line length `\|W·sin θ\| + \|H·cos θ\|`, so declared stops land off-position — on `gradientBrandBackdrop` that visibly moves the 58% pink band on welcome's 412x915 box. Trading an axis error for a stop-position error is not a fix. |
