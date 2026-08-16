# Retro Rework Backlog

Registry of remediation items surfaced by retro-review audits. `scrum-master`
checks this file before ordinary `continue`; any `PENDING` or `IN_PROGRESS`
item blocks plain ordinary backlog continuation until the user runs
`continue retro` (or explicitly bypasses with `continue normal` /
`continue ordinary` / `continue backlog` / `continue ignoring retro`).

| Item ID | Source Audit | Status | Priority | Story | Summary |
|---|---|---|---|---|---|
| RWB-20260816-001 | REQ-002 retro-audit/audit-report.md | RESOLVED | HIGH | STORY-002_onboarding_pairing_navigation | `pairing_choice` screen has no design-canvas counterpart; user decision 2026-08-16 routed ui-ux-designer to add the canvas node + resolve F-B; delivered as STORY-034_pairing_choice_canvas_addition (DONE, Reviewer DEFERRED_ONLY) |
| RWB-20260816-012 | REQ-002 STORY-034 review/review-report.md (D1) | PENDING | LOW | STORY-002_onboarding_pairing_navigation | `pairing_choice` app build does not apply the design system's surface/CTA styling (gradient bg, glow CTA, type scale) even though content/structure now MATCH; pre-existing gap surfaced by STORY-034's new reference render; route to mobile lane |
| RWB-20260816-002 | REQ-002 retro-audit/audit-report.md | PENDING | HIGH | STORY-004_welcome_design_fidelity | Missing both sides of `welcome` evidence pair (already flagged as IF-7 in req_master.md) |
| RWB-20260816-003 | REQ-002 retro-audit/audit-report.md | PENDING | MEDIUM | STORY-006_register_design_fidelity | Missing both sides of `register` evidence pair |
| RWB-20260816-004 | REQ-002 retro-audit/audit-report.md | PENDING | MEDIUM | STORY-011_invite_code_design_fidelity | Missing both sides of `invite` evidence pair |
| RWB-20260816-005 | REQ-002 retro-audit/audit-report.md | PENDING | MEDIUM | STORY-014_paired_success_design_fidelity | Missing both sides of `paired` evidence pair (report describes a near-full rewrite, never visually confirmed) |
| RWB-20260816-006 | REQ-002 retro-audit/audit-report.md | PENDING | MEDIUM | STORY-015_love_contract_design_fidelity | Missing both sides of `contract` evidence pair |
| RWB-20260816-007 | REQ-002 retro-audit/audit-report.md | PENDING | MEDIUM | STORY-018_chat_typing_ghost_design_fidelity | Missing both sides of `chat` evidence pair (must capture the typing-ghost UI state specifically) |
| RWB-20260816-008 | REQ-002 retro-audit/audit-report.md | PENDING | MEDIUM | STORY-022_anti_ghosting_settings_design_fidelity | Missing both sides of `antighost` evidence pair |
| RWB-20260816-009 | REQ-002 retro-audit/audit-report.md | PENDING | MEDIUM | STORY-025_love_timeline_design_fidelity | Missing both sides of `timeline` evidence pair; reviewer's own round-2 report already flags this as unresolved |
| RWB-20260816-010 | REQ-002 retro-audit/audit-report.md | PENDING | HIGH | STORY-026_private_gallery_design_fidelity | `galleryOpen` state cannot be forced by `render-design-canvas.js`; needs a tooling fix or explicit exemption |
| RWB-20260816-011 | REQ-002 retro-audit/audit-report.md | PENDING | MEDIUM | STORY-028_shared_expenses_design_fidelity | Missing both sides of `expense` evidence pair |

---

## RWB-20260816-001 — STORY-002 pairing_choice: no canvas screen exists

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-002_onboarding_pairing_navigation/`
Status: RESOLVED
Priority: HIGH

**Resolution (2026-08-16):** Delivered as `STORY-034_pairing_choice_canvas_addition`
(Status: DONE). `pairingchoice` node added to the design system
(`Cupid App.dc.html` nav bar + `Cupid Screens.dc.html` screen body, INDEX,
BACK_TO, NO_CHROME/NO_TABS); finding F-B closed by rewiring the canvas CTA
graph to the app's real chain (`profile → pairingchoice → {invite → waiting |
joincode} → paired → contract → vow`).
`design-reference-pairingchoice-android.png` rendered and paired with
`implemented-pairingchoice-emulator-5560.png` in both STORY-002's and
STORY-034's own `visual-fidelity/` directories. Reviewer (Iris-QC) recorded
AC1-4 all PASS and `Outcome: DEFERRED_ONLY` — see
`STORY-034_pairing_choice_canvas_addition/review/review-report.md`. Deferred
finding D1 (styling divergence, not structural) tracked separately as
RWB-20260816-012.

**User decision (2026-08-16):** the design canvas is missing this screen,
not the app. Route `ui-ux-designer` to add a `pairing_choice` node to the
design system and resolve finding F-B (canvas encodes a shorter pairing
chain than the app), then render `design-reference-pairingchoice-*` and pair
it with the existing implemented capture. Recorded in `req_master.md` §
`## Retro Audit`. Tracked as
`STORY-034_pairing_choice_canvas_addition` (Implementation Lane:
ui-ux-designer).

Current evidence: `visual-fidelity/implemented-pairingchoice-emulator-5560.png`
exists; no `design-reference-pairingchoice-*` exists. The story's own report
confirms this is not an oversight — `render-design-canvas.js --list-screens`
was run (37 ids enumerated) and none corresponds to a `pairing_choice` state;
`invite`/`joincode`/`profile` were each considered and rejected. AC
conformance was instead verified against AC4's chrome rule plus
`chain_chrome_guard_test.dart` (18/18 passing).

Additional finding surfaced by this audit, not yet in `req_master.md`'s
Deferred Follow-Up Items: the same investigation (**F-B**) found the design
canvas encodes a *shorter* pairing chain that appears to omit a
`pairing_choice`-equivalent node entirely — i.e. the canvas itself may be
missing this screen, not just the render tooling.

Exact remediation needed (one of):
1. Product Owner / UI-UX Designer confirms whether the design canvas is
   missing this screen by design intent or by omission; if by omission,
   route a canvas-export request so `render-design-canvas.js --screen=pairing_choice`
   (or the correct new screen id) can produce
   `design-reference-pairingchoice-*.png` to pair with the existing
   `implemented-pairingchoice-emulator-5560.png`.
2. Or: Scrum Master/PO records an explicit, durable exemption in
   `req_master.md` accepting the AC4 chrome-rule + `chain_chrome_guard_test.dart`
   structural-test baseline as the permanent substitute evidence for this
   specific screen — no such exemption currently exists.

Either path should also resolve/triage finding F-B (chain-order mismatch
between canvas and app) since it directly affects which fix is correct.

## RWB-20260816-002 — STORY-004 welcome: zero rendered evidence either side

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-004_welcome_design_fidelity/`
Status: PENDING
Priority: HIGH

Current evidence: `visual-fidelity/` holds only `visual-fidelity-report.md`,
no images. The report's comparison method was reading the CSS/HTML prototype
literally against the Flutter widget tree — this is the already-known IF-7
gap in `req_master.md`, the direct cause of `BUG-20260816-001` reaching
integration undetected.

Exact remediation needed:
1. Capture `implemented-welcome-<device>.png` from the running app.
2. Render `design-reference-welcome-<platform>.png` via
   `render-design-canvas.js --screen=welcome`.
3. Note: STORY-033's own folder already contains a matched
   `design-reference-welcome-android.png` / `implemented-welcome-emulator-5554.png`
   pair for the same screen. That does NOT satisfy this rule — the pair
   must live in STORY-004's own `visual-fidelity/` directory — but it can be
   reused as a starting reference/baseline if the welcome screen has not
   changed since STORY-033.

## RWB-20260816-003 — STORY-006 register: zero rendered evidence either side

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-006_register_design_fidelity/`
Status: PENDING
Priority: MEDIUM

Exact remediation needed: capture `implemented-register-<device>.png` from
the running app; render `design-reference-register-<platform>.png` via
`render-design-canvas.js --screen=register`.

## RWB-20260816-004 — STORY-011 invite: zero rendered evidence either side

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-011_invite_code_design_fidelity/`
Status: PENDING
Priority: MEDIUM

Exact remediation needed: capture `implemented-invite-<device>.png` from the
running app; render `design-reference-invite-<platform>.png` via
`render-design-canvas.js --screen=invite`. Note: a
`design-reference-invite-android.png` already exists in STORY-002's own
folder, confirming the `invite` canvas screen renders fine and tooling is
not the blocker here — the capture was simply never produced for this
story's own directory.

## RWB-20260816-005 — STORY-014 paired/paired-success: zero rendered evidence either side

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-014_paired_success_design_fidelity/`
Status: PENDING
Priority: MEDIUM

The report describes the pre-existing screen as "not a partial match — it
was a placeholder," with 15 deviations found and 14 corrected in code, none
of it visually confirmed.

Exact remediation needed: capture `implemented-paired-<device>.png` from the
running app (post-pairing success state); render
`design-reference-paired-<platform>.png` via `render-design-canvas.js
--screen=paired` (confirm exact screen id via `--list-screens` if `paired`
does not resolve).

## RWB-20260816-006 — STORY-015 love contract: zero rendered evidence either side

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-015_love_contract_design_fidelity/`
Status: PENDING
Priority: MEDIUM

Report used a "Token Mapping Policy" (code/token comparison only).

Exact remediation needed: capture `implemented-contract-<device>.png` from
the running app; render `design-reference-contract-<platform>.png` via
`render-design-canvas.js --screen=contract`.

## RWB-20260816-007 — STORY-018 chat typing-ghost: zero rendered evidence either side

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-018_chat_typing_ghost_design_fidelity/`
Status: PENDING
Priority: MEDIUM

Exact remediation needed: capture `implemented-chat-<device>.png` from the
running app with the typing-ghost UI state actively triggered (not the
idle/default chat state — this story's AC scope is specifically the
typing-ghost indicator); render `design-reference-chat-<platform>.png` via
`render-design-canvas.js --screen=chat`.

## RWB-20260816-008 — STORY-022 anti-ghosting settings: zero rendered evidence either side

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-022_anti_ghosting_settings_design_fidelity/`
Status: PENDING
Priority: MEDIUM

Exact remediation needed: capture `implemented-antighost-<device>.png` from
the running app (`anti_ghost_screen.dart`); render
`design-reference-antighost-<platform>.png` via `render-design-canvas.js
--screen=antighost` (confirm exact screen id via `--list-screens`).

## RWB-20260816-009 — STORY-025 love timeline: zero rendered evidence either side

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-025_love_timeline_design_fidelity/`
Status: PENDING
Priority: MEDIUM

Round-2 review report already self-flags this: "no on-device, emulator or
rendered-PNG capture backs this review... consistent with the rest of the
REQ-002 wave." Reviewer also carried forward items D-1, M-4, M-5, M-11 noting
preview screenshots need a seeded `relationshipStartDate` to render
meaningfully.

Exact remediation needed: capture `implemented-timeline-<device>.png` from
the running app with a seeded `relationshipStartDate` (per the reviewer's
own M-11 note, otherwise the capture will not show representative content);
render `design-reference-timeline-<platform>.png` via
`render-design-canvas.js --screen=timeline`.

## RWB-20260816-010 — STORY-026 private gallery: galleryOpen state unrenderable

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-026_private_gallery_design_fidelity/`
Status: PENDING
Priority: HIGH

Current evidence: `implemented-gallery-emulator-5560.png` exists; no
`design-reference-gallery-*` exists. Report header is explicit:
`Design-Reference-Render: BLOCKED (DESIGN_CANVAS_STATE_FORCE_UNSUPPORTED)` —
`render-design-canvas.js` cannot force the `galleryOpen` UI state. The report
proposes an exact tooling fix and notes the only alternative is an explicit
Scrum Master exemption (none currently exists).

Exact remediation needed (one of):
1. Add a state-forcing flag (report proposes `--click=<css selector>`) to
   `render-design-canvas.js` (currently outside this story's write scope —
   route to whoever owns that tool, likely a DevOps/tooling story), then
   render `design-reference-gallery-<platform>.png` with `galleryOpen`
   forced.
2. Or: Scrum Master/PO records an explicit, durable exemption in
   `req_master.md` accepting the current evidence as sufficient for this
   specific state — no such exemption currently exists.

## RWB-20260816-011 — STORY-028 shared expenses: zero rendered evidence either side

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-028_shared_expenses_design_fidelity/`
Status: PENDING
Priority: MEDIUM

Report notes two visible design-source details remain unmet because they
live in shared components outside this story's scope — unrelated to the
evidence-pairing gap.

Exact remediation needed: capture `implemented-expense-<device>.png` from
the running app; render `design-reference-expense-<platform>.png` via
`render-design-canvas.js --screen=expense`.

## RWB-20260816-012 — STORY-002 pairing_choice: surface/CTA styling gap (D1, mobile lane)

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-002_onboarding_pairing_navigation/`
Status: PENDING
Priority: LOW

Surfaced by `STORY-034_pairing_choice_canvas_addition`'s reviewer
(`review/review-report.md`, finding D1) once a design-reference render for
`pairing_choice` existed for the first time. Content/structure MATCH; the
app build's surface/CTA styling does not apply the design system's tokens:

1. Background — reference: purple→magenta gradient with small particle
   accents; implemented: flat dark navy, no gradient, no particles.
2. Primary pill — reference: pink→purple gradient with glow
   (`var(--grad-hot)` + `var(--glow)`); implemented: flat solid pink, no
   gradient, no glow.
3. Type scale — implemented title and pill label render visibly larger, so
   the pill label wraps to two lines and the title wraps at a different word
   than the reference.
4. Title vertical offset sits lower in the implementation (~32% vs ~23%
   down).

Classification: pre-existing gap in STORY-002 (DONE/merged), not introduced
or worsened by STORY-034 — STORY-034 only made it visible by creating the
first-ever reference render for this screen. Out of STORY-034's own
`## Out of Scope` (no STORY-002 app code changes).

Exact remediation needed: route to the `mobile` lane to bring
`pairing_choice_screen.dart` (or equivalent) onto the design system's
gradient surface, gradient+glow CTA, and type scale, matching
`design-reference-pairingchoice-android.png`.
