# UX Spec: STORY-002 Pairing-Choice Navigation Restore

Screen id restored to the design canvas: **`pairingchoice`** (no underscore,
`isPairingChoice` flag) — same id/flag STORY-034
(`REQ-002_screen_flow_and_design_fidelity_audit/STORY-034_pairing_choice_canvas_addition`)
originally authored. Commit `3d74a75` (2026-08-20) deleted this node and its
supporting plumbing along with rewiring the edges below; this spec restores
exactly what that commit removed, verified line-by-line against the current
design source, not re-derived from scratch.

## What was verified in the current design source before writing this spec

Read (grep + ranged reads only, per large-file policy —
`cupid-app-design-system/Cupid Screens.dc.html` is 241 KB and was never
full-read):

- `cupid-app-design-system/Cupid Screens.dc.html`: no `isPairingChoice`
  anywhere; `isInvite` block (lines 168-203) CTA at line 201 targets
  `{{ goVow }}` with copy "Tiếp tục → Fingerprint Vow" / "Continue →
  Fingerprint Vow"; `BACK_TO` (line 1853) has `joincode: 'invite'` and
  `invite: 'profile'`, no `pairingchoice` entry; `INDEX` "Ghép đôi" category
  (lines 1865-1872) has no `pairingchoice` item; `NO_CHROME`/`NO_TABS` (lines
  1951-1952) have no `pairingchoice` entry; no `goPairingChoice`, `goJoinCode`,
  or `goWaiting` handler exists anywhere in the file. `goInvite`,
  `goContract`, `goVow`, `goPaired` (lines 2130, 2437) and the `isJoinCode` /
  `isWaiting` / `isPaired` flags (line 2434) already exist and are unaffected.
- `cupid-app-design-system/Cupid App.dc.html`: the top demo nav bar has
  `data-screen-btn="profile"` (line 191) immediately followed by
  `data-screen-btn="contract"` (line 192) — no `pairingchoice` button between
  them (it sat there before `3d74a75`, per STORY-034's original spec).

This confirms the diagnosis in
`data/bugs/BUG-20260824-001_pairing_code_screen_missing_design/diagnosis.md`
("Design-source drift finding") against the live file, not just against the
bug report's prose.

## Design-system source changes to make (exact instructions for whoever applies this spec)

### 1. `cupid-app-design-system/Cupid App.dc.html`

Insert, between the existing `data-screen-btn="profile"` line (191) and
`data-screen-btn="contract"` line (192):

```html
<span data-screen-btn="pairingchoice" style="padding:6px 11px;border-radius:7px;background:rgba(248,240,247,.06);color:rgba(248,240,247,.75)">Pairing choice</span>
```

This is what makes the node enumerable by `render-design-canvas.js
--list-screens` and renderable by `--screen=pairingchoice`.

### 2. `cupid-app-design-system/Cupid Screens.dc.html`

**a. New `isPairingChoice` screen body** — insert immediately after the
`isProfile` block's closing `</sc-if>` (line 119) and before the `isContract`
block (line 121):

```html
<sc-if value="{{ isPairingChoice }}" hint-placeholder-val="{{ true }}">
<div style="min-height:100%;display:flex;flex-direction:column;padding:150px 28px 0">
<div style="text-align:center;font-family:Nunito;font-weight:900;font-size:24px;line-height:1.3"><span data-vi>Ghép đôi để mở khoá Cupid</span><span data-en>Pair up to unlock Cupid</span></div>
<div onClick="{{ goInvite }}" style="margin-top:28px;height:52px;border-radius:var(--r-btn);background:linear-gradient(95deg,var(--pink),var(--purple));color:#fff;display:flex;align-items:center;justify-content:center;font-size:16.5px;font-weight:700;cursor:pointer;box-shadow:var(--glow)"><span data-vi>Ghép đôi với người ấy</span><span data-en>Pair up with them</span></div>
<div onClick="{{ goJoinCode }}" style="margin-top:16px;text-align:center;font-size:13.5px;font-weight:700;color:var(--pink);cursor:pointer"><span data-vi>Tôi đã có mã</span><span data-en>I already have a code</span></div>
</div>
</sc-if>
```

Content, layout and copy reused verbatim from STORY-034's original spec
(`REQ-002.../STORY-034_pairing_choice_canvas_addition/ux/uiux-spec.md`), which
was itself sourced from the running app's actual `pairingchoice` capture — not
invented here.

**b. `isInvite` block CTA (line 201)** — restore the pre-`3d74a75` target:

- Before: `onClick="{{ goVow }}"` / "Tiếp tục → Fingerprint Vow" / "Continue →
  Fingerprint Vow"
- After: `onClick="{{ goWaiting }}"` / "Tiếp tục → Đợi ghép" / "Continue →
  Waiting"

**c. `INDEX` sidebar** (the "Ghép đôi" category, lines 1865-1872) — add as the
first item, ahead of `invite`:

```js
{ id: 'pairingchoice', icon: 'favorite_border', vi: 'Chọn cách ghép đôi', en: 'Pairing choice' },
```

**d. `BACK_TO`** (line 1853) — change:

- `joincode: 'invite'` → `joincode: 'pairingchoice'`
- `invite: 'profile'` → `invite: 'pairingchoice'`
- add `pairingchoice: 'profile'` (restores the node's own back target — this
  is part of restoring the node itself, not one of the two edges the handoff
  names, but without it `canBack` for `pairingchoice` would silently resolve
  to `false` since it's chromeless anyway and no header renders regardless;
  restoring it keeps the node's data fully self-consistent with how STORY-034
  originally shipped it, and costs nothing since `NO_CHROME` already hides any
  back affordance on this node)

**e. `NO_CHROME`, `NO_TABS`** (lines 1951-1952) — add `pairingchoice: 1` to
both. Same AC4-chromeless requirement as every other pre-pairing node
(`waiting`, `paired`, etc.) — full-bleed, no header, no bottom tabs.

**f. New navigation handlers** — add next to the existing `goInvite`/
`goContract`/`goVow` cluster (line 2130):

```js
goJoinCode: () => a.go('joincode'), goWaiting: () => a.go('waiting'),
```

(`goInvite` already exists and is reused unchanged for `pairingchoice`'s first
CTA. `goJoinCode`/`goWaiting` do not exist anywhere in the file today — grep
verified above — so both need adding for `pairingchoice`'s second CTA and the
restored `isInvite` CTA respectively.)

**g. New flag** — add next to the existing `isWelcome`/`isProfile`/
`isContract`/`isInvite`/`isVow` flags (line 2133):

```js
isPairingChoice: sc === 'pairingchoice',
```

## Navigation graph after this restore

```
profile ──goContract──▶ contract          (unchanged by this story — see note below)

pairingchoice ─┬─goInvite──▶ invite ──goWaiting──▶ waiting ──goPaired──▶ paired ──goContract──▶ contract ──goVow──▶ vow
               └─goJoinCode▶ joincode ─────────────goPaired──────────────▶ paired

BACK_TO: pairingchoice → profile
         invite        → pairingchoice
         joincode       → pairingchoice
```

This matches the pre-`3d74a75` chain documented in the bug diagnosis and in
REQ-002 STORY-002's own corrected navigation graph: `profile_setup →
pairing_choice → {invite → waiting → paired | join_code → paired} →
love_contract → vow → home`.

## Scope boundary — what this spec does NOT change (flag for Tech Lead, not resolved here)

- **`profile`'s own CTA still targets `goContract`, not `pairingchoice`.**
  Verified live in the current file (§ "What was verified" above) — this was
  already true before `3d74a75` touched anything downstream of it, and this
  story's own scope (`story_master.md` § In Scope items 1-2, `req_master.md`
  Locked Decision 2) is bounded to the two invite/join-code edges into
  `pairingchoice`, not `profile`'s edge into it. In the design canvas as
  restored here, `pairingchoice` is reachable by the top-nav `data-screen-btn`
  (for `--screen=pairingchoice` fidelity rendering, satisfying AC6) and by
  `BACK_TO` from `invite`/`joincode`, but not by forward click-through from
  `profile`. Whether the actual Flutter `OnboardingRouter` already places
  `pairing_choice_screen.dart` between profile-setup and invite/join-code (as
  the Product Owner's breakdown flagged it might) is exactly the
  implementation-verification question the handoff assigns to Tech Lead —
  this spec does not take a position on it, and does not require `profile`'s
  canvas CTA to change for AC1-7 to be satisfiable from a design-reference
  standpoint.
- Reordering the physical HTML block position of `isPairingChoice` relative to
  other already-correct screen bodies beyond the one specified insertion point
  above.
- `invite`/`joincode`/`profile`'s own headers (`NO_CHROME` gap) — a separate,
  already-identified finding (STORY-034's "F-A"), not this story's scope.
- The couple-type picker content itself (STORY-001's scope) —
  `COUPLE_TYPES` already exists in this same file (lines 1824-1829) as a
  separate, pre-existing catalog with different copy/icons than STORY-001's
  locked content decision in `req_master.md`; reconciling that is STORY-001's
  own UX Design phase, not touched here.
- Redesigning Fingerprint Vow or its own entry point.

## Confirmed render command for Scrum Master / fidelity comparison (AC6)

```
render-design-canvas.js --screen=pairingchoice --platform=android --theme=dark --lang=vi
```

Same device/theme/lang convention as the story's OQ5 disposition (dark + `vi`
only; no light/EN rendered pass required).

## Regression-test note (AC7, informational — not this spec's own artifact)

`req_master.md`'s regression-risk bullet and `story_master.md` AC7 call out
`app_shell_test.dart` and any other test still pinned to the `goVow` post-code
navigation target. This spec restores the design-source expectation
(`goWaiting`) that those tests should now assert against; updating the actual
Dart test files is implementation/verification scope, not UX Design scope.
