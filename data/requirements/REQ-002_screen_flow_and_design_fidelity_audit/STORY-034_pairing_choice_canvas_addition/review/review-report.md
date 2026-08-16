# Review Report: STORY-034 Pairing Choice Canvas Addition

Review type: `compact-story-review`
Story: REQ-002_screen_flow_and_design_fidelity_audit / STORY-034_pairing_choice_canvas_addition
Complexity: `trivial` — single lane (`ui-ux-designer`), design-asset only
Reviewed at BaseHead: `40351308d6040ec9d96e92c2900732bf4af472df`
Reviewer: Iris-QC

Outcome: DEFERRED_ONLY

## Scope Gate

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES
Scope gate path: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-034_pairing_choice_canvas_addition/review/scope-gate.md`

The handoff's general compact-mode guidance says to keep the scope gate inline, but
`validate-reviewer-two-phase.sh` requires the separate file even in compact mode, so the
file was written first and both agree.

| Field | Value |
|---|---|
| Touched files in scope | 6 (budget 8): `Cupid App.dc.html`, `Cupid Screens.dc.html`, `design-reference-pairingchoice-android.png`, `implemented-pairingchoice-emulator-5560.png`, `story_master.md`, `ux/uiux-spec.md` |
| Evidence used | `git diff 4035130 -- "Cupid App.dc.html" "Cupid Screens.dc.html"` (+18/-7); both PNGs opened and compared; `story_master.md` AC1-4; `ux/uiux-spec.md` §§ "What was added", "F-B resolution" |
| Out of scope, not read | STORY-002 app code, `chain_chrome_guard_test.dart`, STORY-002 review artifacts; `req_master.md` / `master_requirements_list.md` / checkpoint (Scrum Master state) |
| Retro gate | Satisfied — this story IS the retro/rework item (`Scope: Retro-hardening (RWB-20260816-001)`) |
| Phase 2 | PROCEED |

## Acceptance Criteria

| AC | Verdict | Evidence |
|---|---|---|
| AC1 — node exists and is enumerable | PASS | Diff adds `<span data-screen-btn="pairingchoice">` to the `Cupid App.dc.html` nav bar (the `--list-screens` scan target) and `{ id: 'pairingchoice', icon: 'favorite_border', ... }` to `INDEX` under the pairing category. Corroborated by AC3: the render only succeeds if `--screen=pairingchoice` resolves. |
| AC2 — F-B closed, chain reconciled | PASS | See "F-B closure" below — fixed at the source, not worked around. |
| AC3 — render produced and placed | PASS | `design-reference-pairingchoice-android.png` present in STORY-002's `visual-fidelity/` at 406x900. Opened it: a real rendered screen (title, pill CTA, secondary link, chromeless) — not blank, not an error frame, not a placeholder. |
| AC4 — pair reads MATCH | PASS | Direct image comparison below. |

## F-B closure (AC2)

The canvas previously encoded a shorter/differently-ordered pairing chain. The diff rewires
it to the app's real chain
(`profile → pairingchoice → {invite → waiting | joincode} → paired → contract → vow`):

| Edge | Before | After |
|---|---|---|
| `profile` CTA | `goContract` ("Tiếp tục → Love Contract") | `goPairingChoice` ("Tiếp tục → Ghép đôi") |
| `invite` CTA | `goVow` ("Tiếp tục → Fingerprint Vow") | `goWaiting` ("Tiếp tục → Đợi ghép") |
| `contract` both-signed CTA | `goInvite` (backward edge into pairing) | `goVow` ("Cả hai đã ký → Fingerprint Vow") |
| `BACK_TO` | `joincode: 'invite'`, `invite: 'profile'` | `joincode: 'pairingchoice'`, `invite: 'pairingchoice'`, `pairingchoice: 'profile'` |

New handlers `goPairingChoice`/`goJoinCode`/`goWaiting` and flag `isPairingChoice` are all
present in the diff. `waiting` and `joincode`, previously reachable only via the demo nav
bar, are now in the click-through chain. `chain_chrome_guard_test.dart` was not re-verified
and stays authoritative — correctly out of scope.

`NO_CHROME` and `NO_TABS` both gain `pairingchoice: 1`, required for the render to satisfy
AC4's chromeless rule. Verified in the diff and confirmed in the rendered image (no header,
no back arrow, no bottom tabs).

## Visual fidelity — direct image comparison (AC4)

Both images were opened, not merely checked for existence. The reference depicts *this*
screen, not a neighbouring canvas node. Same-screen-pair rule: **MATCH**.

| Element | Reference (406x900) | Implemented (405x900) | Reads |
|---|---|---|---|
| Title | "Ghép đôi để mở khoá Cupid" | same | MATCH |
| Primary pill | "Ghép đôi với người ấy" | same | MATCH |
| Secondary link | "Tôi đã có mã" | same | MATCH |
| Header / back arrow | absent | absent | MATCH |
| Bottom tab bar | absent | absent | MATCH |
| Lower surface | empty | empty | MATCH |

RWB-20260816-001 is resolvable: a design reference for the same screen now exists and pairs
with `implemented-pairingchoice-emulator-5560.png`.

## Deferred findings

**D1 — the app build does not apply the design system's surface/CTA styling to
`pairing_choice`.** Content matches; styling does not:

1. Background — reference: purple→magenta gradient with small particle accents; implemented:
   flat dark navy, no gradient, no particles.
2. Primary pill — reference: pink→purple gradient with glow (`var(--grad-hot)` + `var(--glow)`);
   implemented: flat solid pink, no gradient, no glow.
3. Type scale — implemented title and pill label render visibly larger, so the pill label wraps
   to two lines and the title wraps at a different word than the reference.
4. Title vertical offset sits lower in the implementation (~32% vs ~23% down).

Classification: pre-existing, out of scope. The screen belongs to STORY-002 (DONE/merged) and
STORY-034's `## Out of Scope` forbids touching that app code, so this story cannot supply the
fix — not `PATCH_REQUIRED` here. STORY-034 did not make it worse; it made the gap visible for
the first time by creating a reference that never existed. This is not `DEFERRED_ONLY` masking
a primary gate: the proof of *this* story's change is the diff, the enumeration, and the
successful render, all passing.

Recommendation: raise a new RWB item against the `mobile` lane to bring `pairing_choice` onto
the design system's gradient surface, gradient+glow CTA, and type scale. Route to `mobile-dev`,
not back to STORY-034.

Not a finding: the reference carries the canvas Android device bezel while the emulator capture
does not. That frame convention is already established across REQ-002's `design-reference-*` set.

## Gates

Design source (diff + enumeration) PASS. Design fidelity pairing (both images opened) PASS
with D1 deltas. No app code touched, so runtime startup smoke and entry-point reachability
are not required for this `trivial` design-asset story.

Screen id note: `pairingchoice` (no underscore) is used instead of the AC's `pairing_choice`.
`ux/uiux-spec.md` documents the reason (canvas ids are single concatenated tokens; matches
`main_preview.dart`'s existing `'pairingchoice'` route key). Documented, not silent — accepted.

## State recommendation

- Check `Review (Reviewer)`; story status `DONE`
- RWB-20260816-001: RESOLVED
- Open a new RWB item for D1 against the `mobile` lane
