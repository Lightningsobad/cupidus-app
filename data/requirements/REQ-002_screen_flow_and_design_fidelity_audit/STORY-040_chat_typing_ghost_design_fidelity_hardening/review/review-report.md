# STORY-040 Review Report — Chat + Typing Ghost Design Fidelity Hardening

Outcome: DEFERRED_ONLY

- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Story: STORY-040 (RWB-20260816-007 hardening of STORY-018)
- Review type: `compact-story-review`
- Reviewer: Iris-QC
- Date: 2026-08-17
- Worktree: `/Users/alantravala/workspace/snapsofts/cupid-apps`
- Branch: `main` · BaseHead: `9da5d2ce02ae8b0b1529061886057f16d26c371b`
- Complexity: `trivial` · Implementation Lane: `mobile` · Retro-Type: RED-PATCH

## Scope Gate

Phase: SCOPE_GATE — inline (compact review, no separate `scope-gate.md`).

Source/test files in scope (4, from `git diff --name-only <BaseHead>`):

- `mobile/lib/features/chat/presentation/widgets/chat_composer.dart` (D2/AC4)
- `mobile/lib/features/chat/presentation/screens/chat_screen.dart` (N1/AC6)
- `mobile/lib/main_preview.dart` (capture fixture)
- `mobile/test/features/chat/presentation/chat_design_fidelity_test.dart` (AC4)

Evidence files in scope: `visual-fidelity/visual-fidelity-report.md` plus all
three PNGs in the same directory.

Query keys: `_GhostToggleButton.build`, `_isPinnedToBottom`, `wrapInShell`,
`VISUAL_FIDELITY`, `RWB-20260816-016`, `BUG-20260817-001`.

Risk surfaces: mobile interaction, mobile navigation/discoverability, app
lifecycle (frame-boundary crash). Not touched: persistence, schema, auth,
external integration, config.

The four remaining diff entries (`master_bugs_list.md`, `req_master.md`,
`rework-backlog.md`, `scrum-master-checkpoint.md`) are Scrum Master-owned
workflow state, not implementation; excluded from review scope.

## Acceptance criteria

| AC | Verdict | Evidence |
| --- | --- | --- |
| 1 | PASS with deferral | Rendered-to-rendered pair present and inspected. All remaining visible deltas are governed exclusions except R-1 below. |
| 2 | PASS | 25-deviation table re-verified off the renders; measurements consistent with what I observe in both images. |
| 3 | PASS | Ghost bubble is live in `implemented-chat-emulator-5560.png`: struck faded tail `em sai rồi`, kept run at full brightness, pink block cursor, `Linh đang nghĩ…` header. AC3's core claim is now render-backed, not token-argued. |
| 4 | PASS | Fix + platform-parameterized test verified independently (see Gates). |
| 5 | PASS | No `mobile/lib/design_system/` path in the name-only diff. `RWB-20260816-016` present in `rework-backlog.md`. |
| 6 | PASS | N1 corrected in app code; N2 correctly referred out per the story's own split-out disposition; V-1 correctly retained. |
| 7 | PASS | Evidence pair + supplementary capture + report with `VISUAL_FIDELITY: PASS` all present in `visual-fidelity/`. |
| 8 | PASS | No new entry point. Chat reachable via the `Trò chuyện` tab — visible as the active tab in the implemented capture, independently confirmed from the render rather than from the claim. |

## Gates independently rerun

| Gate | Result |
| --- | --- |
| `flutter analyze --no-fatal-infos lib test` | `80 issues found`, exit 0. Every line is `info`; **0 errors, 0 warnings**. None in the four files this story touched. Matches the report's claim. |
| `flutter test test/design_system/no_fork_guard_test.dart test/features/chat --reporter compact` | `+64: All tests passed!` Includes both new AC4 platform cases and the ADR-004 no-fork guard. Matches the report's claim. |
| AC4/D2 test is a real guard, not a tautology | **Verified.** Nesting at `chat_composer.dart:355-366` is `SizedBox(slot) > Center > InkWell > Container(46x46) > Column > Icon(blur_on)`. `ghostVisual()` resolves to that 46x46 `Container` — there is no intermediate `Container` between it and the icon, so the finder targets the constrained widget. Pre-fix on the iOS axis the slot is a tight 44x44, `Center` relays loose `0..44`, and the 46 `Container` clamps to 44x44, failing `expect(getSize(...), Size(46,46))` exactly as the report records. Verified by widget-tree structure rather than by mutating delivered source. |
| Visual fidelity evidence | Both `implemented-chat-emulator-5560.png` and `design-reference-chat-android.png` open as real images and depict the chat screen. `Design-Screen: chat` is recorded and the reference is that screen. `VISUAL_FIDELITY: PASS` matches my own read of the body. |
| `wrapInShell` restored in delivered source | Confirmed — 0 occurrences in `git diff <BaseHead> -- mobile/lib/main_preview.dart`. |

## Known out-of-scope items — confirmed correctly left untouched

- **D1** (`colorOnAccent`): no `design_system/` file in the diff; `RWB-20260816-016` registered. Correct.
- **N2** (shell FAB occludes send button): no `core/navigation/` file in the diff; `BUG-20260817-001` registered. Correct. I can see the occlusion directly in the implemented capture — the pink account-hub FAB sits exactly where the send button belongs and no send button is visible. The finding is real and the referral is the right call.
- **V-1** (input pill 48pt vs 46pt): reasoning holds. The pill *is* the text field's touch surface, so constraining it to 46 would drop the primary input below the Material 48pt minimum to buy 2pt of pixel fidelity — the opposite trade from D2, where the 46pt box is decoration inside a larger slot. `ux/uiux-spec.md` §5 precedent applies. No fix forced.

## Deferred findings

**R-1 — chat header delta is visible in the evidence pair but not recorded anywhere in the report.**
The reference renders `Minh ↔ Linh` plus a `đang online` presence chip at top-right; the implemented capture renders `Linh` alone with no presence chip. Root cause is pre-existing and documented in code at `chat_screen.dart:164-169` — `CupidHeader` exposes a title string only, with no avatar/presence slot, reused as-is rather than reopening a frozen shared component. Correcting it means touching `design_system/adaptive/`, which this story's Out of Scope forbids, so the code disposition would be "defer" regardless; the defect is that the report's out-of-scope enumeration lists seven divergences and omits this one. In a hardening story whose entire deliverable is a complete rendered comparison, an undisclosed visible delta is worth tracking. Recommend Scrum Master add it as a follow-up rework-backlog item under the same RWB-014/015/016 split-out pattern. Not blocking: it is pre-existing, this story did not make it worse, and it does not contradict any claim the `PASS` actually rests on.

**R-2 — N2 is a functional production defect, not a visual one.** The chat screen's primary action is unreachable in the shipped app. Correctly referred out of this story, but `BUG-20260817-001` warrants priority ahead of ordinary visual backlog.

## Rationale

The story delivers what RWB-20260816-007 asked for: STORY-018's fidelity claims are now backed by an actual render with the Typing Ghost state live, which is precisely the state STORY-018 never captured. Two real defects were found by rendering that code reading had missed — the D2 iOS clamp and the N1 frame-boundary crash — and both are fixed with correct engineering judgment in each direction.

Three things raise confidence rather than lower it: the report self-discloses the reference-coverage gap (the design canvas cannot drive `partnerDraft`, so the ghost region is verified against the design source plus render measurement rather than pixel-to-pixel); it discloses the temporary `wrapInShell: false` capture and proves the flag was restored; and it declines to add a synthetic test for N1 with a correct explanation — `flutter_test` drives build, layout and paint synchronously inside one `drawFrame`, so such a test would pass both before and after the fix and would prove nothing. I accept the on-device stack trace as the evidence rather than demanding a tautological test.

Outcome is `DEFERRED_ONLY` rather than `CLEAN` solely because of R-1.

## State recommendation

- Keep `Implementation (Development)` checked.
- Check `Review (Reviewer)`.
- Story status: `DONE`.
- Scrum Master to record R-1 as a new rework-backlog item before closure.
