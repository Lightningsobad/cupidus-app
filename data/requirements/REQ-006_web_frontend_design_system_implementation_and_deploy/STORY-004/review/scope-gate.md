# Scope Gate — REQ-006 / STORY-004 Pairing Invite Landing Page

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

Review type: `full-story-review` (parallel story review)
Review report path: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-004/review/review-report.md`
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-004`
Diff baseline: `41b82520c7499662e42075bc1bb8a91fe084fe3b` → HEAD `0cd7ca750bc8f50983cb5c73d413163c05fe2424`
Story: `standard` / lane `frontend` / class `standard`

## Source/test files in scope (6 changed + 4 shell files read for verification)

Changed by this story (all inside the phase Write Scope):

- `web/src/pages/share.astro`
- `web/src/components/share/InviteHero.astro`
- `web/src/components/share/PairingSequence.astro`
- `web/src/components/share/InviteSteps.astro`
- `web/src/components/share/KeepsakeCards.astro`
- `web/src/data/share-content.ts`

Read unchanged, to verify the entry point and shell immutability independently:

- `web/src/data/site-nav.ts`
- `web/src/components/shell/SiteHeader.astro`
- `web/src/layouts/SiteLayout.astro`
- `cupid-app-design-system/Cupid Web.dc.html` (ranged: `:386-451`, `:40-60`,
  `:690-720`, `:775-800`)

## Evidence files in scope

- `coding-plan/test-results.md` §1-§8
- `coding-plan/screenshots/implementation-1440-dark-vi.png`,
  `implementation-375-light-en.png` (visual inspection)
- `coding-plan/phase-P1-invite-page-body-and-entry-point.md` §4 Acceptance
  Criteria, §6 Test Scope, §7 Status
- `../requirements/requirements.md` AC-1..AC-10
- `../../STORY-001/architecture/contract-summary.md` §2, §4, §6
- `../../STORY-001/review/review-report.md` (precedent for the mandatory
  evidence sections in this requirement)
- `data/devops/system/design-fidelity-config.json`

## Touched risk surfaces and critical gates

| Risk surface | Critical gate | Verify by |
|---|---|---|
| Frontend interaction (non-functional cells/CTA) | build + type-check + DOM assertions | `test-results.md` §1, §3, §5 |
| Frontend discoverability / navigation integration | `## Entry Point Reachability` + independent code read | `test-results.md` §4 + `site-nav.ts` / `SiteHeader.astro` |
| Typed contract (`PageKey`, `SiteLayout` props) | `astro check` | `test-results.md` §1 |
| Shared contract immutability (STORY-001 shell) | changed-file list | `git diff --name-only <BaseHead>` |
| UI-bearing, `design_source` set, `ui_surface: true` | rendered `VISUAL_FIDELITY` verdict | see AC-9 deferral below |
| Runtime / configuration | registry-backed startup smoke | `## Story Runtime Startup Smoke` |
| Runtime / configuration guide | 12a applicability | phase §1B `Update Required: NO` |

## Query keys for Phase 2

`isShare`, `codeCells`, `cards`, `inviteSteps`, `startPage`, `navItems`,
`share`, `Reachable: YES`, `Story Runtime Startup Smoke`, `VISUAL_FIDELITY`,
`data-vi`/`data-en`, `<title>`, `tabindex`, `<input`.

## Carried Scrum Master resolution (not re-litigated here)

AC-9's design-canvas render (`render-design-canvas.js --screen=share`) is
recorded `DESIGN_REFERENCE_RENDER_UNAVAILABLE` and already deferred by Scrum
Master to the requirement-level `frontend-dev Mode: requirement-visual-audit`.
This gate independently re-ran `--list-screens` to confirm the premise; it does
not re-block the story on the missing design reference.

## Phase 2 decision

Proceed to focused verification. Scope is inside the `full-story-review` budget
(6 changed files, 1 governing artifact over ~20 KB — `ux/uiux-spec.md`, read by
range only via the phase file's line-cited values).
