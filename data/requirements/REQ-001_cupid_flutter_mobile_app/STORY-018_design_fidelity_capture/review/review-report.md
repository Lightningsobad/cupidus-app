# Review Report — STORY-018 Hardening: Design Fidelity Capture Coverage

Review type: `compact-story-review`
Reviewer: Iris-QC
Date: 2026-08-12

Outcome: DEFERRED_ONLY

## Scope Gate

See `review/scope-gate.md` for the full identity/decision/risk-surface fields.

- Review type: `compact-story-review` (8 touched files, at budget)
- Source files in scope (all 8 from handoff, all reviewed):
  1. `mobile/android/app/src/debug/AndroidManifest.xml` — diff reviewed
  2. `mobile/android/app/src/profile/AndroidManifest.xml` — diff reviewed
  3. `mobile/lib/main_preview.dart` — full diff reviewed (478 lines)
  4. `mobile/lib/preview/preview_app_shell_chrome.dart` — full read (new file)
  5. `mobile/lib/preview/preview_not_implemented_screen.dart` — full read (new file)
  6. `mobile/lib/preview/preview_screen_entry.dart` — full read (new file)
  7. `mobile/lib/preview/preview_session_bootstrap.dart` — full read (new file)
  8. `mobile/tool/seed_preview_state.mjs` — full read (13 KB, new file)
- Governing artifact in scope (1 large, over 20 KB budget): `coding-plan/master-plan.md`
  (§2, §3, §4.1, §4.4, §5 Phases Overview, §5.2 Phase Detail, §6 Build And
  Verification Gate, §7 OQ-1 read directly)
- Other governing inputs read in full (all under 20 KB): `story_master.md`,
  `requirements/requirements.md` (OQ-1 ruling), `visual-fidelity/visual-fidelity-report.md`
  (combined 37/37 summary)
- Evidence spot-checked: `visual-fidelity/visual-fidelity-report-part-a.md` (first 40
  lines — runtime/seed facts and Part A headline finding), directory listing of
  `visual-fidelity/` (37 `design-reference-*.png` + 37 `implemented-*.png` confirmed
  present by filename)
- Query keys used: AC1–AC6 text, OQ-1 ruling, DEC-1/DEC-3/DEC-4, §6 Build And
  Verification Gate, cross-cutting findings 1–4 from the handoff
- Git boundary: `git -C <Worktree> diff --name-only af2434d` confirmed 3 of the 8
  handoff files are tracked modifications (`main_preview.dart` + both
  `AndroidManifest.xml`); the other 5 (`mobile/lib/preview/**`,
  `mobile/tool/seed_preview_state.mjs`) are untracked new files (`git status`
  confirmed `??`), consistent with `HEAD == BaseHead` and pending story
  work not yet committed.

## Build/Regression Gate — re-run, not reused

Reran per the handoff instruction (no `test-results.md` artifact existed to reuse):

- `cd mobile && flutter analyze` — full unfiltered run. 0 errors, 0 warnings.
  77 pre-existing `info`-level lints (`prefer_initializing_formals`,
  `deprecated_member_use`, `use_null_aware_elements`) in files this story did
  not touch (`core/navigation/pair_gate_shell.dart`,
  `features/dream_jar/presentation/contribution_history_cubit.dart`, etc. —
  confirmed by grepping the output for `main_preview` / `lib/preview/`: 0
  matches). Pre-existing, out of this story's write scope, not caused by this
  story — `DEFERRED` per scope-and-evidence.md, not blocking.
- `cd mobile && flutter test` — full unfiltered run. `890/890` passed
  (`All tests passed!`), matching the recorded baseline exactly. No regression.

## Acceptance Criteria

| AC | Verdict | Evidence |
|---|---|---|
| AC1 (37/37 pairs exist) | PASS | 37 `design-reference-*.png` + 37 `implemented-*.png` confirmed present by directory listing |
| AC2 (concrete verdict per screen, not ratio-only) | PASS | Combined report + Part A spot-check show concrete per-screen UI deltas (e.g. "oversized text scale wraps logotype", "flat unthemed gray fill, no content; broken chrome variant") |
| AC3 (backend-live, seeded state stated per screen) | PASS | `seed_preview_state.mjs` seeds over the real public HTTP API only (paired couple, gallery, timeline, jar, expenses, messages, alarm, vibe); Part A confirms backend answering at `127.0.0.1:3005` at judging time and records session/seed facts |
| AC4 (AppShell chrome per DEC-4 rule) | PASS | `PreviewAppShellChrome` implements the real `CupidTabBar`; `main_preview.dart`'s `_PreviewScreen` applies it per-entry via `wrapInShell`; report records chrome yes/no + why per screen, and flags the "broken bottom-chrome variant" as a deviation rather than silently passing it |
| AC5 (no ratio-only/zero-evidence rows) | PASS | 37/37 rows recorded with concrete detail in the combined report |
| AC6 (judged by outcomes, not tooling existence) | PASS | Report explicitly reasons from rendered evidence per screen, not tool presence |
| `alarm`/`home` re-litigation discipline | PASS | Combined table states explicitly, for both, whether the AppShell/backend-live fix changed the result (`alarm`: "regression vs. first audit"; `home`: "content finding unchanged... chrome now present but wrong widget") — not silently overwritten |

## OQ-1 / Scope Discipline

`requirements/requirements.md` OQ-1 ruling (approved scope cut for the 10
not-implemented screens) is correctly reflected: all 10 rows in the combined
report are labeled `approved scope cut (requirements.md OQ-1) — placeholder
only`, distinct from the 27 real deviations. The four cross-cutting findings
(oversized text scale ~12 screens, broken bottom-chrome variant ~10 screens,
load-error states beyond the fixed 8 on 6 screens, `jar`/`jarlist` content
collision) are present in the combined report exactly as forwarded findings,
not fixed and not silently omitted — consistent with this story's Out of
Scope. No deviation from the 27 real findings was fixed by this diff; the
touched files are harness/tooling only (`main_preview.dart`,
`mobile/lib/preview/**`, debug/profile manifests, `seed_preview_state.mjs`),
matching the story's declared write scope.

## Risk Surfaces

- **Mobile navigation / deep link (debug-only)**: `cupidpreview://screen/<id>`
  intent-filter is added only to `src/debug/` and `src/profile/`
  `AndroidManifest.xml` (Gradle manifest-merger scopes these per build
  variant); `main`/release manifest is untouched (confirmed by `git diff
  --name-only` not listing it). `didPushRouteInformation` ignores any
  scheme/host/id it doesn't recognize rather than crashing. No production
  surface added.
- **Auth**: `bootstrapPreviewSession()` uses real Firebase sign-in
  (`--dart-define=PREVIEW_EMAIL/PASSWORD`), no-op when unset, no bypass added
  to production auth. Consistent with DEC-3 (no dev auth bypass exists in the
  backend).
- **Local dev tooling / secrets**: `seed_preview_state.mjs`'s default Firebase
  Web API key (line 15) matches the already-public key shipped in
  `mobile/lib/firebase_options.dart` (Firebase Web/Android API keys are
  designed to be client-embedded, not secret) — not a new credential
  exposure. Default seed account passwords are dev-only test accounts against
  a local backend, all overridable via env vars.
- Runtime startup gate (P7/P9, scoped to this story's own capture run per the
  handoff): satisfied by the produced evidence itself — 37 real
  `implemented-*.png` captures from a booted emulator against a live backend
  are stronger proof the harness actually ran than a separate startup-smoke
  doc would be.

## Deferred Finding (non-blocking)

- **`seed_preview_state.mjs`'s `seedAlarm()` is not idempotent.** Every other
  seed function (`seedGallery`, `seedTimeline`, `seedDreamJar`,
  `seedExpenses`, `seedMessages`, `seedVibe`) checks for an existing row
  before creating one; `seedAlarm()` unconditionally `POST`s a new alarm on
  every run. `coding-plan/master-plan.md` §5.2 P7 explicitly requires the
  seed script to "be idempotent." This does not affect the already-captured
  37/37 evidence (seeding already ran once, successfully, before P9's
  captures), but a future re-seed for a re-capture pass would accumulate
  duplicate alarms. Owner: mobile-dev, low priority, fix opportunistically in
  a future STORY-018-adjacent pass — not required before closing this story.

## Traceability

- `story_master.md` AC1–AC6 and Out of Scope — verified above.
- `requirements/requirements.md` OQ-1 ruling — verified reflected correctly in
  the report.
- `coding-plan/master-plan.md` §4.1 DEC-1, §4.3 DEC-3, §4.4 DEC-4, §5/§5.2
  phase inventory (P1–P4 `NOT_APPLICABLE` with rationale, P5–P11 `DONE`), §6
  build/verification/evidence gates — all satisfied by the diff and evidence
  reviewed above.
- No architecture or UX artifacts exist or are required for this story (P1
  `NOT_APPLICABLE`, no new user-facing UX surface); confirmed consistent with
  `story_master.md` § Role Completion.

## Recommendation

- Keep `Implementation (Development)` checked.
- Check `Review (Reviewer)`.
- Recommend story status `DONE`.
- Carry the seed-script idempotency note forward as a deferred note only; no
  rework required to close this story.

REVIEW_COMPLETE: YES
