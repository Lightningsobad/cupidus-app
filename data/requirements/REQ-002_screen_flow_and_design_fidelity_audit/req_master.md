# Requirement Master: REQ-002 Screen Flow Correction & Design Fidelity Audit
Status: IN_PROGRESS (retro-hardening — see `## Retro Audit` below; reopened
2026-08-16 from DONE per `retro-audit/audit-report.md` RED-PATCH verdict)
Landed: 2026-08-16 — integration branch
`codex/REQ-002_screen_flow_and_design_fidelity_audit-integration` merged into
`main` via `git-story-boundary.sh land-integration` at merge commit
`a2de396` (parents `185a078`, `de0e3fe`). Round 4 closing-pass requirement
integration review (Iris-QC) recorded `Outcome: DEFERRED_ONLY`, no blocking
finding remained; R3-1 CLOSED, D4-1 deferred (LOW). Mobile code and all
bug-queue evidence confirmed present on `main` post-merge.
Stories-Merged: WAIVED — two stray story boundaries never carried real work
and were superseded by the actual delivery, which used STORY-001..STORY-033
exclusively (see `## User Stories` table, all DONE/DEFERRED and merged).
`SCOPE-B-RESCOPE` (started 2026-08-13, product-owner run, status STARTED) was
an early rescoping attempt abandoned once the one-screen-per-story breakdown
was finalized; its worktree is clean at its own base_head with zero unique
commits. `STORY-000` (started 2026-08-16, reviewer run, status STARTED) is a
stray boundary with a clean worktree, zero divergence from its own
base_head, and no story artifact anywhere under
`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/` — never
used for real work. Both independently confirmed via
`git-story-boundary.sh status` and `git status --porcelain`/`git log` in
each worktree before waiving.

## Source Request (verbatim, Vietnamese)
> Thêm 1 yêu cầu mới bao gồm:
> 1. Điều chỉnh lại các màn hình theo đúng các flow của app, ví dụ hiện tại
>    đang không phải màn đăng nhập khi vào ứng dụng này.
> 2. Rà soát song song toàn bộ các màn hình để điều chỉnh đúng như design,
>    yêu cầu khớp 100% (mỗi màn hình là 1 story).

## Business Context
The Cupid Flutter mobile app (REQ-001) is DONE, but the user has identified
two live defects/gaps against the intended product experience:

1. **App navigation/flow correctness** — the screens users land on do not
   follow the correct app flow. Concrete example given by the user: the
   screen shown when opening the app is not the login screen, when it should
   be. This scope covers auditing and correcting entry-point routing and
   inter-screen navigation so the app flow matches the intended user journey
   (e.g., correct initial route, correct screen-to-screen transitions per the
   product flow).
2. **Design fidelity, 100% match, across every screen** — a full re-audit of
   every screen in the app against the locked design source
   (`cupid-app-design-system`, per `detect_design_source.py`), correcting any
   visual/layout/spacing/component deviation until each screen matches the
   design exactly. This is broader than a spot-check: it must cover the
   entire current screen inventory.

This requirement is distinct from REQ-001's prior retro-audit hardening cycle
(STORY-017..STORY-021), which closed the design-fidelity capture gap that
existed at that time (37/37 screens captured, 3 code-fix hardening stories
delivered, REQ-001 closed DONE 2026-08-12). REQ-002 is a new, user-initiated
pass requested after that closure and must not assume the prior cycle's
findings still hold — it re-verifies flow correctness and design match from
current app state.

## Scope

### A. Screen Flow / Navigation Correction
- Audit the app's actual entry point and inter-screen navigation against the
  intended product flow (per UX/System UX Memory and the app's own flow
  definitions).
- Fix any screen/route that does not match the correct flow. Confirmed
  example: initial app launch must route to the login screen (currently does
  not).
- Story splitting for this part is normal Product Owner judgment (may be one
  story or a few, grouped by flow/navigation area) — it is NOT subject to the
  one-screen-per-story rule below.

### B. Full Design Fidelity Audit (100% match required)
- Re-audit **every** current screen in the app against the locked design
  source, screen by screen, and correct any deviation found.
- Acceptance bar is exact match ("khớp 100%") to the design source, not a
  best-effort approximation.
- **Story splitting directive (explicit user instruction): one story per
  screen.** Product Owner must enumerate the current full screen inventory
  and create exactly one story per screen for this part of the requirement,
  so each screen's design-fidelity correction can be reviewed and delivered
  independently.
- User explicitly requested this part run as a **parallel** review/delivery
  effort across screens (`rà soát song song toàn bộ các màn hình`). Route
  execution of this requirement through `continue parallel` /
  `parallel-continue.md` rather than the ordinary single-story-at-a-time
  flow, once stories exist.

## Deployment Status
- Development Environment: NOT_DEPLOYED
- Staging: NOT_REQUESTED
- Production: NOT_REQUESTED

## Configuration Documentation
- Source of Truth: `deployment/configuration-guide.md`
- Status: NOT_REQUIRED
- Pending User Setup: NONE
- Last Updated:

## Deferred Follow-Up Items (out of this requirement's scope)
- **Real biometric ("Đăng nhập bằng vân tay") login authentication.** STORY-005
  Reviewer round 3 (`STORY-005_login_design_fidelity/review/review-report.md`,
  finding BF-01) found the locked design authors a fingerprint quick-unlock
  row on the login screen that the app does not implement. Wiring functional
  biometric auth (device APIs, permission prompts, success/failure/fallback)
  exceeds STORY-005's trivial design-fidelity scope. User decision
  2026-08-15: defer and open a new backlog item rather than fold it into
  STORY-005 or render it decorative-only. Not yet created as a story — needs
  Product Owner scoping (business case, acceptance criteria, platform
  biometric API selection) as a future backlog item, tracked outside REQ-002.
- **iOS visual-fidelity pass for the login screen (STORY-005).** Blocked by
  `IOS_NO_SIMULATOR` (no iOS Simulator runtime installed on this Mac); STORY-005
  was accepted Android-only scope per prior user decision, so AC4 stays
  PARTIAL. Reviewer round 4 (`STORY-005_login_design_fidelity/review/review-report.md`)
  notes a later iOS pass should also settle the Apple social button's 16px
  glyph (`Cupid Screens.dc.html:1451`), which was never in this story's
  Android scope. Not yet scheduled.
- **RR-01 — fixed-height field card has no text-scaling clamp.** STORY-005
  Reviewer round 4 found the login screen's `SizedBox(height: 63.6)` field
  card has no `TextScaler` clamp; at 1.3x system text scale, computed content
  height (~73dp) would overflow the fixed 63.6dp constraint. Not blocking for
  STORY-005 (no dynamic-type acceptance criterion was in scope), but the same
  fixed-height pinning pattern is likely present on other field-bearing
  screens across REQ-002's Scope B story set and should get a deferred
  requirement-level text-scaling audit/follow-up.
- **ND-01 — documentation defect in STORY-005 `coding-plan/test-results.md`.**
  The field-state evidence section incorrectly attributes the soft keyboard
  not rendering in some captures to "a known emulator/adb `screencap`
  limitation" — this is contradicted by the filled-state capture
  (`login-android-filled.png`) in the same evidence set, which does show a
  full keyboard. Documentation-only fix needed; the underlying AC3 conclusion
  is unaffected (independently corroborated by Reviewer round 4). Not yet
  corrected.
- **IF-2 — inconsistent screen header affordances (MEDIUM).** Round 2
  requirement mobile visual audit + Round 2 integration review: `expense` and
  `jarnew` show a title with no visible back affordance, while most other
  screens use back-arrow+title and `invite`/`joincode` use back-arrow with no
  title. Not blocking — `expense` is reached via `Navigator.push` so a
  system/gesture back exists; this is a missing *visible* affordance, not a
  dead end. No REQ-002 story owns the shared header contract. Needs a
  requirement-level header-affordance audit/follow-up.
  **Round 3 update:** `otp`/`forgot`/`permissions`/`onboarding_profile_setup`
  are RESOLVED out of this finding — `BUG-20260814-001` (`f726e8c`) correctly
  removed their header per the locked `STORY-002` AC4 Chrome Rules override;
  "no header chrome" is their specified behaviour, a fourth pattern, not a
  deviation. `expense`/`jarnew` remain the open MEDIUM gap.
- **D3-2 (Round 3) — no-visible-back-affordance group widens from 2 to 6
  screens.** With the header removed, `otp`/`forgot`/`permissions`/
  `onboarding_profile_setup` join `expense`/`jarnew` as screens with no
  in-screen back control. Deferred on the same reasoning already accepted for
  `expense`: the navigation leg survives via the platform back gesture
  (`uiux-spec.md:34` locks the `forgot → login` transition;
  `auth_leg_edges_test.dart` pins that leg through `handlePopRoute()`).
  Recording because the count changed and no story owns the shared header
  contract. Same requirement-level header-affordance follow-up as IF-2 above.
- **IF-3 — `chat` has no partner header (LOW).** Possibly fixture-dependent;
  re-check with a real paired session before routing.
- **IF-4 — shared app-background wash occluded on 3 of 4 onboarding-chain
  screens (LOW).** Restated in Round 3 after the `otp`/`forgot`/`permissions`/
  `profile` recapture: the original Round 2 comparator list ("`otp` flatter
  than `forgot`/`permissions`/`profile`") was wrong. Pixel-sampled on the
  recaptured screenshots: `otp`, `permissions`, `profile` are identical flat
  `rgb(23,17,41)`; `forgot` is the outlier, rendering the shared background
  wash. Root cause: `otp_screen.dart:79`, `permissions_screen.dart:107`, and
  `onboarding_profile_setup_screen.dart:85` each still set
  `backgroundColor: colors.colorBackground` (opaque `Scaffold` fill) —
  independently confirmed by Scrum Master via direct source read.
  `forgot_screen.dart` dropped that override under STORY-032 AC1 and is the
  only one of the four migrated to the shared `CupidAppBackground` wash. Out
  of per-screen story scope (the shared background layer arrived in
  STORY-032, after these four screens shipped from STORY-007/008/009/010).
  Scope caveat: only these four screens were re-measured; a repo-wide sweep
  for the same retained-override pattern was not part of this pass.
- **D3-1 (Round 3, was DEF-2 in the `BUG-20260816-001` bugfix review) —
  `gradientBrandBackdrop` has a single consumer.** Confirmed: the only
  production call site is `welcome_screen.dart:143` (plus the token
  definition and one test assertion); `165deg` occurs exactly once in
  `cupid-app-design-system/project/Cupid Screens.dc.html` (line 69, inside
  the `isWelcome` block), so no other canvas screen silently paints something
  else in its place. Residual question — whether other screens' differently
  angled backdrops match their own design sources — is genuine but is
  ordinary per-screen fidelity work, informational only.
- **D4-1 (Round 4) — IF-4's `backgroundColor: colors.colorBackground`**
  **override pattern is wider than the 3 named screens (LOW).** Round 4's
  closing-pass reviewer ran a repo-wide sweep (IF-4's own scope caveat) and
  found 7 screens retain the override, not 3: `otp_screen.dart`,
  `permissions_screen.dart`, `onboarding_profile_setup_screen.dart`, plus
  `invite_screen.dart`, `joincode_screen.dart`, `vow_screen.dart`, and
  `love_contract_screen.dart`. Does not reopen R3-1 and does not change
  IF-4's LOW severity — the shared `CupidAppBackground` wash is occluded, not
  broken; whether it should reach these additional screens is a design
  question, not a defect. Recorded so the STORY-032 background migration is
  not assumed complete. Same owner as D3-2: requirement-level fidelity
  follow-up.
- **IF-5 — `gallery` photo tiles render as empty dark rectangles (LOW).**
  Likely seeded-data dependent, not a layout defect. Re-check with a seeded
  media fixture before routing.
- **IF-6 — `jarnew` uses bare Material underline fields, not the rounded
  filled field cards used elsewhere (LOW).** Normally a modal sheet
  (`CreateDreamJarSheet`) captured outside its host; has no canvas id of its
  own, so may have no locked design counterpart at all.
- **IF-7 — STORY-004 shipped with no rendered visual-fidelity evidence
  (PROCESS).** `STORY-004_welcome_design_fidelity/visual-fidelity/` holds
  only a report, no `implemented-*.png`/`design-reference-*.png` — the direct
  reason the welcome-screen defects (`BUG-20260816-001`) reached integration
  undetected. Argues for enforcing the per-story capture rule going forward.
- **IF-8 — stale claim in STORY-030's visual-fidelity report (PROCESS).**
  States `data/devops/system/design-fidelity-config.json` "does not exist
  anywhere in this repository"; the file is present at integration HEAD with
  `design_source.locked: true`. Documentation-only correction, not yet made.
- **Tech Lead finding P1-F2 (carried from Round 1 integration review D-6).**
  Still open pending a Product Owner/UX framing ruling; no live regression
  found for it in either integration review round.
- **E-1 — app shell tab bar (≤3 destinations + separate FAB) vs. the design's
  5-tab canvas.** Round 2 review flagged this as a business/scope decision,
  not a call for Reviewer or Scrum Master. User decision (2026-08-16): open a
  new story rather than accept the divergence — tracked as
  `REQ-003_app_shell_five_tab_navigation_and_fab_consolidation`
  (`data/requirements/master_requirements_list.md`, Status: PENDING). Not a
  REQ-002 blocker; REQ-002 does not need REQ-003 to close.
- **E-2 — `notifs` DND banner copy conflicts with `reminder_copy_guard_test.dart`'s**
  **ADR-002 ban.** Round 2 review flagged this as a design-vs-ADR conflict
  needing a business ruling. User decision (2026-08-16): route to Product
  Owner/UI-UX Designer for a copy ruling rather than keep the guard as-is —
  tracked as `REQ-004_notifications_dnd_banner_copy_reconciliation`
  (`data/requirements/master_requirements_list.md`, Status: PENDING). Not a
  REQ-002 blocker; REQ-002 does not need REQ-004 to close.

## Retro Audit

Trigger: `retro-audit/audit-report.md` (Audit Date 2026-08-16), user-scoped
design-fidelity evidence-pairing check. Verdict: **RED-PATCH** — 11 of 32
DONE stories had a `visual-fidelity/` directory missing one or both sides of
a same-screen `implemented-*`/`design-reference-*` pair. Remediation items
tracked in `data/retro-audit/rework-backlog.md`, RWB-20260816-001 through
RWB-20260816-011. This requirement is reopened to `IN_PROGRESS` until every
RWB item is resolved, then returns to `DONE` per the same pattern used for
REQ-001's retro-hardening cycle.

- **RWB-20260816-001 — STORY-002 `pairing_choice` has no design-canvas
  counterpart. RESOLVED (2026-08-16).** User decision (2026-08-16, in
  response to the audit report): the design canvas is missing this screen,
  not the app — routed `ui-ux-designer` to add a `pairing_choice` node to the
  design system and resolve finding F-B (the canvas encoded a shorter
  pairing chain than the app actually implements), then rendered
  `design-reference-pairingchoice-android.png` and paired it with the
  existing `implemented-pairingchoice-emulator-5560.png` capture in
  STORY-002's own `visual-fidelity/` directory. Delivered as
  `STORY-034_pairing_choice_canvas_addition` (Status: DONE). Reviewer
  (Iris-QC) recorded `Outcome: DEFERRED_ONLY`: AC1-4 all PASS, F-B closed at
  source; one deferred finding D1 (app build does not apply the design
  system's surface/CTA styling to `pairing_choice` — pre-existing gap,
  belongs to the `mobile` lane, tracked as RWB-20260816-012, not a
  STORY-034 blocker). See `STORY-034.../review/review-report.md`.
- **RWB-20260816-012 — STORY-002 `pairing_choice`: surface/CTA styling gap**
  **(D1, mobile lane) (LOW). RESOLVED (2026-08-18).** Resolved by
  `STORY-045_pairing_choice_design_fidelity_hardening` (DONE, Reviewer
  `DEFERRED_ONLY`). Root cause: 2 of 4 reported deviations (background
  gradient/particles, CTA gradient/glow) were already closed pre-story,
  artifacts of a stale/mis-scaled STORY-002-era capture; only type scale and
  title vertical offset needed a real fix (1 file, +13/-3). All 6 ACs PASS,
  matched 1px-tolerance visual-fidelity evidence pair. New regression from
  the fix (short-viewport/landscape overflow, DF1) split to
  `RWB-20260816-022`. See `STORY-045.../review/review-report.md` and
  `rework-backlog.md`.
- **RWB-20260816-022 — `pairing_choice` layout no longer tolerates short
  viewports (DF1, mobile lane) (LOW). RESOLVED (2026-08-18).** Regression
  introduced by STORY-045's own RWB-012 fix (fixed top padding, no scroll
  fallback); out of that story's portrait-only acceptance surface, did not
  block its `DONE` status. Resolved by
  `STORY-048_pairing_choice_viewport_regression_hardening` (DONE, Reviewer
  `Outcome: CLEAN`, 0 blocking/0 deferred): `SingleChildScrollView` wraps
  the existing `Padding` under a retained `Align(topCenter)`, matching the
  `joincode_screen.dart:138` precedent's effect. AC1 widget test reproduced
  a 72dp overflow at font scale 1.3x (larger than the ~38dp estimate) and
  passes post-fix; AC2 portrait geometry proven pixel-identical pre/post fix
  by both implementer and reviewer independently, so STORY-045's evidence
  pair was untouched. DONE gate additionally required a fresh
  `STORY-048/visual-fidelity/` pair (UI-bearing screen, locked design
  source); produced capture-and-record only and independently verified. See
  `STORY-048.../review/review-report.md` and `rework-backlog.md`.
- **RWB-20260816-002 — STORY-004 `welcome`: zero rendered evidence either
  side. RESOLVED (2026-08-17).** Delivered via
  `STORY-035_welcome_design_fidelity_hardening` (Status: DONE, Retro-Type:
  RED-PATCH, Fixes: STORY-004), routed through the full Product Owner -> UX
  Designer -> Tech Lead -> implementation -> Reviewer pipeline across three
  review cycles. Cycle 2 `DEFERRED_ONLY` correctly deferred a real gradient-
  axis defect (D1, `cupid_color_tokens.dart`, CSS-angle vs Flutter-Alignment
  mismatch) as outside the original Write Scope; the user then explicitly
  chose to widen the story's Write Scope and fix D1 inline rather than route
  it separately. Phase P1 (Tech Lead + mobile-dev) fixed the shared token
  helper at its root, covering both `gradientBrandBackdrop` (welcome,
  rendered re-verification) and `gradientHot` (~20 consumers, verified via a
  box-shape-matrix axis/extent test), touching zero consumer widget files.
  Cycle 3 `Outcome: CLEAN` (0 blocking, 0 deferred) — Reviewer independently
  re-measured the fixed axis with a different method than mobile-dev's own
  and confirmed match; all AC1-5 PASS;
  `visual-fidelity/visual-fidelity-report.md` records
  `VISUAL_FIDELITY: PASS`. See `STORY-035.../review/review-report.md`.
- **RWB-20260816-003 — STORY-006 `register`: zero rendered evidence either
  side. RESOLVED (2026-08-17).** Delivered via
  `STORY-036_register_design_fidelity_hardening` (Status: DONE, Retro-Type:
  RED-PATCH, Fixes: STORY-006), routed through Product Owner (trivial/mobile
  single-lane scoping; UX Designer and Tech Lead phases `SKIPPED:trivial`) ->
  mobile-dev implementation -> Reviewer (`compact-story-review`) pipeline.
  Mobile-dev captured a real evidence pair
  (`implemented-register-emulator-5560.png` /
  `design-reference-register-android.png`) and the rendered-to-rendered
  comparison surfaced and fixed a real deviation (AC2, field-card height —
  Flutter's default `bodyLarge` line-box vs. the design's line-height,
  corrected via a forced `StrutStyle`, with a new regression test). Reviewer
  (Iris-QC) cycle 1 recorded `Outcome: DEFERRED_ONLY`: AC1-5 all PASS with
  independently re-derived evidence; the governed header-chrome deviation
  (register outside the canvas's `NO_CHROME` list, app correctly omits it
  per STORY-002's UX spec) independently verified; 0 blocking findings, 3
  non-blocking deferred (DEF-1 traceability nit, DEF-2 residual sub-visible
  password-card gap, DEF-3 evidence-count nit). See
  `STORY-036.../review/review-report.md`.
- **RWB-20260816-004 — STORY-011 `invite`: zero rendered evidence either
  side. RESOLVED (2026-08-17).** Delivered via
  `STORY-037_invite_design_fidelity_hardening` (Status: DONE, Retro-Type:
  RED-PATCH, Fixes: STORY-011), routed through Product Owner (trivial/mobile
  single-lane scoping; UX Designer and Tech Lead phases `SKIPPED:trivial`) ->
  mobile-dev implementation -> Reviewer (`compact-story-review`) pipeline
  across two cycles. Mobile-dev captured a real evidence pair
  (`implemented-invite-emulator-5560.png` /
  `design-reference-invite-android.png`) and the rendered-to-rendered
  comparison surfaced and fixed a real deviation (D1, share CTA copy).
  Reviewer (Iris-QC) cycle 1 recorded `Outcome: PATCH_REQUIRED`: 1 blocking
  (B1, HIGH) — an opaque `Scaffold` `backgroundColor` override at
  `invite_screen.dart:176-177` occluded the shared `CupidAppBackground`
  `--sky` gradient wash + star layer; AC1/AC2/AC4 FAIL. Mobile-dev rework
  removed the override (`forgot_screen.dart:103-106` precedent from
  STORY-032 AC1), re-captured the implemented-side render, and added 4
  screen-backdrop probe rows to the measured table. Reviewer cycle 2
  recorded `Outcome: DEFERRED_ONLY`: 0 blocking, AC1-5 all PASS,
  independently re-derived (7 self-chosen backdrop probes, 5 exact + 2 within
  1 unit of blue). 1 deferred finding (DEF-1: 6 sibling screens —
  `otp_screen.dart`, `love_contract_screen.dart`,
  `onboarding_profile_setup_screen.dart`, `permissions_screen.dart`,
  `joincode_screen.dart`, `vow_screen.dart` — carry the same opaque
  backdrop-occluding override, out of this single-screen story's scope) split
  out as `RWB-20260816-013` (requirement-level sweep, mobile lane, PENDING).
  See `STORY-037.../review/review-report.md`.
- **RWB-20260816-013 — six sibling screens carry the same opaque**
  **`Scaffold` `backgroundColor` override that occludes the shared**
  **`CupidAppBackground` sky wash (LOW). RESOLVED (2026-08-18).** Split
  out of RWB-20260816-004's Reviewer cycle-2 DEF-1 finding (also
  independently corroborated by the STORY-032/STORY-033 closing-pass D4-1
  finding above, which found 7 screens with this pattern before invite's own
  fix here brought that count down to 6). Tracked against `STORY-011` as the
  nearest anchor since the affected screens span multiple stories; user
  selected this item next via `AskUserQuestion` after STORY-045/RWB-012's
  closure. Delivered via `STORY-046_shared_backdrop_occlusion_hardening`
  (Status: DONE). All 6 overrides removed. Reviewer (Iris-QC) cycle 1
  recorded `Outcome: PATCH_REQUIRED` (BLK-1: rendered design-fidelity
  evidence — a PNG pair per screen plus `VISUAL_FIDELITY:` marker — is
  mandatory for a UI-lane story with a locked `design_source` and is not
  waivable by scope relaxation, even for a `trivial` story; BLK-2: probe-only
  evidence did not verify the content/layout-unchanged clause). Mobile-dev
  patched additively: rendered all 12 PNGs (all 6 references fresh, not
  reused) and added a decisive pre-change A/B comparison per screen against
  each screen's own prior hardening story. Reviewer cycle 2 recorded
  `Outcome: DEFERRED_ONLY`: both blocking findings resolved, 0 blocking
  remain. Two new deferred findings, out of this story's scope, split to
  `RWB-20260816-023` (DEF-2: `contract` evidence pair compares mismatched
  states) and `RWB-20260816-024` (DEF-3: `VISUAL_FIDELITY: PASS` is
  backdrop-scoped only; `joincode`'s structural deviation is the largest and
  needs triage). See `STORY-046.../review/review-report.md` and
  `rework-backlog.md`.
- **RWB-20260816-023 — STORY-046 `contract` evidence pair compares**
  **mismatched states (LOW). PENDING.** Split out of `STORY-046`'s Reviewer
  cycle-2 finding DEF-2, found by the reviewer independently opening all 12
  rendered PNGs: the implemented `contract` capture shows the
  `partnerAlreadySigned` state, the design reference shows a different,
  unsigned state — AC3's content-column `MATCH` rests on structural
  correspondence only, not a same-state comparison. Does not change
  STORY-046's own outcome (BLK-2 was independently answered by a same-screen
  pre-change A/B). See `rework-backlog.md` for exact remediation.
- **RWB-20260816-024 — STORY-046 `VISUAL_FIDELITY: PASS` is backdrop-scoped**
  **only; `joincode` structural deviation needs triage (LOW). RESOLVED**
  **(2026-08-18).** Split out of `STORY-046`'s Reviewer cycle-2 finding
  DEF-3: three undisclosed pre-existing deviations from the design
  references — `profile` (avatar/CTA text), `permissions` (notification-body
  localization), and `joincode` (single free-text field vs. the reference's
  8-char segmented cells and missing affordances — the largest of the
  three) — none moved by STORY-046's own diff, each owned by its own origin
  story (STORY-009/STORY-010/STORY-012). The missing app-bar chrome on 4
  screens is separately confirmed an approved Chrome Rules deviation, not a
  defect. User selected this item next via `AskUserQuestion` after
  STORY-046/RWB-013's closure. Opened as
  `STORY-047_pairing_chain_deviation_triage`. Product Owner triage set 5 ACs
  (AC1 profile CTA copy, AC2 permissions notification copy, AC3 joincode
  segmented entry, AC4 paste, AC5 creator cross-link); `joincode`'s 6-vs-8
  char question resolved as a design-source content error, not a real
  backend/contract mismatch, no escalation needed. Mobile implementation
  delivered and verified AC1/AC3/AC4/AC5; AC2 hit STORY-021's approved
  ADR-002 copy guard (`reminder_copy_guard_test.dart:18-22` bans literal
  `synced alarm`) — same guard/ADR conflict class already tracked in
  `REQ-004_notifications_dnd_banner_copy_reconciliation` for a different
  token. User decision 2026-08-18: fold AC2 into REQ-004 (one PO/UX ruling
  for both tokens); STORY-047 closes on AC1/AC3/AC4/AC5 only, STORY-009's
  `permissions` fix moves to REQ-004. `Iris-QC` compact-story-review
  returned `Outcome: CLEAN` (0 blocking, 0 deferred); STORY-047 marked
  `DONE`. `Quét QR` (§3d) remains an unregistered future story. See
  `rework-backlog.md` and `STORY-047.../story_master.md` for exact detail.
- **RWB-20260816-005 — STORY-014 `paired`/paired-success: zero rendered**
  **evidence either side. RESOLVED (2026-08-17).** Delivered via
  `STORY-038_paired_success_design_fidelity_hardening` (Status: DONE,
  Reviewer Iris-QC-4 `Outcome: CLEAN`, all 6 ACs PASS, no deferred
  findings). Re-verified all 15 of STORY-014's originally-claimed
  deviations against the actual rendered app; found and fixed a real
  regression (D3 couple-presence avatar cluster, 6dp box-model gap between
  Flutter's inward `Border.all` stroke and the design's content-box CSS
  sizing); D15 re-confirmed still correctly excluded. See
  `STORY-038.../review/review-report.md`.
- **RWB-20260816-006 — STORY-015 `contract`/love contract: zero rendered**
  **evidence either side. RESOLVED (2026-08-17).** Delivered via
  `STORY-039_love_contract_design_fidelity_hardening` (Status: DONE,
  Retro-Type: RED-PATCH, Fixes: STORY-015), routed through Product Owner
  (trivial/mobile single-lane scoping, explicit DEF-1/DEF-2 fold-in and
  F-1/F-2/F-3 exclude-with-reasoning scope calls; UX Designer and Tech Lead
  phases `SKIPPED:trivial`) -> mobile-dev implementation -> Reviewer
  (`compact-story-review`) pipeline. Mobile-dev captured the first-ever
  rendered evidence pair for `contract`, re-confirmed D-1 through D-13 (9 of
  13 directly rendered, 4 by widget test/structure — capture-state
  limitation), and fixed DEF-1 (clause checkbox: now a 24x24 radius-9 box
  with `--grad-hot` fill/`§N` trailing) and DEF-2 (hold-to-sign button: now
  64px `--r-card` slab with `--glow`, right-to-left dim overlay, conic-
  gradient touch puck) directly in `clause_toggle_row.dart` /
  `hold_to_sign_button.dart`. The render also caught and fixed a new
  regression, DEF-2a (dim overlay painted at zero height). Reviewer
  (Iris-QC-5) recorded `Outcome: DEFERRED_ONLY`: AC1-7 all PASS, 0 blocking;
  two real deltas deferred rather than silently dropped — incomplete AC2
  render coverage split to `RWB-20260816-014`, an unclassified clause-
  counter delta split to `RWB-20260816-015`. DEF-3/F-1/F-2/F-3/F-5
  re-confirmed out of scope, untouched. See
  `STORY-039.../review/review-report.md`.
- **RWB-20260816-014 — `contract` D-7/D-8/D-10/D-13 have no in-scope**
  **render path (LOW). PENDING.** Split out of `STORY-039`'s Reviewer finding
  V-1: those 4 D-items were re-confirmed by widget test/structure only,
  because `main_preview.dart` exposes no requester-unsigned contract fixture
  (needed to paint the add-clause row) and the design canvas only paints its
  `myUnsigned` branch (no signed/error-state reference exists at all). No
  D-item unverified or regressed — a coverage gap, not an open defect. See
  `rework-backlog.md` for exact remediation.
- **RWB-20260816-015 — `contract` clause-counter row is an unclassified**
  **app-vs-design delta (LOW). PENDING.** Split out of `STORY-039`'s Reviewer
  finding V-2: the app's `2/20 điều khoản` counter row has no design-canvas
  counterpart and was misfiled under F-5 (which is scoped to the add-clause
  copy diff only); needs an explicit Product Owner/Tech Lead disposition
  alongside the F-1/F-2/F-3 token-vs-source policy question. See
  `rework-backlog.md` for exact remediation.
- **RWB-20260816-007 — STORY-018 chat typing-ghost: zero rendered evidence**
  **either side (MEDIUM). RESOLVED.** Resolved by
  `STORY-040_chat_typing_ghost_design_fidelity_hardening` (Status: DONE,
  Reviewer Iris-QC-6 `Outcome: DEFERRED_ONLY`, AC1-8 all PASS). D2
  (ghost-toggle 44pt iOS clamp) fixed inline as AC4; N1 (render-only
  frame-boundary crash) found and fixed. D1 split to RWB-20260816-016; R-1
  (undisclosed `chat` header presence-chip delta, reviewer-found) split to
  RWB-20260816-017; N2 (shell FAB fully occludes the chat send button, a
  functional production defect) filed as
  `BUG-20260817-001_chat_fab_occludes_send_button` in the bug queue.
- **RWB-20260816-016 — `chat` missing `colorOnAccent`/inverse-text design**
  **token (LOW). PENDING.** Split out of `STORY-040`'s Product Owner scoping
  (finding D1, carried from STORY-018's own review): real in light theme
  (OQ5, out of scope), imperceptible in the audited dark theme; needs a
  `design_system/`-owned token addition. See `rework-backlog.md` for exact
  remediation.
- **RWB-20260816-017 — `chat` header missing partner pairing + presence**
  **chip (LOW). PENDING.** Surfaced by STORY-040's reviewer (R-1): design
  reference renders `Minh ↔ Linh` + a `đang online` presence chip, the
  implemented render shows `Linh` alone — pre-existing `CupidHeader`
  title-only limitation, not a STORY-040 regression, needs a
  `design_system/adaptive/`-owned avatar/presence slot. See
  `rework-backlog.md` for exact remediation.
- **RWB-20260816-008 — STORY-022 anti-ghosting settings: zero rendered**
  **evidence either side (MEDIUM). RESOLVED.** Resolved via
  `STORY-041_anti_ghosting_settings_design_fidelity_hardening` (Status: DONE,
  Reviewer Iris-QC-6 `Outcome: DEFERRED_ONLY`, AC1-7 all PASS, AC1/AC5
  PASS-with-deferral). First-ever rendered comparison via a
  `PREVIEW_ANTIGHOST=state-a|state-b` capture fixture in
  `main_preview.dart` (`anti_ghost_screen.dart` untouched); F-01..F-10
  re-confirmed against the render including both emphasis targets F-03/F-06;
  R-2 narrow-width truncation checked, no defect found. D-01/D-02/D-03/R-1/
  R-3 re-confirmed out of scope. Two real deltas split out: D-05 (undisclosed
  public-countdown penalty row) to RWB-20260816-018; RV-1 (undisclosed
  sound-penalty row label delta, reviewer-found) to RWB-20260816-019. See
  `rework-backlog.md` for exact remediation.
- **RWB-20260816-018 — `antighost` penalty card missing undisclosed**
  **"Public countdown" row (LOW). PENDING.** Split out of `STORY-041`'s
  Product Owner scoping (finding D-05, carried from STORY-022's own
  review): design source's penalty card has a third row, `Đếm ngược công
  khai` / "Public countdown" (amber tile), the app implements only two
  rows; needs a new persisted setting, backend field, and l10n keys — same
  blocker class as D-01. See `rework-backlog.md` for exact remediation.
- **RWB-20260816-019 — `antighost` sound-penalty row label mismatch**
  **(LOW). PENDING.** Found by Iris-QC-6 re-reading STORY-041's own render
  pixel-by-pixel (finding RV-1), undisclosed by either STORY-022's or
  STORY-041's own reports: design's third penalty row reads `Phát âm thanh`,
  app renders `Gây ồn`; needs an l10n string correction under
  `mobile/lib/l10n/arb/`, same blocker class as D-01/D-02/D-03. See
  `rework-backlog.md` for exact remediation.
- **RWB-20260816-009 — STORY-025 love timeline: zero rendered evidence**
  **either side (MEDIUM). RESOLVED.** Hardening story
  `STORY-042_love_timeline_design_fidelity_hardening` (Complexity: trivial,
  lane: mobile) DONE, Reviewer `CLEAN` (all 7 ACs MET, independent
  re-measurement, no blocking findings). `VISUAL_FIDELITY: PASS`, 18/20 of
  STORY-025's deviations matched as-is, 2 (#8 connector-dot fill, #19
  dashed-border rhythm/straddle) fixed. AC4 conic-ring PASS (M-2
  discharged); dashed-border FAIL-then-fixed (M-3 discharged). Residual R-1
  (entry-card +5dp, line-height metrics) folds into the existing M-4
  shared-typography carry-forward for requirement integration review.
  Closure commit `7e5ab1f`.
- **RWB-20260816-020 — `render-design-canvas.js` tooling gap (LOW,
  devops).** Split from STORY-042's own evidence capture: no `--scroll`
  flag, `--hide` selectors don't survive the screen-click re-render, so
  below-the-fold design content is uncapturable. Not blocking (diagnostic
  workaround used); see `rework-backlog.md` for exact remediation.
- **RWB-20260816-011 — STORY-028 shared expenses: zero rendered evidence**
  **either side (MEDIUM). RESOLVED.** Hardening story
  `STORY-043_shared_expenses_design_fidelity_hardening` (Complexity: trivial,
  lane: mobile) DONE, Reviewer `Iris-QC-8` round 2 `DEFERRED_ONLY` (round 1
  was `PATCH_REQUIRED` on stale iOS evidence, resolved). All 7 ACs MET; all
  32 of STORY-028's enumerated deviations re-verified against a real
  dual-platform render for the first time. Two render-only defects fixed in
  app code (date zero-padding, amount-unit spacing). M-3's inaccurate
  justification corrected directly in STORY-028's own
  `visual-fidelity-report.md`. D-1/D-2/M-1's sharpened shared-component
  descriptions split to `RWB-20260816-021`.
- **RWB-20260816-021 — Shared design-system FAB shape and iOS CTA gap**
  **(sharpened, LOW, mobile).** Split from STORY-043's round-2 review
  (D-c): `CupidAddAction` FAB resolves to a circle/pill instead of the
  design's 20px rounded square; `CupidPrimaryButton` iOS CTA gap is now
  much narrower than STORY-028 originally recorded (height/label-size
  deltas plus a missing leading glyph only); M-1 FAB overlap confirmed
  Material-only. Anchor: `mobile/lib/design_system/adaptive/**`, same
  exclusion class as RWB-012 — see `rework-backlog.md` for exact
  remediation.
- **RWB-20260816-010 — STORY-026 private gallery: `galleryOpen` state**
  **unrenderable (HIGH). RESOLVED.** Hardening story
  `STORY-044_private_gallery_design_fidelity_hardening` (Complexity:
  standard, lane: devops then mobile) DONE, Reviewer `Iris-QC-9` round 2
  `Outcome: DEFERRED_ONLY` (round 1 `PATCH_REQUIRED` on a single missing
  runtime-startup-smoke gate, closed via scrum-master waiver — zero app
  code changed; no AC ever failed). `--click` flag added to
  `render-design-canvas.js`, real `galleryOpen` reference rendered, all 10
  of STORY-026's D1-D10 deviations plus its open E2 composite-width
  question re-verified against a genuine rendered pair, `VISUAL_FIDELITY:
  PASS`, 0 in-scope deviations. D-1 (tool durability, same shape as
  still-PENDING RWB-020) and D-2 (shadow-falloff platform convention)
  carried forward as follow-ups.
- **RWB-20260816-014 — `contract` D-7/D-8/D-10/D-13 had no in-scope render
  path (LOW). RESOLVED.** Hardening story
  `STORY-049_contract_unsigned_state_render_coverage` (Complexity: trivial,
  lane: mobile) DONE, Reviewer `Iris-QC` cycle 2 `DEFERRED_ONLY` (cycle 1
  was `PATCH_REQUIRED` on a false "the design-canvas render tooling does not
  exist" premise inherited from STORY-048, corrected in this story and in
  `rework-backlog.md`). AC-1 (D-7/D-8) closed by a real rendered
  `requesterUnsigned` vs. design `myUnsigned` comparison, superseding
  STORY-039's structure-only re-confirmation. AC-2 (D-10/D-13) closed by
  disposition: D-10 now rests on the sanctioned renderer's own recorded
  output (the `mySigned` branch is structurally unreachable in the design
  source — no `hint-placeholder-val` — confirmed by three forcing `--click`
  attempts all byte-identical to the `myUnsigned` baseline); D-13 unaffected,
  independent no-design-counterpart grounds. DEF-1 (add-clause label copy
  delta) split to `RWB-20260816-025`.
- **RWB-20260816-015 — `contract` clause-counter row is an unclassified**
  **app-vs-design delta (LOW). RESOLVED (2026-08-18).** Delivered via
  `STORY-050_contract_clause_counter_disposition` (Status: DONE, Retro-Type:
  RED-PATCH, Fixes: STORY-015), Product Owner triage (no code/UX/architecture
  change) plus a narrow mobile evidence-capture addendum to satisfy the DONE
  visual-evidence gate; Reviewer (Iris-QC) `Outcome: DEFERRED_ONLY`. Two
  dispositions:
  1. **F-1/F-2/F-3 token-vs-source policy elevated to a standing**
     **REQ-002-wide policy.** Wherever an implemented screen already draws
     from a real `design_system/` token (color, type-scale, or spacing step)
     and the only divergence from the literal design-source pixel value is
     that token's scale-snap — not a missing token, not a hardcoded arbitrary
     value, not a structural/content difference — the divergence is accepted
     design-system behavior, not a fidelity defect, and does not need
     per-screen re-litigation in future REQ-002 fidelity stories. Boundary:
     does not cover missing tokens (e.g. RWB-20260816-016), hardcoded
     non-token values, or structural/layout/content deltas — those remain
     in-scope defects for their own fidelity stories. This class was flagged
     systemic by STORY-039's own reviewer: "will recur on every remaining
     REQ-002 Scope B story" (STORY-015 `review/review-report.md`, corrected
     here — STORY-050's own citation misquoted this as "Scope A screen";
     REQ-002's Scope A is the distinct STORY-001/STORY-002 pairing/navigation
     track, not the fidelity-audit track this finding actually belongs to).
  2. **CC-1 — `contract` clause-counter row (`{n}/20 điều khoản`).**
     Keep-and-exclude, confirming and re-affirming STORY-015's original A-1
     disposition rather than reopening it. Not in the design source; a
     pre-existing REQ-001 product affordance backing a real,
     backend-enforced 20-clause cap; kept and re-homed inside the
     clause-list block (`type.caption`/`colorTextMuted`). Excluded from
     STORY-015/STORY-039 AC1 fidelity comparisons, deliberately not "fixed".
     Given its own named exclusion id rather than folded into the F-series,
     which is reserved for token-vs-source findings — CC-1 is a structural
     app-only element with no design-source counterpart to snap against.

  Reviewer non-blocking finding V-1 corrected here rather than carried
  forward: STORY-050's own justification text called the F-series
  "already-gapped" — inaccurate, since F-4 is defined (STORY-015's own
  evidence-gap finding) and was separately resolved by STORY-049, not
  omitted. See `STORY-050.../review/review-report.md` and
  `rework-backlog.md`.
- **RWB-20260816-016 — `chat` missing `colorOnAccent` / inverse-text**
  **design token (LOW). RESOLVED (2026-08-18).** Delivered via
  `STORY-051_chat_inverse_text_token_hardening` (Status: DONE, Retro-Type:
  RED-PATCH, Fixes: STORY-018), Product Owner disposition: implement now —
  OQ5 gates *enabling* light theme as a user surface, not building token
  *infrastructure* for it, and the working assumption already commits to
  4-combination token infrastructure. UI/UX Designer specified `colorOnAccent`
  (dark `#F7EEFB`, verbatim `colorText` dark copy so the dark render is
  unchanged by construction; light `#FFFFFF` per the design source's literal
  intent). Tech Lead: `SKIPPED:trivial`, flagged the `ThemeExtension`
  `copyWith`/`lerp` completeness invariant. Mobile Developer added the token
  across all six `colorText` touch points and updated both consumer call
  sites. Reviewer (Iris-QC) pass 1 found a real blocking regression the story
  itself introduced (B1): the `message_bubble.dart:99` edit applied
  `colorOnAccent` unconditionally rather than guarding it on `isMine`, so the
  partner (received) bubble repainted with it too — invisible white-on-white
  text in light theme (`colorSurface`/`colorOnAccent` both `#FFFFFF`,
  1.00:1), masked in the only currently-shipping dark theme because dark
  `colorOnAccent` and `colorText` are byte-identical. Fixed with a one-line
  `isMine` guard plus a non-tautological light-theme regression test
  (revert-checked) and a correction to the evidence report's invalid
  "control region" inference. Reviewer pass 2 `Outcome: DEFERRED_ONLY` — 0
  blocking, 1 non-blocking carried finding (no explicit `Design-Screen:`
  line, substance satisfied). See `STORY-051.../review/review-report.md`
  (both passes) and `rework-backlog.md`.

## User Stories
| ID | Title | Complexity | Status | Path |
|----|-------|------------|--------|------|
| STORY-001 | App Launch / Session-Based Entry Routing Correction | standard | DONE | `STORY-001_app_launch_entry_routing/story_master.md` |
| STORY-002 | Onboarding & Pairing Flow Navigation Correction | standard | DONE | `STORY-002_onboarding_pairing_navigation/story_master.md` |
| STORY-003 | Design Fidelity — Splash | trivial | DONE | `STORY-003_splash_design_fidelity/story_master.md` |
| STORY-004 | Design Fidelity — Welcome | trivial | DONE | `STORY-004_welcome_design_fidelity/story_master.md` |
| STORY-005 | Design Fidelity — Login | trivial | DONE | `STORY-005_login_design_fidelity/story_master.md` |
| STORY-006 | Design Fidelity — Register | trivial | DONE | `STORY-006_register_design_fidelity/story_master.md` |
| STORY-007 | Design Fidelity — OTP Verification | trivial | DONE | `STORY-007_otp_design_fidelity/story_master.md` |
| STORY-008 | Design Fidelity — Forgot Password | trivial | DONE | `STORY-008_forgot_password_design_fidelity/story_master.md` |
| STORY-009 | Design Fidelity — Permissions | trivial | DONE | `STORY-009_permissions_design_fidelity/story_master.md` |
| STORY-010 | Design Fidelity — Onboarding Profile Setup | trivial | DONE | `STORY-010_onboarding_profile_design_fidelity/story_master.md` |
| STORY-011 | Design Fidelity — Invite / Create Pairing Code | trivial | DONE | `STORY-011_invite_code_design_fidelity/story_master.md` |
| STORY-012 | Design Fidelity — Join / Enter Pairing Code | trivial | DONE | `STORY-012_join_code_design_fidelity/story_master.md` |
| STORY-013 | Design Fidelity — Waiting For Pairing | trivial | DONE | `STORY-013_waiting_pairing_design_fidelity/story_master.md` |
| STORY-014 | Design Fidelity — Paired Success | trivial | DONE | `STORY-014_paired_success_design_fidelity/story_master.md` |
| STORY-015 | Design Fidelity — Love Contract | trivial | DONE | `STORY-015_love_contract_design_fidelity/story_master.md` |
| STORY-016 | Design Fidelity — Fingerprint Vow | trivial | DONE | `STORY-016_fingerprint_vow_design_fidelity/story_master.md` |
| STORY-017 | Design Fidelity — Home Dashboard | trivial | DONE | `STORY-017_home_dashboard_design_fidelity/story_master.md` |
| STORY-018 | Design Fidelity — Chat & Typing Ghost | trivial | DONE | `STORY-018_chat_typing_ghost_design_fidelity/story_master.md` |
| STORY-019 | Design Fidelity — Typing Ghost Consent/Settings | trivial | DONE | `STORY-019_typing_ghost_settings_design_fidelity/story_master.md` |
| STORY-020 | Design Fidelity — Vibe Check | trivial | DONE | `STORY-020_vibe_check_design_fidelity/story_master.md` |
| STORY-021 | Design Fidelity — Synced Reminder | trivial | DONE | `STORY-021_synced_reminder_design_fidelity/story_master.md` |
| STORY-022 | Design Fidelity — Anti-Ghosting Settings | trivial | DONE | `STORY-022_anti_ghosting_settings_design_fidelity/story_master.md` |
| STORY-023 | Design Fidelity — Zodiac Red Flag | N/A | DEFERRED | `STORY-023_zodiac_red_flag_design_fidelity/story_master.md` |
| STORY-024 | Design Fidelity — Love Pet "Bún" | trivial | DONE | `STORY-024_love_pet_design_fidelity/story_master.md` |
| STORY-025 | Design Fidelity — Love Timeline | trivial | DONE | `STORY-025_love_timeline_design_fidelity/story_master.md` |
| STORY-026 | Design Fidelity — Private Gallery | trivial | DONE | `STORY-026_private_gallery_design_fidelity/story_master.md` |
| STORY-027 | Design Fidelity — Dream Jar | trivial | DONE | `STORY-027_dream_jar_design_fidelity/story_master.md` |
| STORY-028 | Design Fidelity — Shared Expenses | trivial | DONE | `STORY-028_shared_expenses_design_fidelity/story_master.md` |
| STORY-029 | Design Fidelity — Me / Profile | trivial | DONE | `STORY-029_me_profile_design_fidelity/story_master.md` |
| STORY-030 | Design Fidelity — Privacy / My Data | trivial | DONE | `STORY-030_privacy_my_data_design_fidelity/story_master.md` |
| STORY-031 | Design Fidelity — Notifications | trivial | DONE | `STORY-031_notifications_design_fidelity/story_master.md` |
| STORY-032 | Design System — App-Shell Background, Button & Header Follow-Up | standard | DONE | `STORY-032_design_system_app_shell_follow_up/story_master.md` |
| STORY-033 | App Shell Design System Deltas | standard | DONE | `STORY-033_app_shell_design_system_deltas/story_master.md` |
| STORY-034 | Pairing Choice Canvas Addition (retro-hardening, RWB-20260816-001) | trivial | DONE | `STORY-034_pairing_choice_canvas_addition/story_master.md` |
| STORY-035 | Hardening - Welcome Screen Visual Fidelity Evidence (retro-hardening, RWB-20260816-002) | standard | DONE | `STORY-035_welcome_design_fidelity_hardening/story_master.md` |
| STORY-036 | Hardening - Register Screen Visual Fidelity Evidence (retro-hardening, RWB-20260816-003) | trivial | DONE | `STORY-036_register_design_fidelity_hardening/story_master.md` |
| STORY-037 | Hardening - Invite Screen Visual Fidelity Evidence (retro-hardening, RWB-20260816-004) | trivial | DONE | `STORY-037_invite_design_fidelity_hardening/story_master.md` |
| STORY-038 | Hardening - Paired Success Screen Visual Fidelity Evidence (retro-hardening, RWB-20260816-005) | trivial | DONE | `STORY-038_paired_success_design_fidelity_hardening/story_master.md` |
| STORY-039 | Hardening - Love Contract Screen Visual Fidelity Evidence (retro-hardening, RWB-20260816-006) | trivial | DONE | `STORY-039_love_contract_design_fidelity_hardening/story_master.md` |
| STORY-040 | Hardening - Chat & Typing Ghost Visual Fidelity Evidence (retro-hardening, RWB-20260816-007) | trivial | DONE | `STORY-040_chat_typing_ghost_design_fidelity_hardening/story_master.md` |
| STORY-041 | Hardening - Anti-Ghosting Settings Visual Fidelity Evidence (retro-hardening, RWB-20260816-008) | trivial | DONE | `STORY-041_anti_ghosting_settings_design_fidelity_hardening/story_master.md` |
| STORY-042 | Hardening - Love Timeline Visual Fidelity Evidence (retro-hardening, RWB-20260816-009) | trivial | DONE | `STORY-042_love_timeline_design_fidelity_hardening/story_master.md` |
| STORY-043 | Hardening - Shared Expenses Visual Fidelity Evidence (retro-hardening, RWB-20260816-011) | trivial | DONE | `STORY-043_shared_expenses_design_fidelity_hardening/story_master.md` |
| STORY-044 | Hardening - Private Gallery Visual Fidelity Evidence (retro-hardening, RWB-20260816-010) | standard | DONE | `STORY-044_private_gallery_design_fidelity_hardening/story_master.md` |
| STORY-045 | Hardening - Pairing Choice Surface/CTA Styling Fidelity (retro-hardening, RWB-20260816-012) | trivial | DONE | `STORY-045_pairing_choice_design_fidelity_hardening/story_master.md` |
| STORY-046 | Hardening - Shared Screen Backdrop Occlusion Fix (retro-hardening, RWB-20260816-013) | trivial | DONE | `STORY-046_shared_backdrop_occlusion_hardening/story_master.md` |
| STORY-047 | Pairing Chain Undisclosed Deviation Triage (retro-hardening, RWB-20260816-024) | trivial | DONE | `STORY-047_pairing_chain_deviation_triage/story_master.md` |
| STORY-048 | Pairing Choice Viewport Regression Hardening (retro-hardening, RWB-20260816-022) | trivial | DONE | `STORY-048_pairing_choice_viewport_regression_hardening/story_master.md` |
| STORY-049 | Contract Unsigned-State Render Coverage (retro-hardening, RWB-20260816-014) | trivial | DONE | `STORY-049_contract_unsigned_state_render_coverage/story_master.md` |
| STORY-050 | Contract Clause-Counter Row Disposition (retro-hardening, RWB-20260816-015) | trivial | DONE | `STORY-050_contract_clause_counter_disposition/story_master.md` |
| STORY-051 | Chat Inverse-Text / colorOnAccent Token Disposition (retro-hardening, RWB-20260816-016) | trivial | DONE | `STORY-051_chat_inverse_text_token_hardening/story_master.md` |
| STORY-052 | Chat Header Partner Pairing + Presence Chip (retro-hardening, RWB-20260816-017) | standard | DONE | `STORY-052_chat_header_partner_presence_hardening/story_master.md` |
| STORY-053 | Anti-Ghosting Public-Countdown Penalty Row (retro-hardening, RWB-20260816-018) | standard | RETRO_PENDING | `STORY-053_antighost_public_countdown_penalty_hardening/story_master.md` |
