---
story_status_recommendation: "DONE"
implementation_status_recommendation: "KEEP_CHECKED"
reviewed_at: 2026-09-25
reviewed_by: Reviewer
---

# Review Report: STORY-011 Vỏ hoàng đạo / trắc nghiệm

Outcome: DEFERRED_ONLY

## Reviewed Inputs

- Review gate: `final-synthesis` (over four completed `scoped-slice` passes)
- Scope Gate: `review/scope-gate.md` (P1 pass) plus the inline scope sections
  each later slice added for its own phase; diff coverage re-verified below
- Requirements: `requirements/requirements.md`, `story_master.md` §Acceptance
  Criteria (AC-1..AC-6 local numbering) and requirement-level AC-2..AC-34 /
  BR-2/7/12/13/14 / R-1e/R-1g/R-7/R-10/R-13/R-14/R-15a/b/c cited across the
  four slices
- UX: `ux/uiux-spec.md`
- Architecture: `architecture/solution.md`, `architecture/contract-summary.md`
- Coding Plan: `coding-plan/master-plan.md`, `coding-plan/coding-agent-guide.md`,
  `coding-plan/phase-P1-content-pack-and-gate.md` .. `phase-P4-entry-point-wiring.md`
- Test Results: `coding-plan/test-results.md` (all phases, plus the
  story-level `## Story Runtime Startup Smoke` section)
- Previous review findings: `review/slice-P1.md`, `review/slice-P2.md`,
  `review/slice-P3.md`, `review/slice-P4.md` — all `PARTIAL_SLICE_ONLY`, 0
  blocking, 10 deferred combined; read fresh and cross-checked against their
  own cited evidence for this pass, not taken on trust

## Reviewed Scope

- Story complexity: `standard`
- Bug status: `N/A`
- Code scope reviewed: full story diff `git diff 5fba81eb..HEAD` — 51 files.
  Verified this baseline is the true merge-base with
  `codex/REQ-016_solo_stage1_relationship_assistant-integration`, not an
  empty-diff HEAD. Union of the four slices' declared source/test inventories
  covers all 26 `mobile/` source and test files in the diff — no file was
  added to the branch after any slice's scope was fixed; no orphaned file
  exists outside slice coverage. The remaining 25 diff entries are the
  story's own process artifacts (architecture, coding-plan, review, ux,
  visual-fidelity, story_master/story_brief) plus the two design-reference
  PNGs, none of which are runtime code.
- Evidence reviewed: `coding-plan/test-results.md` in full (all four phase
  sections plus the story-level smoke section), `visual-fidelity/visual-fidelity-report.md`
  in full (§1-§7 for P3, §P4 for P4)
- Risk surfaces reviewed: all eight rows of `master-plan.md` §3A, confirmed
  covered by the phase mapping and independently re-checked by each owning
  slice (see slice reports for line-level evidence)
- Critical gates reviewed: targeted/regression Flutter test suites per phase,
  scoped `flutter analyze`, `flutter build apk --debug`, visual fidelity gate
  (re-run independently by both P3 and P4 slices with negative controls),
  story-level runtime startup smoke
- Backend targeted verification gates: `NOT_APPLICABLE` — story has zero
  backend surface by design (AC-22/AC-23, static asset bundle only, no
  transport import anywhere under `lib/features/zodiac_shell`, confirmed by
  P1's recursive source scan and re-confirmed at P2's wider module root)
- Story runtime startup smoke: `NOT_APPLICABLE` — `master-plan.md` §4 declares
  `mobile-app: mobile, startup smoke NOT_APPLICABLE` for this story, which is
  the correct declaration: the story adds no new app bootstrap/runtime
  service and is reached through an already-running, already-startable hub
  screen; per `reviewer/references/scope-and-evidence.md`, mobile story scope
  does not require story-level e2e/emulator lifecycle evidence. `test-results.md`
  additionally carries a `## Story Runtime Startup Smoke` section that starts
  `backend-api` — this is transparently labelled as satisfying an unrelated
  repo-level spawn-guard precondition (`guard-parallel-spawn.sh`), not as
  evidence for this mobile-only story, and I confirm that framing is accurate
  rather than misleading. Mobile reachability itself is proven instead by
  P4's production-widget-tree navigation tests (see below), which is the
  gate this story actually owns.
- Frontend targeted verification gates: `N/A` — no web/frontend lane
- Frontend discoverability/navigation integration: `N/A`
- Requirement frontend visual audit: `N/A`
- Mobile targeted verification gates: `PASS` — 4 phases, 0 blocking findings
  across independent slice reviews; combined suite re-run by the P2 slice at
  story HEAD (`+142 ~4`, 0 failures); scoped `flutter analyze` delta 0 against
  the pre-existing non-zero repo baseline, independently re-verified by the
  P4 slice with three separate targeted runs rather than accepted on the
  phase's own count
- Mobile discoverability/navigation integration: `PASS` — P4 slice proved
  hub-originated navigation through the real production widget tree with a
  `NavigatorObserver`, from both hub states (populated and Minute-1-empty),
  with the target cell resolved by `QuickEntryCell.values.indexOf(...)`
  rather than a hardcoded index
- Requirement mobile visual audit: `NOT_APPLICABLE` (this story-level pass) —
  requirement-level mobile visual audit belongs to REQ-016 integration review,
  not to this story synthesis
- Story artifacts reviewed: `story_master.md`, `story_brief.md`,
  `requirements/requirements.md`, `ux/uiux-spec.md`,
  `architecture/solution.md`, `architecture/contract-summary.md`, all four
  `coding-plan/phase-*.md`, `coding-plan/master-plan.md`
- Bug artifacts reviewed: `N/A`
- OQ context reviewed: OQ-3, closed 2026-09-06 via D-15 → R-15a/b/c; no
  unresolved OQ touches this story

## Outcome Summary

- Review outcome: DEFERRED_ONLY
- Rationale: all four scoped slices independently verified their phase's
  acceptance criteria and risk surfaces against concrete code/test evidence
  with 0 blocking findings; my own re-verification confirms full diff
  coverage (no orphaned files), a correctly-declared `NOT_APPLICABLE` runtime
  startup smoke, and an adequate (if structurally shared) story-level visual
  fidelity verdict (see below). Reconciling all 10 carried deferred items
  against each other finds no combination that becomes blocking: the
  documentation-staleness items (D-P1-1, D-P1-3, D-P2-1) are non-code and
  change no shipped byte; the two content/state-machine gaps (D-P1-2, D-P2-2)
  are each independently confirmed to have no currently reachable production
  trigger, and they do not compose into one (D-P1-2 is an unscanned-but-tolerated
  root key, D-P2-2 requires a parse *failure*, which is a structurally
  different and currently impossible event given P1's gate plus the asset
  bundle being build-time bound); the visual-fidelity disclosure gaps
  (D-P3-1, D-P4-1) and the shared-token structure (D-P3-2) touch audit
  completeness, not implementation correctness, and no AC is affected; the
  capture inconsistency (D-P4-2) and layout shape (part of D-P4-1) are
  STORY-001-owned surface, out of this story's write scope; D-P4-3 is a
  disclosure gap the slice already closed on the merits independently. None
  of the 10 items, alone or combined, meets the `PATCH_REQUIRED` bar in
  `reviewer/references/triage-and-outcomes.md` (incorrect implementation,
  unmet AC, unverifiable AC, or violated UX/architecture constraint).
- Blocking findings: 0
- Deferred findings: 10 (D-P1-1, D-P1-2, D-P1-3, D-P2-1, D-P2-2, D-P3-1,
  D-P3-2, D-P4-1, D-P4-2, D-P4-3 — all carried from the slices, reconciled
  below)
- Dismissed observations: 0

## Traceability Summary

- Requirements: `story_master.md` AC-1..AC-6 (local) all satisfied; full
  requirement-level AC citation is in each slice report's own Traceability
  section (AC-2..AC-34, BR-2/7/12/13/14, SC-2, R-1e/R-1g/R-7/R-10/R-13/R-14/
  R-15a/b/c) and is not re-derived here
- Bug report: `N/A`
- Diagnosis: `N/A`
- Open Questions: OQ-3 closed 2026-09-06 (D-15 → R-15a/b/c); binding
  constraints implemented and independently tested at every phase, not left
  as prose
- UX: `ux/uiux-spec.md` honoured; the one open UX question (D-P4-1's shape
  divergence between the canvas's vertical three-row list and the shipped
  horizontal strip) is STORY-001-owned, pre-existing, and not this story's to
  resolve
- Architecture: `architecture/solution.md` UI-delivery anchor and
  `architecture/contract-summary.md` §1-§6 honoured, with D-P1-1 the one
  doc-side divergence (architecture doc names `schemaId`, shipped wire form
  is `schema_id`; implementation is correct, doc is stale)
- Testing evidence: `coding-plan/test-results.md`, all four phases PASS, 0
  failures; combined suite re-run confirmed green at story HEAD by the P2
  slice; `flutter build apk --debug` PASS; scoped `flutter analyze` delta 0
  re-verified independently by the P4 slice against three separate targeted
  invocations

## Risk Surface Gate Summary

| Risk Surface | Source Of Truth | Critical Gate | Result | Notes |
|--------------|-----------------|---------------|--------|-------|
| Cổng nhập nội dung | `contract-summary.md` §3/§4 | Gate over real bundled assets, 5 rejection rules, 1 control fixture each | PASS | P1; D-P1-2 notes an unscanned-but-tolerated root-key blind spot, no live violation |
| N là thuộc tính dữ liệu | `master-plan.md` §3A | No item-count constant; N=1/N=7 fixtures both parse and play through | PASS | P1, P2, P3 all independently confirm no hardcoded N |
| Tất định, không xoay theo ngày | `solution.md` §3 | No `DateTime`/`Random`/`Timer` under the module; same inputs → same outcome, repeated | PASS | P2, recursive scan covers files added by later phases too |
| Hợp đồng thẻ chỉ-đọc | `contract-summary.md` §2 | `activity_card.dart` diff is a pure `+2 -1` append | PASS | P2 |
| Bề mặt kết quả một-lượt-cuộn | `solution.md` §3 | Single `ListView`/`Scrollable`, no collapsible interstitial, across all 27 outcomes | PASS | P3 |
| Giọng R-1e/R-1g ở đầu ra | `contract-summary.md`, `uiux-spec.md` §3.4 | No score/rank surface; ask-block is the closing block by geometry, not presence | PASS | P1 (lexical), P3 (structural) |
| Cửa vào thấy được | `master-plan.md` §3A | Hub-originated navigation through production widget tree, both hub states, no gating conditional | PASS | P4 |
| Ngoại tuyến / không AI | AC-22/AC-23 | No transport import anywhere under the module; static asset bundle only | PASS | P1 scan recursive over the eventual full module footprint, re-confirmed at P2 |
| Visual fidelity (story-level) | `visual-fidelity/visual-fidelity-report.md` | Two audited surfaces (result screen §1-§7, hub strip §P4), each independently gate-run with a negative control and eyeballed | PASS | See "Story-level visual verdict" below |
| Runtime startup smoke (story-level) | `master-plan.md` §4 | `mobile-app` declared `NOT_APPLICABLE`; entry reachability proven by P4 instead | NOT_APPLICABLE | See Reviewed Scope above |

## Story-level visual verdict (owned by this synthesis)

`visual-fidelity-report.md` carries one top-level `VISUAL_FIDELITY: PASS`
token for two structurally different surfaces — the result screen (§1-§7,
audited by the P3 slice) and the hub quick-entry cell (§P4, audited by the
P4 slice) — which is what D-P3-2 flags. I judge this **adequate as a
whole-story verdict**, not merely accepted:

- The file is not a single undifferentiated claim. It is internally split
  into two self-contained audits, each with its own screenshot table, its
  own rule-by-rule comparison table (§1-§7's 19-row table for the result
  screen; §P4.2/§P4.3's eyeball and canvas comparison for the hub cell),
  its own numbered deviation list with justification, and its own explicit
  local verdict line (`VISUAL_FIDELITY: PASS cho bề mặt P4 sở hữu` at
  §P4.4, distinct from the top-of-file token).
- Both halves were independently re-run against the gate script with a
  negative control (P3 slice: empty-directory control, exit 1; P4 slice:
  separate empty-directory control at a different tmp path, exit 1) —
  proving the `PASS` is a real evaluation on both passes, not a no-op read
  twice.
- Both halves were eyeballed against their own PNGs by different slice
  passes (P3: `implemented-7-vo-hoang-dao-3-viec-md.png` +
  `-md-chon-lat.png`; P4: `implemented-man-goc-muon-lam-md-quick-entry.png` +
  `implemented-phut-1-kho-trong-md-quick-entry.png`), each confirming
  diacritics, icon glyphs, and the AC-specific negative checks (no lock, no
  badge, no percentage/score) on their own images, not on the other
  surface's.
- The one real cost of the shared token is what D-P3-2 already names: the
  automated gate script cannot fail one surface while passing the other. A
  future defect confined to just one surface would still show `PASS` at the
  top of the file, and only a reader who opens the body — as both slices and
  this synthesis did — would catch it. That is a tooling-precision gap worth
  carrying forward (see D-P3-2 below), not a coverage gap in what was
  actually audited here. Both surfaces this story ships were audited, with
  evidence, independently.

## Deferred Findings

**D-P1-1 — `architecture/contract-summary.md` §1/§2 sketches the envelope key
as `schemaId`; shipped wire form is `schema_id`.** Implementation is correct
(`ContentPackage.parse` reads `schema_id`); the architecture doc is stale.
No shipped byte affected. Owner: Tech Lead.

**D-P1-2 — the time-gating key scan (`collectJsonKeys`) covers item keys
only; envelope root keys (e.g. the shipped quiz pack's untouched `"locale":
"vi"`) are tolerated and invisible to the scan.** Both shipped packages are
currently clean (0 hits for all five gated keys). The gap is real for a
future CMS export that adds a root-level gated key (e.g. `"daily": true`
outside `items`), not for anything shipped today. Owner: Mobile Developer —
narrow the dartdoc's "at any depth" claim or extend the scan to the envelope
root; extending is preferred since the CMS is out of repo.

**D-P1-3 — phase P1 §3's input-layer task text names a per-feature keyword
denylist that contradicts R-15c and was never built that way; the gate
correctly delegates to the shared `notebookBoundaryHitsIn` instead, which a
test (`gate test:732`) actively pins.** The phase text is the stale side, not
the implementation. Owner: Tech Lead — align phase §3 wording.

**D-P2-1 — `test-results.md:118`'s first P2 evidence row records a command
(`flutter test test/features/zodiac_shell/`) whose written form does not
match its reported count (45) at the commit it claims** — at `27700367` that
directory already held P1's 67 tests, so the command as written would have
reported 112. No correctness consequence: the P2 slice independently reran
the directory at story HEAD (`+142 ~4`, all green) and the phase's own third
evidence row (`+457 ~5` regression) already covers the regression question.
Owner: Mobile Developer — correct the row to the command actually run.

**D-P2-2 — `ZodiacShellCubit`'s stage enum has no error member, so a pack
load failure leaves `ZodiacShellStage.loading` rendering `SizedBox.shrink()`
indefinitely with no timeout, retry, or error copy.** Refined across two
slices: the reader is not trapped (a real `Navigator` back control renders
once the screen is pushed in production — the missing-back-button appearance
is a harness artifact of being pumped as `home`), and there is no currently
reachable production trigger — `pubspec.yaml` declares
`assets/data/req016/` as a bundled directory asset, and P1's content gate
makes a malformed shipped pack a build-time impossibility. Deferred as real
but currently unreachable. Owner: Mobile Developer, on `ZodiacShellCubit`'s
stage enum, if this module ever needs to tolerate a pack that fails to
parse.

**D-P3-1 — the visual-fidelity deviation list for the result screen omits
two copy deltas against the canvas**, both with the same legitimate cause as
already-documented deviation 1 (screen 7 has no partner-name binding in this
story): the canvas's ask-block heading is personalised
("CÂU ĐỂ HỎI CÚN") against the shipped generic "CÂU ĐỂ HỎI", and the
canvas's positioning note names the partner against the shipped generic
line. No AC violated (AC-15 requires a question, not a named one). Owner:
Mobile Developer — add the two rows to the deviation list.

**D-P3-2 — one visual-fidelity report and one top-of-file
`VISUAL_FIDELITY:` token span both the P3 (result screen) and P4 (hub strip)
surfaces, so the automated gate cannot fail one surface independently of the
other.** Judged adequate as a whole-story audit in this synthesis (see
"Story-level visual verdict" above) because both surfaces carry independent,
evidenced, explicitly-stated sub-verdicts inside the file body. The
structural risk — a single shared token masking a future single-surface
regression to an automated reader that does not open the body — remains and
is worth a tooling improvement. Owner: DevOps/Tech Lead — consider whether
`verify-story-visual-fidelity-gate.sh` should recognise per-`Design-Screen:`
sub-verdicts for stories that audit more than one distinct UI surface.

**D-P4-1 — two of the three P4 design-reference screenshots (`man-goc-muon-lam`,
`phut-1-kho-trong`) do not draw the quick-entry strip at all; only the third
(`tab-y-tuong-hub-cua-vao`) does, and against it the shipped strip differs by
an undisclosed subtitle-copy delta** ("Vui thôi — nhưng cuối cùng vẫn ra 3
điều làm thật" on the canvas row, absent from the shipped cell — the strip
shape has no room for it). The shape and label deviations are already
disclosed and are STORY-001/AC-28-owned, not P4's to fix; the subtitle
omission from the disclosure list is the new part. Owner: Mobile Developer —
add the row; Owner: UI/UX — confirm at requirement level whether
`tab-y-tuong-hub-cua-vao`'s vertical-list shape is still the governing design
for the three entry points, since the shipped horizontal strip is
STORY-001's shape, not P4's to change.

**D-P4-2 — the "Vỏ hoàng đạo" cell is flush to the frame's right edge with no
inset in the populated-hub capture, but normally inset with a visible rounded
corner in the Minute-1 capture, at the same 415px frame width.** Eyeball
evidence only (a pixel probe was refused by the query-first guard). The
strip's layout is STORY-001-owned and P4 may not change it; most likely cause
is the populated hub's header giving the strip a different available width
than the Minute-1 surface. Owner: STORY-001 owner / synthesis-for-requirement
— not P4's write scope.

**D-P4-3 — two disclosure gaps, neither reaching misconduct.** (1) The
`write_scope` grant citation for editing `gift_ideas_screen_test.dart` and
`conversation_starters_screen_test.dart` cannot be reconstructed — the source
parallel-run file is gone from gitignored `data/runtime/`. Resolved on the
merits independently: the P4 slice read the actual code changes and
confirmed the retirements are legitimate (§4 of `slice-P4.md`), so the
citation gap does not change the verdict. (2) The "222 warnings / 0 errors"
analyzer baseline in the phase record did not reproduce, and the count
arithmetic (271 − 21 test-only issues ≈ 250) does not reconcile against 222
as a `lib`-only figure. The P4 slice's three independently-targeted
`flutter analyze` runs (the seven P4-adjacent files, `test/`,
`lib/features/zodiac_shell`) already establish the real claim — P4
contributes zero analyzer issues — without relying on the stale number.
Owner: whoever next needs a repo-wide analyzer baseline — re-measure before
reuse; do not carry "222" forward as live.

## Implementation Action Items

None required before closing this story — 0 blocking findings. The owner
notes above (Tech Lead: D-P1-1, D-P1-3, D-P3-2; Mobile Developer: D-P1-2,
D-P2-1, D-P2-2, D-P3-1, D-P4-1, D-P4-3; UI/UX + STORY-001 owner: D-P4-1,
D-P4-2) are for future backlog follow-up, not a gate on this story's `DONE`
status.

## Workflow State Recommendation

- Story status: `DONE`
- Bug status: `N/A`
- `Implementation (Development)`: `KEEP_CHECKED`
- `Review (Reviewer)`: `CHECK`
- Next step: Scrum Master may mark STORY-011 `DONE`, tick `story_master.md`'s
  `Review (Reviewer)` checkbox, and proceed with the story's normal
  merge/completion flow. The 10 deferred items above should be preserved
  (e.g. carried into a retro or a follow-up doc-hygiene pass) rather than
  dropped, per `reviewer/references/triage-and-outcomes.md`'s deferred-finding
  recording requirement.
- State update owner: `scrum-master` only. Reviewer does not edit story or
  requirement status files.

REVIEW_COMPLETE: YES
