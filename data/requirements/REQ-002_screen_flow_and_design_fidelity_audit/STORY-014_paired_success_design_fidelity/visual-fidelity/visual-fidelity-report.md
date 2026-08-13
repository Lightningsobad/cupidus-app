# Visual Fidelity Report: STORY-014 Paired Success

Story: STORY-014 Design Fidelity — Paired Success
Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Screen: `paired` (ghép đôi thành công), NO_CHROME / NO_TABS
Configuration audited: dark theme + `vi` locale (the enabled combination)
Lane: mobile

## Design Source

Locked source: `cupid-app-design-system`

Exact reference block: `cupid-app-design-system/project/Cupid Screens.dc.html`,
`<sc-if value="{{ isPaired }}">`, lines 1592-1608. Design tokens resolved from
the same file's `[data-plat]` / `body[data-theme="dark"]` custom-property
blocks (lines 23-27) and the `@keyframes` block (lines 28-40).

Implementation file audited and corrected:
`mobile/lib/features/pairing/presentation/screens/paired_screen.dart`

## Verdict

The pre-existing screen was not a partial match — it was a placeholder. It
rendered a single flat accent-pink circle plus one line of text, against a
design source that specifies a radial-gradient stage, two overlapping
gradient couple avatars with a floating heart, a display-weight title, a
supporting body line, three stat chips, and a primary CTA. Fifteen deviations
were found and fourteen were corrected in code. One is documented below as
out-of-scope-blocked with its reason.

## Deviations Found And Fixed

### D1 — Screen background missing the radial celebration wash

- Design: `background: radial-gradient(circle at 50% 38%,
  rgba(255,127,182,.3), transparent 62%)` over `--bg`.
- Before: flat `colors.colorBackground` only, no gradient.
- Fix: `RadialGradient(center: Alignment(0, -0.24), radius: 0.9, ...)` layered
  over the `Scaffold` background. `rgba(255,127,182)` is exactly
  `colorAccentPink` (`#FF7FB6`), so the stop is
  `colorAccentPink.withValues(alpha: 0.3)` and the end stop is the same hue at
  zero alpha (rather than `transparent` black) so the fade carries no gray
  fringe.
- Note on `radius: 0.9`: CSS sizes a bare `circle` to the farthest corner. On
  the design frame, the farthest corner from (50%, 38%) is
  `sqrt(0.5w^2 + 0.62h^2)`; the 62% colour stop then lands at ~0.89 of the
  shortest side, which is the unit Flutter's `RadialGradient.radius` uses.
  `0.9` is that derived value, not an invented one.

### D2 — Screen padding did not match

- Design: `padding: 40px 26px`.
- Before: `EdgeInsets.all(CupidSpacing.lg)` (24 on all sides).
- Fix: `EdgeInsets.symmetric(vertical: 40, horizontal: 26)`. Both values fall
  off the 8pt `CupidSpacing` grid, so they are transcribed verbatim rather
  than rounded to the nearest token; AC1 requires an exact match.

### D3 — Couple-presence signal was a single flat circle

- Design: two 76x76 circles, `border-radius:50%`, `border:3px solid var(--bg)`,
  the second offset by `margin-left:-22px` so the pair overlaps; fills are
  `linear-gradient(135deg,#FFB1D3,#C79BF0)` and
  `linear-gradient(135deg,#A8F0DF,#C79BF0)`.
- Before: one 72x72 flat `colorAccentPink` circle, no border, no partner
  avatar — no couple-presence signal at all.
- Fix: a 130x76 `Stack` (76 + 76 - 22 overlap) holding two 76x76 gradient
  circles with a 3px `colorBackground` border, the second positioned at
  `left: 54`. Flutter's `Container.margin` asserts non-negative insets, so the
  CSS negative margin is expressed as explicit `Positioned` offsets, which
  also collapse the cluster's layout width the way the CSS negative margin
  does.
- Token gap: `#FFB1D3`, `#A8F0DF` and `#C79BF0` are not carried by
  `CupidColorTokens`, and `gradientDream`/`gradientHot` do not match these
  stops. `test/design_system/no_fork_guard_test.dart` (D3/ADR-004) forbids a
  raw colour literal inside `lib/features`, so — mirroring the existing
  `pet_hero_gradient.dart` precedent — they were declared as a new
  design-system token file. See "Write Scope Deviations" below.

### D4 — Floating heart absent

- Design: `💕` at `left:50%; top:-16px; transform:translateX(-50%);
  font-size:26px`, above the avatar cluster.
- Before: absent.
- Fix: `Positioned(left: 0, right: 0, top: -16, child: Center(...))` inside the
  cluster `Stack` with `clipBehavior: Clip.none`, `TextStyle(fontSize: 26)`.

### D5 — Pop-in animation used the wrong keyframe and duration

- Design: `animation: popIn .6s cubic-bezier(.2,1.6,.4,1)`, where `@keyframes
  popIn` is `scale(.94) translateY(8px) opacity 0` → `scale(1) translateY(0)
  opacity 1`.
- Before: a 500 ms `Curves.elasticOut` scale from 0 with no translate and no
  opacity ramp — a substitute effect, not the source keyframe.
- Fix: 600 ms controller on `Cubic(0.2, 1.6, 0.4, 1)`, driving
  `scale: 0.94 + 0.06 * t`, `translateY: 8 * (1 - t)` and `opacity: t`. The
  curve overshoots past 1 by design, so only opacity is clamped.

### D6 — Bob animation used the wrong travel, duration and easing

- Design: `animation: bob 2s ease-in-out infinite`, where `@keyframes bob` is
  `0%,100% translateY(0); 50% translateY(-7px)`.
- Before: 900 ms linear controller with a -6 px travel, applied to the avatar
  itself rather than to a floating heart.
- Fix: 1000 ms controller with `repeat(reverse: true)` (a full 2 s cycle),
  `Curves.easeInOut`, `-7 * value` travel, applied to the `💕` element as the
  design specifies.

### D7 — Title copy did not match the design source

- Design (`vi`): `Ghép đôi thành công!` / (`en`) `You are paired!`.
- Before: `Đã ghép đôi!` / `You're paired!`.
- Fix: copy transcribed verbatim from the `data-vi` / `data-en` spans.

### D8 — Title typography was the wrong role and size

- Design: `font-family:Nunito; font-weight:900; font-size:28px;
  line-height:1.2`.
- Before: `cupidType.cardTitle` — the platform UI font at weight 600, 22 px, no
  line height.
- Fix: `cupidType.display` (Nunito 900) with `fontSize: 28, height: 1.2`.

### D9 — Title gap did not match

- Design: `margin-top:28px` between the avatar cluster and the title.
- Before: `SizedBox(height: CupidSpacing.lg)` (24).
- Fix: `SizedBox(height: 28)`.

### D10 — Supporting body line absent

- Design: `Từ giây phút này mọi thứ trong Cupid là của chung hai người. Không
  có đường lui đâu 🎀` at `font-size:13.5px; line-height:1.6; color:var(--tx2);
  margin-top:10px; max-width:275px`.
- Before: absent.
- Fix: rendered inside `ConstrainedBox(maxWidth: 275)` at
  `cupidType.caption.copyWith(fontSize: 13.5, height: 1.6, color:
  colorTextMuted)`, 10 px below the title. `--tx2` is exactly
  `colorTextMuted`.

### D11 — Stat chip row absent

- Design: three chips, `gap:12px`, `margin-top:26px`; each chip
  `padding:12px 18px; border-radius:18px; background:var(--surf);
  box-shadow:var(--shadow)`. Values `1 / 16 / 0` in `Nunito 900 22px` coloured
  `var(--pink)` / `var(--mint)` / `var(--purple)`; labels `ngày / tính năng /
  lần cãi` at `11px var(--tx2)` with `margin-top:3px`.
- Before: absent.
- Fix: a `Row` of three chips matching every value above.
  `--surf` → `colorSurface`, `--shadow` → `cupidPlatform.elevationShadow`
  (which carries the platform-correct `0 6px 18px rgba(80,30,110,.16)` /
  `0 10px 30px rgba(80,30,110,.18)`), `--pink` → `colorAccentPink`, `--mint` →
  `colorMint`, `--purple` → `colorAccentPurple`, `--tx2` → `colorTextMuted`.
  The values are fixed copy in the design source, not derived state, so they
  are rendered as literal copy and introduce no new data dependency.

### D12 — Primary CTA absent

- Design: `Ký Love Contract →` at `margin-top:30px; width:100%;
  max-width:300px; height:54px; border-radius:var(--r-btn);
  background:var(--grad-hot); color:#fff; font-size:16.5px; font-weight:800;
  box-shadow:var(--glow)`.
- Before: absent, with a code comment carrying REQ-001's rationale ("no Love
  Contract flow exists yet"). That rationale is now stale — `lib/features/
  love_contracts/` exists in the app.
- Fix: rendered at exactly the design's geometry and styling.
  `--grad-hot` → `colors.gradientHot`, `--r-btn` →
  `cupidPlatform.radiusButton` (999, pill), `--glow` → `colors.glowShadow`.
- Navigation boundary: the CTA's destination is explicitly out of this story's
  scope (Scope A / STORY-001 / STORY-002 own inter-screen navigation). The
  screen therefore renders the CTA but wires no route: it exposes a nullable
  `onSignContract` callback seam, mirroring the existing `onPaired` seam on
  `WaitingScreen` and `JoincodeScreen`. No route import, no default
  destination, and AC4 is unaffected (how the screen is reached is unchanged).
  Flagged for the Reviewer as the one judgement call in this story.

### D13 — CTA/label typography (rolled into D12)

- Design: `font-size:16.5px; font-weight:800`, inheriting the platform
  `--fs-ui` stack (no `font-family` override).
- Fix: `cupidType.body.copyWith(fontSize: 16.5, fontWeight: FontWeight.w800)`,
  which carries the platform UI font family.

### D14 — Content could not survive vertical overflow

- Design: `min-height:100%` with flex centring.
- Before: `Center` + `Padding` only. With the far taller corrected content
  (~480 px including padding) plus OS text scaling, this would hard-overflow.
- Fix: `Center` + `SingleChildScrollView` with the padding moved onto the
  scroll view. Centred and non-scrolling at normal sizes — identical to the
  design — and scrollable only when it would otherwise clip.

## Deviation NOT Fixed (out of scope)

### D15 — Avatar initials

- Design: the two avatars carry the initials `M` and `L` at
  `font-size:27px; font-weight:800; color:#fff`.
- Status: NOT implemented.
- Reason: those glyphs are the prototype's demo identity data. Rendering real
  initials requires the paired screen to receive the current user's and the
  partner's display names, which is a new data dependency on pairing-success
  business logic. The handoff for this story explicitly forbids touching
  pairing-success business logic, and the story's Out of Scope section
  excludes new features. Inventing placeholder letters would be a worse
  deviation than omitting them.
- Recommendation: raise as a follow-up story that plumbs partner identity into
  `PairedScreen`, alongside the D12 navigation wiring that Scope A owns.

## Token Mapping Verified

| Design source | Token used |
| --- | --- |
| `--bg` `#171129` | `colorBackground` |
| `--surf` `#241B42` | `colorSurface` |
| `--tx` `#F7EEFB` | `colorText` |
| `--tx2` `#B4A6CE` | `colorTextMuted` |
| `--pink` `#FF7FB6` | `colorAccentPink` |
| `--mint` `#79E2CD` | `colorMint` |
| `--purple` `#B78CF5` | `colorAccentPurple` |
| `--grad-hot` | `gradientHot` |
| `--glow` | `glowShadow` |
| `--shadow` | `cupidPlatform.elevationShadow` |
| `--r-btn` `999px` | `cupidPlatform.radiusButton` |
| Nunito 900 | `cupidType.display` |
| platform `--fs-ui` body | `cupidType.body` / `cupidType.caption` |

Residual token note: the design uses literal `#fff` for text on the gradient
CTA. There is no pure-white token; `colorText` (`#F7EEFB` in dark theme) is
used, matching the established convention in `welcome_screen.dart`, which also
paints `colorText` on `gradientHot`. Delta is imperceptible and theme-correct.

## AC Coverage

- **AC1** (layout, spacing, colour/token usage, typography match exactly in
  dark + `vi`): met for D1-D14. D15 documented above as blocked by the story's
  own business-logic boundary.
- **AC2** (deviations corrected in the rendered app, not merely documented):
  met — every item above except D15 is a code change in `paired_screen.dart`,
  re-verified against the design source line by line.
- **AC3** (celebration treatment matches the design source's `fall` keyframe,
  not a substitute): met, and worth stating precisely because the AC's premise
  is easy to misread. `@keyframes fall` (line 28) is used **only** by the
  global `stormOnMe` overlay (lines 1634-1647), which is a separate
  app-wide effect, not part of the `paired` screen. The `paired` screen's own
  celebration treatment is `popIn` on the avatar cluster and `bob` on the
  floating heart. Both were previously substitute effects (`elasticOut` scale
  from 0; a 900 ms linear -6 px bob on the wrong element) and are now the
  exact source keyframes — see D5 and D6. No confetti was added to this
  screen, because the design source does not put confetti on this screen.
- **AC4** (no new entry point; existing navigation path unchanged): met.
  `PairedScreen`'s call sites (`pair_gate_shell.dart:171`,
  `invite_screen.dart:117`, both `onPaired` seams in the tests) are unchanged
  and still construct it as `const PairedScreen()`.

## Out-of-Scope Confirmation

- Pairing-success business logic: untouched. No cubit, repository, poller, or
  state class was modified.
- Navigation: untouched. No route, no `Navigator` call, and no call site
  changed. The CTA seam defaults to null.
- Light theme / `en` locale: no dedicated visual pass performed (OQ5). All
  fixes are token-driven, so they stay correct across all four
  platform x theme combinations; `en` copy was transcribed alongside `vi`.

## Write Scope Deviations

Two files outside the handoff's declared `WriteScope` were touched. Both are
reported here for Scrum Master/Reviewer ratification.

1. `mobile/lib/design_system/tokens/couple_avatar_gradients.dart` (new).
   Required by D3. The avatar gradient stops have no existing token and
   `no_fork_guard_test.dart` forbids the literals inside `lib/features`. This
   follows the established `pet_hero_gradient.dart` precedent for exactly this
   situation.
2. `mobile/lib/design_system/design_system.dart` (one added export line).
   Required so feature code can reach the new token through the single barrel
   import, per `architecture/solution.md` §2 ("one barrel import, no direct
   token/theme file imports from feature code").

Additionally, the story's existing widget test lives at
`mobile/test/features/pairing/presentation/paired_screen_test.dart`, one level
above the declared `mobile/test/features/pairing/presentation/screens` path.
The existing file was updated in place rather than duplicated into a new
directory.

## Verification Evidence

All commands run in the story worktree
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-014/mobile`
with Flutter 3.44.1 / Dart 3.12.1.

1. `flutter gen-l10n` — required first: `lib/l10n/generated/app_l10n.dart` is
   generated output and was absent in the fresh worktree, which made a
   repo-wide `flutter analyze` report pre-existing `uri_does_not_exist` /
   `AppL10n` errors unrelated to this story.
2. `flutter analyze lib/features/pairing lib/design_system test/features/pairing`
   — 9 issues, all `info • prefer_initializing_formals`, all pre-existing in
   files this story did not touch (`invite_cubit.dart`, `joincode_cubit.dart`,
   `pair_gate_cubit.dart`, `invite_screen.dart`, `joincode_screen.dart`,
   `waiting_screen.dart`). Zero issues in `paired_screen.dart`,
   `couple_avatar_gradients.dart`, `design_system.dart`, or the updated test.
3. `flutter test test/features/pairing/presentation/paired_screen_test.dart test/design_system`
   — **All tests passed** (40). This run includes
   `no_fork_guard_test.dart`, confirming the new screen introduces no raw
   colour literal or platform fork inside `lib/features`.
4. `flutter test test/features/pairing test/core/navigation`
   — **All tests passed** (76). Regression check across every `PairedScreen`
   call site, including `PairGateShell` and `InviteScreen` production wiring.

No device install, emulator provisioning, toolchain setup, or release
configuration was performed — out of this story's verification scope.

## Test Changes

`mobile/test/features/pairing/presentation/paired_screen_test.dart`:

- Updated the live-region assertion to the corrected title copy
  (`You are paired!`).
- Replaced the single-`AnimatedBuilder` semantics assertion with
  `findsNWidgets(2)` under `ExcludeSemantics`, covering both the `popIn` and
  `bob` controllers.
- Added coverage for the design-source body copy, the `💕` element, all three
  stat values and labels, and the CTA label.
- Added a typography assertion pinning the title to Nunito / w900 / 28 /
  height 1.2 and the CTA label to 16.5 / w800.
- Added a CTA seam test asserting `onSignContract` fires on tap.
