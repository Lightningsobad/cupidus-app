# Retro-Audit Report: STORY-011 Epic-3 — Bun Pet Đồng Hành

Run Key: 2026-08-12:REQ-001:STORY-011:retro-audit
Audit type: requirement-authority retro-audit, independent re-verification against
current `main` at BaseHead `f7d06fd4737cc7edbe6f6e33c205bf77fdf26f67`. The prior
`review/review-report.md` (Outcome: CLEAN) was treated as context only, not
authoritative; all findings below are re-derived directly from current source,
tests, and evidence artifacts.

## Acceptance Criteria — independently re-verified

| AC | Evidence (file:line) | Result |
|----|----------------------|--------|
| AC1 — paired users can view the shared pet's current state | `mobile/lib/features/pet/data/pet_repository.dart:28-35` `readStatus()` parses `GET /pets/status` into `PetStatus`. `mobile/lib/features/pet/presentation/pet_screen.dart:83-105` `_ReadyState` renders `PetHeroCard`/`PetXpCard`/`PetActionRow`/`PetStatsRow`/`PetReactionsCard` exclusively from that `PetStatus` (no client recompute). `pet_preview_card.dart:165-236` `_PreviewReady` independently renders the same data on the home-dashboard entry point. | PASS |
| AC2 — any pet interaction shown maps to a real `pets` backend capability | `pet_repository.dart` contains exactly 4 backend calls: `GET /users/me` (pairing), `GET /pets/status` (read), `PATCH /pets/interact` (line 41-44), `POST /pets/adopt` (line 48-59). No other pet mutation exists in `lib/features/pet/**`. `pet_action_row.dart:38` and `:52` — both "Feed" and "Play" buttons call the identical `context.read<PetCubit>().interact()`; no separate feed/play backend effect is implied or implemented. | PASS |
| AC3 — unpaired users cannot access this feature | `pet_cubit.dart:41-59` `load()` calls `readPairing()` and emits `PetLocked` before any pet content is fetched or rendered if `!pairing.isPaired`. Independently re-derived at both surfaces: `pet_screen.dart:63` renders `PetLockedCard` (`pet_guard_states.dart:67-77`, no adopt CTA, no interact buttons) for `PetLocked`; `pet_preview_card.dart:61-66` renders the compact locked variant for the same state, and always routes taps through `PetScreen`, which re-derives the gate rather than trusting the preview card's cached state. | PASS |

No blocking implementation defects found on independent re-read. `pet_mood.dart:21-37` confirms the `sleep` sprite state is never produced (`BunSpriteState.fromMood` has no case reaching it), and `pet_action_row.dart:57-72` confirms the 5s cooldown surfaces via `Semantics(enabled: false)` plus a live-region announcement rather than a silent no-op, matching `ux/uiux-spec.md` §7.

## Scope Discipline (`ux/uiux-spec.md` §9 / `story_master.md` Out of Scope)

- No `pets` endpoint/DTO change: confirmed — `pet_repository.dart` calls only the 4 pre-existing endpoints.
- No streak/badge/per-species-art/sleep-state: confirmed by direct source read (`pet_mood.dart`), consistent with `test-results.md` §5's `git grep` sweep.
- 24h adopt gate stays attempt-based (D3), not client-countdown: consistent with `ux/uiux-spec.md` §5 Open Item 5's own recommendation; no client-side hour arithmetic found in the pet feature.

## OQ Discipline

- `data/intake/bootstrap/conflicts_open_questions.md` read in full: no open item there names `pets`, `bun`, or epic-3 pet mechanics. OQ5 (light theme/EN locale) is unrelated to this story's scope.
- `req_master.md`: no `## Open Question Triage` or `## Approved Scope Change` section exists for STORY-011.
- No OQ-driven constraint violation found.

## Design Fidelity — UNVERIFIED (not PASS)

Per the reused evidence at
`data/requirements/REQ-001_cupid_flutter_mobile_app/integration-review/mobile-visual-audit.md`
(Result: FAIL), the `pet` screen sits in the audit's "Captured, not yet reviewed"
table — ratio-only evidence (design 165 KB vs implemented 24 KB, **6.9x** gap),
explicitly flagged by that report as insufficient for a PASS/MATCH verdict and
not yet screenshot-reviewed in detail. Per this handoff's instruction, that
ratio-only evidence was reused as-is and no new screenshots were captured.

Two additional signals raise the risk that this ratio reflects a real gap
rather than mere design drift:

1. The `pet` screen's 6.9x ratio is in the same range as the audit's four
   **confirmed** structural-gap screens (`antighost` 6.0x, `gallery` 6.0x,
   `invite` 5.7x, `joincode` 5.0x) — none of those turned out to be simple
   post-implementation design drift once reviewed in detail.
2. The `home` screen — the actual discoverable entry point that hosts
   `PetPreviewCard` (`home_screen.dart:130`) — is independently **confirmed
   FAIL** by the same audit: it is still the literal STORY-001 placeholder
   ("Cupid mobile scaffold is running." + a plain card list), not the design's
   couple-header/hero-counter/pet-card-with-XP-bar layout. This is a
   requirement-level (not STORY-011-owned) gap, but it means the pet feature's
   real-world discoverability surface does not resemble the design at all,
   independent of whether `PetScreen` itself renders faithfully.

Design Fidelity is therefore recorded as **UNVERIFIED**, not PASS, consistent
with "a missing render is never a PASS for Design Fidelity" and with treating
ratio-only evidence as insufficient. This is not a new defect — it is the same
systemic gap the mobile-visual-audit already surfaces — but it is material
enough to withhold a CLEAN verdict for this story until the `pet` screen gets a
detailed screenshot-vs-design review (and `home` gets the AppShell-wrapped
recapture the audit already recommends).

## Deferred Findings Carried From Prior Review (re-checked, still non-blocking)

1. `pet_hero_gradient.dart` design-system-token deviation — re-confirmed
   non-duplicate, single-consumer, transparently documented; no action
   required.
2. `Package.resolved` incidental sweep in the story-boundary commit — process
   note only, no content risk; still applicable as a Scrum Master process
   recommendation, not a story defect.

## Story-level Substantive Verdict: NEEDS_WORK

Rationale: all three ACs independently re-verify PASS with concrete,
re-derived code and test evidence; no functional or contract defect was found.
The gap is entirely in the Design Fidelity gate, which is UNVERIFIED (not
PASS) on reused ratio-only evidence that pattern-matches confirmed-FAIL
sibling screens, compounded by the confirmed-FAIL state of the `home` entry
screen this feature is discovered through. This does not warrant
SIGNIFICANT_GAPS or FUNDAMENTAL_MISMATCH (the implementation logic is sound
and AC-complete), but it cannot be called CLEAN while a required verification
gate remains unproven.

Classification Impact: AMBER

Recommended next step (not an implementation instruction — Reviewer does not
edit workflow state): route the `pet` screen (and its `home` host) through the
mobile-visual-audit's own recommended remediation — fix the harness to wrap
screens in `AppShell`, recapture, and complete the detailed screenshot-vs-design
review for the `pet` pair before treating STORY-011's Design Fidelity gate as
resolved.

REVIEW_COMPLETE: YES
