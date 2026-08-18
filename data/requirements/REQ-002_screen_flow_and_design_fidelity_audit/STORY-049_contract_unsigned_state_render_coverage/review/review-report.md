# Review Report: STORY-049 Contract Unsigned-State Render Coverage

Outcome: DEFERRED_ONLY

Review type: `compact-story-review` (mobile lane, `Complexity: trivial`,
RED-PATCH retro-hardening for RWB-20260816-014)
Reviewed: 2026-08-18 — re-review cycle 2, after the B-1/B-2 rework
Supersedes: the 2026-08-18 cycle-1 `PATCH_REQUIRED` report (2 blocking, 3
deferred). Cycle-1 findings are resolved below; its deferred items are carried
forward.
BaseHead: `1e23295cd08e98928023324b92d095e61f1b29d7`

## Scope Gate

- Review report path: this file
- Source/test files in scope: `mobile/lib/main_preview.dart` (the only changed
  implementation file); read for verification only:
  `mobile/lib/features/love_contracts/presentation/screens/love_contract_screen.dart`,
  `mobile/lib/features/love_contracts/presentation/love_contract_state.dart`
- Evidence files in scope: `visual-fidelity/visual-fidelity-report.md` and all
  three `visual-fidelity/*.png`
- Governing artifact: this story's `story_master.md` (AC-1/AC-2/AC-3, `### Rework
  (Review B-1/B-2)`)
- Cross-checks: `cupid-app-design-system/project/Cupid Screens.dc.html:148-167`,
  `.ai-team-bundle/runtime/tools/`, `git diff` vs BaseHead
- Touched risk surfaces: mobile interaction (preview harness only — no shipped
  app code), design-fidelity evidence
- Critical gates: rendered design-vs-implementation pair per rule 12e3; static
  analysis + test suite (re-run unfiltered this cycle); scope boundary
- Phase 2 proceeded.

## Outcome Rationale

Both cycle-1 blocking findings are resolved, and each was re-verified from
primary sources rather than from the story's own account of the fix. All three
ACs now pass. One residual wording imprecision and the cycle-1 deferred items
remain, none of which affect an AC verdict or any piece of evidence.

| AC | Verdict | Basis |
|----|---------|-------|
| AC-1 (D-7/D-8 closed by real render) | PASS | Re-confirmed; unchanged this cycle |
| AC-2 (D-10/D-13 document-and-close) | PASS | D-10 now rests on the renderer's own recorded output |
| AC-3 (scope boundary) | PASS | Diff is exactly one preview-only file, +18/-5 |

## Cycle-1 Blocking Findings — Both Resolved

### B-1 — false tooling-absence claim / untried `mySigned` render — RESOLVED

Independently verified, not taken on the story's word:

- **Tools exist, untracked.** `wc -c` returns exactly the claimed sizes —
  `.ai-team-bundle/runtime/tools/render-design-canvas.js` 20011 bytes,
  `capture-mobile-screen.sh` 23087 bytes — and `git ls-files --
  .ai-team-bundle/runtime/tools/` returns empty, confirming the
  "untracked install artifact, not absent" explanation.
- **The design-source claim is real.** I read
  `cupid-app-design-system/project/Cupid Screens.dc.html` directly: line 154 is
  `<sc-if value="{{ mySigned }}">` with **no** `hint-placeholder-val`, line 160
  is `<sc-if value="{{ myUnsigned }}" hint-placeholder-val="{{ true }}">`, and
  the hold-to-sign control at line 161 carries only design-time
  `onMouseDown`/`onMouseUp` placeholder bindings. The structural-unreachability
  argument holds on the source, independent of the tool run.
- **The forcing attempt is real.** `shasum -a 256` on the stored probe gives
  `2acd1045727564cf7ff167fd36e13f3a418c65509be7debc35060ba6498514b3` for
  `design-reference-contract-mysigned-attempt-android.png` — byte-identical to
  `design-reference-contract-myunsigned-android.png`. Clicking the sign control
  changes nothing, which is the evidence. The deliberately-wrong-selector control
  returning `DESIGN_CANVAS_CLICK_TARGET_MISSING` / exit 1 is what makes the
  exit-0 results meaningful rather than vacuous.
- **Corrections landed** in `story_master.md` (`## Background` strikethrough,
  AC-2 bullet, `## Mobile Implementation`) and in the visual-fidelity report
  (three places), each dated and struck through rather than silently rewritten.
- **`Design-Screen: contract`** is recorded at `visual-fidelity-report.md:4`,
  satisfying the rule 12e2 item left open in cycle 1.
- **D-13 untouched**, as required — it still rests on its independent
  no-design-counterpart grounds.

D-10 now closes on evidence rather than on an absent-tool assertion, which is
what B-1 asked for.

### B-2 — false doc comment in `main_preview.dart` — RESOLVED

The corrected comment (`mobile/lib/main_preview.dart:480-483`) now qualifies the
claim to "the only fixture that paints that row *in the same sign state as the
design canvas's `myUnsigned` branch*". I verified this qualified form is
actually true, from the code rather than the comment:

- `love_contract_state.dart:74` — `bool get canEditClauses => viewerRole ==
  ContractViewerRole.requester;` (role-only, sign-state-independent)
- `love_contract_screen.dart:427` — `if (state.canEditClauses)` gates the
  add-clause row, and the enclosing clause block (`:376-426`) is unconditional
- `main_preview.dart:521-532` — `bothSigned` is also `viewerRole: requester`, so
  it does paint the row, but in the signed state; `partnerAlreadySigned` is
  `viewerRole: partner`, so it does not paint it at all

`requesterUnsigned` is therefore the only fixture painting that row in the
unsigned state the design's `myUnsigned` branch shows. The comment is now
accurate and the fixture choice is confirmed correct.

## Independent Re-verification This Cycle

- **Diff scope (AC-3).** `git diff <BaseHead>` touches `mobile/lib/main_preview.dart`
  (+18/-5) plus two Scrum Master control-plane files
  (`data/retro-audit/rework-backlog.md`, `scrum-master-checkpoint.md`). No other
  source file changed; no shipped app code touched.
- **Images (rule 12e3).** I opened both PNGs again. Both are real, non-blank,
  non-error captures of the Love Contract screen; the reference depicts the
  `myUnsigned` branch (hold-to-sign control, single `+` add-clause row), and the
  implementation shows the same screen in the unsigned state with the add-clause
  row painted. Nothing in the images contradicts `VISUAL_FIDELITY: PASS` for
  D-7/D-8, and the non-D-item deltas are disclosed in the report rather than
  hidden.
- **`flutter analyze --no-pub lib test`** — re-run unfiltered: **80 issues, all
  `info`**, zero errors, zero warnings. Matches the story's claim.
- **`flutter test --no-pub`** — re-run unfiltered: **`+1285 ~2: All other tests
  passed!`**, exit 0 (1285 passed, 2 skipped, 0 failures). Matches.
- **Scrum Master corrections (handoff item 7).** Both are accurate and
  consistent with what I verified independently: the `## Background` STORY-048
  paragraph and the AC-2 first bullet are struck through with dated corrections
  that state the tools exist as untracked install output and preserve AC-2's
  outcome. Neither rewrites history silently.
- **Entry point (12e1):** not applicable — no user-facing capability is
  delivered; `main_preview.dart` is a build-time preview harness.
- **Runtime smoke (12g):** not required (`Complexity: trivial`).

## Deferred Findings

- **DEF-1 (carried forward) — add-clause label copy delta.** Implementation
  renders `Thêm điều khoản riêng`; design paints `Thêm điều khoản của riêng tụi
  mình`. Real, previously undisclosed app-vs-design delta, ARB-owned, correctly
  out of scope under AC-3. Same class as `RWB-20260816-019`. Recommend Scrum
  Master file a new RWB item against STORY-015, anchored `mobile/lib/l10n/arb/`.
- **DEF-2 (carried forward) — clause counter row** (`2/20 điều khoản`): already
  tracked as `RWB-20260816-015`, dispositioned A-1 in STORY-015. No action.
- **DEF-3 (cycle 1) — RESOLVED, no longer deferred.** The propagated false
  tooling claim in `data/retro-audit/rework-backlog.md` (RWB-20260816-014) has
  been struck through with a dated correction. The premise can no longer be
  inherited by a third story.
- **DEF-4 (new) — residual unqualified wording in two spots.** `story_master.md:179`
  ("renders the add-clause row, which no prior fixture could paint") and
  `visual-fidelity-report.md:10-12` ("because no preview fixture could paint
  that row") still carry the unqualified form of the claim B-2 corrected in the
  source comment — `bothSigned` does paint the row, in the signed state. Not
  blocking: cycle 1 scoped the required fix to the source comment and passed
  AC-1 with this wording, the rework did exactly what was asked, no AC verdict
  or measurement depends on it, and `story_master.md:165-173` states the accurate
  version a few lines away. Suggested fix when these files are next touched:
  apply the same qualifier already used in the doc comment — "in the same sign
  state as the design's `myUnsigned` branch".
- **DEF-5 (new) — one stale sentence.** `story_master.md:232-238` says two
  Scrum-Master-owned places "still carry the inherited claim and are **not**
  edited here". Both have since been corrected, so the note now describes a state
  that no longer exists. Worth a one-line "corrected 2026-08-18" amendment in the
  same pass as DEF-4.

## Traceability

| Input | Use |
|---|---|
| `story_master.md` AC-1/AC-2/AC-3, `### Rework (Review B-1/B-2)` | Acceptance basis, rework claims |
| `git diff 1e23295`, `git ls-files` | Change scope (AC-3), tool tracking status |
| `mobile/lib/main_preview.dart:472-536` | Corrected doc comment, fixture correctness (B-2) |
| `love_contract_state.dart:74`, `love_contract_screen.dart:376-427` | `canEditClauses` is role-only; row gating (B-2) |
| `Cupid Screens.dc.html:148-167` | `mySigned` / `myUnsigned` `sc-if` branches (B-1) |
| `.ai-team-bundle/runtime/tools/*` (sizes only) | Tool existence (B-1) |
| `shasum -a 256` on all three PNGs | Probe/reference byte-identity (B-1) |
| All three `visual-fidelity/*.png` (opened) | Rule 12e3 mobile-lane verification |
| `flutter analyze` / `flutter test` re-runs | Verification evidence (rule 18: prior cycle's claim re-checked after a source edit) |
| `data/retro-audit/rework-backlog.md` diff | DEF-3 closure |

UX spec and architecture: none exist (both `SKIPPED:trivial`); rule 9 applies, so
`coding-plan/master-plan.md` is not required.
Configuration guide: not in scope — no setup/configuration surface touched.

## State Recommendation

- Story status: `DONE`
- Keep `Implementation (Development)` checked; check `Review (Reviewer)`
- `RWB-20260816-014` can now be resolved: D-7/D-8 are closed by a real rendered
  comparison, and D-10/D-13 by an evidence-backed disposition
- DEF-1 warrants a new RWB item against STORY-015 (ARB copy); DEF-4/DEF-5 are
  documentation-only and need no separate story
- Blocking findings: 0 · Deferred findings: 4 (DEF-1, DEF-2, DEF-4, DEF-5)
