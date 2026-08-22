# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
If the phase names shared interfaces, read those artifacts first.
`../ux/uiux-spec.md` §6.2 already carries every measurement, colour, and VI/EN
string verbatim — read the named subsections there rather than re-deriving them
from `Cupid Web.dc.html`, and open the design source only for the glyph
geometry P1 must copy.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane.
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into migration, rollout, or contract areas not
   assigned to your lane.
6. Stop and escalate if the assigned work requires an unresolved OQ decision
   that the phase does not already resolve.

## 4. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Do not redesign the whole plan during implementation.
- Escalate if the plan is materially wrong.

## 5. Story-Specific Traps

- **Node version.** `astro@6.0.5` requires Node >= 22.12.0 and this machine's
  default is v20.20.2. Run `npm run check` / `npm run build` on a pinned Node;
  an engine failure here looks exactly like a code failure.
- **`npm run build` does not type-check.** `npm run check` (astro check) is the
  type gate and must be run separately.
- **The shell is read-only.** Do not touch `web/src/layouts/`,
  `web/src/components/shell/`, `web/src/styles/`, `web/src/scripts/`,
  `web/src/data/site-nav.ts`, `web/package.json`, or `web/astro.config.*`. Seven
  sibling stories are editing `web/` in parallel worktrees; a shell edit both
  conflicts on merge and re-renders seven other pages whose fidelity evidence is
  already captured. A needed shell change is a finding for Tech Lead, not a
  local edit.
- **Both language spans, always.** Every visible string needs a `data-vi` and a
  `data-en` span. A missing one renders blank in that language with no build
  error and no console warning.
- **Copy exactly.** Date ranges use `" – "` (space, EN DASH U+2013, space); pair
  labels use `×` (U+00D7), not `x`. Do not normalise, re-translate, or fix
  typography.
- **One value, not two.** The compatibility ring's `conic-gradient` stop and the
  number in its inner disc must both derive from `DAILY_READ.score`.
- **No interactive elements.** Nothing on this page is clickable or focusable.
  Do not add a link, button, `tabindex`, `<progress>`, or `<meter>` — the source
  uses plain styled `div`s and the page has no controls of its own.
- **Element-card icons are the one a11y exception.** They have no visible label,
  so they get a real accessible name; every other sign icon sits beside visible
  text and must be `aria-hidden`.
