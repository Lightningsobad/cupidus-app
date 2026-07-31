# 010_vibes-solution.md

## 0. Metadata

- User Story ID: STORY-010 (Epic-3 — Vibes / Cảm Xúc Hằng Ngày)
- Requirement: REQ-001_cupid_flutter_mobile_app
- Complexity: S / Story-Class: standard
- Lane: Mobile only (no backend, frontend, or DevOps participation)
- Context Mode: Brownfield (extends the landed mobile core: `CupidApi`, `CupidApiFailure`, design-system tokens, `service_locator`)
- Branch Action: none (system baseline reliable for this scope)
- Decision ids in this document are story-scoped (`D-010-*`) and are promoted to
  system `ADR-*` numbers at requirement integration, to avoid ADR-number
  collision with the other stories running in this parallel wave.

## 1. Decision Summary

- Direction: a self-contained `features/vibes/` slice (domain → data → cubit →
  presentation) over the already-frozen `vibes` REST module, pull/refresh only.
  No realtime, no local database, no shared-file redesign.
- Drivers: AC1-AC3, A1 (backend frozen), D2 (Cubit for CRUD screens), OQ4
  (Drift is scoped to chat/timeline/expenses, not vibes), UX §3 mood mismatch,
  UX §5 CTA gap, UX §6 copy gap, parallel-wave shared-file contention.
- Resolved this run: STORY-004 is **not** a dependency (D-010-1); the nudge CTA
  ships decorative-only (D-010-4); the 5-value mood set with `spicy → horny`
  is the wire contract (D-010-2).

## 2. Downstream Contract Summary

Authoritative for this story's mobile phases. Backend consumed unchanged.

- REST surface (all four generated methods return `Response<void>` because the
  Swagger declares no response schema, so bodies are unreachable through the
  generated `Epic3DailyVibeCheckApi`). Follow the landed STORY-003 precedent in
  `mobile/lib/features/auth/data/auth_repository.dart:99-112`: call the shared
  `CupidApi.dio` directly with typed JSON mapping in the feature.

```dart
// mobile/lib/features/vibes/data/vibes_repository.dart
Future<VibeEntry?> fetchMyToday();                 // GET  /vibes/today   -> object | null
Future<List<VibeEntry>> fetchMyHistory();          // GET  /vibes/history?days=8
Future<List<VibeEntry>> fetchPartnerHistory();     // GET  /vibes/partner?days=8
Future<void> submitMood(VibeMood mood);            // POST /vibes { "mood": "<wire>" }
```

- Wire mood contract (frozen `Mood` enum, `backend/src/modules/vibes/entities/vibe.entity.ts:4-10`):
  `happy | sad | angry | horny | tired`. Display id `spicy` maps to wire
  `horny`; the removed `soft` display id has no wire value.
- `VibeEntry` JSON shape (TypeORM `Vibe`): `id`, `userId`, `mood`, `note?`,
  `createdAt` (ISO-8601). `note` is parsed but unused in v1 UI.
- Failure contract: `CupidErrorInterceptor` already sets a `CupidApiFailure` on
  `DioException.error`. The repository rethrows that failure (never the raw
  `DioException`), matching `AuthRepository`. Presentation maps it to inline
  text only.
- Localized copy: feature-local `BuildContext` extension
  (`presentation/vibe_strings.dart`), following the STORY-003 precedent in
  `features/auth/presentation/auth_strings.dart`. `mobile/lib/l10n/**` is
  deliberately **not** in this story's write scope (D-010-6).
- Data model / migration contract: none. New dependencies: none.
- Requirement configuration guide impact: **NOT REQUIRED** (no env var, secret,
  dependency, or third-party integration change).
- Runtime: `mobile-app` (`data/devops/system/runtime-command-registry.json`).
  Flutter is not on PATH on this machine; use
  `"${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter"`.

## 3. Scope And Assumptions

- In scope: mood check-in (immediate submit, optimistic + revert), partner vibe
  card with nudge banner copy, 7-day history strip, discoverable entry point
  from the existing `HomeScreen`, defensive unpaired/empty states.
- Out of scope: any `vibes` endpoint or Swagger change (A1); note input (UX §4);
  a real nudge/hug action (D-010-4); the daily-reminder notification deep link
  (no notification infrastructure in this story; the backend partner push is a
  stub log at `vibes.service.ts:33-40`); the full `home` dashboard layout.
- Assumption A-1 (non-blocking, PO confirmation pending, UX §3/§10.1): the grid
  ships 5 cells. Backend-safe either way; only `VibeMood` changes if PO keeps 6.
- Assumption A-2 (non-blocking, PO confirmation pending, UX §6/§10.3): the strip
  header ships accurate "7 ngày gần nhất" / "last 7 days" copy. The backend has
  no deletion job, so the designed "auto-deleted in 30d" copy would overstate a
  retention guarantee.

## 4. Architecture Delta

### Boundaries And Ownership

- `features/vibes/domain/`: `VibeMood` (display id ↔ wire value, single mapping
  site) and `VibeEntry`. No Flutter or Dio imports.
- `features/vibes/data/`: `VibesRepository`, the only place that knows the
  `/vibes*` paths and JSON keys. Depends on `core/network/cupid_api.dart` only.
- `features/vibes/presentation/`: `VibeCubit` + `VibeState`, screen, and
  props-only widgets. Never imports `Dio`, `cupid_api`, or raw paths.
- Shared touch points, both append-only to limit parallel-wave conflicts:
  `core/di/service_locator.dart` (two registrations) and
  `design_system/icons/cupid_icons.dart` (one `tipsAndUpdates` constant).

### D-010-1 — No STORY-004 realtime dependency (resolves story_master open item)

Vibes is pull/refresh only. Evidence: the backend has no vibes gateway or vibe
event name (`grep` over `backend/src` finds vibes only in the REST module,
`data-export`, and `admin`), and STORY-004's contract restricts
`RealtimeEvent.name` to the frozen `CHAT_EVENTS`/`ALARM_EVENTS` values
(`STORY-004 architecture/solution.md` §2). There is no vibe event to subscribe
to, so wiring `RealtimeCoordinator` here would produce a permanently silent
stream. Freshness comes from: fetch on screen open, re-fetch after a successful
submit, and `RefreshIndicator.adaptive` pull-to-refresh. UX §10.4 already
accepts this with no new visual state.

### D-010-2 — 5-value mood set, `spicy → horny` mapped in exactly one place

`VibeMood` owns `wireValue` (`happy|sad|angry|horny|tired`), the display id
(`spicy` for `horny`), and `fromWire` with an unknown-value fallback that skips
the entry rather than throwing, so an unexpected server value cannot crash the
strip. No other file may contain a mood string literal.

### D-010-3 — `GET /vibes/today` is authoritative for "my today"; the strip is bucketed client-side

`getTodayVibe` uses **server** local midnight (`vibes.service.ts:68-81`) while
`getHistory` uses a rolling `now - days` window ordered `DESC`
(`vibes.service.ts:46-57`). Therefore:

- my current selected cell comes from `GET /vibes/today` only — the client never
  recomputes "my today" from history;
- both strips request `days=8`, not 7, so the rolling window fully covers the
  last 7 **local** calendar days under any client/server timezone offset;
- entries are bucketed by `DateTime.parse(createdAt).toLocal()` calendar date,
  newest wins per day, missing days render the `none` glyph;
- partner "today" is derived from the partner history bucket for the local
  today, not from a `days=1` call (which is a rolling 24h window and would show
  last night's vibe as today).
- Known limitation: near midnight with a large client/server offset, my
  authoritative "today" cell can disagree with my local strip bucket for one
  day. Accepted for v1; no backend change is available under A1.

### D-010-4 — Nudge CTA ships decorative-only (resolves UX §5 / §10.2)

No non-new-endpoint mechanism for "Nudge" exists: the vibes module has no
nudge/hug route, its partner push is a commented-out stub, and STORY-004's
`emit` is socket-only against frozen chat/alarm event names with no backend
handler for a vibe nudge. UX option (a) is therefore the only accurate choice —
render the pill as an affirming label with no tap target and no
button/interactive semantics (UX §8).

### D-010-5 — Entry point is a navigation-only card on the existing `HomeScreen`

`AppShell` currently renders the placeholder `HomeScreen` directly
(`core/navigation/app_shell.dart:5-12`); the design-source `home` dashboard and
the 5-tab bar are not in this story's scope. `VibeEntryCard` is mounted on
`HomeScreen` as a discoverable tap target that pushes `VibeScreen`, keeping the
`home_screen_ready_signal` key intact (runtime registry readiness contract). The
card takes an optional `today` snapshot parameter so the home-dashboard story can
data-bind it later without touching feature internals; v1 passes nothing, so the
screen makes no duplicate fetch.

### D-010-6 — Feature-local strings, no shared ARB edit

Adding keys to `mobile/lib/l10n/arb/app_en.arb` + `app_vi.arb` would put this
story in write contention with every other story in the wave on two shared files
guarded by `test/l10n/arb_parity_test.dart`. STORY-003 already set the
feature-local extension precedent. Debt: fold `vibe_strings.dart` and
`auth_strings.dart` into the generated `AppL10n` pipeline in a later
consolidation story.

### AC3 (unpaired access) — relies on the app-level paired route gate

Per UX §7 this story must **not** build a screen-level "are you paired" guard as
the primary control. That app-level gate is owned by the pairing/shell work and
is not present at this story's BaseHead, so AC3 cannot be verified end-to-end
inside this story; it is verified at requirement integration once the gate
lands. What this story does own: `GET /vibes/partner` returns `[]` for an
unpaired or newly-unpaired user (`vibes.service.ts:59-66`), so the partner card
and both strips must render the existing `none` / "Chưa nói gì" state instead of
an error — this also covers the UX §7 mid-session unpair edge case. Recorded as
risk R-010-1 for Scrum Master, not a blocker for the mobile build.

## 5. Non-Functional Impact

- Network: exactly 3 GETs per screen open/refresh, 1 POST per check-in. No
  polling, no socket, no background work.
- Persistence: none (OQ4 assigns Drift to chat/timeline/expenses only).
  In-memory cubit state; no `hydrated_bloc` for this screen.
- Accessibility: per-cell accessible name plus selected/toggled semantics, live
  announcement on optimistic revert, `--tap` minimum re-verified after the 3+2
  layout (UX §8).
- Privacy: Level-2 data, no lock affordance required (UX header).

## 6. Risks And Mitigations

| Id | Risk | Mitigation |
|----|------|------------|
| R-010-1 | AC3 depends on a paired route gate absent at BaseHead | Feature degrades to `none`/waiting on `[]`; AC3 verified at requirement integration; escalated to Scrum Master |
| R-010-2 | Rapid double-tap creates duplicate same-day records | Cubit disables the grid while a submit is in flight (UX §4) |
| R-010-3 | `GET /vibes/today` returns an empty body for "no check-in" | Repository treats `null`/empty body as "no entry", never as a parse error |
| R-010-4 | Parallel-wave conflict on `service_locator.dart` / `cupid_icons.dart` | Append-only single-line edits at the end of the existing registration block / class |
| R-010-5 | Unknown future mood value from the server | `VibeMood.fromWire` returns null and the entry is skipped, not thrown |

## 7. Handoff Notes

- Mobile lane: execute `coding-plan/master-plan.md` phases P0 → P4 in order.
- Product Owner: confirm A-1 (drop `soft`) and A-2 (strip copy). Both ship a
  backend-accurate default if unanswered; neither blocks the build.
- Scrum Master: record R-010-1 so requirement integration verifies AC3 after the
  paired route gate lands.
