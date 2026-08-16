# Review Report: STORY-014 Design Fidelity — Paired Success

Reviewer: Iris-QC
Mode: compact-story-review
Flow: parallel-story
Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Story: STORY-014 Design Fidelity — Paired Success
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-014`
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-014`
Diff baseline: `8396273e6a5e6a2798557aa68864f0ef24cd939b`
Implementation commit reviewed: `2aea224`

## Outcome

Outcome: DEFERRED_ONLY

No blocking defect. Every acceptance criterion is met against the locked design
source. Two deferred findings (F1, F3) and three accepted-with-note items are
recorded below; F3 carries a residual risk that must be tracked into REQ-002
integration review.

## Review Scope

Diff reviewed (6 files, +738/-74):

- `mobile/lib/features/pairing/presentation/screens/paired_screen.dart` (+310/-67)
- `mobile/lib/design_system/tokens/couple_avatar_gradients.dart` (new, +31)
- `mobile/lib/design_system/design_system.dart` (+1 export)
- `mobile/test/features/pairing/presentation/paired_screen_test.dart` (+69/-6)
- `data/requirements/.../STORY-014_paired_success_design_fidelity/visual-fidelity/visual-fidelity-report.md` (new)
- `data/requirements/.../STORY-014_paired_success_design_fidelity/story_master.md` (artifact checkbox)

Design source re-derived independently from
`cupid-app-design-system/project/Cupid Screens.dc.html`:
`<sc-if value="{{ isPaired }}">` lines 1592-1608, custom properties lines 23-27,
`@keyframes bob` line 31, `@keyframes popIn` line 40, `@keyframes fall` usage
lines 1634-1647.

## Acceptance Criteria

### AC1 — layout, spacing, colour/token usage, typography match exactly (dark + `vi`)

MET. Verified element by element against the design source rather than against
the mobile-dev report. Independent confirmations:

- Stage: `radial-gradient(circle at 50% 38%, rgba(255,127,182,.3), transparent
  62%)`. Implementation uses `Alignment(0, -0.24)` — correct conversion of CSS
  `38%` to Flutter's `-1..1` axis (`2 * 0.38 - 1`). `radius: 0.9` is the correct
  farthest-corner derivation, and `rgba(255,127,182)` is exactly
  `colorAccentPink` `#FF7FB6`. Ending on the same hue at zero alpha rather than
  `transparent` black is the right call: it reproduces the browser's
  premultiplied interpolation instead of introducing a grey fringe.
- Padding `40px 26px`, title gap `28`, body gap `10`, stats gap `26`, CTA gap
  `30`, body `max-width:275`, CTA `max-width:300`, CTA `height:54`, chip
  `padding:12px 18px`, chip `border-radius:18`, label gap `3` — all transcribed
  verbatim and all correct.
- Copy: `Ghép đôi thành công!` / `You are paired!` and the full body line match
  the `data-vi` / `data-en` spans character for character, including the 🎀.
  Stat copy `1 ngày` / `16 tính năng` / `0 lần cãi` and `Ký Love Contract →`
  match.
- Token mapping verified hex-for-hex against `cupid_color_tokens.dart` dark
  theme, not just against the report's table: `--bg #171129` =
  `colorBackground`, `--surf #241B42` = `colorSurface`, `--tx2 #B4A6CE` =
  `colorTextMuted`, `--pink #FF7FB6` = `colorAccentPink`, `--mint #79E2CD` =
  `colorMint`, `--purple #B78CF5` = `colorAccentPurple`,
  `--grad-hot linear-gradient(120deg,#FF7FB6,#B78CF5)` = `gradientHot`,
  `--r-btn 999px` = `radiusButton` (999). `--shadow` correctly resolves through
  `cupidPlatform.elevationShadow`, which is the platform-forked seam the design
  source itself uses.
- Typography: `cupidType.display` is `Nunito / w900`, so `display.copyWith(28,
  height 1.2)` for the title and `display.copyWith(22)` for stat values are the
  correct roles. `caption` / `body` carry the platform `--fs-ui` family at w400,
  matching the design source's un-overridden `font-family` on those elements.
- New gradient token: `linear-gradient(135deg, ...)` maps to
  `Alignment(-0.7071, -0.7071) -> Alignment(0.7071, 0.7071)`, which is the
  correct down-right vector for CSS `135deg`. Stops `#FFB1D3/#C79BF0` and
  `#A8F0DF/#C79BF0` match the source exactly.

Deviation found by this review: see F1 (CSS box-model on the avatar circles).

### AC2 — deviations corrected in the rendered app, not merely documented

MET. All fourteen claimed fixes are real code changes in `paired_screen.dart`,
not report-only entries. The pre-existing screen was genuinely a placeholder
(one flat pink circle plus one text line); the corrected screen renders the
stage gradient, the couple avatar cluster, the floating heart, the title, the
body line, three stat chips and the primary CTA.

### AC3 — celebration treatment matches the design source, not a substitute

MET. This AC's premise needed correcting and the implementation handled it
correctly; this review independently confirms the correction.

`@keyframes fall` (line 28) is referenced only by the global `stormOnMe`
overlay at lines 1636-1647. It appears nowhere in the `isPaired` block. The
`paired` screen's actual celebration treatment is `popIn .6s
cubic-bezier(.2,1.6,.4,1)` on the avatar cluster and `bob 2s ease-in-out
infinite` on the heart. Adding confetti to this screen would itself have been
an AC1 violation.

Both keyframes are now exact, verified against lines 31 and 40:

- `popIn`: `scale(.94) translateY(8px) opacity 0` → `scale(1) translateY(0)
  opacity 1`. Implementation drives `0.94 + 0.06 * t`, `8 * (1 - t)`, and
  `opacity: t.clamp(0, 1)` over 600 ms on `Cubic(0.2, 1.6, 0.4, 1)`. Clamping
  only opacity is correct — CSS clamps opacity but lets the overshooting timing
  function carry scale past 1.
- `bob`: `0%,100% translateY(0); 50% translateY(-7px)` over 2 s. A 1000 ms
  controller with `repeat(reverse: true)` and `Curves.easeInOut` reproduces the
  full 2 s cycle with the correct −7 px travel, and matches CSS's per-segment
  application of the timing function. The bob is now on the heart, where the
  source puts it, instead of on the avatar.

### AC4 — no new entry point, existing navigation path unchanged

MET, verified structurally rather than by assertion. The diff touches six files
and none of them is a call site, a route, or a navigation file. `PairedScreen`
is still constructed as `const PairedScreen()` at `pair_gate_shell.dart:171`
and `invite_screen.dart:117`. The new `onSignContract` parameter is optional
and defaults to null, so no call site is forced to change.

## Findings

### F1 — DEFERRED — CSS box-model on the avatar circles (minor visual, requirement-wide)

The design source declares each avatar as `width:76px; height:76px;
border:3px solid var(--bg)` (lines 1595-1596) with no `box-sizing:border-box`.
CSS therefore uses the default content-box: each circle renders 82x82 with the
gradient painting out to the full 82 px under the border, and the
`margin-left:-22px` overlap makes the cluster 142x82.

Flutter paints `Border.all` inset, so
`Container(width: 76, height: 76, border: 3)` renders 76x76 total with only
70 px of visible gradient, and the cluster is 130x76. The hero element is
therefore about 8 percent undersized relative to the source.

Deferred rather than patch-required because this is a transcription convention,
not a STORY-014 defect. The same `fixed-size circle + border, no box-sizing`
pattern occurs 9 times across `Cupid Screens.dc.html`, so several other REQ-002
fidelity stories are making the same call. Fixing it in this story alone would
make STORY-014 inconsistent with its siblings.

Recommended action: settle the box-model convention once at REQ-002 integration
review and apply it uniformly. If the convention lands as content-box, the fix
here is `width: 82, height: 82` with `left: 60` for the trailing avatar and a
`142x82` cluster.

### F2 — ACCEPTED — avatar initials `M` / `L` not implemented

The handoff asked me to confirm this is a scope boundary rather than a missing
AC. Confirmed as a reasonable boundary.

The source renders `M` and `L` at `font-size:27px; font-weight:800; color:#fff`
inside the avatars. These are the prototype's demo identity data. Rendering
real initials requires `PairedScreen` to receive the current user's and the
partner's display names, which is a new data dependency on pairing-success
business logic — explicitly excluded by the story's Out of Scope section.
Hardcoding the literal letters `M` and `L` would ship prototype fixture data to
production users, which is a worse outcome than two clean gradient discs.

Note the contrast with the stat chips (`1` / `16` / `0`), which were correctly
rendered as literal copy: those are fixed design copy with no per-couple
meaning, whereas initials are inherently per-user. The implementation drew that
line in the right place.

Recommended action: follow-up story plumbing partner identity into
`PairedScreen`, naturally bundled with the F3 navigation wiring.

### F3 — DEFERRED — CTA renders with no destination (residual risk)

The handoff asked me to confirm this is a reasonable scope boundary. Confirmed
for the story, with a residual risk that must not be lost.

AC1 requires the CTA to be rendered — it is part of the locked design source
(line 1606, `onClick="{{ goContract }}"`). The destination is owned by Scope A.
`STORY-002_onboarding_pairing_navigation` exists in the backlog and is the
correct owner, so this is a real handoff, not an orphaned gap. Exposing a
nullable `onSignContract` seam mirrors the existing `onPaired` seam on
`WaitingScreen` and `JoincodeScreen`, which is the established pattern in this
feature. No route import and no default destination were invented.

Residual risk: until STORY-002 lands, both production call sites pass null, so
the screen ships a full-width gradient CTA with glow shadow that does nothing
when tapped. `InkWell(onTap: null)` suppresses the ripple but the button is not
visually disabled, so it reads as fully enabled. A user completing pairing will
tap the most prominent element on the screen and get no feedback.

Recommended action: REQ-002 must not be marked DONE while this screen ships a
dead primary CTA. Track STORY-002 as a hard dependency of REQ-002 integration
review and re-verify the wiring there.

### F4 — ACCEPTED WITH NOTE — CTA label colour

The source specifies literal `color:#fff` on the CTA; the implementation uses
`colorText` (`#F7EEFB` in dark theme). There is no pure-white token, and
`no_fork_guard_test.dart` (D3/ADR-004) forbids raw colour literals inside
`lib/features`. The choice matches the existing `welcome_screen.dart`
convention of painting `colorText` on `gradientHot`. Delta is a 4/255 lift on
two channels — not perceptible. Accepted, and correctly self-disclosed in the
visual-fidelity report.

### F5 — INFORMATIONAL — SafeArea wrapping

The `isPaired` block uses plain `padding:40px 26px`, unlike the other
chromeless screens in the same file (lines 206, 1326, 1658) which use
`var(--safe-top)`. The implementation wraps content in `SafeArea`. Because the
content is vertically centred, the only effect is a downward shift of about
15 px on iOS (`safe-top 54` vs `safe-bot 24`) and zero on Android
(`6` / `6`). `SafeArea` is the correct app behaviour regardless. The stage
gradient is correctly placed outside `SafeArea`, so its 38 percent centre still
resolves against the full frame as the source intends. No action.

### F6 — PROCESS — write-scope deviation requiring Scrum Master ratification

Two files outside the declared `WriteScope` were modified, both self-reported:

1. `mobile/lib/design_system/tokens/couple_avatar_gradients.dart` (new)
2. `mobile/lib/design_system/design_system.dart` (one added export line)

Both are technically justified and I endorse them: the gradient stops
`#FFB1D3`, `#A8F0DF`, `#C79BF0` have no existing token, `no_fork_guard_test`
forbids the literals inside `lib/features`, and the `pet_hero_gradient.dart`
precedent already establishes exactly this resolution. The barrel export is
required by `architecture/solution.md` §2. The new token file is additive and
touches no existing token value, so blast radius on sibling parallel stories is
nil.

Separately, the story's widget test lives at
`mobile/test/features/pairing/presentation/paired_screen_test.dart`, one level
above the declared test path, and was updated in place rather than duplicated.
That was the right call.

Recommended action: Scrum Master ratifies the write-scope extension. No code
change needed.

## Verification Evidence

Reviewed statically. The mobile-dev's reported evidence:

- `flutter gen-l10n`, then
  `flutter analyze lib/features/pairing lib/design_system test/features/pairing`
  — 9 `info • prefer_initializing_formals`, all in files this story did not
  touch; zero in the four changed source files.
- `flutter test test/features/pairing/presentation/paired_screen_test.dart test/design_system`
  — 40 passed, including `no_fork_guard_test.dart`.
- `flutter test test/features/pairing test/core/navigation` — 76 passed.

Verification limitation: `flutter` and `dart` are not on `PATH` in the reviewer
sandbox (`command not found`, also via login shell), so I could not
independently re-execute analyze or test. The above is taken from the
mobile-dev report and is not reviewer-reproduced.

To compensate, I reviewed the test diff statically. It is sound:

- Assertions pin the corrected title copy, the design-source body copy, the 💕
  element, all three stat values and labels, and the CTA label.
- A typography assertion pins the title to `Nunito / w900 / 28 / height 1.2`
  and the CTA to `16.5 / w800`, so a future regression on the type ramp fails
  loudly rather than silently.
- The semantics assertion correctly became `findsNWidgets(2)` under
  `ExcludeSemantics`, covering both the `popIn` and `bob` builders.
- A new seam test asserts `onSignContract` fires on tap.
- No `pumpAndSettle` is used anywhere against the infinite `bob` controller;
  the tests advance with explicit `pump(Duration)`, so they cannot hang. Both
  controllers are disposed.

The declared `no_fork_guard_test.dart` pass is consistent with the code: every
colour access in the changed feature file is bound to a local
`CupidColorTokens` first, and the only raw hex literals introduced live in
`lib/design_system/tokens/`, outside the guard's scanned path.

## Residual Risks

1. F3 — dead primary CTA on a shipped screen until
   `STORY-002_onboarding_pairing_navigation` wires the destination. Must gate
   REQ-002 DONE.
2. F1 — avatar cluster is 130x76 where the source computes 142x82. Requires a
   requirement-level box-model convention decision.
3. F2 — avatars render without initials until partner identity is plumbed
   through.
4. Test and analyze results are mobile-dev-reported, not reviewer-reproduced
   (no Flutter toolchain in the reviewer sandbox).
5. Light theme / `en` locale received no dedicated visual pass (OQ5,
   out of scope). All fixes are token-driven so they should hold, with one
   known exception: the stage gradient uses `colorAccentPink`, which is
   `#E8558F` in light theme, whereas the design source hardcodes
   `rgba(255,127,182)` in the gradient regardless of theme. The token-driven
   choice is the better app behaviour; flagging it only so a future light-theme
   pass is not surprised.

## Verdict

The implementation is a genuine, careful transcription of the locked design
source, not a report-driven approximation. The two judgement calls raised in
the handoff (nullable CTA seam, omitted initials) are both correct scope
boundaries and were correctly self-disclosed. The one deviation this review
found independently (F1, box-model) is requirement-wide rather than
story-local.

Outcome: DEFERRED_ONLY
REVIEW_COMPLETE: YES
