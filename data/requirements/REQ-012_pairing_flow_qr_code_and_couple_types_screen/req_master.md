# Requirement Master: REQ-012 Pairing flow QR code & Couple Types screen redesign
Status: IN_PROGRESS

## Deployment Status
- Development Environment: NOT_DEPLOYED
- Staging: NOT_REQUESTED
- Production: NOT_REQUESTED

## Configuration Documentation
- Source of Truth: `deployment/configuration-guide.md`
- Status: NOT_REQUIRED
- Pending User Setup: NONE
- Last Updated:

## Source Request (verbatim, Vietnamese)
> Màn hình Chọn cách ghép đôi (Có mã / tạo mã) đã được update design mới. Hãy sửa lại.
> Ở màn Tạo mã đã có hiện QRCode, hãy xem và điều chỉnh, tương ứng bên Scan mã cũng phải xem lại vì có thêm tính năng scan QR code.
> Màn tạo mã sẽ là màn Couple Types, hãy đảm bảo đúng màn này.

## Business Intent (normalized)
The pairing method selection screen ("Có mã" / "Tạo mã" — Have a code / Create
a code) has an updated design in the design system that is not yet reflected
in the app. This requirement brings the implementation in line with the
current design, specifically:

1. Update the "Choose pairing method" screen (Have code / Create code) to
   match its new design system version.
2. Review and adjust the "Create code" screen, which now displays a QR code
   for pairing.
3. Correspondingly review/update the "Scan code" (Have code / join) screen to
   add or align QR-code scanning capability, since the create-code side now
   offers a QR code to scan.
4. Confirm and preserve that the "Create code" screen in the app is the
   Couple Types screen (couple-type selection), not a separate/different
   screen — i.e. do not diverge pairing-method screen work from the existing
   Couple Types screen identity established in prior requirements
   (see REQ-009 invite couple-type picker & pairing navigation restore).

## Known Prior Context
- REQ-009 (`data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/req_master.md`)
  previously restored the invite couple-type picker and pairing navigation
  flow. This requirement is a design-fidelity follow-up on that same flow, not
  a rebuild.
- Design source: `cupid-app-design-system/` (Cupid App design system HTML/DC
  files). The design system has recently been updated with QR-code-bearing
  screens (working tree shows local modifications to
  `cupid-app-design-system/Cupid App.dc.html`,
  `cupid-app-design-system/Cupid Screens.dc.html`, and `support.js`, plus new
  files `Cupid Email Reset Password.html` and `Cupid Email Verify.html` — the
  exact screens for THIS requirement's scope should be confirmed by Product
  Owner/UI-UX against the current design system state, not assumed from file
  names alone).

## Scope Notes For Story Splitting (Product Owner)
- Confirm the two/three screens in scope precisely: (a) pairing-method choice
  screen, (b) create-code screen showing QR code (= Couple Types screen), (c)
  scan-code / have-code screen needing QR scan capability.
- Confirm whether QR scanning is camera-based (device camera permission,
  scan-to-parse-code UX) or another mechanism, from the updated design.
- Confirm the Couple Types screen identity constraint stays intact: the
  create-code screen must remain the existing Couple Types screen, updated in
  place, not replaced by a new screen.

## User Stories
| ID | Title | Complexity | Status | Path |
|----|-------|------------|--------|------|
| STORY-001 | Pairing-method choice screen redesign | standard | PENDING | data/requirements/REQ-012_pairing_flow_qr_code_and_couple_types_screen/STORY-001_pairing_method_choice_screen_redesign/story_master.md |
| STORY-002 | Create-code (Couple Types) screen QR display | standard | PENDING | data/requirements/REQ-012_pairing_flow_qr_code_and_couple_types_screen/STORY-002_create_code_couple_types_screen_qr_display/story_master.md |
| STORY-003 | Scan-code screen QR scanning capability | complex | PENDING | data/requirements/REQ-012_pairing_flow_qr_code_and_couple_types_screen/STORY-003_scan_code_screen_qr_scanning_capability/story_master.md |
