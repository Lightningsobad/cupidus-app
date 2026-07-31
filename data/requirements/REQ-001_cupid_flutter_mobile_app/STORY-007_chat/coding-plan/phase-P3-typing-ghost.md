# Phase P3 – Typing Ghost (2-way, AC2) and `ghostset`

## 1. Objective

Ship the 2-way typing ghost with the ADR-013b client-owned timing contract, the
receiver-side struck-through deleted-run derivation, the 3-state consent toggle,
and the `ghostset` settings screen. Covers AC2.

## 1A. Ownership

- Phase ID: P3
- Canonical Phase File: `phase-P3-typing-ghost.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P2
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/chat/presentation/ghost_cubit.dart`
  - `mobile/lib/features/chat/presentation/screens/ghost_settings_screen.dart`
  - `mobile/lib/features/chat/presentation/widgets/ghost_bubble.dart`
  - `mobile/lib/features/chat/data/ghost_consent_store.dart`
  - `mobile/lib/features/chat/presentation/widgets/chat_composer.dart` (edit; created by P2)
  - `mobile/test/features/chat/presentation/ghost_cubit_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: N/A
  - Readiness Check: N/A for this phase
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `GhostCubit`
  - `GhostConsentStore`
  - `ghostTimingConstants` (the ADR-013b values, exported for tests)
- Shared Interfaces Consumed:
  - `ChatPartnerStore`, `chat_events.dart` (P1)
  - `ChatComposer` (P2)
  - `RealtimeCoordinator.emit` / `events(names:)` (STORY-004)
- Risk Surfaces:
  - Typing-ghost timing (AC2)
  - Ghost consent + privacy
- Source Of Truth:
  - authoritative artifact: `../architecture/solution.md` §4 ADR-013b timing table and ADR-013e state model
  - consumer contract: `GhostCubit` state consumed by `ChatComposer` and `GhostBubble`
- Primary Inputs Summary:
  - architecture: `../architecture/solution.md` §4 ADR-013b (timing constants, receiver-side deleted-run derivation), ADR-013e (consent states, local opt-in gate)
  - OQ constraints: `../architecture/solution.md` §2 invariant 3 — ghost content never touches Drift or `shared_preferences`
  - upstream phase outputs: P2 `ChatComposer`; P1 `ChatPartnerStore`, `chat_events.dart`
  - UX constraints: `../ux/uiux-spec.md` §3d (three toggle states, placeholder swap, watched-warning row, dashed partner ghost bubble with struck-through deleted runs and 1.3 s `ghostFade`), §4 (four `ghostset` cards, mutual-consent footer), §8 (polite live region)
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: none
- Phase Sizing:
  - Behavior Slice: typing ghost and its settings screen only
  - Source/Test File Count: 4 source + 1 edit to a P2 file + 1 test
  - Split Required: NO
  - Split Rationale: within one specialist lifecycle. The `chat_composer.dart` edit overlaps P2's write scope, which is safe because both phases run sequentially in the single mobile lane

## 2. Required Reads

- `../architecture/solution.md` §4 ADR-013b, ADR-013e; §2 invariant 3
- `../ux/uiux-spec.md` §3d, §4, §8
- P2 output `mobile/lib/features/chat/presentation/widgets/chat_composer.dart`
- P1 outputs `mobile/lib/features/chat/data/chat_partner_store.dart`, `chat_events.dart`

## 3. Tasks

- Create `ghost_consent_store.dart` (ADR-013e): persists a single `shared_preferences` boolean recording whether the user has explicitly opted into typing ghost on this device. Rationale to record in a doc comment: the frozen backend defaults `User.isGhostModeEnabled` to `true`, so the server flag alone is not informed consent for keystroke streaming. `optIn()` writes the local flag and `PATCH /users/me {isGhostModeEnabled: true}`; `optOut()` clears it and PATCHes `false`.
- Create `ghost_cubit.dart` with the ADR-013b constants exported as named consts so tests reference them rather than duplicating literals:
  - outbound throttle 120 ms, trailing edge
  - immediate flush on any `content` length **decrease** (deletion) — never coalesced
  - sender idle 1200 ms then `emit('stopTyping', {...})`
  - receiver stale-ghost expiry 6000 ms since the last `ghostTyping`
- Sender path: on each draft change, emit `typing` with the **full current draft** as `content` (the payload shape is frozen), subject to the throttle and the deletion flush. Reset the idle timer on every keystroke.
- Receiver path: subscribe to `events(names: {ghostTyping, ghostStopTyping})`. Keep the previous `content` in memory and diff it against each new value; the removed tail renders struck-through in `--ghost` with the 1.3 s `ghostFade` fade-to-45%-opacity. This derivation is entirely receiver-side — the backend carries no deletion information (ADR-013b).
- Implement the receiver stale expiry as a hard requirement, not defensive polish: ephemeral events are dropped while the app is not foreground (ADR-012d/g), so a `ghostStopTyping` can be lost and would otherwise leave a stuck ghost bubble.
- Consent state machine (ADR-013e): `off` when the local opt-in flag is false or the server flag is false; `pending` when opted in locally and server-true but no `ghostTyping` has been received from the partner this session; `on` once any `ghostTyping` has been received. The partner column in `ghostset` must read waiting/unknown, never a definite "off" — the contract exposes no partner flag.
- Inject the clock/timer factory so tests can drive all four constants deterministically (follow the `GraceTimerFactory` seam already used in `core/realtime/realtime_coordinator.dart`).
- Ghost content must never be written to Drift or `shared_preferences`, and must never be logged (`../architecture/solution.md` §2 invariant 3, §5).
- Edit `chat_composer.dart`: add the 3-state ghost toggle to the left of the text field per `../ux/uiux-spec.md` §3d (off `--surf`/`--tx2`/"OFF"; pending `···`; on `rgba(183,140,245,.24)`/`--purple`/"ON"). Tapping while `pending` performs the accept/opt-in action rather than re-toggling. Swap the field placeholder to the "They see every keystroke…" copy while `on`. Show the "…is watching you type" warning row above the composer only while `on` **and** the draft is non-empty.
- Create `ghost_bubble.dart`: dashed `rgba(183,140,245,.6)` border, `rgba(183,140,245,.12)` fill, blinking-cursor character, struck-through deleted runs. Visually distinct from `message_bubble.dart` — do not reduce it to a plain "…is typing" indicator.
- Create `ghost_settings_screen.dart` reproducing the four `ghostset` cards from `../ux/uiux-spec.md` §4 verbatim, with the header and bottom tab bar visible. Mark the "under 200ms" explainer copy with a code comment noting it is unverified product copy pending PO revision (ADR-013b).
- Accessibility (`../ux/uiux-spec.md` §8): the partner's live draft is a **polite** live region — per-keystroke deltas must not each interrupt. Announce only ghost on/off transitions and full message arrivals assertively. The 3-state toggle exposes semantic labels, not colour or the `···` glyph alone.
- Write `ghost_cubit_test.dart` with a fake clock/timer factory and a fake coordinator.

## 4. Acceptance Criteria

- AC2 timing, each asserted against the exported constant rather than a duplicated literal:
  - rapid keystrokes within 120 ms produce one trailing `typing` emit
  - a content-length decrease produces an immediate `typing` emit even inside an active throttle window
  - 1200 ms of no keystrokes produces exactly one `stopTyping` emit
  - 6000 ms with no further `ghostTyping` clears the partner ghost bubble even when no `ghostStopTyping` arrives
- Deleted-run derivation: feeding `"hello"` then `"he"` yields a rendered struck-through `"llo"` run.
- Consent: with the server flag `true` but no local opt-in, the composer toggle renders `off` and no `typing` is ever emitted. After `optIn()`, `pending` is entered; the first received `ghostTyping` moves it to `on`.
- No ghost content reaches Drift or `shared_preferences` (asserted with an in-memory database and a fake prefs store).
- `flutter analyze` reports no new issues.

## 5. Planned Outputs

- Code: `mobile/lib/features/chat/presentation/ghost_cubit.dart`, `screens/ghost_settings_screen.dart`, `widgets/ghost_bubble.dart`, `mobile/lib/features/chat/data/ghost_consent_store.dart`, edited `widgets/chat_composer.dart`
- Contracts: `GhostCubit`, `GhostConsentStore`, exported ADR-013b timing constants
- Requirement configuration guide updates: none
- Notes: `ghost_settings_screen.dart` carries the "under 200ms" copy caveat comment

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, `chat` composer plus `ghostset` screen
- Required levels:
  - unit: `bloc_test` on `GhostCubit` with an injected fake clock covering all four ADR-013b constants; deleted-run diff; consent state machine; no-persistence assertion
  - integration: widget test on `ghost_settings_screen.dart` rendering all three toggle states with their semantic labels
  - mobile build/type-check/static-analysis: `flutter analyze`
- Required checks: ghost content absent from Drift and prefs; partner consent column never renders a definite "off"
- Mobile discoverability / navigation integration: P4 owns the `ghostset` entry point from the chat header. P3 must not wire its own ad-hoc route.
- Minimum gates by risk surface:
  - Typing-ghost timing (AC2): all four constants asserted with a fake clock
  - Ghost consent + privacy: server-default-true does not enable ghost without local opt-in; no ghost content persisted
- Required regression or contract coverage: P2's `chat_cubit_test.dart` and the `ChatScreen` widget test must still pass after the `chat_composer.dart` edit
- Required runtime signals: none — no runtime startup smoke in this phase
- Evidence format: concise rows recorded by P5 in `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests: `flutter test test/features/chat/`
  - Build/type-check/lint command: `flutter analyze`
  - Required assertion evidence: recorded emit list and timestamps from the fake coordinator for each timing case; rendered struck-through run for the delete case; empty Drift and prefs state after a ghost session

## 7. Status

- Status: DONE
- Last updated: 2026-07-31
- Delivered:
  - `mobile/lib/features/chat/data/ghost_consent_store.dart` (new)
  - `mobile/lib/features/chat/presentation/ghost_cubit.dart` (new)
  - `mobile/lib/features/chat/presentation/widgets/ghost_bubble.dart` (new)
  - `mobile/lib/features/chat/presentation/screens/ghost_settings_screen.dart` (new)
  - `mobile/lib/features/chat/presentation/chat_strings.dart` (edit: ghost/`ghostset` copy)
  - `mobile/lib/features/chat/presentation/widgets/chat_composer.dart` (edit: 3-state toggle, placeholder swap, watched-warning row)
  - `mobile/lib/features/chat/presentation/screens/chat_screen.dart` (edit: wires `GhostCubit`, `GhostBubble`, assertive on/off announcement — no `ghostset` nav entry, reserved for P4)
  - `mobile/test/features/chat/presentation/ghost_cubit_test.dart` (new)
- Evidence: `flutter test test/features/chat/` — 44/44 passed (14 new
  `ghost_cubit_test.dart` cases: sender timing throttle/decrease-flush/idle-stop,
  receiver stale-expiry and struck-through deleted-run derivation, consent state
  machine, no-persistence guard; P2's `chat_cubit_test.dart` and
  `chat_repository_test.dart` still pass unchanged). `flutter analyze
  lib/features/chat/ test/features/chat/` — 0 errors/warnings, 14 pre-existing
  `prefer_initializing_formals` info-level lints only (established repo
  precedent, not fixed; matches STORY-003/005).
- Scope note: §6 Test Scope also names a `ghost_settings_screen.dart` widget
  test, but §1B Write Scope and Phase Sizing ("1 test") name only
  `ghost_cubit_test.dart`. Write Scope was treated as authoritative (same
  precedent as the `chat_screen.dart` write-scope resolution above); no widget
  test file was added. Flagging this doc inconsistency for Tech Lead/Reviewer.
