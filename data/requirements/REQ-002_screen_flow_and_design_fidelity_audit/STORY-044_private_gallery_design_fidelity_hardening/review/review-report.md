# Review Report — STORY-044 Private Gallery Design Fidelity Hardening

Outcome: DEFERRED_ONLY

- Review type: `compact-story-review` (cycle 1), `completion/resume` (cycle 2)
- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Story: STORY-044_private_gallery_design_fidelity_hardening
- Retro-Type: RED-PATCH (RWB-20260816-010), Fixes: STORY-026
- Reviewer: Iris-QC
- Date: 2026-08-18 (cycle 1), 2026-08-18 (cycle 2)
- Blocking findings: 0 (cycle 1 raised B1; closed in cycle 2)
- Deferred findings: 2

## Scope Gate

- Review type: `compact-story-review`; no separate `scope-gate.md` (skill rule 5a).
- Report path: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-044_private_gallery_design_fidelity_hardening/review/review-report.md`
- Retro discipline: this IS the retro/rework handoff for RWB-20260816-010, so
  core rule 1a is satisfied without a bypass marker.
- Source/config files in scope (2): `coding-plan/render-design-canvas-click.patch`;
  `.ai-team-bundle/runtime/tools/render-design-canvas.js` (ranged reads L55-84,
  L370-429 only — the two patched regions).
- Evidence files in scope (5): `coding-plan/tool-contract-click-flag.md`,
  `coding-plan/test-results.md`, `visual-fidelity/design-reference-gallery-android.png`,
  `visual-fidelity/implemented-gallery-emulator-5560.png`,
  `visual-fidelity/visual-fidelity-report.md` (ranged: L1-120, L120-299, L299-397 —
  21 KB, over the full-read threshold).
- Governing artifacts: `story_master.md`, `requirements/requirements.md`,
  `architecture/solution.md` (16.8 KB, under threshold, full read),
  `scrum-master-checkpoint.md`.
- Git baseline: `git diff --name-only db413549e2` — only `req_master.md`,
  `rework-backlog.md`, `scrum-master-checkpoint.md` modified; the STORY-044
  directory is untracked (pending `git-story-boundary.sh complete`).
- Touched risk surfaces: operational command (`render-design-canvas.js` CLI
  contract), mobile design-fidelity evidence. No persistence, auth, migration,
  external integration, or app-code surface touched.
- Not read (handoff forbids): STORY-035..043 artifacts, full STORY-026 report,
  `rework-backlog.md`, mobile/devops source outside the list above.

## Acceptance Criteria

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC1 `--click` repeatable, after `--screen`, before shutter | PASS | Verified in the live tool, not just the patch: click pass at L392-411 sits after the `--screen` block (L375-390) and before the `label`/screenshot loop (L413-420). See finding N1 on the wording reconciliation. |
| AC2 zero match → typed error, no output | PASS | `die('DESIGN_CANVAS_CLICK_TARGET_MISSING: ...')` at L406 fires before the screenshot loop, so no PNG can be written. Empirically confirmed in `test-results.md` §4: exit 1, output dir verifiably empty via `find`. |
| AC3 no regression to existing captures | PASS | `MULTI_VALUE_KEYS` (L65) is scoped to `click` alone and the whole pass is gated on `clicks.length`. Confirmed empirically by byte-identical SHA-256 re-renders of `welcome` and `register` against their committed references (`test-results.md` §5). |
| AC4 real `galleryOpen` reference rendered | PASS | I opened `design-reference-gallery-android.png`: it depicts the Private Gallery in the **unlocked** state — mint "Đã mở · tự khoá lại sau 60 giây" banner with `00:58`, 2-column photo grid, dashed "Thêm ảnh" tile. This is the `galleryOpen` block, not `galleryLocked`, and no prototype FAB is present. |
| AC5 matched implementation pair | PASS | `implemented-gallery-emulator-5560.png` opens as a real 1080x2400 emulator capture of the gallery grid. Pairing on platform/theme/locale/state/content is proven from `gallery_capture_entry.dart` (`visual-fidelity-report.md` §2). |
| AC6 STORY-026 D1-D10 re-verified | PASS | All ten re-checked against the rendered pair with concrete measurements (§4). D3 (shadow outside the `ClipRRect`) is the one that source reading could never prove and the render now settles. |
| AC7 deviations fixed in app, not documented | PASS | Zero in-scope deviations surfaced, so the conditional Write Scope was correctly not exercised. I checked this claim against the §3-§8 reasoning rather than the header token — see below. |

**Zero-deviation claim independently checked.** The handoff asked me not to take
`In-Scope-Deviations-Found: 0` on trust. The in-scope surface is fixed by
`solution.md` §2 to four regions (grid padding L745, grid definition L751, photo
tiles L752-754, dashed add tile L755). Every residual difference in §3.1-§3.5
resolves into a bucket that predates this story: nearest-token snaps declared in
STORY-026 §1 (bottom padding 40→32, gutters 11→8, chip inset 9→8, label
11.5→13), the disclosed E1/E2/E3 app extensions, and one shadow-falloff
observation on `cupid_platform_tokens.dart` — a path explicitly prohibited to P1
by `solution.md` §3 and a design-system-wide change rather than a gallery fix.
The §6 composite-width analysis genuinely closes E2's open question: at matched
character count the two chips measure 88.0 px vs 88.4 dp, and the tile-2/3 deltas
are fully accounted for by string length. The classification holds.

**Image inspection (rule 12e3).** Both PNGs open as real images and show the
correct screen; neither is a placeholder, error frame, spinner, or wrong canvas
screen. `Design-Screen: gallery` is recorded in `story_master.md` and is the id
actually passed as `--screen=gallery`. The visible differences between the two
images (app bar/back arrow, bottom nav bar, auto-lock banner, screenshot notice)
all sit outside the four in-scope regions and are adjudicated in §7 / `solution.md`
§2. Nothing I can see contradicts the `PASS`.

## Blocking Findings

None open. B1 below was raised in cycle 1 and is **RESOLVED** in cycle 2 — see
`## Cycle 2` for the verification.

**B1 (RESOLVED cycle 2) — missing story-level runtime startup smoke (rule 12g).**
STORY-044 is `Complexity: standard` (non-trivial) with `mobile` in its
implementation lane, so the registry-backed runtime startup smoke is a mandatory
story-level gate. It is absent on both permitted paths:

- `story_master.md` records no `Runtime-Smoke: WAIVED — <reason>` line.
- `coding-plan/test-results.md` has no `## Story Runtime Startup Smoke` section.
  P1.2 supplies analyze / test / build (`flutter analyze`, 45/45 tests,
  `app-debug.apk`), which are build gates, not the app-launches-on-device gate.

The DONE gate (`validate-done-gate.sh`) enforces this independently, so closure
will be rejected regardless of this report's verdict.

Mitigating context, which makes the remedy cheap either way: this phase changed
zero app code. I confirmed `git diff --name-only db413549e2` touches no `mobile/`
path, matching the P1.1 claim, so the app's boot behaviour is byte-identical to
`BaseHead`.

Either remedy closes B1:

1. **[owner: mobile-dev]** Launch the app on the emulator per the `mobile-app`
   registry entry, confirm it reaches its first screen with no crash or error
   screen, and record the result as `## Story Runtime Startup Smoke` in
   `coding-plan/test-results.md`; or
2. **[owner: scrum-master]** Record `Runtime-Smoke: WAIVED — evidence-only
   phase; zero app-code delta vs BaseHead db413549e2 (`git diff --stat
   db413549e2 -- mobile/` empty)` in `story_master.md`. Reviewer must not edit
   `story_master.md` (skill rule 7), which is why this is routed rather than
   applied.

No other rework is required. Findings B1 aside, the implementation and evidence
are sound and no AC failed.

## Deferred Findings

**D-1 — the `--click` change is not durable (KD4).** The tool file is gitignored
(`.gitignore:5`), so the committed patch plus contract note are the only durable
artifacts and the next `./install.sh --platform=claudecode` run overwrites the
working change. P0 handled this correctly within its reach; upstream propagation
to the bundle source repo is out of this story's scope. `solution.md` §3 already
routes it to Scrum Master as a follow-up alongside the still-`PENDING` RWB-020,
which has the identical shape. Carried here so it is not lost at story closure.

**D-2 — shadow falloff length differs by platform convention.** CSS `blur: 18`
(sigma 9) versus Flutter `blurRadius: 18` (sigma ≈ 10.4) on an exactly
transcribed token. Peak elevation lift matches; only the decay length differs.
Fix belongs to whichever story owns
`mobile/lib/design_system/tokens/cupid_platform_tokens.dart`, and it would be a
platform-wide recalibration. Correctly excluded from this phase.

## Traceability

- Requirements: AC1-AC7 verified above; OQ5 (light theme / `en` locale) correctly
  triaged as unresolved-but-non-blocking, consistent with STORY-026's precedent.
  No AC requires light theme or `en`.
- UX: `SKIPPED:no-new-ux-content` is justified — no new screen, flow, interaction,
  or responsive/a11y decision; the story reuses the already-approved `galleryOpen`
  reference.
- Architecture: KD1 (corrected line table), KD2 (Playwright selector engine, not
  `querySelectorAll`), KD3 (`--platform=android` only), KD4 (patch as the durable
  deliverable) are each honoured in the delivered implementation. R1 verified and
  not reproduced with no speculative code added; R2 respected (out-of-scope regions
  annotated, not hidden); R3 not triggered; R4 freshness confirmed.
- Configuration guide: `solution.md` §5 records NOT_APPLICABLE. Correct — no
  runtime service, env var, secret, port, or dependency change.
- Entry point (12e1): not applicable. The story delivers no new user-facing
  capability; the gallery entry point is pre-existing and unchanged (zero Dart delta).

## Risk Surfaces And Gates

| Surface | Critical gate | Result |
| --- | --- | --- |
| Operational command (`render-design-canvas.js` CLI) | No regression to existing captures | PASS — SHA-256 byte-identical for `welcome` and `register` |
| Operational command — failure mode | Typed error, no partial output | PASS — exit 1, empty output dir |
| Mobile design fidelity | Rendered pair + `VISUAL_FIDELITY` verdict | PASS — both images inspected, verdict supported by §3-§8 |
| Mobile build integrity | analyze / test / build | PASS — 1 pre-existing `info` lint outside scope, 45/45 tests, APK built |
| Mobile runtime | Story runtime startup smoke | WAIVED — `story_master.md:18` per rule 12g (was B1) |

## Cycle 2 — B1 verification (`completion/resume`)

Scope of this cycle was B1 alone. Cycle 1's scope gate is reused unchanged; no
artifact, image, or source file was reread.

**B1 is closed.** `story_master.md:18-22` now records, in the top metadata block
immediately above `## Artifacts`:

> `Runtime-Smoke: WAIVED — evidence-only phase; zero app-code delta vs BaseHead
> db413549e2 (...confirmed empty by Scrum Master 2026-08-18). Recorded per
> review/review-report.md finding B1 remedy 2 (reviewer may not edit this file).
> Resolves B1.`

This satisfies rule 12g's only permitted escape: the gate is waived in the story
master with a stated reason, and the stated reason is the correct one. I did not
take the factual claim on trust — I re-ran
`git diff --stat db413549e2d0c877e1ce3a01f1d7b1b3e8394a6f -- mobile/` myself and
it returned no output, so the zero app-code-delta premise the waiver rests on
holds independently of who asserted it. Remedy 2 from cycle 1 is met verbatim,
including its ownership constraint.

**Verdicts carried forward unchanged.** AC1-AC7 all remain PASS; nothing in this
cycle touched the evidence those verdicts rest on, and B1 was never an AC failure
— it was a missing operational gate alongside a passing implementation. D-1
(gitignored tool change not durable, upstream follow-up alongside RWB-020) and
D-2 (shadow falloff Gaussian convention on the design-system token layer) remain
open as deferred, not re-opened and not resolved by this cycle.

With no blocking finding remaining and two deferred notes recorded, the outcome
moves from `PATCH_REQUIRED` to `DEFERRED_ONLY`.

## State Recommendation

- Keep `Implementation (Development)` checked in `story_master.md`.
- Check `Review (Reviewer)`.
- Story status: `DONE`.
- RWB-20260816-010 may be marked `RESOLVED`: the rework item's own remediation
  path (a) is delivered — the `--click` tool fix exists, the real `galleryOpen`
  reference was rendered, and STORY-026's findings were re-verified against a
  genuine rendered pair, clearing its
  `DESIGN_CANVAS_STATE_FORCE_UNSUPPORTED` block.
- Carry D-1 forward as a follow-up item. It shares its shape with the still-
  `PENDING` RWB-020, and the `--click` change is lost on the next
  `./install.sh --platform=claudecode` run until the bundle source repo is
  updated upstream.
