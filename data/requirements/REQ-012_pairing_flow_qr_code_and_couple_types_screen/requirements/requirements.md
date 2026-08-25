# Requirement Breakdown: REQ-012 Pairing flow QR code & Couple Types screen redesign

## Source Artifacts

- Requirement master: `data/requirements/REQ-012_pairing_flow_qr_code_and_couple_types_screen/req_master.md`
- Additional input files:
  - `cupid-app-design-system/Cupid Screens.dc.html` — `isPairStart` block
    (lines 1571-1615, "Chọn cách ghép" / choose-method screen), `isInvite`
    block (lines 170-224, "Tạo mã" / create-code screen), `isJoinCode` block
    (lines 1617-1637, "Nhập mã" / join-code screen)
  - `cupid-app-design-system/Cupid App.dc.html` — screen preview nav labels
    (lines 193-195: `pairstart` = "Chọn cách ghép", `invite` = "Tạo mã",
    `joincode` = "Nhập mã")
- Existing related requirement artifacts:
  - `data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/req_master.md`
    (DONE) — locked navigation decisions for this same flow; not reopened by
    this requirement.

## Context Summary

- Request summary: the pairing-method choice screen ("Có mã" / "Tạo mã") has
  an updated design not yet reflected in the app; the create-code screen now
  shows a QR code and must remain the existing Couple Types screen; the
  scan/have-code side must be reviewed and updated for a new QR-scan
  capability since the create-code side now offers a QR code to scan.
- Primary actors: a pairing user creating an invite code (inviter) and a
  pairing user joining with a code (invitee).
- Problem to solve: the shipped pairing screens have drifted from the current
  design system state (3-option choose-method layout, QR-bearing create-code
  screen, QR-scan affordance on the join side).
- Business outcome: pairing flow visually and functionally matches the
  current design, and users sitting together can pair faster via camera QR
  scan in addition to manual code entry.
- Success signal: choose-method screen shows the 3 options from the current
  design; create-code screen (= Couple Types screen) shows the live QR + code
  + couple-type picker without regressing REQ-009's locked post-pairing
  navigation; join-code screen offers working camera QR scan alongside
  manual entry.
- Notes on current project context: this is a design-fidelity/enhancement
  follow-up on REQ-009's already-locked navigation graph for this same flow.
  REQ-009's navigation decisions are precedent, not open questions, for this
  requirement.

## Scope Decision

### In Scope

1. Redesign the pairing-method choice screen (`pairstart`, "Chọn cách ghép
   đôi") to the current design's three-option layout: create code ("Tôi tạo
   mã mời"), enter a partner's code manually ("Người ấy đã có mã"), and scan
   a partner's QR ("Quét QR trên máy họ") — matching current copy, icons, and
   layout.
2. Update the create-code screen (`invite`, "Tạo mã" — the existing Couple
   Types screen) to display the live pairing QR code and 8-character code
   exactly as in the current design, while preserving the existing
   couple-type picker ("Tụi mình thuộc kiểu nào?", 4-card grid) on the same
   screen, positioned after the code/QR per the REQ-009-locked placement.
3. Add/align a camera-based QR-code scanning capability on the join/scan-code
   screen (`joincode`, "Nhập mã" / "have code") so a user can scan their
   partner's QR to pair, alongside the existing manual code-entry UI and its
   existing "Scan QR" affordance.

### Out of Scope

- Any change to REQ-009's locked post-pairing navigation targets (invite →
  Waiting-for-partner; join-code → paired directly, not Waiting-for-partner;
  neither side → Fingerprint Vow). **Note:** the current design canvas's
  invite-screen CTA copy still reads "Continue → Fingerprint Vow" (bound to
  `goVow`) — this is a stale, unsynced element of the design source and must
  NOT be implemented. REQ-009's locked decision takes precedence over this
  literal design element; UI-UX/Tech Lead should treat the CTA's destination
  as the existing REQ-009 target, only its visual styling as in-scope here.
- The new `Cupid Email Reset Password.html` / `Cupid Email Verify.html`
  design files present in the working tree — unrelated screens, not part of
  this requirement.
- Couple-type content catalog changes (card labels/icons/copy) — already
  authored under REQ-009; only screen layout/QR-integration changes are in
  scope here.
- Fingerprint Vow screen changes.
- Redesigning the Waiting-for-partner screen itself, beyond what is needed to
  keep the existing REQ-009 navigation intact.

### Business Rules And Guardrails

- The create-code screen must remain the existing Couple Types screen,
  updated in place — never a new/separate screen (source request + REQ-009
  precedent).
- The couple-type picker stays positioned AFTER the pairing code/QR is
  already displayed on that screen (REQ-009 locked decision); this
  requirement's QR-display work must not move or precede it.
- Both "enter code manually" and "scan QR" on the join side must resolve to
  the same existing pairing/accept-invitation business capability — QR
  scanning is an additional input method for the same code, not a new
  pairing mechanism.

## Open Question Triage

### OQ1 — Exact QR-scan mechanism on the join/scan-code screen

**Status: UNRESOLVED at this level — business intent set, UX mechanism
deferred to UI-UX Designer.** The current design shows a "Scan QR"
icon/button (`qr_code_scanner`) on both the choose-method screen and the
join-code screen, but no dedicated camera-scan screen/state exists in the
design source to copy from.

- Scope Items BLOCKED: exact scan UX — full-screen camera overlay vs. inline
  scanner panel, camera-permission prompt timing/copy, and the visual
  scanning/success/failure states.
- Scope Items NOT BLOCKED: that scanning is device-camera-based (matches
  "Quét QR trên máy họ" / "Scan the QR on their phone" copy and the
  `qr_code_scanner` iconography — not a manual-image-upload or other
  mechanism); that a successful scan must feed the same accept-invitation
  capability as manual code entry; that a failed/denied-permission scan must
  fall back to the existing manual code-entry UI without dead-ending the
  user.
- Decision: proceed with STORY-003 scoped to camera-based scanning with a
  manual-entry fallback; UI-UX Designer resolves the exact screen/overlay
  mechanism and permission-prompt UX during story-level design.

### OQ2 — Does the invite-screen CTA change its destination to Fingerprint Vow?

**Decision: NO — RESOLVED by REQ-009 precedent.** REQ-009 explicitly locked
that neither the invite nor join-code side navigates to Fingerprint Vow
post-pairing (invite → Waiting-for-partner; join-code → paired). The current
design source's literal `goVow` wiring on the invite screen's continue CTA is
a stale artifact from before REQ-009's restore and must not be implemented.
Only the CTA's visual redesign (styling/layout) is in scope; its navigation
target is unchanged from REQ-009.

### OQs reviewed but not applicable to this requirement

- No entries in `data/intake/bootstrap/conflicts_open_questions.md` reference
  the pairing/QR flow; that registry is bootstrap-era and not applicable to
  this post-bootstrap requirement.

## Coverage Map

| Requirement / Need | Planned Story ID(s) | Notes |
|--------------------|---------------------|-------|
| Update "Chọn cách ghép đôi" screen to new (3-option) design | STORY-001 | pairstart screen |
| "Tạo mã" screen shows live QR code | STORY-002 | invite screen = Couple Types screen |
| Create-code screen stays the existing Couple Types screen (identity preserved) | STORY-002 | REQ-009 precedent, not reopened |
| "Scan mã" side reviewed/updated for QR-scan capability | STORY-003 | joincode screen, camera-based (OQ1) |
| REQ-009 locked post-pairing navigation stays intact | STORY-002 (guardrail) | OQ2, no story changes navigation targets |

## Recommended Story Sequence

| Story ID | Title | Complexity | Depends On | Why This Order | Observable After This Story |
|----------|-------|------------|------------|----------------|-----------------------------|
| STORY-001 | Pairing-method choice screen redesign | standard | None | Natural entry point of the flow; establishes the 3-option layout users see first | User opens the choose-pairing-method screen and sees the current design's 3-card layout (create code / enter code / scan QR) |
| STORY-002 | Create-code (Couple Types) screen QR display | standard | None | Second step in the flow; independently observable without STORY-001 or STORY-003 | User creating a pairing code sees a live QR code + 8-char code + the existing couple-type picker on the Couple Types screen, in the REQ-009-locked layout order |
| STORY-003 | Scan-code screen QR scanning capability | complex | None | Enhances the existing join-code screen; independently observable without the other two | User on the "have code" / join-code screen can scan a partner's QR with the device camera to pair, alongside existing manual entry |

No story depends on another story's delivered behavior: STORY-001's new
"scan QR" card routes to the existing join-code screen, which already
functions via manual entry today and is enhanced (not created) by STORY-003 —
so STORY-001 has standalone value even if STORY-003 ships later or in
parallel.

## Story Index

| Story ID | Title | Brief File | Primary Scope | Key AC/OQ Anchors |
|----------|-------|------------|---------------|-------------------|
| STORY-001 | Pairing-method choice screen redesign | `data/requirements/REQ-012_pairing_flow_qr_code_and_couple_types_screen/STORY-001_pairing_method_choice_screen_redesign/story_brief.md` | `pairstart` screen, 3-option layout | AC1-4 in `story_master.md` |
| STORY-002 | Create-code (Couple Types) screen QR display | `data/requirements/REQ-012_pairing_flow_qr_code_and_couple_types_screen/STORY-002_create_code_couple_types_screen_qr_display/story_brief.md` | `invite` screen QR + code + couple-type picker | AC1-5 in `story_master.md`, OQ2 |
| STORY-003 | Scan-code screen QR scanning capability | `data/requirements/REQ-012_pairing_flow_qr_code_and_couple_types_screen/STORY-003_scan_code_screen_qr_scanning_capability/story_brief.md` | `joincode` screen camera QR scan | AC1-5 in `story_master.md`, OQ1 |
