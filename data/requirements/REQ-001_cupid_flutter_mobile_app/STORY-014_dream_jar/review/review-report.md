# STORY-014 Dream Jar — Final Review Report

Diff baseline: `0a467d03babf1ed4102c3fab09c61b2dec941a0b..HEAD` (`mobile/`),
synthesized from slice reports A (P1+P2), B (P3), and C (P4+P5+P6). No source
was re-read outside the slices; this report consumes slice findings only.

## Acceptance Criteria

1. A paired user can add a dream/wish entry to the shared jar — MET. Create
   flow (slice B) has validated double-submit guards at cubit and widget
   level, local validation before the repository call, and decimal-amount
   formatting matching the P1 repository contract.
2. Both partners can view the jar's contents — PARTIALLY MET. Jar list and
   jar detail (hero card, progress, quick-add) are reachable and tested
   (slices A, B). The contribution-history / per-partner-split view that
   `master-plan.md` §2 maps as part of this AC is implemented (slice C) but
   is **unreachable from any UI path** — see High finding below.
3. Unpaired users cannot access this feature — MET. Repository 404-message
   split, cubit `DreamJarDetailUnpaired` state, and list-screen unpaired case
   are all test-covered (slice A, slice B row 11).

## Findings

### [High] `ContributionHistoryScreen` is orphaned — no navigation edge anywhere in `mobile/lib`
Slice C's full-tree grep for `ContributionHistoryScreen` found only its own
definition file; no `Navigator.push`/route constructs it anywhere. This is
corroborated by slice A, which independently found the detail screen's "See
all contributions" affordance is inert (P2's own phase doc self-documents
this as deferred), and by slice B, whose reviewed list-screen/create-flow
files contain no reference to contribution history either. `master-plan.md`
§3A names this exact failure mode ("orphaned, unreachable feature") as a
blocking risk for the sibling entry-point row, and P5 — the phase meant to
close entry-point gaps — never touched `dream_jar_detail_screen.dart` or
`dream_jar_list_screen.dart` per its own write scope, so the gap was
structurally unclosable within the phases as scoped.

Impact: `test-results.md` §5 marks AC2 fully verified, but the
partner-split/history portion of AC2 that `master-plan.md` §2 relies on is
not actually deliverable to a user in this diff.

Required patch: wire one navigation entry point to `ContributionHistoryScreen`
(e.g. activate the existing "See all contributions" affordance on the jar
detail screen) and add a widget test asserting the navigation.

### [Low/Informational] No widget test pumps `PartnerSplitCard` or `ContributionHistoryScreen` directly
Slice C: only `contribution_history_cubit_test.dart` exists; the P4 phase
doc's own required check ("widget test asserts the split card labels the
current user's column 'You'...") has no corresponding widget test. Not
independently pre-cleared as a deviation by the Scrum Master handoff. Should
be closed alongside the High finding's navigation-wiring patch, since the new
navigation test will need to pump the destination screen anyway.

### [Low] `DreamJarDetailLoaded.copyWith` does not preserve `contributionFailure` by default
Slice A: `copyWith` passes `contributionFailure` straight through instead of
`?? this.contributionFailure`, breaking the usual idiom. No live bug — every
call site in this diff passes the field explicitly. Non-blocking; note for
future maintenance if another phase's cubit ever reuses this state class.

### [Low] Repository failure-mapping tests only exercise `fetchJars`/`fetchJar`
Slice A: `createJar`, `addContribution`, `fetchContributions` share the same
`_mapFailure` path as the tested methods but aren't individually
test-evidenced against phase-P1 AC4. Functional risk is low given the shared
code path. Non-blocking.

### [Info] List-screen → create-sheet tap wiring has no direct navigation-assertion test
Slice B row 6: `dream_jar_list_screen_test.dart` checks the CTA is present
but doesn't tap it and assert the sheet opens; wiring is a one-line
`onPressed` call. Low regression risk, non-blocking.

## Risk Surface Gate Summary (master-plan.md §3A)

| Risk Surface | Result |
|---|---|
| Decimal-as-string JSON decoding | PASS (slice A) |
| Unpaired access (AC3) | PASS (slice A, slice B row 11) |
| Progress / liquid-fill bounds | PASS (slice A, slice C — `partner_split_card.dart`) |
| Double contribution/creation submission | PASS (slice A, slice B rows 1-2) |
| ARB key parity | PASS (slice A, B, C) |
| Design-system compliance | PASS (slice A, B) |
| ADR-014a compliance (no encryption/FFI/new deps) | PASS (slice B row 9) |
| Deferred-scope guardrails (no edit/archive/delete/multi-currency) | PASS (slice B row 10) |
| DI registration correctness | PASS (slice C) |
| Entry-point discoverability | **BLOCKED** — `UNREACHABLE_SCREEN` (slice C) |

## Residual Risks (non-blocking)
- `copyWith` idiom footgun in `DreamJarDetailLoaded` (Low).
- Repository failure-mapping test coverage gap for 3 of 5 methods (Low).
- Missing direct navigation-assertion tests for two low-risk one-line wiring
  points (Info).

## Outcome

The AC2 delivery gap is concrete, narrowly scoped (one missing navigation
edge plus its test), and does not require architectural rework — it is a
straightforward patch to close before this story can be marked DONE.

Outcome: PATCH_REQUIRED

REVIEW_COMPLETE: YES
