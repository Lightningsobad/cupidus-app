## Story Runtime Startup Smoke

- Runtime Id: backend-api
- Registry: data/devops/system/runtime-command-registry.json
- Reason: `guard-parallel-spawn.sh` refused to spawn Alex-Mobile-Dev for this
  story's Phase P1 with "no declared service runtime is running" even though
  Phase P1 itself declares `Runtime startup smoke: NO`. This section satisfies
  that blanket repo-level spawn-guard precondition; it is not a Phase P1 test
  result.
- Command: `npm run start:dev` in `backend/`, `PORT` sourced from
  `DEVSTACK_PORT_API` in `.env.devstack` (shared devstack tenant `cupid_apps`,
  reserved port 21020 per `sharedInfra.reservedPorts.api`)
- Ready Check: `GET http://127.0.0.1:21020/api-docs-json` expecting HTTP 200
- Result: PASS (HTTP 200, valid OpenAPI JSON body returned; process listening
  on `*:21020`, backend `[NestApplication] Nest application successfully
  started` logged)
- Shutdown: PASS (SIGTERM to the nest dev process; process exited within 2s;
  port 21020 confirmed free afterward)

Notes:
- Worktree-local setup performed to make this runnable: `backend/node_modules`
  installed via `npm ci` (worktrees do not share installed dependencies), and
  two pre-existing local secrets/generated files copied from the control
  checkout into this worktree since git worktrees do not carry untracked
  files: `backend/service-account.json` (pre-supplied Firebase Admin
  credential, not generated) and `.env.devstack` (devstack-generated env
  contract for the same shared `cupid-apps` tenant; `devstack use --check`
  confirms this worktree resolves to the same adopted tenant as the control
  checkout, and `devstack port check` showed no conflicts before starting).
- This smoke does not leave backend-api running; per the handoff, only proof
  it can start and answer ready was required.

## Phase P1 — Content Pack And Gate (Mobile)

All commands run from the story worktree's `mobile/` directory on
`codex/REQ-016_solo_stage1_relationship_assistant-STORY-011_zodiac_quiz_shell`.

### Targeted tests

- Command: `flutter test test/features/zodiac_shell/`
- Result: PASS (67/67 — 46 gate tests, 21 parser/schema tests)
- Covers: shipped packages parse under their contract schema id, mapping keys
  decompose into `questions_per_round` tokens, N read only from
  `ContentPackage.length`, parser rejections, gate rules one control per rule,
  time-gating key refusal per key in `zodiacTimeGatingKeys`, lexical delegation
  to `core/content/invariant_terms.dart`, input-side probe refusal in question
  prompts, and the offline/content-free source scans (AC-22/AC-23/R-15a).

### Regression

- Command: `flutter test test/core/content/`
- Result: PASS (15/15, unchanged — the shared `ContentPackage` parser was reused
  verbatim, not modified)
- Combined confirmation run: `flutter test test/features/zodiac_shell/
  test/core/content/` — PASS (82/82)

### Static analysis

- Command: `flutter analyze lib/features/zodiac_shell test/features/zodiac_shell`
- Result: PASS (`No issues found!`)
- Scoping note: the repository-wide `flutter analyze lib test` baseline is
  non-zero (pre-existing warnings, 0 errors), so analysis is scoped to the
  Phase P1 write scope. Delta introduced by this phase: 0 issues. One
  `unnecessary_import` (`dart:typed_data`) raised on the first run was fixed
  before this result.

### Contract deviation recorded

- `architecture/contract-summary.md` §1 sketches the package envelope key as
  `"schemaId"`, but the same section mandates reusing
  `core/content/content_package.dart` verbatim, and `ContentPackage.parse`
  reads `schema_id`. The shipped packages therefore use `schema_id`; the §2
  schema id *values* (`req016.zodiac_quiz.v1`, `req016.zodiac_outcomes.v1`) are
  matched exactly.

### Notes

- `mobile/pubspec.yaml` already declares the `assets/data/req016/` directory, so
  both new packages bundle with no pubspec change (no edit was made to it).
### Design reference resolved (design-side only)

- `Design-Screen: 7-vo-hoang-dao-3-viec` — resolved by this lane and recorded in
  `story_master.md`; no `Design-Screen:` line had been written before.
- Enumerated first, never guessed:
  `node .ai-team-bundle/runtime/tools/render-design-canvas.js
  --surface=cupid-ch-ng-1 --list-screens`
- Rendered:
  `node .ai-team-bundle/runtime/tools/render-design-canvas.js
  --surface=cupid-ch-ng-1 --screen=7-vo-hoang-dao-3-viec --platform=ios
  --out=<story-dir>/visual-fidelity`
  → `DESIGN_CANVAS: OK .../visual-fidelity/design-reference-7-vo-hoang-dao-3-viec-ios.png 415x900`
- Confirmed by looking, not by string match. The render is the "Cung & trắc
  nghiệm" screen and it corroborates the P1 data contract: a self-addressed
  insight, an `about_other` block whose ask line renders as a quoted question
  (AC-15), exactly three suggestion cards each with a title plus a meta note
  (AC-4/BR-2 → `minimumSuggestionsPerOutcome`), and a closing disclaimer with no
  percentage, score, or verdict anywhere (AC-13/AC-14). Candidate
  `tro-doan-khong-thang-thua` was rejected: it is the guessing game, not this
  result surface.

- Visual fidelity: the *implemented* side is NOT_APPLICABLE for this phase —
  P1 ships data and domain code only, no widget. `implemented-*.png` and
  `visual-fidelity-report.md` belong to Phase P3 (result surface screens), which
  now has its design reference in place rather than building blind. This phase
  deliberately wrote no `VISUAL_FIDELITY:` verdict: there is nothing rendered to
  compare yet, and a typed token without a capture is exactly what the gate
  exists to refuse.

## Phase P2 — Deterministic Session (Mobile)

Run at: 2026-09-24 · Worktree:
`.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-011_zodiac_quiz_shell`

### Commands and results

| Command | Result |
| --- | --- |
| `flutter test test/features/zodiac_shell/` | 45/45 PASS |
| `flutter analyze lib/features/zodiac_shell lib/features/activity_cards/domain/activity_card.dart test/features/zodiac_shell` | `No issues found!` (3 items) |
| `flutter test test/features/zodiac_shell/ test/features/activity_cards/` | `+457 ~5: All other tests passed!` (0 failures, 5 pre-existing skips) |

Breakdown of the 45: `zodiac_shell_resolver_test.dart` 16,
`zodiac_rotation_store_test.dart` 15, `zodiac_shell_cubit_test.dart` 14.

`flutter analyze` is scoped to this phase's write scope on purpose: the
repository baseline is non-zero (222 pre-existing warnings, 0 errors), so a
whole-tree run can never read as a pass/fail signal. The delta this phase adds
is zero.

A fresh worktree needs `flutter gen-l10n` before any test that transitively
imports a screen; `zodiac_shell_cubit_test.dart` does, through
`context_notebook_entry_point.dart`. The generated `lib/l10n/generated/` stays
untracked.

### Required assertion evidence

- **Deterministic repeat (AC-21)** —
  `zodiac_shell_resolver_test.dart` "the same set, answers and notebook resolve
  identically every time" resolves the same round five times and asserts one
  distinct outcome id and one distinct suggestion-id sequence.
  `zodiac_shell_cubit_test.dart` "the same answers land on the same outcome on a
  later round" repeats that against the shipped assets *after* the rotation
  cursor has advanced, which is the assumption `solution.md` §3 records: the
  cursor picks questions and never reaches the mapping.
  A second test scans every `.dart` under `lib/features/zodiac_shell/` for
  `DateTime.now`, `Random(`, `Random.secure` and `Stopwatch` and requires none —
  the determinism claim holds for files added later, not just today's.
- **Wrap-around (AC-32)** — `zodiac_rotation_store_test.dart` runs a 7-question
  set for 16 rounds and asserts rounds 8-14 repeat rounds 1-7 in the same order;
  a 5-question set with a 2-question round is asserted to return `[4, 0]` across
  the seam; N=1 returns `[0]` forever rather than running out. The shipped
  `zodiac_quiz.v1.json` cannot exercise any of this — every set ships exactly
  `questions_per_round` questions today — so these run on fixtures, and a
  separate case pins the shipped shape (round == set length repeats).
- **Append-only enum** — the P2 change to `ActivityCardOrigin` is an append;
  `activity_card_test.dart`'s own "the four earlier values keep their positions"
  assertion still passes, and `cubit` test "the card carries the zodiac origin,
  the idea status and the suggestion title" pins `zodiac_shell` end to end
  through `createCard`.

### A tail-freeze the append had to retire

Appending `zodiacShell` broke exactly one assertion elsewhere,
`mobile/test/features/activity_cards/activity_card_test.dart:53`:

`expect(ActivityCardOrigin.values.last, ActivityCardOrigin.dateScript);`

That line pinned the *tail* of an enum whose own contract is append-only, so it
was guaranteed to break on the next append — the very thing the two lines above
it exist to allow ("append-only: the four earlier values keep their positions",
still passing). It now asserts `date_script`'s own index instead, which is what
append-only actually promises and what survives STORY-012's append too. A new
case pins `zodiac_shell`'s wire value and its position behind `date_script`.

Verified as the only breaking assertion before touching anything:
`activity_card_status_test.dart:29` iterates all values without pinning the
tail, and `conversation_starters/calendar_event_service_test.dart:418` pins only
the first five. The file is inside this run's registered `write_scope`.

### Design notes worth carrying into P3

- `ZodiacShellState` has no question index and no round length. A progress bar,
  a "câu 2/5", or a "đã hết" line is not merely unrendered — it cannot be built
  from this state (AC-18/AC-19/AC-31). P3 should not add one.
- The rotation cursor is stored already reduced modulo the set length, so the
  number on disk is a position, never a tally. "How many have I played" is
  unanswerable from storage, not just unexposed.
- `ZodiacShellCubit.undoAddToCards` lives here, not in P3, because P3's write
  scope holds only screens/widgets/arb/tests and its 5-second undo snackbar
  needs a door to delete the card it just created.
- Notebook enrichment folds free text to the packs' ASCII tag vocabulary
  (lowercase, Vietnamese diacritics folded, contiguous runs of up to three
  words joined by `_`). No such helper existed in the repository. Punctuation
  ends a phrase so `cà phê, sách` cannot invent `phe_sach`; spaces do not. A
  notebook that throws — the signed-out case, since the notebook door needs a
  resolved backend user id — is treated exactly like an empty one, and never
  reaches a state P3 could render as an error (AC-25/BR-4).
