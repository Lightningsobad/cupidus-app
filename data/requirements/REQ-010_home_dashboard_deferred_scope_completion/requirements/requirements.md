# Requirement Breakdown: REQ-010 Home Dashboard Deferred Scope Completion

## Source Artifacts

- Requirement master: `data/requirements/REQ-010_home_dashboard_deferred_scope_completion/req_master.md`
- Source bug: `data/bugs/BUG-20260825-001_home_screen_design_mismatch/bug_master.md`
  (`ESCALATED_TO_BACKLOG`)
- Owning prior story (deferral source):
  `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-017_home_dashboard_design_fidelity/`
  (`visual-fidelity/visual-fidelity-report.md`, `review/review-report.md`,
  finding `B5`, `Outcome: DEFERRED_ONLY`)
- Blocking prior story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-023_zodiac_red_flag_design_fidelity/story_master.md`
  (`Status: DEFERRED`)
- Already-shipped reuse targets read as context (not modified here):
  `mobile/lib/features/home/presentation/home_screen.dart`,
  `mobile/lib/features/anti_ghosting/`, `mobile/lib/features/vibes/`,
  `mobile/lib/features/pet/presentation/widgets/pet_preview_card.dart`,
  `mobile/lib/features/account/presentation/screens/notification_settings_screen.dart`
  (REQ-002 `STORY-031`, `Status: DONE`),
  `mobile/lib/features/pairing/presentation/screens/invite_screen.dart`
  (share-sheet pattern precedent)

## Context Summary

- Request summary: a user report that the Home screen is "completely wrong"
  vs. design was diagnosed as not a regression — the region owned by
  `STORY-017_home_dashboard_design_fidelity` still matches the design. The
  remaining perceived mismatch is the set of surfaces `STORY-017` itself
  excluded from its comparison region and recorded as deferrals (finding
  `B5`): 3 already-mounted Home feature widgets not yet checked for visual
  fidelity, a not-yet-built 2-column quick grid, 2 not-yet-built header
  actions, an incomplete couple/partner title, and a not-yet-implemented
  global screen backdrop.
- Primary actors: paired Cupid app end users viewing the Home dashboard.
- Problem to solve: close the specific, named `STORY-017` deferrals so the
  Home dashboard (and, for the `--sky` backdrop, every screen) matches the
  locked design source.
- Business outcome: Home dashboard feature widgets, header actions, and
  couple identity display match the design; the app's global visual theme
  (`--sky` backdrop) is consistent everywhere.
- Success signal: each deferral finding (F3, F4, F6, F10) is either closed
  by a delivered story or explicitly parked with a stated blocker (F6's
  quick-grid Zodiac Red Flag tile).
- Notes on current project context: this requirement closes deferrals from
  an already-`DONE` requirement (`REQ-002`); `REQ-002` and `STORY-017`
  artifacts are read-only input, not modified here except where a story
  below explicitly extends already-shipped code.

## Scope Decision

### In Scope

- Design-fidelity correction of 3 already-mounted Home dashboard widgets
  (anti-ghost alert banner, vibe-check card, pet preview card) against the
  locked design source, dark theme + `vi` locale (STORY-001, STORY-002,
  STORY-003).
- Two new Home dashboard header entry points: share the days-together
  milestone, and quick access to the existing Notifications/preferences
  screen (STORY-004, STORY-005).
- A partner-profile backend surface and mobile display so the couple title
  reads both partners' names (STORY-006).
- The `--sky` global screen backdrop as a shared theme primitive applied
  across every screen (STORY-007).

### Out of Scope

- The presence row, `247` counter, hero caption, milestone pill, card
  rhythm, and tab-bar styling already delivered and design-matched by
  `STORY-017` (per `req_master.md`).
- Re-litigating `STORY-023 Zodiac Red Flag`'s own deferral.
- The 2-column quick grid (`Synced Alarm` + `Zodiac Red Flag` tiles) — see
  `req_master.md` "Product Owner Story Breakdown Decision". Blocked on a
  future requirement to scope and build the Zodiac Red Flag screen; no
  single-tile substitute is opened as a story.
- Any new notifications inbox/feed. The governing design's "notifs" screen
  is the preferences screen `STORY-031` already shipped; STORY-005 only
  adds a Home entry point to it.
- Underlying feature logic already shipped elsewhere (anti-ghosting flow,
  vibe-check submission, pet gameplay, notification preference toggles,
  profile editing) — these stories touch only the Home dashboard surface
  named in each story's scope.

### Business Rules And Guardrails

- Design source for every story: `cupid-app-design-system` (locked,
  confirmed by prior `detect_design_source.py` runs in `REQ-002`), enabled
  dark theme + `vi` locale configuration only, matching the precedent set
  by every closed `REQ-002` design-fidelity story.
- STORY-006 must degrade honestly when partner-profile data is unavailable
  (no fabricated partner name), matching the precedent already set by
  `STORY-017`'s own current degraded rendering.
- STORY-007 must not alter any screen's foreground content, layout, or
  component-level design-fidelity — it adds a shared backdrop layer only.

## Seed To Story Mapping

No discovery `## Story Seeds` table exists for this requirement — it
originates directly from a bug escalation whose scope items were already
authored as explicit, named STORY-017 deferral findings (`req_master.md`
"Scope For Product Owner / UI-UX / Tech Lead"), not from a repository-recon
seed pass. See `req_master.md` "Product Owner Story Breakdown Decision" for
how the 5 recommended scope items map to the 7 stories opened here (items 1
and 3 each split into 3 and 2 stories respectively by distinct user
outcome; item 2 is parked, not opened).

## Coverage Map

| Req scope item | Deferral finding | Story | Disposition |
|---|---|---|---|
| 1. Anti-ghost alert banner | F3 | STORY-001 | Story |
| 1. Vibe-check card | F6 | STORY-002 | Story |
| 1. Pet preview card | F6 | STORY-003 | Story |
| 2. 2-column quick grid | F6 | — | Parked (blocked on STORY-023) |
| 3. Header share action | F3 | STORY-004 | Story |
| 3. Header notification action | F3 | STORY-005 | Story |
| 4. Partner name / couple title | F4 | STORY-006 | Story |
| 5. `--sky` global backdrop | F10 | STORY-007 | Story |

## Open Questions

NONE. No Open Question registry exists yet for this requirement; none of the
7 stories opened here carry an unresolved product decision — each reuses an
already-shipped target (anti-ghosting screen, vibe screen, pet feature,
Notifications screen, share pattern) or is fully specified by the locked
design source (`--sky` token, couple-title format). The only open item
(Zodiac Red Flag content/personalization model) belongs to STORY-023's own
future-requirement recommendation, not to this requirement's OQ set.
