# Phase P2 – `CupidHeader` trailing slot + presence chip

## 1. Objective

`CupidHeader` gains one optional `trailing` slot that renders nothing when
unset, and the chat header uses it to render the `<self> ↔ <partner>` pairing
title plus the static `đang online` presence chip, matching the locked design
source. The other 16 `CupidHeader` consumers are untouched and unchanged.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-header-slot-and-presence-chip.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/design_system/adaptive/cupid_header.dart`
  - `mobile/lib/design_system/tokens/partner_chip_palette.dart`
  - `mobile/lib/features/chat/presentation/widgets/partner_presence_chip.dart`
  - `mobile/lib/features/chat/presentation/screens/chat_screen.dart`
  - chat string/ARB source for the `đang online` / `online` label
  - `mobile/test/design_system/adaptive_widgets_test.dart`
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
  - `ChatPartnerStore.selfDisplayName` / `.partnerDisplayName` (P1)
- Risk Surfaces:
  - Shared-component backward compatibility (16 other consumers)
  - ADR-004 raw-color-literal guard
  - Design fidelity of the `chat` screen
- Source Of Truth:
  - authoritative artifact or convention: `../ux/uiux-spec.md` §1-§4 for every
    pixel value; `../architecture/solution.md` §4 for the slot contract
  - consumer contract: the 16 other `CupidHeader` call sites
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC2-AC6
  - architecture: `../architecture/solution.md` §4 Boundaries And Ownership,
    Mobile Lane
  - upstream phase outputs: P1's two store getters
  - UX constraints: `../ux/uiux-spec.md` §1 (chip geometry, colors, type), §2
    (unset state), §3 (overflow), §4 (semantics)
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one design-system slot plus the single chip that consumes it
  - Source/Test File Count: 6
  - Split Required: NO

## 2. Required Reads

- `../ux/uiux-spec.md` §1-§4
- `../architecture/solution.md` §4

## 3. Tasks

- Add `final Widget? trailing;` to `CupidHeader`, defaulting to `null`. Wire it
  in **both** `_IosHeader` (after the `Expanded` title, before `...actions`) and
  `_MaterialHeader` (prepended to `AppBar.actions`) — `build` branches on
  platform, so a single-branch wiring silently ships an iOS-only or
  Material-only feature. Build neither the widget nor the `10dp` gap when
  `trailing` is null, per `../ux/uiux-spec.md` §2.
- Leave `title`, `onBack`, `backLabel`, `actions`, and `preferredSize`
  untouched.
- Add `mobile/lib/design_system/tokens/partner_chip_palette.dart` carrying only
  the `#00C9A7 → #7B2FBE` 135deg avatar gradient, reusing the `Alignment(
  ∓0.7071067811865476, ∓0.7071067811865476)` derivation already established in
  `couple_presence_palette.dart:20-27`. Do not add it to `CupidColorTokens` and
  do not inline the literals in `lib/features` (ADR-004).
- Build the presence chip widget from `../ux/uiux-spec.md` §1.4: the
  `_PrivacyChip` pill recipe (`colorSurface`, `BorderRadius.circular(999)`),
  asymmetric `5/10/5/6` padding, 24dp gradient avatar with the uppercased first
  character of the partner name in `CouplePresencePalette.avatarInitial`, the
  8dp `colorGreen` dot at `Positioned(right: -1, bottom: -1)` ringed 2dp in
  `colorSurface`, and the 11pt `colorTextMuted` label. The dot rings in
  `colorSurface`, **not** `colorBackground` — do not copy
  `home_screen.dart:458`.
- Put the `đang online` / `online` label in the existing chat string/ARB source
  rather than a bare literal, so an `en` string exists for parity.
- Compose the header in `chat_screen.dart`: title becomes
  `<selfDisplayName> ↔ <partnerDisplayName>`, and `trailing` gets the chip.
  Replace the stale "reused as-is rather than reopening a frozen shared
  component" comment at `chat_screen.dart:163-165`.
- Apply `../ux/uiux-spec.md` §4 semantics: a `Semantics` label on the title that
  drops the `↔` glyph in favor of a natural phrase, and one `Semantics` node
  wrapping the whole chip with the decorative avatar and dot excluded. Do not
  give the chip a `button` role.
- Degrade gracefully when either name is null: render what is available rather
  than a bare `↔` or the string "null".

## 4. Acceptance Criteria

- The chat header renders the pairing title in `<self> ↔ <partner>` format and
  the `đang online` chip at the top-right, matching `../ux/uiux-spec.md` §1.
- Rendering `CupidHeader` without `trailing` produces the same widget tree it
  produced before this story — no reserved space, no extra gap.
- `CupidHeader`'s `title`, `onBack`, `backLabel`, and `actions` parameters are
  unchanged, and `trailing` is optional.
- The new gradient lives in `design_system/tokens/`; no raw color literal is
  added under `lib/features`.
- The chip exposes one coherent semantics label and no button role.

## 5. Planned Outputs

- Code directories or files: `mobile/lib/design_system/adaptive/`,
  `mobile/lib/design_system/tokens/`,
  `mobile/lib/features/chat/presentation/`
- Notes or evidence: `visual-fidelity/` evidence pair plus test run recorded in
  `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter, `mobile-app`, `chat` screen and
  `design_system/adaptive`
- Required levels:
  - unit: presence chip renders the uppercased partner initial; null-name
    degradation renders no `↔`-only or `"null"` string
  - integration: `adaptive_widgets_test.dart` — a `CupidHeader` built without
    `trailing` produces a widget tree identical to the pre-change baseline, on
    both the iOS and Material platform branches
  - mobile build/type-check/static-analysis: `flutter analyze`
  - visual inspection: rendered `chat` header against the locked design source
- Required checks:
  - `test/design_system/no_fork_guard_test.dart` passes (ADR-004)
  - both platform branches of `CupidHeader` are covered; a Material-only test
    does not satisfy the backward-compatibility gate
- Mobile discoverability / navigation integration: N/A — no new surface;
  `chat` keeps its existing navigation path (`../story_master.md` AC7).
- Minimum gates by risk surface:
  - Shared-component backward compatibility: the unset-`trailing` tree-identity
    test passes on both branches
  - ADR-004 raw-color-literal guard: `no_fork_guard_test.dart` passes
  - Design fidelity of the `chat` screen: the `visual-fidelity/` pair below
- Required regression or contract coverage: the existing
  `adaptive_widgets_test.dart` cases pass unmodified.
- Evidence format: test commands with pass/fail summary in
  `coding-plan/test-results.md`, plus the rendered PNG pair under
  `visual-fidelity/`
- Requirement mobile visual audit: REQUIRED — this story touches the `chat`
  screen, a locked `design_source`, and `ui_surface` is not false, so it owes
  its own rendered design-reference/implemented-capture pair under
  `visual-fidelity/` with a `VISUAL_FIDELITY` verdict. Capture through
  `mobile/lib/main_preview.dart` using P1's updated preview fixture so both
  names are populated. Do not reuse STORY-040's pair.
- Verification strategy:
  - Targeted tests/regression/contract checks:
    `flutter test test/design_system test/features/chat`
  - Build/type-check/lint command when required: `flutter analyze`
  - Required assertion evidence: the unset-`trailing` tree-identity assertion
    and the `VISUAL_FIDELITY` verdict quoted in `test-results.md`

## 7. Status

- Status: DONE
- Last updated: 2026-08-18
- Evidence: `coding-plan/test-results.md` (Phase P2 section),
  `visual-fidelity/visual-fidelity-report.md` (`VISUAL_FIDELITY: PASS`)
- Deviations for review: D-1 `↔` emoji-presentation rendering (open, routed to
  UI/UX Designer and Tech Lead — `ux/uiux-spec.md` §1.2 puts the header title
  style out of this story's scope); D-3 new optional
  `CupidHeader.titleSemanticLabel` parameter, required to satisfy §4/AC4
  because `title` is a `String`; D-4 `partner_chip_palette.dart` placed at
  `design_system/tokens/` per this phase file's Write Scope rather than the
  handoff message's non-existent `design_system/adaptive/tokens/`; D-5 one
  barrel export line in `design_system/design_system.dart`. All four are
  detailed in `visual-fidelity/visual-fidelity-report.md` §4.
