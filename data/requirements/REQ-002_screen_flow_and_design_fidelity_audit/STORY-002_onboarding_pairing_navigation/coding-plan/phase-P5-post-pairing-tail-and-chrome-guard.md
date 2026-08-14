# Phase P5 — Post-Pairing Tail & Chrome Guard (AC3 tail, AC4)

Owner: mobile-dev | Lane: mobile | Depends On: P4 | Parallelizable: No
Status: PENDING

## Precondition (blocking)

Confirm the `vow` screen exists after rebase (STORY-016). If missing, stop and
report that dependency — do not build it here.

## Goal

Close the chain (`paired` → `loveContract` → `vow` → `home`), resolve the
dual-entry header problem on the contract screen, and lock AC4 with a
chain-wide guard test so a future story cannot regress chrome silently.

## Problem Being Fixed (D5)

`love_contract_screen.dart:67` has `appBar: CupidHeader(...)`. The screen is
**dual-entry**: in-chain (`paired` → contract, NO_CHROME per AC4) and
post-home via `love_contract_entry_tile.dart:198` (header appropriate).
Deleting the header outright would regress the standalone entry.

## Write Scope

- `mobile/lib/features/love_contracts/presentation/screens/love_contract_screen.dart` (edit)
- `mobile/lib/features/love_contracts/presentation/widgets/love_contract_entry_tile.dart` (edit)
- `mobile/lib/main_preview.dart` (registry only)
- `mobile/test/core/navigation/chain_chrome_guard_test.dart` (new)
- `mobile/test/features/love_contracts/**`

## Primary Inputs

- `../architecture/solution.md` D5, ADR-7
- `../ux/uiux-spec.md` graph rows `paired` → `love_contract` →
  `fingerprint_vow` → `home`, and § Chrome Rules
- `mobile/lib/core/navigation/app_shell.dart:194` (`CupidTabBar` mount)

## Work

### 1. Contract entry mode (ADR-7)

Add an explicit entry mode to `LoveContractScreen`, e.g.
`enum LoveContractEntry { onboardingStep, standalone }` defaulting to
`standalone`:

- `onboardingStep` — no header; advances to `vow` on contract accepted.
- `standalone` — keeps today's `CupidHeader` and today's behaviour.

`love_contract_entry_tile.dart` passes `standalone` explicitly so the
post-home entry is unchanged.

Keep the diff to the header/CTA seam. STORY-019 owns this screen's visual
fidelity; do not restyle anything else in it.

### 2. Close the tail

- `paired` → `loveContract`: `PairedScreen` currently has no forward CTA (its
  doc comment at line 12 says the "Sign the Love Contract →" CTA was left out
  because no Love Contract flow existed yet). It exists now — wire the
  advance through `OnboardingRouter`.
- `loveContract` (onboardingStep) → `vow` on accepted.
- `vow` completed → `home` via `resetTo`, so the completed chain cannot be
  swiped back into. This is the first point the 5-tab bar appears (AC4).

### 3. Chrome guard test (AC4)

`mobile/test/core/navigation/chain_chrome_guard_test.dart` — iterate every
node where `OnboardingChain.isChromeless(node)` is true, pump it, and assert:

- no `AppBar` and no `CupidHeader` in the tree;
- no `CupidTabBar` in the tree.

Then assert `home` **does** mount `CupidTabBar`, so the guard proves the
first-appearance rule rather than just an absence.

No `CupidTabBar` code change is needed: it is mounted only in `AppShell`
(`app_shell.dart:194`), reachable only through `PairGatePaired`, so NO_TABS
already holds structurally. The guard is what keeps it holding.

### 4. Preview registry

Update `main_preview.dart` only where a canvas id now resolves to a real
screen instead of `PreviewNotImplementedScreen`. Do not restructure the
preview harness.

## Tests

- Contract in `onboardingStep`: no header, advances to `vow`.
- Contract in `standalone`: header present, existing behaviour intact.
- `paired` → contract; `vow` completion → `home` with the stack cleared.
- The chrome guard above (blocker §6.1).
- A full forward traversal `register → … → home` touching every node in order,
  asserting no loop back to `welcome`/`login` (blocker §6.6).

## Completion

- The chain closes end to end; the 5-tab bar first appears on `home`.
- `flutter analyze` clean, `flutter test` green.
- All six `master-plan.md` §6 verification-contract blockers cleared, or the
  uncleared ones reported explicitly.

## Stop Rule

If the rebased `vow` screen exposes no completion callback to hang the
`vow → home` edge on, stop and report the exact missing seam. Do not modify
the vow screen's body to add one — STORY-016 owns that file.
