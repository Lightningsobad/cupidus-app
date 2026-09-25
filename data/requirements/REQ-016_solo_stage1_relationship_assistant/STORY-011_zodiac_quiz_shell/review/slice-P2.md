# Slice Review: STORY-011 — P2 Deterministic Session

Outcome: PARTIAL_SLICE_ONLY

Review type: `scoped-slice` (slice 2 of 4). This verdict scopes ONLY phase P2.
Story closure belongs to the later fresh final-synthesis pass.

- Scope gate: `review/scope-gate.md` (P1 pass; scope fields below extend it for P2)
- Diff baseline for this slice: `git -C <Worktree> diff 731084ab 27700367`
- Blocking findings: 0
- Deferred findings: 2

## Scope of this slice

Source/test files in scope (8): `activity_cards/domain/activity_card.dart`,
`zodiac_shell/data/zodiac_rotation_store.dart`,
`zodiac_shell/domain/zodiac_shell_resolver.dart`,
`zodiac_shell/presentation/cubit/zodiac_shell_cubit.dart`, and the four matching
test files under `test/features/`.
Evidence in scope: `coding-plan/phase-P2-deterministic-session.md`,
`coding-plan/test-results.md` §"Phase P2 — Deterministic Session (Mobile)"
(lines 109-197), `coding-plan/master-plan.md` §3A/§5.
Not judged here: P3 result-surface screens, P4 entry-point wiring, and every
story-level mobile gate.

## Acceptance Criteria — phase P2 §4

| # | Acceptance criterion | Verdict | Evidence |
|---|----------------------|---------|----------|
| 1 | Same `(setId, answers, notebookTags)` → same `outcomeId` and same 3 suggestions, repeated | PASS | `ZodiacShellResolver.resolve` is a static total function of its four arguments with no clock, no `Random`, no I/O and no cursor (`zodiac_shell_resolver.dart:36-48`). The rotation cursor never reaches the mapping — it selects *which* questions are asked, which is the `solution.md` §3 assumption. Tests: resolver test:94 (resolves five times, asserts one distinct outcome id and one distinct suggestion-id sequence); cubit test:108 repeats it against the shipped assets *after* the cursor advanced, which is the assertion that actually proves the separation. |
| 2 | No `DateTime.now` token under `lib/features/zodiac_shell/` | PASS | Independent grep over the module for `DateTime`, `Random`, `Timer`, `Stopwatch` returns one hit only — the prose in the resolver's doc comment at :31. Enforced going forward by resolver test:123, a recursive scan of every `.dart` under the module, so a file added by a later phase is covered too. |
| 3 | Playing past the end wraps to the start in the same order; no "exhausted" state; no count on the store's public API | PASS | `nextWindow` is the store's only public method (`zodiac_rotation_store.dart:32`) — there is no `remaining`, `played`, or `isExhausted` to call. The cursor is written back already reduced modulo `total` (:54), so "how many rounds have I played" is unanswerable from the stored value rather than merely unexposed. Tests: rotation store :34 (7-question set over 16 rounds, rounds 8-14 repeat 1-7 in order), :49 (window wrapping across the seam), :76 (N=1 keeps returning `[0]` instead of running out), :118 (stored number never grows past the set), :131 (nothing else is written). |
| 4 | An empty notebook and a throwing notebook both yield exactly 3 suggestions | PASS | `_notebookTags` catches `Object` and returns `const []` (`zodiac_shell_cubit.dart:211-227`) — no error state is emitted, so no P3 screen can render one. `_suggestionsFor` then fills from pack order to exactly `minimumSuggestionsPerOutcome` (`zodiac_shell_resolver.dart:129-146`). Tests: cubit :160 (empty), :170 (throws, and asserts no error state), resolver :156. |
| 5 | `ActivityCardOrigin.values` keeps its order and old `wireValue`s; the new value is last | PASS | The diff on `activity_card.dart` is `+2 -1` — a pure append of `zodiacShell('zodiac_shell')` after `dateScript`, with no other edit and no new field on the card contract. Tests: the existing "the four earlier values keep their positions" case still passes, plus a new case pinning `zodiac_shell`'s wire value and its position behind `date_script`. |

## Contract invariants this slice owns (§3A risk surfaces)

| Risk surface | Verdict | Evidence |
|--------------|---------|----------|
| Tất định, không xoay theo ngày | PASS | AC 1 and 2 above. Nothing in the module reads a clock, so "what the app told me yesterday" and "what it tells me today" cannot diverge. |
| N là thuộc tính dữ liệu (R-15b/AC-31) | PASS | `nextWindow` takes `total`/`perRound` off the set, never a constant; `ZodiacShellState` carries no question index and no round length, so a progress bar or "câu 2/5" cannot be built from the state at all (`zodiac_shell_cubit.dart:16-21`). Rotation fixtures cover N=1 and N=7 with the same behaviour. |
| Hợp đồng thẻ chỉ-đọc (BR-7) | PASS | `addToCards` supplies `title` plus the new origin and nothing else (`zodiac_shell_cubit.dart:187-194`); status is the repository's *Mới nghĩ ra*. The `+2 -1` diff is itself the proof that the card contract gained no field. Cubit test:248 pins origin, status and title end to end through `createCard`. |
| Ngoại tuyến / không AI (AC-22/AC-23) | PASS | No transport import under the module. P1's import scan is recursive over `lib/features/zodiac_shell` (gate test:180-181), so it now covers P2's new `data/` and `presentation/` files without needing a second scan — I verified the scan root rather than assuming it. |

## Test evidence (test-results.md §P2, lines 109-197)

| Gate | Verdict | Note |
|------|---------|------|
| Targeted unit: resolver, rotation store | PASS | Test-name inventory read directly; each §6 required level has real assertions behind it, including the "impossible arguments" and "a value this store did not write" groups, which are beyond what §6 asked for. |
| Integration: cubit over `ContentPackageLoader` with the real assets + fake `ActivityCardRepository` | PASS | Cubit test:94 plays *every* shipped set through to a result, which is the assertion that makes the shipped pack's shape (round length == set length today) a tested fact rather than an assumption. |
| Regression `test/features/activity_cards/` | PASS | Required by §6 because the phase edits `activity_card.dart`; run as the combined third row, `+457 ~5`, 0 failures. |
| Scoped `flutter analyze` over the write scope | PASS | `No issues found!`. Scoping is legitimate and correctly explained: the repo baseline is 222 warnings / 0 errors, so a whole-tree run carries no signal. Delta 0. |
| Per-story visual fidelity | NOT_APPLICABLE (this slice) | P2 builds no widget and changes no UI surface. The implemented capture and the `VISUAL_FIDELITY:` verdict belong to P3 and to the story-level synthesis. |
| Runtime startup smoke | NOT_APPLICABLE (this slice) | Phase §1B/§6 record `Startup Smoke: NOT_APPLICABLE` / `Runtime startup smoke: NO`. The story-level mobile smoke gate remains open and is the synthesis pass's to enforce. |
| Entry point reachability | NOT_APPLICABLE (this slice) | Owned by P4. |

### Independent rerun

I reran `flutter test test/features/zodiac_shell/` in the story worktree to
settle the count discrepancy in D-P2-1 below. Result: `+142 ~4: All tests
passed!` — 142 passing, 4 skipped, 0 failures. Note what this does and does not
prove: it ran at the story HEAD, so it covers P1 + P2 + P3 tests together in the
integrated tree. It is not a reconstruction of the tree at commit `27700367`.
What it establishes is that no P2 code is red now and that P1's 67 tests still
pass alongside it — the regression question the mislabelled row left open.

## Deferred findings

**D-P2-1 — the first evidence row's command and its count do not agree.**
`test-results.md:118` records `flutter test test/features/zodiac_shell/` →
`45/45 PASS`, and the line under it decomposes the 45 across the three files
this phase added. But at commit `27700367` that directory already held P1's 67
tests, so the command as written would have reported 112, not 45. The 45 is the
new files only; either the command was actually scoped to those three paths or
the count was transcribed from a narrower run. No correctness consequence — the
third row's combined `+457 ~5` covers the regression, and my rerun above shows
the directory green — but a command whose written form does not match its
reported count is exactly the shape that lets a stale number hide a regression
later. Owner: Mobile Developer — correct the row to the command that was
actually run. Non-blocking: the underlying gate passed, only its label is wrong.

**D-P2-2 — the cubit has no failure path for pack loading, so a load error
leaves the session with no way forward.** `load()` lets a
`ContentPackageFormatException` propagate and emits nothing, so the state stays
`ZodiacShellStage.loading`; and if `_outcomes` is still null when the round's
last question is answered, `answer()` returns silently
(`zodiac_shell_cubit.dart:150-153`), leaving the user on the last question with
each further tap appending a dead answer. Neither path crashes and neither is
reachable with the shipped packages — P1's gate plus its real-asset parse test
make a shipped-pack load failure a build-time impossibility, and §3 mandates
`try/catch` only for the notebook, which is implemented exactly as specified.
Deferred rather than blocking for that reason. Carrying it because the stuck
state is only invisible while P3's screens are not yet reviewed: the P3 slice
should check what `ZodiacShellStage.loading` renders forever. Owner: Mobile
Developer, if P3 review finds the loading stage has no timeout or retry.

## Note on an assertion this phase retired (not a finding)

`activity_card_test.dart:53` previously pinned `ActivityCardOrigin.values.last`,
which froze the tail of an enum whose own contract is append-only — it was
guaranteed to break on the next append. Replacing it with `date_script`'s own
index is the correct reading of append-only, and it is the assertion that
survives STORY-012's append too. The phase verified it was the only breaking
assertion before changing it (`activity_card_status_test.dart:29` iterates
without pinning the tail; `calendar_event_service_test.dart:418` pins only the
first five). I re-read the diff and agree: this weakens no real guarantee, and
the two sibling call sites were genuinely checked rather than asserted.

## Traceability

- Requirements: AC-3/AC-7/AC-18/AC-19/AC-21/AC-24/AC-25/AC-31/AC-32,
  BR-4/BR-7/BR-13, cited at the assertion sites above.
- OQ discipline: no unresolved OQ touches this slice. R-15b (N as data) is
  implemented as a structural property of the state and of the stored cursor,
  not as a rule a widget is trusted to follow.
- Architecture: `contract-summary.md` §2 (the single rotation key
  `zodiac_shell.rotation_cursor.v1`) and §4 honoured; `solution.md` §3's AC-21
  assumption — the notebook is an input, so a notebook that gained an entry may
  change the three suggestions without breaking determinism — is implemented as
  written and tested that way.
- ADR-010: the store uses one `SharedPreferences` string, so no Drift table and
  no `schemaVersion` bump. Worth recording explicitly, since a schema bump on a
  parallel story branch is a known collision source in this requirement.
- Configuration guide: phase §1B records `Update Required: NO`; this slice adds
  no env var, credential, service, or manual setup step. Confirmed.

## Recommendation

No P2 finding blocks the story. Carry D-P2-1 and D-P2-2 into the final
synthesis, and point the P3 slice at D-P2-2 specifically. The story's outcome
still depends on slices P3-P4 and on the story-level mobile gates (runtime
startup smoke, entry point reachability, implemented visual fidelity), which
this slice does not judge.
