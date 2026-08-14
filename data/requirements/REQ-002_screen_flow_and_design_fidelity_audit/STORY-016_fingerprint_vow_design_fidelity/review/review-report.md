# STORY-016 Review — Design Fidelity: Fingerprint Vow

Outcome: DEFERRED_ONLY

| Field | Value |
| --- | --- |
| Story | STORY-016 Design Fidelity — Fingerprint Vow |
| Requirement | REQ-002 Screen Flow And Design Fidelity Audit |
| Mode | compact-story-review |
| Reviewer | Iris-QC-3 |
| Worktree | `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-016` |
| Branch | `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-016` |
| BaseHead | `4eadb3d871890a9a830d1e9ddb8a161e69a7d6a3` |
| Worktree HEAD | `213793d9271110b3d399855c9b38c6be048fdac0` (single commit, clean tree) |
| MergeTarget | `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration` |
| Merge eligible | YES |

## Diff under review

12 files, +1280/-3. Code: `mobile/lib/features/vow/presentation/screens/vow_screen.dart`
(new, 673 lines), `mobile/lib/features/vow/presentation/vow_strings.dart` (new),
`mobile/lib/design_system/decorations/cupid_star_field.dart` (new),
`mobile/lib/design_system/tokens/vow_palette.dart` (new),
`mobile/lib/design_system/design_system.dart` (+2 export lines),
`mobile/lib/design_system/icons/cupid_icons.dart` (+2 glyph constants),
`mobile/lib/main_preview.dart` (+preview entry, `vow` removed from
`_notImplementedCanvasIds`),
`mobile/test/features/vow/presentation/screens/vow_screen_test.dart` (new, 8 tests).
Artifacts: `story_master.md`, `visual-fidelity/` report + 2 captures.

## Verification re-run by the reviewer (not taken on trust)

| Gate | Command | Result |
| --- | --- | --- |
| Static analysis | `flutter analyze --no-fatal-infos lib/features/vow lib/design_system lib/main_preview.dart test/features/vow` | **No issues found!** (4.8s) |
| Story tests | `flutter test test/features/vow/presentation/screens/vow_screen_test.dart` | **+8: All tests passed!** |
| No-fork guard | `flutter test test/design_system/no_fork_guard_test.dart` | RED with exactly the 7 documented pre-existing violations, none in this diff |
| Tree state | `git status --porcelain` in worktree | clean |

## Traceability

| AC | Requirement | Evidence independently checked | Verdict |
| --- | --- | --- | --- |
| AC1 | Layout, spacing, colour/token usage and typography match the locked source in dark + `vi` | Spot-checked against `Cupid Screens.dc.html:206-226` and `Cupid App.dc.html:30`, not against the report's own table. `colorAccentPink`=`#FF7FB6`=`--pink`; `colorAccentPurple`=`#B78CF5`=`rgba(183,140,245)`; `colorMint`/`colorGreen`=`#79E2CD`=`--mint`/`--green`; `colorLine`=`rgba(247,238,251,.11)`=`--line`; `colorTextMuted`=`#B4A6CE`=`--tx2`; `colorBackground`=`#171129`=`--bg`; `CupidSpacing.lg`=24=`24px`; `display`=Nunito w900 (→29px/1.15)=`font-family:Nunito;font-weight:900`; `labelMono`=Roboto Mono, `_eyebrowLetterSpacing`=10×0.2=2.0=`.2em`; CTA radius from `cupidPlatform.radiusButton`=`--r-btn:999px`. Every off-grid pixel constant (`vow_screen.dart:65-95`) matches the source verbatim: 34/30/12/8/150/154/78/72/38/34/14/6/52/26/16.5/40. Copy strings verified against the source's own binding table at `Cupid Screens.dc.html:2158-2159` (`sẵn sàng`/`đang đợi`, `ready`/`waiting`) — transcribed, not invented. Side-by-side captures agree. | PASS |
| AC2 | Deviations corrected in the rendered app, not merely documented | Confirmed the "no screen existed" claim directly: `mobile/lib/features/vow/` is added wholly by this diff and `vow` is removed from `_notImplementedCanvasIds` in `main_preview.dart`. The screen is now rendered and captured (`implemented-vow-emulator-5560.png`), and the one post-capture delta (missing twinkle particles) is fixed in code by `CupidStarField`, not written up as an outstanding item. | PASS |
| AC3 | Hold-to-sign affordance uses the source's `pulseRing` animation and visual style | `_PulseRing` (`vow_screen.dart:415-463`) reproduces `@keyframes pulseRing{0%{scale(.9);opacity:.7}70%{scale(1.5);opacity:0}100%{opacity:0}}` (`Cupid App.dc.html:35`) at 1900ms with `Curves.easeOut`, over a 2px `--pink` ring. The intentional dwell deviation holds up on inspection: `_HoldDwellPainter` (`:381-409`) deflates by `borderWidth/2` = 0.75, giving arc radius 74.25 — exactly the centre-line of the disc's existing `Border.all(width: 1.5)` inside-stroke on a 150px circle. It therefore repaints the stroke the source already draws at full-alpha pink; no new ring, radius, thickness or hue. Accessibility parity verified by executing the path, not reading it: the passing test at `vow_screen_test.dart:167-190` performs `SemanticsAction.tap` on `vow_hold_target` and the vow signs instantly. | PASS |
| AC4 | Each source state (idle, holding, first-signed, both-signed) matches | Idle and holding as above. Signed disc (`:509-526`): 154px, `colorMint` α0.16 fill, 2px mint border, 72px `checkCircle`, `boom` two-segment curve matching `@keyframes boom{0%{scale(.2);opacity:0}55%{scale(1.18);opacity:1}100%{scale(1)}}`. Both-signed CTA (`:627-672`): 52px, 26px horizontal padding, `colorGreen` fill, `#04231E` ink, 16.5px w700 — matches `Cupid Screens.dc.html:225`. Four widget tests pin the state matrix including a hard assertion that the signed disc is exactly `#79E2CD` α0.16 with a 2px border. | PASS |
| AC5 | No new entry point | Independently confirmed by `git grep VowScreen` across `mobile/lib` and `mobile/test`: the only construction sites are `main_preview.dart:241` (dev-only capture harness) and the test harness. The diff touches no router, shell, or navigator file at all — `main_preview.dart` is the sole `lib` file changed outside `features/vow` and `design_system`. | PASS |

## Risk surfaces and gates

| Surface | Gate | Result |
| --- | --- | --- |
| Cross-story collision with STORY-032 (shared app-shell/theme scope) | `git diff BaseHead -- cupid_sky_palette.dart cupid_app_background.dart cupid_theme.dart` | CLEAR — zero entries for all three. `CupidStarField` is a new `decorations/` file and `VowPalette` a new `tokens/` file; no shared theme/palette file is modified. |
| Barrel/icon file contention | `design_system.dart` +2 export lines, `cupid_icons.dart` +2 constants | Low. Both are append-only additions; a concurrent story appending to the same lists would produce a trivial textual conflict, not a semantic one. Flagged for the integration merge, not blocking. |
| Design-system fork guard | `no_fork_guard_test.dart` re-run | New `lib/features/vow/**` code contributes **zero** violations. The 7 reds are in `ghost_settings_screen.dart:211,411`, `notification_settings_screen.dart:360`, `reminder_schedule_screen.dart:449,450,453`, `reminder_weekday_chips.dart:71` — none appears in this diff's changed-file list, so they are pre-existing and unchanged from `BaseHead`. |
| Additive feature palette placed in `design_system/tokens/` | Precedent check | Genuine, not invented: `couple_presence_palette.dart`, `pet_hero_gradient.dart`, `splash_palette.dart`, `mood_face_palette.dart`, `bun_sprite_palette.dart` already follow this pattern. No existing shared token is modified. |
| 1500ms dwell consistency | Cross-check against shared ritual | `HoldToSignButton.holdDuration` is `Duration(milliseconds: 1500)` (`hold_to_sign_button.dart:26`). Consistent. |
| Star-field interactivity | `pointer-events:none` parity | `ExcludeSemantics` + `IgnorePointer` both present in `cupid_star_field.dart:19-20` and pinned by a passing test asserting `ignoring == true`. Painted as the last `Stack` child (`vow_screen.dart:272`), matching the source's positioned-sibling paint order (`Cupid Screens.dc.html:44-47`). |

## Deferred findings (named owners, none blocking)

| # | Finding | Owner |
| --- | --- | --- |
| D1 | The screen ships unreachable. `VowScreen` has no app route; only the dev preview harness renders it. This is correct per AC5 and the story's Out of Scope, but `lib/features/vow/**` is dead code in the shipped app until the flow is wired. Requirement integration review must confirm STORY-001/STORY-002 actually land the `vow` entry point, otherwise REQ-002 closes with an unreachable screen. | STORY-001 / STORY-002 + requirement integration review |
| D2 | Duplicate twinkle-star implementations: `mobile/lib/features/pairing/presentation/screens/waiting_screen.dart:355-412` keeps a private `_TwinkleStar`/`_SkyBackdrop` alongside the new shared `CupidStarField`. Verified as a legitimate deferral, not scope-dodging: `waiting_screen.dart` is not in this story's diff and belongs to STORY-013's screen, so consolidation cannot be done from inside STORY-016's touched files. | design-system consolidation story |
| D3 | `CupidStarField` is applied to `vow` only, although `Cupid App.dc.html:100` labels it the shared backdrop of every screen ("nền chung mọi screen"). Rolling it into the app shell is app-wide background scope. | STORY-009 / STORY-032 (app-shell background) |
| D4 | Documentation-only inaccuracy in `visual-fidelity/visual-fidelity-report.md`: the transcription table's Title row names a `headline` token, but the code correctly uses `type.display` and no `headline` token exists in `CupidTypographyTokens`. Code is right; the table wording is wrong. | Alex-Mobile-Dev (optional) |
| D5 | Classification drift: `story_master.md` records `Complexity: trivial` / `Story-Class: trivial`, but the delivered change is a from-scratch 673-line screen (+1280 LOC). The handoff's `Story-Class: standard` and the named Reviewer gate were the correct treatment; the story_master fields should be reconciled so the record matches the gate that was actually run. | Helen-SC |
| D6 | No golden baseline. `matchesGoldenFile` would create a new `test/features/vow/.../goldens/` tree; the 8 widget tests are the in-scope regression guard. | goldens-owning story |
| D7 | Only the idle state has a paired design-reference capture — the design canvas drives `myVowed` from its own prototype click handler, so no reference frame can be rendered for the signed/both states. Accepted; the preview harness already exposes `PREVIEW_VOW_STATE=signed\|both` for a later manual capture. | requirement integration review (optional) |

## Nits (recorded, no owner assigned)

- `_HoldDwellPainter` uses `StrokeCap.round`, adding rounded arc ends the source's plain border does not have. Sub-pixel at a 1.5px stroke.
- The source's first star also carries a static `opacity:.5`, which `CupidStarField` does not reproduce. Correct as implemented: the infinite `twinkle` animation animates `opacity` at every keyframe, so the animated value wins for the whole run and the static value is dead.
- `boom`/`twinkle` apply their easing curve across the whole cycle rather than per keyframe segment as CSS does. Visually indistinguishable at these durations.

## Conclusion

All five acceptance criteria pass on independent verification. Every load-bearing
claim in the implementation report was checked against the locked design source
or by re-running the gate, and each one held: no screen existed at `BaseHead`,
the values are transcribed rather than invented, the hold-dwell deviation is the
minimal in-vocabulary treatment it claims to be, the star field reproduces the
source's paint order and non-interactivity, the `no_fork_guard` red is genuinely
pre-existing, and there is no overlap with STORY-032's shared app-shell scope.

Outcome: DEFERRED_ONLY — merge eligible.
