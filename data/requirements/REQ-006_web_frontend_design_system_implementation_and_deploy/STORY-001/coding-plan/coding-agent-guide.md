# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
If the phase names shared interfaces, read those artifacts first.
If the phase names OQ constraints, read the story requirements
`## Open Question Impact` section before coding and do not implement blocked
scope.

`cupid-app-design-system/Cupid Web.dc.html` is a large file. Read only the exact
line ranges your phase names — never the whole file.

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

## 5. Story-Specific Rules

These override any general habit you bring to a frontend task.

- **The design source is read-only reference, not code.**
  `cupid-app-design-system/*.dc.html` is a design-comp template DSL (`{{ }}`,
  `<sc-for>`, `<sc-if>`, `<dc-import>`, `style-hover=`). It is never imported,
  bundled, copied into `web/`, or served.
- **Copy `style="..."` attributes verbatim.** Do not convert them to classes,
  utilities, CSS modules, shorthand, or "equivalent" values. Tidying a style
  string is the single most likely way to fail UI-Fidelity-AC-6, and it fails
  silently.
- **Every `style-hover` becomes one scoped CSS `:hover` rule.** One rule per
  element; never consolidate across elements.
- **Every user-visible string needs both a `data-vi` and a `data-en` span.** A
  missing span produces a silently blank string in that language, with no error.
  Copy strings character for character — no paraphrasing, no punctuation
  normalization, no re-translation.
- **Do not add anything the design source lacks**: no extra nav item, section,
  breakpoint, placeholder copy, animation, or `localStorage` key. The two
  permitted keys are `cupid-web-theme` and `cupid-web-lang`.
- **Do not install** Tailwind, a CSS framework, a UI kit, React, Vue, or Svelte.
- **No `fetch`, API client, or backend dependency.** REQ-006 is static
  (OQ-REQ006-2 RESOLVED).
- **Accessibility additions are allowed and required** where
  `../ux/uiux-spec.md` §6.1/§6.5/§6.6 names a gap — but only additions that do
  not change rendered pixels (labels, roles, `aria-current`, focus rings).
- **Every visual claim is captured at the Fidelity Baseline** defined in
  `../architecture/solution.md` §4: 1440×900, `data-theme="dark"`,
  `data-lang="vi"`, accent `#FF7FB6`. A capture taken under other conditions is
  not evidence.

## 6. Shell Ownership

`SiteLayout.astro`, `SiteHeader.astro`, `SiteFooter.astro`, `tokens.css`,
`global.css`, and the theme/lang boot script are owned by P2 and are frozen for
STORY-002…STORY-008. If a later page needs a shell change, escalate to Tech
Lead — changing the shell silently re-renders the other seven pages and
invalidates their fidelity evidence.
