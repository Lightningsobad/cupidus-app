# Review Scope Gate: STORY-006 "Trước giờ đi" — checklist tất định (SB-211)

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

## Identity

- Review type: `full-story-review`
- Review report path:
  `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-006_before_you_go_checklist/review/review-report.md`
- Scope gate path:
  `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-006_before_you_go_checklist/review/scope-gate.md`

## Scope Decision

- Scope status: `PROCEED`
- Why this review is within budget or why it must stop: 12 source/test/config
  files named by the handoff (11 new, 1 modified mount point) = the
  `full-story-review` ceiling exactly. Two governing artifacts over ~20 KB are
  in play (`requirements/requirements.md` 23.5 KB, read in two ranges; the
  requirement `req_master.md` 50.6 KB touched only by single-key grep, not
  read) — within the 2-artifact allowance.
- Current story or bug status: `Status: TODO`, `Complexity: standard`,
  `Implementation Lane: mobile`, Implementation checkbox checked, Review
  unchecked. P1 + P2 both reported DONE, working tree uncommitted.
- Retro gate: `data/retro-audit/rework-backlog.md` holds zero
  `Status: PENDING` / `Status: IN_PROGRESS` items — ordinary story review is
  allowed without `Retro-Bypass`.

## Governing Inputs

- Primary artifacts:
  - `STORY-006_before_you_go_checklist/story_master.md`
  - `STORY-006_before_you_go_checklist/requirements/requirements.md`
    (AC-1..AC-31, BR-1..BR-17, `## Open Question Impact`)
- Existing review findings: `N/A` — first review pass for this story.
- Test evidence:
  - `STORY-006_before_you_go_checklist/coding-plan/test-results.md`
    (`## Phase P1`, `## Phase P2`)
  - `STORY-006_before_you_go_checklist/visual-fidelity/visual-fidelity-report.md`
- Extra artifacts required beyond the default minimum:
  - `architecture/contract-summary.md` §1-§4 by section only, if a pack-schema
    or `BeforeYouGoPhase` contract question arises
  - `coding-plan/phase-P2-detail-screen-block-and-dismissal.md` §6 only for
    write/test scope verification
  - sibling `STORY-003_private_journal/coding-plan/test-results.md` consulted
    by single-key grep only, to establish the requirement's own precedent for
    the rule 12g / 12e1 evidence section names

## Source/Test Files In Scope

- `mobile/assets/data/req016/before_you_go.v1.json`
- `mobile/lib/features/before_you_go/domain/before_you_go_content.dart`
- `mobile/lib/features/before_you_go/domain/before_you_go_content_gate.dart`
- `mobile/lib/features/before_you_go/domain/before_you_go_resolver.dart`
- `mobile/lib/features/before_you_go/data/before_you_go_dismissal_store.dart`
- `mobile/lib/features/before_you_go/presentation/before_you_go_cubit.dart`
- `mobile/lib/features/before_you_go/presentation/widgets/before_you_go_block.dart`
- `mobile/lib/features/activity_cards/presentation/screens/activity_card_detail_screen.dart`
  (diff hunk only — the mount point after `_primaryAction(...)`)
- `mobile/test/features/before_you_go/before_you_go_content_gate_test.dart`
- `mobile/test/features/before_you_go/before_you_go_resolver_test.dart`
- `mobile/test/features/before_you_go/before_you_go_dismissal_store_test.dart`
- `mobile/test/features/before_you_go/before_you_go_block_test.dart`

## Evidence Files In Scope

- `coding-plan/test-results.md` (`## Phase P1`, `## Phase P2`)
- `visual-fidelity/visual-fidelity-report.md`
- `visual-fidelity/design-reference-sb-211-truoc-gio-di-ios.png`
- `visual-fidelity/implemented-sb-211-truoc-gio-di-ios.png`
- `visual-fidelity/implemented-sb-211-truoc-gio-di-ios-collapsed.png`

## Risk Surfaces And Critical Gates

- Touched risk surfaces:
  - mobile interaction (new block on an existing detail screen)
  - mobile navigation/discoverability (auto-mounted nested block, no new route)
  - local storage/offline (`SharedPreferences` dismissal key, offline-only
    content resolution per AC-22/AC-23)
  - typed/generated contract (content-pack schema + `BeforeYouGoPhase` handoff
    to STORY-012 per AC-24/BR-11)
  - permissions/device API (OS Share Sheet, one-shot, per AC-18..AC-20)
  - app lifecycle (block re-evaluated per screen open, civil-date dependent)
- Source-of-truth artifacts or contracts:
  - `requirements/requirements.md` AC-1..AC-31 and BR-1..BR-17
  - `architecture/contract-summary.md` §1-§4 (pack schema, phase contract)
  - shipped pack `mobile/assets/data/req016/before_you_go.v1.json`
- Critical gates to verify:
  1. mobile static analysis on the changed module — `flutter analyze`
  2. targeted widget/unit tests for resolver, gate, store, block
  3. regression run over the host screen's existing suite
  4. content-gate negative control is non-vacuous (AC-31/BR-17)
  5. no hardcoded pack labels in Dart (AC-29/BR-15)
  6. determinism / no clock read inside the module (AC-10)
  7. no network or AI call on any path (AC-22/AC-23/BR-6)
  8. rendered visual-fidelity evidence per rule 12e2/12e3 — verify the mobile
     lane's own capture and open both images, do not re-capture
  9. `## Entry Point Reachability` with `Reachable: YES`, plus independent
     in-code confirmation of the mount point (rule 12e1)
  10. `## Story Runtime Startup Smoke` for the `mobile` lane (rule 12g)
- Mandatory web Playwright/browser-e2e gate: `NOT_APPLICABLE in ordinary continue`
- Requirement visual audit evidence: `NOT_APPLICABLE` — this story has no
  frontend/web participation; the story lane is mobile-only.
- Mandatory mobile e2e/emulator/signing/store gate: `NOT_APPLICABLE in ordinary continue`
- Requirement mobile visual audit evidence: `REQUIRED when requirement had
  mobile participation` — but that is the requirement-level
  `integration-review/mobile-visual-audit.md`, enforced at requirement
  closure, not at this story gate (rule 12g2). Per-story visual fidelity IS in
  scope here and is present.
- Missing gate evidence or blocker: gates 9 and 10 have NO section in
  `coding-plan/test-results.md` — verify in Phase 2 whether the evidence lives
  anywhere else in the story folder before classifying.

## Query Keys

- ACs: AC-1, AC-2, AC-3, AC-4, AC-5, AC-6, AC-7, AC-8, AC-9, AC-10, AC-11,
  AC-12, AC-13, AC-14, AC-15, AC-16, AC-17, AC-18, AC-19, AC-20, AC-21, AC-22,
  AC-23, AC-24, AC-25, AC-26, AC-27, AC-29, AC-30, AC-31
- BRs: BR-2, BR-4, BR-5, BR-8, BR-9, BR-11, BR-14, BR-15, BR-16, BR-17
- Symbols: `BeforeYouGoContentPack`, `BeforeYouGoItem`, `resolveBeforeYouGo`,
  `BeforeYouGoContentGate`, `BeforeYouGoDismissalStore`, `BeforeYouGoCubit`,
  `BeforeYouGoBlock`, `BeforeYouGoPhase`, `ContentPackageFormatException`
- Keys/strings: `req016.before_you_go.v1`, `schema_id`,
  `before_you_go.dismissed_on.<cardId>`, `Xong hết rồi, đi thôi`, `Mở lại`
- Mount point: `_primaryAction(` in
  `activity_card_detail_screen.dart` (diff hunk, +26 lines)
- Commands: `flutter analyze lib/features/before_you_go`,
  `flutter test test/features/before_you_go/`,
  `flutter test test/features/before_you_go/ test/features/activity_cards/`,
  `--dart-define=CAPTURE_VISUALS=true --plain-name="visual fidelity capture"`
- Evidence headings: `## Phase P1`, `## Phase P2`, `### Negative control của
  cổng nhập — không vacuous`, `## DESIGN_SPEC_CONFLICT`,
  `## Entry Point Reachability`, `## Story Runtime Startup Smoke`
- Already-adjudicated, verify but do not re-litigate: the 6
  `DESIGN_SPEC_CONFLICT` items; the RepaintBoundary capture method; the
  `schemaId` vs `schema_id` doc-only inaccuracy in `contract-summary.md` §1;
  the `scheduledOn: '2026-10-01'` fixture in the out-of-scope
  `activity_card_detail_screen_test.dart`.

## Phase 2 Approval

- Phase 2 may proceed: `YES`
- If `NO`, final review outcome should be: `N/A`
- If `NO`, exact blocker or re-scope instruction: `N/A`
