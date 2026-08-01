# Phase P4 – Contribution History And Per-Partner Split

## 1. Objective

Satisfy AC2's "view the jar's contents" with a paginated contribution history
screen and the cosmetic per-partner contribution split card, both derived from
`GET /dream-jar/:id/contributions`.

## 1A. Ownership

- Phase ID: P4
- Canonical Phase File: `phase-P4-contribution-history.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1, P2
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/dream_jar/presentation/contribution_history_cubit.dart`
  - `mobile/lib/features/dream_jar/presentation/screens/contribution_history_screen.dart`
  - `mobile/lib/features/dream_jar/presentation/widgets/partner_split_card.dart`
  - `mobile/lib/features/dream_jar/presentation/screens/dream_jar_detail_screen.dart` (wire the split card and the "See all contributions" navigation only)
  - `mobile/lib/l10n/arb/app_en.arb`, `mobile/lib/l10n/arb/app_vi.arb` (append keys only)
  - `mobile/test/features/dream_jar/presentation/contribution_history_cubit_test.dart`
  - `mobile/test/features/dream_jar/presentation/partner_split_card_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: widget test pump of the history screen
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `ContributionHistoryCubit` with pagination state
  - `ContributionHistoryScreen(jarId)`
  - `PartnerSplitCard`
- Shared Interfaces Consumed:
  - P1 `DreamJarRepository`, `Contribution`, `DreamJarAmountFormat`, `DreamJarUnpairedFailure`
  - P2 `DreamJarDetailScreen`, `DreamJarUnpairedNotice`
  - `mobile/lib/core/realtime/backend_user_id_store.dart` (current backend user id, read-only)
- Risk Surfaces:
  - Unpaired access (AC3)
  - ARB key parity
  - Design-system compliance
- Source Of Truth:
  - authoritative artifact: `../ux/uiux-spec.md` §1.6 (history list rows and pagination), §1.1 partner-comparison paragraph
  - consumer contract: the split card is cosmetic only and must not feed any gameplay, pet XP, or notification behavior
- Primary Inputs Summary:
  - architecture: `../architecture/solution.md` §2, §6 ADR-014d (client-derived split), ADR-014e ("You"/"Partner" labels)
  - OQ constraints: ADR-014a (no encryption affordance); no server aggregate endpoint may be requested (A1 frozen)
  - upstream phase outputs: P1 repository and models, P2 detail screen and unpaired notice
  - UX constraints: §1.6 reverse-chronological rows with contributor initial, amount, optional note, relative timestamp, lazy-loaded via `limit`/`offset`; §1.1 two proportional bars plus a plain-language delta line
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: history listing plus the derived split card
  - Source/Test File Count: 3 new source + 1 small edit + 2 test (plus append-only ARB edits)
  - Split Required: NO

## 2. Required Reads

- `../architecture/solution.md` §2, §6 (ADR-014d, ADR-014e)
- `../ux/uiux-spec.md` §1.6, §1.1 partner-comparison paragraph, §2, §3
- P1 outputs in `mobile/lib/features/dream_jar/data/`
- P2 `screens/dream_jar_detail_screen.dart`

## 3. Tasks

- Add `ContributionHistoryCubit(DreamJarRepository, BackendUserIdStore)` with `load(jarId)` and `loadMore()` using `limit`/`offset`; track `hasMore` from a short page and guard against concurrent page loads.
- Expose per-`userId` totals from the loaded pages so `PartnerSplitCard` can render without a second data source.
- Build `ContributionHistoryScreen(jarId)`: reverse-chronological rows (contributor initial, VND amount, optional note, relative timestamp), lazy-load on scroll, empty state when the jar has no contributions, and `DreamJarUnpairedNotice` on `DreamJarUnpairedFailure`.
- Build `PartnerSplitCard`: two proportional bars labelled from the current backend user id ("You" vs "Partner"), a localized delta line, and a localized caption stating the split covers the loaded contributions. Do not display real partner names.
- Wire the P2 detail screen's "See all contributions" affordance to push `ContributionHistoryScreen`, and place `PartnerSplitCard` above it. Touch nothing else in that file.
- Append all new strings to both ARB files with matching keys; format every amount through `DreamJarAmountFormat.vnd`.

## 4. Acceptance Criteria

- The history screen lists contributions newest-first with amount, optional note, and relative time (AC2).
- Scrolling past the first page issues exactly one additional request per page and stops when a short page returns.
- `PartnerSplitCard` totals equal the sums of the loaded contributions per `userId`, and the current user's column is labelled "You".
- A jar with no contributions renders an empty state, not an error.
- A `DreamJarUnpairedFailure` renders `DreamJarUnpairedNotice` (AC3).
- The split card triggers no notification, XP, or write of any kind.
- `app_en.arb` and `app_vi.arb` contain the same new keys.

## 5. Planned Outputs

- Code files: the paths listed in `Write Scope`
- Contracts: `ContributionHistoryCubit`, `ContributionHistoryScreen`, `PartnerSplitCard`
- Requirement configuration guide updates: none

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, contribution history
- Required levels:
  - unit: cubit first-page load, `loadMore` offset arithmetic, `hasMore` on a short page, concurrent-load guard, per-user totals, unpaired failure
  - mobile build/type-check/static-analysis: `flutter analyze` clean for touched files
- Required checks: widget test asserts the split card labels the current user's column "You" and renders proportional bars for a two-contributor fixture
- Mobile discoverability / navigation integration: detail → history navigation asserted here
- Minimum gates by risk surface: AC3 → unpaired state test; ARB parity → existing `test/l10n/arb_parity_test.dart`; design-system compliance → existing `test/design_system/` guards
- Required regression or contract coverage: P1-P3 tests stay green; the P2 detail screen test must still pass after the two-line wiring edit
- Evidence format: concise rows in `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests: `flutter test test/features/dream_jar`
  - Static analysis: `flutter analyze`
  - Required assertion evidence: emitted cubit states, requested `limit`/`offset` values, computed per-user totals

## 7. Status

- Status: DONE
- Last updated: 2026-07-30
- Scope note: implemented per `master-plan.md` §5's authoritative P4 row and
  the Scrum Master handoff, which is narrower than this file's original §1B
  Write Scope / §3 Tasks in three respects:
  - `mobile/lib/features/dream_jar/presentation/screens/dream_jar_detail_screen.dart`
    was **not** touched. The master-plan table's P4 Write Scope row does not
    include this file, and the handoff explicitly scoped P4 to the four
    presentation/ARB files below plus a test file, forbidding any P1/P2/P3
    file edit. Wiring `PartnerSplitCard` and a "See all contributions"
    affordance into the detail screen (and the entry-point route into
    `ContributionHistoryScreen` itself) is therefore still open and is the
    natural fit for P5 (entry-point phase), which already depends on P4.
  - `ContributionHistoryCubit` takes `DreamJarRepository` and a plain
    `String jarId` constructor arg, not a `BackendUserIdStore` collaborator.
    `ContributionHistoryScreen` instead takes `currentUserId` as a directly
    passed-in constructor parameter (nullable), consistent with P2/P3's
    precedent that the entry-point phase owns `getIt`/`BackendUserIdStore`
    wiring. `PartnerSplitTotals.of(contributions, currentUserId)` is a pure
    static computation on the widget side rather than cubit-exposed
    per-`userId` totals, satisfying the "no second data source" requirement
    the same way.
  - One combined test file,
    `mobile/test/features/dream_jar/presentation/contribution_history_cubit_test.dart`,
    covers both `ContributionHistoryCubit` (first-page load, `hasMore`,
    unpaired/generic failure, `loadMore` offset arithmetic, concurrent-load
    guard, `loadMoreFailed` recovery) and `PartnerSplitTotals.of` (self/
    partner sums, null-`currentUserId`, empty-list), per the handoff's literal
    instruction to "add a widget/cubit test file" (singular) rather than the
    two separate files this phase file originally named. There is currently
    no widget test pumping `PartnerSplitCard`/`ContributionHistoryScreen`
    directly; the logic they render (`PartnerSplitTotals.of`, cubit states)
    is unit-tested instead.
- Implementation notes:
  - Pagination page size is a private `_pageSize = 20` constant;
    `hasMore` is derived as `page.length == _pageSize` (a full page implies
    there may be more, a short page means the list has ended), matching the
    backend's plain `limit`/`offset` contract — no cursor or total-count
    field exists to key off instead.
  - `ContributionHistoryCubit.loadMore()` is guarded by
    `state is ContributionHistoryLoaded && state.hasMore && !state.isLoadingMore`
    so a second scroll-triggered call while a page fetch is already in
    flight is a no-op, mirroring P2's `DreamJarDetailCubit.addContribution`
    double-submission guard pattern.
  - `PartnerSplitCard` is a purely read-only, cosmetic aggregate (UX §1.1):
    it renders two `ExcludeSemantics`-wrapped proportional fill bars plus a
    mandatory plain-language delta line (UX §3) and a `Semantics(container:
    true)` grouped label per column combining the "You"/"Partner" name and
    amount — it triggers no request, notification, or state write of any
    kind.
  - No partner display-name lookup exists anywhere in this codebase yet, so
    columns are labelled generically via new ARB keys
    (`dream_jar_partner_split_you_label` / `..._partner_label`) rather than
    a real name, matching architecture ADR-014e.
  - Both ARB files were edited additively only (16 new keys); no existing
    key changed. `flutter pub get` was run to regenerate `AppL10n` before
    tests ran; its output (`lib/l10n/generated/`, `l10n-untranslated.json`)
    is gitignored, not committed.
- Evidence:
  - `flutter test test/features/dream_jar/presentation/contribution_history_cubit_test.dart`
    — 11 tests passed (4 `loadFirstPage`, 4 `loadMore`, 3 `PartnerSplitTotals.of`).
  - `flutter analyze` — reports 2 pre-existing-pattern `info`-level
    `prefer_initializing_formals` lints on
    `contribution_history_cubit.dart:70-71` (same unaddressed lint already
    present elsewhere in this codebase, e.g. `auth_repository.dart`,
    `fcm_transport.dart`, `realtime_coordinator.dart`,
    `socket_transport.dart`, `splash_screen.dart`); no error or warning on
    any file touched by this phase. The remaining ~10,990 issues in the full
    `flutter analyze` run are pre-existing noise unrelated to this phase:
    third-party Firebase-plugin build artifacts under
    `build/ios/SourcePackages/checkouts/flutterfire/tests/**` and
    `unused_import` warnings in the generated OpenAPI client
    (`openapi/cupid_api/lib/src/api/*.dart`), neither touched by or in scope
    for this phase.
  - `git status --porcelain` in the story worktree shows only the four
    write-scope files (3 new P4 presentation source files, 1 new P4 test
    file) plus additive edits to the two ARB files; no P1/P2/P3 file
    changed.
