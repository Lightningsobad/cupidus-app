# Story Master: STORY-003 Scan-Code Screen QR Scanning Capability

Status: DONE
Complexity: complex
Story-Class: standard
Implementation Lane: shared
Requirement: REQ-012
Screen: Join/scan-code screen ("Nhập mã của người ấy" / "Enter their code")
Design reference: `cupid-app-design-system/Cupid Screens.dc.html` lines
1617-1637 (`isJoinCode` block: 6-box code display, Paste + "Quét QR"/"Scan
QR" action row, pair-up CTA, "I am the one with the code" switch link) plus
lines 1682-1743, added by `Pink-Designer` per explicit user authorization
(2026-08-26) to close the original design-source gap for the scan-overlay
states (`isScanLive` 1682-1694, `isScanInvalid` 1696-1709, `isScanDenied`
1711-1720, `isScanBlocked` 1722-1732, `isScanUnavailable` 1734-1743).
Final visual-fidelity verdict: `visual-fidelity/visual-fidelity-report.md`
`VISUAL_FIDELITY: PASS` / `OPEN_OBSERVATIONS: VF-7` after the VF-1..VF-6
rework (scan-line animation, helper-copy layout, invalid-card width/dimming,
message typography, CTA width) landed in commit `bb089dc84f`. VF-7 (State 4
message weight) accepted as deferred, non-blocking (DF-5 in
`review/review-report.md` §6/§11.5).

## Artifacts
- [x] Requirements (Product Owner) — this file
- [x] UX Design (UI/UX Designer) — `ux/ux-spec.md`
- [x] Architecture (Tech Lead) — `architecture/solution.md`, `coding-plan/`
- [x] Implementation (Development) — mobile-dev (Alex-Mobile-Dev-4, then
      Alex-Mobile-Dev-3 for the VF-1..VF-6 rework) landed P1-P4
      (camera-permission foundation, scan/decode logic, scan-screen states,
      entry point + preview wiring), AC1-5 implemented, widget tests green
      (+223), `flutter analyze` at the unchanged 8-info baseline. Story
      Runtime Startup Smoke: PASS, run directly by Scrum Master per
      `coding-plan/master-plan.md` §4 (mobile-dev is guard-blocked from
      emulator/device runtime work in ordinary continue); see
      `coding-plan/test-results.md` "## Story Runtime Startup Smoke".
      Committed as `bb089dc84f` on top of BaseHead `ea58d0f`.
- [x] Review (Reviewer) — `review/review-report.md` `Outcome: CLEAN` (original
      final-synthesis pass) plus §11 rework re-review `Outcome: CLEAN`
      (2026-08-26, `RUN-...-reviewer-rework2`), independently re-verifying
      VF-1..VF-6 and recording VF-7 as DF-5. 0 blocking findings. Deferred
      carried: DF-2, DF-4, DF-5. Unverified: UV-1.

## Depends On
- NONE.

## User Story
As a user who has a partner's pairing code, I want to scan their QR code
with my device camera instead of typing the code by hand, so pairing is
faster when we're sitting together.

## In Scope
1. Wire the existing "Quét QR" / "Scan QR" action on the join-code screen to
   a real device-camera QR scan capability (currently a static icon/label
   with no scan behavior behind it).
2. Request camera permission at the point the user initiates a scan; handle
   the granted, denied, and "don't ask again" outcomes without dead-ending
   the user — denied/unavailable camera must fall back cleanly to the
   existing manual code-entry UI already on this screen.
3. On a successful scan, parse the encoded pairing code and feed it into the
   same accept-invitation/pairing capability already used by manual code
   entry — a scanned code must produce an identical pairing outcome to a
   typed code.
4. Handle an invalid/unreadable/expired scanned code with a clear, non-
   fabricated error state, offering retry-scan or fall back to manual entry.
5. Preserve the existing manual 6/8-character code-entry UI, Paste action,
   and the "I am the one with the code" switch link unchanged.

## Out of Scope
- The pairing-method choice screen's routing into this screen (STORY-001).
- The create-code screen's QR generation (STORY-002) — this story only
  consumes/scans a QR, it does not produce one.
- Exact scan-screen visual mechanism (full-screen overlay vs. inline panel)
  and permission-prompt copy/timing — resolved by UI-UX Designer per OQ1 in
  `requirements/requirements.md`, not fixed by this breakdown.
- Any change to post-pairing navigation targets (REQ-009 locked; not
  reopened by this requirement).

## Acceptance Criteria
1. Given a user on the join-code screen taps "Scan QR", when camera
   permission has not yet been decided, then the system requests it, and
   proceeding is possible only after permission is granted.
2. Given camera permission is granted and the user points the camera at a
   valid partner pairing QR, when the code is recognized, then the same
   pairing/accept-invitation flow used for manually typed codes completes,
   producing an identical pairing outcome.
3. Given camera permission is denied or unavailable, when the user attempts
   to scan, then they see a clear message and can fall back to the existing
   manual code-entry UI on the same screen without being blocked from
   pairing.
4. Given a scanned QR does not decode to a valid/current pairing code
   (invalid, malformed, or expired), when this is detected, then the user
   sees an honest error state (not a fabricated success) and can retry
   scanning or switch to manual entry.
5. Given the scan-capable screen renders in the enabled dark theme + `vi`
   locale, when compared against `cupid-app-design-system`'s corresponding
   screen and the resolved UI-UX scan-mechanism spec, then layout, spacing,
   color/token usage, and typography match.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: YES — the existing join-code screen; the
  "Scan QR" affordance already exists visually but has no behavior behind it
  today.
- Direct URL only acceptable: NO — reached via the existing pairing-method
  choice screen and the existing "I am the one with the code" switch link.

## Dependencies
- Depends on: NONE.
- Must not require any future story: confirmed — this story enhances an
  existing, already-reachable screen; it does not require STORY-001's or
  STORY-002's delivery order.

## Open Question Impact

### OQs affecting this story

| OQ ID | Status | Scope Items BLOCKED | Scope Items NOT BLOCKED | Decision |
|-------|--------|---------------------|------------------------|----------|
| OQ1 | RESOLVED (see `ux/ux-spec.md`) | Exact scan-screen visual mechanism, camera-permission prompt copy/timing | Camera-based scanning as the mechanism; scanned code reuses the manual accept-invitation flow; permission-denied fallback to manual entry | Resolved: full-screen camera overlay (not inline panel); permission requested at tap time, no earlier soft-ask screen. Full state machine (opening, live scan, recognized, invalid/expired, denied, permanently denied, unavailable) in `ux/ux-spec.md`. |

### Scope Items BLOCKED in this story

- Exact scan-screen visual mechanism (full-screen camera overlay vs. inline
  scanner panel) and camera-permission prompt copy/timing.

### Scope Items NOT BLOCKED in this story

- That scanning is device-camera-based.
- That a successful scan must produce an identical pairing outcome to manual
  entry.
- That a denied/failed scan must fall back to the existing manual entry UI.

### Scope decisions driven by OQs

- OQ1 UNRESOLVED → the pixel-level scan screen/overlay design is deferred to
  UI-UX Designer. The functional behavior (camera-based, shared
  accept-invitation outcome, honest error/fallback states) is NOT blocked
  and is fixed by AC1-4 above.

### OQs not applicable to this story

- OQ2: invite-screen CTA destination → not applicable, this story does not
  touch the create-code screen or post-pairing navigation.
