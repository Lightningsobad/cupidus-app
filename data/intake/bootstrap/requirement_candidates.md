# Requirement Candidates

## Already Seeded

| Candidate | Status | Requirement | Source |
|-----------|--------|-------------|--------|
| Cupid Flutter mobile app (iOS + Android) | SEEDED | REQ-001 | `data/brainstorms/IDEA-20260729-001_cupid-flutter-mobile-architecture/idea.md` |

REQ-001 was already created via the direct single-requirement intake path
(`data/requirements/REQ-001_cupid_flutter_mobile_app/req_master.md`,
registered in `data/requirements/master_requirements_list.md`) before this
bootstrap run started. No re-seeding is needed; `Official Backlog Seeded` can
be marked true in `bootstrap_master.md` without a fresh Product Owner
delegation.

## No Other Candidates Identified

The available sources (S1-S10 in `source_register.md`) describe one coherent
initiative: ship the Flutter mobile client against the existing frozen
backend and existing design. The legacy `_bmad-output/` corpus (S7-S10)
describes the superseded native-iOS effort and its own story set; those are
historical background, not additional candidate requirements, since REQ-001's
scope (screens grouped by epic-1..epic-6) already supersedes them under D0.

No batch-splitting is required — this is already a single, narrow, coherent
requirement.
