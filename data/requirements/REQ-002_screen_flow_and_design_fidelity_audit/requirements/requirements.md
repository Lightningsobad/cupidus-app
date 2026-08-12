# Requirement Breakdown: REQ-002 Screen Flow Correction & Design Fidelity Audit

## Source Artifacts

- Requirement master: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/req_master.md`
- Additional input files: `data/ux/system/ui_ux_system_memory.md` (screen
  inventory §4, auth session UX patterns §11, epic-3 wording rule §6,
  DND/Critical Alerts flag §7, data sensitivity model §8, platform adaptation
  §3), `data/intake/bootstrap/conflicts_open_questions.md` (OQ5, R8)
- Existing related requirement artifacts:
  `data/requirements/REQ-001_cupid_flutter_mobile_app/` (Status: DONE — the
  shipped app this requirement audits; read-only context, not modified here)

## Context Summary

- Request summary: two independent defect/gap classes found in the
  already-shipped Cupid Flutter app: (1) app launch/inter-screen navigation
  does not match the intended flow — confirmed example: the app does not
  currently open to the login screen when it should; (2) a full re-audit of
  every current screen against the locked design source is required to reach
  100% design fidelity ("khớp 100%"), with an explicit user directive of one
  story per screen for this part.
- Primary actors: paired and unpaired Cupid app end users.
- Problem to solve: users can land on an incorrect screen on launch or
  mid-flow, and some already-shipped screens visually/behaviorally deviate
  from the locked design source.
- Business outcome: entry-point and inter-screen navigation always route
  users to the state-correct screen; every current screen matches the locked
  design source exactly.
- Success signal: the onboarding/pairing navigation chain routes correctly
  end to end, and all 29 current screens pass a 100%-match design-fidelity
  review.
- Notes on current project context: this is a new, user-initiated requirement
  opened directly against an already-DONE REQ-001. It is independent of
  REQ-001's own closed retro-audit hardening cycle (STORY-017..STORY-021,
  closed 2026-08-12) and must not assume that cycle's findings still hold —
  this is a fresh pass over current app state. REQ-001 artifacts are read-only
  input, not in scope to modify directly under this requirement.

## Scope Decision

### In Scope

- **Scope A — Screen Flow / Navigation Correction**: entry-point routing
  (splash/launch → login/welcome/home based on session state) and
  inter-screen navigation across the full onboarding/pairing chain (welcome →
  login/register → otp → forgot-password → permissions → onboarding profile
  setup → invite/join-code → waiting → paired → love contract → fingerprint
  vow → home), plus sign-out and mid-session forced-re-auth navigation
  correctness.
- **Scope B — Full Design Fidelity Audit**: design-fidelity correction
  (visual and behavioral match) for each of the 29 current MVP screens
  against the locked design source (`cupid-app-design-system`, confirmed by
  `detect_design_source.py`), covering layout, spacing, color/token usage,
  typography, iconography, and component states for the enabled runtime
  configuration (dark theme, `vi` locale).

### Out of Scope

- Any new screen, new feature, or new product decision not already present in
  the locked design source.
- Backend contract changes (backend contract remains frozen per REQ-001's A1
  assumption; if a flow or design fix appears to need one, escalate rather
  than silently implementing).
- The main in-app 5-tab bottom-navigation structure itself (home/chat/pet/
  money/me) — not reported as broken; only the onboarding/pairing chain and
  launch routing are the flagged navigation defect area. If a Scope A story's
  audit surfaces a genuine tab-navigation defect, it is handled inside that
  story's own audit scope, not assumed here.
- Enabling light theme or `en` locale for end users — still OQ5-gated
  infra-only per REQ-001 STORY-001. Scope B verifies/fixes fidelity for the
  enabled dark + `vi` configuration; shared-token-level fixes should stay
  correct for all 4 combinations since tokens are shared via
  `ThemeExtension`, but no dedicated light/`en`-only visual QA pass is added.
- Backend Socket.IO auth gap (R8, `conflicts_open_questions.md` § Decisions
  Still Needed From The User) — unrelated to this requirement's mobile UI
  scope.

### Business Rules And Guardrails

- **Entry-point routing state rule** (governs STORY-001): valid/refreshable
  session → home; previously-authenticated session now expired/invalid →
  login (fast re-auth path); no session at all (first install, or after a
  prior deliberate sign-out) → welcome (full marketing screen). Source: UX
  System Memory §11.
- Deliberate sign-out always routes to welcome, not login; a mid-session
  forced re-auth (refresh-token failure while the app is in active use)
  always routes to login, not welcome. These are two intentionally different
  forced-navigation targets (UX System Memory §11) and must not be collapsed
  into one behavior.
- **NO_CHROME / NO_TABS rule**: the entire onboarding/auth/pairing sequence
  (splash → welcome → login → register → otp → forgot → permissions →
  onboarding profile setup → invite → joincode → waiting → paired → contract
  → vow) stays chromeless and hides the bottom tab bar; the 5-tab bar appears
  only after pairing completes, on home (UX System Memory §4).
- **Epic-3 wording rule** (governs STORY-021 Synced Reminder screen, and the
  Synced-Reminder mention on STORY-031 Notifications): UI copy must use
  "nhắc nhở đồng bộ" (synced reminder), never "báo thức" / "alarm" / "Synced
  Alarm". This is a copy-only rename; the underlying dual-confirmation
  interaction (both partners confirm a time, both must swipe to dismiss) is
  correct as designed and is not redesigned. Backend/transport naming
  (`alarms` module, `TRIGGER_ALARM` event) may keep its existing name — only
  user-visible UI copy changes (UX System Memory §6).
- **Do-Not-Disturb copy conflict resolution** (governs STORY-031
  Notifications screen): the design source's raw copy claims the epic-3
  reminder "may break Do Not Disturb," which would require a Critical
  Alerts-class entitlement the app does not have and will not request for v1
  (per D1). This requirement resolves the conflict by scoping the
  DND-bypass claim OUT of v1: the Notifications screen must not state or
  imply DND-bypass behavior — standard notification priority only (UX System
  Memory §7). This is a Product Owner scope decision made directly here
  (option (a) from the UX memory's flagged recommendation), not an escalation
  to the user.
- **Level-1 (device-only) privacy lock affordance**: any screen surfacing
  Level-1 data (chat, Typing Ghost, Private Gallery) must visibly show a lock
  affordance at all times — a standing cross-screen rule for the relevant
  Scope B stories (UX System Memory §5, §8).
- **Love Pet "Bún" vector-art placeholder is confirmed correct, not a gap**:
  Lottie 4-state art is explicitly deferred in the design source's own
  "Chưa làm" list. The Scope B story for this screen audits layout/tokens/
  state fidelity only — it must not treat the missing Lottie animation as a
  fidelity defect (UX System Memory §9, §10).

## Open Question Triage

| OQ ID | Status | Scope Items BLOCKED | Scope Items NOT BLOCKED | Decision |
|-------|--------|----------------------|---------------------------|----------|
| OQ5 | RESOLVED (REQ-001 STORY-001, 2026-08-12) | Enabling light theme / `en` locale for end users | All Scope B design-fidelity fixes for the enabled dark + `vi` configuration; shared-token-level fixes that also correct light/`en` rendering | Scope B verifies/fixes the enabled dark + `vi` rendering only; no new light/`en`-only QA is added |

### OQs reviewed but not applicable to this requirement

- R8 (Backend Socket.IO auth gap) → not applicable; a backend-only security
  decision with no overlap with this requirement's mobile navigation/
  design-fidelity scope.

## Seed To Story Mapping

Not applicable — `req_master.md` carries no `## Story Seeds` table for this
requirement; it is a directly user-scoped requirement, not a discovery
output.

### Distinct user outcomes in this requirement

1. A user opening the app lands on the screen that matches their actual
   session state (STORY-001).
2. A user moving through account creation, verification, permissions,
   profile setup, and partner pairing always reaches the correct next screen
   in the intended sequence (STORY-002).
3. A user viewing each of the app's 29 current screens sees a screen that
   matches the locked design source exactly — one independently observable,
   independently deliverable outcome per screen (STORY-003..STORY-031), per
   the requirement's explicit one-story-per-screen directive for this part.

## Coverage Map

| Requirement / Need | Planned Story ID(s) | Notes |
|---|---|---|
| Entry-point routing correctness (launch → correct screen) | STORY-001 | Confirmed defect: app does not currently open to login when it should for the expired-session case |
| Onboarding/pairing inter-screen navigation correctness | STORY-002 | Full onboarding/pairing chain + sign-out/session-expiry routing |
| Design fidelity, 100% match, all 29 current screens | STORY-003..STORY-031 | One story per screen, explicit user directive; see Story Index |

## Recommended Story Sequence

| Story ID | Title | Complexity | Depends On | Why This Order | Observable After This Story |
|----------|-------|------------|------------|-----------------|-------------------------------|
| STORY-001 | App Launch / Session-Based Entry Routing Correction | standard | None | Fixes the confirmed launch-routing defect first; independent of all other stories | Opening the app from cold/terminated state always lands on the session-correct screen (home / login / welcome) |
| STORY-002 | Onboarding & Pairing Flow Navigation Correction | standard | None | Distinct workflow area (post-entry chain) from STORY-001's cold-launch decision; independently testable starting from welcome/login | Every screen in the onboarding/pairing chain leads to its correct next screen; sign-out and mid-session re-auth route to the correct distinct targets |
| STORY-003 | Design Fidelity — Splash | trivial | None | Independent per-screen fidelity fix | Splash screen renders exactly per the locked design source |
| STORY-004 | Design Fidelity — Welcome | trivial | None | Independent per-screen fidelity fix | Welcome screen renders exactly per the locked design source |
| STORY-005 | Design Fidelity — Login | trivial | None | Independent per-screen fidelity fix | Login screen renders exactly per the locked design source |
| STORY-006 | Design Fidelity — Register | trivial | None | Independent per-screen fidelity fix | Register screen renders exactly per the locked design source |
| STORY-007 | Design Fidelity — OTP Verification | trivial | None | Independent per-screen fidelity fix | OTP screen renders exactly per the locked design source |
| STORY-008 | Design Fidelity — Forgot Password | trivial | None | Independent per-screen fidelity fix | Forgot-password screen renders exactly per the locked design source |
| STORY-009 | Design Fidelity — Permissions | trivial | None | Independent per-screen fidelity fix | Permissions screen renders exactly per the locked design source |
| STORY-010 | Design Fidelity — Onboarding Profile Setup | trivial | None | Independent per-screen fidelity fix | Onboarding profile-setup screen renders exactly per the locked design source |
| STORY-011 | Design Fidelity — Invite / Create Pairing Code | trivial | None | Independent per-screen fidelity fix | Invite/create-code screen renders exactly per the locked design source |
| STORY-012 | Design Fidelity — Join / Enter Pairing Code | trivial | None | Independent per-screen fidelity fix | Join/enter-code screen renders exactly per the locked design source |
| STORY-013 | Design Fidelity — Waiting For Pairing | trivial | None | Independent per-screen fidelity fix | Waiting screen renders exactly per the locked design source |
| STORY-014 | Design Fidelity — Paired Success | trivial | None | Independent per-screen fidelity fix | Paired-success screen renders exactly per the locked design source |
| STORY-015 | Design Fidelity — Love Contract | trivial | None | Independent per-screen fidelity fix | Love Contract screen renders exactly per the locked design source |
| STORY-016 | Design Fidelity — Fingerprint Vow | trivial | None | Independent per-screen fidelity fix | Fingerprint Vow screen renders exactly per the locked design source |
| STORY-017 | Design Fidelity — Home Dashboard | trivial | None | Independent per-screen fidelity fix | Home dashboard renders exactly per the locked design source |
| STORY-018 | Design Fidelity — Chat & Typing Ghost | trivial | None | Independent per-screen fidelity fix | Chat screen renders exactly per the locked design source |
| STORY-019 | Design Fidelity — Typing Ghost Consent/Settings | trivial | None | Independent per-screen fidelity fix | Typing Ghost settings screen renders exactly per the locked design source |
| STORY-020 | Design Fidelity — Vibe Check | trivial | None | Independent per-screen fidelity fix | Vibe Check screen renders exactly per the locked design source |
| STORY-021 | Design Fidelity — Synced Reminder | trivial | None | Independent per-screen fidelity fix; also applies §6 wording rule | Synced Reminder screen renders exactly per design source and uses correct wording |
| STORY-022 | Design Fidelity — Anti-Ghosting Settings | trivial | None | Independent per-screen fidelity fix | Anti-Ghosting settings screen renders exactly per the locked design source |
| STORY-023 | Design Fidelity — Zodiac Red Flag | trivial | None | Independent per-screen fidelity fix | Zodiac Red Flag screen renders exactly per the locked design source |
| STORY-024 | Design Fidelity — Love Pet "Bún" | trivial | None | Independent per-screen fidelity fix | Love Pet screen renders exactly per the locked design source |
| STORY-025 | Design Fidelity — Love Timeline | trivial | None | Independent per-screen fidelity fix | Love Timeline screen renders exactly per the locked design source |
| STORY-026 | Design Fidelity — Private Gallery | trivial | None | Independent per-screen fidelity fix | Private Gallery screen renders exactly per the locked design source |
| STORY-027 | Design Fidelity — Dream Jar | trivial | None | Independent per-screen fidelity fix | Dream Jar screen renders exactly per the locked design source |
| STORY-028 | Design Fidelity — Shared Expenses | trivial | None | Independent per-screen fidelity fix | Shared Expenses screen renders exactly per the locked design source |
| STORY-029 | Design Fidelity — Me / Profile | trivial | None | Independent per-screen fidelity fix | Me/Profile screen renders exactly per the locked design source |
| STORY-030 | Design Fidelity — Privacy / My Data | trivial | None | Independent per-screen fidelity fix | Privacy/My Data screen renders exactly per the locked design source |
| STORY-031 | Design Fidelity — Notifications | trivial | None | Independent per-screen fidelity fix; also resolves §7 DND copy conflict | Notifications screen renders exactly per the locked design source with no DND-bypass claim |

## Story Index

> Full story-specific context lives in each story's
> `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/<STORY>/story_brief.md`.

| Story ID | Title | Brief File | Primary Scope | Key AC/OQ Anchors |
|----------|-------|------------|-----------------|-----------------------|
| STORY-001 | App Launch / Session-Based Entry Routing Correction | `STORY-001_app_launch_entry_routing/story_brief.md` | Scope A | Splash-as-auth-check-gate rule, UX Memory §11 |
| STORY-002 | Onboarding & Pairing Flow Navigation Correction | `STORY-002_onboarding_pairing_navigation/story_brief.md` | Scope A | NO_CHROME/NO_TABS chain, sign-out vs re-auth targets, UX Memory §4, §11 |
| STORY-003 | Design Fidelity — Splash | `STORY-003_splash_design_fidelity/story_brief.md` | Scope B | Epic 1, NO_CHROME/NO_TABS |
| STORY-004 | Design Fidelity — Welcome | `STORY-004_welcome_design_fidelity/story_brief.md` | Scope B | Epic 1, NO_CHROME/NO_TABS |
| STORY-005 | Design Fidelity — Login | `STORY-005_login_design_fidelity/story_brief.md` | Scope B | Epic 1, NO_CHROME/NO_TABS |
| STORY-006 | Design Fidelity — Register | `STORY-006_register_design_fidelity/story_brief.md` | Scope B | Epic 1, NO_CHROME/NO_TABS |
| STORY-007 | Design Fidelity — OTP Verification | `STORY-007_otp_design_fidelity/story_brief.md` | Scope B | Epic 1, NO_CHROME/NO_TABS |
| STORY-008 | Design Fidelity — Forgot Password | `STORY-008_forgot_password_design_fidelity/story_brief.md` | Scope B | Epic 1, NO_CHROME/NO_TABS |
| STORY-009 | Design Fidelity — Permissions | `STORY-009_permissions_design_fidelity/story_brief.md` | Scope B | Epic 1, NO_CHROME/NO_TABS |
| STORY-010 | Design Fidelity — Onboarding Profile Setup | `STORY-010_onboarding_profile_design_fidelity/story_brief.md` | Scope B | Epic 1, NO_CHROME/NO_TABS |
| STORY-011 | Design Fidelity — Invite / Create Pairing Code | `STORY-011_invite_code_design_fidelity/story_brief.md` | Scope B | Epic 1, NO_CHROME/NO_TABS |
| STORY-012 | Design Fidelity — Join / Enter Pairing Code | `STORY-012_join_code_design_fidelity/story_brief.md` | Scope B | Epic 1, NO_CHROME/NO_TABS |
| STORY-013 | Design Fidelity — Waiting For Pairing | `STORY-013_waiting_pairing_design_fidelity/story_brief.md` | Scope B | Epic 1, NO_CHROME/NO_TABS |
| STORY-014 | Design Fidelity — Paired Success | `STORY-014_paired_success_design_fidelity/story_brief.md` | Scope B | Epic 1, NO_CHROME/NO_TABS |
| STORY-015 | Design Fidelity — Love Contract | `STORY-015_love_contract_design_fidelity/story_brief.md` | Scope B | Epic 1, NO_CHROME/NO_TABS, dual-confirmation ritual |
| STORY-016 | Design Fidelity — Fingerprint Vow | `STORY-016_fingerprint_vow_design_fidelity/story_brief.md` | Scope B | Epic 1, NO_CHROME/NO_TABS, dual-confirmation gesture |
| STORY-017 | Design Fidelity — Home Dashboard | `STORY-017_home_dashboard_design_fidelity/story_brief.md` | Scope B | Epic 2, 5-tab chrome |
| STORY-018 | Design Fidelity — Chat & Typing Ghost | `STORY-018_chat_typing_ghost_design_fidelity/story_brief.md` | Scope B | Epic 2, Level-1 lock affordance §5/§8 |
| STORY-019 | Design Fidelity — Typing Ghost Consent/Settings | `STORY-019_typing_ghost_settings_design_fidelity/story_brief.md` | Scope B | Epic 2, Level-1 lock affordance §5/§8 |
| STORY-020 | Design Fidelity — Vibe Check | `STORY-020_vibe_check_design_fidelity/story_brief.md` | Scope B | Epic 3 |
| STORY-021 | Design Fidelity — Synced Reminder | `STORY-021_synced_reminder_design_fidelity/story_brief.md` | Scope B | Epic 3, wording rule §6 |
| STORY-022 | Design Fidelity — Anti-Ghosting Settings | `STORY-022_anti_ghosting_settings_design_fidelity/story_brief.md` | Scope B | Epic 3 |
| STORY-023 | Design Fidelity — Zodiac Red Flag | `STORY-023_zodiac_red_flag_design_fidelity/story_brief.md` | Scope B | Epic 3, custom zodiac icon set §2 |
| STORY-024 | Design Fidelity — Love Pet "Bún" | `STORY-024_love_pet_design_fidelity/story_brief.md` | Scope B | Epic 4, Lottie deferred §9/§10 |
| STORY-025 | Design Fidelity — Love Timeline | `STORY-025_love_timeline_design_fidelity/story_brief.md` | Scope B | Epic 4 |
| STORY-026 | Design Fidelity — Private Gallery | `STORY-026_private_gallery_design_fidelity/story_brief.md` | Scope B | Epic 4, Level-1 lock affordance §5/§8 |
| STORY-027 | Design Fidelity — Dream Jar | `STORY-027_dream_jar_design_fidelity/story_brief.md` | Scope B | Epic 5 |
| STORY-028 | Design Fidelity — Shared Expenses | `STORY-028_shared_expenses_design_fidelity/story_brief.md` | Scope B | Epic 5, platform-adaptive FAB/CTA precedent §3 |
| STORY-029 | Design Fidelity — Me / Profile | `STORY-029_me_profile_design_fidelity/story_brief.md` | Scope B | Epic 6, 5-tab chrome |
| STORY-030 | Design Fidelity — Privacy / My Data | `STORY-030_privacy_my_data_design_fidelity/story_brief.md` | Scope B | Epic 6, 3-tier sensitivity model §8 |
| STORY-031 | Design Fidelity — Notifications | `STORY-031_notifications_design_fidelity/story_brief.md` | Scope B | Epic 6, DND copy conflict §7 |

INTEGRATION_VERIFICATION_REQUIRED: NO

All 31 stories are isolated. STORY-001 and STORY-002 split the flow-correction
scope by workflow area (cold-launch entry decision vs. the onboarding/pairing
chain) and are each independently testable without the other. The 29 Scope B
stories are per-screen visual/behavioral fidelity fixes, entirely independent
of each other and of Scope A — no runtime interaction between stories exists
that per-story implementation testing plus the Reviewer visual-fidelity gate
cannot already cover.
