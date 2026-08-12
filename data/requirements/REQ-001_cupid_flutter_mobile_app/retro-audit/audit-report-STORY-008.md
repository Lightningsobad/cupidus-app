# Retro-Audit: STORY-008 Epic-2 — Anti-Ghosting Configuration

Reviewer: Iris-QC (retro-audit, requirement-authority, independent of prior
story-scoped review)
Run Key: 2026-08-12:REQ-001:STORY-008:retro-audit
BaseHead audited: `f7d06fd4737cc7edbe6f6e33c205bf77fdf26f67` (current `main`)
Prior recorded verdict: `review/review-report.md` — Outcome: CLEAN (treated as
context only, not authoritative; independently re-verified below against
current source on `main`)

## Method

Read `story_master.md`, `architecture/solution.md`, `coding-plan/master-plan.md`
+ `test-results.md`, prior `review/review-report.md`, the UX spec, the central
OQ registry, `req_master.md`, the design-fidelity config, and the reused
mobile-visual-audit evidence. Then independently read the actual current
mobile source files that compose the app's navigation tree
(`mobile/lib/features/chat/presentation/screens/chat_screen.dart`,
`mobile/lib/core/navigation/app_shell.dart`,
`mobile/lib/features/home/presentation/home_screen.dart`) to verify each AC
against what is really mounted on `main` today, rather than trusting the
story's own claim of deferred-but-scheduled work.

## AC-by-AC verdict

### AC1 — "A paired user can view/set anti-ghosting configuration options exposed by the backend contract." — PASS

- `home_screen.dart:19,102` imports `../../anti_ghosting/anti_ghosting.dart`
  and mounts `const AntiGhostEntryCard()` in the composed home screen (append-
  only, present on `main`).
- Entry card routes to `AntiGhostScreen`, which implements states A-D over the
  frozen `ghost-config` contract (`architecture/solution.md` §4, ADR-1..ADR-6).
- Evidence: `coding-plan/test-results.md` — `anti_ghost_cubit_test.dart`
  (13/13), `anti_ghost_screen_test.dart` (5/5), full anti_ghosting suite
  62/62. Consistent with the prior review's citation of the same tests.
- No contradicting evidence found in current source.

### AC2 — "The configured anti-ghosting state is visibly surfaced somewhere in the chat experience." — FAIL (confirmed on current `main`, not previously caught)

This is the substantive finding of this audit. The story's own architecture
(`architecture/solution.md` ADR-3) and every downstream artifact
(`master-plan.md` §6, `test-results.md` §6, the prior `review/review-report.md`)
explicitly and repeatedly documented that AC2 could **not** be demonstrated
end-to-end inside STORY-008's own branch, because `mobile/lib/features/chat/**`
did not exist at STORY-008's `BaseHead a07aa98`. All of them treated this as
acceptable *because* it was a tracked, non-blocking deferral: "the literal
one-line mount in STORY-007's chat screen ... is a Scrum Master scheduling
item for STORY-007 or requirement integration" (architecture §6/§8; repeated
in `master-plan.md` §6 and `test-results.md` §6).

I independently read the actual current chat/navigation source on `main` to
check whether that scheduled mount ever landed:

- `mobile/lib/features/chat/presentation/screens/chat_screen.dart` (full file
  read) — no import of `anti_ghosting`, `GhostStateRow`, or `GhostStormCubit`
  anywhere. The screen mounts `MessageBubble`, `GhostBubble` (STORY-007's own
  typing-ghost indicator — a different feature, correctly out of STORY-008's
  scope), and `ChatComposer`. No STORY-008 anti-ghosting surfacing widget is
  present.
- `mobile/lib/core/navigation/app_shell.dart` (full file read) — the only
  chat-adjacent ghost affordance is a temporary `IconButton` (`key:
  'ghost_settings_entry_action'`) that opens `GhostSettingsScreen` from
  `features/chat/presentation/screens/ghost_settings_screen.dart`, driven by
  `GhostConsentStore`/`coordinator`/`partnerStore`. This is STORY-007's
  Typing-Ghost **consent** settings screen (a same-word, different-feature
  naming collision with STORY-008's "anti-ghosting"), not
  `AntiGhostScreen`/`GhostStateRow`. `GhostStateRow` is not referenced.
- `mobile/lib/features/home/presentation/home_screen.dart` (full file read) —
  confirms the home entry card (AC1) but has no bearing on chat surfacing.

Conclusion: `GhostStateRow`/`GhostStormCubit` (the exported STORY-008 widget
that implements AC2 per UX spec §2.4, "the AC2 gate") exist and are unit/
widget-tested in isolation, but are **mounted nowhere in the composed app**.
A paired user opening the real chat screen today sees no anti-ghosting
state at all. AC2 is unmet on current `main`.

This gap was not caught by any downstream gate:
- STORY-007's own `story_master.md`/review make no mention of mounting
  `GhostStateRow`; its Role Completion section and review report are silent
  on the ADR-3 seam entirely.
- The requirement integration review
  (`integration-review/review-report.md` §6 "Cross-story navigation /
  entry-point wiring") verified DI registration (`service_locator.dart` has
  an "anti-ghosting" entry) and that `AntiGhostEntryCard` is mounted on
  `home_screen.dart`, but never checked whether the chat-mount seam itself
  (the specific, named, risk-tracked deferred item) was completed. It reviewed
  entry points, not the flagged deferral.
- `req_master.md` / `scrum-master-checkpoint.md` record REQ-001 as fully
  `DONE`, all 16 stories `DONE`, integration review `Outcome: CLEAN`, with no
  open item referencing the STORY-008 chat-mount seam.

### AC3 — "Unpaired users cannot access this configuration." — PASS

- `AntiGhostEntryCard`'s own test (`anti_ghost_entry_card_test.dart`) is cited
  as covering "unpaired user sees no card" (defense in depth); `AntiGhostCubit`
  pairing-guard tests assert zero mutating repository calls when unpaired.
  Consistent with UX spec §1's pairing-gate requirement and the backend's own
  `BadRequestException`.
- No current-source evidence contradicts this; the guard logic lives inside
  the (unmounted-in-chat but otherwise intact) `anti_ghosting` feature module
  itself, which is unaffected by the AC2 chat-mount gap.

## OQ Discipline check

ADR-5's descope of the mockup's public-countdown toggle / sound-override
toggle / custom emoji grid is not a requirement-scope reduction requiring an
OQ trace — it is forced by the A1-frozen `ghost-config` contract (no backend
field exists to persist any of the three), correctly cited to the actual
backend DTO/entity source rather than asserted. No OQ id is referenced by
`story_master.md`, `req_master.md`, or the UX spec for this story, and none
was needed for this decision. No OQ Discipline violation found.

The AC2 deferral itself is not an OQ/scope-change matter — it was never framed
as a scope reduction, only as a sequencing deferral to a later, named
integration point that was subsequently never executed. That is a
process/scheduling failure, not an OQ Discipline gap.

## Design Fidelity

Reused evidence only (`integration-review/mobile-visual-audit.md`), not
recaptured. The `antighost` (settings) screen appears only in the "Captured,
not yet reviewed" ratio table (design 183 KB vs implemented 30 KB, 6.0x) — per
the audit's own caveat, ratio-only evidence is insufficient for PASS/MATCH,
and the design source is known to have drifted after implementation (175 KB
-> 247 KB `Cupid Screens.dc.html`), so a ratio delta alone cannot be
attributed to this story without a detailed review. The chat screen (where
AC2's surfacing would visually appear) was not among the audit's 10 reviewed
screens at all.

**Design Fidelity verdict: UNVERIFIED** (weak, ratio-only evidence for the
settings screen; no evidence at all for the chat-surfacing screen). This is
assessed separately from AC pass/fail per the audit method and does not
change the AC2 FAIL above, which rests on direct source-code evidence, not on
visual comparison.

## Summary

- AC1: PASS
- AC2: FAIL — `GhostStateRow` is fully implemented and unit/widget-tested but
  is not mounted anywhere in the composed app (`chat_screen.dart`,
  `app_shell.dart`). The story's own architecture named this exact risk and
  assigned it as a Scrum Master scheduling item for STORY-007 or requirement
  integration; neither picked it up, and the integration review's navigation
  check did not verify this specific named deferral before recording `CLEAN`.
- AC3: PASS
- Design Fidelity: UNVERIFIED (weak evidence only; not gating, tracked
  separately)

Fix scope is narrow and well-defined: mount `GhostStateRow(partnerId:
partnerId)` into `ChatScreen`'s widget tree (per UX spec §2.4: "below the
message list and above the composer," below the `GhostBubble`/typing-ghost
row) and wire its dependencies (partner id source already available via
`ChatPartnerStore`/`BackendUserIdStore`, already constructed in
`app_shell.dart`/`chat_screen.dart`). No architecture rework, no new backend
call, no new dependency — a scoped mount-and-verify patch.

Story-level Substantive Verdict: SIGNIFICANT_GAPS
Classification Impact: RED-PATCH
REVIEW_COMPLETE: YES
