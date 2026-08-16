# Requirement Master: REQ-002 Screen Flow Correction & Design Fidelity Audit
Status: IN_PROGRESS

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
- **IF-3 — `chat` has no partner header (LOW).** Possibly fixture-dependent;
  re-check with a real paired session before routing.
- **IF-4 — `otp` backdrop flatter/darker than sibling auth screens (LOW).**
  Same design-token family as the welcome-screen backdrop defect
  (`BUG-20260816-001`); worth re-checking after that fix lands in case it
  shares a cause.
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
