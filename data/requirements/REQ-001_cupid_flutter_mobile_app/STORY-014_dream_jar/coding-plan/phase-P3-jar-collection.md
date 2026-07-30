# Phase P3 – Jar List, Empty State, Create-Jar Flow

## 1. Objective

Deliver the jar collection surface and jar creation: list with status badges,
the first-run empty state, the single-jar shortcut, and the create-jar sheet
that satisfies AC1's "add to the shared jar" entry path.

## 1A. Ownership

- Phase ID: P3
- Canonical Phase File: `phase-P3-jar-collection.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1, P2
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/dream_jar/presentation/dream_jar_list_cubit.dart`
  - `mobile/lib/features/dream_jar/presentation/create_dream_jar_cubit.dart`
  - `mobile/lib/features/dream_jar/presentation/screens/dream_jar_list_screen.dart`
  - `mobile/lib/features/dream_jar/presentation/widgets/create_dream_jar_sheet.dart`
  - `mobile/lib/l10n/arb/app_en.arb`, `mobile/lib/l10n/arb/app_vi.arb` (append keys only)
  - `mobile/test/features/dream_jar/presentation/dream_jar_list_cubit_test.dart`
  - `mobile/test/features/dream_jar/presentation/create_dream_jar_sheet_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: widget test pump of the list screen
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `DreamJarListCubit` and its states (`loading`, `empty`, `ready`, `unpaired`, `failure`)
  - `DreamJarListScreen` route target (P5 navigates to it)
  - `CreateDreamJarSheet` + `CreateDreamJarCubit`
- Shared Interfaces Consumed:
  - P1 `DreamJarRepository`, `DreamJar`, `DreamJarAmountFormat`, `DreamJarUnpairedFailure`
  - P2 `DreamJarUnpairedNotice`, `DreamJarDetailScreen`
  - `mobile/lib/design_system/**` tokens and adaptive widgets
- Risk Surfaces:
  - Unpaired access (AC3)
  - ARB key parity
  - Design-system compliance
- Source Of Truth:
  - authoritative artifact: `../ux/uiux-spec.md` §1.2 (list rules and status badges), §1.3 (create form), §1.5 (empty state)
  - consumer contract: P5 pushes `DreamJarListScreen` as the single Dream Jar entry route
- Primary Inputs Summary:
  - architecture: `../architecture/solution.md` §2, §3 (VND-only, archived filter, no edit/archive/delete in v1)
  - OQ constraints: ADR-014a (no encryption affordance); ADR-014f (archived jars filtered out, no toggle); deferred scope must not be implemented
  - upstream phase outputs: P1 data layer, P2 unpaired notice and detail route
  - UX constraints: §1.2 zero jars → empty state, exactly one non-archived jar → open the detail directly, 2+ → list; §1.3 required name, required target amount with min-1 validation and as-you-type VND grouping, optional deadline via platform-adaptive date picker, no currency selector
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: collection listing plus creation
  - Source/Test File Count: 4 source + 2 test (plus append-only ARB edits)
  - Split Required: NO

## 2. Required Reads

- `../architecture/solution.md` §2, §3
- `../ux/uiux-spec.md` §1.2, §1.3, §1.5, §2, §3
- P1 outputs in `mobile/lib/features/dream_jar/data/`
- P2 `dream_jar_unpaired_notice.dart` and `screens/dream_jar_detail_screen.dart`

## 3. Tasks

- Add `DreamJarListCubit(DreamJarRepository)` with `load()` and `refresh()`; filter out `DreamJarStatus.archived` jars for display and emit `empty` when nothing remains.
- Emit an unpaired state on `DreamJarUnpairedFailure` and render `DreamJarUnpairedNotice`.
- Build `DreamJarListScreen`: pull-to-refresh, one card per jar (name, progress bar, `current / target`, mint check badge for `completed`), tap opens `DreamJarDetailScreen(jar.id)`, and a pinned "New Dream Jar" CTA.
- When exactly one non-archived jar exists, replace the list body with `DreamJarDetailScreen` content for that jar per UX §1.2 (keep a single navigation entry so the back stack stays one level deep).
- Render the UX §1.5 empty state (tinted `savings` icon, encouraging copy, single create CTA) for the `empty` state.
- Add `CreateDreamJarCubit` with a `submit({name, targetAmount, deadline})` guarded against double submission, and `CreateDreamJarSheet` using the adaptive bottom-sheet chrome: required name field, numeric target field with `DreamJarAmountFormat.grouped` as-you-type formatting and a localized min-1 validation message, optional platform-adaptive date picker, adaptive primary CTA. Do not render a currency selector.
- On create success, close the sheet and refresh the list so the new jar comes from the server.
- Append all new strings to both ARB files with matching keys.
- Do not implement edit, archive, delete, custom-amount, or archived-toggle affordances.

## 4. Acceptance Criteria

- Zero jars renders the empty state with a working create CTA; 2+ jars renders one card per non-archived jar; exactly one non-archived jar renders the detail content directly.
- Archived jars never appear in the list.
- Tapping a jar card opens that jar's detail screen.
- Submitting the create sheet with a blank name or a target amount below 1 shows a localized validation message and issues no request.
- A valid submit issues exactly one `POST /dream-jar` and the new jar appears after the refresh; a second submit while in flight issues none.
- A `DreamJarUnpairedFailure` renders `DreamJarUnpairedNotice` (AC3).
- `app_en.arb` and `app_vi.arb` contain the same new keys; no hardcoded user-facing string in Dart.

## 5. Planned Outputs

- Code files: the paths listed in `Write Scope`
- Contracts: `DreamJarListCubit`, `DreamJarListScreen`, `CreateDreamJarCubit`, `CreateDreamJarSheet`
- Requirement configuration guide updates: none

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, jar list and create sheet
- Required levels:
  - unit: list cubit states for zero / one / many jars, archived filtering, unpaired failure, generic failure; create cubit validation and double-submit guard
  - mobile build/type-check/static-analysis: `flutter analyze` clean for touched files
- Required checks: widget test pumps the create sheet with a fake repository and asserts validation messaging and a single submit call
- Mobile discoverability / navigation integration: list-to-detail navigation asserted here; the Home entry point is P5's
- Minimum gates by risk surface: AC3 → unpaired state test; ARB parity → existing `test/l10n/arb_parity_test.dart`; design-system compliance → existing `test/design_system/` guards
- Required regression or contract coverage: P1 and P2 tests plus `test/l10n/arb_parity_test.dart` stay green
- Evidence format: concise rows in `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests: `flutter test test/features/dream_jar`
  - Static analysis: `flutter analyze`
  - Required assertion evidence: emitted cubit states, request counts on the fake repository, rendered widget finders

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
