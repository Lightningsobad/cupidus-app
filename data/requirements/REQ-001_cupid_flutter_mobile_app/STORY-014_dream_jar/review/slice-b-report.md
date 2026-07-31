# STORY-014 Review — Slice B (P3: create-jar flow + jar list screen)

Scope: `git -C <Worktree> diff 9041ad8..6daafa1 -- mobile/` limited to the 10
files below. Not a final `Outcome:` verdict — see `final-synthesis` report.

## Files Reviewed

- mobile/lib/features/dream_jar/presentation/create_dream_jar_cubit.dart
- mobile/lib/features/dream_jar/presentation/dream_jar_list_cubit.dart
- mobile/lib/features/dream_jar/presentation/screens/dream_jar_list_screen.dart
- mobile/lib/features/dream_jar/presentation/widgets/create_dream_jar_sheet.dart
- mobile/lib/l10n/arb/app_en.arb
- mobile/lib/l10n/arb/app_vi.arb
- mobile/test/features/dream_jar/presentation/create_dream_jar_cubit_test.dart
- mobile/test/features/dream_jar/presentation/create_dream_jar_sheet_test.dart
- mobile/test/features/dream_jar/presentation/dream_jar_list_cubit_test.dart
- mobile/test/features/dream_jar/presentation/dream_jar_list_screen_test.dart

## Findings

### PASS / FAIL / UNVERIFIED Table

| # | Check | Result | Evidence |
|---|-------|--------|----------|
| 1 | Double-submit guard (cubit level) | PASS | `create_dream_jar_cubit.dart` `submit()` early-returns on `state is CreateDreamJarSubmitting` before the `await`; `create_dream_jar_cubit_test.dart:108` "ignores a second submit while the first is in flight" asserts `createJarCallCount == 1` |
| 2 | Double-submit guard (widget level) | PASS | `create_dream_jar_sheet.dart` disables `CupidPrimaryButton.onPressed` (`null`) while `isSubmitting`; `create_dream_jar_sheet_test.dart:75` double-taps and asserts `createJarCallCount == 1` |
| 3 | Local validation before repository call | PASS | blank name / `targetAmount == null \|\| < 1` short-circuits to `CreateDreamJarValidationFailed`; `create_dream_jar_cubit_test.dart:49,64` cover both fields; `create_dream_jar_sheet_test.dart:59` covers the widget-level error text |
| 4 | Decimal-as-string amount input formatting | PASS | `_ThousandsInputFormatter` strips non-digits then re-groups via `DreamJarAmountFormat.grouped` on every keystroke; `_targetAmount` getter strips grouping chars before `num.tryParse`, so the value handed to `submit()` is a plain `num`, matching the P1 `DreamJarRepository.createJar({required num targetAmount})` contract |
| 5 | Entry-point discoverability inside the list screen | PASS | Three affordances wired to `_openCreateSheet`: header `CupidAddAction` (empty/ready states only, with `Semantics(button: true, label: ...)`), empty-state `CupidPrimaryButton`, and a pinned bottom `CupidPrimaryButton` in `_JarListBody`'s `ListView` |
| 6 | Entry-point discoverability test coverage (list → sheet) | UNVERIFIED (non-blocking) | `dream_jar_list_screen_test.dart` asserts the "New Dream Jar" text/CTA is present in the empty state, but no test taps it (or the header action) and asserts `CreateDreamJarSheet`/`showModalBottomSheet` opens. Sheet-opening behavior is only exercised standalone via `create_dream_jar_sheet_test.dart`'s own harness. Wiring is a one-line `onPressed: () => _openCreateSheet(...)` call, low regression risk; not the P5 Home-entry-point gate (out of this slice) |
| 7 | ARB key parity (this slice's new keys) | PASS | All 15 new `dream_jar_create_*`/`dream_jar_list_*`/`dream_jar_new_jar_cta`/`dream_jar_card_status_*`/`dream_jar_empty_title` keys added to `app_en.arb` are present with matching `@`-metadata in `app_vi.arb`; corroborated by `test-results.md` §6 `arb_parity_test.dart` PASS |
| 8 | Design-system compliance | PASS | Uses `context.cupidColors`/`cupidType`/`cupidPlatform`, `CupidSpacing`, `CupidPrimaryButton`, `CupidHeader`, `CupidAddAction`; no design system has no `CupidTextField` wrapper so bare `TextField`/`InputDecoration` (styled by the ambient `buildCupidTheme`) is the existing repo pattern, not a fork; corroborated by `test-results.md` §6 `no_fork_guard_test.dart` etc. all PASS |
| 9 | ADR-014a compliance (no encryption/libsodium/FFI/new deps, no lock/shield affordance) | PASS | No `dart:ffi`, `libsodium`, encryption, or lock/shield copy in any of the 4 reviewed source files; no `pubspec.yaml` touched in this diff range; corroborated by `test-results.md` §7 |
| 10 | Deferred-scope guardrails (no edit/archive/delete, no 4th tile/`note`, no multi-currency, no "show archived" toggle) | PASS | `create_dream_jar_sheet.dart` exposes only name/target/optional-deadline fields; `dream_jar_list_screen.dart` exposes no archive/delete action and no archived-reveal toggle; `dream_jar_list_cubit.dart` unconditionally filters `DreamJarStatus.archived` |
| 11 | Single-jar bypass / archived-filter correctness | PASS | `DreamJarListCubit._fetch()` filters archived before emitting; `dream_jar_list_screen_test.dart` covers empty, all-archived, single-jar bypass, 2+ jar list+navigate, and unpaired cases |

## Risk Surface Gate Rows Touched By This Slice

| Risk Surface (master-plan.md §3A) | Gate | Status |
|---|---|---|
| Double contribution submission (applies here as double jar-creation submission) | P2/P3 cubit+widget test ignoring a second tap during submission | PASS — table rows 1-2 |
| ARB key parity | existing `flutter test` parity gate | PASS — table row 7 |
| Design-system compliance | existing design-system guard tests in `flutter test` | PASS — table row 8 |

No blocking findings in this slice's file set.
