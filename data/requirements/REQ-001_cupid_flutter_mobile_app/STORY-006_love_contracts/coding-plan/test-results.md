# STORY-006 Test Results

## P5 verification (2026-07-31)

Scope: consolidated AC1-AC4 verification per `phase-P5-verification.md`. Full
`mobile` package test suite + `flutter analyze` + the P0-P4 regression checks
named in each phase's `## 6. Test Scope`. Ran at story branch HEAD
`ac04e71bc876b9b97988719d870ed6a431e3a1af` (commit "correct master-plan P4
status + result log", one commit after the P5 fork-guard-fix patch).

| Command | Result |
| --- | --- |
| `flutter test` (whole `mobile` package) | PASS — 170/170 |
| `flutter test test/l10n/arb_parity_test.dart` | PASS — 3/3 (ARB parity — see "ARB parity" row below) |
| `flutter test test/widget_test.dart` | PASS — 1/1 (`home_screen_ready_signal` regression — see "Runtime readiness" row below) |
| `flutter test test/features/love_contracts/` | PASS — 47/47 (P0 data + gate repos, P1 bloc, P2 screen, P3 hold-to-sign, P4 entry tile) |
| `flutter analyze lib/features/love_contracts lib/features/home/presentation/home_screen.dart test/features/love_contracts` | No issues found |
| `flutter analyze lib test` (whole package, excluding the untracked build artifact below) | 17 pre-existing `info`-level `prefer_initializing_formals` lints, all in `lib/core/realtime/**` and `lib/features/auth/**` — none in `love_contracts` or `home_screen.dart`, none touched by this story |

Note on whole-package `flutter analyze` (no path args): it also walks
`mobile/build/ios/SourcePackages/checkouts/flutterfire/...`, a local,
gitignored (`mobile/.gitignore:33` `/build/`) iOS SourcePackages/CocoaPods
vendoring artifact containing FlutterFire's own integration-test fixtures
(`task_e2e.dart`, `test_utils.dart`, etc.), unrelated to this repository's
source and not resolvable as a Dart target from this workspace. This is a
pre-existing local build-cache artifact, not something introduced by
STORY-006; P0-P4 avoided it by scoping `flutter analyze` to touched files.
This phase scoped analyze the same way (rows above) and additionally ran
`flutter analyze lib test` to cover all first-party source without the stray
`build/` tree; both are clean of errors/warnings.

### AC1-AC4 verification at the ADR-006c capability

- **AC1** (paired user can propose/save clauses via `POST /love-contracts`):
  verified by `love_contract_repository_test.dart` (`saveClauses` posts
  `{'clauses': [...]}` to `/love-contracts` and returns the parsed contract)
  and `love_contract_screen_test.dart` (clause toggle, add-clause sheet save,
  20-clause cap). PASS.
- **AC2** at the ADR-006c capability (creator can sign; app renders
  awaiting-partner, never a partner-facing sign affordance; sign-404 shows
  localized sign-unavailable copy): `love_contract_repository_test.dart`
  confirms a 404 on `sign()` maps to `CupidApiFailure.isSignUnavailable ==
  true` (a plain network failure does not). `love_contract_event.dart` and
  `love_contract_state.dart` confirm no partner-sign event/state exists in the
  `Bloc` contract at all (`LoveContractReady` doc comment: "Never exposes a
  partner-side signing affordance (ADR-006c) — there is intentionally no such
  field here"). `hold_to_sign_button_test.dart` (P3, 7/7) covers the mapped
  sign-unavailable banner never leaking a raw failure type/server string, and
  retry recovering to signed. PASS at the stated capability limit (OQ-006A).
- **AC3** at the ADR-006c capability (current contract viewable via the
  revisit entry point, rendered as one current contract, not an array):
  `LoveContractRepository.fetchCurrent()` returns `LoveContract?` (single,
  nullable) from `GET /love-contracts/my-pending`, confirmed by
  `love_contract_repository_test.dart` ("returns null for the empty (null
  body) state", "returns a parsed contract on success") and rendered by
  `LoveContractScreen`'s single ready state. PASS at the stated capability
  limit (OQ-006A).
- **AC4** (entry tile hidden for unpaired users and on gate failure):
  `love_contract_entry_tile_test.dart` — paired user sees the tile; unpaired
  user sees no tile ("hide, not disable"); a failed gate fetch hides the tile
  (fail closed); an unregistered gate repository hides the tile; tapping opens
  `LoveContractScreen`; re-navigating after the user is no longer paired pops
  back and re-hides. PASS (5 widget tests, all green).

### Risk-surface gates (`../architecture/solution.md` §4 / `master-plan.md` §3A)

| Risk Surface | Gate | Status |
| --- | --- | --- |
| Untyped response bodies (`Response<void>`) | unit tests: full payload, empty map, unknown status, missing/non-string clauses | PASS |
| Creator-only backend capability (ADR-006c) | sign-404 → `isSignUnavailable`; no partner-sign event/state in the `Bloc` | PASS |
| Ceremony state machine (ADR-006a) | hold order (early release cancels, one completed event), `inFlight` re-entrancy guard (`canSign`) | PASS |
| Clause constraints 1..20 | 20-clause cap disables add-clause action; 0-clause guard (`canSign` requires `selectedCount > 0`) | PASS |
| AC4 pairing gate | entry tile absent when `partnerId` null, on gate failure, and when unregistered | PASS |
| Custom-gesture accessibility | `HoldToSignButton` semantic activation alternative to raw hold (P3); clause toggle rows use `hasToggledState`/icon-shape change, not colour alone (P2) | PASS |
| l10n parity | `mobile/test/l10n/arb_parity_test.dart` | PASS (3/3) |
| Runtime readiness regression | `Key('home_screen_ready_signal')` via `mobile/test/widget_test.dart` | PASS (1/1) |

No blocked gates.

### Story-level constraints

- `backend/` untouched across the full story range (`git diff --stat
  7935870^..HEAD -- backend/` — empty). PASS.
- No new `mobile/pubspec.yaml` dependency or dev_dependency across the full
  story range (`git diff 7935870^..HEAD -- mobile/pubspec.yaml` — empty).
  PASS.
- No `package:cupid_api/...` import under
  `mobile/lib/features/love_contracts/` (`git grep` — no matches). PASS.

### OQ-006A (open, non-blocking)

The frozen backend cannot support the dual-signature ritual as literally
worded (`partnerId` is never assigned on create, `sign()` matches the
requester only, `SIGNED_PARTNER` is never produced). AC2/AC3 ship at
creator-only capability per ADR-006c. This is a Product Owner / user decision
point (confirm v1 wording, or authorise a narrow A1 backend exception for the
partner half), not a defect — implementation is complete and correct against
the frozen contract. Non-blocking for this story's completion.

### Next owner (Reviewer)

All P0-P5 phases are DONE. Full suite green, analyze clean on all first-party
source, all AC1-AC4 verified at the stated capability, all risk-surface gates
pass, `backend/`/pubspec/`cupid_api`-import constraints hold, OQ-006A is
recorded above (not a defect). Story-level runtime startup smoke is
`NOT_APPLICABLE` per the phase file (no runtime surface/port/env var change;
covered by the `home_screen_ready_signal` widget test above). No further
mobile-lane action is required before review.

## P5 fork-guard-fix (2026-07-31)

Scope: `mobile/lib/features/love_contracts/presentation/widgets/hold_to_sign_button.dart`
raw-color fix only (see `phase-P5-fork-guard-fix.md`).

| Command | Result |
| --- | --- |
| `flutter test test/design_system/no_fork_guard_test.dart` | PASS (1/1) — was failing before this fix |
| `flutter test test/features/love_contracts/presentation/hold_to_sign_button_test.dart` | PASS (7/7) — no regression |
| `flutter analyze lib/features/love_contracts/presentation/widgets/hold_to_sign_button.dart` | No issues found |
