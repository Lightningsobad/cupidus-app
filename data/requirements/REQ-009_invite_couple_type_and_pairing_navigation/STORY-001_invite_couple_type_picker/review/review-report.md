# Review Report — STORY-001 Invite Couple-Type Picker

Reviewer: Iris-QC · `compact-story-review` · 2026-08-24 (cycle 5)
Requirement: REQ-009_invite_couple_type_and_pairing_navigation
Branch: `codex/REQ-009_invite_couple_type_and_pairing_navigation-STORY-001_invite_couple_type_picker`

Outcome: DEFERRED_ONLY

story_status_recommendation: DONE

## Scope Gate

Scope gate path: `<story>/review/scope-gate.md` — written because
`validate-reviewer-two-phase.sh` blocked the stop with `SCOPE_GATE_MISSING`,
even though `SKILL.md:75` (rule 5a) directs `compact-story-review` to use only
this inline section. Real gate beats template; the conflict is raised as DF-6.

Review type: `compact-story-review`, mobile lane, standard story.
Report path: `<story>/review/review-report.md`.

Diff baseline actually used: **`90f531f1ec7e1b0960e000c2e27d45d1be7ad1ef`**
(merge-base with the integration branch), not the handoff's declared
`BaseHead: c97baf18`. See deferred finding DF-1 — the declared baseline covers
only 14 of the ~1,700 implementation lines this story added.

Source/test files in scope (4):
- `mobile/lib/features/pairing/presentation/screens/invite_screen.dart`
- `mobile/lib/features/pairing/presentation/couple_type.dart`
- `mobile/lib/features/pairing/presentation/invite_cubit.dart`
- `mobile/test/features/pairing/presentation/invite_screen_test.dart`

Entry-point files read for independent 12e1 verification (not story-changed):
`mobile/lib/core/navigation/pair_gate_shell.dart`,
`mobile/lib/features/pairing/presentation/screens/pairing_choice_screen.dart`.

Evidence files in scope: `story_master.md`; `coding-plan/test-results.md`
(ranged reads only — 39 KB); `visual-fidelity/visual-fidelity-report.md`;
both `visual-fidelity/*.png`.

Query keys: AC1-AC7 · D1 grid-column equal width · `_coupleGridGutter` ·
`## Entry Point Reachability` · `## Story Runtime Startup Smoke` ·
`VISUAL_FIDELITY:`.

Not re-read per handoff: `architecture/solution.md`,
`coding-plan/master-plan.md`, `coding-plan/phase-P*.md`.

## Acceptance criteria

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC1 — code first, then 4-card section, then CTA | PASS | `invite_screen_test.dart` `AC1:` case, re-run green by Reviewer; corroborated in the device capture |
| AC2 — CTA disabled until a card is chosen | PASS | `AC2:` case, re-run green |
| AC3 — exactly one selected, swaps on tap | PASS | `AC3:` case, re-run green |
| AC4 — persisted to `CupidProfile.coupleType` | PASS | `AC4:` case asserts the wire value is written, not local state |
| AC5 — pre-filled on return | PASS | `AC5:` case, persisted `LIVING_TOGETHER` selected on first paint |
| AC6 — matches design reference, no visible deviation | PASS | Independently pixel-verified by Reviewer — see below |
| AC7 — no picker on the join-code screen | PASS | `AC7:` case, re-run green |

## D1 fix — verified real, correctly scoped, genuinely guarded

The fix (`dbaaf7b`) is 6 insertions / 8 deletions confined to
`_CoupleTypeRow.build` in
`mobile/lib/features/pairing/presentation/screens/invite_screen.dart:629-643`.
It moves the gutter from a per-cell `Padding` inset to a sibling
`SizedBox(width: _coupleGridGutter)` between the two `Expanded` cells. Nothing
else moved: `_coupleGridGutter` keeps its `10`, and no cell internals, tokens,
padding or typography changed. This is the minimal correct fix, not a rewrite.

The regression guard (`invite_screen_test.dart:504-540`) is genuine, not a
restatement of the fix: it reads each cell's `GestureDetector` rect and asserts
`left.width == right.width` and `right.left - left.right == 10` on **both**
rows. `test-results.md:589-605` documents it verified red against the restored
pre-fix composition (`Expected: within <0.01> of <270.0>, Actual: <280.0>` —
the same one-gutter asymmetry). Reviewer re-ran the suite: **17/17 pass**,
including the D1 case.

AC6 was not taken on the report's word. Reviewer pixel-scanned
`implemented-invite-couple-type-android.png` independently (column occupancy
runs over the `colorSurface` `(36,27,66)` fill, bottom row, no glow bleed):

```
left card  x  52..526 = 475px = 180.95dp
right card x 553..1026 = 474px = 180.57dp
gutter                 =  26px =   9.90dp
side margins           52px / 53px = 19.8 / 20.2dp
```

Equal within the dpr-2.625 quantisation floor, matching the report's stated
181.0 / 180.6dp exactly. The capture is genuinely post-fix and is not stale:
commit `6514b78` is titled "recapture device screenshot after D1 fix", the PNG
mtime is 21:43:07 against the 21:39:24 fix commit, and the capture's own
status-bar clock reads 9:43.

Both images were opened and inspected (rule 12e3). The implemented capture
shows this story's screen in the built app — pairing code `CPD-8F2K`, the
"Tụi mình thuộc kiểu nào?" heading, the supporting subtext, the 2x2 grid with
"Cùng thành phố" selected, and the "Tiếp tục" CTA. The reference depicts the
same `invite` screen of the design canvas. No error frame, spinner, placeholder
or wrong screen. Nothing visible in either image contradicts the `PASS`.

## Risk surfaces and critical gates

| Surface | Gate | Result |
| --- | --- | --- |
| Mobile interaction (selection state) | targeted widget tests | PASS — 17/17 re-run by Reviewer |
| Mobile navigation / discoverability | 12e1 entry point, verified in code | PASS — see below |
| Mobile static analysis | `flutter analyze` on touched files | PASS — "No issues found" (`test-results.md:613-618`) |
| Design token integrity | `no_fork_guard_test.dart` | PASS — re-run in the 128-case suite |
| App lifecycle / boot | `## Story Runtime Startup Smoke` (12g) | PASS — real build/install/`monkey` launch/`dumpsys`/`logcat` evidence, no FATAL |
| Design fidelity (12e2/12e3, mobile) | rendered comparison + Reviewer image read | PASS — independently pixel-verified |

Entry point (12e1) verified in code, not taken on trust:
`pair_gate_shell.dart:139` renders `PairingChoiceScreen` for the
`PairGateUnpaired` state → `pairing_choice_screen.dart:98-103` exposes a
discoverable primary CTA "Ghép đôi với người ấy" → `_openInvite` at `:35-42`
pushes the real `InviteScreen` via `MaterialPageRoute`. Discoverable through a
real CTA, not direct-URL-only.

## Deferred findings

**DF-1 — the declared review baseline understated the diff by ~1,700 lines
(process, not code).** The handoff's `BaseHead: c97baf18` resolves to
"chore: seal planning artifacts before code-writer spawn", and the diff from it
shows only 14 changed lines of `invite_screen.dart`. The bulk of the
implementation — `couple_type.dart` (new, 94), `invite_cubit.dart` (+102),
`invite_screen.dart` (+344), `invite_screen_test.dart` (+287),
`main_preview.dart` — landed in `708935f` and `e44764d`, which are *ancestors*
of the declared BaseHead and are also labelled "seal planning artifacts before
code-writer spawn". A reviewer trusting the declared baseline would have
reviewed 14 lines and certified 3,346. Reviewed against merge-base `90f531f1`
instead (18 files, +3,346 / −20). Owner: scrum-master — the boundary-state
`BaseHead` and those two commit subjects should be reconciled before this
pattern repeats in the wave.

**DF-2 — `visual-fidelity-report.md` is uncommitted and its frontmatter says
`review_cycle: 4`.** The committed HEAD (`bdeba6c`) recorded `review_cycle: 5`.
The working-tree file (257 lines, written 21:59:15, i.e. after that commit) is a
cleaner rewrite whose content is *correct* — `VISUAL_FIDELITY: PASS`, no open
items, no stale FAIL reference anywhere, and its measurements match Reviewer's
independent scan exactly. Only the cycle number is stale. Owner: scrum-master —
commit it with the story boundary and bump the cycle number; do not discard it.

**DF-3 — a concurrent writer touched the AC6 evidence artifact during this
review gate.** The file changed content mid-review (17,430 B with a
"Capture staleness" section and an open re-capture item → 17,052 B, the correct
version above). It has since been stable (identical sha over a 20 s sample) and
the surviving version is the correct one, so this does not change the outcome.
Owner: scrum-master — confirm no other lane is still writing to
`<story>/visual-fidelity/` before running the boundary commit, otherwise the
superseded text could land over the good one.

**DF-4 — carried forward unchanged from cycle 1.** Card 4 "Gắn bó lâu dài" maps
to the existing `LIVING_TOGETHER` wire value (accepted semantic drift, recorded
as a REQ-009 follow-up in `architecture/solution.md` §6); In Scope item 5
(design-system node for the cards) remains undone because `phase-P1` excludes
`mobile/lib/design_system/` from the write scope — its intent is satisfied by
the rendered `design-reference-invite-couple-type-android.png`.

**DF-5 — `story_master.md` state is stale.** `Status: PENDING` and the
`Implementation (Development)` checkbox is still unchecked from the D1 routing,
though the D1 fix has landed and passes. Reviewer does not edit workflow state;
scrum-master owns re-checking Implementation, checking Review, and setting
`DONE`.

**DF-6 — reviewer skill rule 5a contradicts `validate-reviewer-two-phase.sh`.**
`SKILL.md:75` states that `compact-story-review` must NOT create a separate
`scope-gate.md` and must carry an inline `Scope Gate` section instead;
`SKILL.md:96-99` confirms "No separate `scope-gate.md`" for this mode. The
SubagentStop guard nonetheless blocked with `SCOPE_GATE_MISSING` and required
the file. Both artifacts now exist. Owner: scrum-master — either the guard
should exempt `compact-story-review` or rule 5a should be withdrawn; every
compact review in this wave will hit the same block until one side changes.

## Blocking findings

None.

## Traceability

Requirements: `story_master.md` AC1-AC7, all PASS; OQ5 (light/EN) correctly
triaged non-blocking, no blocked scope in this story, no unblocked AC omitted.
UX: `ux/ux-spec.md` §6.7/§6.8 deviations are stated identically in the spec, the
build, and the fidelity report (7 enumerated, justified). Architecture: the
`coupleType` contract was pre-existing end to end; no backend/OpenAPI surface
was touched, matching `solution.md`. Evidence: `coding-plan/test-results.md`
`## Entry Point Reachability` (:317), `## Story Runtime Startup Smoke` (:493),
`## D1 — Grid column equal-width fix` (:530), `## Post-fix device recapture (D1)`
(:641). No setup/configuration impact, so no `deployment/configuration-guide.md`
verification was in scope.

## Workflow recommendation

- Keep `Implementation (Development)` checked.
- Check `Review (Reviewer)`.
- Story status: `DONE`.
- Before the boundary commit, resolve DF-2/DF-3 (commit the working-tree
  fidelity report, confirm no concurrent writer).
