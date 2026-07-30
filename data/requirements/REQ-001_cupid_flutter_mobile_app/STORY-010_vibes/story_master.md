# Story Master: STORY-010 Epic-3 — Vibes / Cảm Xúc Hằng Ngày

Status: PENDING
Complexity: S
Epic: epic-3 (daily engagement)
Story-Class: standard
Requirement: REQ-001
Backend module: `backend/src/modules/vibes/`
Design reference: `cupid-mobile-design/` — daily engagement/mood screen group
(exact screen ids to be confirmed by UI/UX Designer).

## Depends On
- STORY-001, STORY-002, STORY-003. Tech Lead to confirm whether this needs
  STORY-004 (realtime) or is fine as request/response only.

## User Story
As a paired user, I want to share a quick daily mood/vibe with my partner so
we stay emotionally in sync even on busy days.

## In Scope
- Setting/sharing a daily vibe/mood entry.
- Partner viewing the other's shared vibe.

## Out of Scope
- Any `vibes` endpoint change (A1 frozen).

## Acceptance Criteria
1. A paired user can set/share a vibe entry.
2. The partner can view the shared vibe.
3. Unpaired users cannot access this feature.

## Open Items For Downstream Roles
- ~~Tech Lead: confirm whether vibe updates need live realtime delivery
  (STORY-004 dependency) or are acceptable as pull/refresh-based.~~
  RESOLVED 2026-07-30 (D-010-1): pull/refresh only, **no STORY-004 dependency**.
  The backend has no vibes gateway or vibe event name, and STORY-004 restricts
  `RealtimeEvent.name` to the frozen `CHAT_EVENTS`/`ALARM_EVENTS` values, so a
  realtime subscription here would be permanently silent.

## Architecture Pass (2026-07-30)

- [x] Architecture (Tech Lead)
- Architecture solution: `architecture/solution.md` (story-scoped decisions
  D-010-1 … D-010-6; promoted to system ADR numbers at requirement integration
  to avoid collision with the other stories in this parallel wave).
- Coding plan: `coding-plan/master-plan.md` with phases P0-P4 (P4 verification).
- Implementation shape: **mobile lane only**. Backend `vibes` module consumed
  unchanged (A1); no frontend or DevOps participation.
- Configuration guide: NOT REQUIRED (no env var, secret, dependency, or
  third-party integration change).
- Decisions that close UX open items: nudge CTA ships decorative-only (D-010-4,
  no non-new-endpoint mechanism exists); `GET /vibes/today` is authoritative for
  "my today" while both history strips use `days=8` and client local-date
  bucketing (D-010-3); feature-local copy instead of a shared ARB edit (D-010-6).
- Pending Product Owner confirmations, both non-blocking with a backend-accurate
  default: A-1 drop the `soft` mood cell (5-cell grid, `spicy → horny`), A-2 ship
  accurate "7 ngày gần nhất" strip copy instead of the "auto-deleted in 30d"
  claim the backend does not implement.
- Escalation for Scrum Master — **R-010-1**: AC3 ("unpaired users cannot access
  this feature") depends on the app-level paired route gate, which does not exist
  at this story's BaseHead (`AppShell` boots straight into the placeholder
  `HomeScreen`). UX §7 forbids a screen-level guard as the primary control, so
  AC3 must be verified at requirement integration once the gate lands. This story
  owns only the defensive path: an empty partner history renders the existing
  waiting/`none` state instead of an error.

## Mobile Implementation Pass

- [x] P0 — Vibes Domain And Data Contract (Mobile Developer), DONE 2026-07-30.
  `VibeMood` (5-value wire mapping, `spicy → horny`, unknown-value skip),
  `VibeEntry.fromJson`, and `VibesRepository` (`fetchMyToday`,
  `fetchMyHistory`, `fetchPartnerHistory`, `submitMood`, `bucketByLocalDay`)
  implemented per `architecture/solution.md` §2/§4 D-010-2/D-010-3. Evidence:
  `coding-plan/phase-P0-vibes-domain-data.md` §7. 15/15 targeted tests pass,
  `flutter analyze` clean for touched files, `test/core/network` regression
  (8/8) still passes.
- [x] P1 — `VibeCubit` + `VibeState` (Mobile Developer), DONE 2026-07-30.
  Optimistic `pick` overlay, DI wiring. Evidence:
  `coding-plan/phase-P1-vibe-cubit.md` §7.
- [x] P2 — Vibe Presentation Widgets And Copy (Mobile Developer), DONE
  2026-07-30. `VibeMoodFace`, `VibeMoodGrid` (5-cell, 3+2 centered layout),
  `PartnerVibeCard` (waiting state + 4 nudge copy variants + decorative-only
  CTA per D-010-4), `VibeHistoryStrip` (7-day, accurate "7 ngày gần nhất" /
  "last 7 days" header per A-2), and `VibeLocaleText` (`vibe_strings.dart`)
  implemented per `architecture/solution.md` §4 D-010-4/D-010-6 and
  `ux/uiux-spec.md` §3/§5/§6/§8/§9. No new design token, no platform fork, no
  `mobile/lib/l10n/**` change. Evidence: `coding-plan/phase-P2-vibe-widgets.md`
  §7 — `flutter analyze` clean for touched files, 66/66 targeted tests pass
  (`test/features/vibes` + `test/design_system`), no regression in
  `no_fork_guard_test.dart` / `theme_matrix_test.dart`.
- [ ] P3 — Vibe screen entry point (next).
