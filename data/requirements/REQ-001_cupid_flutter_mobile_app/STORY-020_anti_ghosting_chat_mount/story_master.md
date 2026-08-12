# Story Master: STORY-020 Hardening - Anti-Ghosting Chat Mount (Retro-Audit RED-PATCH)

Status: DONE
Complexity: XS
Story-Class: standard
Implementation Lane: mobile
Requirement: REQ-001
Retro-Type: RED-PATCH
Fixes: STORY-008 AC2 ("The configured anti-ghosting state is visibly
surfaced somewhere in the chat experience (exact placement per UI/UX
Designer).")
Source: `data/requirements/REQ-001_cupid_flutter_mobile_app/req_master.md`
§ User Stories, STORY-020 row; and
`data/requirements/REQ-001_cupid_flutter_mobile_app/retro-audit/audit-report.md`
§ AC-by-AC Implementation Traceability (STORY-008 AC2 row) and § OQ/
Traceability-Gap Disposition (STORY-008 ADR-3 row), Audit Date 2026-08-12.

## Depends On
- NONE. STORY-007 (chat screen) and STORY-008 (`GhostStateRow` widget) are
  both DONE; this is a code-fix closing a cross-story mounting gap between
  two already-complete stories, not new feature work.

## User Story
As a paired user, I want the anti-ghosting state the app already tracks for
me to actually be visible in my chat experience, so silence from my partner
doesn't get misread as something worse — the signal the app promises exists
but currently never renders.

## Background / Confirmed Defect
STORY-008 built and tested the anti-ghosting chat surfacing as an exported
mount seam rather than editing the chat screen directly. Per STORY-008's own
`story_master.md` (ADR-3): "AC2's chat surfacing ships as an exported
`GhostStateRow(partnerId:)` mount seam, not a chat-file edit, because
`mobile/lib/features/chat/**` is STORY-007-owned and absent from this
story's `BaseHead`; the one-line mount is a Scrum Master scheduling item for
STORY-007 or requirement integration, and AC2 end-to-end evidence is
deferred to it."

That scheduling handoff was never picked up. The retro audit
(`retro-audit/audit-report.md`) confirms this as a build defect, not merely
a deferred-evidence gap:

- AC-by-AC Implementation Traceability: "STORY-008 | AC2 (anti-ghosting
  state surfaced in chat) | **FAIL** | `GhostStateRow` built/tested per
  ADR-3 but never mounted into `chat_screen.dart`/`app_shell.dart` — no
  import/reference anywhere."
- OQ/Traceability-Gap Disposition: "STORY-008 | ADR-3 deferred
  `GhostStateRow` mounting (implementation gap, not an OQ) | Anti-ghosting
  visibility in chat (AC2) | Tracked in `architecture/solution.md`/
  `master-plan.md`/`test-results.md` as a scheduling item for
  STORY-007/integration, but never actually picked up by either |
  **RED-PATCH** — AC FAIL, not merely an evidence gap."

The audit's proposed hardening scope (item 2, priority-ordered) describes
the fix as narrow: "mount `GhostStateRow(partnerId:)` into `ChatScreen`;
narrow, dependencies already constructed." This story confirms and formally
scopes that fix; STORY-008 AC1 (home entry card) and AC3 (pairing guard)
both already PASS per the audit and are unaffected.

## In Scope
1. Mount the existing `GhostStateRow(partnerId:)` widget (STORY-008,
   `mobile/lib/features/anti_ghosting/**` or wherever it currently lives)
   into `ChatScreen` (`mobile/lib/features/chat/**`), including wiring its
   `GhostStormCubit` dependency if it is not already reachable at that mount
   point, so the anti-ghosting state is visibly rendered in the live chat
   experience for paired users.
2. Verify the mount renders correctly for a paired user in the running app
   (not just a widget test in isolation), closing the AC2 end-to-end
   evidence gap the original ADR-3 deferral left open.

## Out of Scope
- Any change to `GhostStateRow`'s own implementation, `GhostStormCubit`, or
  the anti-ghosting config/backend contract (`ghost-config` module) — STORY-
  008 AC1 and AC3 already PASS per the audit and are not touched.
- Any change to STORY-007 chat features not required to host the mount
  point (message list, typing indicator, attachments, etc.).
- New anti-ghosting placement or visual design decisions — this story mounts
  the already-built widget at the placement already specified for STORY-008;
  it does not reopen UI/UX placement as new scope.
- The love-contract partner-visibility fix (STORY-019, separate and already
  DONE).

## Acceptance Criteria
1. The configured anti-ghosting state is visibly surfaced somewhere in the
   chat experience (exact placement per UI/UX Designer) — STORY-008 AC2,
   carried forward unchanged. Verification must confirm `GhostStateRow` is
   actually mounted and rendering inside `ChatScreen`/`app_shell.dart` (an
   import/reference is present and exercised), not merely built and unit
   tested in isolation as before.

## Open Items For Downstream Roles
- [Tech Lead / Mobile Developer] Confirm the mount point matches the
  placement STORY-008 already specified relative to STORY-007's chat screen
  (per STORY-008's Open Items note to UI/UX Designer). If no explicit
  placement record exists, use the most natural existing seam (e.g. a chat
  app-bar/header area) rather than treating placement as a new design
  decision requiring fresh UI/UX Designer scope.

## Role Completion
- [x] Product Owner — `req_master.md` § User Stories STORY-020 row +
  `retro-audit/audit-report.md` (STORY-008 AC2 FAIL row and ADR-3
  traceability-gap row) + `STORY-008_anti_ghosting/story_master.md`
  (original unmodified AC2 text).
- [x] UI/UX Designer — `ux/uiux-spec.md` (mount seam confirmed from 3
  concordant STORY-008 sources: its own UX spec §2.4, its P3 phase file §3,
  and `ghost_state_row.dart`'s own doc comment).
- [x] Architecture (Tech Lead) — `architecture/solution.md` (§1-5 mount
  design + §7 authorized write-scope extension resolving the preview-harness
  blocker found during implementation) + `coding-plan/master-plan.md` (single
  P1 phase) + `coding-plan/phase-P1-mobile-chat-ghost-state-mount.md`.
- [x] Implementation (Development) — P1 by `Alex-Mobile-Dev`, `DONE` in
  `coding-plan/master-plan.md` § Phases Overview. Code+test evidence in
  `coding-plan/test-results.md` (5/5 new mount tests, 110/110 regression,
  clean `flutter analyze`). Visual audit `PASS` in
  `visual-fidelity/visual-fidelity-report.md` with pixel-diff evidence
  (only the row's own 50px band differs between states). A pre-existing,
  story-unrelated preview-harness crash blocked the first visual-audit pass;
  resolved under the Tech Lead-authorized narrow write-scope grant in
  `architecture/solution.md` §7 (`preview_session_bootstrap.dart` only).
- [x] Review (Reviewer) — `review/review-report.md`, `Outcome: CLEAN`
  (Tier 1 compact story review). Diff independently verified against the
  plan (mount seam, `MultiBlocProvider` unchanged, preview-bootstrap change
  stays exactly inside the §7 grant), all 4 phase ACs matched to test
  assertions (not just pass count), both visual-fidelity PNGs viewed
  directly and confirmed. No findings, no patch required.
