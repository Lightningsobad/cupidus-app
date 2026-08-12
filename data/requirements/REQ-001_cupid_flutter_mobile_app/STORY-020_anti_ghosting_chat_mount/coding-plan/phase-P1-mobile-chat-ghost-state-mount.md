# Phase P1 – Mount GhostStateRow into ChatScreen

## 1. Objective

`GhostStateRow` renders inside the live `ChatScreen` widget tree at the seam
`../ux/uiux-spec.md` §1 pins, for a paired user, and costs nothing when there
is no signal. This closes STORY-008 AC2.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-mobile-chat-ghost-state-mount.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/chat/presentation/screens/chat_screen.dart`
  - `mobile/test/features/chat/presentation/chat_screen_ghost_state_row_mount_test.dart` (new)
  - `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-020_anti_ghosting_chat_mount/coding-plan/test-results.md`
  - `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-020_anti_ghosting_chat_mount/visual-fidelity/`
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
  - `GhostStateRow(partnerId:)` via the barrel
    `package:cupid_mobile/features/anti_ghosting/anti_ghosting.dart`
- Risk Surfaces:
  - Seam ordering
  - Idle zero-cost
  - Unpaired leak
  - Duplicate storm poll
  - AC1 running-app evidence
- Source Of Truth:
  - authoritative artifact: `../architecture/solution.md` section 4
  - placement: `../ux/uiux-spec.md` §1
- Primary Inputs Summary:
  - requirements: `../story_master.md` (this story has no `requirements/` dir)
  - architecture: `../architecture/solution.md` sections 1, 4
  - UX constraints: `../ux/uiux-spec.md` §1 (mount slot), §2 (seam behavior),
    §3 (traversal order)
- Requirement Configuration Guide:
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one widget mount plus its parameter plumbing
  - Source/Test File Count: 2
  - Split Required: NO

## 2. Required Reads

- `../story_master.md`
- `../architecture/solution.md`
- `../ux/uiux-spec.md`

## 3. Tasks

1. In `chat_screen.dart`, add
   `import 'package:cupid_mobile/features/anti_ghosting/anti_ghosting.dart';`
   with the other `package:cupid_mobile/...` imports. Do not import the widget
   file path directly.
2. Add `final String? partnerId;` to `_ChatView` with a matching
   `required this.partnerId` constructor parameter, and pass
   `partnerId: partnerStore.partnerId` from `ChatScreen.build`'s `_ChatView`
   construction. `ChatScreen` already holds `partnerStore`; no call site of
   `ChatScreen` changes.
3. In `_ChatViewState.build`'s `Column`, insert exactly one new child strictly
   between the `GhostBubble` `BlocBuilder` and the `ChatComposer`
   `BlocBuilder`:
   `if (widget.partnerId != null) GhostStateRow(partnerId: widget.partnerId!),`
   Add no `Padding`, `SizedBox`, divider, or spacing around it, and change no
   other child. The `partnerId != null` guard is the only permitted condition —
   do not also branch on storm state, the row self-collapses.
4. Add `chat_screen_ghost_state_row_mount_test.dart` under
   `mobile/test/features/chat/presentation/`. `ChatPartnerStore.partnerId` has
   no setter, so drive it the way the chat and anti-ghosting suites already do:
   stub `Dio.httpClientAdapter` to answer `GET /users/me` with a `partnerId`,
   then `await store.refreshFromServer()`. `_FakeChatRepository` and
   `_FakeRealtimeCoordinator` in
   `mobile/test/features/chat/presentation/chat_cubit_test.dart` are private —
   copy the same shape into the new file rather than exporting them.
5. Record results in `test-results.md` and capture the visual-audit evidence
   named in section 6.

## 4. Acceptance Criteria

1. `GhostStateRow` is present in `ChatScreen`'s built widget tree for a paired
   user, positioned below the Typing-Ghost bubble region and above
   `ChatComposer`.
2. When the storm status is not `eligible` (or `GhostConfigRepository` is not
   registered), the seen/no-reply copy is absent and the chat `Column`'s other
   children keep their existing positions and sizes.
3. When `partnerStore.partnerId` is null, `GhostStateRow` is absent from the
   tree entirely.
4. `ChatScreen`'s `MultiBlocProvider` gains no provider, and no file under
   `mobile/lib/features/anti_ghosting/` is modified.

## 5. Planned Outputs

- Code: `chat_screen.dart` (import, one field, one constructor arg, one
  `Column` child).
- Tests: `chat_screen_ghost_state_row_mount_test.dart`.
- Evidence: `coding-plan/test-results.md`, `../visual-fidelity/` captures.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, `ChatScreen`
- Required levels:
  - unit: none new
  - mobile build/type-check/static-analysis: `flutter analyze` and
    `flutter test` for the mobile package
  - visual inspection: emulator capture of the chat screen
- Required checks:
  - New mount test covers all four acceptance criteria above, including a
    `tester.getTopLeft` ordering assertion that places `GhostStateRow` below
    the `GhostBubble` slot and above `ChatComposer`.
  - `mobile/test/features/anti_ghosting/presentation/ghost_state_row_test.dart`
    and the existing chat suite stay green, proving the widget itself and the
    surrounding chat behavior are untouched.
- Mobile discoverability / navigation integration: the row is a passive status
  surface inside an already-reachable screen; no new route or nav entry.
- Minimum gates by risk surface: see `../architecture/solution.md` section 4.
- Evidence format: command output plus assertion summary in `test-results.md`.
- Requirement mobile visual audit: YES — two emulator captures of `ChatScreen`
  for a paired user: one with an eligible storm status showing the amber
  "Seen, no reply" line between the Typing-Ghost bubble area and the composer,
  and one with no eligible state showing a layout identical to the pre-mount
  screen (`../ux/uiux-spec.md` §4). Store under `../visual-fidelity/`.
- Verification strategy:
  - Targeted tests: new mount test, existing chat and anti-ghosting suites.
  - Build/type-check command: `flutter analyze` in `mobile/`.
  - Required assertion evidence: widget-order assertion output and the two
    visual-audit captures.

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-12
