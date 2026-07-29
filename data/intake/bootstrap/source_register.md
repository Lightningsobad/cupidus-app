# Source Register

Inventory of raw sources discovered during bootstrap normalization for
Cupid Apps. This project is brownfield: a NestJS backend is already built and
a Flutter mobile client is the requested new runnable surface (REQ-001).

| # | Source | Type | Coverage | Authority / Trust |
|---|--------|------|----------|--------------------|
| S1 | `data/brainstorms/IDEA-20260729-001_cupid-flutter-mobile-architecture/idea.md` | Brainstorm decision doc | Business scope, D0-D5 architecture decisions, epics-to-screens mapping | Authoritative — explicit user-confirmed decisions dated 2026-07-29, latest direction |
| S2 | `data/brainstorms/IDEA-20260729-001_cupid-flutter-mobile-architecture/development.md` | Brainstorm convergence log | Risk table (R1-R7), PMI notes, Open Questions OQ4/OQ5 | Authoritative for risk/OQ framing |
| S3 | `data/requirements/REQ-001_cupid_flutter_mobile_app/req_master.md` | Seeded requirement master | Normalized problem/value, in/out of scope, D0-D5 table, risks, OQ4/OQ5, foundation order | Authoritative — already reconciles S1/S2; downstream roles should read this first |
| S4 | `backend/` (NestJS app, own nested `.git`) | Existing implemented backend source | ~59 REST endpoints, 2 Socket.IO gateways, Firebase Auth, Swagger at `/api-docs` (`backend/src/main.ts`), `backend/src/modules/` | Authoritative, frozen contract per decision A1 (req_master.md) — client must not require backend contract changes |
| S5 | `docs/backend/backend/epic-{1..6}-*.md` | Backend epic documentation | Per-epic backend behavior docs matching epic-1..epic-6 | Authoritative supporting detail for backend contract; secondary to live Swagger/source |
| S6 | `cupid-mobile-design/` (`Cupid Screens.dc.html`, `Cupid App.dc.html`, `android-frame.jsx`, `ios-frame.jsx`, plus icon/sprite assets) | UI prototype / design source | ~31 screens, iOS + Material variants, dark + light, VI + EN | Authoritative, read-only design source per req_master.md ("không sửa"/do not edit) |
| S7 | `_bmad-output/planning-artifacts/architecture.md` | Prior (BMAD-era) architecture doc | Original client architecture (iOS Native Swift/SwiftUI) | SUPERSEDED for client per D0; backend-relevant sections may still be useful background only |
| S8 | `_bmad-output/planning-artifacts/prd.md`, `product-brief-cupid-2026-02-13.md`, `epics.md`, `ux-design-specification.md`, `implementation-readiness-report-2026-02-13.md` | Prior BMAD planning corpus | Original product brief, epics, UX spec, readiness report | Background/history only. Superseded where it conflicts with S1-S3 (client platform, sequencing). Not re-read in full during bootstrap; downstream roles query only if a specific gap appears. |
| S9 | `_bmad-output/implementation-artifacts/*.md`, `sprint-status.yaml` | Prior BMAD story-level artifacts (1-1..4-4) | Legacy per-story specs from the pre-Flutter effort | Historical reference only; do not treat as current story backlog. Official backlog is `data/requirements/master_requirements_list.md`. |
| S10 | `_bmad-output/brainstorming/brainstorming-session-2026-02-13.md` | Prior brainstorming session | Early idea exploration | Historical background only |

## Notes

- No conflicting *platform* direction exists once S1-S3 (2026-07-29, latest)
  are treated as authoritative over S7 (superseded client architecture).
- The backend (S4) is a separately git-initialized project nested under
  `backend/`. The control repository root (`cupid-apps`) has **zero commits**
  as of bootstrap start — this is a runnable-foundation gap, not a content gap.
- No existing mobile app project exists yet. `cupid-mobile-design/` is
  prototype/reference only (HTML/JSX mockups), not a Flutter codebase.
