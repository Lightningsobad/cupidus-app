# Review Report: STORY-005 Mồi chuyện — rework P5-P7

Outcome: PATCH_REQUIRED

- Review type: `full-story-review` (P5-P7 rework only)
- Scope gate: `review/scope-gate.md` (`SCOPE_GATE_COMPLETE: YES`)
- Reviewer date: 2026-09-24
- Diff baseline: `a4386f76` → `1dd4ba01` (`git merge-base --is-ancestor` = YES)
- P1-P4: out of scope, covered by the approved `Outcome: DEFERRED_ONLY` review
  dated 2026-09-17 (previous body of this file; cited, not re-litigated)

## 1. Rationale

The P5-P7 code is correct, in scope, and well evidenced. All six items the user
adjudicated under "Neo thiết kế" (2026-09-20) are implemented, and the two
images prove it: I opened `design-reference-6-moi-chuyen-a-a-ios.png` and
`implemented-6-moi-chuyen-a-a-material.png` and the build matches the canvas on
every adjudicated item, with no tofu and no layout break.

One critical gate fails, and it is the gate this particular rework exists for.
`visual-fidelity/visual-fidelity-report.md` was never updated: it is still the
P4-dated (2026-09-17) report. It carries `DESIGN_ANCHOR_ADJUDICATION_REQUIRED:
YES`, and its §6/§7 still describe the pre-rework build as current — "Cài đặt
theo spec" for the event-block labels (item 5) and the leading `dd/mm` badge
(item 6b), and "Không ship" for the reason line (item 7). All three shipped.
Its §8 states the condition explicitly: *"Nếu người dùng chọn đường 1 ở §7, mục
này phải được mở lại cùng phase rework."* Path 1 was chosen; the report was not
reopened. `ux/uiux-spec.md` §2/§5 was patched for the same ruling (`06dc96a4`),
so the omission is this one artifact, not the documentation round as a whole.

This is not a style note. `visual-fidelity-report.md` is the artifact the DONE
gate and the REQ-016 requirement-integration review both read. Left as is, the
next reader concludes the hero hierarchy, the new labels, the inline date and
the reason line were not delivered, and that a user ruling is still pending.
Reviewer rule 12c forbids recording `DEFERRED_ONLY` for a gate that is the
primary proof of the changed behavior, and for a design-anchor rework that gate
is exactly this one. The fix is cheap and needs no re-capture: the P7 PNG on
disk is already the anchor image.

## 2. Blocking findings

### B-1 — stale per-story visual-fidelity evidence (owner: mobile-dev)

- File: `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-005_conversation_starters/visual-fidelity/visual-fidelity-report.md`
- Evidence: not present in `git diff --name-only a4386f76` — only the PNG beside
  it changed. Header still reads `phase P4`, `Date: 2026-09-17`; §7 still lists
  items 2, 3, 4, 5, 6b, 7 as open adjudication with an "Đang cài" column
  describing the pre-rework build.
- Required (no re-capture, no device, no new render):
  1. Clear `DESIGN_ANCHOR_ADJUDICATION_REQUIRED: YES` → `NO`, recording that
     path 1 ("Neo thiết kế") was taken and delivered by P5/P6/P7.
  2. Rewrite §7 as a resolved table: item 2 → P5 `ae908e93`; items 3, 4, 5, 6b →
     P6 `9ab00f48`; item 7 → P7 `fa9c0ad5`.
  3. Correct §6 items 5, 6b and 7 so the "Đang cài" statements match the build.
  4. Re-anchor §1/§4b on the current
     `implemented-6-moi-chuyen-a-a-material.png` (the P7 capture) and carry over
     the per-phase eyeball comparisons already written in `test-results.md`
     ("Kiểm tra thị giác" under P5, P6 and P7), including P7's resolution of the
     P6 fold limitation via the `ask-skip` tap before capture.
  5. Record the two remaining unadjudicated canvas deltas below (D-1, D-2) so a
     later round does not reopen them as a fidelity gap.
- Keep `VISUAL_FIDELITY: PASS`. I verified the verdict against both images and
  it is not contradicted — only the body behind it is out of date.

## 3. Adjudication requested by P7

`test-results.md` P7 §"Sửa trôi enum do merge song song" asks the Reviewer to
rule on two edits inside WriteScope but outside phase §3. Both **ACCEPTED**.

| # | Edit | Ruling |
|---|---|---|
| 1 | `starter_content_gate.dart`: add `assertiveClaim` as the 7th `StarterGateRule` | Accept — not cosmetic. `_starterRuleFor` uses `firstWhere` with no `orElse`, so a pack carrying an assertive-claim violation threw `StateError` instead of being rejected: a live AC-29 hole. Sibling sweep satisfied (rule 12d): `gift_content_gate.dart` consulted as the pattern, 218 → 266 sibling content-gate tests re-run green. |
| 2 | `calendar_event_service_test.dart:390`: frozen-length → `take(5)` frozen-prefix comparison | Accept — the contract the test defends is the Drift-persisted wire prefix, not the list length. The weaker form still fails on reorder or on moving `conversation_starter`, and it is forward-compatible with STORY-007's additive `nextPlanAfterDate`. |

## 4. Risk surfaces and critical gates

| Risk surface | Critical gate | Result |
|---|---|---|
| Typed contract (`CalendarEvent` +2 optional keys, `StarterGateRule` +4 values) | targeted gate + service tests | PASS — `starter_content_gate_test` `+48`, `calendar_event_service_test` `+24` |
| Content-invariant gate (AC-29) | negative case per new rule, ship pack clean | PASS — 3 new rules each exercised; `violations.isEmpty` on the shipped pack, 6 of 8 events carry a reason, 2 deliberately carry neither key |
| Mobile interaction (hero/secondary, CTA, refresh disc) | widget tests + static analysis | PASS — screen suite `+33`; `flutter analyze lib test` 0 error, 0 new diagnostic on touched files |
| Mobile navigation / discoverability (12e1) | entry point verified in code | PASS — `activity_card_hub_view.dart:313` `QuickEntryCell.conversationStarters` → `openConversationStartersScreen`; discoverable hub cell, not URL-only. See D-3 for the missing evidence heading. |
| Design fidelity, mobile lane (12e2/12e3) | both images opened, verdict checked | **FAIL** — see B-1. Images themselves are real, correct screen, correct `Design-Screen: 6-moi-chuyen-a-a`, no tofu, no error frame. |
| Local storage / offline (AC-15/AC-16) | no network path added | PASS — new data rides the existing static asset pack; no dependency, no `pubspec.yaml` change |
| Persistence / schema | Drift untouched | PASS — `git diff 9ab00f48 -- mobile/lib/core/database/` empty; `schemaVersion` not touched |
| App startup / runtime smoke (12g) | startup path unchanged | NOT_APPLICABLE as recorded in `master-plan.md` §4 and P4 evidence. See D-3. |
| Configuration / setup (12a) | — | NOT_APPLICABLE — no env var, no external integration, no manual step; no `configuration-guide.md` impact |

Pre-existing reds, both filed and confirmed out of this story's write scope:
`BUG-20260923-001` (11 `test/core/database/` cases, `schemaVersion` 9 vs
asserted 7/8) — P7 proved it at BaseHead on a clean detached worktree, which is
the right standard. `BUG-20260923-002` (3 `conversation_starters` cases) — its
three assertions are **already fixed on this branch** by P7; they stay red only
on STORY-007's branch, which lacks P7. See D-4.

## 5. Acceptance traceability

| AC (verbatim from `requirements/requirements.md`) | Phase | Verdict |
|---|---|---|
| AC-2 / AC-3 — copy to clipboard, create no card, keep no saved list | P5, P6 | PASS — one shared `copyStarter`; hero CTA and secondary icon write the same payload; no store added |
| AC-4 / AC-27 / AC-28 — wrap-around, no "đã hết", no progress indicator, any N ≥ 1 | P5, P6 | PASS — refresh control has no `enabled` flag; N=1/2/12 table; N=1 asserts no placeholder box |
| AC-12 / AC-14 — converted/dismissed events do not come back; one-tap dismiss | P7 | PASS — `refreshContext` recomputes over `state.events`, never re-calls `visibleEvents`; widget test dismisses `ev-later`, adds a notebook entry, and it stays gone |
| AC-13 — past events leave silently | (P4) | Unchanged by P5-P7 |
| AC-15 / AC-16 — no network, no AI | P6, P7 | PASS — reason line is pack sentence + notebook value, no keyword guess, no model |
| AC-17 — deterministic for the same inputs | P5, P7 | PASS — `resolveEventReason` keys on `stableContentKey('$today\|$eventId')`, the same FNV-1a `StarterSelector` uses, over notebook matches sorted by `id`; hero is element `[0]`, no second selection rule |
| AC-20 (R-1g) — a starter must end by asking | P7 | PASS, and correctly inverted for the new field: `eventReasonAsksQuestion` uses `starterStructureHitsIn` in reverse because a reason line retells what the reader wrote and must *not* ask. Confirmed against `invariant_terms.dart:209` — the helper fires when text does not end in `?`/`？`, so `.isEmpty` is the right test |
| AC-29 / AC-30 — runnable gate, content stays data | P7 | PASS — both new keys optional; `reason_context_slot` rejected at parse time when unknown |
| `uiux-spec.md` §2/§5 | P5-P7 | PASS — patched in `06dc96a4` (Tech Lead/Scrum Master ownership, not the implementer's) |

Citation correction (D-5): the handoff named "requirements.md AC-1..AC-6". Those
are `story_master.md`'s own six-item list. The ACs in `requirements.md` that
actually govern P5-P7 are the rows above; this review checked the verbatim text,
not the handoff's ids.

## 6. Deferred findings

- **D-1 — event block container vs canvas.** The canvas draws the event block as
  a dashed-border card with a full-width "+ Thêm vào Muốn làm" button; the build
  uses a thin divider plus a row with a trailing pill and an `×`. Not among the
  six adjudicated items, and the `×` itself is AC-14-backed, so the row shape is
  partly AC-driven. Pre-existing from P4, not worsened here. Record it in B-1
  step 5 rather than reopening it.
- **D-2 — canvas chrome absent.** Back chevron, status bar and the tab strip
  ("Câu để nhắn / Tuần này có gì / Đoán thử") are not in the build. "Đoán thử" is
  SB-144/145/146, explicitly out of scope in `story_master.md`. Record, do not
  act.
- **D-3 — evidence headings missing.** `coding-plan/test-results.md` has no
  `## Entry Point Reachability` and no `## Story Runtime Startup Smoke` heading;
  smoke is recorded as `NOT_APPLICABLE` in `master-plan.md` §4 and in the P4
  section instead, and `story_master.md` carries no `Runtime-Smoke: WAIVED` line.
  I verified the entry point independently in code (§4), and P5-P7 change no
  startup path, so this is hygiene, not a behavioral gap. Scrum Master should add
  `Runtime-Smoke: WAIVED — no phase changes the app startup path` to
  `story_master.md` so the DONE gate reads it from the file the rule names.
- **D-4 — `BUG-20260923-002` will likely resolve on merge.** Its three
  assertions are green on this branch. Before dispatching a bug-fixer, re-verify
  against `codex/REQ-016_solo_stage1_relationship_assistant-integration` after
  STORY-005 merges; a fixer sent now would find nothing to fix here and may
  re-break P7's deliberate `take(5)` prefix form.
- **D-5 — handoff AC ids.** See §5.
- **D-6 — cross-enum wire coupling.** `resolveEventReason` matches notebook
  entries with `entry.kind.wireValue == slot.wireValue`. If `NotebookKind` and
  `StarterContextSlot` wire values ever diverge, the reason line disappears
  silently instead of failing. Same coupling `StarterSelector` already carries,
  so no new risk, but no test pins the mapping itself.

## 7. State recommendation

- Uncheck `Implementation (Development)`; leave `Review (Reviewer)` unchecked.
- Story status → `IN_PROGRESS`.
- Route B-1 to `mobile-dev` as a documentation-only pass inside
  `STORY-005_conversation_starters/visual-fidelity/`. No code change, no
  re-capture, no device. Everything it needs is already on disk.
- On the re-review: verify B-1 only. §3, §4 and §5 above stand and do not need
  re-running.
