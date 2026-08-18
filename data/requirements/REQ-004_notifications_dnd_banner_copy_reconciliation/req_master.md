# Requirement Master: REQ-004 Notifications DND Banner Copy Reconciliation
Status: PENDING

## Source Request
Not user-typed prose. Raised as finding **E-2** in REQ-002's Round 2
requirement-integration-review (Iris-QC,
`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/integration-review/review-report.md`,
"Decisions Required — Not Mine To Make"), then routed to the user directly by
Scrum Master via `AskUserQuestion` on 2026-08-16. User selected: **"Route to
PO/UX for a copy ruling."**

## Business Context
The locked design's `notifs` screen banner includes a "Do Not Disturb"
sentence. STORY-021's approved ADR-002 copy guard test
(`reminder_copy_guard_test.dart:18-22`) explicitly bans that literal string,
with an inline code comment instructing implementers not to delete the test
to unblock a copy change. This is a genuine conflict between the locked
design source and an approved architecture decision record — Iris-QC
assessed it as a business/product ruling, not a call the reviewer or Scrum
Master should make unilaterally.

The user has decided this should be resolved by Product Owner / UI-UX
Designer, not by silently keeping the ADR guard as-is.

**Second token folded in (2026-08-18, user decision):** STORY-047
(`REQ-002_screen_flow_and_design_fidelity_audit/STORY-047_pairing_chain_deviation_triage`,
retro-hardening RWB-20260816-024, AC2) hit the same
`reminder_copy_guard_test.dart:18-22` guard for a second, independent locked
design-source token: the `permissions` screen's notification-permission row
body copy is specified as `Synced Alarm và Emoji Storm cần cái này...`
(`Cupid Screens.dc.html:2452`), and `synced alarm` is separately banned by
the same guard. The app currently ships the ADR-002-canonical
`Nhắc nhở đồng bộ`/`Synced Reminder` phrasing instead
(`permissions_screen.dart:80-81`, unchanged). Mobile implementation reverted
the attempted AC2 copy change and left `main` green; verified by Scrum
Master against disk. This requirement now owns both tokens against the same
ADR-002 guard so PO/UX makes one ruling, not two.

## Scope
- Product Owner / UI-UX Designer review both the design intent behind the
  DND banner sentence and the rationale behind ADR-002's ban on that literal
  string, then rule on one of:
  - Alternate banner copy that preserves the design's DND-awareness intent
    without violating ADR-002 (update the screen only, guard test stays as
    the enforcement backstop), or
  - A scoped, deliberate amendment to ADR-002/the guard test if the ruling
    concludes the original ban no longer reflects current product intent
    (this must be an explicit, documented ADR change, not a silent test
    deletion).
- Update `notifs` screen copy and/or the guard test together, consistent with
  whichever ruling is made.
- Apply the same ruling logic to the `permissions` screen's `Synced Alarm`
  token (STORY-047 AC2, folded in 2026-08-18): either alternate copy that
  preserves design intent without violating ADR-002, or the same documented
  ADR-002 amendment if it applies to both tokens. Update
  `permissions_screen.dart:80-81` and
  `mobile/test/features/onboarding/permissions_screen_test.dart` (already
  carries two assertions pinning the current ADR-002-canonical copy in both
  locales, added by STORY-047's mobile-dev as a marker for whoever executes
  this ruling) together with whichever ruling is made.

## Out of Scope
- REQ-003 (app shell five-tab navigation) — separate, unrelated requirement
  from the same review round.
- Any other Round 2 deferred/blocking findings tracked in REQ-002's own
  `req_master.md` Deferred Follow-Up Items or bug registry.
- STORY-047's AC1/AC3/AC4/AC5 (profile CTA copy, joincode segmented entry,
  paste, creator cross-link) — unrelated to this guard, delivered and closed
  under STORY-047 itself.

## Open Questions
- Which of the two resolution paths above (alternate copy vs. ADR amendment)
  — for Product Owner/UI-UX Designer to decide during story breakdown, citing
  ADR-002's original rationale before proposing a change. The ruling must
  explicitly state whether it applies uniformly to both tokens (`Do Not
  Disturb` and `Synced Alarm`) or differently to each.

## User Stories
(Not yet split. Product Owner begins story breakdown when this requirement
is picked up by `continue`.)
