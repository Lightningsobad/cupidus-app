# Visual Fidelity Report: STORY-010 — Onboarding Profile Setup

VISUAL_FIDELITY: PASS
Design-Screen: profile

Re-issued in round 4 (2026-08-14), superseding this file's round-3 `FAIL`
verdict. Nothing about the render changed between the two issues — the same
capture is the evidence. What changed is the acceptance bar: the four residual
deltas in §4 have been ratified out of AC1/AC2 by the Product Owner and given a
real owner story, which is what the round-3 verdict was waiting on.

This report also replaces the round-2 report wholesale. That one audited
`ProfileEditScreen`; the PO re-scope (commit `5778c7d`) and the tech-lead coding
plan (commit `165c0af`, D1) settled that this story builds a **new, separate**
screen and leaves `ProfileEditScreen` to STORY-029. Nothing below is carried
over from the superseded round — the subject is a different widget tree.

## Verdict basis

Every element the `profile` canvas authors is implemented and confirmed in the
render (§3). Four residual deltas remain visible (§4). All four originate in the
shared `mobile/lib/design_system/` layer — including the shared `CupidHeader`
widget — strictly outside this story's declared seven-file write scope, and each
would move every screen in the live parallel wave if fixed here.

The round-3 review's finding F1 called the `FAIL` verdict *unratified* rather
than wrong: the deltas were real, but no governing artifact scoped them out, so
a self-recorded deferral could not move an AC. That gap is now closed. The
**Product Owner Ruling — 2026-08-14** in `../story_master.md` adopts the
review's recommended route (a) and excludes exactly these four from AC1/AC2,
assigning them to **STORY-033**
(`../../STORY-033_app_shell_design_system_deltas/story_master.md`):

| # | Ratified exclusion | This report |
|---|---|---|
| 1 | Ambient `skyGradient` backdrop (aurora wash + sparkle dots) | §4.4 |
| 2 | `CupidHeader` back-arrow ink renders in primary text ink, not pink | §4.4 |
| 3 | `caption` text style's sub-13px sizing **and its resulting wrap** | §4.2 |
| 4 | CTA gradient axis 120deg vs the canvas' 95deg | §4.3 |

`PASS` therefore means: no deviation remains inside this story's correction
scope. It does **not** mean the screen is pixel-identical to the reference
frame; the four excluded deltas are still visible and are STORY-033's to close.
AC1 and AC2 are written with these exclusions named, so this verdict is read
against the ACs as they now stand, not against an unqualified "no visible
deviation" bar.

Per the ruling's explicit scope disclaimer, this story is **not** authorized to
fix any of the four. None was touched.

Rendered evidence (dark + `vi`, Android, both frames 900px tall):

- `visual-fidelity/implemented-profile-emulator-5554.png` (405x900, 83853 B) —
  regenerated for this round; the previous file rendered the superseded screen
  and is preserved in Git history at `165c0af`.
- `visual-fidelity/design-reference-profile-android.png` (406x900) — unchanged;
  it is the canvas reference and is not affected by the re-scope.

Requirement: REQ-002 (Scope B, Full Design Fidelity Audit)
Story: STORY-010 Design Fidelity — Onboarding Profile Setup
Lane: mobile
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-010`
Round: 4 (re-issue) — BaseHead `dffa96119ec4a6b36c0301f381eadd26f5d7fdbd`
Screen implemented at: `a8d0fed`, BaseHead `165c0af7ff79b97ef4072d7892eb659702d4ac3e`
Design reference: `cupid-app-design-system` (locked)
Configuration audited: dark theme + `vi` locale — the only user-enabled
combination (`CupidFeatureFlags.enableLightTheme` / `enableEnLocale` are off in
`mobile/lib/app/cupid_app.dart`). `en` copy is implemented and unit-tested but
is not user-reachable, so it is not captured.

---

## 1. Subject Under Audit

| | |
|---|---|
| Canvas | `profile` — `cupid-app-design-system/project/Cupid Screens.dc.html:93-118` |
| Screen | `mobile/lib/features/onboarding/presentation/screens/onboarding_profile_setup_screen.dart` |
| Class | `OnboardingProfileSetupScreen` (new file, no shared implementation with `ProfileEditScreen`) |
| Route | `OnboardingProfileSetupRoute` (`/onboarding/profile`) — declared, not wired; STORY-002 owns wiring |
| Supporting widget | `mobile/lib/features/onboarding/presentation/widgets/zodiac_glyph.dart` — port of the `Zodiac Icon` design component |
| Capture entry | `main_preview.dart` canvas id `profile` (D3 repoint) |

`ProfileEditScreen`, `ProfileEditCubit` and their test are byte-identical to
`bf80848`, this branch's merge-base with
`codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`, which is
itself byte-identical to the integration branch's current tip for those paths.
After the round-4 F2 revert, `main_preview.dart` is the only pre-existing source
file this story leaves changed.

## 2. Capture Method

```
flutter run -d emulator-5554 -t lib/main_preview.dart \
  --dart-define=PREVIEW=profile \
  --dart-define=PREVIEW_PROFILE=fixture \
  --dart-define=PREVIEW_BRIGHTNESS=dark
adb -s emulator-5554 exec-out screencap -p    # 1080x2400, downscaled to 405x900
```

The frame is a real device render — Android status bar (10:28, wifi/signal/
battery), gesture pill, real font rasterization — not a widget-test snapshot.
`PREVIEW_PROFILE=fixture` substitutes authored data for
`AccountRepository.fetchProfile()` and is inert without the define, so no other
story's capture of any canvas changes. The fixture
(`displayName: 'Linh'`, `birthday: 2001-03-03`, `language: 'vi'`) already
matched the canvas placeholders (`myName: 'Linh'`, `myDob: '03/03/2001'`,
`Song Ngư`, `Tiếng Việt`) and was not modified.

## 3. Element-By-Element Audit

Canvas line numbers are in `Cupid Screens.dc.html`.

| # | Canvas authors (line) | Implemented as | Render |
|---|---|---|---|
| 1 | body `padding:22px 20px 40px`, column `gap:22px` (94) | `_bodyPadding = fromLTRB(20,22,20,40)`, `_sectionGap = 22` | matches |
| 2 | avatar column, `align-items:center`, `gap:12px` (95) | `_AvatarBlock` centered `Column`, `_avatarCaptionGap = 12` | matches |
| 3 | 104px circle, `overflow:hidden`, `box-shadow:var(--shadow)` (97) | 104dp `BoxShape.circle` + `platformTokens.elevationShadow` | matches |
| 4 | `<image-slot placeholder="Ảnh đại diện">` (97) | photo → `DecorationImage(NetworkImage, BoxFit.cover)`; empty → `person` glyph at 52dp on `colorSurfaceAlt` | see §4.1 |
| 5 | badge 36px, `right:-10px bottom:-6px`, `--grad-hot`, `3px solid var(--bg)`, `--glow` (98) | `Positioned(right:-10,bottom:-6)`, 36dp, `gradientHot`, 3dp `colorBackground` border, `glowShadow` | matches |
| 6 | badge icon `photo_camera` 19px `#fff` (98) | `IconData(0xe412)` at 19dp in `colorText` | matches |
| 7 | caption `Ảnh sẽ được crop tròn`, 12.5px, `--tx2` (100) | `type.caption` + `colorTextMuted` | copy matches, size see §4.2 |
| 8 | card group `gap:12px` (102) | `_cardGap = 12` | matches |
| 9 | card `background:var(--surf)`, `border-radius:var(--r-card)`, `padding:14px 16px` (103/107/112) | `colorSurface`, `platformTokens.radiusCard` (24 material / 26 iOS), `symmetric(h:16,v:14)` | matches |
| 10 | label 11px, `letter-spacing:.06em`, uppercase, `--tx2`, `margin-bottom:5px` (104/108/113) | `type.caption` + `letterSpacing: 0.66` + `.toUpperCase()` + `colorTextMuted`, gap 5 | uppercase/tracking/color match, size see §4.2 |
| 11 | value 17px weight 600 (105/109/113) | `type.body.copyWith(fontWeight: w600)` | matches (token is 17px) |
| 12 | `Tên gọi` / `Ngày sinh` / `Ngôn ngữ` vi+en copy (104/108/113) | `context.viEn(...)` file-local extension | matches |
| 13 | dob row `justify-content:space-between` (109) | `Row` with `Expanded` value + trailing chip | matches |
| 14 | zodiac chip: `padding:5px 12px 5px 5px`, `border-radius:999px`, `--surf2`, 12.5px weight 700, `gap:7px` (109) | `fromLTRB(5,5,12,5)`, `platformTokens.radiusButton` (999 both platforms), `colorSurfaceAlt`, `type.caption` w700, gap 7 | geometry matches, size see §4.2 |
| 15 | `<dc-import name="Zodiac Icon" sign>` at 26x26 (109) | `ZodiacGlyph(sign:, size: 26)` — `CustomPainter` port of all 12 sign paths, element ink/disc palette, sparkles, `cancer` fallback | matches |
| 16 | helper `Cung hoàng đạo tính tự động — dùng cho Zodiac Red Flag.`, 11.5px, `--tx2`, `margin-top:8px` (110) | `type.caption` + `colorTextMuted`, gap 8 | copy matches, size see §4.2 |
| 17 | language chevron `›` 20px `--tx2` (114) | `CupidIcon(CupidIcons.chevronRight, size: 20, color: colorTextMuted)` | matches |
| 18 | CTA height 52px, `border-radius:var(--r-btn)`, `box-shadow:var(--glow)` (117) | 52dp, `radiusButton`, `glowShadow` | matches |
| 19 | CTA `linear-gradient(95deg,var(--pink),var(--purple))` (117) | `colors.gradientHot` | see §4.3 |
| 20 | CTA text `Tiếp tục → Love Contract`, 16.5px, weight 700, `#fff` (117) | `type.body.copyWith(w700)` in `colorText` | copy/weight match, size+ink see §4.2/§4.4 |
| 21 | `onClick="{{ goContract }}"` (117) | `required VoidCallback onContinue`, always enabled | matches (destination is STORY-002's) |

Header chrome is not in the canvas block (the design tool renders it from shared
screen chrome): the screen uses the repo's `CupidHeader` with title
`Hồ sơ của bạn` / `Your profile` and `backLabel` `Quay lại` / `Back`, per plan
D7. See §4.4 for the header delta.

## 4. Residual Deviations

All four are outside `WriteScope`. Fixing any of them inside this story would
either fork a shared token or move every other screen.

Since round 3 they are no longer this story's open deltas: §4.2, §4.3 and §4.4
are the four exclusions ratified out of AC1/AC2 by the Product Owner Ruling and
owned by **STORY-033** (see "Verdict basis" above). They are kept here in full
because STORY-033's implementer needs the measurements, and because a `PASS`
verdict that hid them would be dishonest. §4.1 is not a delta at all.

### 4.1 Empty-avatar placeholder is the app's glyph, not the canvas' dashed slot

The reference frame shows a dashed circle containing an image icon and the words
"Ảnh đại diện". That is the design tool's authoring chrome for an unfilled
`<image-slot>` (line 97 declares it via the `placeholder=` attribute), not
product design — a shipped app has no "drop an image here" affordance. The
screen therefore renders the app's own `person` glyph on `colorSurfaceAlt`,
matching how the rest of the app draws a missing avatar.

Status: intentional, not a defect. Recorded because it is the one place where
the two frames differ by design rather than by omission.
Owner: none — no action wanted.

### 4.2 `type.caption` is 13px; the canvas authors 11 / 11.5 / 12.5px

`CupidTypographyTokens` has no role between `caption` (13px) and `body` (17px).
Four canvas elements sit below 13px: card labels (11px), the zodiac helper
(11.5px), the avatar caption (12.5px) and the chip label (12.5px). All four use
`caption`, so they render 0.5-2px larger than authored. The CTA label is the
mirror case: authored 16.5px, rendered at `body`'s 17px.

Not fixed here by explicit instruction — coding plan §6.3 typography rule: keep
the token and record a token-level finding rather than hard-coding a one-off
`fontSize`, because tokens are shared across all four theme/locale combinations
(Out of Scope, OQ5). The tracking letter-spacing is authored as `.06em` on 11px
and is transcribed as the resulting `0.66` logical px, so the tracking is
absolutely correct while the glyph size is not.

**Layout consequence — the zodiac helper text wraps to two lines.** The helper
`Cung hoàng đạo tính tự động — dùng cho Zodiac Red Flag.` (element 16, canvas
line 110) is authored at 11.5px and fits one line in the reference frame. At
`caption`'s 13px it no longer fits the card's content width and wraps to two
lines, which makes the NGÀY SINH card taller than the reference's and shifts
everything below it down by one line-height.

This is named explicitly, per round-3 review Action Item #2, so it is not
mistaken for an unexplained layout deviation. It is **not** a separate defect
and **not** a spacing or line-height error in this story's code: it is a
downstream consequence of the same excluded `caption` sizing delta. The wrap
resolves by itself when STORY-033 introduces the sub-13px type step — no change
to `onboarding_profile_setup_screen.dart` is needed or wanted. Round 2 recorded
an identical wrap on the superseded screen as a real layout delta (R8), so it is
recorded as one here rather than left implicit under a font-size row.

Owner: STORY-033 (design-system typography scale), exclusion #3. Both the sizing
and this wrap are covered by the same ratified exclusion.

### 4.3 CTA gradient axis is 120deg; this canvas authors 95deg

`colors.gradientHot` is built from `_gradient120Begin/_gradient120End`
(`cupid_color_tokens.dart:81-85`), derived from the design system's
`--grad-hot:linear-gradient(120deg,#FF7FB6,#B78CF5)`. This canvas' CTA overrides
that to `linear-gradient(95deg,var(--pink),var(--purple))` at line 117 — same two
stops, shallower axis. Consuming the token keeps the stop colors exact and the
axis 25deg off; hard-coding 95deg here would fork the gradient for one button.

Both frames read as the same pink→purple sweep at render scale; the delta is
measurable, not conspicuous.

Owner: STORY-033 (design-system gradient tokens), exclusion #4 — needs a
decision on whether per-canvas gradient angles are worth a second token.

### 4.4 Shared chrome: header back-arrow ink and the ambient backdrop

Two deltas belong to widgets this story does not own:

- **Back arrow.** The reference draws it in `--pink`; `CupidHeader` draws it in
  the primary text ink. `CupidHeader` is a shared adaptive widget used by every
  screen in the app.
- **Ambient backdrop.** The reference frame carries the canvas' aurora wash and
  sparkle dots; the implemented frame is flat `colorBackground` (`#171129`). The
  gradient itself *is* tokenized — `CupidColorTokens.skyGradient`
  (`cupid_color_tokens.dart:66-70`) holds the three-stop radial `--sky` recipe —
  but it is stored as a CSS string and no widget consumes it: `lib/design_system`
  contains only `adaptive/`, `icons/`, `theme/` and `tokens/`, with no backdrop
  widget. No screen in the app renders it today, and the preview harness renders
  this screen unwrapped (`wrapInShell` is not set for canvas `profile`), so even
  a shell-level backdrop would not appear in this capture.

Owner: STORY-033 (design system / app shell) — the back arrow is exclusion #2
and the backdrop is exclusion #1. Both are cross-screen REQ-002 findings; a
per-screen fix here would fork shared chrome for one route. The backdrop is the
largest visible difference between the two frames by area, and is the one an
integration reviewer will notice first — it is excluded, not overlooked.

## 5. Gate Evidence

All commands run in the story worktree
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-010/mobile`.

The canonical gate record is now `../coding-plan/test-results.md`, added in
round 4 to close review finding F3. This section is the round-4 re-run,
summarised.

| Gate | Command | Result |
|---|---|---|
| Analyze (branch-touched files) | `flutter analyze` over all 5 changed items, incl. both reverted files | `No issues found! (ran in 2.1s)` |
| Analyze (project) | `flutter analyze lib test` | `77 issues found` — all `info`, all pre-existing, none in a file this branch touches |
| Full suite | `flutter test` | `+935: All tests passed!`, exit 0 |
| Targeted story scope | `flutter test test/features/onboarding test/design_system/no_fork_guard_test.dart test/features/account/…/profile_edit_screen_test.dart` | `+19: All tests passed!` |
| STORY-029 regression | `flutter test test/features/account/presentation/screens/profile_edit_screen_test.dart` | `+3: All tests passed!` — its pre-STORY-010 baseline |
| Runtime startup smoke | preview harness on `emulator-5554` (scope: `mobile-app`) | booted, rendered, captured |

New tests added by this story: 8 screen tests (the eight cases the plan's §6.4
enumerates), 5 `ZodiacGlyph` tests, 2 route tests — 15 in total, all under
`test/features/onboarding/`.

The full-suite and regression counts moved down by 6 from round 3 (`+941` →
`+935`, `+9` → `+3`). That is the F2 revert removing the six superseded
`STORY-010 design fidelity against the 'profile' canvas` tests from
`profile_edit_screen_test.dart`, and nothing else; the reconciliation table in
`../coding-plan/test-results.md` shows the arithmetic.

Two no-fork-guard violations were introduced and fixed during this round, both
worth naming because they show the guard catching a class of mistake a reviewer
would otherwise have to catch by eye:

- `onboarding_profile_setup_screen.dart` — a chained `context.cupidColors.` read
  contains the literal substring `Colors.`, which the guard scans for. Fixed by
  binding `final CupidColorTokens colors = context.cupidColors;` first, which is
  also the convention every other screen already follows.
- `zodiac_glyph.dart` — the guard scans raw file text, so a *doc comment*
  quoting the forbidden packed-hex `Color` constructor tripped it. Reworded.

## 6. AC Assessment

Read against AC1 and AC2 **as amended** by the Product Owner Ruling —
2026-08-14, which names the four shared design-system deltas as excluded.

| AC | Assessment |
|---|---|
| AC1 — exact match to canvas `profile` in dark + `vi`, except the four ratified `design_system/` deltas | MET. Every element the canvas authors is present, correctly ordered and pixel-accurate (§3, all 21 rows). The four remaining deltas (§4.2/§4.3/§4.4, incl. the helper-text wrap) are exactly the four the ruling excludes and are owned by STORY-033. No unexcluded deviation remains. |
| AC2 — in-scope deviations corrected in the app, not merely documented | MET. Every delta inside this story's write scope was corrected in the rendered app and re-verified against the design source by re-capture, not documented away. The four excluded deltas sit in shared `design_system/` files the ruling explicitly forbids this story from touching, so they are outside AC2's correction scope by construction. |
| AC3 — avatar empty and populated states | Met: empty state renders the placeholder glyph with no `DecorationImage` (visible in the capture); populated state configures `NetworkImage` + `BoxFit.cover`, asserted on widget configuration. |
| AC4 — renders standalone, adds no live navigation | Met: the screen builds in a bare `MaterialApp` and pushes no route of its own (test 8); the route factory is declared but nothing calls it, and no nav-graph file is in the diff. |

## 7. Downstream Notes

- **STORY-002** wires this in: `OnboardingProfileSetupRoute.push(context,
  profile: <CupidProfile>, onContinue: <next step>)`. It must resolve the
  `CupidProfile` before pushing (the screen does no I/O) and owns the CTA
  destination — note the canvas' own target is `contract` (`goContract`) while
  STORY-002's chain text says `invite`/`join-code`.
- **STORY-029** inherits `ProfileEditScreen` untouched and unencumbered. Round 4
  reverted the superseded round-2 rework per the Scrum Master Disposition —
  2026-08-14: `profile_edit_screen.dart` and its test are byte-identical to the
  merge-base with the integration branch, so the misleading `STORY-010 design
  fidelity` test group and its six hard-coded canvas-`profile` geometry
  assertions are gone. STORY-029 is free to decide for itself whether canvas
  `profile` is the right fidelity target for the Me-hub edit affordance. The one
  thing it does not inherit is the `profile` preview canvas id, which D3
  repointed to this story's screen.
- **STORY-033** owns all four excluded deltas (see "Verdict basis"). Its fixes
  are expected to move every screen in the wave that consumes the same shared
  piece, this one included, with no further implementation work in STORY-010.
- **`ProfileEditScreen`'s own design fidelity** against `Cupid Screens.dc.html:982`
  is, after the revert, not in any REQ-002 Scope B story's written scope —
  STORY-029 covers only the `me` hub tab. Flagged for `product-owner` as a
  backlog-completeness question in `../story_master.md`; not this story's to
  absorb.
- **Deferred by design:** avatar upload/crop (the badge is inert), language
  switching from the third card, and promoting `ZodiacGlyph` into
  `design_system/icons/` once a second screen needs it.
