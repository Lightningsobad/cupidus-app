# Review Report: STORY-037 Invite Design Fidelity Hardening

Outcome: DEFERRED_ONLY

Review type: compact-story-review | Cycle: 2 (re-review after B1 rework)
Story: REQ-002_screen_flow_and_design_fidelity_audit /
STORY-037_invite_design_fidelity_hardening
Lane: mobile | Complexity: trivial (Retro-Type RED-PATCH, RWB-20260816-004)
Diff baseline: `c3298028cf344a3cc0c2c0826269537e54587e20` (Worktree
`/Users/alantravala/workspace/snapsofts/cupid-apps`, branch `main`)

Cycle 1 result: PATCH_REQUIRED — 1 blocking (B1), 2 deferred (DEF-1, DEF-2).
Cycle 2 result: B1 resolved and independently re-verified; DEF-2 fixed; DEF-1
remains deferred and out of this story's scope.

## Scope Gate (cycle 2)

Changed files re-reviewed (2, both against `BaseHead`):
- `mobile/lib/features/pairing/presentation/screens/invite_screen.dart` (+5 −7)
- `mobile/lib/main_preview.dart` (+25 −2, unchanged since cycle 1)

Evidence re-examined:
- `visual-fidelity/implemented-invite-emulator-5560.png` (re-captured; reopened)
- `visual-fidelity/visual-fidelity-report.md` (backdrop rows, D2 section, G4)
- `visual-fidelity/design-reference-invite-android.png` (unchanged; not re-read
  per handoff, cycle-1 probes reused)

Design source re-queried: `Cupid Screens.dc.html:26` (`--sky` token),
`Cupid Screens.dc.html:209` (G4 CTA label).

Critical gates this cycle: rendered design-fidelity pair (12e2/12e3) — PASS;
static analysis — PASS; targeted widget/unit tests — PASS. Entry-point
reachability (12e1) re-confirmed unaffected: the routing wiring is untouched by
the cycle-2 diff.

## Per-AC Verdicts

| AC | Cycle 1 | Cycle 2 | Basis |
| --- | --- | --- | --- |
| AC1 — layout/spacing/colour/typography match with no visible deviation | FAIL | **PASS** | Backdrop now reproduces the `--sky` composite pixel-exactly; all other rows within tolerance |
| AC2 — any deviation found is corrected in app code | FAIL | **PASS** | Both surfaced deviations (D1 copy, D2 backdrop occlusion) fixed in app code and re-verified with a fresh capture |
| AC3 — code-display/share component styling incl. mono treatment | PASS | PASS | Re-derived in cycle 1; card geometry unchanged by the D2 fix |
| AC4 — evidence pair + `VISUAL_FIDELITY: PASS` in this story's own dir | FAIL | **PASS** | The recorded `PASS` is now consistent with what the two images show |
| AC5 — no new entry point required | PASS | PASS | Routing untouched by the cycle-2 diff |

## B1 Resolution — Verified, Not Taken On Trust

The fix is exactly the one recommended, at
`mobile/lib/features/pairing/presentation/screens/invite_screen.dart:169-176`:
the `backgroundColor: colors.colorBackground` override and the now-unused
`colors` local are gone, replaced by the `forgot_screen.dart:103-106` precedent
comment. The shared `CupidAppBackground` layer (`cupid_app.dart:59`) is no longer
occluded.

I re-opened the re-captured PNG: the sky wash and the star layer are now visible,
where cycle 1's capture was flat. Rather than check the report's arithmetic, I
re-derived the expected backdrop from scratch — reading the three dark-theme
`--sky` radial layers straight off `Cupid Screens.dc.html:26`, compositing them
in CSS paint order (teal, pink, purple, first-listed-is-topmost) over `--bg`
#171129 with a premultiplied `a(t) = a₀ · max(0, 1 − t/stop)` ramp on the
elliptical distance — and compared against 7 backdrop probes I chose myself:

| Probe (px) | Capture actual | My analytic `--sky` | Δ |
| --- | --- | --- | --- |
| (12, 60) | (57, 27, 92) | (57, 27, 92) | exact |
| (12, 100) | (52, 26, 84) | (52, 26, 85) | ΔB 1 |
| (395, 100) | (85, 33, 67) | (85, 33, 68) | ΔB 1 |
| (10, 500) | (23, 17, 41) | (23, 17, 41) | exact |
| (396, 420) | (23, 17, 41) | (23, 17, 41) | exact |
| (200, 800) | (22, 28, 49) | (22, 28, 49) | exact |
| (200, 860) | (21, 35, 53) | (21, 35, 53) | exact |

Five exact matches and two within one unit of blue. The implementation does not
merely "have a gradient now" — it reproduces the design source's specified
backdrop to the byte. Cycle 1's same probes read a flat (23,17,41) everywhere.

The four new rows in `visual-fidelity-report.md`'s measured table are honestly
derived, not eyeballed. I arrived independently at the same analytic model the
report describes, and each claimed implementation value is findable in the
capture at the expected location — (61,29,98) near the layer-1 axis, (93,35,71)
near the layer-2 centre at (385,54), (21,36,54) along the bottom edge. The
report's reference-side top-right (87,33,68) matches my own reference sample at
(385,54) of (86,32,68).

Card geometry is unaffected by the fix, as claimed: the `--surf` (36,27,66) card
run still measures x 20-384 = 365 px = 372.0 dp against the 372 dp anchor, and
the fill colour is still exactly `--surf`.

## DEF-2 Resolution

Fixed and verified against the design source. `Cupid Screens.dc.html:209` reads
`onClick="{{ goWaiting }}"` with
`<span data-vi>Tiếp tục → Đợi ghép</span><span data-en>Continue → Waiting</span>`,
which is what the corrected G4 row now states. The deviation itself remains
governed (separate-node scope, STORY-011 plan §1 D2); only the label was wrong.

## Verification Commands (re-run independently this cycle)

| Command | Result |
| --- | --- |
| `flutter analyze lib/features/pairing/presentation/screens/invite_screen.dart lib/main_preview.dart` | 0 errors, 0 warnings; 3 `info` `prefer_initializing_formals` at `invite_screen.dart:73,74,102` |
| `flutter test test/features/pairing test/design_system/no_fork_guard_test.dart` | **All tests passed!** (98 tests) |

Both reproduce the reported evidence exactly. The 3 infos sit on constructor
lines at 73/74/102, outside both diff hunks (≈169-176 and ≈380-386), so they
remain correctly classified as pre-existing. No unused-local diagnostic appeared,
confirming the `colors` local was removed together with its only use.

## Deferred Findings

- **DEF-1 — six sibling screens carry the same opaque Scaffold override.**
  `otp_screen.dart:79`, `love_contract_screen.dart:109`,
  `onboarding_profile_setup_screen.dart:85`, `permissions_screen.dart:107`,
  `joincode_screen.dart:125`, `vow_screen.dart:169` all still set
  `backgroundColor: colors.colorBackground` and will occlude the same
  `CupidAppBackground` sky layer on their own screens. Out of STORY-037's
  single-screen scope and explicitly excluded from this cycle's blocking check.
  Root cause is that REQ-002 STORY-032's remediation was never swept to its
  remaining call sites; recommend Scrum Master queue a requirement-level sweep so
  the same class of defect is not rediscovered one screen at a time.
- **DEF-2 — closed this cycle.** Retained here only for traceability.

## Traceability

- AC1-5 from `story_master.md`; governed deviations G1-G4 verified against
  `Cupid Screens.dc.html` (`isInvite` block 176-186, tokens 23-26,
  `NO_CHROME`/`NO_TABS` 1960, CTA 209) and STORY-002's approved
  `ux/uiux-spec.md` `## Chrome Rules`.
- Design-fidelity evidence pair complete in this story's own `visual-fidelity/`
  with `VISUAL_FIDELITY: PASS` warranted by the images (12e2/12e3).
- Entry point verified in code at `pairing_choice_screen.dart:39` (cycle 1),
  untouched by the cycle-2 diff.
- Runtime startup smoke (12g) not required: story is `trivial`; the emulator
  capture independently shows the app launching and reaching the screen.

## State Recommendation

- Keep `Implementation (Development)` checked; check `Review (Reviewer)`.
- Story status: `DONE`.
- DEF-1 to be carried by Scrum Master as a separate requirement-level item.
