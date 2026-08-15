# UX Spec: STORY-002 Onboarding & Pairing Flow Navigation Correction

Story-Class: standard | Scope: A (Screen Flow / Navigation Correction)
This is a **navigation-correction spec only** — no new screens, no new entry
points. All nodes below already exist in the app; only the edges (transitions)
and chrome rules are being corrected.

## Screens/Nodes Touched
- `welcome`
- `login`
- `register`
- `forgot_password`
- `otp` (registration verification)
- `permissions`
- `onboarding_profile_setup`
- `pairing_choice` (invite vs. join-code selection step)
- `invite` (create pairing code)
- `join_code` (enter pairing code)
- `waiting` (waiting-for-pairing)
- `paired`
- `love_contract`
- `fingerprint_vow`
- `home` (post-pairing, 5-tab entry)

## Corrected Navigation Graph

| From | Trigger | To | Notes |
|---|---|---|---|
| `welcome` | user selects "sign in" | `login` | |
| `welcome` | user selects "create account" | `register` | |
| `login` | credentials valid, account already paired | `home` | skips onboarding/pairing chain entirely |
| `login` | credentials valid, account not yet paired | resume at correct chain node for that account's pairing state (`onboarding_profile_setup` / `pairing_choice` / `waiting`, per backend state) | not a fixed single target — Tech Lead to define state-resolution rule |
| `login` | user taps "forgot password" | `forgot_password` | |
| `forgot_password` | back | `login` | |
| `register` | registration submitted | `otp` | |
| `otp` | verification succeeds (first time) | `permissions` | AC2: chain must continue in order below, no skip, no loop to `welcome`/`login` |
| `permissions` | permissions step complete | `onboarding_profile_setup` | |
| `onboarding_profile_setup` | profile setup complete | `pairing_choice` | distinct chain step per AC2 — not merged into profile setup screen |
| `pairing_choice` | user selects "create code" | `invite` | |
| `pairing_choice` | user selects "enter code" | `join_code` | |
| `invite` | code created, no confirmation yet | `waiting` | |
| `join_code` | code submitted, backend has not yet confirmed pairing | `waiting` | |
| `join_code` | code submitted, backend confirms pairing synchronously | `paired` | direct-to-paired branch is a backend-flow outcome, not a UX-designed extra screen; Tech Lead owns which condition applies |
| `waiting` | backend confirms pairing (poll/push — Tech Lead decision) | `paired` | |
| `paired` | advance | `love_contract` | |
| `love_contract` | contract accepted | `fingerprint_vow` | |
| `fingerprint_vow` | vow completed | `home` | 5-tab bar becomes visible starting here — first appearance in the whole chain |

### Sign-out (any authenticated screen)
`[authenticated app]` → user-initiated sign-out confirmed → session torn down
→ `welcome`.
Ordering is fixed: teardown happens before navigation fires (AC5). Do not
route to `welcome` first and teardown after.

### Mid-session forced re-auth (any authenticated screen)
`[authenticated app]` → refresh-token failure detected during active use
(not cold launch) → `login`.
Must remain visually/behaviorally distinct from the sign-out target
(`login`, not `welcome`) — this is the one exception to "sign-out goes to
welcome" (AC6).

## Chrome Rules (NO_CHROME + NO_TABS)
Applies to every node in this chain, `splash` through `fingerprint_vow`
(AC4). `splash`'s routing decision itself is STORY-001 scope, but its chrome
state is covered by this same rule and must not regress.
- No header/app-bar chrome on any screen in this list.
- No bottom 5-tab bar on any screen in this list.
- `home` is the first point in the entire flow where the 5-tab bar appears.

## Transitional/Loading States (resolves Open Item)
No new screens are introduced for in-flight backend calls. Where a chain
screen is waiting on a backend response, use an in-place loading affordance
on the current screen, not a route change:
- `otp`: in-place spinner/disabled-state while verification is in flight.
- `join_code` / `invite`: in-place spinner/disabled-state while the pairing
  attempt is submitted, before the router decides between `waiting` and
  `paired`.
- `waiting`: its own screen **is** the transitional state for the
  poll/push-driven `waiting` → `paired` transition; no separate loading
  screen is needed on top of it.

## Open Items Still Owned By Tech Lead
- Exact routing/guard mechanism for `login` → `home` vs. resume-in-chain vs.
  `forgot_password`.
- Poll vs. push mechanism for `waiting` → `paired`.
- Condition under which `join_code` bypasses `waiting` and goes directly to
  `paired`.

These are implementation-detail decisions within the graph above, not open
UX questions — the graph does not change based on how Tech Lead resolves
them.
