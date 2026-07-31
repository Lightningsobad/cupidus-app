# STORY-014 Review — Slice A (P1 + P2) Report

Scope: `mobile/lib/features/dream_jar/data/**`,
`mobile/lib/features/dream_jar/presentation/dream_jar_detail_cubit.dart`,
`.../screens/dream_jar_detail_screen.dart`,
`.../widgets/dream_jar_hero_card.dart`,
`.../widgets/dream_jar_unpaired_notice.dart`, ARB additions, and the P1/P2
test files. This is a slice-level report only; no `Outcome:` line is set
here — that is written by the final-synthesis reviewer after consuming
slices A, B, and C.

Diff baseline: `0a467d03babf1ed4102c3fab09c61b2dec941a0b..9041ad8`, scoped to
this slice's 14 files.

## Files Reviewed

- `mobile/lib/features/dream_jar/data/contribution.dart`
- `mobile/lib/features/dream_jar/data/dream_jar.dart`
- `mobile/lib/features/dream_jar/data/dream_jar_amount_format.dart`
- `mobile/lib/features/dream_jar/data/dream_jar_repository.dart`
- `mobile/lib/features/dream_jar/presentation/dream_jar_detail_cubit.dart`
- `mobile/lib/features/dream_jar/presentation/screens/dream_jar_detail_screen.dart`
- `mobile/lib/features/dream_jar/presentation/widgets/dream_jar_hero_card.dart`
- `mobile/lib/features/dream_jar/presentation/widgets/dream_jar_unpaired_notice.dart`
- `mobile/lib/l10n/arb/app_en.arb`
- `mobile/lib/l10n/arb/app_vi.arb`
- `mobile/test/features/dream_jar/data/dream_jar_model_test.dart`
- `mobile/test/features/dream_jar/data/dream_jar_repository_test.dart`
- `mobile/test/features/dream_jar/presentation/dream_jar_detail_cubit_test.dart`
- `mobile/test/features/dream_jar/presentation/dream_jar_detail_screen_test.dart`

Note: `flutter` is not available in this review environment, so `flutter
test` / `flutter analyze` were not independently re-run for this slice.
Findings below rely on static reading of the diff plus the evidence already
recorded in `coding-plan/phase-P1-data-contract.md` §7 and
`coding-plan/phase-P2-jar-detail.md` §7 (27 + 10 tests passed, `flutter
analyze` clean, regression suites green).

## Findings

### [Low] `DreamJarDetailLoaded.copyWith` does not preserve `contributionFailure` by default
`dream_jar_detail_cubit.dart` — the `copyWith` signature is:
```dart
DreamJarDetailLoaded copyWith({
    DreamJar? jar,
    bool? isAddingContribution,
    Object? contributionFailure,
  }) => DreamJarDetailLoaded(
    jar: jar ?? this.jar,
    isAddingContribution: isAddingContribution ?? this.isAddingContribution,
    contributionFailure: contributionFailure,
  );
```
`contributionFailure` is passed straight through instead of `contributionFailure ?? this.contributionFailure`, so any future caller that invokes `copyWith(...)` without explicitly naming `contributionFailure` will silently clear it. Every call site in this slice (`emit(currentState.copyWith(isAddingContribution: true, contributionFailure: null))`) passes the field explicitly, so there is no live bug today. Flagging because it breaks the usual `copyWith` idiom and is a footgun for P3/P4/P5 or later maintenance if any of them ever call this specific `copyWith` (they own separate cubits, so this is unlikely to be touched by other phases, but worth a note for the synthesis pass).

### [Low] Repository failure-mapping tests only exercise `fetchJars`/`fetchJar`
`dream_jar_repository_test.dart`'s "never rethrows a raw DioException" and both "not paired" 404-split tests call only `fetchJars`/`fetchJar`. `createJar`, `addContribution`, and `fetchContributions` all route through the same shared `_mapFailure`, so functional risk is low, but phase-P1's own AC4 ("Every repository method throws a `CupidApiFailure` subtype and never a raw `DioException`") isn't test-evidenced per-method. Not blocking given the shared code path, but noting the gap.

### [Info] P2's own task list describes pull-to-refresh / refresh-on-focus / inert "See all contributions" wiring that is not implemented
`phase-P2-jar-detail.md` §7 already self-documents this as an intentional scope deviation from the handoff ("exactly as scoped in the master-plan.md P2 row"), and none of those three behaviors appear in P2's own §4 Acceptance Criteria, so this is not a slice-A finding against this phase's AC. Flagging only so the final-synthesis reviewer can confirm P3/P4 (jar list, contribution history — out of this slice's scope) don't assume the "See all contributions" navigation hook already exists.

No other correctness, security, or design-system issues found in this slice's files.

## Risk Surface Gate Rows (master-plan.md §3A, this slice's rows only)

| Risk Surface | Gate | Result |
|---|---|---|
| Decimal-as-string JSON decoding | P1 unit tests over both fixture shapes | pass — `dream_jar_model_test.dart` covers string vs numeric `targetAmount`/`currentAmount`/`amount` for both `DreamJar` and `Contribution`, plus null-default-to-0 |
| Unpaired access (AC3) | P1 repository test on the 404 message split + P2 cubit/widget test | pass — repository test splits `"not paired"` (and case-insensitive variant) from `"Dream Jar not found"`; cubit test asserts `DreamJarDetailUnpaired`; widget test asserts `DreamJarUnpairedNotice` renders with the correct copy |
| Progress / liquid-fill bounds | P1/P2 unit tests for `target=0`, `current>target`, `current=0` | pass — `DreamJar.progressPercent` unit tests cover all three edge cases plus a server-`progress`-above-100 clamp; hero card fill fraction is a direct `(progressPercent / 100).clamp(0, 1)` derivation, so no separate widget-level fill test is needed |
| Double contribution submission | P2 cubit test ignoring a second tap during submission | pass — both cubit-level (`ignores a second tap while the first contribution is in flight`) and widget-level (`quick-add tiles ignore a second tap...`) tests assert `addContributionCallCount` stays 1 |
| ARB key parity | every new key in both `app_en.arb` and `app_vi.arb` | pass (manual check) — `template-arb-file: app_vi.arb` per `mobile/l10n.yaml`, so `app_en.arb` correctly holds flat key/value pairs only and `app_vi.arb` correctly holds the `@key` metadata blocks (matching the pre-existing `common_actions_continue` pattern); all 9 new slice-A keys (`common_actions_retry`, `dream_jar_of`, `dream_jar_remaining`, `dream_jar_completed`, `dream_jar_quick_add_semantic_label`, `dream_jar_unpaired_title`, `dream_jar_unpaired_body`, `dream_jar_load_error`, `dream_jar_contribution_error`) are present in both files with matching keys; not independently re-run through `test/l10n/arb_parity_test.dart` (flutter unavailable here) |
| Design-system compliance | existing design-system guard tests | pass (manual) — `dream_jar_hero_card.dart` and `dream_jar_unpaired_notice.dart` use only `context.cupidColors` / `context.cupidType` / `context.cupidPlatform` / `CupidSpacing` tokens and adaptive design-system widgets (`CupidPrimaryButton`); no raw `Colors.*`, hardcoded hex, or forked styling found; not independently re-run through the `no_fork_guard_test.dart` family (flutter unavailable here) |

REVIEW_SLICE_COMPLETE: YES
