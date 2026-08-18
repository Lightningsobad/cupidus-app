# Review Report — STORY-054 Render-Canvas Below-The-Fold Capture Hardening

- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Story: STORY-054_render_design_canvas_scroll_capture_hardening
- Review type: `compact-story-review` (Tier 1)
- Reviewer: Iris-QC
- Date: 2026-08-18
- Implementation commit: `18cbc7c5efe7a5611478964a5fc3d8c54dfca9cc` (parent `251336d562c0eb91a458eb795a18f318ae7f273a`)

Outcome: CLEAN

## Scope Gate

- Review type: `compact-story-review`; report path is this file.
- Governing artifact: `story_master.md` (`Complexity: trivial`, `Story-Class: standard`, `Implementation Lane: devops`, AC1-AC6, `Retro-Type: RED-PATCH` for RWB-20260816-020, `Dependencies: None`).
- Retro discipline (rule 1a): this story **is** the retro/rework item RWB-20260816-020, so the pending-rework refusal does not apply despite `Retro-Bypass: NO`.
- Source/config files in scope (1): `.ai-team-bundle/runtime/tools/render-design-canvas.js` — gitignored (`.gitignore:5`), invisible to any diff, so verified by direct ranged reads against the committed patch.
- Evidence files in scope (6): `coding-plan/render-design-canvas-scroll.patch`, `coding-plan/tool-contract-scroll-flag.md`, `coding-plan/test-results.md` (§1-§10, read by range), and the three evidence PNGs.
- Touched risk surfaces: operational command (CLI flag contract), runtime/configuration (design-reference capture pipeline). No persistence, auth, external integration, or product UI surface.
- Critical gate: the tool's own CLI execution. There is no unit/integration harness for this headless Node CLI, so the executed commands in §3-§7 are the gate, and re-execution is the authenticity check.
- Not applicable: entry-point reachability (12e1) and rendered visual fidelity (12e2/12e3) — the story writes no product UI; `git diff 251336d5..18cbc7c -- mobile/ backend/ frontend/` is empty, confirmed. Runtime startup smoke (12g) — lane is `devops` and complexity is `trivial`, neither of which 12g covers.
- Phase 2 proceeded; no scope blocker.

## Per-AC Verdicts

| AC | Verdict | Basis |
| --- | --- | --- |
| AC1 — below-the-fold capturable, chrome/dimensions unchanged | **PASS** | Both modes exist in the live tool (`render-design-canvas.js:451-483`): `--scroll=end` and `--scroll=<px>` with `Math.min(px, max)` clamping. Scroll targets a node *inside* the device frame while the shutter captures the frame element, so dimensions cannot change; independently re-rendered at `406x900`, identical to the unscrolled baseline. Image inspection of the committed pair confirms status bar, notch, `Love Timeline` header, bottom nav, home indicator and bezel are in the same position — only the entry list moved. |
| AC2 — `--hide` survives the screen change | **PASS** | Second `applyHides` pass runs after `[data-screen-btn]` click (`render-design-canvas.js:396-411`). Verified by *looking at* the images, not the counts: `ac2-timeline-scrolled-nohide-android.png` shows the rounded purple grid-icon FAB at bottom-right above the nav bar; it is absent from `ac6-timeline-scrolled-android.png` at that exact position. Holds with `--scroll` (§4) and without it (§6, three byte-identical renders). |
| AC3 — no regression for existing callers | **PASS** | `MULTI_VALUE_KEYS = new Set(['click'])` unchanged in the live file (`render-design-canvas.js:80`); `--scroll`/`--scroll-settle-ms` are new last-wins keys. §6 records SHA-256 equality for `welcome`, `register`, `gallery`. Independently confirmed the committed `STORY-044/visual-fidelity/design-reference-gallery-android.png` hashes to `82277b90885e120bd1ec8a66e997f6f713733fd8fe32b1cbdcdbca3a15bd2141`, exactly the value §6 claims the fresh render matched — and that case exercises the `--click` pass, the only other post-`--screen` stage. |
| AC4 — unsatisfiable requests fail loudly, no PNG | **PASS** | All three new typed codes present and reachable in the live file: `DESIGN_CANVAS_SCROLL_VALUE_INVALID` (:455-460), `DESIGN_CANVAS_SCROLL_TARGET_MISSING` (:471-476), `DESIGN_CANVAS_HIDE_TARGET_MISSING` (:403-409). The scroll pass runs for every wanted frame *before* the screenshot loop, so `--platform=all` cannot leave a partial PNG. Re-executed independently (see spot-check 2). |
| AC5 — durable in this repository | **PASS** | `render-design-canvas-scroll.patch` (207 lines) and `tool-contract-scroll-flag.md` (160 lines) are committed in `18cbc7c`. I verified the live gitignored file against the patch by reading all four hunk ranges (:363-411, :446-483, :529-544, :557-588) — the on-disk content matches the patch verbatim, so the committed patch is a truthful record of a change no diff can show. Contract note states flag spelling, accepted values, the ordering guarantee, and the typed failure codes as AC5 requires. |
| AC6 — original discovery case closed | **PASS** | Re-executed the exact §9 command; output byte-identical to the committed evidence (see spot-check 1). The scrolled PNG shows the last entry row `Ký Love Contract` / `25/11/25` / "Ngày thứ 1. Bốn điều khoản, hai dấu vân tay." with its violet dot and `tự động thêm` chip, plus the full-width dashed `Thêm kỷ niệm` pill with the pink `+` badge. The unscrolled baseline ends at `Nhận nuôi Bún` (26/11/25) clipped by the nav bar, with neither element anywhere in the frame. No diagnostic script in the command. |

## Spot-Check Re-Execution (verbatim)

Mandatory test-evidence-authenticity check. Both runs were mine, from the repo root, against the live tool.

**1. AC6 / §9 — sanctioned `--scroll=end` timeline render**

```
$ node .ai-team-bundle/runtime/tools/render-design-canvas.js --location=cupid-app-design-system \
    --entry="Cupid App.dc.html" --out=<scratch>/qc-ac6 --screen=timeline --platform=android \
    --theme=dark --lang=vi --scroll=end
hide: re-applied after --screen=timeline, matched 2x '[data-plat] [style*="z-index: 95"]'
scroll: android frame at 207px of 207px on <div>
DESIGN_CANVAS: OK <scratch>/qc-ac6/design-reference-timeline-android.png 406x900
EXIT=0

$ shasum -a 256 <scratch>/qc-ac6/design-reference-timeline-android.png
68973230151a4989218b0950a093a459679b8b596945d5a95ca22b12de91851d
```

Stdout matches §9 line for line, and the hash is **byte-identical** to the committed `coding-plan/ac6-timeline-scrolled-android.png`. The render is reproducible, not a one-off artifact.

**2. AC4 / §7d — invalid `--scroll` value**

```
$ node .ai-team-bundle/runtime/tools/render-design-canvas.js ... --screen=timeline --scroll=bottom
hide: re-applied after --screen=timeline, matched 2x '[data-plat] [style*="z-index: 95"]'
DESIGN_CANVAS_SCROLL_VALUE_INVALID: --scroll takes a non-negative pixel offset or 'end', got 'bottom'
EXIT=1
$ find <scratch>/qc-ac4-badval -type f    # 0 files
```

Typed code, exit 1, and an empty output directory — exactly as §7d claims.

**3. Committed evidence hashes** — all three match §9's table:

| File | SHA-256 | §9 claim |
| --- | --- | --- |
| `ac6-timeline-scrolled-android.png` | `68973230…91851d` | match |
| `ac6-timeline-unscrolled-android.png` | `a548d54f…fcff44` | match |
| `ac2-timeline-scrolled-nohide-android.png` | `13a9a526…9543b0` | match |

## Blocking Findings

None.

## Deferred Findings

- **D1 — `design-fidelity-config.json` `hide_selectors_note` is now stale.** It still says a missing selector "warns"; after this story a `--screen` render exits 1. The implementer disclosed this in `tool-contract-scroll-flag.md` ("Known-stale note"). Correctly out of scope: the design source is `locked: true` and the config is not this story's write scope. Follow-up owner: devops.
- **D2 — strictness blast radius is verified on 4 of 38 canvas screens.** The post-click hide check hard-fails any `--screen` render whose hide selector matches nothing. Coverage is `timeline`, `welcome`, `register`, `gallery`, each matching `2x`. The selector is canvas-global rather than per-screen, so the residual risk is low, and this hard failure is precisely what AC4 demands — a chrome-bearing reference that a later story stamps `VISUAL_FIDELITY: PASS` is the worse outcome. Recorded as a known consequence, not a defect. Owner: devops, if a future export moves the FAB.

## Notes for Scrum Master

- **N1 — complexity mismatch between handoff and artifact.** The handoff described `Complexity: standard`; `story_master.md:4` records `Complexity: trivial`. The artifact controls. Either classification is satisfied here: the story is single-lane `devops` (rule 15 holds), and the scope fits the compact budget (1 source file, 6 evidence files). No action needed beyond not propagating the wrong value.
- **N2 — Runtime-Smoke.** Rule 12g covers non-trivial `frontend`/`shared`/`backend`/`mobile` stories; this is a trivial `devops` story, so the gate does not apply. Zero app-code delta independently confirmed (`git diff 251336d5..18cbc7c -- mobile/ backend/ frontend/` is empty). `story_master.md` deliberately left this as a DONE-gate decision; recording `Runtime-Smoke: WAIVED` is consistent with STORY-044's devops phase.
- **N3 — no `visual-fidelity/` directory, by design.** The story renders no product UI, so there is no design-conformance claim to make. Do not open a `visual-fidelity-report.md` here; a `VISUAL_FIDELITY:` marker would assert something this story does not deliver. AC6's smoke render under `coding-plan/` is the story's own evidence.

## Traceability

- Requirements: AC1-AC6 in `story_master.md`, all traced above to live-file line ranges plus executed evidence.
- OQ discipline: `story_master.md` "Open Question triage" records OQ5 with **no** scope items blocked and AC1-AC6 explicitly not blocked, with the reason (scroll position is orthogonal to `--theme`/`--lang`). Triage is present and correctly applied — no blocked scope was implemented and no unblocked AC was omitted.
- UX / architecture: `SKIPPED:trivial` per `story_master.md`, appropriate for a headless CLI with no product surface.
- Non-Goals: all six respected. No fidelity evidence re-captured, no app code, no `visual-capture.js` change, no comparison-pipeline change, no design-source edit, no new screen ids. Confirmed by the commit's 7-file surface.
- Configuration guide: not required. The deliverable's contract is documented in `coding-plan/tool-contract-scroll-flag.md`, the same durable form STORY-044 established for this gitignored tool.

## State Recommendation

- Keep `- [x] Implementation (Development)` checked.
- Check `- [ ] Review (Reviewer)`.
- Story status: `DONE`.
- RWB-20260816-020 can be resolved. Note for the retro record: the item's premise that `--hide` selectors "do not survive the screen re-render" does **not** reproduce on the 2026-08-11 export (§5 proves by DOM identity that the post-click nodes are the same nodes pass 1 hid, still `display: none`). The delivered re-apply pass is retained as the AC4 verification point rather than as a fix for an observed regression, and the contract note says so plainly instead of overclaiming.
