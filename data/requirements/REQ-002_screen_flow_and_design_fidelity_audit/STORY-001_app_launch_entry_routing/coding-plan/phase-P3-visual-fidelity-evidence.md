# Phase P3 – Visual-fidelity evidence for the corrected launch chain

## 1. Objective

REQ-002 declares `ui_surface: true` with a locked `design_source`, so every
UI-bearing story must produce visual-fidelity evidence before Review. STORY-001
changes which screen the launch sequence lands on, so the evidence to produce
is a real-device capture of each of the three landing outcomes, proving the
routing is correct and that no landing screen regressed visually.

This phase is a gate, not source work. It writes no application code.

## 1A. Ownership

- Phase ID: P3
- Canonical Phase File: `phase-P3-visual-fidelity-evidence.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P2
- Parallelizable: NO
- Status: NOT_STARTED
- Write Scope:
  - `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-001_app_launch_entry_routing/visual-fidelity/` (captures + report)
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE (the capture itself boots the app)
- Risk Surfaces:
  - R6 Splash visual overlap with STORY-003
- Source Of Truth:
  - `data/devops/system/design-fidelity-config.json` (locked design source)
  - `../architecture/solution.md` ADR-2, ADR-6
  - `../ux/uiux-spec.md` Routing Decision Table
- Requirement Configuration Guide:
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: evidence capture only.
  - Split Required: NO.

## 2. Required Reads

- `../ux/uiux-spec.md` Routing Decision Table (the three outcomes to capture)
- `data/devops/system/design-fidelity-config.json`
- An existing report for format:
  `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-021_privacy_notifications_capability/visual-fidelity/visual-fidelity-report.md`

## 3. Tasks

1. Boot the real app entry point (`lib/main.dart`, not `lib/main_preview.dart`)
   on an emulator or simulator. The preview harness mounts screens directly and
   therefore cannot demonstrate entry routing — it would prove nothing about
   this story.
2. Capture each of the three launch outcomes from a genuine cold start, by
   manufacturing the corresponding real device state:
   - `implemented-launch-home-<device>.png` — valid session (AC1).
   - `implemented-launch-login-<device>.png` — previously authenticated, session
     no longer valid (AC2). Produce this by signing in, then invalidating the
     session server-side or clearing the Firebase user while leaving the
     history marker set. State in the report exactly how it was produced.
   - `implemented-launch-welcome-<device>.png` — no session, after a deliberate
     sign-out or a fresh install (AC3).
3. Capture `implemented-splash-<device>.png` during the dwell, to show the
   splash surface is unchanged apart from the removed tap-to-continue line.
4. Write `visual-fidelity/visual-fidelity-report.md`. It must state
   `VISUAL_FIDELITY: PASS` on the first line, list every capture with its
   dimensions and byte size, describe how each session state was manufactured,
   and confirm no landing screen regressed against its design reference.
5. Record explicitly that the tap-to-continue line is intentionally absent per
   ADR-6, so STORY-003 does not read it as a fidelity defect and reinstate it.

## 4. Acceptance Criteria

- Four captures exist under `visual-fidelity/`.
- `visual-fidelity/visual-fidelity-report.md` exists and records
  `VISUAL_FIDELITY: PASS`.
- Each capture is traceable to a real manufactured session state, not a mocked
  or hard-coded fixture.
- The report names the AC each capture proves.

## 5. Planned Outputs

- `visual-fidelity/implemented-launch-home-<device>.png`
- `visual-fidelity/implemented-launch-login-<device>.png`
- `visual-fidelity/implemented-launch-welcome-<device>.png`
- `visual-fidelity/implemented-splash-<device>.png`
- `visual-fidelity/visual-fidelity-report.md`

## 6. Known Execution Constraint

The bundle capture helper (`.ai-team-bundle/runtime/tools/`) is installed
runtime output and is not present in this story worktree, which contains only
tracked files. If the helper cannot be resolved, capture directly with
`adb exec-out screencap -p` (Android) or
`xcrun simctl io booted screenshot` (iOS) and say so in the report. This is an
execution note, not a blocker.

## 7. Stop Rule

If any of the three session states cannot be manufactured on the available
device, stop and report which state and why. Do not fabricate a capture, and do
not record `VISUAL_FIDELITY: PASS` for an outcome that was not actually
observed.

## 8. Status

NOT_STARTED
