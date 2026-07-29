# Story Master: STORY-008 Epic-2 — Anti-Ghosting Configuration

Status: PENDING
Complexity: S
Epic: epic-2 (communication)
Story-Class: standard
Requirement: REQ-001
Backend module: `backend/src/modules/ghost-config/`
Design reference: `cupid-mobile-design/` — chat/settings screen group (exact
screen ids to be confirmed by UI/UX Designer).

## Depends On
- STORY-001, STORY-002, STORY-003, STORY-004 (realtime signal for
  ghosting detection). Soft dependency on STORY-007 (chat is where
  ghosting is detected/surfaced).

## User Story
As a paired user, I want the app to help detect and surface when my partner
has gone quiet ("ghosting") per our agreed configuration, so silence doesn't
get misread as something worse.

## In Scope
- Configuring anti-ghosting thresholds/behavior per the `ghost-config`
  backend contract.
- Surfacing the anti-ghosting state/signal in the chat experience.

## Out of Scope
- Any `ghost-config` endpoint change (A1 frozen).
- The typing-ghost indicator itself (that's part of STORY-007's realtime
  chat scope) — this story is about ghosting *detection/config*, a distinct
  backend module.

## Acceptance Criteria
1. A paired user can view/set anti-ghosting configuration options exposed by
   the backend contract.
2. The configured anti-ghosting state is visibly surfaced somewhere in the
   chat experience (exact placement per UI/UX Designer).
3. Unpaired users cannot access this configuration.

## Open Items For Downstream Roles
- UI/UX Designer: confirm exact screen/placement for the anti-ghosting
  signal relative to STORY-007's chat screens.
