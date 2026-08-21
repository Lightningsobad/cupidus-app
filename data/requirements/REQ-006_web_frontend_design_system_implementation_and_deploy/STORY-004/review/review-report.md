# Review Report — REQ-006 / STORY-004 Pairing Invite Landing Page

Outcome: PATCH_REQUIRED

Review type: `full-story-review` (parallel story review)
Scope gate: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-004/review/scope-gate.md`
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-004`
Diff baseline: `41b82520c7499662e42075bc1bb8a91fe084fe3b` → HEAD `0cd7ca750bc8f50983cb5c73d413163c05fe2424`
Story: `standard` / lane `frontend` / class `standard`

## Rationale

The delivered code is correct and I found no defect in it. Every functional and
copy-fidelity AC passes, and I verified the port line-by-line against
`Cupid Web.dc.html:387-451` rather than accepting the evidence on trust: the
four new components are a character-exact transcription of the source markup,
including inline styles, tokens, gradients and both locales. The two shell
contracts that consumer stories can break — file immutability and the
`data-vi`/`data-en` mechanism — both hold.

The story is nonetheless returned for patch on **two mandatory evidence
sections that are absent**, not on any code defect. Both are enforced
independently by the DONE gate, so approving the story here would only move the
rejection downstream. Both have direct precedent inside this same requirement:
STORY-001 pass 1 was returned `PATCH_REQUIRED` for exactly these two sections
(its BLK-1 and BLK-2) and closed them with a small documentation patch. Neither
requires touching implementation code.

The AC-9 design-reference gap is **not** among the blocking findings — it is
carried as a deferred item per the Scrum Master resolution, and I confirmed its
premise independently (see DEF-2).

## Blocking findings

### BLK-1 — no `## Story Runtime Startup Smoke` section (reviewer rule 12g)

`coding-plan/test-results.md` has sections §1-§8 and none of them is the
registry-backed startup smoke. Rule 12g makes this smoke mandatory for every
non-trivial `frontend`-lane story unless `story_master.md` records
`Runtime-Smoke: WAIVED — <reason>`; `story_master.md` is 13 lines and carries no
such line.

The phase file actively contradicts the gate rather than merely omitting it:
`phase-P1-invite-page-body-and-entry-point.md:33` declares
`Startup Smoke: NOT_APPLICABLE` for `web-frontend`. That is the identical
conflict STORY-001 hit, and the fix there was explicitly *both* parts — add the
section *and* correct the `NOT_APPLICABLE` claim so the file does not contradict
its own evidence (`STORY-001/review/review-report.md:52-62`). A `web-frontend`
dev server that boots is not inapplicable to a story that adds a page to it.

This is supplyable now, not blocked: the story already ran a loopback server to
take its 16 captures, and STORY-001 recorded the exact registry-backed command
that satisfied this gate — `npm run dev -- --port 21021 --host 127.0.0.1` under
Node `>=22.12.0`, readiness probe on `GET /`, then `SIGTERM` and a
post-shutdown probe. Record `Result: PASS | Shutdown: PASS`.

Owner: `frontend-dev` (or `devops`).

### BLK-2 — entry-point evidence lacks the canonical heading and `Reachable: YES` (rule 12e1)

The substance is correct and I verified it in code rather than from the
evidence file. The entry point is real and discoverable:

- `web/src/data/site-nav.ts:33` — `{ key: 'share', href: '/share', vi: 'Ghép đôi', en: 'Invite' }` in `navItems`
- `web/src/components/shell/SiteHeader.astro:21-30` — desktop pill nav renders every `navItems` entry, with `aria-current="page"` on the active key
- `web/src/components/shell/SiteHeader.astro:31-35` — mobile `<select>` renders the same list, `selected` on the active key
- `web/src/data/site-nav.ts:48` — footer Product column repeats the `/share` link
- `web/src/pages/share.astro:12` — mounts the delivered body under `page="share"`

So AC-1 passes on substance: the page is reachable by nav item, by mobile
select, and by footer link, not only by typing a URL.

What is missing is the machine-checked form. `test-results.md:92` uses the
heading `## 4. Entry Point Reachability (AC-1)` and closes with a bare `PASS.`
at `:110` — there is no `Reachable: YES` line anywhere in the file. Rule 12e1
requires a `## Entry Point Reachability` section carrying `Reachable: YES` and
the concrete path, and STORY-001 was made to add precisely that literal form
(`STORY-001/review/review-report.md:33-37`). The repository's own recent history
shows this being enforced mechanically after the fact
(`d9ff554 docs(REQ-005/STORY-001): add missing Entry Point Reachability
evidence for DONE gate`).

Fix: rename the heading to the canonical `## Entry Point Reachability` and add
`Reachable: YES` plus the `share → /share` path. Content already present below
it needs no change.

Owner: `frontend-dev`.

## Deferred findings

- **DEF-1 — mobile nav `<select>` shows the VI label while the page is in EN.**
  In `screenshots/implementation-375-light-en.png` the whole page body is
  correctly English, but the header `<select>` reads `Ghép đôi` instead of
  `Invite`. The option text is swapped by JS (`SiteHeader.astro:119-128`), not
  by the `data-vi`/`data-en` CSS mechanism, so it is invisible to this story's
  span-parity count and to §5's "zero blank visible span" check. Two readings
  are possible and I could not separate them from the committed artifacts: the
  capture harness may have set `body.dataset.lang` directly without re-running
  `syncLabels()` (a capture artifact), or the swap genuinely does not fire (a
  real shell defect affecting all 8 pages below 1025px). Either way it is
  STORY-001 shell scope, which this story is contractually forbidden to touch,
  and this story did not make it worse. Route to the requirement-level visual
  audit to settle which it is. Owner: `frontend-dev` at requirement scope.
- **DEF-2 — UI-Fidelity-AC-9 has no rendered design reference
  (`DESIGN_REFERENCE_RENDER_UNAVAILABLE`).** Carried per the Scrum Master
  resolution, and I re-ran the underlying check rather than accepting it:
  `render-design-canvas.js --entry="Cupid Web.dc.html" --list-screens` returns
  `{"screens":[],"toggles":[],"platforms":[]}`, so `--screen=share` has nothing
  to target. The reason is structural: the canvas switches page state through a
  React prop (`startPage`, `Cupid Web.dc.html:696,709`) driven by its own nav
  handlers, not through the `[data-screen-btn]` / `[data-plat]` device-frame
  contract the tool implements. STORY-001 could produce
  `design-reference-home-*.png` only because `home` is the canvas's *default*
  state and needed no driving. Frontend-dev's refusal to hand-drive the
  prototype and label the output `design-reference-share-*.png` was the correct
  call — a self-constructed reference put in front of the fidelity gate
  certifies nothing. Escalation stands: `render-design-canvas.js` needs a
  contract for non-device web canvases, or UI-Fidelity-AC-9 needs an agreed
  alternative anchor.
- **DEF-3 — no `visual-fidelity/` directory for this story.** A direct
  consequence of DEF-2: with no obtainable design reference there is no
  comparison to write, so neither `visual-fidelity-report.md` nor a
  `VISUAL_FIDELITY` verdict exists for STORY-004 (STORY-001 has both). Scrum
  Master should expect the same gap on STORY-002/003/005-008 and settle it once
  at requirement level rather than per story.

## Verified against governing inputs

| AC | Verdict | Evidence |
|---|---|---|
| AC-1 discoverability | PASS | `site-nav.ts:33`, `SiteHeader.astro:21-35`, `site-nav.ts:48`, `share.astro:12` — read directly, not taken from evidence (see BLK-2 for the evidence-form defect) |
| AC-2 hero content | PASS | `InviteHero.astro:7-9` is byte-identical to `Cupid Web.dc.html:389-391`, both locales |
| AC-3 code cells non-functional | PASS | 6 `<div>` cells from `share-content.ts:31` (matches source `:778`); `test-results.md` §3 — 0 `<input`, 0 `tabindex`, 6 cells at `56x68` |
| AC-4 CTA presentational only | PASS | `InviteHero.astro:14` `<a href="#">`, gradient verbatim from source `:397`; no handler, no deep link, no fetch |
| AC-5 phone-mockup sequence | PASS | `PairingSequence.astro:9-33` verbatim against source `:398-418`; 3 filled + 3 empty cells, `MochiSprite size={150}` for the source's `dc-import hint-size="150px,150px"`, "Mochi" / "Ngày thứ nhất của hai bạn" / 2-members / 1-pet chips |
| AC-6 three-step explainer | PASS | `share-content.ts:34-38` VI+EN strings character-exact against source `:421-431`, including the em dashes; icons/colors `qr_code_2`/pink, `favorite`/lilac, `pets`/mint |
| AC-7 keepsake section | PASS | `KeepsakeCards.astro:8-21` against source `:434-449`; `keepsakeCards` (`share-content.ts:41-45`) is verbatim from the source's `cards` array at `:794-798` |
| AC-8 per-page title | PASS | `share.astro:12` passes `title="Cupid — Ghép đôi"`; `SiteLayout.astro:17,25` renders it; `test-results.md` §3 confirms distinctness from Home's `Cupid`. Closes STORY-001 DEF-2 for this page |
| UI-Fidelity-AC-9 visual fidelity | DEFERRED | See DEF-2/DEF-3. Interim anchor accepted: verbatim markup equivalence to `:387-451` verified by me, plus the 16 implementation captures |
| AC-10 copy fidelity | PASS | Every VI/EN pair diffed against the source range; `test-results.md` §3 — `data-vi` 44 = `data-en` 44; §5 — exactly one locale visible per combination, zero blank visible spans |

### Shared-contract immutability (STORY-001 `contract-summary.md` §6)

Verified from the diff, not from the evidence file. `git diff --stat
41b8252..HEAD` touches 6 source files, all inside the phase Write Scope. Nothing
under `web/src/layouts/`, `web/src/components/shell/`, `web/src/styles/`, or
`web/src/scripts/`. No nav item or footer link added, no `localStorage` key, no
`fetch`, no second styling system, no new custom property (`test-results.md` §3
measures 0 inline custom-property definitions in the built HTML, and no
stylesheet changed). The route key stays `share`, not renamed to `/invite`, as
§2 requires. The one added global rule pair
(`InviteHero.astro:18-25` — CTA `:hover` and `:focus-visible`) is scoped to
`.cupid-invite-cta`, matches the `Hero.astro` precedent §4 sanctions, and its
`!important` is justified in place (it must beat an inline declaration).

### Touched risk surfaces and critical gates

| Risk surface | Critical gate | Result |
|---|---|---|
| Typed contract (`PageKey`, `SiteLayout` props) | `astro check` | PASS — 32 files, 0 errors/warnings/hints |
| Frontend interaction (non-functional cells + CTA) | build + DOM assertions | PASS — 1 tab stop in `<main>` (the CTA) at all 16 viewport/theme/language combinations; 0 `<input>`, 0 `tabindex` |
| Frontend discoverability / navigation integration | entry-point evidence + independent code read | Code PASS / evidence FAIL — see BLK-2 |
| Shared-contract immutability | changed-file list | PASS — see above |
| Frontend responsive/reflow | multi-breakpoint measurement | PASS — 375/768/1024/1440 x dark/light x vi/en; mockups stack at 375 with the connector centred (≤4px delta), no horizontal overflow, console clean of errors and warnings on all 16 runs |
| UI-bearing, `design_source` set, `ui_surface: true` | rendered `VISUAL_FIDELITY` verdict | DEFERRED — DEF-2/DEF-3 |
| Runtime / configuration | registry-backed startup smoke | FAIL (absent) — see BLK-1 |

### Visual inspection performed

I opened two of the 16 captures rather than counting the files.
`implementation-1440-dark-vi.png` renders the eyebrow `LỜI MỜI`, the 54px H1,
the six `C U P 1 D 7` cells, the gradient `Mở app Cupid` CTA, both 250x500
device frames with the floating heart connector and its two gradient hairlines,
the three explainer cards with their correct icon colours, and the keepsake
panel showing Milestone 214 / Streak 30/30 / Zodiac 92% — matching the source
range section for section, with the `Ghép đôi` nav pill correctly active.
`implementation-375-light-en.png` renders the full EN copy set with no blank
region, the two mockups stacked with the connector centred between them, and
the keepsake cards in a single column. Neither shows an error state, a loading
frame, or a wrong screen. These are implementation captures only — with no
obtainable design reference (DEF-2) they cannot constitute the AC-9 comparison.

### Configuration guide (rule 12a)

Not applicable. The story adds static page content with no env var, secret,
external integration, or manual setup step, and the phase records
`Requirement Configuration Guide: Update Required: NO`
(`phase-P1-...md:58-59`). The existing
`deployment/configuration-guide.md` needs no update for this story.

## State recommendation

- `Implementation (Development)`: uncheck — return to `frontend-dev`.
- `Review (Reviewer)`: leave unchecked.
- Story status: `IN_PROGRESS`.
- Not yet eligible for merge into
  `codex/REQ-006_web_frontend_design_system_implementation_and_deploy-integration`.
- Re-review scope on return is narrow: BLK-1 and BLK-2 only. The code is
  approved as it stands — if the patch touches nothing under `web/`, the source
  review above stands without re-running, and a scoped re-review of the two
  evidence sections is sufficient.
- Carry DEF-1, DEF-2, DEF-3 forward to the requirement-level visual audit.
