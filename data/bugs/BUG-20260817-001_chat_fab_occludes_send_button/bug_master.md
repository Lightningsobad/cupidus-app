# Bug Master: BUG-20260817-001 Chat FAB Occludes Send Button
Status: REPORTED
Severity: HIGH
Source: mobile-dev (Alex-Mobile-Dev), found during STORY-040 rendered-evidence pass
Created: 2026-08-17
Linked Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Linked Story: STORY-016 (shell/navigation owner, DEC-4) — discovered during STORY-040_chat_typing_ghost_design_fidelity_hardening

## Report

Observed behavior:
On the `chat` screen, the shell's account-hub `FloatingActionButton`
(`mobile/lib/core/navigation/app_shell.dart:199-206`, mounted on every tab at
the default `endFloat` location) fully overlaps the chat composer's send
button. Measured off a live render
(`implemented-chat-composer-draft-emulator-5560.png`, captured for
`STORY-040`): the FAB occupies capture-px x=336..386, y=730..786; the
composer's send button visual occupies x=351..386, y=751..786 — 100% covered
by the FAB. Because the FAB paints above the screen body, the send button is
untappable: the chat screen's primary action (sending a message) cannot be
reached in production whenever the shell chrome is active.

Expected behavior:
The chat screen's send button must remain visible and tappable when the
account-hub FAB is present. The design reference
(`design-reference-chat-android.png`) has no FAB on this screen at all, so
there is no rendered target overlap to match — the fix is an IA/layout
decision, not a pixel-matching one.

Reproduction steps or command:
1. Launch the app to the `chat` tab in any state where `AppShell` renders
   (paired-account, shell-wrapped).
2. Type a non-empty draft so the send button reaches its enabled state.
3. Observe/attempt to tap the send button — it is visually covered by the
   account-hub FAB in the bottom-right corner and cannot be tapped.

Failure anchors:
- Stack trace: N/A — not a crash, a visual/interaction occlusion defect.
- Failing test: none yet. Not caught by any existing widget test; the
  chat-screen widget tests pump the screen unshelled (`wrapInShell: false`
  in preview / bare `ChatScreen` in unit tests), so the shell's FAB is never
  in the same render tree as the composer in any current test.
- Route/endpoint/component/job:
  `mobile/lib/core/navigation/app_shell.dart:199-206`
  (`FloatingActionButton`) occludes
  `mobile/lib/features/chat/presentation/widgets/chat_composer.dart`'s send
  button.
- Environment: `emulator-5560`, dark theme, `vi` locale, Material platform
  axis, shell-wrapped `chat` screen (the same axis STORY-040 audited).

Additional context (do not re-derive, read only if diagnosing):
This is the *new* part of a pre-existing, already-accepted chrome divergence
— the 3-tab shell + account-hub FAB vs. the design's 5-tab bar is STORY-016
DEC-4, already approved at requirement level. This bug is not "the FAB
exists", it is "the FAB now covers the chat screen's primary action button".
The fix is a navigation/IA decision (hide the FAB on the chat tab, relocate
it, or inset the chat body to clear it) owned by the shell/navigation
surface, not a chat-screen-local fix — explicitly outside
`STORY-040_chat_typing_ghost_design_fidelity_hardening`'s WriteScope, which is
why it was referred out rather than fixed in that story. Full finding
write-up (measurements, capture references): `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-040_chat_typing_ghost_design_fidelity_hardening/visual-fidelity/visual-fidelity-report.md`,
finding `N2`.

## Reviewer Confirmation

STORY-040's reviewer (Iris-QC-6, `review/review-report.md` finding R-2)
independently confirmed the occlusion directly in the evidence capture and
flagged that this bug — the chat screen's primary action being unreachable in
the shipped app — warrants priority ahead of ordinary visual-fidelity backlog
items. Severity kept at HIGH; no other change to intake facts.

## Artifacts

- [ ] Diagnosis (Bug Fixer)
- [ ] Fix Evidence (Bug Fixer)
- [ ] Review (Reviewer)

## Routing Notes

- Current owner: scrum-master
- Next role: queued for fix-bugs
- Bug Registry: `data/bugs/master_bugs_list.md`
- Diagnosis: `diagnosis.md`
- Fix Evidence: `fix-evidence.md`
- Review Report: `review/review-report.md`
- Checkpoint: `scrum-master-checkpoint.md`

## Blockers

- N/A
