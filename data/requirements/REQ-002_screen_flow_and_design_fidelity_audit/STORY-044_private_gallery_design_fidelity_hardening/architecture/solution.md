# 044_private-gallery-design-fidelity-hardening-solution.md

## 0. Metadata

- Story ID: STORY-044_private_gallery_design_fidelity_hardening
- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Retro-Type: RED-PATCH (RWB-20260816-010), Fixes:
  STORY-026_private_gallery_design_fidelity
- Complexity: standard
- Story-Class: standard
- Lanes: DevOps (P0, tooling) then Mobile (P1, evidence) — hard sequential
- Author: Tech Lead
- Date: 2026-08-17

## 1. Decision Summary

Implement a generic `--click=<selector>` pre-shutter interaction flag on
`.ai-team-bundle/runtime/tools/render-design-canvas.js` (P0, DevOps), then use
it to render the `galleryOpen` design reference and re-verify STORY-026's
value-by-value findings against a real rendered pair (P1, Mobile).

The two phases cannot merge: P1 physically cannot produce its primary artifact
until P0 ships, and they are different lanes with different verification
surfaces (a Node CLI vs a Flutter screen capture).

### Key Discovery

Four facts found during solutioning change how this story must be executed.
They are binding on both phases and must be read before any edit.

**KD1 — every prior line citation for this screen is 8 lines stale.**
`story_master.md` Background, `requirements/requirements.md`, and STORY-026's
own report all cite line numbers that are consistently `+8` off the current
`cupid-app-design-system/project/Cupid Screens.dc.html`. Implementers must use
the actual column below, not the cited column.

| Element | Cited by story_master / STORY-026 | Actual current line |
| --- | --- | --- |
| `<sc-if value="{{ isGallery }}">` | not cited | L732 |
| `<sc-if value="{{ galleryLocked }}">` | L725-735 | L733-743 |
| **`doUnlock` CTA (the click target)** | **L733** | **L741** |
| **`<sc-if value="{{ galleryOpen }}">`** | **L736-751** | **L744-759** |
| grid container padding | L737 | L745 |
| auto-lock banner (OUT OF SCOPE) | L738-742 | L746-750 |
| grid definition | L743 | L751 |
| photo tiles | L744-746 | L752-754 |
| dashed add tile | L747 | L755 |
| screenshot notice (OUT OF SCOPE) | L749 | L757 |

Two further citations in `story_master.md` Background point 1 are wrong in file,
not just in line: `unlock = (side) => this.setState(...)` lives at
`cupid-app-design-system/project/Cupid App.dc.html:411`, not in
`Cupid Screens.dc.html`. The prop that binds it is
`doUnlock: () => a.unlock(side)` at `Cupid Screens.dc.html:2288`.

This is a citation drift, not a design-source integrity failure: the bundle is
`locked: true` with a recorded `content_fingerprint`
(`data/devops/system/design-fidelity-config.json`), and STORY-035..043 rendered
against it successfully in this same cycle.

**KD2 — the click target has no id, class, or data attribute, and `onClick`
does not survive into the DOM.** The CTA is a bare
`<div onClick="{{ doUnlock }}" style="...">` (L741). The canvas runtime rewrites
`on*` attributes into React-style handler props at compile time
(`cupid-app-design-system/project/support.js:438-439`, via `EVENT_MAP` at
L317-318), so no `onclick`/`onClick` attribute exists on the rendered element.
`document.querySelector` over plain CSS therefore cannot reach it by handler
name.

Consequence for P0's contract: `--click` must resolve selectors through
**Playwright's selector engine** (`page.locator()` / `page.$()`), which is a
strict superset of CSS and adds `:has()`, `:text-is()`, and `text=`. It must not
be implemented with `page.evaluate` + `document.querySelectorAll`, which is how
`--hide` works (L323-338) and which would leave this screen unreachable.

Candidate selector for P1, to be confirmed empirically by P0 and recorded:

```text
[data-plat="md"] div:has(> span[data-icon]:text-is("fingerprint"))
```

The `fingerprint` icon glyph is in the shared component and therefore renders in
both frames; the `[data-plat="md"]` prefix is what disambiguates, not the icon.
Do not key the selector on `unlockLabel` text — it differs per platform and per
locale (`Cupid Screens.dc.html:2289`).

**KD3 — one click opens one device frame only.** `Cupid App.dc.html:239` mounts
the shared component with `side="a" platform="ios"` and L251 with
`side="b" platform="md"`. `unlock(side)` sets `unlockedA` or `unlockedB`
(L411), and `galleryOpen` is read per side (`Cupid Screens.dc.html:2287`).
Clicking the `[data-plat="md"]` CTA opens the Android frame and leaves the iOS
frame in `galleryLocked`.

Consequence: P1 must render with `--platform=android`. Running `--platform=all`
with a single md-scoped `--click` would silently write an iOS PNG in the wrong
state. This is a caller responsibility, not something P0 should special-case —
the flag is generic by design — but P0 must document it in the tool's usage
block.

**KD4 — the tool file is gitignored in this repository.** `.gitignore:5` ignores
`.ai-team-bundle/`, and `.bundle-runtime/` (the bundle-managed source that
`.ai-team-bundle/runtime/` is projected from, per
`.agent-contract/runtime-layout.md`) does not exist here — cupid-apps is an
install target, not the bundle source repo.

Two consequences, both of which P0 must handle rather than discover late:

1. The `--click` change will not appear in the story branch diff, so AC1-AC3
   would have nothing for Reviewer to review.
2. The next `./install.sh --platform=claudecode` run overwrites it.

Resolution is in section 4 (`P0 durability boundary`). This is the same
structural gap `story_master.md` Background point 2 names for RWB-020
(STORY-042), which is still `PENDING` — so it is a known unresolved problem in
this repo, not a surprise.

## 2. Scope And Assumptions

In scope, fixed by `requirements/requirements.md` `## Scope`:

- P0: `--click=<selector>` (repeatable) on `render-design-canvas.js`, applied
  after `--screen` navigation and before the shutter, failing with a typed
  `DESIGN_CANVAS_CLICK_TARGET_MISSING`, with zero behavior change for renders
  that pass no `--click`.
- P1: `design-reference-gallery-android.png` in the `galleryOpen` state, a
  matched `implemented-gallery-*` counterpart, re-verification of STORY-026's
  sections 2-3 findings against that pair, this story's own
  `visual-fidelity/visual-fidelity-report.md`, and in-app correction of any
  deviation the rendered comparison newly surfaces.

Out of scope and explicitly not to be re-opened:

- Any exemption/waiver path (`requirements.md` `## Scope`).
- `visual-capture.js`, editing the locked design bundle, reusing REQ-001's
  wrong-state `design-reference-gallery-android.png`, hand-rolled Playwright
  scripts (rejected in STORY-026's report section 8.1).
- The `galleryLocked` state.
- Light theme and `en` locale (OQ5, unresolved at registry level, blocks no AC).

### Already-adjudicated differences — not defects, not P1's to fix

The rendered pair will visibly differ from the app in five places that are
already ruled on. P1 must annotate them and move on:

| Ref | Difference | Ruling and authority |
| --- | --- | --- |
| — | auto-lock banner, actual L746-750 | Out of scope by PO ruling; STORY-026 AC3 requires its absence (STORY-026 report §1) |
| — | screenshot notice, actual L757 | Out of scope by PO ruling; STORY-026 AC3 requires its absence (STORY-026 report §1) |
| E1 | 2-vs-3 responsive column count | Disclosed app extension, `STORY-013_gallery/ux/uiux-spec.md` §6 (STORY-026 report §3A) |
| E2 | caption is a localized date, not `date · location` | Disclosed app extension; `GalleryItem` carries no location field (STORY-026 report §3A) |
| E3 | uploader initial badge | Disclosed app extension, `uiux-spec.md` §4.2 (STORY-026 report §3A) |

The in-scope comparison surface is therefore only: grid container padding
(L745), grid definition (L751), photo tiles (L752-754), dashed add tile (L755).

### Open Question Constraints

- OQ5 (light theme / `en` locale): unresolved in
  `data/intake/bootstrap/conflicts_open_questions.md`, blocks no AC in this
  story. Render dark / `vi` only, matching STORY-026's precedent.

## 3. Architecture Delta

### Boundaries And Ownership

| Lane | Phase | Owns | Must not touch |
| --- | --- | --- | --- |
| DevOps | P0 | `render-design-canvas.js` argument parsing and the click pass; the durable tool-change artifact under the story dir | any `mobile/**` file; any `visual-fidelity/` artifact; the locked design bundle |
| Mobile | P1 | `visual-fidelity/` evidence and report; in-app corrections inside the section 2 comparison surface | `render-design-canvas.js`; the locked design bundle; the two out-of-scope design elements |

### P0 tool contract

`render-design-canvas.js` `main()` runs this order today: theme/lang toggles
(L270-281) → freeze-animations (L294-306) → hide (L317-347) → `--screen` click
(L349-364) → platform screenshot loop (L372-394).

AC1's wording ("after the `--screen` navigation and before the hide/freeze/
shutter capture sequence") was written against STORY-026's *proposal*, before
anyone read the real ordering — in the code, hide and freeze already run
**before** the screen click, so the phrase cannot be satisfied literally. The
only ordering that satisfies both halves of AC1 is:

> insert the click pass immediately after the `--screen` block (after L364) and
> before the `label` / platform screenshot loop (before L366).

P0 must state this reconciliation in its own output so Reviewer does not read it
as an AC1 miss.

Contract requirements:

1. **Repeatability requires an argument-parser change.** `parseArgs` (L48-56)
   does `out[m[1]] = m[2]`, i.e. last-wins, so `--click=a --click=b` silently
   keeps only `b`. Accumulate into an array for a named multi-value key
   allowlist containing **only** `click`. Every other key keeps last-wins so
   `--screen`/`--theme`/`--lang`/`--hide` parse byte-identically (AC3).
2. **Playwright selector engine, not `querySelectorAll`** — see KD2.
3. **Typed failure.** Zero matches must `die('DESIGN_CANVAS_CLICK_TARGET_MISSING: ...')`.
   The failure lands before the screenshot loop, so no PNG is written (AC2). Note
   `fs.mkdirSync(out)` at L265 already ran; an empty/pre-existing output
   directory is acceptable, a new or truncated PNG is not.
4. **Settle after each click**, via a `--click-settle-ms` with a default in the
   300-500ms band, consistent with the existing `--screen-settle-ms` (L358).
   `doUnlock` triggers a root `setState` (`Cupid App.dc.html:411`) that
   re-renders both frames and mounts `<image-slot>` placeholders.
5. **Echo the match count to stderr** so a caller can see an ambiguous selector.
   Do not add strict-mode enforcement; ambiguity is the caller's problem, and
   AC2 only demands that zero matches is not a silent no-op.

### P0 durability boundary (resolves KD4)

P0 task 1 is to verify the ignore status with
`git check-ignore -v .ai-team-bundle/runtime/tools/render-design-canvas.js`.

If it is ignored — the expected outcome — the phase splits its deliverable:

- The **working change** is applied in place so P1 can actually render. It is
  not committed and is not durable.
- The **durable, reviewable deliverable** is a committed unified diff plus a
  short contract note under
  `data/requirements/.../STORY-044.../coding-plan/`, which *is* tracked. This is
  what Reviewer diffs for AC1-AC3.
- Upstream propagation into the bundle source repo is **out of this story's
  reach** and must be raised to Scrum Master as a follow-up, alongside the
  still-`PENDING` RWB-020 which has the identical shape.

Do not force-add the ignored path and do not rewrite `.gitignore`: both fight an
intentional decision, and neither survives the next installer run.

### Affected Modules

| Path | Phase | Change |
| --- | --- | --- |
| `.ai-team-bundle/runtime/tools/render-design-canvas.js` | P0 | `parseArgs` multi-value allowlist; click pass after L364; usage block |
| `.../STORY-044.../coding-plan/` (patch + contract note) | P0 | durable artifact for KD4 |
| `.../STORY-044.../visual-fidelity/` | P1 | reference PNG, implemented PNG, report |
| `mobile/lib/features/gallery/presentation/widgets/gallery_grid_view.dart`, `gallery_tile.dart` | P1 | **only if** the rendered pair surfaces an in-scope deviation |
| `mobile/test/features/gallery/gallery_capture_entry.dart` | P1 | **only if** AC5 needs a re-capture |

### Risk Surfaces And Source Of Truth

| Risk surface | Where it bites | Source of truth |
| --- | --- | --- |
| Stale line citations (KD1) | P0 selector, P1 comparison | section 1 KD1 table |
| Handler-only click target (KD2) | P0 implementation choice | `support.js:438-439` |
| Wrong-frame capture (KD3) | P1 render invocation | `Cupid App.dc.html:239,251` |
| Ungitted tool change (KD4) | P0 reviewability | `.gitignore:5` |
| Prototype chrome returning after re-render | P1 reference validity | section 4 below |
| AC7 scope explosion | P1 | section 2 adjudication table |
| Stale output file read as fresh | P1 | section 4 below |

## 4. Named Risks And Required Handling

**R1 — the prototype FAB may return after the click.** The hide pass sets
`display:none !important` via `el.style.setProperty` (L333) on nodes matched
*before* the click, outside the runtime's knowledge. `doUnlock` re-renders the
canvas. If the re-render recreates the screen-index FAB node
(`design-fidelity-config.json` `hide_selectors`), the inline hide is lost and
the reference carries prototype chrome — precisely what that config exists to
prevent.

Handling: **verify, do not pre-emptively code.** P0 renders once with the click
and inspects the frame corner where the FAB sits. Only if it reappears, re-run
the hide pass after the click pass, gated on `clicks.length > 0` so that
no-click renders stay byte-identical (AC3).

**R2 — do not hide the out-of-scope design elements.** The auto-lock banner
(L746-750) and screenshot notice (L757) are inside the `galleryOpen` block and
are out of scope, which makes `--hide` tempting. Do not. `hide_selectors` exists
for prototype affordances, not for suppressing real design content; hiding them
would make the locked reference misrepresent the design. Capture the full frame
and annotate the two regions in the report.

**R3 — AC7 must not become feature work.** A failed comparison that would
require new behavior — a 60s auto-lock timer, screenshot detection, or a
biometric unlock gate — is new functional scope, not hardening. The app's
`GalleryLocked` state is a *pairing* gate
(`gallery_screen.dart:116`), semantically different from the design's biometric
lock; that divergence is already covered by the section 2 adjudication. If P1
finds an in-scope deviation whose fix requires new behavior, stop and escalate
to Scrum Master rather than implementing it.

**R4 — a failed render leaves the previous PNG in place.** `die()` writes
nothing but deletes nothing. P1 must confirm the reference file is genuinely new
(mtime or a clean output directory), not a survivor of an earlier run.

## 5. Non-Functional Impact

- No runtime service, env var, secret, port, or third-party integration change.
  Requirement Configuration Guide impact: NOT_APPLICABLE.
- P0 touches machine-local tooling only; no app binary, no dependency change.
- P1's build/verification gate is the mobile registry entry (`mobile-app`,
  `flutter build apk --debug`), and only if it edits Dart source.

## 6. Option Evaluation

**P0 selector resolution — `page.$()` (accepted) vs `page.evaluate` +
`querySelectorAll` (rejected).** The `--hide` pass uses the latter, so mirroring
it is the obvious move. Rejected: KD2 shows the target carries no CSS-addressable
identity, so a pure-CSS engine leaves this screen unreachable and the story
cannot meet AC4. `page.$()` also brings actionability waits (visibility,
stability) that a raw DOM `.click()` does not.

**P0 repeatability — allowlisted multi-value keys (accepted) vs
accumulate-all-repeats (rejected).** Accumulating every repeated key into an
array is less code, but it would change `--hide` and `--theme` from string to
array for any caller that repeats them, which is exactly the AC3 regression this
story is forbidden to introduce.

**P0 durability — committed patch artifact (accepted) vs force-adding the
ignored file (rejected) vs deferring the whole story (rejected).** Force-adding
overrides a deliberate `.gitignore` decision and still loses the change on the
next installer run. Deferring blocks P1 for a problem P1 does not own. The patch
artifact gives Reviewer something real to review inside the story's own tracked
directory while leaving the upstream fix where it belongs.

**P1 platform — `--platform=android` (accepted) vs `--platform=all`
(rejected).** KD3: `all` would emit an iOS PNG in the wrong state with no error.
Android is also the platform the existing `implemented-gallery-emulator-5560.png`
was captured on, so it is the pairing target AC5 asks about.
