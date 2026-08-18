# Retro Rework Backlog

Registry of remediation items surfaced by retro-review audits. `scrum-master`
checks this file before ordinary `continue`; any `PENDING` or `IN_PROGRESS`
item blocks plain ordinary backlog continuation until the user runs
`continue retro` (or explicitly bypasses with `continue normal` /
`continue ordinary` / `continue backlog` / `continue ignoring retro`).

| Item ID | Source Audit | Status | Priority | Story | Summary |
|---|---|---|---|---|---|
| RWB-20260816-001 | REQ-002 retro-audit/audit-report.md | RESOLVED | HIGH | STORY-002_onboarding_pairing_navigation | `pairing_choice` screen has no design-canvas counterpart; user decision 2026-08-16 routed ui-ux-designer to add the canvas node + resolve F-B; delivered as STORY-034_pairing_choice_canvas_addition (DONE, Reviewer DEFERRED_ONLY) |
| RWB-20260816-012 | REQ-002 STORY-034 review/review-report.md (D1) | RESOLVED | LOW | STORY-002_onboarding_pairing_navigation | `pairing_choice` app build does not apply the design system's surface/CTA styling; resolved by STORY-045_pairing_choice_design_fidelity_hardening (DONE, Reviewer DEFERRED_ONLY). Root cause: 2 of the 4 reported deviations (background gradient/particles, CTA gradient/glow) were already closed pre-story, artifacts of a stale/mis-scaled STORY-002-era capture; only type scale and title vertical offset needed a real fix (1 file, +13/-3). A new regression from the fix (DF1, short-viewport/landscape overflow) split to RWB-022 |
| RWB-20260816-002 | REQ-002 retro-audit/audit-report.md | DONE | HIGH | STORY-004_welcome_design_fidelity | Missing both sides of `welcome` evidence pair (already flagged as IF-7 in req_master.md); resolved by STORY-035_welcome_design_fidelity_hardening (DONE, Reviewer cycle 3 CLEAN); D1 gradient-axis defect fixed inline (user-approved scope widening) |
| RWB-20260816-003 | REQ-002 retro-audit/audit-report.md | RESOLVED | MEDIUM | STORY-006_register_design_fidelity | Missing both sides of `register` evidence pair; resolved by STORY-036_register_design_fidelity_hardening (DONE, Reviewer cycle 1 DEFERRED_ONLY) |
| RWB-20260816-004 | REQ-002 retro-audit/audit-report.md | RESOLVED | MEDIUM | STORY-011_invite_code_design_fidelity | Missing both sides of `invite` evidence pair; resolved by STORY-037_invite_design_fidelity_hardening (DONE, Reviewer cycle 2 DEFERRED_ONLY) |
| RWB-20260816-005 | REQ-002 retro-audit/audit-report.md | RESOLVED | MEDIUM | STORY-014_paired_success_design_fidelity | Missing both sides of `paired` evidence pair; resolved by STORY-038_paired_success_design_fidelity_hardening (DONE, Reviewer CLEAN) |
| RWB-20260816-006 | REQ-002 retro-audit/audit-report.md | RESOLVED | MEDIUM | STORY-015_love_contract_design_fidelity | Missing both sides of `contract` evidence pair; resolved by STORY-039_love_contract_design_fidelity_hardening (DONE, Reviewer DEFERRED_ONLY) |
| RWB-20260816-007 | REQ-002 retro-audit/audit-report.md | RESOLVED | MEDIUM | STORY-018_chat_typing_ghost_design_fidelity | Missing both sides of `chat` evidence pair; resolved by STORY-040_chat_typing_ghost_design_fidelity_hardening (DONE, Reviewer DEFERRED_ONLY). D2 (iOS toggle clamp) fixed inline as AC4; N1 (render-only crash) found+fixed. D1 split to RWB-016, R-1 (undisclosed header delta) split to RWB-017, N2 (FAB occludes send button) filed as BUG-20260817-001 |
| RWB-20260816-008 | REQ-002 retro-audit/audit-report.md | RESOLVED | MEDIUM | STORY-022_anti_ghosting_settings_design_fidelity | Missing both sides of `antighost` evidence pair; resolved by STORY-041_anti_ghosting_settings_design_fidelity_hardening (DONE, Reviewer DEFERRED_ONLY). D-05 split to RWB-018; RV-1 (undisclosed sound-penalty row label delta) split to RWB-019 |
| RWB-20260816-009 | REQ-002 retro-audit/audit-report.md | RESOLVED | MEDIUM | STORY-025_love_timeline_design_fidelity | Missing both sides of `timeline` evidence pair; resolved by STORY-042_love_timeline_design_fidelity_hardening (DONE, Reviewer CLEAN). R-1 folded into M-4 carry-forward; tooling gap split to RWB-020 |
| RWB-20260816-010 | REQ-002 retro-audit/audit-report.md | RESOLVED | HIGH | STORY-026_private_gallery_design_fidelity | `galleryOpen` state could not be forced by `render-design-canvas.js`; resolved by STORY-044_private_gallery_design_fidelity_hardening (DONE, Reviewer round 2 DEFERRED_ONLY after a round-1 PATCH_REQUIRED on a missing runtime-smoke gate, closed via scrum-master waiver). `--click` flag added, real `galleryOpen` reference rendered, all 10 of STORY-026's D1-D10 re-verified against the real pair, 0 in-scope deviations. D-1 (tool durability, same shape as still-PENDING RWB-020) and D-2 (shadow-falloff platform convention) carried forward as follow-ups, not split into new RWB items |
| RWB-20260816-011 | REQ-002 retro-audit/audit-report.md | RESOLVED | MEDIUM | STORY-028_shared_expenses_design_fidelity | Missing both sides of `expense` evidence pair; resolved by STORY-043_shared_expenses_design_fidelity_hardening (DONE, Reviewer round 2 DEFERRED_ONLY after a round-1 PATCH_REQUIRED on stale iOS evidence). M-3 doc correction applied to STORY-028's own report; D-1/D-2/M-1 sharpened descriptions split to RWB-021 |
| RWB-20260816-021 | REQ-002 STORY-043 review/review-report.md (D-c) | PENDING | LOW | STORY-028_shared_expenses_design_fidelity | Shared design-system components need visual-fidelity fixes, sharpened by a real render (STORY-028's descriptions were reasoned, now corrected): D-1 `CupidAddAction` FAB gap is wider than recorded — flat pink **circle**, not just missing size/glow, because `radiusButton` resolves to a pill on a square FAB rather than the design's 20px rounded square; D-2 `CupidPrimaryButton` iOS CTA gap is narrower than recorded — already has `gradientHot`/`glowShadow`/pill radius/`w800`, remaining gap is only height 54 vs 52, fontSize 16.5 vs 15.5, missing leading `add` glyph; M-1 (FAB overlap) is now observed, not predicted, and confirmed Material-only (iOS has no FAB so no overlap). Anchor: `mobile/lib/design_system/adaptive/**`, shared with Dream Jar/Gallery/Home — same exclusion class as RWB-012; route to mobile lane, same design-system-scoped story as RWB-012 if one is opened |
| RWB-20260816-013 | REQ-002 STORY-037 review/review-report.md (DEF-1) | RESOLVED | LOW | STORY-011_invite_code_design_fidelity | 6 sibling screens (`otp_screen.dart:79`, `love_contract_screen.dart:109`, `onboarding_profile_setup_screen.dart:85`, `permissions_screen.dart:107`, `joincode_screen.dart:125`, `vow_screen.dart:169`) carried the same opaque `backgroundColor: colors.colorBackground` Scaffold override that occluded the shared `--sky` app-shell backdrop; STORY-032's remediation was never swept to these call sites; resolved by STORY-046_shared_backdrop_occlusion_hardening (DONE, Reviewer cycle 2 DEFERRED_ONLY). DEF-2 (contract pair state mismatch) split to RWB-023; DEF-3 (VISUAL_FIDELITY scope caveat, joincode structural deviation) split to RWB-024 |
| RWB-20260816-023 | REQ-002 STORY-046 review/review-report.md (DEF-2) | PENDING | LOW | STORY-015_love_contract_design_fidelity | `contract`'s STORY-046 evidence pair compares mismatched states: implemented capture is `partnerAlreadySigned` (English fixture clauses, "2/20 điều khoản", "Minh Anh đã ký, đến lượt bạn"), design reference shows a different state (Vietnamese clause copy, "+ Thêm điều khoản của riêng tụi mình" affordance, no signature line); AC3's content-column MATCH rests on structural correspondence only, not same-state comparison; route to requirement-level audit for a same-state re-verification |
| RWB-20260816-024 | REQ-002 STORY-046 review/review-report.md (DEF-3) | IN_PROGRESS | LOW | STORY-002_onboarding_pairing_navigation | STORY-046's `VISUAL_FIDELITY: PASS` is backdrop-scoped only, not a full design match for the 6 screens it touched; app-bar-chrome absence on `otp`/`profile`/`permissions`/`joincode` is an approved Chrome Rules deviation, but `profile` (avatar/CTA text), `permissions` (notification body localization), and especially `joincode` (single free-text field vs. 8-char segmented `CPD-8…` cells, missing Dán/Quét QR/creator affordances — reviewer called this "the largest") are undisclosed pre-existing deviations from their own origin stories; triage each at the requirement-level audit (`joincode` first). Opened as `STORY-047_pairing_chain_deviation_triage` |
| RWB-20260816-014 | REQ-002 STORY-039 review/review-report.md (V-1) | PENDING | LOW | STORY-015_love_contract_design_fidelity | `contract` D-7/D-8/D-10/D-13 re-confirmed by test/structure only, no in-scope render path (`main_preview.dart` lacks a requester-unsigned fixture); add fixture, route to mobile lane |
| RWB-20260816-015 | REQ-002 STORY-039 review/review-report.md (V-2) | PENDING | LOW | STORY-015_love_contract_design_fidelity | `contract` clause-counter row is an unclassified app-vs-design delta misfiled under F-5; route with F-1/F-2/F-3 token-policy question to Product Owner/Tech Lead |
| RWB-20260816-016 | REQ-002 STORY-040 story_master.md (D1) | PENDING | LOW | STORY-018_chat_typing_ghost_design_fidelity | `chat` missing `colorOnAccent`/inverse-text design token; real in light theme (OQ5), imperceptible in audited dark theme; `design_system/` change outside chat-screen story WriteScope |
| RWB-20260816-017 | REQ-002 STORY-040 review/review-report.md (R-1) | PENDING | LOW | STORY-018_chat_typing_ghost_design_fidelity | `chat` header renders `Linh` alone with no `đang online` presence chip, vs. design's `Minh ↔ Linh` + presence chip; pre-existing `CupidHeader` title-only limitation, undisclosed in STORY-040's report; `design_system/adaptive/` change outside chat-screen story WriteScope |
| RWB-20260816-018 | REQ-002 STORY-041 story_master.md (D-05) | PENDING | LOW | STORY-022_anti_ghosting_settings_design_fidelity | `antighost` penalty card omits design source's first row `Đếm ngược công khai` / "Public countdown" (amber tile); needs a new persisted setting, backend field, and l10n keys — same blocker class as D-01; split out of STORY-041's Product Owner scoping rather than folded into the hardening story |
| RWB-20260816-019 | REQ-002 STORY-041 review/review-report.md (RV-1) | PENDING | LOW | STORY-022_anti_ghosting_settings_design_fidelity | `antighost` sound-penalty row label reads `Gây ồn` in the app vs. design's `Phát âm thanh` — same glyph/position, different words; undisclosed in STORY-022's or STORY-041's own reports, reviewer-found; string lives in `mobile/lib/l10n/arb/`, same l10n-blocker class as D-01/D-02/D-03; split out rather than patched in-story |
| RWB-20260816-020 | REQ-002 STORY-042 visual-fidelity-report.md (Tool limitation) | PENDING | LOW | STORY-042_love_timeline_design_fidelity_hardening | `render-design-canvas.js` has no `--scroll` flag and its `--hide` selectors don't survive the screen-click re-render, so below-the-fold design content is uncapturable by the sanctioned tool; anchor devops |
| RWB-20260816-022 | REQ-002 STORY-045 review/review-report.md (DF1) | PENDING | LOW | STORY-002_onboarding_pairing_navigation | `pairing_choice_screen.dart`'s `Align(topCenter)` + fixed `EdgeInsets.fromLTRB(28, 150, 28, 0)` fix (STORY-045) removed the layout's short-viewport tolerance: required height inside `SafeArea` rises from ~211dp to ~350dp with no scroll fallback; orientation is unlocked, so a 360x640dp phone rotated overflows by ~38dp. Sibling `joincode_screen.dart:138` made the same transcription and guarded it with `SingleChildScrollView` — same one-line remediation; anchor mobile |

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
Status: RESOLVED
Priority: MEDIUM

Resolved via `STORY-042_love_timeline_design_fidelity_hardening` (Status:
DONE, Reviewer Iris-QC-7 `Outcome: CLEAN`, all 7 ACs MET). Product Owner
scoped 7 ACs (M-11 folded into AC1 fixture-setup; D-1/M-4/M-5/M-8-12
confirmed out of scope; M-2/M-3/conic-ring-seam folded into AC4). Rendered
comparison performed for the first time via a `PREVIEW_TIMELINE_FIXTURE`
dev-only capture fixture in `mobile/lib/main_preview.dart`; 18/20 of
STORY-025's deviations matched as-is, 2 (#8 connector-dot fill, #19
dashed-border rhythm/straddle) did not survive a real render and were
fixed. AC4 conic-ring seam PASS no fix needed (M-2 discharged);
dashed-border FAIL as delivered, fixed (M-3 discharged). Reviewer
independently re-measured every AC (rail centre, entry-card edges,
countdown-card top, conic-ring, dashed-border via luminance analysis
cross-validated against the sanctioned photo-placeholder frame,
connector-dot box-sizing) and reproduced the implementer's gates exactly
(flutter analyze clean, full suite 1270 passed). Residual R-1 (entry card
+5dp from Nunito line-height metrics) folds into the existing M-4
shared-typography carry-forward for requirement integration review, not a
new item. A `render-design-canvas.js` tooling gap (no `--scroll` flag;
`--hide` selectors don't survive the screen-click re-render, so
below-the-fold content is uncapturable by the sanctioned tool) is split to
`RWB-20260816-020`. See
`STORY-042.../visual-fidelity/visual-fidelity-report.md` and
`STORY-042.../review/review-report.md`. Closure commit `7e5ab1f`.

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
Status: RESOLVED
Priority: HIGH

Resolved via `STORY-044_private_gallery_design_fidelity_hardening` (Status:
DONE, Reviewer Iris-QC-9, round 2 `Outcome: DEFERRED_ONLY`, all 7 ACs PASS).
Round 1 was `PATCH_REQUIRED` on a single finding B1 (missing story-level
runtime startup smoke, rule 12g) — remedy was scrum-master-owned since the
phase changed zero app code (`git diff --stat db413549e2 -- mobile/`
independently confirmed empty both by the reviewer and by scrum-master);
closed via a `Runtime-Smoke: WAIVED` line in `story_master.md`. No AC ever
failed in either cycle.

Remediation path (a) from this item's original two options was delivered:
P0 (devops) added a repeatable `--click=<css selector>` pre-shutter
interaction flag to `render-design-canvas.js` (committed as a patch, since
the tool file itself is gitignored — `.gitignore:5`); P1 (mobile) rendered
`design-reference-gallery-android.png` with `galleryOpen` forced via the
`doUnlock` CTA selector, paired it with STORY-026's existing
`implemented-gallery-emulator-5560.png`, and re-verified all 10 of
STORY-026's D1-D10 deviations plus its open E2 composite-width question
against the real rendered pair (0 in-scope deviations found). Zero app
code changes were required.

Follow-ups carried forward, not split into new RWB items (same shape as
existing entries):
- D-1: the `--click` tool change is not durable — `.gitignore:5` means the
  next `./install.sh --platform=claudecode` overwrites it; upstream
  propagation to the bundle source repo is still owed, identical shape to
  the still-`PENDING` RWB-020.
- D-2: shadow-falloff decay length differs by platform rendering convention
  (CSS blur sigma vs. Flutter blurRadius sigma on an exactly transcribed
  token) — belongs to whichever story next touches
  `cupid_platform_tokens.dart`, a design-system-wide recalibration, not a
  gallery-specific fix.

## RWB-20260816-011 — STORY-028 shared expenses: zero rendered evidence either side

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-028_shared_expenses_design_fidelity/`
Status: RESOLVED
Priority: MEDIUM

Resolved via `STORY-043_shared_expenses_design_fidelity_hardening` (Status:
DONE, Reviewer Iris-QC-8, round 2 `Outcome: DEFERRED_ONLY`, all 7 ACs MET).
Round 1 was `PATCH_REQUIRED`: both iOS evidence captures had been taken from
a pre-fix build (status-bar timestamps ~20 min before the Android set;
stale `17/8` date and `480.000 ₫` spaced-unit strings) and one MATCH verdict
(F6) cited the wrong image — real defects, not reviewer nitpicks, since they
certified a build other than the one delivered. Round 2 replaced both iOS
captures from the corrected build and fixed both findings.

All 32 of STORY-028's enumerated deviations (25 + AC1's F1-F7) re-verified
against a real dual-platform render for the first time. Two new
render-only findings fixed in app code: N-1 (`_dateLabel` not zero-padded,
now `dd/MM`), N-2 (amount had a stray space before `₫`, now attached). N-3
(dev-only preview-harness FAB overlay bug) fixed in `main_preview.dart`
only, not reachable from production. D-1/D-2 (shared `CupidAddAction`/
`CupidPrimaryButton` components) and M-1 (FAB overlap, travels with D-1)
re-confirmed out of scope; M-2 (empty filtered result, cosmetic) and M-4
(1px gap, below threshold) re-confirmed non-blocking. M-3's inaccurate
"as in the mock" justification corrected directly in STORY-028's own
`visual-fidelity/visual-fidelity-report.md` (F2 row) by Scrum Master, since
STORY-028 is closed and Reviewer declined to edit its approved artifact.

D-1/D-2/M-1's sharpened descriptions (the render revealed D-1 is a shape
defect, not just size/glow, and D-2's gap is now much narrower than
STORY-028 recorded) are split to `RWB-20260816-021` so a future
design-system-scoped story is not scoped against the stale baseline. See
`STORY-043.../visual-fidelity/visual-fidelity-report.md` and
`STORY-043.../review/review-report.md` (both rounds).

## RWB-20260816-021 — Shared design-system components: FAB shape and iOS CTA gap (sharpened, mobile lane)

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-028_shared_expenses_design_fidelity/`
Status: PENDING
Priority: LOW

Found during `STORY-043_shared_expenses_design_fidelity_hardening`'s round-2
rendered evidence (Reviewer Iris-QC-8, D-c), which sharpens and in one case
corrects STORY-028's own D-1/D-2/M-1 descriptions now that a real
dual-platform render exists. STORY-028 had deferred all three because the
affected widgets — `CupidAddAction` (Material FAB) and `CupidPrimaryButton`
(iOS full-width CTA) — live in shared
`mobile/lib/design_system/adaptive/**` components used by Dream Jar,
Gallery, and Home, not just Expenses; same exclusion class as RWB-012
(different anchor screen, same shared-component reasoning).

1. **D-1 (Material FAB, shape defect, not previously recorded).** Design
   source specifies `60x60`, `border-radius:20px` (rounded square),
   `grad-hot` background, glow shadow, `27px` glyph. The shipped
   `CupidAddAction` already has the right size, gradient, and glow, but its
   `radiusButton` token resolves to a full circle/pill, not a 20px rounded
   square — a shape defect STORY-028's own report never recorded (it only
   flagged "flat pink circle" as if the whole visual treatment were missing).
2. **D-2 (iOS full-width CTA, gap much narrower than STORY-028 recorded).**
   Design source specifies `height:52px`, `grad-hot` background, glow,
   `15.5px w800` label, leading `add` glyph. The shipped `CupidPrimaryButton`
   already draws the gradient, glow, pill radius, and a `w800` label —
   STORY-028's "missing gradient/glow" description is stale. The remaining
   gap on real render is only: height 54px vs. 52px, label size 16.5px vs.
   15.5px, and a missing leading `add` glyph.
3. **M-1 (FAB overlap, now observed and confirmed Material-only).** The
   round-2 iOS capture shows the same last-row amount (`1.200.000₫`) renders
   in full at the same scroll extent where the Material capture clips it to
   `1.200`. Confirmed by direct image comparison — not a shared-layout
   fault, so it travels only with a Material-side D-1 fix, not with D-2.

Exact remediation needed: fix `radiusButton` (or the FAB's explicit radius
override) in `CupidAddAction` to a 20px rounded square per the design
tokens; adjust `CupidPrimaryButton`'s iOS variant height/label size and add
the leading `add` glyph; re-verify M-1 clears once D-1 lands. Anchor:
`mobile/lib/design_system/adaptive/**` (shared component lane), no specific
screen story blocked today — same routing posture as RWB-012.

## RWB-20260816-012 — STORY-002 pairing_choice: surface/CTA styling gap (D1, mobile lane)

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-002_onboarding_pairing_navigation/`
Status: RESOLVED
Priority: LOW

Resolved by `STORY-045_pairing_choice_design_fidelity_hardening` (DONE,
Reviewer `DEFERRED_ONLY`, closure commit pending). Independent code-level
root-cause verification (both by the implementer and, separately, by the
reviewer): of the 4 reported deviations, deviations 1 and 2 (background
gradient/particles, CTA gradient/glow) were already closed in the codebase
before this story opened — `CupidPrimaryButton` already applies
`gradientHot`/`glowShadow` and `CupidAppBackground` was already mounted at
the composition root. Both were measurement artifacts of a stale, mis-scaled
implementation capture carried over from STORY-002 (predating commit
`d43d9f2`/STORY-032, and rendered at `--width=540` with no matching
`--density`). Only deviations 3 (type scale) and 4 (title vertical offset)
were real and were fixed: `pairing_choice_screen.dart`, one file, +13/-3
(`Center` -> `Align(topCenter)` + `EdgeInsets.fromLTRB(28, 150, 28, 0)`;
title style -> `27px`/`w900`/`height:1.3`). All 6 ACs PASS with a matched
1px-tolerance visual-fidelity evidence pair (dark theme, `vi` locale).

New regression introduced by the fix, deferred not blocking (existing
evidence pair stays valid — portrait-only, no design-scope regression):
short-viewport/landscape overflow from the fixed top padding with no scroll
fallback. Split to `RWB-20260816-022`.

Carry-forward note (from both the implementer and reviewer, worth acting on
when scoping remaining items): the same stale/mis-scaled STORY-002-era
capture set may also have distorted the scoping of still-`PENDING`
RWB-20260816-013..021. Recommend a baseline re-capture at native
resolution/density before scoping each of those, rather than trusting the
original audit's reported deviations at face value.

## RWB-20260816-013 — 6 sibling screens occlude the shared `--sky` backdrop (DEF-1, mobile lane)

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-011_invite_code_design_fidelity/`
(tracking anchor; the affected screens span multiple stories/features)
Opened as: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-046_shared_backdrop_occlusion_hardening/`
Status: RESOLVED
Priority: LOW

**Resolution (2026-08-18):** Delivered as `STORY-046_shared_backdrop_occlusion_hardening`
(Status: DONE). All 6 `backgroundColor:` Scaffold overrides removed, following
the `forgot_screen.dart:103-106` precedent. Reviewer (Iris-QC) cycle 1 found
`Outcome: PATCH_REQUIRED` (BLK-1: probe-only evidence insufficient for a
UI-bearing story with a locked `design_source` — a rendered `implemented-*`/
`design-reference-*` PNG pair per screen plus a top-level `VISUAL_FIDELITY:`
marker is required and is not waivable by scope relaxation; BLK-2: the probe
did not verify the "content/layout unchanged" clause of AC2-AC7). Mobile-dev
patched additively: rendered all 12 PNGs (all 6 references fresh, not reused,
which also resolved DEF-1), added a `## Rendered design-fidelity comparison`
section with a decisive pre-change A/B per screen (`vow` against
STORY-016's pre-change capture, `contract` against STORY-039's). Reviewer
cycle 2 recorded `Outcome: DEFERRED_ONLY`: both blocking findings resolved,
0 blocking findings remain. Two new deferred findings surfaced by the
reviewer opening all 12 images (not disclosed by the mobile-dev's own
report) were out of this story's scope and split to new items: DEF-2
(`contract` pair compares mismatched states) to `RWB-20260816-023`; DEF-3
(`VISUAL_FIDELITY: PASS` is backdrop-scoped only, `joincode`'s structural
deviation is the largest) to `RWB-20260816-024`. DEF-1
(`requirements.md` overstates reusable references) needed no new tracked
item — self-contained, already corrected in the story's own artifacts,
non-blocking documentation fix for whenever `requirements.md` is next
touched.

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

## RWB-20260816-022 — `pairing_choice` layout no longer tolerates short viewports (DF1, mobile lane)

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-002_onboarding_pairing_navigation/`
(tracking anchor; regression is in `pairing_choice_screen.dart`)
Status: PENDING
Priority: LOW

Surfaced by `STORY-045_pairing_choice_design_fidelity_hardening`'s reviewer
(`review/review-report.md`, finding DF1) while reviewing that story's
`Center` -> `Align(topCenter)` + `EdgeInsets.fromLTRB(28, 150, 28, 0)` fix
for RWB-20260816-012 AC3/AC4. The fixed top padding and lack of a scroll
fallback removed the layout's tolerance for short viewports:

- Required height inside `SafeArea` rises from roughly 211dp (pre-fix) to
  roughly 350dp (150 top pad + 2-line title at 27x1.3x2 = 70.2 + `xl` spacing
  32 + CTA 54 + `sm` spacing 8 + `TextButton` ~36).
- Neither `mobile/main.dart` nor `android/app/src/main/AndroidManifest.xml`
  locks orientation (`configChanges` includes `orientation|screenSize`), so
  landscape is reachable at runtime.
- On a 360x640dp phone rotated (usable height ~312dp) this overflows by
  roughly 38dp; on the STORY-045 capture device (`emulator-5560`) rotated it
  fits by only ~13dp and overflows once `font_scale` reaches ~1.3.
- Derived arithmetically from the widget tree and token values by the
  reviewer, not empirically reproduced (writing a probe test or capturing
  landscape is outside a compact-story-review's scope).

Classification: genuine regression introduced by STORY-045's own fix, not
pre-existing — but out of that story's acceptance surface (the locked design
source is a fixed portrait frame; no AC, UX section, or design reference
covers landscape or elevated font scale), so it does not invalidate
STORY-045's evidence pair or block its `DONE` status.

Exact remediation needed: wrap the `Padding` in `pairing_choice_screen.dart`
in a `SingleChildScrollView`, following the identical precedent already
established on the sibling screen `joincode_screen.dart:138` (same
design-column-from-top transcription, already guarded this way). One-line
fix, no visual change in portrait, so no existing evidence pair needs to be
redone; route to mobile lane.

## RWB-20260816-023 — STORY-046 `contract` evidence pair compares mismatched states (DEF-2, requirement-level audit)

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-015_love_contract_design_fidelity/`
(tracking anchor; finding is about STORY-046's own new `contract` evidence pair)
Status: PENDING
Priority: LOW

Surfaced by `STORY-046_shared_backdrop_occlusion_hardening`'s reviewer
(`review/review-report.md` cycle 2, finding DEF-2) while independently
opening all 12 rendered PNGs added by that story's patch — undisclosed by
the mobile-dev's own report. The implemented `contract` capture
(`implemented-contract-emulator-5560.png`) depicts the
`partnerAlreadySigned` state with English fixture clause text ("Always tell
the truth", "Don't sleep angry", "Check in once a day", "Say sorry first,
argue about it later"), a "2/20 điều khoản" counter, and a "Minh Anh đã ký,
đến lượt bạn" line. The design reference
(`design-reference-contract-android.png`, rendered fresh for STORY-046)
depicts a different state: Vietnamese clause copy ("Không giận quá 24
giờ", …), a "+ Thêm điều khoản của riêng tụi mình" affordance, and no
signature line.

Classification: not a regression and does not change STORY-046's own
outcome — that story's BLK-2 question (whether the backdrop-only change
altered `contract`'s content/layout) was independently and decisively
answered by a same-screen pre-change A/B against
`STORY-039_love_contract_design_fidelity_hardening`'s pre-change capture,
which does not depend on the reference's state matching. But the AC3 row's
`MATCH` verdict for `contract`'s content column rests on structural
correspondence (header band, clause rows, divider, CTA, encryption footer)
only, not on a same-state comparison, so it does not independently confirm
content fidelity in the signed state shown.

Exact remediation needed: at the REQ-002 requirement-level audit
(`integration-review/mobile-visual-audit.md`), either re-render
`design-reference-contract-android.png` in the `partnerAlreadySigned` state
(matching the implemented capture's fixture) or re-capture `contract` in
the reference's unsigned state, then re-compare content/layout on a true
same-state pair; route to mobile lane for the render/capture step.

## RWB-20260816-024 — STORY-046 `VISUAL_FIDELITY: PASS` is backdrop-scoped only; `joincode` structural deviation needs triage (DEF-3, requirement-level audit)

Story: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-002_onboarding_pairing_navigation/`
(tracking anchor; finding spans STORY-007/STORY-009/STORY-010/STORY-012's
own screens, surfaced incidentally by STORY-046's evidence)
Opened as: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-047_pairing_chain_deviation_triage/`
Status: IN_PROGRESS
Priority: LOW

Surfaced by `STORY-046_shared_backdrop_occlusion_hardening`'s reviewer
(`review/review-report.md` cycle 2, finding DEF-3) while opening all 12
rendered PNGs added by that story's patch. The report honestly records four
categories of deviation from the design references, none moved by
STORY-046's own diff and none newly introduced by it:

- no app-bar chrome on `otp`, `profile`, `permissions`, `joincode`, where
  the references draw a titled header — this one is an **approved**
  deviation per `ux/uiux-spec.md` Chrome Rules, not a defect
- `profile`: filled person-glyph avatar vs. the reference's dashed "Ảnh đại
  diện" ring; CTA "Tiếp tục → Love Contract" vs. the reference's "Tiếp tục →
  Ghép đôi"
- `permissions`: notification body "Nhắc nhớ đồng bộ và Emoji Storm" vs.
  the reference's "Synced Alarm và Emoji Storm" (localization delta)
- `joincode` (the largest): a single 6-character free-text field vs. the
  reference's 8-character segmented `CPD-8…` cells, and no "Dán" / "Quét
  QR" / "Tôi mới là người tạo mã →" affordances

Classification: pre-existing gaps, not introduced or worsened by
STORY-046 — that story made the shared backdrop wash visible on all 6
screens and changed nothing else; its `VISUAL_FIDELITY: PASS` marker
means "the backdrop fix landed and this story moved nothing else," not
"these 6 screens match the design source." Each deviation is owned by its
own origin story (`otp`→STORY-007, `permissions`→STORY-009,
`profile`→STORY-010, `joincode`→STORY-012) and reopening them inside
STORY-046 would have reopened four closed stories against its own explicit
Out-of-Scope list.

Exact remediation needed: triage each of the three real (non-chrome)
deviations at the REQ-002 requirement-level audit
(`integration-review/mobile-visual-audit.md`) before requirement closure —
`joincode` first, since it is structural rather than cosmetic. For each,
decide whether it is a genuine defect to harden (new RWB item, mobile
lane) or an accepted product/content difference to record and close as-is.

**Progress (2026-08-18):** Product Owner triage set 5 ACs in
`STORY-047_pairing_chain_deviation_triage/story_master.md`: AC1 (`profile`
CTA copy), AC2 (`permissions` notification copy), AC3 (`joincode` segmented
entry), AC4 (`joincode` paste), AC5 (`joincode` creator cross-link).
`joincode`'s 6-vs-8-char question resolved as a design-source content error
(backend `InvitationsService.generateCode` and every mobile surface already
agree at 6), not a real backend/contract mismatch — no cross-lane escalation
needed. Mobile implementation (`Alex-Mobile-Dev-13`) delivered and verified
AC1/AC3/AC4/AC5 (`flutter test` all green). AC2 blocked: the design's literal
`Synced Alarm` (`Cupid Screens.dc.html:2452`) trips STORY-021's approved
ADR-002 copy guard (`reminder_copy_guard_test.dart:18-22`), the same
guard/ADR conflict class already tracked, PENDING, in
`REQ-004_notifications_dnd_banner_copy_reconciliation` for a different token
("Do Not Disturb"). User decision 2026-08-18: fold AC2 into REQ-004 (one
PO/UX ruling for both tokens) rather than litigate it separately here;
`permissions`/STORY-009's fix moves to REQ-004 and is no longer part of this
item's remediation. This item (RWB-20260816-024) now closes once STORY-047
lands AC1/AC3/AC4/AC5 with rendered visual-fidelity evidence for `profile`
and `joincode` only.
