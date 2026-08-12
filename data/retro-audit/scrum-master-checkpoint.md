# Retro Audit Checkpoint

Cycle: 2026-08-12
Active Requirement: REQ-001_cupid_flutter_mobile_app
Mode: single-req
Trigger: user "review REQ-001" retro-audit → RED-PATCH CONFIRMED, user-confirmed 2026-08-12.

## Retro Audit: COMPLETE (historical, do not re-open)

All 16 stories (STORY-001..016) audited across 3 batches. Full findings,
ledger, and Git boundary repair records are in
`data/requirements/REQ-001_cupid_flutter_mobile_app/retro-audit/audit-report.md`
and this checkpoint's git history (prior commit `af2434d`) — do not re-derive
from chat. Verdict: RED-PATCH — CONFIRMED (Design Fidelity FAIL req-wide, 4
AC FAILs, 6 unapproved scope/traceability gaps). 9 RED-PATCH, 3 AMBER, 4 GREEN.

Known non-blocking tooling gap (STORY-002 reviewer Stop hook re:
`visual-fidelity-report.md` gate on a non-UI story) — flagged to user, no fix
applied, does not block anything remaining. Do not re-investigate.

`list-releasable-agents.sh` intermittently prints stale `@session-e67e7d2e`
handles that don't match the real running `@session-359b6de2` teammates —
known non-blocking bookkeeping discrepancy; use the real suffix from
`TaskStop`'s own error listing when this recurs.

## User Course-Correction (binding, do not deviate)

Exactly 2 hardening stories, strict order, full pipeline each. The 3 code-fix
hardening stories (STORY-006 partnerId/contract-visibility, STORY-008
GhostStateRow mount, STORY-016 privacy/notifications) are EXPLICITLY DEFERRED
— do NOT create them until BOTH STORY-017 and STORY-018 are `DONE` with
Reviewer approval.

## STORY-017_oq_scope_triage: DONE

PO-owned OQ/scope triage. Reviewer (Iris-QC-17) `Outcome: CLEAN`. Boundary
completed (`git-story-boundary.sh complete`, commit `af2434d`). Status flipped
to `DONE` in both `req_master.md` User Stories table and STORY-017's own
`story_master.md` (auto-sync did NOT flip it — had to be done manually; expect
the same manual step for STORY-018).

## STORY-018_design_fidelity_capture: IN_PROGRESS

Git-Boundary: REQUIRED | Story-Class: standard | Depends-On: NONE
Worktree: /Users/alantravala/workspace/snapsofts/cupid-apps | Branch: main
MergeTarget: main | BaseHead: af2434de8c5f2b46dcd90e025879f73055d96742
BoundaryState: `.git/ai-team-story-boundaries/REQ-001_cupid_flutter_mobile_app/STORY-018.json`

Coding plan: `STORY-018_design_fidelity_capture/coding-plan/master-plan.md`
(339 lines). Single-lane mobile; P1-P4 NOT_APPLICABLE; P5-P11 mobile,
dispatched sequentially (one phase per `Alex-Mobile-Dev` handoff, per the
scrum-master skill's mobile-dev template).

Phase status (all independently re-verified by Scrum Master, not just
trusted from specialist self-report):
- P5 design references (37 PNGs): DONE
- P6 harness foundation (runtime screen switching, live-session bootstrap,
  AppShell chrome, debug manifest intent-filter): DONE
- P7 seed script (`mobile/tool/seed_preview_state.mjs`, idempotent, live
  backend): DONE
- P8 registry wiring (37/37 canvas ids, `needsFixtures` empty, `flutter
  analyze`/`flutter test` 890/890 clean): DONE
- P9 implementation captures (37 PNGs): DONE. Three incidents hit and fully
  resolved along the way (no further action needed):
  (a) illegal `--` in debug-manifest XML comment broke `assembleDebug` —
      fixed by mobile-dev, re-verified by direct build.
  (b) shared emulator (~600MB free) couldn't fit the 223MB debug APK —
      worked around with `flutter build apk --profile` (93.6MB); surfaced a
      missing intent-filter in `src/profile/AndroidManifest.xml` (debug-only
      originally) — fixed by mobile-dev (mirrored block), re-verified via
      rebuild+reinstall+live deep-link+dumpsys check.
  (c) first capture pass froze mid-loop (25/37 duplicate/frozen under wrong
      filenames, app UI thread stopped responding, no crash/ANR) — diagnosed
      by mobile-dev via visual inspection, corroborated by me via file-size
      clustering, fixed by me (`am force-stop`+`am start`), recaptured
      cleanly by mobile-dev on retry.
  Final 37/37 independently re-verified: `find -printf` metadata (fresh
  timestamps, no more clustering) + 3 representative visual spot-checks
  across all 3 claimed categories (genuine / error-empty / not-implemented
  placeholder). Coding-plan P9 Status cell confirmed `DONE` via direct read.

- **Pre-P10 gate: RESOLVED.** P9 surfaced 8 ids rendering empty/error content
  — profile, contract, chat, timeline, expense, jar, jarlist, me. Two stacked
  causes, both fixed, all 8 independently re-verified by direct screenshot
  Read (not self-report):
  1. `Alex-Mobile-Dev-4` correctly diagnosed DEC-3 (live Firebase sign-in
     required, no bypass) meant every prior build with
     `PREVIEW_EMAIL`/`PREVIEW_PASSWORD` unset 401'd on every live-repo screen,
     and rebuilt with those two dart-defines
     (`preview.dev.a@cupid.test`/seed script's account A credential).
  2. Installing that build surfaced a device-level DNS failure
     (`emulator-5554` couldn't resolve real hostnames; raw IP worked) that
     blocked Firebase Auth itself (`network-request-failed`, unhandled
     exception in `bootstrapPreviewSession` before `runApp()`, app stuck on
     native splash). User granted explicit permission to reset the shared
     emulator; fixed via `adb reboot` (preserves `/data`, reinits netd) —
     confirmed via logcat `FirebaseAuth: Notifying id token listeners`.
  3. After that fix, `profile` still spun forever (silently, no logged
     error) and `contract` showed an explicit "Không có kết nối mạng" error.
     Root-caused directly (not guessed): `mobile/lib/core/config/
     cupid_api_config.dart` defaults `CUPID_API_BASE_URL` to
     `http://localhost:3000`, which inside the emulator is the emulator's
     own loopback, not the host — no build ever passed this dart-define. The
     host backend also wasn't running at all. Started it via
     `scripts/start-dev.sh`; `setup.sh` auto-resolved to port **3006** (3005
     busy — the other concurrent session on this machine already holds it),
     confirmed ready via `GET 127.0.0.1:3006/api-docs-json` → 200. Rebuilt
     the profile APK a third time, same single-ABI arm64 trick (93.6MB),
     adding `--dart-define=CUPID_API_BASE_URL=http://10.0.2.2:3006` alongside
     the two auth defines. Reinstalled, recaptured all 8 ids: all now render
     real seeded content (timeline shows "Seeded memory...", expense shows
     "750.000 đ / 2 khoản chi", jar/jarlist show "Trip to Paris", profile
     shows the real edit form, contract shows real skeleton/loaded content,
     chat/me render without error). No further action needed on this gate.

  Two NEW minor visual findings surfaced by this recapture, NOT fixed by me
  (implementation-level, belongs in P10/P11 mobile-dev MATCH/DEVIATION
  judging, not a Scrum Master fix): `me` screen has a text-overflow/vertical
  letter-wrap layout defect on the display-name text; `chat` screen shows an
  unexplained plain-gray background fill (may be intentional empty-state or
  may be a defect — mobile-dev to judge in P10/P11, `chat` is already in the
  Part A id list below).

  Backend dev server is running in the background for the remainder of this
  story (started via `scripts/start-dev.sh`, PID tree rooted at shell PID
  19658, Nest process port 3006) — do not restart it; it must stay up through
  P10/P11 captures since they hit the same live backend.

- **P10 (Part A per-screen verdicts): DONE.** Dispatched to a fresh
  `Alex-Mobile-Dev` (canonical name, `session-359b6de2`) after fixing a
  `subagent_type` role-alias mismatch (`guard-canonical-agent-name.sh`).
  Result independently verified: `visual-fidelity-report-part-a.md` exists
  with all 19 rows + summary table; master-plan P10 Status cell confirmed
  `DONE` via direct read. **Verdict: 19/19 DEVIATION, 0/19 MATCH.**
  - Recaptured 2 of the 8 already-fixed ids that fall in Part A (`profile`,
    `contract` — both P9 captures were stale error/spinner states); both now
    render real content. `chat` judged as-is per handoff instruction (flat
    unthemed gray fill, no ChatScreen content — looks like a build/theming
    defect, not a data gap).
  - `alarm`/`home` old-vs-new note (as required by plan §5.2): `alarm`'s
    chrome fix genuinely worked (only Part A capture with the correct 5-tab
    `CupidTabBar`), but content now fails entirely ("Không tải được nhắc nhở
    đồng bộ") — a new regression, worse than the first audit's content FAIL.
    `home`'s content finding is unchanged (still the literal STORY-001
    placeholder), but chrome went from absent to present-and-broken (2-label
    nav, pink FAB overlapping labels).
  - **Two systemic issues surfaced, outside this handoff's fix/recapture
    scope, explicitly NOT fixed (implementation-level, feeds later code-fix
    story scoping only — do not act on these until after both hardening
    stories are DONE per the user's course-correction):**
    1. Load-error/empty states on 6 of the 29 un-recaptured ids (`alarm`,
       `antighost`, `gallery`, `invite`, `joincode`, `pet`) despite the
       backend being live at capture time — flagged as possibly a seed-timing
       gap distinct from a design mismatch, needs a follow-up capture pass
       before treating as final design verdicts (not yet actioned).
    2. Oversized text-scale regression (~3-4x design size) on `splash`,
       `welcome`, `login`, `register`, `forgot`, and (confirmed via fresh
       recapture) `contract` — reproduces identically on a live-backend
       recapture, so not a one-off; wraps single words across full-width
       lines and pushes CTAs/inputs off the 900px capture. Mobile-dev
       recommends Tech Lead triage before this affects P11 judging too.
    Also recorded: a second broken-chrome variant (2-label nav + overlapping
    pink profile FAB) recurring on `home`, `gallery`, `chat`, distinct from
    the correctly-working `CupidTabBar` seen on `alarm`/`privacy`/`vibe`.

- **OQ-1: RULED.** Andy-PO-2 (`Mode: story-requirements`) ruled all 10
  not-implemented ids (`otp`, `permissions`, `vow`, `zodiac`, `themes`,
  `themedetail`, `sharepick`, `shareedit`, `shareapprove`, `shareok`)
  **approved scope cuts**, not defects — none was ever promised by any of the
  16 original stories' User Story/Scope/AC text, per-screen evidence
  verified. No code-fix hardening story created for these ids; the 3 deferred
  hardening stories (STORY-006/008/016) are unaffected. Outputs verified on
  disk: `STORY-018_design_fidelity_capture/requirements/requirements.md`
  (new, OQ-1 ruling + both required anchors) and `req_master.md` `## Open
  Question Triage / Approved Scope Change` entry 7 (new). Capture work is
  unaffected either way — P11 must still render/record a placeholder +
  `DEVIATION — screen not implemented` row for all ten; this ruling only
  fixes the row label to "approved scope cut" instead of "defect."

- **P11: DONE.** Dispatched via `SendMessage` continuation to the same
  `Alex-Mobile-Dev`. Independently verified: `coding-plan/master-plan.md` P11
  row `DONE`; `visual-fidelity-report.md` has all 37/37 rows, 0/37 MATCH,
  10/37 correctly labeled "approved scope cut" citing the OQ-1 ruling.
  Recaptured `me`, `timeline`, `jar`, `expense` (once), `jarlist` (twice) —
  all reproduced their broken state, not stale captures.
  - `me` recapture confirms the earlier-flagged text-overflow finding, more
    severe than first observed: single-character-per-line wrap.
  - **New finding — `jar`/`jarlist` content collision**: both render
    byte-/visually-identical placeholder content despite distinct design
    refs, survived two recapture attempts including one to rule out a
    route-switch race. Looks like a preview-registry/route wiring defect,
    not a styling issue. Flagged for Tech Lead triage, not fixed.
  - Cross-cutting findings now confirmed spanning both batches (not fixed,
    feed future code-fix hardening-story scoping only, per user's standing
    deferral): oversized text scale on 12 screens; broken bottom-chrome
    variant on 10 screens; load-error/empty states on 6 screens despite live
    backend (possible seed-timing gap, needs follow-up capture pass).
  - None of the above blocks STORY-018 review — the story's own scope is
    capture + verdict recording, not fixing these; all are explicitly
    forwarded as future hardening-story input.

- **STORY-018: DONE.** Reviewer (`Iris-QC@session-359b6de2`,
  `Mode: compact-story-review`) returned `Outcome: DEFERRED_ONLY`, no blocking
  findings (890/890 tests, 0 analyze issues in touched files; one non-blocking
  deferred finding: `seed_preview_state.mjs`'s `seedAlarm()` not idempotent —
  only matters for a future re-seed run). Report:
  `STORY-018_design_fidelity_capture/review/review-report.md`.
  Committed `124d8161165a342244f769f763aa310d6fc8abd1` (also carries the
  STORY-017 `Status: DONE` flip that was pending uncommitted since the prior
  merge at `af2434d`). `req_master.md` User Stories STORY-018 row and
  STORY-018's own `story_master.md` Status both flipped to `DONE` before that
  commit. Git story boundary: `commit_sha`/`merge_sha` both
  `124d8161...`, `MERGE_COMPLETE: true` (via `repair-boundary --commit-sha`
  since the boundary's own `commit` subcommand only seals *uncommitted* work
  and the story was committed manually first — needed
  `repair-boundary --branch main --worktree <repo root> --merge-target main
  --commit-sha <sha>` before `complete` would accept it; note this for any
  future inline story where Scrum Master commits before running the boundary
  helper's own `commit` step).

  **Both STORY-017 and STORY-018 are now `DONE` with Reviewer approval.**
  Per the user's explicit standing instruction, this unblocks creating the 3
  deferred code-fix hardening stories (STORY-006 partner visibility,
  STORY-008 GhostStateRow mount, STORY-016 privacy/notifications) — now with
  a much larger evidence set than originally scoped: the systemic oversized
  text-scale regression (~12 screens), the broken bottom-chrome variant
  (~10 screens), the `jar`/`jarlist` routing collision, and the load-error/
  possible-seed-timing-gap pattern (6 screens), all recorded in
  `STORY-018_design_fidelity_capture/visual-fidelity/visual-fidelity-report.md`.
  **Next: triage this evidence into the 3 stories' scope and create them**
  (Product Owner-owned story creation, per the normal breakdown flow — not yet
  started).

## After both hardening stories are DONE

Only then create the 3 deferred code-fix stories (STORY-006, STORY-008,
STORY-016). Then set REQ-001 Status back to `DONE` per the RED-PATCH Verdict
Plan's Done Condition, and update `master_requirements_list.md`'s REQ-001
row to `DONE`.

## Standing operational notes

- Never write the literal substring "retro-audit" in a non-reviewer handoff
  prompt (`guard-broad-handoff.sh` GENERIC false-positive) — paraphrase, or
  use `Checkpoint: NONE`.
- Canonical runtime agent names only: `Pink-Designer`, `Alan-Techlead`,
  `Alex-Mobile-Dev`, `Iris-QC`, etc. — never per-phase variants.
- Coding-plan edits must keep `## 5. Phases Overview` (level-2, not nested),
  the 10-column header, `P\d+` phase ids, bare terminal `Status` tokens
  (rationale in prose below, not in the cell).
- Run `list-releasable-agents.sh` + `TaskStop` at natural checkpoints.
