# Requirement Master: REQ-011 Zodiac Red Flag content + Home quick-grid completion
Status: PENDING

## Deployment Status
- Development Environment: NOT_DEPLOYED
- Staging: NOT_REQUESTED
- Production: NOT_REQUESTED

## Configuration Documentation
- Source of Truth: `deployment/configuration-guide.md`
- Status: NOT_REQUIRED
- Pending User Setup: NONE
- Last Updated:

## Source

Direct user request (2026-08-25), following up on
`BUG-20260825-001_home_screen_design_mismatch` /
`REQ-010_home_dashboard_deferred_scope_completion`. REQ-010 delivered 6 of 7
scope items (anti-ghost banner, vibe-check card, pet preview card, header
share/notifications actions, couple title, `--sky` backdrop) but explicitly
parked Item 2 (Home dashboard 2-column quick grid) because it depends on
`STORY-023_zodiac_red_flag_design_fidelity`
(`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-023_zodiac_red_flag_design_fidelity/`),
which is `Status: DEFERRED` with no built screen — the design's quick-grid
tile needs a real Zodiac Red Flag feature to link to, not just a static tile.

User confirmed (2026-08-25) they want this shipped as a complete, end-to-end
feature: "hoàn chỉnh, bao gồm cả dữ liệu và giao diện, cả backend" (complete,
including data, UI, and backend) — not just a UI stub.

## Scope

1. **Zodiac Red Flag screen — full feature.**
   - Per-sign-pair "conflict index" content: for a couple's two zodiac signs,
     surface a compatibility/conflict-risk reading.
   - Daily tip content: a rotating/daily piece of content tied to the
     couple's sign pair (mechanism TBD by Product Owner — e.g. deterministic
     per-day pick from a curated content table, not necessarily generative).
   - Backend: data model + storage for zodiac sign pairs, conflict-index
     content, and daily-tip content; an endpoint/contract the mobile app
     reads from.
   - Mobile: the Zodiac Red Flag screen itself (entry point from the Home
     quick-grid tile), rendering the conflict index and today's tip against
     the existing design system.
2. **Home dashboard 2-column quick grid — completion.**
   - Add the `Zodiac Red Flag` tile alongside the existing `Synced Alarm`
     tile so the quick grid matches the design's 2-column layout
     (`Cupid Screens.dc.html` Home node).
   - Wire the tile to the new Zodiac Red Flag screen from Scope Item 1.

## Out of Scope

- Re-litigating or re-scoping `Synced Alarm`, the presence row, counter, hero
  caption, milestone pill, card rhythm, or tab-bar styling — already
  delivered and design-matched.
- Any other REQ-010 deferral (anti-ghost banner, vibe-check card, pet
  preview card, header actions, couple title, `--sky` backdrop) — all
  already `DONE`.
- Deciding the exact content-authoring pipeline / editorial process for
  daily tips beyond what Product Owner scopes as MVP; that decision belongs
  to story breakdown, not this requirement master.

## Open Questions For Product Owner

- OQ: What is the MVP content source for per-sign-pair conflict index and
  daily tips — a static curated table shipped with the app/backend, or an
  admin-authored content system? `STORY-023`'s own deferral notes flagged
  "daily-tip content source" as an open product decision.
- OQ: Is personalization limited to the couple's two known zodiac signs
  (already captured elsewhere in profile data, if so), or does this
  requirement also need to collect/confirm zodiac sign as new profile
  input?

## User Stories
| ID | Title | Complexity | Status | Path |
|----|-------|------------|--------|------|
