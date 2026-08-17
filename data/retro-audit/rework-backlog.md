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
| RWB-20260816-002 | REQ-002 retro-audit/audit-report.md | DONE | HIGH | STORY-004_welcome_design_fidelity | Missing both sides of `welcome` evidence pair (already flagged as IF-7 in req_master.md); resolved by STORY-035_welcome_design_fidelity_hardening (DONE, Reviewer cycle 3 CLEAN); D1 gradient-axis defect fixed inline (user-approved scope widening) |
| RWB-20260816-003 | REQ-002 retro-audit/audit-report.md | RESOLVED | MEDIUM | STORY-006_register_design_fidelity | Missing both sides of `register` evidence pair; resolved by STORY-036_register_design_fidelity_hardening (DONE, Reviewer cycle 1 DEFERRED_ONLY) |
| RWB-20260816-004 | REQ-002 retro-audit/audit-report.md | RESOLVED | MEDIUM | STORY-011_invite_code_design_fidelity | Missing both sides of `invite` evidence pair; resolved by STORY-037_invite_design_fidelity_hardening (DONE, Reviewer cycle 2 DEFERRED_ONLY) |
| RWB-20260816-005 | REQ-002 retro-audit/audit-report.md | RESOLVED | MEDIUM | STORY-014_paired_success_design_fidelity | Missing both sides of `paired` evidence pair; resolved by STORY-038_paired_success_design_fidelity_hardening (DONE, Reviewer CLEAN) |
| RWB-20260816-006 | REQ-002 retro-audit/audit-report.md | RESOLVED | MEDIUM | STORY-015_love_contract_design_fidelity | Missing both sides of `contract` evidence pair; resolved by STORY-039_love_contract_design_fidelity_hardening (DONE, Reviewer DEFERRED_ONLY) |
| RWB-20260816-007 | REQ-002 retro-audit/audit-report.md | PENDING | MEDIUM | STORY-018_chat_typing_ghost_design_fidelity | Missing both sides of `chat` evidence pair (must capture the typing-ghost UI state specifically) |
| RWB-20260816-008 | REQ-002 retro-audit/audit-report.md | PENDING | MEDIUM | STORY-022_anti_ghosting_settings_design_fidelity | Missing both sides of `antighost` evidence pair |
| RWB-20260816-009 | REQ-002 retro-audit/audit-report.md | PENDING | MEDIUM | STORY-025_love_timeline_design_fidelity | Missing both sides of `timeline` evidence pair; reviewer's own round-2 report already flags this as unresolved |
| RWB-20260816-010 | REQ-002 retro-audit/audit-report.md | PENDING | HIGH | STORY-026_private_gallery_design_fidelity | `galleryOpen` state cannot be forced by `render-design-canvas.js`; needs a tooling fix or explicit exemption |
| RWB-20260816-011 | REQ-002 retro-audit/audit-report.md | PENDING | MEDIUM | STORY-028_shared_expenses_design_fidelity | Missing both sides of `expense` evidence pair |
| RWB-20260816-013 | REQ-002 STORY-037 review/review-report.md (DEF-1) | PENDING | LOW | STORY-011_invite_code_design_fidelity | 6 sibling screens (`otp_screen.dart:79`, `love_contract_screen.dart:109`, `onboarding_profile_setup_screen.dart:85`, `permissions_screen.dart:107`, `joincode_screen.dart:125`, `vow_screen.dart:169`) carry the same opaque `backgroundColor: colors.colorBackground` Scaffold override that occludes the shared `--sky` app-shell backdrop; STORY-032's remediation was never swept to these call sites; route to mobile lane |
| RWB-20260816-014 | REQ-002 STORY-039 review/review-report.md (V-1) | PENDING | LOW | STORY-015_love_contract_design_fidelity | `contract` D-7/D-8/D-10/D-13 re-confirmed by test/structure only, no in-scope render path (`main_preview.dart` lacks a requester-unsigned fixture); add fixture, route to mobile lane |
| RWB-20260816-015 | REQ-002 STORY-039 review/review-report.md (V-2) | PENDING | LOW | STORY-015_love_contract_design_fidelity | `contract` clause-counter row is an unclassified app-vs-design delta misfiled under F-5; route with F-1/F-2/F-3 token-policy question to Product Owner/Tech Lead |

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
Status: DONE
Priority: HIGH

**Resolution (2026-08-17):** delivered via
`STORY-035_welcome_design_fidelity_hardening` (Status: DONE). Routed through
the full Product Owner -> UX Designer -> Tech Lead -> implementation lanes ->
Reviewer pipeline per the RED-PATCH plan, across three review cycles:

- Cycle 1: `PATCH_REQUIRED` (F1 missing twinkle particles, F2 missing
  runtime-smoke evidence).
- Cycle 2: `DEFERRED_ONLY` — F1/F2 both resolved and independently
  re-verified; D1 (backdrop gradient axis, 6.86 deg rendered vs 14.98 deg
  design) correctly deferred as outside the P0 Write Scope.
- User decision (2026-08-16): rather than route D1 to a separate follow-up
  item, widen STORY-035's Write Scope and fix it inline, in this story, now.
- Phase P1 (Tech Lead architecture extension + mobile-dev implementation):
  new `CupidCssAngleGradient extends LinearGradient` overriding
  `createShader`, fixing the CSS-angle/Flutter-Alignment mismatch at its
  root (`mobile/lib/design_system/tokens/cupid_color_tokens.dart`), covering
  both `gradientBrandBackdrop` (welcome, rendered re-verification) and
  `gradientHot` (~20 consumers, verified via an exhaustive box-shape-matrix
  axis/extent test per Tech Lead's accepted sizing decision). Zero consumer
  widget files touched.
- Cycle 3: `Outcome: CLEAN` (0 blocking, 0 deferred). Reviewer independently
  re-measured the fixed gradient axis with a different method from
  mobile-dev's own (least-squares plane fit vs. sub-pixel iso-colour-line
  analyzer): 14.99-15.01 deg vs the design's 15.00 deg. All AC1-5 PASS.
  `visual-fidelity/visual-fidelity-report.md` records `VISUAL_FIDELITY: PASS`.

Evidence: matched `implemented-welcome-emulator-5560.png` /
`design-reference-welcome-android.png` pair now lives in
`STORY-035_welcome_design_fidelity_hardening/visual-fidelity/`, produced by
the rendered-output-to-rendered-output method (not the literal
CSS/HTML-prototype-vs-widget-tree method that caused the original IF-7 gap
and `BUG-20260816-001`). No separate D1 follow-up item was needed — it was
fixed, not deferred. Full detail:
`STORY-035_welcome_design_fidelity_hardening/review/review-report.md`.

## RWB-20260816-003 — STORY-006 register: zero rendered evidence either side

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-006_register_design_fidelity/`
Status: RESOLVED
Priority: MEDIUM

**Resolution (2026-08-17):** delivered via
`STORY-036_register_design_fidelity_hardening` (Status: DONE). Routed
through Product Owner (trivial/mobile-single-lane scoping; UX Designer and
Tech Lead phases marked `SKIPPED:trivial` per single-lane trivial routing) ->
mobile-dev implementation -> Reviewer (`compact-story-review`) per the
RED-PATCH plan:

- Mobile-dev captured `implemented-register-emulator-5560.png` and rendered
  `design-reference-register-android.png` (dark theme + `vi` locale, per
  STORY-006's own configuration), placed in STORY-036's own
  `visual-fidelity/` directory alongside `visual-fidelity-report.md`
  recording `VISUAL_FIDELITY: PASS`.
- The rendered-to-rendered comparison surfaced a real deviation (AC2): each
  field card rendered 4.3dp taller than the design due to Flutter's default
  `bodyLarge` line-box (24dp) vs. the design's ~19.9dp. Fixed in code via
  `_fieldInputLineHeight = 1.25` + a forced `StrutStyle` on the register
  `TextField`, with a new regression test guarding the fix. Re-verified with
  a fresh render pair (card 68.04 vs 67.84 dp, input baseline identical at
  48.9 dp).
- Reviewer (Iris-QC-2) cycle 1: `Outcome: DEFERRED_ONLY`. AC1-5 all PASS with
  independently re-derived evidence (root cause re-derived from Material 3
  line-box math; both PNGs opened directly; design-source HTML cross-checked;
  all 3 test commands rerun independently, catching a minor evidence-table
  undercount in the process). Governed header-chrome deviation (register is
  outside the design canvas's `NO_CHROME` list but the app correctly omits
  the header per STORY-002's approved UX spec) independently verified, not
  accepted on trust. 0 blocking findings; 3 deferred, non-blocking: DEF-1
  (fix rationale cites an imprecise design-source line for the line-height
  value — the value itself is correct, empirically re-derived), DEF-2
  (residual ~2.8dp password-card gap, same root-cause class, left for a
  future pass), DEF-3 (verification table undercounted the auth test suite
  pass count by 1, immaterial to the verdict).

Note resolved: STORY-006's own `story_master.md` status/Review-checkbox
discrepancy was left as documented (not altered) in STORY-036's
`## Background` section — it does not block this RWB item's closure, since
the remediation vehicle is STORY-036, not a reopen of STORY-006 itself.

Evidence: `STORY-036_register_design_fidelity_hardening/visual-fidelity/`
(evidence pair + report); full detail:
`STORY-036_register_design_fidelity_hardening/review/review-report.md`.

## RWB-20260816-004 — STORY-011 invite: zero rendered evidence either side

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-011_invite_code_design_fidelity/`
Status: RESOLVED
Priority: MEDIUM

**Resolution (2026-08-17):** delivered via
`STORY-037_invite_design_fidelity_hardening` (Status: DONE). Routed through
Product Owner (trivial/mobile-single-lane scoping; UX Designer and Tech Lead
phases marked `SKIPPED:trivial`) -> mobile-dev implementation -> Reviewer
(`compact-story-review`) per the RED-PATCH plan, across two review cycles:

- Mobile-dev captured `implemented-invite-emulator-5560.png` and rendered
  `design-reference-invite-android.png` (dark theme + `vi` locale), placed in
  STORY-037's own `visual-fidelity/` directory. Rendered comparison surfaced
  and fixed a real AC2 deviation (D1): share CTA Vietnamese label
  `Chia sẻ mã mời` corrected to the design source's `Gửi link mời`.
- Reviewer (Iris-QC-3) cycle 1: `Outcome: PATCH_REQUIRED`. 1 blocking (B1,
  HIGH): an opaque `backgroundColor: colors.colorBackground` Scaffold
  override at `invite_screen.dart` occluded the shared app-shell `--sky`
  gradient backdrop + star layer; the report's measured table never probed
  that region, so `VISUAL_FIDELITY: PASS` was reached without examining it.
  AC1/AC2/AC4 FAIL. 2 deferred (DEF-1: 6 sibling screens with the same
  override, out of single-screen scope; DEF-2: a governed-deviation CTA
  label mislabelled in the report).
- Mobile-dev rework: removed the override (+ unused `colors` local) per the
  `forgot_screen.dart:103-106` STORY-032 precedent; re-captured the
  implementation PNG; added 4 screen-backdrop probe rows to the measured
  table; fixed DEF-2.
- Reviewer cycle 2: `Outcome: DEFERRED_ONLY`. AC1-5 all PASS, independently
  re-derived (7 self-chosen backdrop probes against an analytic `--sky`
  composite model, 5 exact + 2 within 1 unit; `flutter analyze`/`flutter
  test` re-run independently). 0 blocking. DEF-1 remains, split out as
  RWB-20260816-013 (mobile lane, LOW, PENDING).

Note resolved: STORY-011's own `story_master.md` status/Review-checkbox
discrepancy was left as documented (not altered) in STORY-037's
`## Background` section — same disposition as the STORY-006/STORY-036
precedent; does not block this RWB item's closure since the remediation
vehicle is STORY-037, not a reopen of STORY-011 itself.

Evidence: `STORY-037_invite_design_fidelity_hardening/visual-fidelity/`
(evidence pair + report); full detail:
`STORY-037_invite_design_fidelity_hardening/review/review-report.md`.

## RWB-20260816-005 — STORY-014 paired/paired-success: zero rendered evidence either side

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-014_paired_success_design_fidelity/`
Status: RESOLVED
Priority: MEDIUM

**Resolution (2026-08-17):** delivered via
`STORY-038_paired_success_design_fidelity_hardening` (Status: DONE). Routed
through Product Owner (trivial/mobile-single-lane scoping; UX Designer and
Tech Lead phases marked `SKIPPED:trivial`) -> mobile-dev implementation ->
Reviewer (`compact-story-review`) per the RED-PATCH plan, single cycle:

- Mobile-dev captured `implemented-paired-emulator-5560.png` and rendered
  `design-reference-paired-android.png` (dark theme + `vi` locale), placed in
  STORY-038's own `visual-fidelity/` directory. Re-verified all 15 of
  STORY-014's originally-claimed deviations (D1-D15) against the actual
  rendered app rather than STORY-014's prose, and found + fixed a real
  regression (D3): the couple-presence avatar cluster rendered 6dp too small
  because Flutter's inward `Border.all` stroke was not accounted for against
  the design's content-box CSS sizing (avatar box 76->82px, second-avatar
  offset 54->60, re-captured after the fix). D1/D2/D4-D14 re-confirmed
  matching; D15 (avatar initials) re-confirmed still correctly excluded per
  its documented business-logic boundary.
- Reviewer (Iris-QC-4): `Outcome: CLEAN`. All 6 ACs PASS, no deferred
  findings. Independently re-derived the D3 root cause from the design
  source's `<style>` block (confirmed no global `box-sizing:border-box`
  rule), re-sampled the D1 backdrop wash and two hard-anchor scale
  calibration points, verified the AC4 animation timing line-by-line against
  the keyframes, and re-ran `flutter analyze`/`flutter test` independently
  (reproduced the `+159` pass count). Two non-blocking observations recorded
  (evidence-dir tracking, a Story-Class metadata note) — both resolved by
  this story's completion commit.

Note resolved: STORY-014's own `story_master.md` status/Review-checkbox
discrepancy was left as documented (not altered) in STORY-038's
`## Background` section — same disposition as the
STORY-006/STORY-011/STORY-036/STORY-037 precedent; does not block this RWB
item's closure since the remediation vehicle is STORY-038, not a reopen of
STORY-014 itself.

Evidence: `STORY-038_paired_success_design_fidelity_hardening/visual-fidelity/`
(evidence pair + report); full detail:
`STORY-038_paired_success_design_fidelity_hardening/review/review-report.md`.

## RWB-20260816-006 — STORY-015 love contract: zero rendered evidence either side

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-015_love_contract_design_fidelity/`
Status: RESOLVED
Priority: MEDIUM

Report used a "Token Mapping Policy" (code/token comparison only).

Resolved via `STORY-039_love_contract_design_fidelity_hardening` (Status:
DONE, Reviewer Iris-QC-5 `Outcome: DEFERRED_ONLY`, AC1-7 all PASS). Rendered
comparison performed for the first time; D-1..D-13 re-confirmed (9 of 13
directly rendered, 4 by widget test/structure — capture-state limitation, see
RWB-20260816-014); DEF-1 (clause checkbox) and DEF-2 (hold-to-sign button)
fixed in `clause_toggle_row.dart`/`hold_to_sign_button.dart` and re-verified
in the render; DEF-2a (dim overlay zero-height regression) found by the
render and fixed; DEF-3/F-1/F-2/F-3/F-5 re-confirmed out of scope. Two real
deltas deferred rather than silently dropped: incomplete AC2 render coverage
split to RWB-20260816-014, and an unclassified clause-counter row delta split
to RWB-20260816-015. See `STORY-039.../review/review-report.md`.

## RWB-20260816-014 — `contract` D-7/D-8/D-10/D-13 have no in-scope render path (V-1, mobile lane)

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-015_love_contract_design_fidelity/`
(tracking anchor; remediation is a preview-fixture/tooling gap on the
`contract` screen)
Status: PENDING
Priority: LOW

Surfaced by `STORY-039_love_contract_design_fidelity_hardening`'s reviewer
(`review/review-report.md`, finding V-1) while re-verifying STORY-015's
D-1..D-13. D-7 and D-8 (add-clause row) and D-10/D-13 (signed card /
sign-action error banner) were re-confirmed by widget test / widget-tree
structure only, not by the rendered pair: `main_preview.dart:328-354` exposes
only `partnerAlreadySigned` and `bothSigned` contract fixtures, so a
requester-unsigned capture (needed to paint the add-clause row) is
unavailable without editing `main_preview.dart`, which was outside
STORY-039's write scope; D-10/D-13 additionally have no design-side reference
at all (the canvas only paints its `myUnsigned` branch). No D-item is
unverified or regressed — this is a coverage gap, not an open defect.

Exact remediation needed: add a requester-unsigned preview fixture to
`main_preview.dart` so the add-clause row can be render-compared, and confirm
whether the design canvas can render signed/error branches at all before
requiring a rendered comparison of a state the design source does not paint.

## RWB-20260816-015 — `contract` clause-counter row is an unclassified app-vs-design delta (V-2, mobile lane)

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-015_love_contract_design_fidelity/`
(tracking anchor; overlaps the F-1/F-2/F-3 token-vs-source policy question)
Status: PENDING
Priority: LOW

Surfaced by `STORY-039_love_contract_design_fidelity_hardening`'s reviewer
(`review/review-report.md`, finding V-2). The app renders a
`2/20 điều khoản` clause-counter row that the design canvas does not have,
pushing the clause list ~26 image px lower than the reference.
`visual-fidelity-report.md` filed it under "the F-5 copy family", but
STORY-039's own `## Out of Scope` scopes F-5 specifically to the add-clause
copy diff — so this delta is currently unclassified, not excluded, and
AC1's exclusion list is F-1/F-2/F-3 only. Not blocking (Core Rule 7): the
counter is a pre-existing REQ-001 product affordance backing the 20-clause
cap, not introduced by STORY-015 or STORY-039, and removing it is a
product-copy decision outside a fidelity-hardening story's authority.

Exact remediation needed: Product Owner / Tech Lead to give this an explicit
disposition (keep-and-exclude vs. reposition vs. remove) alongside the
F-1/F-2/F-3 requirement-level token-vs-source policy question, rather than
leaving it filed under F-5.

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

## RWB-20260816-013 — 6 sibling screens occlude the shared `--sky` backdrop (DEF-1, mobile lane)

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-011_invite_code_design_fidelity/`
(tracking anchor; the affected screens span multiple stories/features)
Status: PENDING
Priority: LOW

Surfaced by `STORY-037_invite_design_fidelity_hardening`'s reviewer
(`review/review-report.md` cycle 2, finding DEF-1) while verifying B1's fix
on the `invite` screen. Root cause: REQ-002 STORY-032 AC1 removed an opaque
`backgroundColor: colors.colorBackground` Scaffold override from
`forgot_screen.dart` so the shared `CupidAppBackground` `--sky` gradient
wash (mounted once at `cupid_app.dart:59`) is not occluded — but that fix
was never swept to its remaining call sites. The same opaque override still
exists on 6 other screens, each of which will occlude the same shared
backdrop layer on its own screen:

1. `mobile/lib/features/pairing/presentation/screens/otp_screen.dart:79`
2. `mobile/lib/features/pairing/presentation/screens/love_contract_screen.dart:109`
3. `mobile/lib/features/pairing/presentation/screens/onboarding_profile_setup_screen.dart:85`
4. `mobile/lib/features/pairing/presentation/screens/permissions_screen.dart:107`
5. `mobile/lib/features/pairing/presentation/screens/joincode_screen.dart:125`
6. `mobile/lib/features/pairing/presentation/screens/vow_screen.dart:169`

Classification: pre-existing gap, not introduced or worsened by STORY-037 —
STORY-037 only made it visible by adding the first-ever screen-backdrop
probe to a REQ-002 evidence report. Out of STORY-037's own single-screen
scope.

Exact remediation needed: route to the `mobile` lane to remove the
`backgroundColor:` override on each of the 6 screens above, following the
`forgot_screen.dart:103-106` precedent comment, then verify with a rendered
evidence pair (or at minimum a screen-backdrop probe) per screen that the
shared `--sky` wash is no longer occluded.
