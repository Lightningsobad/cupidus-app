# Requirement Master: REQ-003 App Shell Five-Tab Navigation & FAB Consolidation
Status: DONE

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
  **RESOLVED, see Resolution below: removed entirely, no shortcut.**

## Resolution (2026-08-20, Product Owner)

Closed as already-delivered. This requirement's entire stated Scope was
shipped under `STORY-061_dream_jar_list_design_fidelity_hardening`
(REQ-002 retro-hardening, Status: `DONE`, Reviewer Round 3
`Outcome: DEFERRED_ONLY`, 0 blocking findings, merged to `main`) via its
AC8 ("Shell tab-bar shape") and Product Owner Decision 1 ("Gallery
entry-point relocation") in that story's `story_master.md`. Verified
directly against live code and STORY-061's own artifacts, not just against
Scrum Master's summary:

- **`mobile/lib/core/navigation/app_shell.dart` (current `main`, read in
  full)** builds exactly 5 shell destinations in order — Nhà (Home),
  Trò chuyện (Chat, gated by `ChatEntryGate`), Pet, Ví chung (Dream Jar
  list), Tôi (Me/account hub via `MeScreen`) — matching the design canvas's
  5-tab shape 1:1. The `Scaffold` has no `floatingActionButton`; the FAB is
  gone from the shell entirely, not repurposed as a shortcut.
- **STORY-061's `requirements/requirements.md` AC8** states verbatim: "The
  bottom tab bar matches the design's 5-tab shape (Nhà / Trò chuyện / Pet /
  Ví chung / Tôi)... replacing the current 3-tab-plus-separate-account-FAB
  shape" — this is REQ-003's Scope stated as an acceptance criterion,
  verified via AC9's mandatory design-reference-conformance method (fresh
  `implemented-jarlist-*`/`design-reference-jarlist-*` evidence pair,
  Reviewer AC-by-AC verdict, not id-match alone).
- **STORY-061's `story_master.md` "Decision 1 — Gallery entry-point
  relocation" (APPROVED)** already resolved the one adjacent risk REQ-003's
  Scope flagged ("do not touch other screens... unless the tab change
  requires route wiring changes"): removing the old 3-tab-plus-FAB shape
  to ship the 5-tab shape would have orphaned the shipped Gallery feature's
  only entry point, so Tech Lead/Mobile Developer added a Gallery entry
  card to `HomeScreen` in the same phase. This was itemized, PO-approved,
  and reviewed inside STORY-061 — not a gap left for REQ-003.
- **Reviewer's 5 deferred findings (D1-D5)** in STORY-061's
  `review/review-report.md` are all Dream Jar illustration/glyph/pill
  styling and one repo-hygiene item (design-source directory drift); none
  concerns the tab bar, the FAB, or the account-hub entry point. No
  remaining gap against REQ-003's Scope was left open or deferred.

No part of REQ-003's Scope is uncovered. No new story is opened.

## User Stories
N/A — fully covered by `STORY-061_dream_jar_list_design_fidelity_hardening`
(REQ-002). See Resolution above.
