# Review Report — STORY-047 Pairing Chain Undisclosed Deviation Triage

Outcome: CLEAN

Review type: `compact-story-review` · Story-Class `standard` · Complexity `trivial` · Lane `mobile`
Reviewed at BaseHead `e5ab67046f51927b47427a858a4df218f526e0dc` (worktree `/Users/alantravala/workspace/snapsofts/cupid-apps`, branch `main`).

## Scope Gate

In-scope ACs: AC1, AC3, AC4, AC5. AC2 descoped 2026-08-18 into
`REQ-004_notifications_dnd_banner_copy_reconciliation` (ADR-002 copy-guard conflict);
its absence is not treated as a defect.

Source/test files in scope (8, within compact budget):

| File | AC |
| --- | --- |
| `mobile/lib/features/pairing/presentation/screens/joincode_screen.dart` | AC3, AC4, AC5 |
| `mobile/lib/features/onboarding/presentation/screens/onboarding_profile_setup_screen.dart` | AC1 |
| `mobile/lib/main_preview.dart` | capture seeding |
| `mobile/test/features/pairing/presentation/joincode_screen_test.dart` | AC3, AC4, AC5 |
| `mobile/test/features/pairing/presentation/screens/joincode_screen_design_test.dart` | AC3 tokens |
| `mobile/test/features/onboarding/presentation/screens/onboarding_profile_setup_screen_test.dart` | AC1 |
| `mobile/test/features/auth/presentation/screens/auth_leg_edges_test.dart` | AC1 regression |
| `mobile/test/features/onboarding/permissions_screen_test.dart` | AC2 boundary only |

Evidence in scope: `visual-fidelity/visual-fidelity-report.md` + all 8 PNGs;
`story_master.md` §"Product Owner Triage" and §"Blocker (2026-08-18)".

Query keys: `_ctaLabel`, `_CodeSlotField`, `_CodeSlot`, `_pasteCode`,
`_InviteCrossLink`, `OnboardingNode.invite`, `errorText`, `_codeLength`.

## AC Verification

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC1 — `profile` CTA copy | PASS | `onboarding_profile_setup_screen.dart:407` now `context.viEn('Tiếp tục → Ghép đôi', 'Continue → Pair up')`, matching `Cupid Screens.dc.html:117`. `onPressed` untouched — `auth_leg_edges_test.dart` still asserts the tap lands on `pairingChoice` and cannot pop. Rendered `implemented-profile-*.png` reads the new label. |
| AC3 — 6 segmented slots | PASS | `_CodeSlot` applies `colorSurface` fill, `radiusSmall`, 1.5px `colorLine`/`colorAccentPink`/`colorRed` borders, `glowShadow` on active, `labelMono` 21px w500. All four states verified in the rendered PNGs (see below). §9 preserved: slots are an `ExcludeSemantics`+`IgnorePointer` overlay over ONE `TextField` that retains the accessible name (`hintText`) and the `errorText` description binding; `JoincodeCubit.submit`/`isBusy` untouched. |
| AC4 — `Dán` paste | PASS | `_pasteCode` trims, uppercases and truncates to `_codeLength` (6), exactly as the AC states; `_PasteButton` renders 48px / `radiusButton` / 1.5px `colorLine` with the `content_paste` glyph. Three tests cover normal paste, over-length truncation (`ABCDEFGH` → `ABCDEF`), and null clipboard (leaves entry untouched). |
| AC5 — creator cross-link | PASS | `_InviteCrossLink` → `_router.push(context, OnboardingNode.invite)`. The test proves push-not-reset properly: after tapping, `JoincodeScreen` is still on the stack offstage, and popping back restores the half-typed `3F9`. |

## Design Fidelity (mobile lane, rule 12e3)

`VISUAL_FIDELITY: PASS` verified by opening all 8 PNGs, not by trusting the token.

Both references depict the correct screens (`Hồ sơ của bạn` profile frame;
`Nhập mã ghép đôi` join-code frame) — not a placeholder, wrong screen, error
frame or spinner. All six implemented captures are real, distinct emulator
frames (timestamps 10:14–10:18, sequential and fresh).

The four AC3 states each match the report's written description:

- empty — six idle slots, pink caret in slot 1, no glow
- partial (`3F9`) — slot 3 pink border + glow, caret in slot 4
- active (`3F9A2B`) — slot 6 pink border + glow, no caret
- error — all six borders red, glow suppressed, `Mã không đúng hoặc đã hết hạn` inline below the row

This is consistent with `_CodeSlot`'s logic (`glow = active && !hasError`,
`active: i == code.length - 1`, `caret: i == code.length`).

The five disclosed deviations are exactly what I see in the images, and each is
pre-adjudicated: app-bar chrome (uiux-spec Chrome Rules, "do not reopen"), the
`8 ký tự`/5-box reference contradiction (§3a ACCEPTED, backend ships 6),
absent `Quét QR` (§3d OUT OF SCOPE), the avatar glyph (§1a ACCEPTED), and the
zodiac helper wrap (cosmetic, capture width). Nothing undisclosed was found —
the report does not oversell its PASS.

Note: no literal `Design-Screen: <id>` marker line appears in the report, but
the Evidence table maps each screen id to its exact reference PNG and the
preview entrypoint records `cupidpreview://screen/<id>`; I independently
confirmed both references depict this story's screens, which is the substantive
check 12e3 exists to force. No action required.

## AC2 Boundary

Confirmed against the diff, not taken on trust: `permissions_screen.dart` and
`reminder_copy_guard_test.dart` have **zero** changes at BaseHead. The ADR-002
guard test still passes in my own run. `permissions_screen_test.dart` gained two
assertions only (+10/-0), pinning the current ADR-002-canonical copy in both
locales — correctly an AC2 *pin*, not an AC2 *implementation*. REQ-004 will need
to update those two assertions together with the screen.

## Risk Surfaces And Critical Gates

| Surface | Gate | Result |
| --- | --- | --- |
| Mobile interaction (input widget rewrite) | Targeted widget tests | PASS — re-run by reviewer, 58/58 |
| Mobile navigation / discoverability | AC5 push-not-reset test + router wiring read in code | PASS |
| Permissions / device API (clipboard read) | No new permission or dependency (`flutter/services.dart`) | PASS |
| Static analysis | `flutter analyze lib test` → 80 pre-existing `info` issues, none new | PASS (implementer evidence) |
| Build | `flutter build apk --debug -t lib/main_preview.dart` across preview seeds | PASS (implementer evidence) |
| Design fidelity (12e2/12e3) | 8 rendered PNGs opened and compared | PASS |
| Entry point reachability (12e1) | Both screens are existing in-chain surfaces; AC5 adds a discoverable in-body cross-link verified in code and by test | PASS |
| Runtime startup smoke (12g) | Not required — story is `Complexity: trivial`. Emulator captures and the debug APK build nonetheless show the app launching to both screens. | N/A |

Reviewer re-run (rule 18, targeted regression on the rewritten widget):
`flutter test` over the six scoped files → `00:02 +58: All tests passed!`.

No configuration/setup impact: no env vars, no new dependency, no runtime
registry change — `configuration-guide.md` verification not applicable.

## Findings

Blocking: 0. Deferred: 0.

No new deferred findings requiring rework-backlog items. Two observations
recorded here only, neither affecting the outcome and neither warranting a
backlog split:

1. `_contentPasteIcon` (codepoint `0xe14f`) is declared file-locally because
   `CupidIcons` does not expose it and `design_system/` was outside this story's
   write scope. This is documented in-code and follows the existing
   `invite_screen.dart` precedent — a deliberate, scope-correct choice.
2. The `_pasteCode` doc comment says the truncation lets "a pasted invite link
   tail" land. Accurate for a bare tail; pasting a full URL would yield the
   first 6 characters of the URL instead. Behaviour matches AC4's literal
   "trimmed, uppercased, truncated to 6 characters", so the AC is met — only
   the comment slightly oversells the case.

## Traceability

- Requirements: `story_master.md` §"Product Owner Triage (2026-08-18)" AC1/AC3/AC4/AC5, each carrying a `Cupid Screens.dc.html` line citation, all satisfied verbatim (rule 14 — no substitutions accepted).
- UX: `ux/uiux-spec.md` §9 single-accessible-field contract preserved; §4/§5 `NO_CHROME` unchanged.
- Architecture: none required (`SKIPPED:trivial`, correct under the Lane Consistency Rule — every AC is single-lane `mobile`).
- Evidence: `visual-fidelity/visual-fidelity-report.md` + 8 PNGs; implementer test/analyze/build runs; reviewer re-run above.

## State Recommendation

- Keep `Implementation (Development)` checked
- Check `Review (Reviewer)`
- Story status → `DONE`
- RWB-20260816-024 may be resolved for the `profile` and `joincode` screens.
  Two items from its original triage remain open by design and should stay
  tracked outside this story: AC2 / `permissions` copy (owned by REQ-004) and
  `Quét QR` scanning (§3d, needs Tech Lead solutioning for camera package and
  platform permissions).
