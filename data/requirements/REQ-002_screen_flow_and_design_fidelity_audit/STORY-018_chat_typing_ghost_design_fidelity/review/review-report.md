---
story_status_recommendation: "DONE"
implementation_status_recommendation: "KEEP_CHECKED"
reviewed_at: 2026-08-13
reviewed_by: Reviewer
---

# Review Report: STORY-018 Design Fidelity — Chat & Typing Ghost

Outcome: DEFERRED_ONLY

## Scope Gate (inline)

- Declared implementer WriteScope (`RUN-...-STORY-018-mobile-dev.json`):
  `mobile/lib/features/chat/presentation/screens/chat_screen.dart`,
  `mobile/lib/features/chat/presentation/widgets`,
  `mobile/test/features/chat`, the story `visual-fidelity/` dir, and
  `story_master.md`.
- Actual diff vs `bf80848`: 8 files. 7 fall inside the declared scope
  (`chat_screen.dart` is an explicit scope entry, so it is **not** an
  exception). 1 file is outside: `chat_strings.dart`.
- The exception is recorded twice — `write_scope_exception` in the run file and
  the "Scope disclosure" section of the fidelity report. Reason verified as
  legitimate: `privacyChip` needed the AC3 `Level 1 · ` prefix and
  `ghostBubbleHeader` is the new AC4 string. Both are localized copy that has no
  other home in this repo's layout, and `ChatStrings` is chat-feature-local, not
  shared. Not scope creep; no third-party or cross-feature file touched.
- Confirmed untouched: `ghost_settings_screen.dart` (STORY-019),
  `design_system/adaptive/cupid_tab_bar.dart` (STORY-017),
  `features/anti_ghosting/**` (STORY-020), and all `design_system/` tokens.
- OQ gate: `story_master.md` "Open Question Impact" declares AC1-5 unblocked and
  OQ5 (light theme / `en` locale) out of scope. The implementation honours this —
  every fix is token-derived, so it stays correct across all four combinations,
  and no light/`en` visual pass was claimed. Respected.
- Scope gate: PASS.

## Reviewed Inputs

- Review gate: `compact-story-review`
- Scope Gate: `inline`
- Requirements: `STORY-018_chat_typing_ghost_design_fidelity/story_master.md`
- Bug Report / Diagnosis / Fix Evidence: `N/A`
- UX / Architecture / Coding Plan: `N/A` (SKIPPED:trivial per story_master.md)
- Test Results: `visual-fidelity/visual-fidelity-report.md` §Verification, plus
  independent reruns (below)
- Previous review findings: `N/A`

## Reviewed Scope

- Story complexity: `standard` (run state) — see observation O1
- Code scope reviewed: 6 files (5 lib + 1 test), full read of
  `message_bubble.dart`, `chat_composer.dart`, `chat_design_fidelity_test.dart`,
  and the changed ranges of `chat_screen.dart` / `ghost_bubble.dart` /
  `chat_strings.dart`; plus `design_system/tokens/cupid_platform_tokens.dart`
  read to resolve one sizing question
- Risk surfaces reviewed: UI-lane design fidelity (mobile), mobile widget/layout
  regression, accessibility regression, ADR-004 no-fork guard
- Critical gates reviewed: rendered-value fidelity comparison against the locked
  design source, mobile targeted test evidence, mobile static analysis
- Backend targeted verification gates: `NOT_APPLICABLE`
- Story runtime startup smoke: `NOT_APPLICABLE` (no runtime provisioned in this
  lane; widget-test host used instead)
- Frontend targeted verification gates: `NOT_APPLICABLE`
- Frontend discoverability/navigation integration: `NOT_APPLICABLE`
- Requirement frontend visual audit: `NOT_APPLICABLE`
- Mobile targeted verification gates: `PASS`
- Mobile discoverability/navigation integration: `PASS` (AC5 — no route,
  `Navigator`, or tab-bar change; `ChatScreen`'s public constructor unchanged)
- Requirement mobile visual audit: `PASS`
- OQ context reviewed: OQ5 only, confirmed non-blocking

## Independent Verification

Rerun by the reviewer in the story worktree's `mobile/` dir, not copied from the
implementer's record:

| Command | Result |
| --- | --- |
| `flutter analyze --no-fatal-infos lib/features/chat test/features/chat` | `14 issues found.` — all info `prefer_initializing_formals`, all in untouched `data/` and `*_cubit.dart` files; zero in the 6 changed files |
| `flutter test test/design_system/no_fork_guard_test.dart test/features/chat --reporter compact` | `+56: All tests passed!` — ADR-004 no-fork guard green, so no raw colour literals survived in `lib/features/**` |

Full-suite `+927` and the isolated `+7` fidelity run were accepted from the
recorded evidence; the `+56` rerun is a strict superset of the `+7`.

## AC Verification

AC1-AC5 all verified against the rendered tree, not against constants:
`chat_design_fidelity_test.dart` reads `BoxDecoration`, `TextStyle`, `Icon`, and
`Opacity` values back out of a `buildCupidTheme(material, dark)` + `Locale('vi')`
host. AC4 is the strongest case — the test pumps at 0ms and 1300ms and asserts
`0.95 → 0.45` with `Curves.easeOut`, `TextDecoration.lineThrough`, and
`decorationColor == colorGhost @ 85%`, exactly the design source's
`@keyframes ghostFade` and `rgba(180,166,206,.85)`. AC3's chip is pinned above
the `Expanded` scroll area in `chat_screen.dart:191`, so it survives scrolling —
the deliberate, documented divergence from the mock's DOM position, correctly
resolved in favour of the AC's "visible at all times" wording.

The `reverse: true` thread rewrite (`chat_screen.dart:202-227`) is internally
consistent: index inversion puts the newest message at the bottom, the
older-page trigger moved to `maxScrollExtent`, and pin-to-bottom moved to
`minScrollExtent`. All three edges flipped together; no half-migration.
`Semantics(excludeSemantics: true)` on `MessageBubble` and the `liveRegion`
wrappers in the composer survived the restructure.

## Risk Surface Gate Summary

| Risk Surface | Source Of Truth | Critical Gate | Result | Notes |
|--------------|-----------------|---------------|--------|-------|
| UI design fidelity (mobile) | `Cupid Screens.dc.html` `isChat` block | Rendered-value comparison vs design source | PASS | 25 deviations corrected, each mapped to a source line; 7 widget tests assert rendered values |
| Mobile regression | `flutter test` | Targeted + full suite | PASS | `+56` rerun; `+927` recorded |
| Mobile static analysis | `flutter analyze` | Zero new issues | PASS | 14 info, identical to baseline |
| Design-system integrity | ADR-004 no-fork guard | Guard test green | PASS | Regression caught and fixed during implementation, not suppressed |
| Accessibility | `ux/uiux-spec.md` §8 | Semantics preserved | PASS | Bubble semantics, ghost toggle label, live regions all intact |

## Outcome Summary

- Review outcome: DEFERRED_ONLY
- Rationale: All five acceptance criteria are met with rendered-value evidence,
  every gate reproduces independently, and the single write-scope exception is
  correctly disclosed and justified. Two non-blocking findings are deferred;
  neither affects the audited dark + `vi` + Material configuration.
- Blocking findings: 0
- Deferred findings: 2
- Dismissed observations: 1

## Deferred Findings

**D1 — No `colorOnAccent` / inverse-text design token.** The design source sets
`color:#fff` on the own-message bubble text and the send glyph;
`message_bubble.dart:99` and `chat_composer.dart:310` use `colors.colorText`
instead. Confirmed reasonable, not a blocking gap: ADR-004 forbids raw colour
literals under `lib/features/**`, no on-accent token exists, and `colorText` is
the established convention for text on an accent fill
(`cupid_primary_button.dart:49`). In the audited dark theme `colorText` is
`#F7EEFB` against a pink→purple gradient — imperceptible, so AC1 holds for this
story's scope. The token is genuinely needed for light theme, where `colorText`
is `#3E2645` on the same gradient, but light theme is OQ5 / out of scope here and
`design_system/` is outside this story's WriteScope. Follow-up owner: UI/UX
Designer + design-system owner.

**D2 — Ghost toggle visual clamps to 44pt on the iOS platform axis (new,
reviewer-found).** `chat_composer.dart:349-360` nests a `Container(46 × 46)`
inside `SizedBox(width: platformTokens.tapTarget, height:
platformTokens.tapTarget)` via a `Center`. `CupidPlatformTokens.material()` has
`tapTarget = 48`, so the 46pt visual fits and the audited Material axis is
correct. `CupidPlatformTokens.ios()` has `tapTarget = 44`, so the same
`Container` is silently constrained to 44 × 44 there — a 2pt fidelity delta on
the iOS axis, with no overflow error to surface it. Not blocking: the story's
audited configuration is explicitly the Material axis, and the hit target is
correct on both. `_SendButton` is unaffected (36 < 44). Suggested fix when the
iOS axis is audited: size the visual `Container` outside the tap-target
`SizedBox` rather than inside it.

## Dismissed Observations

**O1 — Story-class metadata disagreement.** `story_master.md` declares
`Complexity: trivial` / `Story-Class: trivial`, while both run-state files and
the review handoff declare `story_class: standard`. Dismissed for this gate: the
stricter classification was applied (a named compact Reviewer gate rather than
lightweight Scrum Master validation), so no gate was skipped. Flagged only so
Scrum Master can reconcile the artifact if the registry depends on that field.

## Residual Risks

- Evidence is static widget-tree assertion only. No emulator screenshot diff or
  on-device pass was run — no mobile runtime is provisioned in this lane. Sub-pixel
  metrics (dashed-border stroke rhythm, `letterSpacing` rendering, gradient
  interpolation) are argued from token and constant values, not from pixels. This
  is a lane-wide constraint for REQ-002, not a STORY-018 shortfall.
- Off-scale constants (`15.5`, `10.5`, `0.84`, etc.) are pinned as private
  file-local `const`s with a comment naming the design-source line. This is the
  right call given no matching token exists, but it does mean these values will
  not follow a future design-source revision automatically.

## Workflow State Recommendation

- Story status: `DONE`
- Bug status: `N/A`
- `Implementation (Development)`: `KEEP_CHECKED`
- `Review (Reviewer)`: `CHECK`
- Next step: Scrum Master may mark STORY-018 `DONE` and treat the branch as
  merge-eligible into `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`.
  Carry D1 forward as a design-system follow-up and D2 into whichever story
  audits the iOS platform axis.
- State update owner: `scrum-master` only. Reviewer does not edit story or
  requirement status files.
