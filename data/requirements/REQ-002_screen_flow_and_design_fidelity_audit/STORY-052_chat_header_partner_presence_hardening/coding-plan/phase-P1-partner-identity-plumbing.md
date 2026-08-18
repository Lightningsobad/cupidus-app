# Phase P1 – Partner identity plumbing (`ChatPartnerStore` split)

## 1. Objective

`ChatPartnerStore` stops exposing one mislabelled `displayName` getter and
exposes two correctly named getters — `selfDisplayName` and
`partnerDisplayName` — mapped to the two distinct `GET /users/me` keys. Every
call site is repointed at the one it actually means, which removes the latent
self-for-partner defect in `GhostBubble` and `ChatComposer`.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-partner-identity-plumbing.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P0
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/chat/data/chat_partner_store.dart`
  - `mobile/lib/features/chat/presentation/screens/chat_screen.dart`
  - `mobile/lib/main_preview.dart`
  - `mobile/lib/core/di/service_locator.dart`
  - `mobile/test/features/chat/` (store coverage)
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Consumed:
  - `GET /users/me` `partnerDisplayName` (`../architecture/contract-summary.md`)
- Risk Surfaces:
  - Self-vs-partner name plumbing (latent defect, Key Discovery item 3)
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/contract-summary.md`
    sections 2-3 and 6
  - consumer contract: P2 header composition
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC2-AC4 and the `## Out of Scope` note on
    repointing `chat_screen.dart:249,270`
  - architecture: `../architecture/solution.md` §4 Mobile Lane
  - upstream phase outputs: P0's expanded `/users/me` response
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: identity plumbing only — no widget or token work
  - Source/Test File Count: 5
  - Split Required: NO

## 2. Required Reads

- `../architecture/contract-summary.md`
- `../architecture/solution.md` §1 Key Discovery, §4 Mobile Lane

## 3. Tasks

- In `chat_partner_store.dart`, rename `displayName` to `selfDisplayName`
  (still fed by the payload's `displayName` key) and add `partnerDisplayName`
  fed by the new key. Correct the class dartdoc, which currently calls the self
  value "the paired partner's display name". Extend `clearOnSignOut` to clear
  both fields.
- Do **not** keep a compatibility `displayName` getter. Its absence is what
  forces every call site through the compiler
  (`../architecture/contract-summary.md` section 6).
- Repoint `chat_screen.dart`'s existing `partnerDisplayName:` arguments (the
  `GhostBubble` and `ChatComposer` call sites, around lines 249 and 270, and the
  `_ChatView` field they flow through) at `partnerStore.partnerDisplayName`.
  This is the PO-approved correctness byproduct — do not restyle, re-audit, or
  otherwise widen those two widgets.
- Leave the header `title:` argument alone in this phase; P2 owns the pairing
  title.
- Update `_PreviewChatPartnerStore` in `main_preview.dart` so the preview
  harness can supply both names independently. P2's visual-fidelity capture
  depends on this.
- Update `service_locator.dart` where the store's getters are referenced. Leave
  the `PartnerDisplayName` typedef and its `() => null` registration in place —
  it belongs to the love-contracts lane and is out of scope here.
- Add store unit coverage asserting the two getters map to the two distinct
  payload keys and that both clear on sign-out.

## 4. Acceptance Criteria

- `ChatPartnerStore` exposes `selfDisplayName` and `partnerDisplayName`; no
  `displayName` getter remains.
- A payload where the two keys hold different values produces two different
  getter results — a test that would still pass if both getters read the same
  key does not satisfy this.
- `GhostBubble` and `ChatComposer` receive the partner's name, not the caller's.
- Both fields are null after `clearOnSignOut`.
- `flutter analyze` reports no issues.

## 5. Planned Outputs

- Code directories or files: `mobile/lib/features/chat/data/`,
  `mobile/lib/features/chat/presentation/screens/`, `mobile/lib/core/di/`,
  `mobile/lib/main_preview.dart`
- Notes or evidence: test run recorded in `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter, `mobile-app`
- Required levels:
  - unit: `ChatPartnerStore` — two-key mapping with distinct values, sign-out
    teardown
  - mobile build/type-check/static-analysis: `flutter analyze`
- Required checks: no `displayName` getter survives on `ChatPartnerStore`; the
  distinct-values assertion is present.
- Mobile discoverability / navigation integration: N/A — this phase adds no
  surface; `chat` is reached through its existing path (`../story_master.md`
  AC7).
- Minimum gates by risk surface:
  - Self-vs-partner name plumbing: `flutter analyze` clean plus the
    distinct-values unit assertion
- Required regression or contract coverage: existing chat widget tests pass
  after the rename.
- Evidence format: test command plus pass/fail summary in
  `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests/regression/contract checks: `flutter test test/features/chat`
  - Build/type-check/lint command when required: `flutter analyze`
  - Required assertion evidence: the distinct-values assertion quoted in
    `test-results.md`

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-18
