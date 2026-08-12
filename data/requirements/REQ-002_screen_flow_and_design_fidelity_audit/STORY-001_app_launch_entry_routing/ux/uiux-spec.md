# UX Spec: STORY-001 App Launch / Session-Based Entry Routing

Scope: routing logic only. No new screen, no visual redesign of splash
(visual fidelity is STORY-003). This spec exists so mobile-dev can implement
the routing state machine without re-deriving AC1-AC5.

## Screens / Routes Touched
- `splash` (existing entry route — routing source only, visuals untouched)
- `home` (target — valid/refreshable session)
- `login` (target — expired/invalid session)
- `welcome` (target — no session)

## Splash Routing State Machine

States:
1. **Entering** — splash mounts on cold launch or resume-from-terminated
   state only (never on a foreground resume of an already-running app —
   see AC5 / "Resume Guard" below).
2. **Checking** — splash holds visually static (no navigation, no
   intermediate screen swap) while two operations run concurrently:
   - Minimum dwell timer: 2s fixed.
   - Session resolution: resolve current session/refresh-token state to one
     of `valid`, `expired`, `none`.
3. **Resolved** — both the dwell timer and session resolution have
   completed. The state machine reads whichever resolution value came back
   and performs exactly one navigation, replacing the splash route (no
   back-stack entry to splash).
4. **Routed** — terminal state for this launch; the entry-routing decision
   does not run again until the next cold/terminated-state launch.

Transition rule: navigation is gated on `dwell_complete AND
session_resolved`, whichever finishes last triggers the transition to
Resolved. Neither condition alone is sufficient (AC4).

## Routing Decision Table

| Session resolution | Target route | AC |
|---|---|---|
| `valid` (or silently refreshable) | `home` | AC1 |
| `expired` / `invalid` (was previously authenticated) | `login` | AC2 |
| `none` (first install, or after deliberate sign-out) | `welcome` | AC3 |

Only one navigation call is made per cold launch, using route replacement
(not push), so the user cannot navigate back to splash.

## Checking-State UI

- Splash surface stays visually static for the full hold — no flicker, no
  placeholder/intermediate screen, no partial navigation.
- If a loading indicator is used to signal the session check is in
  progress, it must be a non-blocking, non-branded addition to the existing
  splash surface (e.g. a subtle indicator) — it must not alter splash
  layout, imagery, or composition, since splash visual fidelity is owned by
  STORY-003. Coordinate final indicator treatment (or its omission) with
  the STORY-003 implementer so the two stories do not land conflicting
  splash changes.
- No transition animation is specified beyond the app's existing default
  route-replacement transition when moving from splash to the resolved
  target (`home` / `login` / `welcome`); this story does not introduce a
  new transition.

## Resume Guard (AC5)

- The entry-routing decision (the state machine above) runs only on a cold
  start or a resume from a fully terminated app state.
- A foreground/background lifecycle transition of an already-running app
  with a still-valid session must not re-mount splash, must not re-run the
  routing decision, and must not navigate the user away from whatever
  screen they are currently on.
- This guard is a platform/navigation-layer concern (distinguishing "cold
  launch" from "lifecycle resume"); the exact mechanism is an Open Item for
  Tech Lead per story_master.md. This spec only fixes the UX-visible
  contract: no visible re-route, no visible re-splash, on ordinary
  foreground resume.

## Out of Scope (confirmed)
- Splash/welcome/login/home visual design — Scope B stories.
- Sign-out / mid-session forced-re-auth navigation — STORY-002.
- Session/token issuance, storage, validation mechanics — backend-frozen,
  Tech Lead decides resolution mechanism only.
