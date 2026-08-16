# Requirement Master: REQ-003 App Shell Five-Tab Navigation & FAB Consolidation
Status: PENDING

## Source Request
Not user-typed prose. Raised as finding **E-1** in REQ-002's Round 2
requirement-integration-review (Iris-QC,
`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/integration-review/review-report.md`,
"Decisions Required — Not Mine To Make"), then routed to the user directly by
Scrum Master via `AskUserQuestion` on 2026-08-16. User selected: **"Open a new
app-shell/navigation story."**

## Business Context
The locked design (`cupid-app-design-system`, app shell canvas) specifies 5
bottom-tab destinations: Nhà, Trò chuyện, Pet, Ví chung, Tôi. The shipped
`app_shell.dart` (delivered under REQ-001/REQ-002) instead ships ≤3 tab
destinations plus a separate pink circular Floating Action Button that does
not appear on the design canvas at all.

Iris-QC's Round 2 review assessed this as one coupled decision, not two: the
FAB currently appears to be the app's sole entry point to the account hub,
which is the same destination the design's missing 5th "Tôi" tab represents.
`expenses_route.dart:14-19` already carries a code comment acknowledging the
5-tab shell as a recognised, unlanded item — this is not a fresh discovery,
just the first time it has been raised as an explicit scope decision.

The user has decided this divergence should be corrected rather than
accepted, via a new story rather than as an unowned side effect of REQ-002.

## Scope
- Audit `app_shell.dart` (current tab destinations, current FAB) against the
  locked design's 5-tab bottom navigation canvas.
- Add the missing tab destination(s) so the shell matches the design's 5
  destinations (Nhà/Trò chuyện/Pet/Ví chung/Tôi).
- Reconcile the existing FAB with the "Tôi"/account-hub destination — most
  likely removing the FAB in favor of the 5th tab, but the exact mechanism
  (remove vs. repurpose vs. keep as a shortcut to the same destination) is a
  UX decision for Product Owner / UI-UX Designer to make during story
  breakdown, not pre-decided here.
- Do not touch other REQ-001/REQ-002 screens outside the app shell/tab-bar
  composition itself unless the tab change requires route wiring changes.

## Out of Scope
- REQ-004 (notifications DND banner copy reconciliation) — separate,
  unrelated requirement from the same review round.
- Any other Round 2 deferred/blocking findings tracked in REQ-002's own
  `req_master.md` Deferred Follow-Up Items or bug registry.

## Open Questions
- Exact FAB disposition (remove entirely vs. repurpose as a quick-action
  shortcut that still routes to the same "Tôi" destination as the 5th tab) —
  for Product Owner/UI-UX Designer during story breakdown.

## User Stories
(Not yet split. Product Owner begins story breakdown when this requirement
is picked up by `continue`.)
