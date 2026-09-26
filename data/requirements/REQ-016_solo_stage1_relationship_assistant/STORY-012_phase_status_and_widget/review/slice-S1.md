# Review Slice S1: phase-P1 content packages + invariant gate

Phase: SCOPED_SLICE
REVIEW_SLICE_COMPLETE: YES

## Identity

- Story: `STORY-012_phase_status_and_widget` (REQ-016)
- Slice: S1 per `review/scope-gate.md` §`Source/Test Files In Scope`
- Diff baseline: `b58afbe073eff4e1ebb9151735221532a9cf5a82`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-012_phase_status_and_widget`
- Diff shape: 8 files, all new, 1270 insertions, 0 deletions.

## Files Reviewed

| File | Lines added |
| --- | --- |
| `mobile/assets/data/req016/phase_content.v1.json` | 69 |
| `mobile/assets/data/req016/nudges.v1.json` | 42 |
| `mobile/assets/data/req016/drip.v1.json` | 40 |
| `mobile/lib/features/phase_status/domain/phase_content.dart` | 259 |
| `mobile/lib/features/phase_status/domain/phase_content_gate.dart` | 74 |
| `mobile/lib/features/phase_status/data/phase_content_repository.dart` | 103 |
| `mobile/test/features/phase_status/phase_content_gate_test.dart` | 371 |
| `mobile/test/features/phase_status/phase_content_repository_test.dart` | 312 |

Two files outside the slice were touched by narrow query only, and are named
here so the synthesis pass knows they were not re-reviewed:
`mobile/lib/core/content/invariant_terms.dart` (grep for the `InvariantRule`
enum, to prove the gate is non-vacuous) and `mobile/pubspec.yaml` (grep for the
asset declaration, to prove the packs resolve through the real bundle).

## Verification Evidence

Command, run from the worktree `mobile/` directory:

```
flutter test test/features/phase_status/phase_content_gate_test.dart \
             test/features/phase_status/phase_content_repository_test.dart
```

Result: `00:00 +35: All tests passed!` — 35 passing, 0 failing, 0 skipped.

## AC And Invariant Verdicts

### AC-1 (SB-83 prepare-not-guess, R-1b) — PASS, content half only

All three `phase_id: "waiting"` lines steer the reader to a concrete
preparation action the user performs alone, and none of them carries an
inference about the other party:

- `phase.waiting.prepare.v1` — "Chuẩn bị dần cho buổi tới" / "Bạn có thể chọn
  trước một chỗ mà bạn thấy hay"
- `phase.waiting.notebook.v1` — "Một việc nhỏ bạn tự làm được hôm nay"
- `phase.waiting.quiet_note.v1` — "Lời mời của bạn đã gửi đi rồi" (a statement
  about the user's own past action, not about the recipient)

The R-1b half is additionally enforced, not merely observed: every display
string of every pack is measured against `InvariantRule.recipientBehaviour` by
`validatePhaseContentPackages`, and `phase_content_gate_test.dart:243-254`
proves each denied term of that rule is caught in a phase line.

Scope note: the screen-side half of AC-1 — that screen (1) actually routes the
user to the prepare surface when an un-answered invited card exists — is
resolver/presentation behaviour and belongs to S2, not S1.

### AC-37 / R-15a (content is a schema'd data package, not code strings) — PASS

- Three packs ship with a pinned `schema_id` (`req016.phase_content.v1`,
  `req016.drip.v1`, `req016.nudges.v1`), a `version`, a `locale`, and a durable
  per-item id. `phase_content.dart:6-21` holds the ids and asset keys as the
  single declaration site.
- A wrong `schema_id`, a duplicate item id, an unknown `phase_id`, an unknown
  `surface`, an unknown nudge `slot`, and a present-but-empty optional string
  each throw `ContentPackageFormatException` rather than degrading to an empty
  or defaulted pack (`phase_content_repository_test.dart:147-243`). That is what
  makes R-15a's "loud, never degraded" clause real: this story's legitimate
  empty states are visually identical to a silently dropped pack.
- Non-vacuity check on the load path: both test files read the packs from disk
  (`File(assetKey)` / `_DiskBundle`), so neither exercises `rootBundle`. A pack
  missing from the asset manifest would therefore still pass both suites while
  failing on device. Confirmed registered at `mobile/pubspec.yaml:104-105`
  (`assets:` → `- assets/data/req016/`), so the real bundle path resolves.
- BR-15's acceptance test — "swap the source to an out-of-repo CMS without a
  single code change" — holds in the form available to this story: nothing in
  Dart knows a line's text, only its asset key and schema id, so regenerating
  the three JSON files from a CMS at build time touches no Dart. A *runtime* CMS
  fetch is separately banned by AC-34/BR-13, so that is the only reading of
  BR-15 the requirement leaves open.
- Scope note: AC-37's sharpest clause — no hardcoded strings in the **widget**
  code — is enforced against the native surfaces by S3's
  `native_copy_scan_test.dart` and is not decided here.

### AC-38 / R-15b (N is a data attribute) — PASS within slice

- An empty drip pack parses and passes the gate as a legal shipped state
  (`phase_content_gate_test.dart:217-235`), so the N ≥ 0 clause holds at the
  data layer.
- The milestone thresholds are package data read off the `nudges.v1.json` root
  (`thresholds: [5, 10, 25, 50, 100]`), not a Dart constant and not a backend
  value, and come back ascending, deduplicated, and unmodifiable
  (`phase_content.dart:227-259`). This is BR-16's requirement met literally.
- The "no AC may be derived from the seed count" clause is enforced by a running
  scan, not by convention: `phase_content_gate_test.dart:343-355` walks every
  `.dart` file under `lib/features/phase_status` and fails on any
  `items|package|phaseContent|drip|nudges|thresholds` `.length` read. The scan is
  non-vacuous — it resolves real files off disk via
  `Directory(...).listSync(recursive: true)`.
- Scope note: the *behavioural* half of AC-38 — that a drained drip store goes
  silent rather than relaxing the BR-9 frequency ceiling — lives in
  `drip_cadence_policy.dart` and is S6a's verdict, not S1's.

### AC-39 / R-15c (the invariant rules are a running import gate) — PASS

- `validatePhaseContentPackages` measures *every* reader-visible string of all
  three families, including the optional `secondary` and `title`, via each
  item's `displayStrings` (`phase_content.dart:125`, `141`, `162`). An absent
  optional string is correctly not a violation.
- The gate delegates every rule to the shared `InvariantRule` /
  `invariantDeniedTerms` table rather than declaring a family-local copy. The
  shared enum covers all four categories AC-39 enumerates — `recipientBehaviour`
  (R-1b/R-1e/AC-23), `flattery`, `percentDisplay`, `streakDisplay` — plus
  `scoreOrRatio` and `manipulativeTone`. The gate is therefore not vacuous with
  respect to any category the AC names.
- The rejection tests iterate the *entire* denylist (`for (entry in
  invariantDeniedTerms.entries) for (term in entry.value)`) across all three
  package families, so adding a term to the shared table automatically extends
  coverage instead of silently leaving a hole.
- R-15c's anti-duplication clause is itself tested:
  `phase_content_gate_test.dart:324-341` fails if any `phase_status` source
  redeclares a denied term, after stripping string literals and line comments so
  that dartdoc explaining the rule is not mistaken for a second copy of it.
- The three shipped packs report zero violations when read from disk
  (`phase_content_gate_test.dart:190-199`), which is the clause that makes a
  violating line turn a run red rather than reach a reader.

## Findings

### M-1 (MINOR, non-blocking) — the gate reddens the test run, and nothing else

AC-39 says a violating item must "làm hỏng bản dựng". The gate is enforced by a
unit test, so it reddens `flutter test`, not `flutter build`. The repository has
no CI job that runs `flutter test` — `find .github/workflows` returns
`deploy-backend.yml` and `deploy-web.yml` only. The gate is consequently as
strong as the delivery test gate and no stronger: a content author who edits a
pack and ships without running the suite is not stopped by machinery. This is a
repo-level CI gap, not a defect in the S1 code, and the mechanism AC-39 asks for
does exist and is non-vacuous. Recorded for the synthesis pass to weigh against
the story's other CI-dependent gates rather than as an S1 blocker.

### M-2 (MINOR, non-blocking) — the source scan misses suffixed forms

`_standaloneTerm()` (`phase_content_gate_test.dart:20-22`) brackets the term
with `(?<![a-z0-9_])` / `(?![a-z0-9_])`. The comment correctly explains why `\b`
was rejected (Dart's word boundary is ASCII-only, and several denied terms
begin or end with a non-ASCII letter). The consequence is that an inflected form
such as `streaks` escapes the scan, because the trailing `s` fails the
lookahead. This affects only the R-15c *anti-duplication* source scan, never
content validation, and the narrower form is the deliberate trade that keeps
contract-fixed storage keys such as `phase_status.drip.seen_ids` from being
flagged. No change requested.

### M-3 (INFORMATIONAL) — cross-slice dependency to carry into synthesis

The matching semantics AC-39 ultimately rests on live in
`mobile/lib/core/content/invariant_terms.dart` (`invariantHitsIn`,
`invariantDeniedTerms`), which is pre-existing shared code, absent from this
story's diff, and outside every slice in `scope-gate.md`. S1 verified that the
rule *enum* covers each category AC-39 names; it did not review how each term is
matched. If no other slice owns that file, the synthesis pass should record it
as a reviewed-by-reference dependency rather than as verified code.

### M-4 (INFORMATIONAL) — `nudges.v1.json` is decoded twice per load

`PhaseContentRepository._milestoneThresholds()` re-reads and re-decodes the
nudges asset because `ContentPackageLoader` does not surface package root keys.
The code comments the trade and the bundle caches the string, so the cost is one
extra decode of a 42-line file, once, behind a cached future. No change
requested.

## Residual Risks For Synthesis

- AC-1 screen-side routing → S2.
- AC-37 widget-code hardcoding clause → S3 / S4.
- AC-38 exhaustion-silence and BR-9 ceiling behaviour → S6a.
- Whether any slice owns `lib/core/content/invariant_terms.dart` (see M-3).
- Whether the story's test gate is run by anything other than the delivery
  pipeline (see M-1).
