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

## Out of Scope
- REQ-003 (app shell five-tab navigation) — separate, unrelated requirement
  from the same review round.
- Any other Round 2 deferred/blocking findings tracked in REQ-002's own
  `req_master.md` Deferred Follow-Up Items or bug registry.

## Open Questions
- Which of the two resolution paths above (alternate copy vs. ADR amendment)
  — for Product Owner/UI-UX Designer to decide during story breakdown, citing
  ADR-002's original rationale before proposing a change.

## User Stories
(Not yet split. Product Owner begins story breakdown when this requirement
is picked up by `continue`.)
