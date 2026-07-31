# Phase P4 – Entry Point And Pairing Gate (AC5)

## 1. Objective

Make chat reachable through a discoverable shell surface and gate it to paired
users only. Covers AC5 and closes the orphaned-feature risk for both `chat` and
`ghostset`.

## 1A. Ownership

- Phase ID: P4
- Canonical Phase File: `phase-P4-entry-point-and-gate.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P2
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/core/navigation/app_shell.dart`
  - `mobile/lib/features/chat/presentation/chat_entry_gate.dart`
  - `mobile/test/core/navigation/app_shell_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: N/A (registry notes `flutter run` needs a connected device and is interactive)
  - Readiness Check: `Key('home_screen_ready_signal')` pumps on the home screen, per the runtime registry `readiness.sourceFile` — this phase edits the shell that mounts it and must preserve it
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `ChatEntryGate`
  - `AppShell` chat destination
- Shared Interfaces Consumed:
  - `ChatPartnerStore` (P1)
  - `ChatScreen` (P2), `GhostSettingsScreen` (P3, optional at build time — wire the header action to it if P3 has landed, otherwise land the action in the same phase run after P3)
  - `CupidTabBar` adaptive widget (STORY-001)
- Risk Surfaces:
  - Pairing gate (AC5)
  - Discoverability
- Source Of Truth:
  - authoritative artifact: `../architecture/solution.md` §4 Risk Surfaces rows "Pairing gate" and "Discoverability"
  - consumer contract: `ChatPartnerStore.partnerId`
- Primary Inputs Summary:
  - architecture: `../architecture/solution.md` §4 Risk Surfaces; §3 Out Of Scope (unpair edge case dropped)
  - OQ constraints: none specific to this phase
  - upstream phase outputs: P1 `ChatPartnerStore`; P2 `ChatScreen`; P3 `GhostSettingsScreen`
  - UX constraints: `../ux/uiux-spec.md` §2 (flow map and the `ghostset` entry-point rule), §7 (pairing gate, unpair edge case)
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: none
- Phase Sizing:
  - Behavior Slice: navigation and gating only
  - Source/Test File Count: 2 source + 1 test
  - Split Required: NO
  - Split Rationale: intentionally small; kept separate because it is the AC5 and discoverability gate and must not be buried inside the screen build

## 2. Required Reads

- `../architecture/solution.md` §4 Risk Surfaces; §3 Out Of Scope
- `../ux/uiux-spec.md` §2, §7
- `mobile/lib/core/navigation/app_shell.dart`
- `mobile/lib/design_system/adaptive/cupid_tab_bar.dart`
- P1 output `mobile/lib/features/chat/data/chat_partner_store.dart`

## 3. Tasks

- Create `chat_entry_gate.dart`: resolves `ChatPartnerStore.partnerId`; when it is null, the chat destination is not offered and the chat route is not reachable. AC5's gate is `partnerId != null` from `GET /users/me` — do **not** import or depend on any STORY-005 pairing source file, which may not be merged.
- Edit `app_shell.dart` to mount `CupidTabBar` with exactly two destinations that exist today: Home and Chat. Do not scaffold the pet/money/me tabs — those screens do not exist and empty tabs would be dead affordances. The 5-tab shell arrives with its own stories.
- Gate the Chat destination behind `ChatEntryGate`. When unpaired, render the existing Home screen alone, exactly as the shell does today.
- Preserve the runtime readiness signal: `Key('home_screen_ready_signal')` must still be present and pump after the shell change. The runtime registry names this as `mobile-app`'s readiness check, so breaking it breaks the project's dev-readiness gate.
- Add a trailing header action on `chat` that opens `ghostset`. This is an explicit, documented Tech Lead exception to `../ux/uiux-spec.md` §2, which reserves the decision for Tech Lead/PO: the design source's Home dashboard `goGhostSet` tile does not exist yet because Home is still a placeholder screen, so without this action `ghostset` would be an orphaned feature. Record a code comment saying to move this entry to the Home tile once the real Home dashboard lands.
- Do **not** implement partner-unpaired-while-chatting navigation. The frozen `CHAT_EVENTS` set contains no unpair event and `User` carries no unpair signal, so the event can never fire; `../ux/uiux-spec.md` §7 explicitly permits dropping it in that case.
- Write `app_shell_test.dart`.

## 4. Acceptance Criteria

- AC5: with `partnerId == null`, the Chat destination is absent from the tab bar and the chat route cannot be reached; with `partnerId` set, Chat is present and navigable.
- `ghostset` is reachable from the chat header action.
- `Key('home_screen_ready_signal')` is still found and pumped after the shell change.
- No pet/money/me tab destinations are added.
- No import of any STORY-005 pairing source file exists in this phase's output.
- `flutter analyze` reports no new issues.

## 5. Planned Outputs

- Code: `mobile/lib/features/chat/presentation/chat_entry_gate.dart`, edited `mobile/lib/core/navigation/app_shell.dart`
- Contracts: `ChatEntryGate`, `AppShell` chat destination
- Requirement configuration guide updates: none
- Notes: code comment recording the temporary `ghostset` header entry point

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, app shell and navigation
- Required levels:
  - integration: widget tests on `AppShell` — paired shows Chat, unpaired hides Chat, chat header action reaches `ghostset`, readiness key still pumps
  - mobile build/type-check/static-analysis: `flutter analyze`
- Required checks: no pet/money/me destinations present; no STORY-005 import present
- Mobile discoverability / navigation integration: this phase **is** the discoverability gate. Chat must be reachable from a discoverable shell surface, not by direct route construction only, and `ghostset` must be reachable from the chat header.
- Minimum gates by risk surface:
  - Pairing gate (AC5): unpaired-hides / paired-shows asserted
  - Discoverability: chat reachable from the shell, `ghostset` reachable from the chat header, readiness key preserved
- Required regression or contract coverage: the existing home-screen readiness widget test referenced by the runtime registry must still pass
- Required runtime signals: none — no runtime startup smoke in this phase; readiness is asserted as a widget test
- Evidence format: concise rows recorded by P5 in `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests: `flutter test test/core/navigation/ test/features/home/`
  - Build/type-check/lint command: `flutter analyze`
  - Required assertion evidence: finder presence/absence for the Chat destination under both partner states; finder for the readiness key

## 7. Status

- Status: DONE
- Last updated: 2026-07-31
- Evidence:
  - Created `mobile/lib/features/chat/presentation/chat_entry_gate.dart`
    (`ChatEntryGate`, a `StatefulWidget` gating on
    `ChatPartnerStore.partnerId != null`, triggering a best-effort
    `refreshFromServer()` when initially locked; imports only
    `chat_partner_store.dart`, no STORY-005/pairing source file).
  - Edited `mobile/lib/core/navigation/app_shell.dart`: `AppShell` now mounts
    `CupidTabBar` with exactly two destinations (Home always, Chat gated by
    `ChatEntryGate`); `Key('home_screen_ready_signal')` preserved on the Home
    screen; added the documented temporary `ghostset` header action
    (`Key('ghost_settings_entry_action')`) overlaid on `ChatScreen` via a
    `Stack`, opening `GhostSettingsScreen` (Tech Lead exception per §3, code
    comment records the removal condition).
  - Wrote `mobile/test/core/navigation/app_shell_test.dart`: 4 tests —
    paired (Chat reachable, ghostset action opens `GhostSettingsScreen`,
    readiness key absent once navigated away from Home), unpaired (Chat
    absent, only Home tab item, readiness key present, no pet/money/me tabs),
    and two static-source guard checks (`chat_entry_gate.dart` and
    `app_shell.dart` import no pairing/`features/pairing` source).
  - `flutter test test/core/navigation/`: **4/4 passed** (0 failures).
    `test/features/home/` named in this phase's §6 verification command does
    not exist in this worktree (`git ls-files mobile/test/features/`
    confirms no `home` test directory); ran the existing
    `test/core/navigation/` suite only, which is the readiness-key/shell
    coverage this phase owns.
  - `flutter analyze` scoped to touched files
    (`lib/core/navigation/app_shell.dart`,
    `lib/features/chat/presentation/chat_entry_gate.dart`,
    `test/core/navigation/app_shell_test.dart`): 5 `info`-level
    `prefer_initializing_formals` style suggestions on `AppShell`'s
    constructor (public param names intentionally differ from private field
    names); 0 errors, 0 warnings.
