# Scope Gate — REQ-012 / STORY-001 Pairing-Method Choice Screen Redesign

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

- Review type: compact-story-review
- Review report path: `data/requirements/REQ-012_pairing_flow_qr_code_and_couple_types_screen/STORY-001_pairing_method_choice_screen_redesign/review/review-report.md`
- Story: STORY-001_pairing_method_choice_screen_redesign
- Complexity: standard
- Implementation Lane: shared (delivered by mobile-dev against the Flutter app)
- Branch: `codex/REQ-012_pairing_flow_qr_code_and_couple_types_screen-STORY-001_pairing_method_choice_screen_redesign`
- BaseHead: `d32f02f3c5fdeb0572c2ac2e8fb4831289d9142b`
- Worktree HEAD: `9afe9be08aec7e36f4ed6ee027f8433fe8ab7435`
- Implementation commit: `8c203dba543bae1b678338bfbab896df4203a9d2`

## Source/test files in scope

From `git -C <Worktree> diff --name-only d32f02f3c5fdeb0572c2ac2e8fb4831289d9142b`
(6 changed source/test files, within the compact budget of 8):

- `mobile/lib/features/pairing/presentation/screens/pairing_choice_screen.dart`
- `mobile/lib/design_system/icons/cupid_icons.dart`
- `mobile/lib/design_system/tokens/cupid_color_tokens.dart`
- `mobile/lib/features/pet/presentation/widgets/pet_preview_card.dart`
- `mobile/test/features/pairing/presentation/screens/pairing_choice_screen_test.dart`
- `mobile/test/features/pairing/presentation/pair_gate_cubit_test.dart`

Read additionally for independent entry-point verification (unchanged file, not a
review target): `mobile/lib/core/navigation/pair_gate_shell.dart`

## Evidence files in scope

- `data/requirements/REQ-012_pairing_flow_qr_code_and_couple_types_screen/STORY-001_pairing_method_choice_screen_redesign/story_master.md`
- `data/requirements/REQ-012_pairing_flow_qr_code_and_couple_types_screen/STORY-001_pairing_method_choice_screen_redesign/coding-plan/test-results.md`
- `data/devops/system/design-fidelity-config.json`
- `data/retro-audit/rework-backlog.md` (retro gate check only)

One large governing artifact over ~20 KB was in scope (`rework-backlog.md`, 109 KB),
queried by exact status keys rather than full-read, within the compact budget of 1.

## Touched risk surfaces and critical gates to verify

| Risk surface | Critical gate |
|---|---|
| Mobile interaction (three-row screen rebuild) | Targeted widget tests |
| Mobile navigation / discoverability | Entry point verified in router code + `## Entry Point Reachability` evidence section |
| Mobile UI design fidelity | Per-story rendered capture + `VISUAL_FIDELITY` verdict + resolved `Design-Screen` |
| App lifecycle / startup | `## Story Runtime Startup Smoke` |
| Shared design-token contract (`CupidColorTokens`) | Theme matrix / contrast / no-fork-guard suites + sibling call-site check |
| Static analysis | `flutter analyze lib test` severity |

## Query keys for Phase 2

- AC1, AC2, AC3, AC4 from `story_master.md`
- `pairstart` three-row layout; `createCodeRowKey` / `enterCodeRowKey` / `scanQrRowKey`
- `_openInvite`, `_openJoincode`, `InviteScreen`, `JoincodeScreen`
- `PairingChoiceScreen`, `PairGateUnpaired`, `PairGateShell`
- `colorGlowCore`, `Colors.white`, `_readyGlowAlpha` (BUG-20260825-002 pixel-identity)
- `Entry Point Reachability`, `Reachable: YES`
- `Story Runtime Startup Smoke`, `Runtime-Smoke: WAIVED`
- `VISUAL_FIDELITY`, `Design-Screen`, `Design-Surface`, `ui_surface`, `design_source`
- `Status: PENDING` / `Status: IN_PROGRESS` in the rework backlog

## Gate decisions

- Retro gate: `data/retro-audit/rework-backlog.md` has 0 `Status: PENDING` and
  0 `Status: IN_PROGRESS` items. Ordinary story review may proceed.
- Design-fidelity exemption check: `design-fidelity-config.json` has `ui_surface: true`
  and a locked `design_source` (`id: cupid-app`, `surface: mobile`); `story_master.md`
  records `Design-Surface: cupid-app` and `UI-facing story: YES`. Neither audited
  scope-out applies, so the per-story rendered visual-fidelity check is REQUIRED.
- Scope budget: within compact-story-review limits. No scoped-slice split needed.
- Phase 2 verdict: PROCEED to focused verification.

## Phase 2 outcome

Focused verification completed. Pass-1 outcome recorded in `review-report.md`:
`Outcome: PATCH_REQUIRED` (4 blocking findings F1-F4, 2 deferred findings D1-D2).

---

# Pass 2 — re-review after mobile-dev rework (2026-08-26)

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

- Review type: compact-story-review (2nd pass)
- Pass-2 BaseHead / HEAD: `0b5efe157394426b439c4f80e04973c50bbeb898`
- Rework diff reviewed: `d32f02f3c5fdeb0572c2ac2e8fb4831289d9142b..0b5efe157394426b439c4f80e04973c50bbeb898`
- Scope narrowed to the pass-1 findings F1/F2/F3 as evidence deliverables, plus an
  independent AC4 judgement on the recorded `VISUAL_FIDELITY: FAIL`. F4 was excluded
  from the rework handoff but is re-assessed against the mandatory runtime-smoke gate.

## Files in scope for pass 2

Changed by the rework (production code):
- `mobile/lib/main_preview.dart` (+7/-3, dev-only preview entrypoint)

New/changed evidence artifacts:
- `visual-fidelity/visual-fidelity-report.md`
- `visual-fidelity/design-reference-pairstart-android.png` (read as an image)
- `visual-fidelity/implemented-pairstart-emulator-5554.png` (read as an image)
- `coding-plan/test-results.md` sections 5-7 (ranged reads only)
- `story_master.md` (`Design-Screen` + Artifacts hunk, via diff)

Not re-read per handoff `Do Not Re-read`: `ux/ux-spec.md`,
`pairing_choice_screen.dart`, `cupid_icons.dart`, `cupid_color_tokens.dart`,
`pairing_choice_screen_test.dart`. AC1-AC3 and the BUG-20260825-002 pixel-identity
finding were verified in pass 1 and are unchanged by this diff.

## Query keys for pass 2

- `VISUAL_FIDELITY`, `Design-Screen: pairstart`, `list-screens`, `pairingchoice`
- `Entry Point Reachability`, `Reachable: YES`
- `Story Runtime Startup Smoke`, `Runtime-Smoke: WAIVED`
- `Để sau, xem trước app đã` (delta D-1), canvas chrome (D-2), row-3 wrap (D-3)

## Gate decisions

- Design-fidelity exemption: unchanged, still REQUIRED (`ui_surface: true`, locked
  `design_source` `cupid-app`, `Design-Surface: cupid-app`).
- Mobile-lane rule: reviewer verifies the implementer's capture by READING both
  images; no re-capture. Done.
- Phase 2 verdict: PROCEED. Outcome `PATCH_REQUIRED`, scoped to F4 only; F1/F2/F3
  cleared and the `FAIL` token accepted as deferred (D1, `product-owner`).
