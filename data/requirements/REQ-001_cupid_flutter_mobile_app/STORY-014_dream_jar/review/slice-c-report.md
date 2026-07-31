# STORY-014 Dream Jar — Review Slice C (P4+P5+P6)

Scope: contribution history, home entry point, DI wiring, and the
splash_screen_test.dart write-scope-deviation fix. No `Outcome:` line — this
is a slice review; final synthesis owns the story-level outcome.

## Files Reviewed

- mobile/lib/core/di/service_locator.dart
- mobile/lib/design_system/icons/cupid_icons.dart
- mobile/lib/features/dream_jar/presentation/contribution_history_cubit.dart
- mobile/lib/features/dream_jar/presentation/screens/contribution_history_screen.dart
- mobile/lib/features/dream_jar/presentation/widgets/dream_jar_entry_card.dart
- mobile/lib/features/dream_jar/presentation/widgets/partner_split_card.dart
- mobile/lib/features/home/presentation/home_screen.dart
- mobile/lib/l10n/arb/app_en.arb
- mobile/lib/l10n/arb/app_vi.arb
- mobile/test/features/auth/presentation/splash_screen_test.dart
- mobile/test/features/dream_jar/presentation/contribution_history_cubit_test.dart
- mobile/test/features/dream_jar/presentation/dream_jar_entry_card_test.dart
- mobile/test/features/home/home_screen_test.dart

Cross-checked (read-only, not in write scope): `story_master.md`,
`coding-plan/master-plan.md`, `coding-plan/phase-P4-contribution-history.md`,
`coding-plan/phase-P5-entry-point.md`, `coding-plan/test-results.md`.

## Findings

### [High] `ContributionHistoryScreen` is unreachable from any UI path in this diff

`git grep -rn "ContributionHistoryScreen" -- mobile/lib` (full-tree search,
not slice-restricted) returns only the class's own definition file — no
`Navigator.push`/route anywhere in `mobile/lib` constructs it. Consequences:

- `master-plan.md` §2 AC mapping states AC2 ("both partners can view the
  jar's contents") is satisfied in part by "paginated contribution history +
  per-partner split (P4)". As shipped, that screen (and the `PartnerSplitCard`
  it hosts) cannot be reached by a user, so this half of AC2 is not actually
  deliverable despite `test-results.md` §5 marking AC2 verified.
- `master-plan.md` §3A Risk Surfaces table names this exact failure mode for
  the sibling "Entry-point discoverability" row: "Blocker If Gate Cannot Run:
  orphaned, unreachable feature."
- `phase-P4-contribution-history.md` §7 explicitly acknowledges the detail
  screen's "See all contributions" wiring was deferred: "Wiring
  `PartnerSplitCard` and a 'See all contributions' affordance into the detail
  screen (and the entry-point route into `ContributionHistoryScreen` itself)
  is therefore still open and is the natural fit for P5 (entry-point phase),
  which already depends on P4." But this slice's P5 diff (`home_screen.dart`)
  only wires `HomeScreen` → `DreamJarListScreen`; it does not add any route
  to `ContributionHistoryScreen`.
- `phase-P5-entry-point.md` §1B Write Scope also never lists
  `dream_jar_detail_screen.dart` or `dream_jar_list_screen.dart`, so P5 as
  scoped could not have closed this gap either.

Sibling slices A/B cover `dream_jar_detail_screen.dart` and
`dream_jar_list_screen.dart` — final synthesis should confirm with those
slice reports whether either file wires `ContributionHistoryScreen`
somewhere outside this slice's file list before treating this as a confirmed
blocker (my full-tree grep found none, but I did not open those two files
myself per the scoped-slice restriction).

### [Low/Informational] No widget test pumps `PartnerSplitCard` or `ContributionHistoryScreen` directly

`master-plan.md` §5 P4 Test Scope column requires "cubit unit tests, widget
test"; `phase-P4-contribution-history.md` §6 is more specific: "Required
checks: widget test asserts the split card labels the current user's column
'You' and renders proportional bars for a two-contributor fixture." Only
`contribution_history_cubit_test.dart` exists, covering the cubit and the
pure `PartnerSplitTotals.of` computation — no `WidgetTester.pumpWidget` of
either the screen or the card. `phase-P4-contribution-history.md` §7 self-
documents this gap ("There is currently no widget test pumping
`PartnerSplitCard`/`ContributionHistoryScreen` directly") and argues unit
coverage of the underlying logic is an equivalent substitute. Unlike the
`splash_screen_test.dart` deviation, this narrowing is not called out in the
Scrum Master handoff as a pre-approved deviation — flagging for
final-synthesis judgment rather than treating it as pre-cleared.

## Risk Surface Gate Rows Touched By This Slice

| Risk Surface | Result | Notes |
|---|---|---|
| Entry-point discoverability | **BLOCKED** (typed: `UNREACHABLE_SCREEN`) | `HomeScreen` → `DreamJarListScreen` edge is correctly wired and tested (`home_screen_test.dart`), but `ContributionHistoryScreen` has zero navigation edges anywhere in `mobile/lib`. See High finding above. |
| Progress / liquid-fill bounds (`partner_split_card.dart`) | PASS | `heightFactor` guards `maxAmount <= 0 → 0` and clamps `(amount / maxAmount).clamp(0, 1)`; no divide-by-zero, no crash for `current=0`/`target=0`-equivalent inputs. |
| DI registration correctness (`service_locator.dart`) | PASS | Single `registerLazySingleton<DreamJarRepository>` call; no duplicate registration found in the file. |
| New icon glyph correctness (`cupid_icons.dart`) | PASS (informational) | `savings` glyph follows the exact pattern of the three pre-existing entries (doc comment citing bundled-font cmap codepoint). Codepoint `0xe2eb` itself is not independently re-verified against the font binary in this review — same trust boundary as the pre-existing entries, not a new risk this phase introduced. |
| ARB key parity (`app_en.arb`/`app_vi.arb`) | PASS | Parsed both files as JSON; key-set diff (excluding `@`-metadata keys) is empty in both directions — all new P4/P5 keys present in both locales. |
| `splash_screen_test.dart` deviation fix | PASS | `git diff --stat` confirms a 3-line-only change (import + two `MaterialApp` params). Matches `test-results.md` §4's documented root cause (P5's `DreamJarEntryCard` calls `AppL10n.of(context)` in `build()`, which the pre-existing bare `_harness` `MaterialApp` didn't support) and mirrors the existing `home_screen_test.dart` localization-delegate pattern. No unrelated assertions changed. |

REVIEW_SLICE_COMPLETE: YES
