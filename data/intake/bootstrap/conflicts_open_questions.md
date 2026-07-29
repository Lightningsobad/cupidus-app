# Conflicts And Open Questions

## Resolved Conflicts (carried forward for traceability only)

- **Client platform**: `_bmad-output/planning-artifacts/architecture.md`
  specified a native iOS (SwiftUI) client. This is SUPERSEDED by decision D0
  (2026-07-29, `idea.md`): the client will be built in Flutter for iOS +
  Android. Not a live conflict — resolved by explicit, dated user decision.
  Tech Lead should cite D0 rather than reconciling the two documents.

## Resolved Open Questions

- **OQ4 — Offline storage strategy — RESOLVED (ADR-007,
  `data/architecture/system/system_architecture_memory.md`)**: Drift for
  chat/timeline/expenses, `hydrated_bloc` for ephemeral state only. Bounded:
  Drift is a read-through, server-authoritative cache; **no offline
  write/outbox queue in v1**, because the backend has no idempotency key,
  client message id, or dedupe field anywhere, so a replay queue cannot be
  made duplicate-safe without a backend change (which A1 forbids).

## Open Questions (unresolved, blocking-relevant scope only)

- **OQ5 — Light theme & English (EN) locale in v1?** Design assets cover both
  dark/light and VI/EN. Working assumption: build token + ARB infrastructure
  for all 4 combinations now, but only *enable* dark + `vi` at v1 launch.
  Product Owner must confirm this scope decision when breaking down the
  `design_system` story (first shared-foundation story).

## Assumptions Currently Carrying The Flow

- Backend contract is frozen (A1) — no story in this requirement may request
  a backend endpoint change without escalation.
- `cupid-mobile-design/` is authoritative and read-only; deviations require a
  UX decision, not silent implementation choices.
- Repository root has zero commits; an initial commit must happen as part of
  the Runnable Project Foundation gate before any story worktree/branch work
  can start (git-story-boundary tooling requires a `BaseHead` sha).

## Decisions Still Needed From The User

- **R8 — Backend Socket.IO auth gap (raised by Tech Lead system-foundation
  pass, non-blocking for bootstrap)**: `backend/src/modules/messages/chat.gateway.ts:39-57`
  — `handleConnection` performs no auth check, and `JOIN_ROOM` joins whatever
  `userId` the client supplies. Any client can currently impersonate any user
  and read their chat over the socket gateway. The client cannot fix this
  (backend contract A1 is frozen); Tech Lead's ADR makes the client forward-
  compatible by sending the Firebase token in `handshake.auth.token` now, but
  the actual backend fix requires a decision: escalate to the backend team
  before epic-2 (chat) reaches production, accept the risk for a
  private-beta/limited-user v1, or something else. Not required to unblock
  foundation/bootstrap work; must be resolved before epic-2 chat ships to
  production.
- **D1/Critical-Alerts copy conflict (raised by UI/UX Designer system-foundation
  pass, non-blocking for bootstrap)**: the raw design source's Notifications
  screen copy says "Chỉ Synced Alarm được phép phá Do Not Disturb" (only
  Synced Alarm may break Do Not Disturb) — this implies a Critical Alerts-class
  entitlement, which directly conflicts with D1 (no Critical Alerts in v1).
  Default/safe direction consistent with D1: Product Owner scopes this copy
  out of v1 (remove the DND-override claim) rather than requesting the
  entitlement; escalate to the user only if PO believes the DND-override
  behavior is actually required for v1. To resolve during the
  `design_system`/epic-3 story breakdown, not a bootstrap blocker. Confirmed
  independently by Tech Lead (ADR-002): the backend module/gateway name
  `alarms`/`TRIGGER_ALARM` can stay as transport naming; only user-facing copy
  needs the "nhắc nhở đồng bộ" rename.
- **Nginx VPS-target ambiguity (raised by DevOps system-foundation pass,
  relevant to the Deployment Foundation User Confirmed gate)**:
  `backend/nginx/default.conf` has `server_name api-cupid.tikup.me`, and
  `backend/docker-compose.yml` uses fixed prod-style host ports. This looks
  like a pre-existing VPS deployment target, but there is no record of who
  owns `api-cupid.tikup.me` or whether it is still live. DevOps has
  explicitly NOT adopted this as a confirmed staging/production target. User
  must confirm: is this a real, currently-owned VPS target to keep as a
  future `Deploy lên VPS` reference, or legacy/unused and safe to ignore?
- **BLOCKING — `backend/` is a separate git repository with real remote
  history, discovered by Scrum Master during the Runnable Project Foundation
  gate's initial-commit step (git plumbing inspection, not source review)**:
  `backend/.git` is a fully independent repo, branch `main`, remote
  `origin -> https://github.com/hoak57uet/cupid-backend.git`, 6 commits. One
  commit message is `"build: Add Firebase service account key to Docker
  image for application startup"` — this strongly suggests a Firebase
  service-account credential was committed into `backend/`'s own git history
  at some point, independent of whatever file currently sits at
  `backend/service-account.json` on disk today (confirmed present on disk,
  content NOT read/inspected). This blocks the repo-root initial commit
  because: (a) `git add backend/` from repo root will create a broken gitlink
  (submodule reference with no `.gitmodules` entry) rather than tracking
  backend's files, breaking `git-story-boundary.sh` diffing/worktree tooling
  for any backend story; (b) folding backend's working tree into the new
  root repo's history must not also import a possibly-secret-containing
  history without an explicit user decision. This is a genuine "which
  strategy" decision, not something Scrum Master should default silently.
  Options to put to the user: (1) fold `backend/` as regular tracked files in
  the new root repo (drop `backend/.git`, keep the current working tree only,
  do not import backend's separate commit history, leave the GitHub remote
  itself untouched/unpushed); (2) keep `backend/` as a git submodule pointing
  at the existing GitHub remote; (3) exclude `backend/` from root git
  tracking entirely. Recommended default if the user has no strong
  preference: option (1), since delivery tooling (git-story-boundary.sh,
  story worktrees/diffs) requires backend files to be normal tracked files
  in the root repo, and the existing GitHub remote is untouched either way.
  Regardless of which option is chosen, `backend/service-account.json` (and
  any other credential file) must be excluded via `.gitignore` before any
  root commit that touches `backend/`.
- No other item is material enough to block bootstrap seeding or foundation
  synthesis at this time. OQ5 is deferred to Product Owner story breakdown
  per the working assumption above, consistent with `req_master.md`.
