# Story Brief: STORY-002 Pairing-Choice Navigation Restore

## Identity

- Parent requirement: REQ-009_invite_couple_type_and_pairing_navigation
- Story master: `data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/STORY-002_pairing_choice_navigation_restore/story_master.md`
- Final story requirements artifact: `data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/STORY-002_pairing_choice_navigation_restore/requirements/requirements.md`

## Brief

- Actor: any user who has just created (inviter) or entered (invitee) a
  pairing code.
- Capability: continuing from invite/join-code reaches Waiting-for-partner
  via the pairing-choice screen, never Fingerprint Vow; back navigation from
  invite/join-code returns to pairing-choice.
- Business value: restores the intended pre-pairing flow order (reverts the
  `3d74a75` divergence); keeps `pairing_choice_screen.dart` (STORY-034 in
  REQ-002) live rather than orphaned.
- Key business rules or guardrails: `BACK_TO` invite->pairing-choice,
  joincode->pairing-choice (exact wiring, not invite->profile or
  joincode->invite); Fingerprint Vow never reachable as immediate post-code
  target from either screen.
- Key edge or failure case: any existing test pinned to the old `goVow`
  target (e.g. `app_shell_test.dart`) must be updated, not left asserting a
  now-wrong expectation — same test-family risk already handled once for
  `BUG-20260817-001`.
- Existing system entry / discoverability seed: all three screens (invite,
  join-code, pairing-choice) already exist and are reachable; no new entry
  point, this story corrects/confirms navigation edges between them.
- Complexity: standard — navigation-graph correction + design-node
  restoration + regression-test reconciliation, needs UX Design (design
  node restore) and Tech Lead (verify actual current wiring, since the
  registered `pairing_choice_screen.dart` builder may already sit in a
  different graph position than the locked decision's literal description —
  confirm during architecture, don't reopen the decision itself). Lane:
  shared.
- Depends on: NONE (independent of STORY-001; see requirement-level
  `## Recommended Story Sequence`).

## Direct Anchors

- Requirement AC / BR anchors: `req_master.md` `## Locked Navigation
  Decisions` item 2; `req_master.md` `## Scope For Product Owner / UI-UX /
  Tech Lead` (pairing_choice_screen.dart reconnect, regression risk bullets).
- Open Question anchors: OQ5 (light theme/EN locale) — non-blocking, same
  disposition as REQ-002 STORY-011/036/037.
- Related story dependencies: STORY-001 (Invite couple-type picker) — no
  structural dependency; STORY-001 adds screen content above the Continue
  CTA, this story owns only what Continue does next.

## Scope Seed

### In Scope

- Invite/join-code -> pairing-choice -> Waiting-for-partner (not Vow).
- `BACK_TO` wiring for invite and join-code.
- `pairing_choice_screen.dart` content/design confirmation.
- `pairing_choice`/`isPairingChoice` design-system node restoration.
- Regression test updates for any `goVow`-pinned expectation.

### Out of Scope

- Fingerprint Vow's own design or its entry point elsewhere in the product.
- 5-tab shell / FAB changes beyond these two navigation edges.
- The couple-type picker (STORY-001's scope).
- Reopening `BUG-20260817-001`'s own fix.
