# Retro-Audit — STORY-012 Timeline Kỷ Niệm

Run Key: 2026-08-12:REQ-001:STORY-012:retro-audit
BaseHead verified: `main` HEAD `f7d06fd4737cc7edbe6f6e33c205bf77fdf26f67`
Scope: independent re-verification against current `main`, prior review
reports treated as context only.

## What was deferred, and is it resolved on current `main`?

The story's Phase-P1 scoped review
(`STORY-012_timeline/review/review-report.md`, `Outcome: DEFERRED_ONLY`)
deferred merge-to-`main` — not any AC — pending an ADR-010
canonical-Drift-owner fold. P1 had built a standalone `AppDatabase` Drift
class in the story worktree at the same time a sibling story (STORY-007,
chat) was independently building the canonical `CupidDatabase`; shipping both
unmerged would have put two independent Drift/SQLite databases on one device.
P1's own ACs were already confirmed PASS in isolation; the defer was purely
an architecture-consistency pre-merge condition.

**Resolved.** Independently confirmed on current `main` (not just by
re-reading `review-report-fold.md`, which also recorded `Outcome: CLEAN`):

- `git ls-files mobile/lib/core/database/` at `main` HEAD `f7d06fd` shows no
  `app_database.dart`/`.g.dart` anywhere; the only database file is
  `cupid_database.dart`/`.g.dart` plus `daos/{message,timeline,expense}_dao.dart`.
- `mobile/lib/core/database/cupid_database.dart:21-30` — `@DriftDatabase` on
  `CupidDatabase` declares `tables: [Messages, TimelineEntries,
  TimelineSyncState, Expenses, ExpenseSyncMetadata]`, `daos: [MessageDao,
  TimelineDao, ExpenseDao]` — Timeline's tables live under the single
  canonical owner, not a second database.
- `mobile/lib/core/database/daos/timeline_dao.dart:13-15` —
  `class TimelineDao extends DatabaseAccessor<CupidDatabase> with
  _$TimelineDaoMixin implements SessionScopedStore` — confirms the DAO is
  hosted on `CupidDatabase`, not a standalone `AppDatabase`.
- `scrum-master-checkpoint.md`'s integration->`main` merge record
  independently verified the same condition (`cupid_database.dart` present,
  no stray `app_database.dart`) before the merge landed.
- Current `schemaVersion` is `2` (Expenses added additively by a later
  story, `onUpgrade` only adds the two new Expenses tables) — no regression
  to Timeline's schema-v1 tables, which remain untouched by the version bump.

The deferred condition is fully closed on `main`; nothing from the P1 defer
remains open.

## Acceptance Criteria (independently verified against current `main`)

1. **A paired user can create a timeline entry.** PASS.
   `mobile/lib/features/timeline/presentation/create_entry_cubit.dart` +
   `widgets/create_memory_sheet.dart` implement validate/submit/offline-block/
   pairing-required/success paths; `screens/timeline_screen.dart`'s two "Add a
   memory" call sites (`_ReadyView`, `_EmptyView`) are wired to
   `CreateMemorySheet.show` (the P8 gap closure — confirmed present in
   current source, not a stale claim). Test coverage:
   `create_entry_cubit_test.dart`, `create_memory_sheet_test.dart`,
   `timeline_screen_test.dart` (both "Add a memory" widget tests).
2. **Both partners can view the shared timeline.** PASS. Couple-scoping is
   server-side (`coupleId`); client-side, `timeline_repository.dart` +
   `timeline_screen.dart` render the fetched page unmodified. DTO decode
   (`timeline_event_dto.dart`), repository read-through, and screen
   loading/ready/empty states are each independently tested per
   `timeline_event_dto_test.dart`, `timeline_repository_test.dart`,
   `timeline_screen_test.dart`.
3. **Offline read after ≥1 sync; new entries still require connectivity.**
   PASS. `timeline_dao.dart:30-48` `replaceFirstPage()` is the only writer
   (server-authoritative overwrite, no outbox/queue columns);
   `lastSyncedAt()` (line 52-56) distinguishes never-synced from
   synced-empty. `create_entry_cubit.dart` fails fast under
   `NetworkUnavailableFailure` before any repository call — no local Drift
   write on a failed create. Matches ADR-007 (OQ4, `conflicts_open_questions.md`
   "Resolved Open Questions" — Drift read-through, no offline write queue in
   v1, because the backend has no idempotency key). OQ4 is correctly honored
   by this implementation; no drift from the resolved OQ.
4. **Unpaired users cannot access this feature.** PASS.
   `timeline_entry_point_card.dart` itself has no pairing awareness by
   design (doc comment states the caller gates it); confirmed the caller
   does gate it — `mobile/lib/features/home/presentation/home_screen.dart:72`
   calls `getIt<CouplePairingStore>().resolve()` and line 312 mounts
   `TimelineEntryPointCard` only behind that resolution. `CouplePairingStore`
   itself returns `unpaired`/`unknown` distinctly and is tested in
   `couple_pairing_store_test.dart` / `timeline_entry_point_test.dart`
   ("unpaired: entry-point card is absent", "unknown: entry-point card is
   absent").

No AC regression, no stale claim found; all four ACs check out against
current source, not just prior review prose.

## Design Fidelity

**UNVERIFIED — not PASS.** `integration-review/mobile-visual-audit.md`
(Result: FAIL overall) captured exactly 10 of the design's 37 screens:
`alarm`, `antighost`, `gallery`, `home`, `invite`, `joincode`, `paired`,
`pet`, `privacy`, `vibe`. No timeline screen is among the 10 captured pairs.
STORY-012's screens (`timeline_screen.dart`, the create-memory sheet) were
never visually audited against the design, in either direction. This is a
residual gap carried at the requirement level, not something this story
regressed or that P1-P9's own reviews claimed to cover — `slice-c.md`
explicitly recorded "Requirement mobile visual audit: NOT_APPLICABLE
(deferred to requirement-level audit)" at the time, and that deferred audit
still hasn't reached timeline's screens. Do not treat this as a story defect;
treat it as an open requirement-level audit gap that should extend to
timeline when the audit's "Extend `previewScreens`" next step is picked up.

## OQ Discipline

- OQ4 (offline storage strategy) — resolved via ADR-007, correctly applied
  by this story (see AC3 above); no drift.
- OQ5 (light theme / EN locale) — not implicated by this story's scope
  (timeline data/persistence/UI text uses the existing ARB infra; no
  timeline-specific theme/locale toggle logic exists).
- No new open question was raised or left unresolved by STORY-012's own
  scope. No bug in `data/bugs/master_bugs_list.md`'s 7 REQ-001 bugs
  (`BUG-20260801-001`..`007`) references timeline; the two post-deploy
  readiness-gate bugs were unrelated (stale `AppShell` test seam from
  STORY-016, and a `"Synced Alarm"` copy-guard violation from STORY-016).

## Story-level Substantive Verdict: CLEAN
## Classification Impact: GREEN
## REVIEW_COMPLETE: YES
