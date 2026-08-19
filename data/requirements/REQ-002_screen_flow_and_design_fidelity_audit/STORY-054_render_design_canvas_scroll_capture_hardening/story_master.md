# Story Master: STORY-054 Render-Canvas Below-The-Fold Capture Hardening

Status: DONE
Complexity: trivial
Story-Class: standard
Implementation Lane: devops
Requirement: REQ-002
Retro-Type: RED-PATCH
Fixes: NONE — capture-tooling capability gap, not a defective story output.
STORY-042's shipped evidence stands; its below-the-fold capture was taken with
a disclosed throwaway diagnostic Playwright script, recorded in its own
`visual-fidelity/visual-fidelity-report.md` "Tool limitation" section.
Scope: Retro-hardening (RWB-20260816-020) — `render-design-canvas.js` capture
tooling only.
Screen: NONE — this story changes the capture tool, not an app screen.
UI-Fidelity-AC: WAIVED — the story renders no product UI and writes no
`mobile/`, `backend/`, or `frontend/` code. The locked `design_source` is this
story's *input* (the canvas it must render more completely), not a surface it
implements, so a "matches the design reference" criterion has no subject here.
The design source is instead asserted as the fixed comparison target in AC6.
Visual-Fidelity-Evidence: NOT_APPLICABLE — `visual-fidelity/` is mandatory
"for every story on a UI lane"
(`.claude/skills/scrum-master/references/artifact-contract.md:167-169`) and
`devops` is not a UI lane. AC6's smoke render is this story's own evidence and
belongs under `coding-plan/`, not under `visual-fidelity/`. Do not open a
`visual-fidelity/visual-fidelity-report.md` for this story; a `VISUAL_FIDELITY:`
marker here would assert a design-conformance claim the story does not make.
Runtime-Smoke: WAIVED — Scrum Master DONE-gate decision, 2026-08-18. Zero
app-code delta independently confirmed
(`git diff 251336d5..18cbc7c -- mobile/ backend/ frontend/` empty), the same
shape STORY-044's devops phase closed with `Runtime-Smoke: WAIVED`. AC6
executes the changed tool end-to-end (Reviewer spot-check re-execution,
byte-identical evidence), a stronger gate for a headless Node CLI than an app
startup smoke.

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — SKIPPED:trivial
- [x] Architecture (Tech Lead) — SKIPPED:trivial
- [x] Implementation (Development) — devops, 2026-08-18.
      `coding-plan/render-design-canvas-scroll.patch`,
      `coding-plan/tool-contract-scroll-flag.md`,
      `coding-plan/test-results.md`, plus AC6/AC2 evidence PNGs.
      AC1-AC6 all PASS by execution; see `coding-plan/test-results.md` §10.
- [x] Review (Reviewer) — Iris-QC, 2026-08-18, Outcome: CLEAN. `review/review-report.md`.

## Background (Rework Item)

`data/retro-audit/rework-backlog.md` item RWB-20260816-020 (Status: PENDING,
Priority: LOW, anchor: devops), split out of
`STORY-042_love_timeline_design_fidelity_hardening`'s own AC4 evidence
capture. Verbatim remediation text from that registry entry (do not re-derive):

> `render-design-canvas.js` has no scroll flag, and its `--hide` selectors are
> applied before the `[data-screen-btn]` click, so they do not survive the
> screen re-render. Any screen whose fidelity-critical content is below the
> fold (e.g. `timeline`'s last entry row and its "Thêm kỷ niệm" dashed button)
> cannot be captured by the sanctioned tool.
>
> Exact remediation needed: add a `--scroll <px>` (or `--scroll-to-end`) flag
> to `render-design-canvas.js` that scrolls the screen's overflowing body
> element after the `[data-screen-btn]` click and before the screenshot, and
> re-apply `--hide` selectors after that click rather than before it. Anchor:
> devops (`render-design-canvas.js` tooling), no specific story blocked today.

Two defects, one outcome. The missing scroll control and the non-surviving
`--hide` selectors are not independent bugs: both are consequences of the same
pipeline-ordering problem (work done before the `[data-screen-btn]` screen
click is discarded by the re-render), and neither alone makes a below-the-fold
screen capturable — a scrolled frame still carries the chrome that `--hide` was
supposed to remove. They are delivered together as one story with one
verification, not split.

## Product Owner Scoping

### Actor and outcome

**Actor:** the design-fidelity evidence author — the mobile/devops/reviewer
role that must produce a `design-reference-<label>-<platform>.png` pair for a
story's visual-fidelity gate.

**Problem:** for any screen whose fidelity-critical content sits below the
device-frame fold, the sanctioned renderer physically cannot produce that
evidence. The only way past it today is an unsanctioned throwaway script,
which bypasses the locked pipeline's hide/freeze/frame guarantees and produces
output that is not byte-comparable to sanctioned renderer output.

**Business outcome:** below-the-fold design content becomes capturable by the
sanctioned tool, so fidelity evidence for tall screens stops depending on
per-story improvisation and stays comparable across stories.

**Success signal:** the `timeline` screen — the original discovery case —
renders in full through the sanctioned tool alone, with no diagnostic script
in the loop (AC6).

### Standalone-value gate

*After only this story merges and deploys, what can a stakeholder observe that
they could not observe before?* A sanctioned `render-design-canvas.js` render
of the `timeline` screen that includes the last entry row and the "Thêm kỷ
niệm" dashed button, with `--hide` chrome actually absent from the image —
content that no sanctioned render has ever been able to show. That is a real,
inspectable artifact, not "the code is in place". Gate: **PASS**.

### Repo constraint the story must be delivered around

`render-design-canvas.js` lives at
`.ai-team-bundle/runtime/tools/render-design-canvas.js`. It **is** present in
this checkout, but it is gitignored (`.gitignore:5`, `.ai-team-bundle/`,
confirmed via `git check-ignore -v`), so a direct edit to it cannot be
committed and would be invisible to every future reader and to any freshly
installed bundle.

This exact constraint already has a precedent in this requirement:
`STORY-044_private_gallery_design_fidelity_hardening` added the `--click` flag
to this same script and shipped it as a **committed patch file plus a tool
contract note** under its own `coding-plan/`
(`coding-plan/render-design-canvas-click.patch`,
`coding-plan/tool-contract-click-flag.md`,
`coding-plan/test-results.md`). STORY-054 follows the same pattern (AC5).

Note for the implementer: because the tool is present on disk, the patch can
and must be applied and actually executed, not merely authored — AC1/AC2/AC3
are behavioral criteria, not a code-reading exercise.

### Open Question triage

`data/intake/bootstrap/conflicts_open_questions.md` carries exactly one
unresolved blocking-relevant item, **OQ5** (light theme and EN locale in v1).

- **Scope Items BLOCKED:** none.
- **Scope Items NOT BLOCKED:** all of AC1-AC6. The new capture control is
  orthogonal to theme and locale — it changes *where in the page* the shutter
  fires, not which `--theme`/`--lang` toggle is selected, and it must behave
  identically under every existing toggle combination (AC3). OQ5's resolution
  cannot change any acceptance criterion in this story.

No payment, checkout, billing, subscription, or entitlement scope is present,
so no provider-confirmation OQ applies.

## Acceptance Criteria

1. **Below-the-fold content becomes capturable.** Given a screen whose body
   content overflows its device frame, when the render is invoked with the new
   scroll control, then the written PNG shows the content at the requested
   scroll position instead of the top-of-frame content, and the frame chrome,
   device bezel, and image dimensions are unchanged from an unscrolled render
   of the same screen. The control must support **both** an explicit pixel
   offset and a "scroll to the end of the scrollable content" mode, so an
   author can either target a known position or capture the tail of a screen
   without guessing a magic number. The exact flag spelling is a devops/Tech
   Lead choice and must be recorded in the tool contract note (AC5).

2. **`--hide` selectors survive the screen change.** Given a render that
   combines `--screen=<id>` with one or more `--hide=<selector>` values, when
   the PNG is written, then every element matched by those selectors is absent
   from the image. This must hold when the scroll control from AC1 is used and
   when it is not.

3. **No regression for existing callers.** Given any render command that does
   not pass the new scroll control, when it runs, then it produces the same
   visible result as before this story. No existing flag (`--screen`,
   `--theme`, `--lang`, `--hide`, `--click`, `--platform`, `--label`,
   `--max-edge`, `--entry`, `--out`, `--location`, `--list-screens`) changes
   its spelling, its value type, or its repeat semantics. At least one
   previously-captured screen is re-rendered with its original command line and
   compared against its committed `design-reference-*.png` to demonstrate this.

4. **A capture that cannot be honored fails loudly.** Given a scroll request
   that cannot be satisfied — no scrollable element found, or a `--hide`
   selector matching nothing — when the render runs, then it exits with a typed
   error naming the cause and **writes no PNG**, following the existing
   `DESIGN_CANVAS_CLICK_TARGET_MISSING` precedent. Silently writing an
   unscrolled or chrome-bearing image is the failure mode this criterion
   exists to prevent: a misleading design reference is worse than no design
   reference, because a downstream story would compare against it and record a
   false `VISUAL_FIDELITY: PASS`.

5. **The change is durable in this repository.** Given that the tool file is
   gitignored, when the story closes, then the change ships as a committed
   unified-diff patch file plus a tool contract note under this story's
   `coding-plan/`, following the STORY-044 precedent
   (`STORY-044_private_gallery_design_fidelity_hardening/coding-plan/render-design-canvas-click.patch`
   and `.../tool-contract-click-flag.md`). The contract note states the exact
   flag spelling, its accepted values, its ordering guarantee relative to the
   `[data-screen-btn]` click and the shutter, and its typed failure codes. A
   direct uncommitted edit to
   `.ai-team-bundle/runtime/tools/render-design-canvas.js` does not satisfy
   this criterion, and the patch must apply cleanly on top of STORY-044's
   already-landed `--click` patch.

6. **The original discovery case is closed (smoke check).** Given the
   `timeline` screen, when it is rendered with the new control through
   `render-design-canvas.js` alone — no diagnostic or throwaway script
   anywhere in the command — then the resulting PNG shows the screen's last
   entry row and its "Thêm kỷ niệm" dashed button, the content RWB-20260816-020
   names as uncapturable today. The rendered PNG and the exact command line
   are committed as this story's evidence under `coding-plan/`.

## Non-Goals

Explicit, so downstream roles do not widen this story:

1. **No re-capture or re-verification of any story's fidelity evidence.**
   STORY-042 is DONE with its limitation disclosed, and STORY-025's and every
   other screen's evidence stays as-is. If a future reader wants tall-screen
   evidence re-taken with the new control, that is a new item against that
   screen's own origin story, not this one.
2. **No app code.** No `mobile/`, `backend/`, or `frontend/` path is in scope.
3. **No changes to `visual-capture.js`** or to the implemented-side capture
   path. This story changes the design-reference renderer only.
4. **No change to the visual-fidelity comparison pipeline** or to
   `hooks/lib/visual_fidelity.py`. Whether a scrolled design reference is a
   valid comparison target for an unscrolled implemented-side screenshot is a
   question for whichever story next captures a tall screen; it is not settled
   here.
5. **No edits to the locked design source** (`cupid-app-design-system`) to make
   content fit above the fold. The tool adapts to the design, never the
   reverse.
6. **No new screen ids or canvas toggles.** The scroll control operates on
   whatever `--screen` already selects.

## Complexity / Lane

`Complexity: trivial`, `Implementation Lane: devops`.

Per `references/complexity-routing.md` routing order: not security-sensitive,
not performance-critical, no new screens, no new UX decisions, and no new
architecture decisions — the flag-contract shape (repeatable/typed flag applied
after the `[data-screen-btn]` click and before the shutter, with a typed
`DESIGN_CANVAS_*` failure and a committed patch as the durable deliverable) was
established by STORY-044 on this same file and is reused, not re-decided. A
single implementation lane writes all of it.

This is deliberately *not* `standard`. STORY-044 was `standard` because it
genuinely spanned two lanes (a devops tool phase, then a mobile evidence phase
that could not start until the flag existed). STORY-054 has no second lane: it
ends at the tool. Classifying it `standard` would force
`Implementation Lane: shared` under the Lane Consistency Rule, which would
route a headless Node CLI with zero product UI through the UI/UX Designer —
work with no subject. The single-lane test is decisive here, so this is not a
"when unsure, prefer standard" case.

Risk note for the Reviewer, which complexity routing does not capture: AC2
changes pipeline ordering for **every** existing `--hide` caller, not only for
callers of the new flag. AC3 is the guard on that blast radius and should be
verified by execution against a real previously-captured screen, not by reading
the patch.

## Dependencies

None. STORY-044's `--click` patch is already landed and DONE; AC5 requires this
story's patch to apply cleanly on top of it, which is a sequencing fact about
an already-merged story, not a pending dependency.
