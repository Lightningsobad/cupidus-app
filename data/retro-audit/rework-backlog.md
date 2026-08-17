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
| RWB-20260816-007 | REQ-002 retro-audit/audit-report.md | RESOLVED | MEDIUM | STORY-018_chat_typing_ghost_design_fidelity | Missing both sides of `chat` evidence pair; resolved by STORY-040_chat_typing_ghost_design_fidelity_hardening (DONE, Reviewer DEFERRED_ONLY). D2 (iOS toggle clamp) fixed inline as AC4; N1 (render-only crash) found+fixed. D1 split to RWB-016, R-1 (undisclosed header delta) split to RWB-017, N2 (FAB occludes send button) filed as BUG-20260817-001 |
| RWB-20260816-008 | REQ-002 retro-audit/audit-report.md | RESOLVED | MEDIUM | STORY-022_anti_ghosting_settings_design_fidelity | Missing both sides of `antighost` evidence pair; resolved by STORY-041_anti_ghosting_settings_design_fidelity_hardening (DONE, Reviewer DEFERRED_ONLY). D-05 split to RWB-018; RV-1 (undisclosed sound-penalty row label delta) split to RWB-019 |
| RWB-20260816-009 | REQ-002 retro-audit/audit-report.md | IN_PROGRESS | MEDIUM | STORY-025_love_timeline_design_fidelity | Missing both sides of `timeline` evidence pair; STORY-042 implementation complete (2/20 deviations fixed, AC1-7 done), `VISUAL_FIDELITY: PASS`; awaiting Reviewer |
| RWB-20260816-010 | REQ-002 retro-audit/audit-report.md | PENDING | HIGH | STORY-026_private_gallery_design_fidelity | `galleryOpen` state cannot be forced by `render-design-canvas.js`; needs a tooling fix or explicit exemption |
| RWB-20260816-011 | REQ-002 retro-audit/audit-report.md | PENDING | MEDIUM | STORY-028_shared_expenses_design_fidelity | Missing both sides of `expense` evidence pair |
| RWB-20260816-013 | REQ-002 STORY-037 review/review-report.md (DEF-1) | PENDING | LOW | STORY-011_invite_code_design_fidelity | 6 sibling screens (`otp_screen.dart:79`, `love_contract_screen.dart:109`, `onboarding_profile_setup_screen.dart:85`, `permissions_screen.dart:107`, `joincode_screen.dart:125`, `vow_screen.dart:169`) carry the same opaque `backgroundColor: colors.colorBackground` Scaffold override that occludes the shared `--sky` app-shell backdrop; STORY-032's remediation was never swept to these call sites; route to mobile lane |
| RWB-20260816-014 | REQ-002 STORY-039 review/review-report.md (V-1) | PENDING | LOW | STORY-015_love_contract_design_fidelity | `contract` D-7/D-8/D-10/D-13 re-confirmed by test/structure only, no in-scope render path (`main_preview.dart` lacks a requester-unsigned fixture); add fixture, route to mobile lane |
| RWB-20260816-015 | REQ-002 STORY-039 review/review-report.md (V-2) | PENDING | LOW | STORY-015_love_contract_design_fidelity | `contract` clause-counter row is an unclassified app-vs-design delta misfiled under F-5; route with F-1/F-2/F-3 token-policy question to Product Owner/Tech Lead |
| RWB-20260816-016 | REQ-002 STORY-040 story_master.md (D1) | PENDING | LOW | STORY-018_chat_typing_ghost_design_fidelity | `chat` missing `colorOnAccent`/inverse-text design token; real in light theme (OQ5), imperceptible in audited dark theme; `design_system/` change outside chat-screen story WriteScope |
| RWB-20260816-017 | REQ-002 STORY-040 review/review-report.md (R-1) | PENDING | LOW | STORY-018_chat_typing_ghost_design_fidelity | `chat` header renders `Linh` alone with no `đang online` presence chip, vs. design's `Minh ↔ Linh` + presence chip; pre-existing `CupidHeader` title-only limitation, undisclosed in STORY-040's report; `design_system/adaptive/` change outside chat-screen story WriteScope |
| RWB-20260816-018 | REQ-002 STORY-041 story_master.md (D-05) | PENDING | LOW | STORY-022_anti_ghosting_settings_design_fidelity | `antighost` penalty card omits design source's first row `Đếm ngược công khai` / "Public countdown" (amber tile); needs a new persisted setting, backend field, and l10n keys — same blocker class as D-01; split out of STORY-041's Product Owner scoping rather than folded into the hardening story |
| RWB-20260816-019 | REQ-002 STORY-041 review/review-report.md (RV-1) | PENDING | LOW | STORY-022_anti_ghosting_settings_design_fidelity | `antighost` sound-penalty row label reads `Gây ồn` in the app vs. design's `Phát âm thanh` — same glyph/position, different words; undisclosed in STORY-022's or STORY-041's own reports, reviewer-found; string lives in `mobile/lib/l10n/arb/`, same l10n-blocker class as D-01/D-02/D-03; split out rather than patched in-story |
| RWB-20260816-020 | REQ-002 STORY-042 visual-fidelity-report.md (Tool limitation) | PENDING | LOW | STORY-042_love_timeline_design_fidelity_hardening | `render-design-canvas.js` has no `--scroll` flag and its `--hide` selectors don't survive the screen-click re-render, so below-the-fold design content is uncapturable by the sanctioned tool; anchor devops |

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

## RWB-20260816-016 — `chat` missing `colorOnAccent` / inverse-text design token (D1, mobile lane)

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-018_chat_typing_ghost_design_fidelity/`
(tracking anchor; a `design_system/` token gap, not a chat-screen-local fix)
Status: PENDING
Priority: LOW

Split out of `STORY-040_chat_typing_ghost_design_fidelity_hardening`'s
Product Owner scoping (finding D1, carried forward from STORY-018's own
`review/review-report.md`). The design source sets `color:#fff` on the
own-message bubble text and send glyph; `message_bubble.dart:99` and
`chat_composer.dart:310` use `colors.colorText` instead, because
`CupidColorTokens` carries no on-accent / inverse-text token and ADR-004
forbids raw colour literals under `lib/features/**`. In the audited dark
theme `colorText` is `#F7EEFB` — imperceptible against the pink→purple
gradient, so this story's own AC1 holds. The gap is real in light theme,
where `colorText` is `#3E2645` on the same gradient — a genuine contrast
regression there. Not blocking for STORY-040: light theme is OQ5 and
explicitly out of scope for this hardening pass, and adding the token is a
`design_system/` change outside a chat-screen story's natural `WriteScope`.

Exact remediation needed: UI/UX Designer + design-system owner to add a
`colorOnAccent` (or equivalently named inverse-text) token to
`CupidColorTokens`, then update `message_bubble.dart:99` and
`chat_composer.dart:310` to consume it, scoped together with whichever
future story delivers light-theme / `en` locale (OQ5) user-facing support.

## RWB-20260816-007 — STORY-018 chat typing-ghost: zero rendered evidence either side

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-018_chat_typing_ghost_design_fidelity/`
Status: RESOLVED
Priority: MEDIUM

Resolved via `STORY-040_chat_typing_ghost_design_fidelity_hardening` (Status:
DONE, Reviewer Iris-QC-6 `Outcome: DEFERRED_ONLY`, AC1-8 all PASS). Rendered
comparison performed for the first time with the Typing Ghost UI state
actively triggered via a `PREVIEW_CHAT_GHOST=on` capture fixture; all 25 of
STORY-018's original deviations re-confirmed against the render. Two real
defects found by rendering that code reading had missed: D2 (ghost-toggle
44pt iOS clamp) fixed inline as AC4 with a platform-parameterized regression
test; N1 (frame-boundary null-check crash on the empty-state -> first-message
transition) found and fixed, deliberately left without a synthetic test
(flutter_test's synchronous `drawFrame` cannot reproduce the attach-before-
layout race). V-1 (48pt vs 46pt input pill) re-verified and deliberately
retained per `ux/uiux-spec.md` §5 Material tap-target precedent. Three real
deltas deferred rather than silently dropped: D1 (missing `colorOnAccent`
token) split to RWB-20260816-016, R-1 (undisclosed header presence-chip
delta, reviewer-found) split to RWB-20260816-017, and N2 (shell FAB fully
occludes the chat send button — a functional production defect, not a
design-fidelity nit) filed as `BUG-20260817-001_chat_fab_occludes_send_button`
in the bug queue rather than this registry. See
`STORY-040.../visual-fidelity/visual-fidelity-report.md` and
`STORY-040.../review/review-report.md`.

## RWB-20260816-017 — `chat` header missing partner-name pairing + presence chip (R-1, mobile lane)

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-018_chat_typing_ghost_design_fidelity/`
(tracking anchor; a `design_system/adaptive/` shared-component gap, not a
chat-screen-local fix)
Status: PENDING
Priority: LOW

Surfaced by `STORY-040_chat_typing_ghost_design_fidelity_hardening`'s reviewer
(`review/review-report.md`, finding R-1) while re-verifying STORY-040's own
evidence pair. The design reference renders `Minh ↔ Linh` plus a `đang
online` presence chip at top-right; the implemented capture renders `Linh`
alone with no presence chip. Root cause is pre-existing and documented in code
at `chat_screen.dart:164-169` — `CupidHeader` exposes a title string only,
with no avatar/presence slot, reused as-is rather than reopening a frozen
shared component. Not a STORY-040 regression and not blocking: the delta
pre-dates this hardening pass and correcting it means touching
`design_system/adaptive/`, outside a chat-screen story's natural WriteScope
either way. The defect flagged by the reviewer was disclosure only — the
hardening report's out-of-scope enumeration omitted this delta.

Exact remediation needed: UI/UX Designer + design-system owner to give
`CupidHeader` an optional avatar/presence slot (or an equivalent adaptive
variant), then update `chat_screen.dart`'s header composition to pass the
partner pairing (`Minh ↔ Linh`) and online-presence state, scoped as its own
story rather than folded into a future chat hardening pass.

## RWB-20260816-008 — STORY-022 anti-ghosting settings: zero rendered evidence either side

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-022_anti_ghosting_settings_design_fidelity/`
Status: RESOLVED
Priority: MEDIUM

Resolved via `STORY-041_anti_ghosting_settings_design_fidelity_hardening`
(Status: DONE, Reviewer Iris-QC-6 `Outcome: DEFERRED_ONLY`, AC1-7 all PASS,
AC1/AC5 PASS-with-deferral). Rendered comparison performed for the first
time via a `PREVIEW_ANTIGHOST=state-a|state-b` capture fixture in
`mobile/lib/main_preview.dart` (production `anti_ghost_screen.dart`
untouched); F-01..F-10 all re-confirmed against the render, including the
two emphasis targets F-03 (segmented threshold control) and F-06 (penalty
icon tiles). R-2 (narrow-width truncation) checked and resolved as no
defect — all 4 segment labels render complete at 360dp. D-01/D-02/D-03/R-1/
R-3 re-confirmed out of scope (l10n-blocked / OQ5-blocked / note-only). Two
real deltas split out rather than folded in: D-05 (undisclosed "Public
countdown" penalty row, needs new setting+backend+l10n) to
RWB-20260816-018, and RV-1 (undisclosed sound-penalty row label delta,
reviewer-found) to RWB-20260816-019. See
`STORY-041.../visual-fidelity/visual-fidelity-report.md` and
`STORY-041.../review/review-report.md`.

## RWB-20260816-018 — `antighost` penalty card missing undisclosed "Public countdown" row (D-05, backend+l10n)

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-022_anti_ghosting_settings_design_fidelity/`
(tracking anchor; needs new persisted setting/backend field/l10n keys, not a
screen-local rendering fix)
Status: PENDING
Priority: LOW

Split out of `STORY-041_anti_ghosting_settings_design_fidelity_hardening`'s
Product Owner scoping (finding D-05, carried forward from STORY-022's own
`review/review-report.md`). The design source's penalty card has three rows
(design source lines 555-571); the app implements only two (Emoji Storm,
sound) and omits the first row entirely: `Đếm ngược công khai` / "Public
countdown", an amber tile (`rgba(255,201,126,.2)`, `var(--amber)` `timer`
glyph). Reviewer confirmed this needs a new persisted setting plus a backend
field and new l10n keys — the same blocker class as D-01. Not folded into
STORY-041: it is excluded by that story's own Out of Scope ("any new
feature, new screen state, or new interaction") and is not a pure rendering
fix a screen-scoped hardening story can absorb.

Exact remediation needed: Product Owner/Tech Lead to scope a new persisted
anti-ghosting setting ("public countdown") plus its backend field, then
Backend Developer adds the field/API support, UI/UX Designer confirms the
amber-tile row spec, Mobile Developer adds the row to
`anti_ghost_screen.dart` with new l10n keys under `mobile/lib/l10n/arb/`,
scoped as its own story rather than folded into a future anti-ghosting
hardening pass.

## RWB-20260816-019 — `antighost` sound-penalty row label mismatch (RV-1, l10n)

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-022_anti_ghosting_settings_design_fidelity/`
(tracking anchor; needs an l10n string change under `mobile/lib/l10n/arb/`,
same blocker class as D-01/D-02/D-03)
Status: PENDING
Priority: LOW

Found by Iris-QC-6 while independently re-reading the STORY-041 hardening
capture pixel-by-pixel (`review/review-report.md`, finding RV-1), not
disclosed by either STORY-022's or STORY-041's own reports. The design
source's third penalty row reads `Phát âm thanh`; the app's corresponding
row reads `Gây ồn` — same glyph, same position, different words. Disposition
is defer, not patch: the string lives in `mobile/lib/l10n/arb/`, outside
STORY-041's WriteScope and its own AC4 sibling constraint (do not touch
D-05/backend/l10n scope). Pre-existing, not made worse by STORY-041.

Exact remediation needed: scope alongside D-01/D-02/D-03 and RWB-016 in a
future l10n-scoped story — correct the `Gây ồn` string (or confirm intended
wording with Product Owner) under `mobile/lib/l10n/arb/`, then re-verify the
`antighost` render.

## RWB-20260816-009 — STORY-025 love timeline: zero rendered evidence either side

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-025_love_timeline_design_fidelity/`
Status: IN_PROGRESS
Priority: MEDIUM

Hardening story: `STORY-042_love_timeline_design_fidelity_hardening`
(Status: RETRO_PENDING) opened 2026-08-17, user-selected. Product Owner
scoped 7 ACs (M-11 folded into AC1 fixture-setup; D-1/M-4/M-5/M-8-12
confirmed out of scope; M-2/M-3/conic-ring-seam folded into AC4). Mobile-dev
implementation complete: `visual-fidelity-report.md` records
`VISUAL_FIDELITY: PASS`; 18/20 of STORY-025's deviations matched as-is, 2
(#8 connector-dot fill, #19 dashed-border rhythm/straddle) did not survive
a real render and were fixed. AC4 conic-ring seam PASS no fix needed (M-2
discharged); dashed-border FAIL as delivered, fixed (M-3 discharged).
Residual R-1 (entry card +5dp from Nunito line-height metrics) folds into
the existing M-4 shared-typography carry-forward for requirement
integration review, not a new item. A `render-design-canvas.js` tooling gap
(no `--scroll` flag; `--hide` selectors don't survive the screen-click
re-render, so below-the-fold content is uncapturable by the sanctioned
tool) is split to `RWB-20260816-020`. Next: dispatch Reviewer
(`compact-story-review`).

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

## RWB-20260816-020 — `render-design-canvas.js` cannot capture below-the-fold content (tooling)

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-042_love_timeline_design_fidelity_hardening/`
Status: PENDING
Priority: LOW

Found during STORY-042's own AC4 evidence capture (not blocking — a
throwaway diagnostic Playwright script was used as a workaround, see
`STORY-042.../visual-fidelity/visual-fidelity-report.md` "Tool limitation"
section). `render-design-canvas.js` has no scroll flag, and its `--hide`
selectors are applied before the `[data-screen-btn]` click, so they do not
survive the screen re-render. Any screen whose fidelity-critical content is
below the fold (e.g. `timeline`'s last entry row and its "Thêm kỷ niệm"
dashed button) cannot be captured by the sanctioned tool.

Exact remediation needed: add a `--scroll <px>` (or `--scroll-to-end`) flag
to `render-design-canvas.js` that scrolls the screen's overflowing body
element after the `[data-screen-btn]` click and before the screenshot, and
re-apply `--hide` selectors after that click rather than before it. Anchor:
devops (`render-design-canvas.js` tooling), no specific story blocked today.

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
