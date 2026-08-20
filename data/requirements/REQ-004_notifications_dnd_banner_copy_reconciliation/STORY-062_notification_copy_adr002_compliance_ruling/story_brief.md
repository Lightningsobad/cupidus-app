# Story Brief: STORY-062 Notification Copy ADR-002 Compliance Ruling

## Identity

- Parent requirement:
  `data/requirements/REQ-004_notifications_dnd_banner_copy_reconciliation/req_master.md`
- Story master:
  `data/requirements/REQ-004_notifications_dnd_banner_copy_reconciliation/STORY-062_notification_copy_adr002_compliance_ruling/story_master.md`
- Final story requirements artifact:
  `data/requirements/REQ-004_notifications_dnd_banner_copy_reconciliation/STORY-062_notification_copy_adr002_compliance_ruling/requirements/requirements.md`

## Brief

- Actor: end user reading notification-related copy (account settings
  `notifs` screen; onboarding `permissions` screen).
- Capability: both screens' copy stays honest about what the app can
  deliver — no Do-Not-Disturb-override claim, no native-alarm-clock label —
  and that guarantee is enforced by a static guard that catches the claim in
  either English or Vietnamese.
- Business value: closes two open Reviewer/retro findings (E-2, RWB-20260816-024
  AC2) with a durable, documented ruling instead of leaving the guard/design
  conflict unresolved or relying on implementer discretion that could be
  reversed later.
- Key business rules or guardrails: ADR-002 is not amended — its rationale
  (no Critical Alerts entitlement; R9 foreground-only delivery) is still
  true. See `req_master.md` Ruling for full citation chain.
- Key edge or failure case: a future contributor translates the design
  source's "Do Not Disturb" sentence into Vietnamese to "fix" a copy diff —
  the hardened guard must fail that build the same way it already fails the
  English wording.
- Existing system entry / discoverability seed: not applicable — no new
  screen, no new entry point; both screens already ship and are already
  reachable.
- Complexity: trivial — single-lane (mobile-dev, test file only), no new
  screens, no new UX decision (copy is already ratified by this ruling), no
  new architecture decision.
- Why this complexity: the only code change is adding one token to an
  existing static guard test; both screens' production copy is unchanged.
- Implementation lane seed: mobile.
- Depends on: None.

## Direct Anchors

- Requirement AC / BR anchors: `req_master.md` Scope bullets 1-3, Ruling
  section.
- Open Question anchors: `req_master.md` Open Questions (RESOLVED), central
  registry `conflicts_open_questions.md:73-85`.
- Related story dependencies: none. References STORY-031 and STORY-047
  (REQ-002) as the source of the already-shipped copy this story ratifies,
  but does not depend on reopening either.

## Scope Seed

### In Scope

- Add the Vietnamese Do-Not-Disturb phrase ("không làm phiền") to
  `reminder_copy_guard_test.dart`'s forbidden-token list.
- Confirm `notification_settings_screen_test.dart` and
  `permissions_screen_test.dart` still pass unmodified (regression proof that
  no copy changed).
- Record the ratified ruling's citation trail in the story-level requirements
  artifact for Reviewer traceability.

### Out of Scope

- Changing the `notifs` banner or `permissions` row copy text.
- Any other forbidden-token addition beyond the one Vietnamese DND phrase
  this ruling's intent requires.
- Reopening ADR-002, D1, or R9.
