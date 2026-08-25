# Story Master: STORY-001 Pairing-Method Choice Screen Redesign

Status: PENDING
Complexity: standard
Story-Class: standard
Implementation Lane: shared
Requirement: REQ-012
Screen: Pairing-method choice screen ("Chọn cách ghép đôi" / "How do you want
to pair?")
Design reference: `cupid-app-design-system/Cupid Screens.dc.html` lines
1571-1615 (`isPairStart` block: header, 3 selectable rows — create code,
enter code manually, scan QR — plus the privacy note and "later" link)
Design-Screen: pairstart (resolved by mobile-dev rework; `render-design-canvas.js
--list-screens` has no `pairingchoice` id — `pairstart` is the correct canvas
id for this block, confirmed against `ux-spec.md:3` and the rendered PNG)
Design-Surface: cupid-app

## Artifacts
- [x] Requirements (Product Owner) — this file
- [x] UX Design (UI/UX Designer)
- [x] Architecture (Tech Lead)
- [ ] Implementation (Development) — commit `8c203dba543bae1b678338bfbab896df4203a9d2`
      (mobile-dev, Alex-Mobile-Dev) landed AC1-AC3 and an in-scope fix for
      BUG-20260825-002 via additive `CupidColorTokens.colorGlowCore`; rework
      commit `0b5efe157394426b439c4f80e04973c50bbeb898` closed F1 (visual-
      fidelity report, VISUAL_FIDELITY FAIL accepted DEFERRED — sole cause is
      D-1, the escape-link Product Owner decision, non-regressive and not
      fixable by mobile-dev), F2 (Design-Screen resolved `pairstart`), and F3
      (Entry Point Reachability section). F4 (Story Runtime Startup Smoke) is
      now closed too — run directly by Scrum Master (mobile-dev is guard-
      blocked from device runtime work in ordinary continue); see
      `coding-plan/test-results.md` "## Story Runtime Startup Smoke", PASS.
      Reviewer pass-2 confirmed F1-F3 CLEARED with only F4 remaining; F4 is
      now closed. Re-check this box after Reviewer confirms F4 in a fresh
      pass.
- [ ] Review (Reviewer) — pass 2 PATCH_REQUIRED (sole blocker was F4, now
      closed — see `review/review-report.md` and Implementation note above)

## Depends On
- NONE.

## User Story
As a user starting the pairing flow, I want the "how do you want to pair"
screen to show all three current pairing options — create a code, enter a
partner's code, or scan a partner's QR — matching the current design, so I
can immediately pick the fastest method for my situation.

## In Scope
1. Update the pairing-method choice screen layout, copy, and iconography to
   match the current design source's three-row layout:
   - "Tôi tạo mã mời" / "I'll create the code" → routes to the create-code
     (Couple Types) screen.
   - "Người ấy đã có mã" / "They already have a code" → routes to the
     join-code screen (manual entry).
   - "Quét QR trên máy họ" / "Scan the QR on their phone" → routes to the
     same join-code screen (STORY-003 adds the actual camera-scan capability
     there; this story only wires the new entry point).
2. Preserve the existing privacy note and the "later, look around first"
   escape link exactly as already present in the flow.
3. Preserve existing navigation: back target and the two screens this screen
   routes into are unchanged by this story.

## Out of Scope
- Any change to the create-code screen (STORY-002) or the join-code screen's
  own content (STORY-003) beyond this screen routing to them.
- Implementing actual camera QR scanning — STORY-003.
- Any change to post-pairing navigation targets (REQ-009 locked; not
  reopened by this requirement — see `requirements/requirements.md` OQ2).

## Acceptance Criteria
1. Given a user reaches the pairing-method choice screen, when it renders,
   then it shows exactly the three options from the current design source
   (create code, enter code manually, scan QR) with matching copy and icons,
   replacing any prior two-option layout.
2. Given the user taps "I'll create the code", when the tap is handled, then
   they land on the existing create-code (Couple Types) screen, unchanged by
   this story's routing.
3. Given the user taps either "They already have a code" or "Scan the QR on
   their phone", when the tap is handled, then both routes land on the
   existing join-code screen (the same screen, matching current design's own
   routing — QR scanning inside it is STORY-003's scope, not this story's).
4. Given the screen renders in the enabled dark theme + `vi` locale, when
   compared against `cupid-app-design-system`'s corresponding screen, then
   layout, spacing, color/token usage, and typography match.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: YES — this is the existing pairing-method
  choice screen (`pairstart`), reachable from the existing pairing entry
  point in the app; only its layout/options are updated.
- Direct URL only acceptable: NO — reached through the existing pairing
  entry flow.

## Dependencies
- Depends on: NONE.
- Must not require any future story: confirmed — the third card routes to
  the existing (already-functional via manual entry) join-code screen, so
  this story delivers standalone value independent of STORY-003's delivery
  order.

## Open Question Impact
NONE. OQ1 and OQ2 in `requirements/requirements.md` "Open Question Triage"
affect STORY-003 and STORY-002 respectively, not this story's scope.
