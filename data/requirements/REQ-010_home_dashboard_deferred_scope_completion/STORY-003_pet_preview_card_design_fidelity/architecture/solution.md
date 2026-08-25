# STORY-003_pet_preview_card_design_fidelity-solution.md

## 0. Metadata

- Complexity: standard
- Date: 2026-08-25

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: the `PetReady` variant of `PetPreviewCard` deviates from
  the locked design source on chrome, decoration, content structure, and XP bar
  (`../ux/uiux-spec.md` §1-§3); and the design-fidelity capture harness cannot
  photograph that variant at all because `PetCubit.load()` hits an
  unauthenticated backend and resolves to `PetFailure` (AC3).
- Architectural invariants / non-goals:
  - The card keeps exactly one tap target reaching `PetRoute.push` from every
    state variant (AC4). No new entry point, no second gesture surface.
  - XP math stays `PetStatus.levelProgress` (`pet_models.dart:90`). Mood, level,
    and adoption logic are read-only for this story.
  - The four states the design source does not depict (`PetLoading`,
    `PetLocked`, `PetNoPet`, `PetFailure`) keep their current plain
    `colorSurface` chrome unchanged (`../ux/uiux-spec.md` §0).
  - Omitting the new dart-define leaves production behaviour bit-identical.
- Proposed technical direction: split the shared chrome into an unchanged
  `_PreviewShell` (four undepicted states) plus a new ready-only shell, extract
  the tap/`Semantics` wrapper both share, and add a `PREVIEW_PET_FIXTURE`
  dart-define in `main_preview.dart` that injects a preview `PetRepository`
  double through a new optional `HomeScreen` parameter into the already-mounted
  `PetPreviewCard`.
- Why this fits the current system: `main_preview.dart` already carries eight
  `_Preview*Repository` doubles and three `bool.fromEnvironment` fixture gates
  (`PREVIEW_HOME_FIXTURE` at line 832 is the closest precedent); `HomeScreen`
  already exposes three optional injection seams of exactly this shape
  (`resolveProfile`, `resolvePairingStatus`, `createTimelineCubit`).

### Key Discovery

The UX spec's assumption that `PetPreviewCard`'s existing `repository` override
is "the natural extension point" is correct but not sufficient. Two facts block
the obvious plumbing:

1. `PetPreviewCard` is mounted `const` and argument-free inside `HomeScreen`
   (`mobile/lib/features/home/presentation/home_screen.dart:191`), and
   `HomeScreen` has no pet-related parameter. The fixture therefore cannot be
   wired from `main_preview.dart` alone — `HomeScreen` must gain a fourth
   optional injection seam and the mount site loses `const`.
2. The existing test double `mobile/test/features/pet/presentation/fake_pet_repository.dart`
   cannot be reused: `lib/` must not import `test/`. The preview double is a
   separate, deliberate near-duplicate living in `main_preview.dart` alongside
   its siblings, and it implements the same four `PetRepository` members
   (`readPairing`, `readStatus`, `interact`, `adopt`).

## 3. Scope And Assumptions

- In Scope: `PetReady` chrome/decoration/content/XP-bar rendering in
  `pet_preview_card.dart`, one new optional `HomeScreen` injection parameter,
  and one new `main_preview.dart` fixture gate plus its repository double.
- Out Of Scope: `pet_screen.dart` and every other pet widget, `PetCubit`, mood
  and level computation, design-system token files, and the four undepicted
  compact state visuals.
- Assumptions affecting design:
  - `PetCubit.load()` reaches `PetReady` when `readPairing()` reports paired and
    `readStatus()` returns a non-null `PetStatus`; implementation confirms this
    against `pet_cubit.dart` before authoring fixture values.
  - `colorAccentPink`, `colorMint`, `colorLine`, and `gradientDream` already
    equal their design-source counterparts exactly (asserted by
    `../ux/uiux-spec.md` §1 and §3.5); no new design token is introduced.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module: `mobile/lib/features/pet/presentation/widgets/` for rendering;
  `mobile/lib/main_preview.dart` for capture-harness state.
- New or changed boundaries: `HomeScreen` gains one optional
  `PetRepository? petRepository` seam, mirroring its existing `resolveProfile`
  seam exactly (nullable field, private default, resolved at the mount site).
  This is the only production-code coupling the fixture adds, and it is inert
  when the parameter is omitted.
- Shared patterns reused: `main_preview.dart` `bool.fromEnvironment` fixture
  gate + `_Preview*Repository implements *Repository` double
  (`PREVIEW_HOME_FIXTURE` / `_previewHomeProfile`, lines 824-847); the
  `ClipRRect` → `Stack` → `Positioned.fill(ColoredBox)` +
  `FractionallySizedBox(DecoratedBox(gradient))` progress-bar pattern from
  `pet_xp_card.dart:68-89`; the static `Positioned` + `IgnorePointer` +
  `RadialGradient` hero-glow pattern from `home_screen.dart:303-311`.

### Affected Modules

- Mobile: `features/pet/presentation/widgets`, `features/home/presentation`,
  preview entrypoint `main_preview.dart`.

### Contracts And Integrations

- Empty-state contract: the fixture changes only which `PetState` the preview
  harness observes. It must not add a new state, and it must not make
  `PetFailure` unreachable in production — the failure branch stays wired.
- Compatibility posture: additive-only. Every new parameter and define is
  optional with a default that reproduces today's behaviour.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|------------|-------------------|----------------------------|
| Ready-state chrome fidelity | `../ux/uiux-spec.md` §1-§2; design source `Cupid Screens.dc.html` `isHome` lines 291-303 | Ready-only shell built from named tokens (`colorAccentPink`/`colorMint`/`colorLine`), never literal colors; glow circle positioned with `LayoutBuilder` for the 12% card-relative offset | Widget test asserting the ready shell's gradient stops, border, `ClipRRect`, and glow geometry; plus fixture-backed capture compared to the design source | Report `MOBILE_VERIFY_BLOCKED` naming the missing capture step; do not claim AC1 from code reading |
| Undepicted compact states unchanged | `../ux/uiux-spec.md` §0 | `_PreviewShell` body is not edited at all; the ready variant gets a separate widget rather than a branch inside it | Widget test asserting `PetLoading`/`PetLocked`/`PetNoPet`/`PetFailure` still render flat `colorSurface` with no gradient and no glow | Same as above |
| XP bar restructure | `../ux/uiux-spec.md` §3.5; `pet_xp_card.dart:68-89`; `pet_models.dart:90` | Replace `LinearProgressIndicator` with the existing gradient pattern; `widthFactor` stays `status.levelProgress.clamp(0.0, 1.0)` | Widget test asserting track color `colorSurface`, 8px height, `gradientDream` fill, and `widthFactor` equal to `levelProgress` for an authored status | Report the exact failing assertion |
| Fixture must not alter production behaviour | `main_preview.dart:824-847` precedent | Optional parameter + `bool.fromEnvironment` default `false`; live path resolves `getIt<PetRepository>()` as today | Widget test asserting a default `HomeScreen()` passes no repository override and the card still resolves from the service locator | Report `MOBILE_VERIFY_BLOCKED` with the failing test path |
| Tap target / entry-point reachability (AC4) | `../ux/uiux-spec.md` §5; `home_screen.dart:191` mount | Tap + `Semantics` wrapper extracted once and shared by both shells; decorative glow wrapped in `IgnorePointer` | Existing/extended entry-point test asserting a tap on the ready card reaches `PetRoute`, and the card is still mounted in the Home column | Report the failing navigation assertion; never mark the story complete on an unreachable card |

### Lane Handoff

#### Mobile Lane

- Responsibilities: all four risk-bearing edits and their tests, plus the
  fixture-backed rendered capture that proves AC1 and AC3.
- Authoritative inputs: `../ux/uiux-spec.md` §0-§5 (per-property correction
  table), this file's section 4, `../requirements` (story acceptance criteria).
- Guardrails:
  - Do not edit `_PreviewShell`'s existing body, `pet_screen.dart`, any
    `design_system/` token file, or any pet data/cubit file.
  - Do not add an `AnimationController`, a pub dependency, or a new shared
    typography token; the 17px/w900 Nunito pet name is a local `TextStyle`
    literal, matching the `home_screen.dart` couple-name precedent
    (`../ux/uiux-spec.md` §3.3).
  - Do not import anything from `mobile/test/` into `mobile/lib/`.
  - Do not add a second tap target, route, or navigation destination.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| Separate ready-only shell widget + extracted shared tap wrapper | `../ux/uiux-spec.md` §0 leaves the split mechanism to Tech Lead | ACCEPTED | Makes "compact states unrepainted" structurally true rather than test-enforced, while keeping the AC4 tap contract defined exactly once |
| `_PreviewShell({bool ready = false})` boolean branch | Fewer widgets, one file-local change | REJECTED | One build method would own two different chromes, so every future edit to the compact path can silently reach the ready path — the §0 invariant would rest on reviewer vigilance instead of structure |
