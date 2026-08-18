# Story Master: STORY-046 Hardening - Shared Screen Backdrop Occlusion Fix

Status: DONE
Complexity: trivial
Story-Class: standard
Implementation Lane: mobile
Requirement: REQ-002
Retro-Type: RED-PATCH
Fixes: STORY-007_otp_design_fidelity, STORY-009_permissions_design_fidelity, STORY-010_onboarding_profile_design_fidelity, STORY-012_join_code_design_fidelity, STORY-015_love_contract_design_fidelity, STORY-016_fingerprint_vow_design_fidelity
Scope: Retro-hardening (RWB-20260816-013)
Screens: OTP Verification (`otp_screen.dart`), Love Contract (`love_contract_screen.dart`),
Onboarding Profile Setup (`onboarding_profile_setup_screen.dart`), Permissions
(`permissions_screen.dart`), Join/Enter Pairing Code (`joincode_screen.dart`),
Fingerprint Vow (`vow_screen.dart`) — 6 sibling screens, one shared defect pattern
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`).
Design-Screen: otp, contract, profile, permissions, joincode, vow
All 6 references were rendered fresh from the locked canvas for this story
rather than reused (`render-design-canvas.js --entry="Cupid App.dc.html"`), so
no pair depends on a prior story's render. This also settles the reviewer's
DEF-1: `STORY-015_love_contract_design_fidelity/visual-fidelity/` holds no PNG,
so `contract` had no reusable reference to inherit.

## Artifacts
- [x] Requirements (Product Owner) — `requirements/requirements.md`
- [x] UX Design (UI/UX Designer) — SKIPPED:trivial
- [x] Architecture (Tech Lead) — SKIPPED:trivial
- [x] Implementation (Development) — `visual-fidelity/visual-fidelity-report.md`
- [x] Review (Reviewer) — `review/review-report.md` (cycle 2, `Outcome: DEFERRED_ONLY`)

## Background (Rework Item)
`data/retro-audit/rework-backlog.md` item RWB-20260816-013 (source:
`STORY-037_invite_design_fidelity_hardening`'s reviewer, `review/review-report.md`
cycle 2, finding DEF-1) — read directly, not re-derived, before this story is
scoped.

STORY-032 AC1 removed an opaque `backgroundColor: colors.colorBackground`
`Scaffold` override from `forgot_screen.dart` so the shared
`CupidAppBackground` `--sky` gradient wash (mounted once at
`cupid_app.dart:59`) is not occluded — but that fix was never swept to the
override's remaining call sites. The same opaque override still exists on 6
other screens, each of which occludes the same shared backdrop layer on its
own screen:

1. `mobile/lib/features/auth/presentation/screens/otp_screen.dart:79`
2. `mobile/lib/features/love_contracts/presentation/screens/love_contract_screen.dart:109`
3. `mobile/lib/features/onboarding/presentation/screens/onboarding_profile_setup_screen.dart:85`
4. `mobile/lib/features/onboarding/presentation/screens/permissions_screen.dart:107`
5. `mobile/lib/features/pairing/presentation/screens/joincode_screen.dart:125`
6. `mobile/lib/features/vow/presentation/screens/vow_screen.dart:169`

(Path correction, applied 2026-08-18 by Product Owner/Scrum Master: only
`joincode_screen.dart` actually lives under
`mobile/lib/features/pairing/presentation/screens/`; the other 5 files live
in their own feature directories as corrected above. All 6 line numbers were
independently confirmed correct by direct read/grep. See
`requirements/requirements.md` `## In Scope` item 1 for the authoritative
per-screen path list.)

Classification: pre-existing gap, not introduced or worsened by STORY-037 —
STORY-037 only made it visible by adding the first-ever screen-backdrop probe
to a REQ-002 evidence report. Out of STORY-037's own single-screen scope.

Exact remediation needed: route to the `mobile` lane to remove the
`backgroundColor:` override on each of the 6 screens above, following the
`forgot_screen.dart:103-106` precedent comment, then verify with a rendered
evidence pair (or at minimum a screen-backdrop probe) per screen that the
shared `--sky` wash is no longer occluded.

Carry-forward note (from STORY-045's reviewer, Iris-QC-10, RWB-20260816-012
closure): STORY-045 found that 2 of that item's 4 originally-reported
deviations were never real defects — they were measurement artifacts of a
stale, mis-scaled STORY-002-era screenshot. This item's defect pattern (an
opaque `backgroundColor:` override, verifiable directly in source, not a
subtle pixel-measurement delta) is a different, code-structural class of
finding and is not expected to share that risk — but Product Owner should
still confirm each of the 6 screens' existing design-reference renders are
current before scoping ACs off them.

Product Owner should confirm Complexity/Story-Class and Implementation Lane
accordingly (likely `standard`/`mobile` single-lane given 6 screens/6 files,
one mechanical pattern, no new screen/flow/persistence/integration surface).

Exact remediation steps: see `rework-backlog.md` RWB-20260816-013 detail
section and STORY-037's own `review/review-report.md` finding DEF-1 (already
read, do not re-derive).
