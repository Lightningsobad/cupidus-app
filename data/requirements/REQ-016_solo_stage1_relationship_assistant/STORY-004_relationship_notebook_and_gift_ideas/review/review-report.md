# STORY-004 — Story Review Report (final synthesis)

Outcome: DEFERRED_ONLY

Canonical review gate for
`REQ-016_solo_stage1_relationship_assistant/STORY-004_relationship_notebook_and_gift_ideas`.
This file supersedes the previous final-synthesis pass, which returned the story
for rework on F6. F6 has since been fixed and independently re-reviewed.

- Mode: final-synthesis (Tier-3 Scoped Slice + Fresh Final Synthesis)
- Reviewer: Iris-QC (fresh spawn, no prior context on this story)
- Date: 2026-09-11
- Branch: `codex/REQ-016_solo_stage1_relationship_assistant-STORY-004_relationship_notebook_and_gift_ideas`
- Worktree HEAD at review: `b1feb3ddc27490adeb24ea769d2dcf49889c2ffc` (the F6 fix;
  same sha as the handoff's `BaseHead`)
- Slice-chain diff baseline: `e5b3741743744241cd8cfb60543cf6d37f0ec946`
- Story class: complex, shared-foundation. Lane: mobile.

## Scope Gate

Eight slice reports read in full or by range; no slice left an item `UNVERIFIED`.

| Slice input | Scope | Slice result |
|---|---|---|
| `review/slice-P1.md` | Drift v6 persistence, notebook schema | all scoped items PASS |
| `review/slice-P2.md` | shared invariant gate, context packs | all PASS, 4 LOW/INFO |
| `review/slice-P3.md` | ask-on-the-spot shared surface | 10/10 PASS, 1 blocker since fixed |
| `review/slice-P4.md` | notebook + skill screens, menu | all PASS, 5 LOW/INFO |
| `review/slice-P5-P6.md` | gift packs/gate, repository, selector | all PASS, 1 MAJOR traceability item |
| `review/slice-P7.md` | gift screen, quick-entry, push-to-hub | 12/13 PASS, F1 FAIL, F2/F5 gate items |
| `review/slice-P7-patch.md` | design-anchor patch `c618914` | F1/F2/F3 closed, F6 MAJOR FAIL new |
| `review/slice-F6-fix.md` | the F6 fix at `b1feb3d` | F6 CLOSED, AC-18 risk not realized, 2 new minors |

Source re-opened at this pass, deliberately and narrowly, because the whole
verdict turns on one commit: `git show b1feb3d` over
`gift_ideas_cubit.dart` and `gift_ideas_screen.dart` (the complete source diff,
~85 lines), plus governing AC text at `requirements/requirements.md:156-162`
(AC-18) and `:236-249` (AC-33, AC-34). Nothing else was reread; every other row
below cites its slice.

## Verdict on the three questions this handoff asked

**1. Is F6 (AC-33) closed? YES — confirmed in the diff, not taken from the slice.**

`GiftIdeasState.withDismissed` now computes
`exhausted = suggestions.isNotEmpty && suggestions.every(dismissed.contains)`;
on exhaustion it returns `dismissedGiftIds: const <String>{}` and advances
`roundStartGiftId` to the idea after the round's lead. `visibleSuggestions`
additionally falls back to the whole ranked list when a filter change narrows
`suggestions` down to already-dismissed ideas — that is the AC-18 path, and it is
a genuinely distinct second case, not a restatement of the first. The screen's
no-match line moved from `visible.isEmpty` to `state.suggestions.isEmpty`, so the
AC-34 defined-empty branch is the only way that sentence is now reachable.

Hand-traced at both ends of AC-33's stated range (`N ≥ 1`, "3, 10, hay vài trăm"):
at `N = 1`, `afterLead.isEmpty ? round.first` re-seats the single idea and clears
the set, so the reader sees it again rather than an empty screen; at `N = 3`,
round leads advance A → B → C → wrap, indefinitely. At no N does the flow produce
an "đã hết ý tưởng" message, a dead-end screen, or a count/percentage/remaining
indicator. All four of AC-33's literal prohibitions hold, and the required
positive behaviour — `quay vòng tất định` — is the one implemented.

**2. Are F7 and F8 blocking? NO — both deferred, reasoning below.**

**3. One story verdict: `DEFERRED_ONLY`.** No blocking findings remain.

## Rationale for not blocking on the new F7

The rotation defect is real and I reproduced it from the diff rather than
accepting it: `visibleSuggestions` calls `_startingAtRound(remaining)`, where
`remaining` has already had the dismissed ideas removed. The round's lead **is**
`roundStartGiftId` and it is the first thing dismissed in a new round, so
`indexWhere` returns `-1` on that very next build, `start.isNegative` takes the
untouched branch, and the list reverts to unrotated ranked order for the rest of
the round. `_startingAtRound`'s own doc comment attributes the `-1` case to a
filter change only; dismissing the round lead is the case it did not anticipate.
Concretely at `[A,B,C]` after the first wrap: `[B,C,A]` → dismiss B → `[A,C]`
where the getter's documented model gives `[C,A]`.

It does not block, for three reasons that are about the AC and not about
convenience:

1. **No clause of AC-33 is violated.** The AC legislates four prohibitions and
   one required behaviour. All five hold at every N. It says nothing about the
   order within a round; it requires that cycling be deterministic, and this is
   deterministic — same state in, same list out, so AC-28 also still holds.
2. **The cross-round cycle is intact, which is the part the AC is about.** The
   wrap computes `round = _startingAtRound(suggestions)` against the *full*
   ranked list, where `roundStartGiftId` is always present, so the round lead
   advances correctly every wrap and every idea takes its turn at the lead. The
   defect is confined to intra-round ordering after one specific tap.
3. **The user-visible harm is a repeat arriving one tap early**, in a flow whose
   defined behaviour is to repeat the whole pack forever. Nothing is persisted,
   nothing is lost, and nothing is unreachable.

This is a quality defect inside a satisfied AC. Under the reviewer skill's own
split — block on what breaks acceptance, defer what does not — it is D-1 below,
with the one-line fix direction recorded so the follow-up lane does not have to
re-derive it. F8 is a test-coverage nit on a branch that is correct by reading
and by hand trace, and is D-2.

## Acceptance criteria

Thirty-six criteria, all traced against `requirements/requirements.md` text
(SKILL rule 14: the AC's text governs, not a plan file's citation of it).

PASS, owning slice in brackets — AC-1/AC-2/AC-3 [P3], AC-4/AC-6/AC-9 [P1+P4],
AC-5/AC-7/AC-8 [P4], AC-10/AC-11 [P2+P3+P4], AC-12 [P1+P4], AC-13 [P5-P6],
AC-14 cl.2 [P7-patch], AC-15 [P5+P7-patch], AC-16/AC-19 [P5 gate + P7 scan],
AC-21/AC-22/AC-23 [P7+P7-patch], AC-24 [P7-patch], AC-25 [P1+P4+P7-patch],
AC-28 [P6], AC-29 [P4], AC-30 [P7-patch], AC-32 [P2+P5+P7], AC-36 [P2].

The rows that are not a plain PASS:

| AC | Subject | Verdict | Note |
|----|---------|---------|------|
| AC-14 cl.1 | Lọc theo dịp × **giai đoạn quen nhau** × sổ tay | PARTIAL | 2 of 3 axes exist. The stage axis exists in no artifact below `requirements.md`. Requirement-level, see D-A. |
| AC-17 | Bộ lọc "2 tiếng tối nay" | PASS (reservation) | Ceiling filter correct [P6]; the tier *labels* are pack data, see D-D. |
| AC-18 | Nhánh không-tốn-tiền trả về **không rỗng** | PASS | Was AT RISK under F6. The `remaining.isEmpty ? suggestions` fallback closes it; a dedicated widget test now covers a dismissal carried into a narrower branch [F6-fix]. |
| AC-20 | Handmade nêu rõ kỹ năng, công sức **theo giờ** | PASS (reservation) | `_basis()` prefers the skill match; compact card renders minutes, see D-E. |
| AC-26 | Kết bằng câu để hỏi, đoán ở tầng "user đoán" | PASS (narrow) | `gift_ideas_guess_row` is an invitation, not a claim [P7-patch]. |
| AC-27 | Không đóng khung chiến thuật | PASS (1 test gap) | Rule wired, no gift-family fixture, see D-F. |
| AC-31 | Cổng ship + trạng thái duyệt truy vết theo id bền | PASS (reservation) | Durable ids hold; `editorial_review` ungated in the context family, see D-G. |
| AC-33 | Hết-tập là trạng thái êm đã định | **PASS** | Closed at `b1feb3d`, verified above. Intra-round ordering defect deferred as D-1. |
| AC-34 | Rỗng đã định; số bậc/nhánh là thuộc tính dữ liệu | PASS | N=1 and N=200 [P5-P6]; the two protected pack-driven items were left alone through both patch rounds [P7-patch]. |
| AC-35 | Cổng nhập từ chối kể cả nội dung CMS ngoài repo | PASS (CMS clause deferred) | Gate has no runtime caller; see D-B. |

## Findings ledger — final status

| Id | Origin | Severity | Status |
|---|---|---|---|
| P3-F1 | slice-P3 | BLOCKING | CLOSED — import boundary green at HEAD [P7 §6, P7-patch]. |
| P7-F1 | slice-P7 | MAJOR | CLOSED — AC-14 cl.2 met by `_ProvenanceLine` over all three context kinds, non-vacuous test [P7-patch]. |
| P7-F2 | slice-P7 | BLOCKING (procedural) | CLOSED — user anchored on DESIGN (`b516c48`, STORY-001 precedent); 5 authorized items reworked, 2 protected items left pack-driven [P7-patch §6]. Not re-litigated. |
| P7-F3 | slice-P7 | MINOR | CLOSED — `story_master.md:12-14` lists all three design screens [P7-patch]. |
| P7-F5 | slice-P7 | UNVERIFIED | CLOSED — Scrum Master ran the full mobile runtime smoke on `emulator-5554` (debug APK build → `adb install` → `am start -W` → resumed-activity poll → `force-stop`), all steps EXIT=0/READY. No waiver needed. |
| **F6** | slice-P7-patch | MAJOR | **CLOSED at `b1feb3d`** — verified in the diff at this pass. |
| P7-F4 | slice-P7 | MINOR (doc) | DEFERRED — D-H. |
| P7p-F7 | slice-P7-patch | MINOR (evidence) | DEFERRED — D-I. |
| P7p-F8 | slice-P7-patch | MINOR (evidence) | DEFERRED — D-J. |
| F6f-F7 | slice-F6-fix | MINOR (new) | DEFERRED — D-1. |
| F6f-F8 | slice-F6-fix | NIT (new) | DEFERRED — D-2. |
| P56-F1 | slice-P5-P6 | MAJOR (traceability) | DEFERRED to requirement level — D-A. |
| P2-F1..F4, P4-F1..F5, P3-F2/F3, P56-F2..F6 | various | MINOR/INFO | DEFERRED — rolled into D-C..D-G, D-K. |

Note on ids: `slice-P7-patch.md` and `slice-F6-fix.md` each number their new
findings F7 and F8, and they are four different findings. The `P7p-` and `F6f-`
prefixes above disambiguate them; use those ids downstream.

## Risk surfaces and critical gates

| Touched surface | Critical gate | Status |
|---|---|---|
| persistence / schema / migration (Drift v5→v6) | additive-migration test + forbidden-column set-equality | PASS [P1] |
| typed/generated contract (`.g.dart`, ARB l10n) | regeneration in the same commit; vi/en key parity | PASS [P1, P7-patch O3] |
| mobile interaction (3 screens, cards, chips, ask slot) | targeted widget/unit suites | PASS — `flutter test test/features/gift_ideas` → `+102 ~1 All tests passed!` at `b1feb3d`, re-run independently by the F6-fix reviewer and matching Scrum Master's own run |
| mobile navigation / discoverability | entry-point reachability, verified in code | PASS — hub quick-entry cell → `openGiftIdeasScreen` in both hub states, 4 widget tests [P7 §3]. Heading missing from the evidence file, D-H |
| static analysis | scoped `flutter analyze` | PASS — 0 errors, 0 warnings on the 3 touched files; 3 pre-existing `prefer_initializing_formals` infos outside the diff |
| content packs / build gate | from-disk pack validation, red-proven fixtures | PASS [P2, P5] — no runtime caller, D-B |
| app lifecycle / session state | dismissal set and round cursor are screen-lifetime, never persisted | PASS — no second store, AC-22/AC-25 hold |
| design fidelity (mobile lane, SKILL 12e2/12e3) | implementer captures, reviewer verifies | PASS — `visual-fidelity/visual-fidelity-report.md:1,150` `VISUAL_FIDELITY: PASS`; 3 design references and 9 implemented PNGs present; two independent slice reviewers opened the screen-5 images and compared them against the canvas rather than trusting the token [P7 §5, P7-patch §5]. `Design-Screen: 2-so-tay-nguoi-yeu, 3-ho-so-ky-nang-phien-ban-toi, 5-goi-y-qua-thang-cong-suc` recorded in `story_master.md`. `b1feb3d` changes no layout, so the captures remain current |
| runtime startup smoke (SKILL 12g, mobile) | app launches and reaches first screen | PASS — see P7-F5 above |

No setup/configuration impact: this story adds no env var, no service, no port,
no external integration, so SKILL 12a does not apply and no
`deployment/configuration-guide.md` change is required.

## Deferred items

- **D-1 (F6f-F7, MINOR, code).** `visibleSuggestions` rotates `remaining` (already
  filtered) instead of rotating `suggestions` and filtering after, so dismissing a
  round's own lead makes `_startingAtRound` return `-1` and the list silently
  reverts to unrotated ranked order for the rest of that round. Deterministic,
  never empty, violates no AC-33 clause; it contradicts the getter's own doc
  comment. Fix is one reordering of two operations in `visibleSuggestions`:
  rotate `suggestions` to `roundStartGiftId` first, then drop `dismissedGiftIds`
  from the rotated list. `rotate([A,B,C], B) = [B,C,A]` minus `{B}` → `[C,A]`.
  Pair it with a state-level test that dismisses past a wrap and asserts the lead
  two taps into round two.
- **D-2 (F6f-F8, NIT, test).** No state-level test for the single-idea pack:
  `gift_selector_test.dart` covers `nextBatch` at N=1, but `GiftIdeasState`'s
  `afterLead.isEmpty ? round.first` branch is unguarded. Correct by reading and by
  hand trace at this pass; needs a fake single-idea catalogue to cover. Fold into
  D-1's patch.
- **D-A (MAJOR, requirement-level, needs Product Owner).** AC-14 clause 1's
  "giai đoạn quen nhau" axis exists in no artifact below `requirements.md` —
  not `architecture/contract-summary.md`, `coding-plan/master-plan.md`, or
  `ux/uiux-spec.md` — and `GiftContextKind` is a closed `interest`/`event`/`skill`
  set. The axis was descoped upstream of implementation, so P5/P6 built the
  contract they were pointed at and this is not a developer defect. Note the BR-16
  tension: adding it later needs a fourth enum value, i.e. a Dart edit, which cuts
  against content-as-data. **Must be adjudicated before REQ-016 integration
  review**, not at story-DONE time. Classification carried unchanged from the
  prior synthesis and independently agreed here.
- **D-B (residual, requirement-level).** AC-35's final clause — the gate runs even
  for out-of-repo CMS content — is not satisfied: neither `validateContextPacks`
  nor `validateGiftPacks` has a caller in `mobile/lib`; both run only under
  `flutter test`. Shipped packs *are* gated from disk at CI time, so the exposure
  is a pack edited without running the suite, not an unvalidated production path.
  The same shape shipped in merged STORY-002 and no CMS exists in the repo.
  Deliberate requirement-level deferral, as slice-P2 asked synthesis to decide.
- **D-C (documentation).** AC-id citation drift, 11+ logged instances across the
  phase files, the P6/P7 planning artifacts, and `slice-P7.md`'s own verdict
  table. Code and tests use the correct ids throughout. The table in this report
  is filed against `requirements.md` text and supersedes every earlier table. One
  cleanup pass on the phase files would stop the drift being re-copied.
- **D-D.** Effort-tier labels ship as "Trong 30 phút / Một tới hai giờ / Trọn một
  buổi"; neither `uiux-spec.md` Phần D's "làm được trong 2 tiếng tối nay" nor the
  canvas's single chip appears. Correct under AC-32/AC-34/R-15b — labels are pack
  data — so this is an untaken content decision, not a code defect.
- **D-E.** The compact card renders effort in minutes (`240'`) while AC-20 says
  "theo giờ". Pack-derived, and the canvas draws minutes too. Pack/format question.
- **D-F.** `manipulativeTone` is the one shared invariant rule with no gift-family
  fixture, and it is the rule AC-27 exists for. Wired, not proven. One fixture in
  the AC-26 group closes it.
- **D-G.** `editorial_review` is parsed but ungated in the context-pack family
  (the preset family has `editorialReviewIncomplete`). AC-31's traceability half
  holds via durable ids; the asymmetry between gate families is the residual.
- **D-H (P7-F4).** `coding-plan/test-results.md` has no `## Entry Point
  Reachability` heading. Documentation only — the entry point is real, verified
  in code by two independent slice reviewers, and covered by four widget tests.
- **D-I (P7p-F7).** `implemented-5-goi-y-qua-thang-cong-suc-md-full.png` clips
  before the guess row despite `visual-fidelity-report.md:170-176` introducing it
  specifically to evidence that row. Evidence defect, not a product defect: the
  row has two widget tests including a geometric below-every-card assertion.
  Correct the claim or take a taller capture.
- **D-J (P7p-F8).** `visual-fidelity-report.md:59-64`'s Authority note still
  states an unscoped "spec beats canvas" rule that §P7 lines 220-231 retracts.
  Needs a one-clause phase qualifier.
- **D-K (carried, low).** Notebook rows written inside the same second order
  arbitrarily-but-stably, contradicting the facade's "Newest first" doc comment
  (no AC imposes ordering); `AskOnTheSpotSlot.entryPointId` is contract-required
  but never read; `eventOn` is written and rendered by nothing; repo-wide
  `flutter analyze lib test` still exits 1 on a pre-existing ~217-issue info
  baseline that predates this story.

## Conclusion and state recommendation

Across 36 acceptance criteria this story holds up: forbidden columns are enforced
by executable set-equality, the content packs are real data with durable ids
behind a build-breaking gate with red-proven fixtures, the selector is
deterministic by construction, there is no second store and no price field
anywhere, and the two design-vs-pack items the user's design-anchor decision did
*not* authorize were correctly left alone through two patch rounds. Every
blocking item raised across eight slice passes — P3-F1, P7-F1, P7-F2, P7-F5 and
F6 — is now closed, each verified against code or first-hand evidence rather than
accepted from a report.

The one open code item, D-1, sits inside an acceptance criterion that passes. It
makes a repeat arrive one tap earlier than the ideal model in a flow whose whole
purpose is to repeat forever, and returning the story a third time for it would
buy less than it costs. It is recorded with its exact fix so a follow-up round or
the requirement integration pass can take it cheaply.

Recommendation to Scrum Master:

- keep `Implementation (Development)` checked
- check `Review (Reviewer)`
- story status `DONE`
- carry D-A and D-B into REQ-016 integration review as requirement-level items
  requiring Product Owner adjudication before the requirement can close
- carry D-1 and D-2 as a bounded follow-up (one getter, one test file)
