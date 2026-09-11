# Slice review — P3 "ask-on-the-spot shared surface"

- Story: STORY-004_relationship_notebook_and_gift_ideas (REQ-016)
- Slice: P3 — `AskOnTheSpotSlot` + cadence policy + one-way facade
- Mode: scoped-slice
- Reviewer: Iris-QC
- Date: 2026-09-11
- Diff base: `e5b3741743744241cd8cfb60543cf6d37f0ec946`
- Worktree HEAD: `97f218c` (P7)
- Files reviewed: 6 (the declared slice set)

Outcome: PARTIAL_SLICE_ONLY

Slice result: all ten cited ACs/BRs PASS, with one blocking phase-invariant
regression (F1) that STORY-004 must resolve before it can be called clean.

## Independent verification run

```
cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter test --reporter compact \
  test/features/context_notebook/ask_cadence_policy_test.dart \
  test/features/context_notebook/ask_on_the_spot_slot_test.dart
→ 00:08 +22 -1: Some tests failed.
```

22 of 23 green. The single red is the phase's own import-boundary gate — see F1.
All ten AC/BR assertions below are among the 22 green.

## AC / BR verdicts

| Id | Verdict | Evidence |
|---|---|---|
| AC-1 | PASS | `ask_on_the_spot_cubit.dart:141-178` writes then emits `hidden` with no intermediate "saved" state. Tests `the answer disappears with no toast, dialog or save button` (asserts no `SnackBar`/`Dialog`/`AlertDialog`/`Lưu vào hồ sơ`/`Đã lưu`) and `the answer is written straight through and the flow re-runs` (`contextChangedCount == 1`). `ask_on_the_spot_slot.dart` builds no overlay, route, or messenger call anywhere. |
| AC-2 | PASS | Invariant is in the widget, not the caller: module-level `_routeClaims` map at `ask_on_the_spot_slot.dart:13-14`, claimed in `didChangeDependencies` (`:94-110`), released in `dispose` (`:121-125`); non-owner returns `SizedBox.shrink()` at `:129-131`. Tests `two slots on one route render one card, not two` and `the muted slot stays empty after the first one is answered`. Phase §6 minimum gate (two-slot test must exist) is satisfied — not `SHARED_CONTRACT_UNSTABLE`. |
| AC-3 | PASS | `ask_on_the_spot_cubit.dart:182-193` emits `hidden` **before** awaiting `recordPromptState`, so the user is never blocked on the write. Session scope is a set, not a clock (`ask_cadence_policy.dart:11-23`). Tests `skipping hides the card without blocking or scolding` (asserts no `Dialog`, no `chưa`, no `Hãy`) and `the skipped question is not asked again this session` (slot torn down and rebuilt; the skipped prompt does not return, the next one does). Policy-level coverage: 5 tests in group `bỏ qua là phạm vi phiên, không phải đồng hồ (AC-3)`. |
| AC-4 | PASS | Read-back goes through the facade, not the repository: test `ContextNotebookReader sees what the card just wrote` calls `contextNotebookReader().entries(kind: NotebookKind.interest)` and finds the just-answered value. Facade impl `context_notebook_entry_point.dart:37-51`. |
| AC-5 | PASS | No route, dialog, or forced step exists in the slice: `_AskCard` (`ask_on_the_spot_slot.dart:167-276`) is an inline `Container`; nothing left to ask yields `SizedBox.shrink()` (`:141-143`). Test `nothing left to ask renders nothing, not an empty prompt` asserts no card, no `TextField`, no `Dialog`. |
| AC-10 | PASS | Free text is opt-in only. The `Khác...` chip renders instead of a field (`ask_on_the_spot_slot.dart:226-232`); the `TextField` appears only after `_freeTextOpen` is set (`:234-254`). Empty submissions are dropped at `:269-275` and again at `ask_on_the_spot_cubit.dart:146-149`. Tests `a free-text answer is opt-in, never the default box` (`find.byType(TextField) → findsNothing` before the tap) and `every required soft-skill seed is on screen before any typing` (same assertion on the skill path). |
| AC-11 | PASS | Skill questions draw chips from the `skill_seeds` pack, not from the question's own `chips` (`ask_on_the_spot_cubit.dart:116-136`), and declaration order is preserved — no re-ranking of the four required seeds to the front, which `uiux-spec.md` Phần C forbids. Test `every required soft-skill seed is on screen before any typing` asserts one chip per id in `requiredSkillSeedIds` and `requiredSkillSeedIds.length >= 4`; the list is 4 ids at `domain/context_content.dart:16-21`. Assertions track the constant rather than a copied list (`ask_on_the_spot_slot_test.dart:60-71`). Seed id round-trip verified by `tapping a seed stores it with its stable seed id`. |
| BR-1 | PASS | The only two write paths into context stay the inline ask and the user's own add; the facade exposes read-only `ContextNotebookReader` and deliberately no write method (`context_notebook_entry_point.dart:26-32`, documented at `:1-9`). No "fill this in first" gate exists. Additionally `ask_on_the_spot_cubit.dart:107-113` swallows every load failure into `hidden`, so a missing pack or unresolved owner key degrades the host flow to "no card" rather than an error the host must render. |
| BR-2 | PASS | `AskCadencePolicy.nextQuestion` returns exactly one question or `null` (`ask_cadence_policy.dart:43-83`); there is no batch/next-also entry point, so stacking two asks is not expressible against the API. Priority = `neededFieldIds` order first, package order within a target; answered dropped permanently; session-skipped excluded; previous-session skips queued behind never-asked ones (`:49-82`). Covered by 11 tests in `ask_cadence_policy_test.dart`. Unknown target id throws rather than silently skipping (`:53-60`, test `a target id outside contract-summary §2 is a caller bug, not a skip`). |
| BR-3 | PASS | "Bỏ qua" is a plain text link with no confirm step (`ask_on_the_spot_slot.dart:256-263`) and the flow continues immediately (see AC-3). No reproach copy: test asserts absence of `chưa` and `Hãy` substrings. Note this is a substring heuristic, not an exhaustive tone check — acceptable at this level, called out as residual risk R3. |

## Findings

### F1 — BLOCKING (phase invariant currently red)

Phase P3 §4 requires: "Không file nào ngoài `features/context_notebook/**`
import một symbol nội bộ của feature", and §6 lists it as a Required check.
The test that enforces it exists and is well built
(`ask_on_the_spot_slot_test.dart:384-448` — it resolves relative and
`package:` URIs before matching, so it is not the vacuous substring matcher
its own P3 evidence records as having been caught and fixed).

That test is **red at current worktree HEAD**:

```
biên giới import của feature no file outside features/context_notebook imports an internal [E]
  Expected: empty
    Actual: [
      'lib/features/gift_ideas/presentation/screens/gift_ideas_screen.dart -> ../../../context_notebook/data/context_notebook_repository.dart',
      'lib/features/gift_ideas/presentation/screens/gift_ideas_screen.dart -> ../../../context_notebook/domain/ask_cadence_policy.dart',
      'lib/features/gift_ideas/presentation/screens/gift_ideas_screen.dart -> ../../../context_notebook/domain/context_content.dart'
    ]
```

Introduced by commit `97f218c` ("P7 gift screen, quick-entry, push-to-hub"),
at `mobile/lib/features/gift_ideas/presentation/screens/gift_ideas_screen.dart:10-12`.

**This is not only a P7 discipline lapse — it is a P3 shared-surface defect.**
`AskOnTheSpotSlot` publishes three `@visibleForTesting` seam parameters
(`repository`, `contentLoader`, `sessionSkips`, `ask_on_the_spot_slot.dart:50-57`)
whose types are **not exported by the facade**
(`context_notebook_entry_point.dart:19-21` exports only `NotebookEntry`,
`NotebookKind`, `SkillEntry`, `AskOnTheSpotSlot`). Any consumer that wants to
inject those seams for its own widget tests is therefore *forced* to reach past
the facade — which is exactly what P7 did
(`gift_ideas_screen.dart:46-52`, `:77-79`, `:125`). The contract as shipped makes
the boundary invariant unachievable for the consumers it was written for
(STORY-005/008/009/010 will hit the identical wall).

Recommended fix, in preference order:
1. Keep the seams off the public widget: have consumers accept an injected
   `Widget` (or a slot-builder callback) in their own test constructors, so the
   host screen never names a context_notebook internal type.
2. Failing that, P3 exports a single narrow test-seam type from the facade so
   the boundary stays intact by construction.

Not fixable by loosening the test's exemption list — the exemption list is
correctly limited to the composition root
(`ask_on_the_spot_slot_test.dart:388`), and widening it would delete the
invariant rather than satisfy it.

### F2 — Advisory (contract-conformant, doc inaccurate)

`AskOnTheSpotSlot.entryPointId` is required by the §3 contract
(`architecture/contract-summary.md:67`) and the implementation matches that
signature, but the field is **never read**: `build()` at
`ask_on_the_spot_slot.dart:60-68` does not forward it to `_AskOnTheSpotHost`,
and nothing downstream consumes it. The doc comment at `:37-40` claims it
"Travels with the ask as the caller's own label", which is not true today —
`notebook_entries` has no entry-point column (`contract-summary.md:86-92`), so
there is nowhere for it to travel to. Contract-conformant, so not blocking;
the comment should either be corrected to say the value is reserved, or the
value should be threaded to `question_id`'s sibling column if the requirement
ever needs per-entry-point attribution.

### F3 — Advisory (stale evidence, not stale code)

`test-results.md` Phase P3 "Ghi chú cho reviewer" item 1 states that
`openNotebookScreen`/`openSkillProfileScreen` throw `UnimplementedError`
pointing at P4. That is no longer the worktree state: both have real
`Navigator.push` bodies at `context_notebook_entry_point.dart:58-77`, i.e. P4
did its handoff as planned. The note is correct as a P3-time record and
harmless, but a later reader synthesising the story should not treat it as
current. No action required beyond not citing it as present state.

## Carried question from the P2 slice reviewer

**Answer: NO — P3 does not wire `validateContextPacks` into any runtime
pack-loading path. The gate still runs only from tests after P3.**

- Definition: `mobile/lib/features/context_notebook/domain/context_content_gate.dart:47`
- Callers, exhaustively (`grep -rn validateContextPacks mobile/lib mobile/test`):
  `mobile/test/features/context_notebook/context_content_gate_test.dart:76, 107, 314, 377, 398`.
  Zero callers anywhere in `mobile/lib`.
- The path `AskOnTheSpotSlot`/`AskOnTheSpotCubit` actually use bypasses the gate:
  `ask_on_the_spot_cubit.dart:83-88` loads `ask_questions` and `:127-131` loads
  `skill_seeds`, both via raw `ContentPackageLoader.load(...)` with only a
  `expectedSchemaId` check. There is no gate call between load and render.

Materially important qualifier the P2 note did not have: the gate **is** run
against the real shipped assets read from disk, in
`context_content_gate_test.dart:83-100` (group `shipped packs pass the gate
from disk (AC-35/AC-36/BR-18)`). So the shipped packs are verified at test/CI
time even though nothing verifies them at app runtime. The practical residual
exposure is therefore a pack edited without re-running the suite, not an
unvalidated production path — see R1.

## Residual risks

- **R1** — AC-11's runtime guarantee ("four soft-skill seeds on screen before
  any typing") is enforced by `requiredSkillSeedIds` only through tests. The
  widget renders whatever the pack contains
  (`ask_on_the_spot_cubit.dart:132-135`); if the shipped
  `skill_seeds.v1.json` ever loses a required id, the slot degrades silently
  because the cubit's catch-all (`:107-113`) turns pack problems into an absent
  card. Mitigated by the from-disk gate test above; unmitigated only if a pack
  edit ships without the suite.
- **R2** — `_routeClaims` never re-assigns ownership when the owning slot is
  disposed while a muted sibling stays mounted (the muted sibling only re-claims
  if its own `didChangeDependencies` fires again,
  `ask_on_the_spot_slot.dart:94-110`). This matches AC-2's intent and the test
  `the muted slot stays empty after the first one is answered` asserts exactly
  that behaviour, so it is intentional — recorded only so a later story does not
  read it as a bug.
- **R3** — BR-3's "no reproach" check is a two-substring assertion (`chưa`,
  `Hãy`). Adequate for the slice, not a general tone guarantee.
- **R4** — `AskSessionSkips.shared` is process-global mutable state
  (`ask_cadence_policy.dart:14`). Correct for the documented session scope, and
  tests inject their own instance so cross-test bleed is avoided, but any future
  code that needs a narrower scope must inject rather than mutate the singleton.

## Verdict for this slice

Nine of ten cited ACs/BRs and the tenth (AC-11) all PASS on the six slice
files, with no UNVERIFIED items. The slice's own design is sound and the
one-question-at-a-time invariant is genuinely in the widget as the contract
requires. The blocker is F1: the phase's own Required boundary check is red at
HEAD, and the root cause is a gap in this phase's published surface, not only
in the consumer that tripped it. F1 must be resolved before STORY-004 can be
called clean; F2 and F3 are deferrable.
