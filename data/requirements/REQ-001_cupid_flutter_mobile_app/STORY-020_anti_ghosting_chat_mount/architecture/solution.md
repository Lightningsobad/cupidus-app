# STORY-020 Anti-Ghosting Chat Mount – solution.md

## 0. Metadata

- Complexity: XS
- Date: 2026-08-12

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: close STORY-008 AC2, which failed because a
  deliberately exported mount seam was never consumed. The fix must be the
  smallest edit that makes the seam live, not a redesign of either side.
- Architectural invariants / non-goals: `GhostStateRow` and `GhostStormCubit`
  are frozen; `mobile/lib/features/anti_ghosting/**` is read-only in this
  story. `ChatComposer` stays the last `Column` child. Chat gains no
  anti-ghosting configuration entry point.
- Proposed technical direction: one import plus one `Column` child in
  `chat_screen.dart`, and one nullable `partnerId` field threaded from
  `ChatScreen` (which already holds `partnerStore`) into `_ChatView`. No new
  cubit, provider, repository, route, or string.
- Why this fits the current system: `GhostStateRow` was authored as a
  zero-dependency drop-in — it owns its own `BlocProvider<GhostStormCubit>`,
  resolves `GhostConfigRepository` from `get_it` itself, runs its own
  lifecycle poll, and has no compile dependency on any `features/chat/` type.
  The chat side therefore needs no wiring beyond passing a `String partnerId`.

### Key Discovery

STORY-008's ADR-2 guard rationale is stale, and it is the reason this story is
worth doing rather than a no-op. `ghost_state_row.dart:37-42` guards on
`getIt.isRegistered<GhostConfigRepository>()` because, at STORY-008 authoring
time, "nothing on the current `HomeScreen`/`main.dart` boot path calls
`setupServiceLocator()`". That is no longer true: `mobile/lib/main.dart:20`
calls `setupServiceLocator()`, and `mobile/lib/core/di/service_locator.dart:238`
registers `GhostConfigRepository` as a lazy singleton. The guard therefore
passes in the running app, the storm poll actually starts, and AC1's
running-app evidence is obtainable. Had the comment still been accurate, this
mount would have rendered `SizedBox.shrink()` forever and the story would have
been blocked on DI work instead. Do not "fix" the stale comment — the file is
out of write scope.

Second discovery, which removes a task the handoff asked to check: no
`GhostStormCubit` reachability work exists at the mount point. `ChatScreen`'s
`MultiBlocProvider` (`chat_screen.dart:46-63`) must **not** be extended;
`GhostStateRow` provides its own cubit internally. Adding a second provider
would create two competing pollers.

## 3. Scope And Assumptions

- In Scope: `mobile/lib/features/chat/presentation/screens/chat_screen.dart`
  and one new chat widget test.
- Out Of Scope: `mobile/lib/features/anti_ghosting/**`, `ghost-config` backend
  contract, every other chat surface, and the non-interactive CTA pill flagged
  in `../ux/uiux-spec.md` §5.2.
- Assumptions affecting design: `ChatScreen` is reachable only through
  `ChatEntryGate`, which unlocks on `ChatPartnerStore.partnerId != null`
  (`../ux/uiux-spec.md` §2), so a non-null `partnerId` is the normal case and
  null is a defensive path, not a designed state.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module: `mobile/lib/features/chat/presentation/screens/`.
- New or changed boundaries: none. This story consumes an existing published
  seam; it does not create one. The dependency direction is chat →
  anti_ghosting, one way, via the existing feature barrel
  `mobile/lib/features/anti_ghosting/anti_ghosting.dart`, which already
  exports `GhostStateRow`. Import the barrel, not the widget file.
- Shared patterns reused: cross-feature imports in `chat_screen.dart` use
  `package:cupid_mobile/...`; only `features/chat/`-internal imports are
  relative.

### Affected Modules

- Mobile: `features/chat/presentation/screens`.

### Contracts And Integrations

- Empty-state contract: the row is mounted unconditionally with respect to
  *storm status* — it already self-collapses to `SizedBox.shrink()` when the
  status is not `eligible`, so chat must not wrap it in a state-conditional
  builder, add `Padding`, or add a divider. The single permitted condition is
  `partnerId != null`; a null partner renders nothing at all, with no
  placeholder and no error copy.
- Compatibility posture: `GhostStateRow`'s own guard already tolerates an
  unregistered locator, so a harness that mounts `ChatScreen` without
  `setupServiceLocator()` stays green rather than crashing.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|---|---|---|---|---|
| Seam ordering | `../ux/uiux-spec.md` §1, §3 | Insert as a new `Column` child strictly after the `GhostBubble` `BlocBuilder` and before the `ChatComposer` `BlocBuilder`; touch no other child | Widget test asserts `GhostStateRow`'s top edge sits below `GhostBubble`'s region and above `ChatComposer` | Report ordering unverifiable; do not merge on visual inspection alone |
| Idle zero-cost | `../ux/uiux-spec.md` §2 | Mount unconditionally on storm status; add no wrapper, spacing, or divider | Widget test asserts the seen/no-reply copy is absent and no extra height is introduced when the status is not `eligible` | Report as blocker |
| Unpaired leak | `../ux/uiux-spec.md` §2, STORY-008 AC3 | Guard only on `partnerId != null` | Widget test asserts `GhostStateRow` is absent from the tree when `partnerStore.partnerId` is null | Report as blocker |
| Duplicate storm poll | `ghost_state_row.dart:44-51` | Do not add `GhostStormCubit` to `ChatScreen`'s `MultiBlocProvider` | Reviewer confirms `MultiBlocProvider` is unchanged in the diff | Report as blocker |
| AC1 running-app evidence | `story_master.md` AC1 | Emulator capture of chat with an eligible storm status | Mobile visual audit screenshots under `../visual-fidelity/` | Report `MOBILE_VERIFY_REQUIRED` with the exact missing capture |

### Lane Handoff

#### Mobile Lane

- Responsibilities: thread `partnerId`, mount the row, add the mount test,
  capture running-app evidence.
- Authoritative inputs: `../ux/uiux-spec.md` §1-§3, this section 4.
- Guardrails: do not edit any file under
  `mobile/lib/features/anti_ghosting/`; do not extend `ChatScreen`'s
  `MultiBlocProvider`; do not reorder, restyle, or re-space any existing
  `Column` child; do not add an announcement for the row (the widget owns its
  own live region, `ghost_state_row.dart:138`); do not add a new l10n key.

## 5. Non-Functional Impact

- Opening chat now starts a `GET /ghost-config/storm-status/:partnerId` poll
  (60s, foreground-only) that did not previously run on this screen. This is
  the widget's designed ADR-2 behavior and is accepted as-is; it is recorded
  here only so it is not read later as a chat-screen regression.

## 7. Authorized Write-Scope Extension — Preview Harness (2026-08-12)

Durable authorization for the AC1 capture blocker in
`../visual-fidelity/visual-fidelity-report.md`. Option A is **AUTHORIZED**;
Option B is **REJECTED** (it contradicts `capture-mobile-screen.sh`'s stated
"state must be FAKED, not driven" contract, is not repeatable, leaves the
preview harness broken for every future chat capture, and does not by itself
produce the eligible-storm state anyway).

**Correction to the proposal.** The report names `main_preview.dart` as the
target, following STORY-019. That route is a dead end: `AuthRepository`'s
backend sync is private and reachable only through its gateway-backed sign-in
methods; the preview's `_PreviewUnusedAuthGateway` throws on every method
(`main_preview.dart:407-436`); `FirebaseSignInGateway` still has no concrete
implementation in this worktree; and `_buildAuthRepository()`
(`main_preview.dart:438-442`) does not even pass the optional
`backendUserIdStore`. "Perform a real backend login through `AuthRepository`"
therefore requires building a Firebase gateway — far outside this story.

The equivalent result is ~10 lines in the bootstrap, using public API only.
`main()` already runs `setupServiceLocator()` before
`bootstrapPreviewSession()` (`main_preview.dart:457-458`), so `getIt` is ready.

**Second blocker, not yet reported.** Fixing the crash alone still yields no
AC1 eligible capture. `ChatPartnerStore.refreshFromServer()` is called only by
`ChatEntryGate` (`chat_entry_gate.dart:43`), which the preview bypasses by
building `ChatScreen` directly (`main_preview.dart:238-242`). `partnerId`
stays null, so the mount's `partnerId != null` guard correctly suppresses the
row. The grant below covers this.

### Granted write scope

- Grant: `mobile/lib/preview/preview_session_bootstrap.dart` — this file only.
- **May**: after the existing Firebase sign-in, `POST /auth/login` via
  `getIt<CupidApi>().dio`, pass the response body to
  `getIt<BackendUserIdStore>().updateFromLoginResponse(...)`, then
  `await getIt<ChatPartnerStore>().refreshFromServer()`. Update the file's doc
  comment to cite this section as the authorization.
- **Must**: keep all new work inside the existing `PREVIEW_EMAIL` /
  `PREVIEW_PASSWORD` empty-guard, so the unauthenticated preview path is
  unchanged; and make the new backend work non-fatal (catch and continue) —
  `bootstrapPreviewSession()` is awaited before `runApp`, so an unreachable
  backend must not take down the other 36 preview screens.
- **May not**: modify `main_preview.dart`, `main.dart`, `service_locator.dart`,
  `auth_repository.dart`, `firebase_sign_in_gateway.dart`, `chat_entry_gate.dart`,
  either store class, anything under `mobile/lib/features/`, or
  `capture-mobile-screen.sh`. No `/auth/register` fallback (it would mutate
  backend state mid-capture; preview accounts are pre-seeded). No committed
  credentials, no new package dependency, no new `getIt` registration, no new
  preview screen builder, no change to the 37-canvas registry.
- Verification: `flutter analyze` clean; both AC1 captures produced; and one
  unrelated preview screen still renders with `PREVIEW_EMAIL`/`PREVIEW_PASSWORD`
  unset, proving the no-op path is intact.

### Backend state authorization

The staged `storm-status` recipe (report § "What is NOT blocked") is authorized
to **execute** against the dev backend on port 3005, using only the seeded
`preview.dev.a@cupid.test` / `preview.dev.b@cupid.test` accounts, with no
backend code, schema, or seed-script change. Record the mutation in
`coding-plan/test-results.md` so the dev-backend state change is traceable.

### Known follow-up, not this story's scope

STORY-018's `chat` entry in its 37/37 coverage claim was never a real
`ChatScreen` render — its baseline capture shows the same crashed empty
scaffold. Option A repairs this as a side effect, but STORY-018's coverage
record is not corrected here. Flagged for backlog; do not open scope for it in
STORY-020.
