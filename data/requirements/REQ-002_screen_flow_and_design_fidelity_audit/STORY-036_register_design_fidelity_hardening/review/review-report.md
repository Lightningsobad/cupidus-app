# Review Report: STORY-036 Register Design Fidelity Hardening

Outcome: DEFERRED_ONLY

Review type: `compact-story-review`
Story: `REQ-002_screen_flow_and_design_fidelity_audit/STORY-036_register_design_fidelity_hardening`
Complexity: trivial | Story-Class: trivial | Implementation Lane: mobile (single-lane, confirmed)
Rework item: RWB-20260816-003 (RED-PATCH retro-hardening — retro/rework work, so rule 1a's pending-RWB refusal does not apply)
Diff baseline: `git -C <worktree> diff 37b47c93108634d8a08e4a8f3d5286eef4eb3b51`

## Scope Gate

Source/test files in scope (3, within compact budget):
- `mobile/lib/features/auth/presentation/screens/register_screen.dart` (22 KB — ranged reads only: 1-60, 160-189, 355-434)
- `mobile/lib/main_preview.dart`
- `mobile/test/features/auth/presentation/screens/register_screen_test.dart`

Evidence files in scope:
- `story_master.md` (`## Acceptance Criteria`, `## In/Out Of Scope`)
- `visual-fidelity/visual-fidelity-report.md`
- `visual-fidelity/implemented-register-emulator-5560.png`, `visual-fidelity/design-reference-register-android.png`
- `scrum-master-checkpoint.md`

Corroborating reads (claim verification only, ranged):
- `cupid-app-design-system/project/Cupid Screens.dc.html` lines 1-60, 1462-1497 (AC2 headline claim, AC3 empty-state claim)
- `data/devops/system/design-fidelity-config.json` (design source locked, `ui_surface: true`)
- `STORY-002_onboarding_pairing_navigation/ux/uiux-spec.md` (NO_CHROME waiver)

Query keys: `_fieldInputLineHeight`, `strutStyle`, `_focusRingWidth`, `foregroundDecoration`, `line-height`, `NO_CHROME`, `RegisterScreen(`.
Trivial story: no `coding-plan/master-plan.md` required (rule 9).

## Acceptance Criteria

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC1 layout/spacing/color/typography match | PASS | Rendered pair inspected directly. Both PNGs open as real images, both depict the register screen (`Tạo tài khoản`), dark theme + `vi`, same seeded row. Measured table matches on padding, card pitch, fills (#241B42), radius, meter geometry/tokens, CTA. One visible difference — header chrome — is a governed deviation, see below. |
| AC2 deviation corrected in code, re-verified | PASS | Root cause independently plausible and consistent: Material 3 `bodyLarge` reserves a 1.5 line box (24 dp at 16 px), matching the report's measured 24.2 dp against the design's ~19.9 dp. Fix present in the diff at `register_screen.dart:412-416` (`StrutStyle(fontSize: 16, height: 1.25, forceStrutHeight: true)`) plus `_fieldInputLineHeight` at line 34. Fresh render pair post-fix: card 68.04 vs 67.84 dp, input baseline identical at 48.9 dp. Rationale carries a traceability defect — see DEF-1. |
| AC3 four validation states | PASS | `filled` verified by the rendered pair. `empty` — verified in the design source: the `<input>`s at lines 1477/1481/1485 carry no `placeholder`, so an empty controller with no `hintText` is the correct reading, not a fabrication. `focused` — `foregroundDecoration` border at `_focusRingWidth = 1.5` in `colorAccentPink` (`register_screen.dart:331`, `369-377`), reasoned from the canvas's own active-input treatment rather than invented; painted as foreground so it costs no layout inset. `error` — form-level message from `RegisterFailed` (`register_screen.dart:173-175`); no per-field error styling invented where the canvas composes none. Reasoning is sound for the three uncomposed states. |
| AC4 evidence pair in this story's own dir | PASS | `implemented-register-emulator-5560.png` (405x900) and `design-reference-register-android.png` (406x900) both present under this story's `visual-fidelity/`, alongside `visual-fidelity-report.md` recording `VISUAL_FIDELITY: PASS` with concrete deltas and named states — not a bare token. |
| AC5 no new entry point | PASS | Diff touches no navigation/routing file (3 files only, none under `core/navigation` or a router). `RegisterScreen`'s new `initialName`/`initialEmail`/`initialPassword` default to `''`, so the real entry point is byte-for-byte unchanged in behavior; only `main_preview.dart` (dev-only entrypoint) seeds them. Reachability independently confirmed: STORY-002 UX spec records the `welcome → register` and `login → register` edges, and `auth_leg_edges_test.dart` asserts "login the register link pushes register and keeps login underneath" (passing in this session's rerun). |

## Design Fidelity (rule 12e2 / 12e3, mobile lane)

Verified by reading the artifacts, not by trusting the verdict token. Not re-captured (device lifecycle is not reviewer scope).

- `Design-Screen: register` is recorded in `story_master.md:14`, and the reference image I opened does depict the register screen — not a different canvas screen, not a placeholder, not an error or blank frame.
- The implemented capture shows this story's screen in the built app, rendering cleanly (no red error screen, no spinner).
- Governed deviation — VERIFIED, not accepted on trust: the reference renders the canvas's shared header (pink back arrow + `Đăng ký`) because `register` is absent from the canvas's `NO_CHROME` list; the app omits it. `STORY-002_onboarding_pairing_navigation/ux/uiux-spec.md` section "Chrome Rules (NO_CHROME + NO_TABS)" (AC4) states the rule applies to every node `splash` through `fingerprint_vow` with "No header/app-bar chrome on any screen in this list", and `register` is in that node list (line 11). Adding the header would contradict an approved spec and regress sibling screens. The locked `design-fidelity-config.json` was not edited to hide the difference — confirmed, `design_source` still `locked: true` with its original fingerprint.
- Apart from that governed difference, the two images do not visibly contradict the `PASS`.

## Risk Surfaces And Critical Gates

| Surface | Gate | Result |
| --- | --- | --- |
| Mobile interaction / text layout | `flutter analyze` on both changed lib files | PASS — "No issues found! (ran in 1.5s)", rerun this session |
| Mobile interaction / text layout | `flutter test .../register_screen_test.dart` | PASS — 8/8, rerun this session; includes the new strut regression guard |
| Auth-feature regression | `flutter test test/features/auth/` | PASS — "All tests passed!", rerun this session (final counter reads `+113`; see DEF-3) |
| Mobile navigation / discoverability | Entry point unchanged, verified in code + passing edge test | PASS |
| Design fidelity (UI-bearing, design source configured) | Rendered pair present, opened, and cross-checked | PASS |
| Runtime startup smoke (rule 12g) | Not required — story is `trivial`; 12g scopes the gate to non-trivial stories | N/A (supporting: the app was launched on `emulator-5560` via `main_preview.dart` to take the capture, and it reached the screen without an error frame) |
| Setup/configuration (rule 12a) | No env, dependency, infra, or config change in the diff | Not applicable |

## Deferred Findings

- **DEF-1 (traceability, evidence + code comment).** The AC2 rationale attributes the design's field-input line height to `Cupid Screens.dc.html` line 1472. Line 1472 is the register block's H1 title (`font-family:Nunito;font-weight:900;font-size:26px;line-height:1.25`), not the field input; the `<input>`s at lines 1477/1481/1485 declare no `line-height`, and no global rule sets one in the canvas's atomics block. The value 1.25 is nonetheless correct — it is a *measured* match to what the browser computes for those inputs (validated by the differential capture and by card 68.04 vs 67.84 dp), not a transcribed design declaration. This matters because the same file already binds `_titleLineHeight = 1.25` (line 23) to that exact line-1472 declaration, so a future reader can easily mistake `_fieldInputLineHeight` for a transcribed token when it is an empirical fit. Affects `visual-fidelity-report.md` "Deviation Found And Fixed In App Code (AC2)" and the comment at `register_screen.dart:407-411`. Not blocking: the delivered behavior is correct and is proven by the rendered pair, which is AC1/AC2's governing evidence.
- **DEF-2 (residual, same root cause left unfixed).** The password card measures 107.0 dp against the reference's 104.2. I could not see this difference in the two images at 1:1, so it does not fail AC1's "no visible deviation". Worth preserving because the cause the report names — Flutter reserving more line box than Chrome for the 11 px strength caption — is the *same* class of defect this story just fixed for the field input, and the same forced-strut remedy is available for the caption `Text` if a later pass wants the residual closed. The report's tolerance sentence is also muddled: it reads as if 2.8 dp were "below the ~1 dp measurement noise", when its own explanation is ~1.5 dp of caption line box plus ~1 dp of noise.
- **DEF-3 (evidence transcription).** The verification table records `flutter test test/features/auth/` as "112 passed"; the rerun's final line reads `00:02 +113: All tests passed!`. Immaterial to the verdict — every test passes either way — but noted because evidence accuracy is this hardening story's whole subject.

## Blocking Findings

None.

## Traceability

- Requirements: `story_master.md` AC1-5, `## In Scope` 1-4, `## Out of Scope` (OQ5 light/`en` exclusion consistent with STORY-006 and STORY-035 precedent), `## Open Question Impact` (all ACs NOT BLOCKED — no OQ triage gap under rule 12).
- UX: `STORY-002_onboarding_pairing_navigation/ux/uiux-spec.md` "Chrome Rules (NO_CHROME + NO_TABS)" — governs the one visible reference/implementation difference.
- Architecture: SKIPPED:trivial per single-lane trivial routing — appropriate under rule 9.
- Testing: three commands rerun independently this session, all passing; regression guard added for the fix.
- Design source: `data/devops/system/design-fidelity-config.json` (`claude-design`, `locked: true`, `ui_surface: true`); `Design-Screen: register` resolved and recorded.

## State Recommendation

- Keep `Implementation (Development)` checked.
- Check `Review (Reviewer)`.
- Story status: `DONE`. Deferred findings DEF-1..DEF-3 are recorded here for future reference; none requires rework before closure.
- Owner note for Scrum Master: this story is `trivial`, so rule 12g does not require `## Story Runtime Startup Smoke`. If the DONE gate demands the section anyway, the available evidence is the `main_preview.dart` launch on `emulator-5560` performed to take the capture.
