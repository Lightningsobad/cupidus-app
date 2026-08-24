# Requirement Breakdown: REQ-009 Invite couple-type picker & pairing navigation restore

## Source Artifacts

- Requirement master: `data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/req_master.md`
- Additional input files: `data/bugs/BUG-20260824-001_pairing_code_screen_missing_design/bug_master.md` (escalation source, diagnosis)
- Existing related requirement artifacts: REQ-002 `STORY-011_invite_code_design_fidelity`, `STORY-034_pairing_choice_canvas_addition`, `STORY-037_invite_design_fidelity_hardening`

## Context Summary

- Request summary: escalated from BUG-20260824-001. The invite/create-pairing-code
  screen is missing a couple-type picker, and the post-code navigation edge
  diverged from its intended target during commit `3d74a75` (2026-08-20), which
  also deleted the `isPairingChoice` design-system node. Two navigation decisions
  are user-confirmed and locked (see `req_master.md` `## Locked Navigation
  Decisions`); this breakdown implements them, it does not re-decide them.
- Primary actors: the user creating a pairing invitation (inviter, on the
  invite/create-pairing-code screen); the user entering a partner's code
  (invitee, on the join-code screen) for the navigation-restore story only.
- Problem to solve: (1) the invite screen has no way to capture what kind of
  couple the two partners are before pairing continues; (2) continuing from
  invite/join-code currently risks landing on "Fingerprint Vow" — a
  post-pairing surface — before pairing has actually completed, and the
  previously-built `pairing_choice_screen.dart` (STORY-034) is at risk of
  staying disconnected/unverified against a missing design node.
- Business outcome: the invite flow captures couple-type context at the right
  point in the journey, and the pre-pairing chain reaches its correct
  post-pairing-choice target — Waiting-for-partner for the inviter, `paired`
  for the invitee (asymmetric by design; see req_master's `## Locked
  Navigation Decisions`, item 2) — through the pairing-choice screen instead
  of skipping ahead to Fingerprint Vow.
- Success signal: an inviter can select a couple-type after their code is
  shown and continue; continuing from invite always lands on Waiting-for-
  partner via the pairing-choice screen, continuing from join-code always
  lands on `paired` via the pairing-choice screen, and neither ever lands on
  Fingerprint Vow; back navigation from invite/join-code returns to the
  pairing-choice screen.
- Notes on current project context: `CupidProfile.coupleType` already exists
  as an optional field in the mobile domain model and DTO
  (`mobile/lib/features/account/domain/cupid_profile.dart`,
  `mobile/openapi/cupid_api/lib/src/model/update_profile_dto.dart`) — Tech
  Lead should confirm during architecture whether existing profile-update
  plumbing already covers persistence or new wiring is needed.
  `pairing_choice_screen.dart` (`mobile/lib/features/pairing/presentation/screens/`)
  and its `OnboardingRouter` builder registration already exist in the
  codebase; whether the currently-registered wiring already matches the
  locked decision's asymmetric `invite -> pairing-choice -> waiting` /
  `join-code -> pairing-choice -> paired` order, or needs repositioning, is an
  implementation-verification question for Tech Lead/mobile-dev during
  STORY-002, not a reason to reopen the locked decision itself.

## Scope Decision

### In Scope

- A couple-type picker (4-card grid, vi/en content) on the invite/create-code
  screen, placed after the pairing code is already displayed, leading to the
  Continue CTA.
- Persistence semantics for the selected couple-type on `CupidProfile`.
- Design-system node authoring for the invite-screen couple-type cards and for
  the `pairing_choice`/`isPairingChoice` node.
- Restoring the post-code navigation target for both invite and join-code via
  the pairing-choice screen, asymmetrically: invite leads to
  Waiting-for-partner, join-code leads to `paired` (invitee acceptance is
  synchronous, so there is no waiting state) — neither leads to Fingerprint
  Vow.
- `BACK_TO` wiring: invite -> pairing-choice, join-code -> pairing-choice.
- Reconnecting/confirming `pairing_choice_screen.dart` (STORY-034) in the
  active flow, including its own content/design match.
- Updating any automated test pinned to the prior `goVow` post-code
  navigation expectation (e.g. `app_shell_test.dart`) to the restored target.

### Out of Scope

- Any change to the 5-tab shell / FAB consolidation
  (`REQ-003_app_shell_five_tab_navigation_and_fab_consolidation`) beyond what
  is strictly needed to restore the two navigation edges above.
- Redesigning "Fingerprint Vow" itself; this requirement only removes it as
  the immediate post-code navigation target for invite/join-code. A different
  entry point for Vow elsewhere in the product is separate scope.
- Displaying or surfacing the selected couple-type anywhere in the product
  beyond storing it on `CupidProfile` (e.g. a shared couple-profile display)
  — future scope, not decided here.
- A couple-type picker on the join-code (invitee) screen — the locked
  decision places it only on the invite/create-code screen.
- Editing the selected couple-type after the invite flow completes (e.g. from
  Account/profile settings) — future scope.

### Business Rules And Guardrails

- Couple-type selection is mandatory to continue from the invite screen: the
  Continue CTA stays disabled until exactly one of the 4 cards is selected.
  Decided here because the picker sits directly in the CTA's path and no
  "skip" affordance is part of the locked design placement.
- Couple-type content catalog (authored here per req_master's explicit ask —
  STORY-011 excluded it from its own scope):
  1. **Yêu xa / Long-distance** — icon: map-pin/flight — vi: "Tụi mình đang ở
     hai nơi khác nhau" — en: "We're in different places"
  2. **Cùng thành phố / Same city** — icon: location-city — vi: "Tụi mình ở
     cùng một thành phố" — en: "We live in the same city"
  3. **Mới hẹn hò / Just started dating** — icon: sparkle-heart — vi: "Tụi
     mình mới bắt đầu tìm hiểu nhau" — en: "We just started getting to know
     each other"
  4. **Gắn bó lâu dài / Long-term / committed** — icon: infinity-heart — vi:
     "Tụi mình đã gắn bó với nhau lâu rồi" — en: "We've been together for a
     while"
  UI/UX Designer may refine exact icon glyphs to what the design system
  exposes; the 4 categories and their vi/en meaning are the locked content
  decision.
- Selected couple-type persists to `CupidProfile.coupleType` and survives app
  restart; if the user backs out and returns to the invite screen before
  pairing completes, the prior selection is shown pre-selected, not lost.
- Post-code navigation target for both invite and join-code is the
  pairing-choice screen, but the terminal target is asymmetric by design:
  invite leads to Waiting-for-partner (the inviter genuinely waits on their
  partner); join-code leads to `paired`, not Waiting-for-partner, because
  `acceptInvitation(code)` is synchronous for the invitee and there is nothing
  left to wait for. Fingerprint Vow is never reachable as the immediate next
  screen from either.
- `BACK_TO`: invite's back action returns to pairing-choice (not profile);
  join-code's back action returns to pairing-choice (not invite).

## Open Question Triage

| OQ ID | Status | Scope Items BLOCKED | Scope Items NOT BLOCKED | Decision |
|-------|--------|---------------------|------------------------|----------|
| OQ5 (light theme / EN locale in v1) | UNRESOLVED, non-blocking | None | All scope in this requirement | Same disposition as STORY-011/STORY-036/STORY-037: dark + `vi` is the only enabled user-facing configuration; no dedicated light/EN rendered fidelity pass required for either story in this requirement |

### OQs reviewed but not applicable to this requirement

- No other OQ in `data/intake/bootstrap/conflicts_open_questions.md` references
  pairing, invite, couple-type, or navigation scope.

## Seed To Story Mapping

> Not applicable — this requirement was escalated directly from a bug
> diagnosis (`BUG-20260824-001`), not from a discovery pass with a
> `## Story Seeds` table. No seed table exists to map.

### Distinct user outcomes in this requirement

1. An inviter can record what kind of couple they are, right after their
   pairing code is generated, before continuing.
2. Anyone who has just created or joined a pairing code is taken through the
   pairing-choice screen to their correct terminal target — Waiting-for-
   partner for the inviter, `paired` for the invitee — never to Fingerprint
   Vow, and can navigate back to pairing-choice from either screen.

## Coverage Map

| Requirement / Need | Planned Story ID(s) | Notes |
|--------------------|---------------------|-------|
| Couple-type picker placement (after code, before Continue) | STORY-001 | |
| Couple-type content catalog (vi/en labels, hints, icons) | STORY-001 | Authored above |
| `CupidProfile.coupleType` persistence semantics | STORY-001 | |
| Design-source node: invite-screen couple-type cards | STORY-001 | Own UX Design phase |
| Post-code navigation: invite -> pairing-choice -> waiting; join-code -> pairing-choice -> paired; never vow | STORY-002 | Asymmetric by design |
| `BACK_TO` wiring: invite/join-code -> pairing-choice | STORY-002 | |
| `pairing_choice_screen.dart` reconnect/confirm (STORY-034) | STORY-002 | |
| Design-source node: `isPairingChoice`/pairing-choice | STORY-002 | Own UX Design phase |
| Regression risk: tests pinned to `goVow` (e.g. `app_shell_test.dart`) | STORY-002 | Built into story's own testing |

## Recommended Story Sequence

| Story ID | Title | Complexity | Depends On | Why This Order | Observable After This Story |
|----------|-------|------------|------------|-----------------|------------------------------|
| STORY-001 | Invite couple-type picker | standard | None | Independent capability; can render/persist selection regardless of what "Continue" currently routes to | Inviter sees and can select a couple-type card after their code is shown, and it is saved to their profile |
| STORY-002 | Pairing-choice navigation restore | standard | None | Independent of STORY-001 — the navigation-target fix does not require the picker to exist to be delivered or verified | Continuing from invite reaches Waiting-for-partner and continuing from join-code reaches `paired`, both via the pairing-choice screen, never Fingerprint Vow; back navigation returns to pairing-choice |

No forward or circular dependency between the two: each passes the
standalone-value gate on its own, and neither's acceptance criteria require
the other story's behavior to exist first. Recommended delivery order is
either sequence; STORY-002 first slightly simplifies manual verification of
STORY-001's own Continue action landing on the correct screen, but is not a
structural dependency.

INTEGRATION_VERIFICATION_REQUIRED: NO — both stories touch
`invite_screen.dart`, but each owns a structurally separate concern (content
above the CTA vs. the CTA's navigation target) that its own story tests can
verify independently; no cross-story runtime interaction exists that neither
story's own tests plus Reviewer gate can already cover.

## Story Index

| Story ID | Title | Brief File | Primary Scope | Key AC/OQ Anchors |
|----------|-------|------------|----------------|--------------------|
| STORY-001 | Invite couple-type picker | `data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/STORY-001_invite_couple_type_picker/story_brief.md` | Invite/create-code screen, couple-type content + persistence | Locked Decision 1; OQ5 non-blocking |
| STORY-002 | Pairing-choice navigation restore | `data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/STORY-002_pairing_choice_navigation_restore/story_brief.md` | Post-code navigation, `BACK_TO` wiring, `pairing_choice_screen.dart` | Locked Decision 2; OQ5 non-blocking |
