# Phase P2 – Jar Detail, Preset Quick-Add, Unpaired Notice

## 1. Objective

Deliver the primary Dream Jar screen: hero progress card, the three confirmed
preset contribution tiles (AC1), and the shared unpaired notice widget (AC3)
that P3 and P4 reuse.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-jar-detail.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/dream_jar/presentation/dream_jar_detail_cubit.dart`
  - `mobile/lib/features/dream_jar/presentation/screens/dream_jar_detail_screen.dart`
  - `mobile/lib/features/dream_jar/presentation/widgets/dream_jar_hero_card.dart`
  - `mobile/lib/features/dream_jar/presentation/widgets/dream_jar_unpaired_notice.dart`
  - `mobile/lib/l10n/arb/app_en.arb`, `mobile/lib/l10n/arb/app_vi.arb` (append keys only)
  - `mobile/test/features/dream_jar/presentation/dream_jar_detail_cubit_test.dart`
  - `mobile/test/features/dream_jar/presentation/dream_jar_detail_screen_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: widget test pump of the detail screen
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `DreamJarDetailCubit` and its states (`loading`, `ready`, `submitting`, `unpaired`, `failure`)
  - `DreamJarUnpairedNotice` widget (consumed by P3 and P4)
  - `DreamJarDetailScreen(jarId)` route target
- Shared Interfaces Consumed:
  - P1 `DreamJarRepository`, `DreamJar`, `DreamJarUnpairedFailure`, `DreamJarAmountFormat`
  - `mobile/lib/design_system/**` tokens and adaptive widgets
- Risk Surfaces:
  - Double contribution submission
  - Progress / liquid-fill bounds
  - Unpaired access (AC3)
  - ARB key parity
  - Design-system compliance
- Source Of Truth:
  - authoritative artifact: `../ux/uiux-spec.md` §1.1 (hero, presets, copy branches), §1.8 (unpaired), §2, §3
  - consumer contract: P3 and P4 import `DreamJarUnpairedNotice` rather than re-implementing it
- Primary Inputs Summary:
  - architecture: `../architecture/solution.md` §2, §4 `Contracts And Integrations` (non-idempotent contribution POST)
  - OQ constraints: ADR-014a — no encryption badge, lock, or shield affordance anywhere on this screen
  - upstream phase outputs: P1 repository, models, formatter, failure type
  - UX constraints: §1.1 `liquidY = 154 - 108 * min(1, current/target)`; encouragement copy branches on `DreamJarStatus.completed`, not on the raw percentage; §1.8 relies on the global pairing gate, so this screen only renders the notice defensively
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one screen plus its cubit and two widgets
  - Source/Test File Count: 4 source + 2 test (plus append-only ARB edits)
  - Split Required: NO

## 2. Required Reads

- `../architecture/solution.md` §2, §4 `Contracts And Integrations`
- `../ux/uiux-spec.md` §1.1, §1.8, §2, §3, §4
- P1 outputs in `mobile/lib/features/dream_jar/data/`
- `mobile/lib/features/auth/presentation/sign_out_cubit.dart` (cubit/state shape to mirror)

## 3. Tasks

- Add `DreamJarDetailCubit(DreamJarRepository)` with `load(jarId)`, `refresh()`, and `contribute(num amount)`; map `DreamJarUnpairedFailure` to an unpaired state and other `CupidApiFailure`s to a failure state carrying a localized message.
- Ignore `contribute` calls while a contribution is already in flight, and reload the jar after a successful contribution so `currentAmount`/`progress` come from the server rather than being computed locally.
- Build `DreamJarHeroCard` from design-system tokens: gradient hero, jar fill height from the UX §1.1 formula clamped to `0..1`, name chip, `current / target · percent` amount line, and the encouragement pill branching on `DreamJarStatus.completed`.
- Build `DreamJarDetailScreen(jarId)`: hero card, a quick-add row of exactly three preset tiles (+100k / +200k / +500k VND, last tile emphasized), pull-to-refresh, refresh on screen focus, and a "See all contributions" affordance that is inert until P4 lands (wire the navigation in P4).
- Build `DreamJarUnpairedNotice`: centered icon plus localized explanation, no retry loop, no encryption claim.
- Append all new strings to both ARB files with matching keys; format every amount through `DreamJarAmountFormat.vnd`.
- Disable the whole quick-add row and show inline progress while a contribution is submitting; surface a failure without losing the currently rendered jar.

## 4. Acceptance Criteria

- Loading a jar renders name, current amount, target amount, and clamped percent from the repository response.
- Tapping a preset tile issues exactly one `POST /dream-jar/:id/contributions`; a second tap during submission issues none.
- After a successful contribution the screen shows server-refreshed amounts.
- A `DreamJarUnpairedFailure` renders `DreamJarUnpairedNotice`, not a generic error (AC3).
- Jar fill fraction is 0 when `targetAmount = 0` and never exceeds 1 when `currentAmount > targetAmount`.
- `app_en.arb` and `app_vi.arb` contain the same new keys; no hardcoded user-facing string in Dart.
- No encryption/lock/shield affordance or "end-to-end encrypted" copy appears.

## 5. Planned Outputs

- Code files: the paths listed in `Write Scope`
- Contracts: `DreamJarDetailCubit`, `DreamJarUnpairedNotice`, `DreamJarDetailScreen`
- Requirement configuration guide updates: none

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, jar detail screen
- Required levels:
  - unit: cubit state transitions for load, refresh, contribute success, contribute-while-submitting, unpaired failure, generic failure
  - mobile build/type-check/static-analysis: `flutter analyze` clean for touched files
  - visual inspection: none in this phase (requirement-level mobile visual audit only)
- Required checks: widget test pumps the screen with a fake repository and asserts the three preset tiles, the amount line, and the unpaired notice branch
- Mobile discoverability / navigation integration: not owned here — P5 owns the discoverable entry point
- Minimum gates by risk surface: double submission → cubit test; progress bounds → fill-fraction unit test; AC3 → unpaired widget test; ARB parity → existing `test/l10n/arb_parity_test.dart`; design-system compliance → existing `test/design_system/` guards
- Required regression or contract coverage: `test/l10n/arb_parity_test.dart` and `test/design_system/**` stay green
- Evidence format: concise rows in `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests: `flutter test test/features/dream_jar`
  - Static analysis: `flutter analyze`
  - Required assertion evidence: emitted cubit states and rendered widget finders

## 7. Status

- Status: DONE
- Last updated: 2026-07-30
- Scope note: implemented per the handoff's explicit instruction to build
  "exactly as scoped in the master-plan.md P2 row" — hero progress card,
  3 preset quick-add tiles disabled while submitting, and the unpaired
  notice widget. This phase file's task list (§3) additionally describes
  pull-to-refresh, refresh-on-focus, and an inert "See all contributions"
  affordance; those were not part of the handoff's scope and are not
  implemented here. P3/P4 owners should confirm whether that wiring lands
  in P3/P4/P5 or needs a follow-up note.
- Implementation notes:
  - Progress fill uses a simple proportional `FractionallySizedBox` bar
    instead of the UX §1.1 liquid-jar formula/illustration — no SVG asset
    or new pubspec dependency is available (ADR-014a), so an equivalent
    accessible proportional fill is used instead, clamped to `0..1` via
    `(progressPercent / 100).clamp(0, 1)`.
  - `DreamJarUnpairedNotice` renders title + body text only, no icon —
    no verified glyph codepoint exists in `cupid_icons.dart` for a
    jar/savings icon, and inventing one would violate the icon-glyph
    verification rule.
  - `DreamJarDetailCubit.addContribution` relies on Dart's
    synchronous-until-first-`await` execution: the in-flight guard check
    and `emit(isAddingContribution: true)` both run before the first
    `await`, so two back-to-back synchronous calls (as in the widget
    double-tap test) still only reach the repository once.
  - Both ARB files were edited additively only; no existing key changed.
- Evidence:
  - `flutter test test/features/dream_jar/presentation` — 10 tests passed
    (7 cubit unit tests, 3 widget tests, including the double-submission
    guard at both the cubit and widget level).
  - `flutter test test/features/dream_jar/data test/l10n/arb_parity_test.dart
    test/design_system` — 74 tests passed (P1 data-layer regression, ARB
    parity, design-system no-fork/adaptive/theme-matrix/icon-variant
    guards all stayed green).
  - `flutter analyze lib/features/dream_jar test/features/dream_jar` — No
    issues found.
  - `git status --porcelain` in the story worktree shows only the six
    write-scope files (4 new presentation source files, 2 new test files)
    plus additive edits to the two ARB files; no P1 (`data/**`) file
    changed.
