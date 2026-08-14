# Story Master: STORY-007 Design Fidelity — OTP Verification

Status: IN_REVIEW
Complexity: trivial
Story-Class: trivial
Implementation Lane: mobile
Requirement: REQ-002
Scope: B (Full Design Fidelity Audit)
Screen: otp, Epic 1 (Core connection / onboarding), NO_CHROME / NO_TABS
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`)
Design-Screen: otp

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — SKIPPED:trivial
- [x] Architecture (Tech Lead) — SKIPPED:trivial
- [x] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- NONE. Independent of every other Scope A/Scope B story; runs as part of
  the story-level-parallel wave for REQ-002 Scope B.

## User Story
As a user verifying an OTP code, I want the screen to match the locked
design source exactly, so the app feels visually consistent and trustworthy
during verification.

## In Scope
1. Re-audit the current otp screen (chromeless, no tab bar) against
   `cupid-app-design-system` for the enabled dark theme + `vi` locale
   configuration: code-input component styling, resend-timer/countdown
   treatment, spacing, color/design-token usage, and typography (mono for
   the code input per §2 if specified in the source).
2. Correct every deviation found directly in the app code so the rendered
   screen matches the design source exactly — this is a fix, not an audit
   report.
3. Audit component states present in the design source (empty input,
   partially entered, error/invalid code, resend-available vs.
   resend-cooldown) for token/style fidelity.

## Out of Scope
- Where otp navigates to after success/failure — Scope A
  (STORY-001/STORY-002) owns inter-screen navigation correctness.
- Any new feature, new screen state, or new interaction not already present
  in the locked design source.
- Light theme / `en` locale user-facing visual QA (OQ5 — infra-only, not
  enabled for users yet); token-level fixes should stay correct for all 4
  combinations since tokens are shared, but no dedicated light/`en` visual
  pass is required.

## Acceptance Criteria
1. Given the otp screen rendered in the enabled dark theme + `vi` locale,
   when compared against `cupid-app-design-system`'s corresponding screen,
   then layout, spacing, color/token usage, and typography match exactly
   with no visible deviation.
2. Given any deviation was found during this story's audit, when the story
   is delivered, then the deviation is corrected in the rendered app (not
   merely documented) and re-verified against the design source.
3. Given each code-input/resend-timer state present in the design source
   (empty, partial, error/invalid, resend-available, resend-cooldown), when
   rendered, then each state's styling matches the design source exactly.
4. Given the screen is reached through its existing normal navigation path,
   when a user arrives at it, then no new entry point is required — this
   story does not change how the screen is reached.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the current otp screen, already reachable
  in the shipped app.
- Direct URL only acceptable: N/A — existing reachable screen, not new.

## Dependencies
- Depends on: NONE.
- Must not require any future story: confirmed.

## Open Question Impact
OQ5 (light theme / `en` locale) only affects out-of-scope light/`en`
user-facing visual QA per this story's Out of Scope section; it does not
block any in-scope acceptance criterion.

### Scope Items BLOCKED in this story
- None.

### Scope Items NOT BLOCKED in this story
- All acceptance criteria (1-4) are unblocked.

## Implementation Notes (mobile-dev)

The premise in `## System Integration And Discoverability` was false: no otp
screen existed in `mobile/lib`. `otp` was listed in `main_preview.dart`'s
`_notImplementedCanvasIds`, and REQ-001 `req_master.md` §7 records it as one of
ten canvas screens under an approved scope cut (STORY-018 OQ-1).

Delivered rather than blocked, following REQ-002 STORY-009 (`permissions`, same
scope-cut list, built from scratch and marked DONE). `OtpScreen` is
presentational and preview-only — no route, no navigation entry point, no
backend call — which satisfies AC4. `onVerify`/`onResend` are callbacks left for
the story that owns the `register -> otp -> permissions` flow.

Delivered:
- `mobile/lib/features/auth/presentation/screens/otp_screen.dart` (new)
- `mobile/test/features/auth/otp_screen_test.dart` (new, 9 tests)
- `mobile/lib/main_preview.dart` (registered `otp`, removed it from
  `_notImplementedCanvasIds`)
- `visual-fidelity/visual-fidelity-report.md` plus the two compared PNGs

`VISUAL_FIDELITY: FAIL`. Every delta inside this story's own surface is fixed.
Two visible deltas remain, both in shared chrome inherited by every screen and
deferred with named owners in the report: `CupidHeader`'s back arrow is white
where the design paints it pink, and the app shell does not paint the design's
`--sky` gradient background.

AC3 caveat: the design source composes no error/invalid OTP state, so none was
invented. The resend-available state is an explicit extrapolation from the
canvas's own inline-action idiom and should be confirmed by ui-ux-designer.

Note for Scrum Master: `permissions_screen.dart:80-81` ships the forbidden
string `Synced Alarm`, failing `reminder_copy_guard_test.dart` at BaseHead
`4eadb3d`. Pre-existing merged work, not this story; worth a queued bug.

### Build gate: BLOCKED on pre-existing red (read this before reviewing)

The mobile lane closed BLOCKED, not complete. The story's own gate is green:

- `flutter analyze --no-fatal-infos lib/features/auth lib/main_preview.dart test/features/auth` — PASS
- `flutter test test/features/auth/otp_screen_test.dart test/design_system/adaptive_widgets_test.dart` — PASS 21/21
- `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=otp` — PASS

The blocker is `no_fork_guard_test.dart`, already red at BaseHead `4eadb3d` on
files this story does not touch. Three violations (`Colors.white`,
`Color(0xFFFFFFFF)`) are mechanical token swaps, but four are
`Colors.transparent` and have no in-scope fix: the guard
(`no_fork_guard_test.dart:18-23`) is a blunt substring match with no allowlist,
so `Colors.` catches `Colors.transparent` and `Color(0x` catches the equivalent
`Color(0x00000000)`. Clearing them requires either a transparent token in
`CupidColorTokens` or an allowlist in the guard — a tech-lead/design-system
decision, and one that would collide with STORY-032, whose ACTIVE write scope
already covers `design_system.dart` and `cupid_theme.dart`.

Not fixed from this story deliberately. Reviewer: judge this branch on the
scoped gate above; the guard red is not a regression introduced here.
