# Review Report: STORY-005 Mồi chuyện — rework P5-P7 (final)

Outcome: CLEAN

- Review type: `final-synthesis` (full-story review + B-1 scoped-slice re-review)
- Scope gate: `review/scope-gate.md` (`SCOPE_GATE_COMPLETE: YES`)
- Reviewer: Iris-QC · Date: 2026-09-24
- Review scope: P5-P7 rework only. P1-P4 stay covered by the approved
  2026-09-17 `DEFERRED_ONLY` review (earlier body of this file; cited, not
  re-litigated).
- Implementation baseline: `a4386f76` → `1dd4ba01`; doc patch `36966472`;
  slice record `0d2fd318`. Worktree clean at the time of synthesis.

## 1. Review history for this story round

| Round | Artifact | Result |
|---|---|---|
| Full-story review, P5-P7 | this file, 2026-09-24 body | `PATCH_REQUIRED` — one blocking finding, B-1 |
| Doc-only patch (mobile-dev) | commit `36966472`, `visual-fidelity/visual-fidelity-report.md` | 1 file changed, no code, no PNG, no re-capture |
| Scoped-slice re-review, B-1 only | `review/slice-b1-visual-fidelity-doc.md` | `review_slice_result: PASS` |
| Final synthesis | this body | closure decision below |

## 2. What the full review established (carried forward, not re-run)

- P5-P7 code is correct, in scope, and well evidenced. All six items the user
  adjudicated on 2026-09-20 under "Neo thiết kế" are implemented, and both the
  canvas reference and the built screenshot were opened and compared: the build
  matches on every adjudicated item, no tofu, no layout break.
- Two P7 edits inside WriteScope but outside the phase plan were adjudicated
  and **ACCEPTED**: the 7th `StarterGateRule` (`assertiveClaim`) closes a live
  AC-29 hole — `_starterRuleFor` uses `firstWhere` with no `orElse`, so a pack
  carrying that violation threw `StateError` instead of being rejected; and the
  `calendar_event_service_test.dart` frozen-prefix `take(5)` form, which still
  fails on reorder and is forward-compatible with STORY-007.
- Every risk surface passed its critical gate except design fidelity: typed
  contract, AC-29 content gate, mobile interaction, entry-point discoverability
  (`activity_card_hub_view.dart:313`), offline/local-storage, Drift schema
  untouched. Runtime smoke and configuration are `NOT_APPLICABLE`.
- Acceptance traceability was checked against the verbatim text of
  `requirements/requirements.md`: AC-2/AC-3, AC-4/AC-27/AC-28, AC-12/AC-14,
  AC-15/AC-16, AC-17, AC-20 (R-1g), AC-29/AC-30 all PASS; AC-13 unchanged by
  this round.
- Two pre-existing reds are filed and out of this story's write scope:
  `BUG-20260923-001` (Drift `schemaVersion` drift, proved at BaseHead on a
  clean detached worktree) and `BUG-20260923-002` (see D-4).

## 3. B-1 closure

**B-1 — stale per-story visual-fidelity evidence (owner: mobile-dev): CLOSED.**

The slice re-review confirmed all five required steps landed, and confirmed
them against the story's real commit history rather than against the patch's
own prose:

1. `DESIGN_ANCHOR_ADJUDICATION_REQUIRED` is now `NO`, with path 1 and its three
   delivering commits named in the header.
2. §7 is a resolved table — item 2 → P5 `ae908e93`; items 3, 4, 5, 6b → P6
   `9ab00f48`; item 7 → P7 `fa9c0ad5`. No row left open.
3. §6 items 5, 6b and 7 now describe the shipped build; the superseded
   2026-09-17 statements are retained but explicitly banner-labelled as
   historical.
4. §1/§4b are re-anchored on the P7 capture, and the per-phase eyeball
   comparisons from `test-results.md` are carried over, including P7's
   `ask-skip`-before-capture resolution of the P6 fold limitation.
5. D-1 and D-2 are recorded in a new §7b under the same ids, so a later round
   cannot reopen them as a fidelity gap.

Two independent checks make this a real closure rather than a paper one. The
diff is documentation-only — one path, no `.dart`, no test, no asset, no PNG —
so the "no re-capture" claim is proved by the diff. And `git log` on
`implemented-6-moi-chuyen-a-a-material.png` gives `3ff29be4` → `ae908e93` →
`9ab00f48` → `fa9c0ad5`, which matches the report's claim that the file on disk
is the P7 capture. `VISUAL_FIDELITY: PASS` was kept unchanged and was not
weakened into a conditional pass.

The §5 stale-row risk (four rows describing the pre-rework build) was checked
explicitly and cleared: the rows survive under a banner scoping the whole table
to the 2026-09-17 snapshot and redirecting the reader to §7. Internally
consistent, therefore not a residual B-1 defect.

No new finding was opened by the slice, and nothing in it reopens D-1..D-6.

## 4. Deferred findings (carried, non-blocking)

- **D-1 — event block container vs canvas.** Dashed-border card with a
  full-width "+ Thêm vào Muốn làm" on the canvas; divider plus trailing pill and
  `×` in the build. Not adjudicated, partly AC-14-driven, pre-existing from P4.
  Now recorded in the visual-fidelity report §7b.
- **D-2 — canvas chrome absent.** Back chevron, status bar, tab strip. "Đoán
  thử" is SB-144/145/146, explicitly out of scope. Recorded in §7b.
- **D-3 — evidence headings missing.** `coding-plan/test-results.md` has no
  `## Entry Point Reachability` / `## Story Runtime Startup Smoke` heading.
  Hygiene only: the entry point was verified independently in code and P5-P7
  change no startup path. **Partly actioned** — `story_master.md` now carries
  `Runtime-Smoke: WAIVED`.
- **D-4 — `BUG-20260923-002` will likely resolve on merge.** Its three
  assertions are already green on this branch via P7; they stay red only on
  STORY-007's branch, which lacks P7. Re-verify on the integration branch after
  STORY-005 merges before dispatching a bug-fixer — a fixer sent now may
  re-break P7's deliberate `take(5)` prefix form.
- **D-5 — handoff AC ids.** The handoff named "requirements.md AC-1..AC-6";
  those are `story_master.md`'s own six-item list. The governing ACs are the
  ones traced in §2.
- **D-6 — cross-enum wire coupling.** `resolveEventReason` matches on
  `entry.kind.wireValue == slot.wireValue`. If `NotebookKind` and
  `StarterContextSlot` ever diverge, the reason line disappears silently. Same
  coupling `StarterSelector` already carries; no test pins the mapping.

None of these blocks closure. D-4 is the only one with a scheduling
consequence.

## 5. Residual risk

- Low. The remaining risk is documentation drift, not behavior: the
  visual-fidelity report is now accurate but carries a large historical layer
  (banner-scoped §5 and §6 statements) that a careless later reader could still
  quote as current.
- D-6 is the only untested coupling; it is pre-existing and symmetrical with
  code already shipped.

## 6. State recommendation

- Check `Implementation (Development)` and `Review (Reviewer)` in
  `story_master.md`.
- `story_master.md` `Design-Screen:` (lines 11-14) still says the
  visual-fidelity report carries `DESIGN_ANCHOR_ADJUDICATION_REQUIRED: YES`
  with six unadjudicated items. That is stale as of `36966472` — the flag is
  `NO`. Scrum Master should correct that pointer as part of the DONE update;
  it is outside this review's write scope.
- Story is merge-eligible into
  `codex/REQ-016_solo_stage1_relationship_assistant-integration`.
- Requirement closure still needs the separate REQ-016 integration review;
  re-check D-4 there.

REVIEW_COMPLETE: YES
