# Requirement Master: REQ-002 Screen Flow Correction & Design Fidelity Audit
Status: PENDING

## Source Request (verbatim, Vietnamese)
> Thêm 1 yêu cầu mới bao gồm:
> 1. Điều chỉnh lại các màn hình theo đúng các flow của app, ví dụ hiện tại
>    đang không phải màn đăng nhập khi vào ứng dụng này.
> 2. Rà soát song song toàn bộ các màn hình để điều chỉnh đúng như design,
>    yêu cầu khớp 100% (mỗi màn hình là 1 story).

## Business Context
The Cupid Flutter mobile app (REQ-001) is DONE, but the user has identified
two live defects/gaps against the intended product experience:

1. **App navigation/flow correctness** — the screens users land on do not
   follow the correct app flow. Concrete example given by the user: the
   screen shown when opening the app is not the login screen, when it should
   be. This scope covers auditing and correcting entry-point routing and
   inter-screen navigation so the app flow matches the intended user journey
   (e.g., correct initial route, correct screen-to-screen transitions per the
   product flow).
2. **Design fidelity, 100% match, across every screen** — a full re-audit of
   every screen in the app against the locked design source
   (`cupid-app-design-system`, per `detect_design_source.py`), correcting any
   visual/layout/spacing/component deviation until each screen matches the
   design exactly. This is broader than a spot-check: it must cover the
   entire current screen inventory.

This requirement is distinct from REQ-001's prior retro-audit hardening cycle
(STORY-017..STORY-021), which closed the design-fidelity capture gap that
existed at that time (37/37 screens captured, 3 code-fix hardening stories
delivered, REQ-001 closed DONE 2026-08-12). REQ-002 is a new, user-initiated
pass requested after that closure and must not assume the prior cycle's
findings still hold — it re-verifies flow correctness and design match from
current app state.

## Scope

### A. Screen Flow / Navigation Correction
- Audit the app's actual entry point and inter-screen navigation against the
  intended product flow (per UX/System UX Memory and the app's own flow
  definitions).
- Fix any screen/route that does not match the correct flow. Confirmed
  example: initial app launch must route to the login screen (currently does
  not).
- Story splitting for this part is normal Product Owner judgment (may be one
  story or a few, grouped by flow/navigation area) — it is NOT subject to the
  one-screen-per-story rule below.

### B. Full Design Fidelity Audit (100% match required)
- Re-audit **every** current screen in the app against the locked design
  source, screen by screen, and correct any deviation found.
- Acceptance bar is exact match ("khớp 100%") to the design source, not a
  best-effort approximation.
- **Story splitting directive (explicit user instruction): one story per
  screen.** Product Owner must enumerate the current full screen inventory
  and create exactly one story per screen for this part of the requirement,
  so each screen's design-fidelity correction can be reviewed and delivered
  independently.
- User explicitly requested this part run as a **parallel** review/delivery
  effort across screens (`rà soát song song toàn bộ các màn hình`). Route
  execution of this requirement through `continue parallel` /
  `parallel-continue.md` rather than the ordinary single-story-at-a-time
  flow, once stories exist.

## Deployment Status
- Development Environment: NOT_DEPLOYED
- Staging: NOT_REQUESTED
- Production: NOT_REQUESTED

## Configuration Documentation
- Source of Truth: `deployment/configuration-guide.md`
- Status: NOT_REQUIRED
- Pending User Setup: NONE
- Last Updated:

## User Stories
| ID | Title | Complexity | Status | Path |
|----|-------|------------|--------|------|
