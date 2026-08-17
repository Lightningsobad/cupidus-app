# Phase P0 – `--click` Pre-Shutter Interaction Flag On `render-design-canvas.js`

## 1. Objective

Add a repeatable `--click=<selector>` flag to
`.ai-team-bundle/runtime/tools/render-design-canvas.js` that clicks in-frame
elements after `--screen` navigation and before the shutter, fails with a typed
`DESIGN_CANVAS_CLICK_TARGET_MISSING` on zero matches, and changes nothing for
renders that pass no `--click`. Prove it by rendering the `galleryOpen` state
that STORY-026 could not reach, and deliver the change in a form Reviewer can
actually diff.

Satisfies AC1, AC2, AC3, and unblocks AC4.

## 1A. Ownership

- Phase ID: P0
- Canonical Phase File: `phase-P0-render-canvas-click-flag.md`
- Owner: DevOps
- Lane: DevOps

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `.ai-team-bundle/runtime/tools/render-design-canvas.js` — restricted to
    `parseArgs`, the new click pass between the `--screen` block and the
    platform screenshot loop, and the usage/doc block
  - `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-044_private_gallery_design_fidelity_hardening/coding-plan/render-design-canvas-click.patch`
  - `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-044_private_gallery_design_fidelity_hardening/coding-plan/tool-contract-click-flag.md`
  - `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-044_private_gallery_design_fidelity_hardening/coding-plan/test-results.md`
- Prohibited paths: every `mobile/**` file; the whole
  `cupid-app-design-system/**` locked design bundle;
  `data/devops/system/design-fidelity-config.json`; `.gitignore`; every other
  tool under `.ai-team-bundle/runtime/tools/`; this story's `visual-fidelity/`
  directory (P1 owns it); all STORY-026 and STORY-035..043 artifacts.
- Impacted Runtime Service/App:
  - Name: NONE
  - Rationale: `render-design-canvas.js` is machine-local bundle tooling with no
    entry in `data/devops/system/runtime-command-registry.json`.
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: N/A — the tool's own invocation is its build gate.
- Risk Surfaces:
  - Handler-only click target with no CSS identity (KD2)
  - Ungitted tool change, not reviewable, installer-overwritten (KD4)
  - Prototype FAB returning after the click re-render (R1)
  - Regression to `--screen`/`--theme`/`--lang`/`--hide` parsing (AC3)
- Source Of Truth:
  - tool contract and insertion point: `../architecture/solution.md` section 3
    (`P0 tool contract`)
  - selector and DOM facts: `../architecture/solution.md` section 1, KD1 and KD2
  - durability handling: `../architecture/solution.md` section 3
    (`P0 durability boundary`)
  - accepted/rejected mechanisms: `../architecture/solution.md` section 6
- Primary Inputs Summary:
  - architecture: `../architecture/solution.md` sections 1, 3, 4, 6
  - acceptance criteria: `../requirements/requirements.md` AC1-AC3
- Requirement Configuration Guide:
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one new CLI flag on one tool, plus the argument-parser change
    it requires and its own regression proof.
  - Source/Test File Count: 4 (1 source, 1 patch artifact, 1 contract note, 1
    test-results)
  - Split Required: NO
  - Split Rationale: the parser change and the click pass are one feature —
    the flag is not repeatable without both, and splitting them would write the
    same file twice.

## 2. Required Reads

- `../architecture/solution.md` sections 1 (KD1-KD4), 3, 4, 6
- `../requirements/requirements.md` AC1-AC3
- `.ai-team-bundle/runtime/tools/render-design-canvas.js` (whole file, ~466
  lines)

Do not read STORY-026's artifacts, `data/retro-audit/rework-backlog.md`, or any
STORY-035..043 artifact. Everything you need from them is in solution.md.

## 3. Tasks

1. **Establish the durability boundary before writing code.** Run
   `git check-ignore -v .ai-team-bundle/runtime/tools/render-design-canvas.js`.
   The expected result is a match on `.gitignore:5`. Record the actual result in
   `test-results.md`.
   - If ignored: your durable deliverables are the patch artifact and the
     contract note listed in Write Scope. Do **not** force-add the ignored path
     and do **not** edit `.gitignore` (solution.md section 3,
     `P0 durability boundary`).
   - If not ignored: commit the file change normally and note that the patch
     artifact is redundant.
2. **Fix `parseArgs` repeatability** (L48-56). It currently does
   `out[m[1]] = m[2]`, i.e. last-wins, so `--click=a --click=b` silently keeps
   only `b`. Accumulate into an array for a named multi-value key allowlist
   containing **only** `click`. Every other key must keep last-wins so
   `--screen`, `--theme`, `--lang`, `--hide`, `--platform`, `--out`, `--label`,
   `--max-edge`, `--entry`, and the `*-settle-ms` family parse byte-identically.
3. **Add the click pass** immediately after the `--screen` block (after L364)
   and before the `label` assignment / platform screenshot loop (L366+). Record
   in the contract note why this is the correct reading of AC1: hide and freeze
   already run *before* the screen click in this code, so AC1's literal phrasing
   is unsatisfiable and section 3 of solution.md governs.
4. **Resolve selectors through Playwright's selector engine** (`page.$()` /
   `page.locator()`), not `page.evaluate` + `document.querySelectorAll`. The
   `--hide` pass uses the latter; mirroring it here would leave this screen
   unreachable, because the target carries no CSS-addressable identity —
   `onClick` is compiled to a React-style prop and never reaches the DOM
   (`cupid-app-design-system/project/support.js:438-439`). See solution.md KD2.
5. **Fail cleanly on zero matches** with
   `die('DESIGN_CANVAS_CLICK_TARGET_MISSING: ...')`, naming the selector that
   missed. The failure must land before any PNG is written. Echo the match count
   per selector to stderr so an ambiguous selector is visible; do not add strict
   -mode enforcement.
6. **Settle after each click** via a new `--click-settle-ms` with a default in
   the 300-500ms band, consistent with `--screen-settle-ms` (L358). The click
   triggers a root `setState` (`cupid-app-design-system/project/Cupid App.dc.html:411`)
   that re-renders both frames and mounts `<image-slot>` placeholders.
7. **Update the usage block** (L28-37) with `--click` and `--click-settle-ms`,
   and state the one-frame caveat: each device frame holds independent state
   (`Cupid App.dc.html:239` `side="a" platform="ios"`, L251 `side="b"
   platform="md"`), so a frame-scoped click opens only that frame and callers
   using `--platform=all` need one selector per frame. See solution.md KD3.
8. **Prove AC3 by regression, not by assertion.** Re-render at least two screens
   that already have committed references from the STORY-035..043 set, with no
   `--click` argument, and confirm the output is unchanged against those
   committed PNGs. Record the screens, commands, and comparison result in
   `test-results.md`.
9. **Prove AC2.** Run with a deliberately non-matching selector and confirm the
   typed error, a non-zero exit, and that no new or truncated PNG was written.
10. **Prove AC1/AC4-readiness and resolve R1.** Run:

    ```text
    node .ai-team-bundle/runtime/tools/render-design-canvas.js \
      --location=cupid-app-design-system \
      --out=<scratch dir> --screen=gallery --platform=android \
      --theme=dark --lang=vi \
      --click='[data-plat="md"] div:has(> span[data-icon]:text-is("fingerprint"))'
    ```

    Confirm the rendered Android frame shows the `galleryOpen` block
    (`Cupid Screens.dc.html:744-759`) — the mint `lock_open` banner with the
    `00:58` countdown, the 2-column photo grid, the dashed add tile — and not
    the `galleryLocked` block (L733-743). Then inspect the corner where the
    prototype screen-index FAB sits (`design-fidelity-config.json`
    `hide_selectors`). If the FAB reappeared, the click's re-render dropped the
    inline hide: re-run the hide pass after the click pass, gated on
    `clicks.length > 0` so no-click renders stay byte-identical. If it did not
    reappear, add no such code — verify, do not pre-emptively code (R1).
11. **Record the exact working selector verbatim** in the contract note. The
    candidate above is unverified; if it needs adjusting, P1 must use whatever
    you actually ran, not the candidate. Do not key the selector on
    `unlockLabel` text — it differs by platform and locale
    (`Cupid Screens.dc.html:2289`).
12. **Write the patch artifact and contract note.** The patch is a unified diff
    of the tool change. The contract note states the flag's signature, the
    insertion point, the verified selector, the one-frame caveat, and the R1
    outcome. Keep the scratch PNGs out of the story's `visual-fidelity/`
    directory — that is P1's, and P1 renders its own.

## 4. Acceptance Criteria

- AC1: `--click` is repeatable, and each selector's click runs after `--screen`
  navigation and before the shutter, at the insertion point solution.md section
  3 specifies. The AC1-wording reconciliation is recorded in the contract note.
- AC2: a non-matching selector produces `DESIGN_CANVAS_CLICK_TARGET_MISSING`, a
  non-zero exit, and no new or partial PNG. Demonstrated in `test-results.md`.
- AC3: at least two existing STORY-035..043 screen captures re-render unchanged
  with no `--click` argument. Demonstrated in `test-results.md`.
- The `galleryOpen` state renders (task 10), proving P1 is unblocked.
- The durability boundary from task 1 is resolved and recorded, not left
  implicit.

## 5. Planned Outputs

- `.ai-team-bundle/runtime/tools/render-design-canvas.js` (working change;
  durable only if task 1 shows it is tracked)
- `coding-plan/render-design-canvas-click.patch`
- `coding-plan/tool-contract-click-flag.md`
- `coding-plan/test-results.md`

## 6. Test Scope

- The tool's own CLI invocations: `--list-screens`, the two no-`--click`
  regression renders, the failing-selector render, and the `galleryOpen` render.
- Excluded: backend e2e/test_e2e, Playwright/browser e2e suites, traces,
  scenario reruns, repository-root local script gates, and the entire Flutter
  test suite (P1 owns any Dart-side gate).

## 7. Status

PENDING.

## 8. Stop Rule

Stop and report to Scrum Master without implementing if:

- Playwright is not provisioned (`VISUAL_RUNTIME_MISSING`, exit 3) — that is an
  install defect, not this phase's to fix.
- The design-source fingerprint check fails against
  `data/devops/system/design-fidelity-config.json`, which would mean the locked
  bundle changed and KD1's citation-drift explanation is wrong.
- No selector can reach the `doUnlock` CTA at all. That would invalidate the
  whole tool-fix path and reopen the exemption decision, which is a PO call.
