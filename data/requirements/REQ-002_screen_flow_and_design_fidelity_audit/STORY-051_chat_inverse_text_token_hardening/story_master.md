# STORY-051: Chat Inverse-Text / colorOnAccent Token Disposition

Status: RETRO_PENDING
Retro-Type: RED-PATCH
Fixes: STORY-018_chat_typing_ghost_design_fidelity
Complexity: TBD (Product Owner triage)
Story-Class: standard
Implementation Lane: TBD (Product Owner triage)

## Artifacts

- [ ] Requirements (Product Owner)
- [ ] UX Design (UI/UX Designer)
- [ ] Architecture (Tech Lead)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Background (Rework Item)

Source: `data/retro-audit/rework-backlog.md` — RWB-20260816-016, split out of
`STORY-040_chat_typing_ghost_design_fidelity_hardening`'s Product Owner
scoping (finding D1, carried forward from STORY-018's own
`review/review-report.md`).

The design source sets `color:#fff` on the own-message bubble text and send
glyph; `message_bubble.dart:99` and `chat_composer.dart:310` use
`colors.colorText` instead, because `CupidColorTokens` carries no on-accent /
inverse-text token and ADR-004 forbids raw colour literals under
`lib/features/**`. In the audited dark theme `colorText` is `#F7EEFB` —
imperceptible against the pink→purple gradient, so STORY-040's own AC1 held.
The gap is real in light theme, where `colorText` is `#3E2645` on the same
gradient — a genuine contrast regression there. Not blocking for STORY-040:
light theme is OQ5 and was explicitly out of scope for that hardening pass,
and adding the token is a `design_system/` change outside a chat-screen
story's natural WriteScope.

Exact remediation suggested by the surfacing reviewer: UI/UX Designer +
design-system owner to add a `colorOnAccent` (or equivalently named
inverse-text) token to `CupidColorTokens`, then update
`message_bubble.dart:99` and `chat_composer.dart:310` to consume it, scoped
together with whichever future story delivers light-theme / `en` locale
(OQ5) user-facing support.

Product Owner must confirm this disposition against the current status of
OQ5 (central Open Question registry) before scoping: if OQ5 (light theme /
`en` locale support) is not yet approved product scope, Product Owner should
consider whether this token gap can be closed standalone (token addition +
2-file consumption, without shipping a full light-theme toggle), rather than
leaving it blocked indefinitely on unscoped future work. Record whichever
disposition is chosen — implement now, or keep-and-exclude pending OQ5 — with
reasoning, per this campaign's established triage pattern (see
`STORY-050.../story_master.md` `## Product Owner Triage`).
