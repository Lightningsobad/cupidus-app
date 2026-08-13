# STORY-021 Visual Fidelity Report — Synced Reminder

- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Story: STORY-021 (Synced Reminder design fidelity)
- Lane: mobile-dev
- Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-021`
- BaseHead: `bf808483223580df81b1fb951b141a6597cb82dd`
- Audit conditions: dark theme enabled, `vi` locale, `CupidPlatform.material`
- Design source (locked): `cupid-app-design-system/project/Cupid App.dc.html`
  — the canvas entry named by `data/devops/system/design-fidelity-config.json`.
  All `line NNN` citations below point into
  `cupid-app-design-system/project/Cupid Screens.dc.html`, the screen markup
  that canvas renders.
- Design-Screen: `alarm` (`Cupid Screens.dc.html:2215` `isAlarm: sc === 'alarm'`;
  screen-list entry at `:1878`)
- Design-Screen state (overlay): `alarmRinging` (`Cupid Screens.dc.html:2413`
  `alarmRinging: !!a.ringing`)

This is a fix report, not an audit-only report. Every deviation listed under
"Findings" was corrected in app code in this branch unless it appears under
"Deferred with rationale".

## 1. Scope audited

| Surface | File |
| --- | --- |
| Schedule screen (shared-time confirmation) | `mobile/lib/features/reminders/presentation/screens/reminder_schedule_screen.dart` |
| Time stepper + gradient clock | `mobile/lib/features/reminders/presentation/widgets/reminder_time_stepper.dart` |
| Weekday chip row | `mobile/lib/features/reminders/presentation/widgets/reminder_weekday_chips.dart` |
| Firing overlay (dual swipe-to-dismiss) | `mobile/lib/features/reminders/presentation/widgets/reminder_firing_overlay.dart` |
| Canonical vi/en copy | `mobile/lib/features/reminders/presentation/reminder_strings.dart` |

Design-source anchors: schedule block lines 488-535, firing overlay block
lines 1657-1673, dark token block line 27, `shake` keyframe line 32.

## 2. Token normalization rule applied

Design-source pixel values within ~4px of an existing `CupidSpacing` step were
normalized to the token (8pt grid). Explicit numeric literals were used only
where no token matches the locked design; each such literal carries a
file-level `const` with a dartdoc citing the design-source line:

`_chipDiameter 34`, `_ctaHeight 54`, `_badgeSize 96`, `_badgeRadius 34`,
`_bodyMaxWidth 250`, `_dismissPillMaxWidth 300`, `_dismissPillHeight 60`,
`_partnerDividerWidth 30`, plus `fontSize` 15/16/16.5→16/56,
`letterSpacing -0.03em`, `line-height 1.55`.

## 3. Findings and fixes

### 3.1 Screen shell

| # | Deviation (before) | Design source | After |
| --- | --- | --- | --- |
| F1 | Scroll padding `EdgeInsets.all(CupidSpacing.lg)` = 24 all round | line 489 `padding:8px 16px 40px` | `EdgeInsets.fromLTRB(md, sm, md, xl+sm)` = 16/8/16/40 |
| F2 | Section gaps `CupidSpacing.lg` (24) ×4 | lines 505/519/522/525/528 `margin-top:14px` | `CupidSpacing.md` (16) ×4 |
| F3 | AppBar title used an inline `viEn(...)` literal | — | `context.reminderScreenTitle` (moved into `reminder_strings.dart`) |

### 3.2 Hero card

| # | Deviation (before) | Design source | After |
| --- | --- | --- | --- |
| F4 | `boxShadow: colors.glowShadow` present | line 490: hero card declares `border` only, no `box-shadow` | shadow removed; `border: Border.all(colors.colorLine)` kept |
| F5 | Flat/vertical gradient | line 490 `linear-gradient(160deg, rgba(255,201,126,.22), rgba(183,140,245,.2))` | `LinearGradient` with `_heroGradientBegin/_heroGradientEnd` computed from the repo's CSS-angle convention `begin=(-sinθ,cosθ)`, `end=(sinθ,-cosθ)` at θ=160°; stops `colorAmber@0.22` → `colorAccentPurple@0.20` |
| F6 | Padding 24/24 | line 490 `padding:26px 20px 22px` | `EdgeInsets.symmetric(horizontal: md+xs = 20, vertical: lg = 24)` |
| F7 | Eyebrow styled `colorBackground` + `w600` | line 492 `font-size:12px;color:var(--tx2)` | `type.caption.copyWith(color: colors.colorTextMuted)` |
| F8 | Eyebrow→stepper gap `sm` (8) | line 493 `margin-top:14px` | `CupidSpacing.md` (16) |

### 3.3 Time stepper

| # | Deviation (before) | Design source | After |
| --- | --- | --- | --- |
| F9 | Stepper buttons were bare `IconButton`s tinted `colorAccentPink`, no surface | lines 494 and 496 `width:44px;height:44px;border-radius:50%;background:var(--surf);box-shadow:var(--shadow)`; icon `22px;color:var(--tx2)` | circular `Container` painted at the design's `_stepperDiameter` (44) with `colorSurface` + `platformTokens.elevationShadow`; icon 22 `colorTextMuted`. The `IconButton` around it is held at `platformTokens.tapTarget` by a `SizedBox`, so the 44dp design geometry does not shrink the touch target (round 2 / review D-1 — see §3.9) |
| F10 | Clock had default line-height and no tracking | line 495 `font-size:56px;line-height:1;letter-spacing:-.03em` | `height: 1`, `letterSpacing: -0.03 * 56` added to the existing 56/Nunito-900/`gradientDream` ShaderMask |

### 3.4 Weekday chips

| # | Deviation (before) | Design source | After |
| --- | --- | --- | --- |
| F11 | Chip diameter followed `tapTarget` (48 on material), which wrapped the 7-chip row at 360dp | line 500 `34x34;border-radius:50%` | 34dp visible circle centered inside a `34 × tapTarget` hit box — the design diameter is honoured without dropping below the platform tap target vertically |
| F12 | `Wrap` spacing `CupidSpacing.xs` (4) | line 498 `gap:7px` | `CupidSpacing.sm` (8) |
| F13 | Chip label `w600` | line 500 `font-weight:800` | `FontWeight.w800` |

### 3.5 Confirmation cards (shared-time confirmation UI)

| # | Deviation (before) | Design source | After |
| --- | --- | --- | --- |
| F14 | `radiusSmall` (16) corners, 1px border, no shadow | lines 506 and 511 `border-radius:var(--r-card);box-shadow:var(--shadow)` | `platformTokens.radiusCard`; border replaced by `platformTokens.elevationShadow` |
| F15 | Left-aligned content | lines 506 and 511 `text-align:center` | `crossAxisAlignment` default (center) + `textAlign: TextAlign.center` on both texts |
| F16 | Name row muted-weight | lines 508 and 513 `font-size:12.5px;font-weight:700` | `type.caption.copyWith(color: colors.colorText, fontWeight: FontWeight.w700)` |
| F17 | "Bạn"/"Đối tác" were inline `viEn(...)` literals in two files | — | `context.reminderYouLabel` / `context.reminderPartnerLabel` |

### 3.6 Primary action (three mutually exclusive states)

| # | Deviation (before) | Design source | After |
| --- | --- | --- | --- |
| F18 | All three states rendered at `platformTokens.tapTarget` (48 material) | lines 519/522/525 `height:54px` | shared `_ctaHeight = 54`; confirm CTA wrapped in `SizedBox(height: _ctaHeight)` so the tight parent constraint overrides `CupidPrimaryButton`'s internal `tapTarget` height (that widget is outside this story's write scope) |
| F19 | Waiting pill: no border, icon 18, body-weight text | line 522 `background:var(--surf);border:1px solid var(--line);font-size:15px;font-weight:700;color:var(--tx2)`, `hourglass_top` 20px | `colorSurface` + `Border.all(colorLine)`, icon 20, `fontSize 15 / w700 / colorTextMuted` |
| F20 | Both-confirmed CTA rendered as a greyed-out disabled button | line 525 `background:rgba(121,226,205,.16);border:1.5px solid var(--mint);color:var(--mint);font-size:16;font-weight:800`, `notifications_active` 21px | rebuilt as an `OutlinedButton` whose `disabled*` slots carry the same mint values as the enabled slots, so the inert control still renders the locked enabled treatment |

### 3.7 Rule card

| # | Deviation (before) | Design source | After |
| --- | --- | --- | --- |
| F21 | Card lacked `colorSurface`/`radiusCard`/shadow | line 528 `padding:16px;border-radius:var(--r-card);background:var(--surf);box-shadow:var(--shadow)` | all three applied |
| F22 | Icon tinted with the accent colour | line 530 `swipe_up` 20px `var(--peach)` | `colors.colorPeach`, size 20 (glyph substitution — see Deferred D2) |
| F23 | Body was a single flat muted paragraph | line 531 renders `<strong style="color:var(--tx)">Luật chơi:</strong>` and `<strong>cả hai</strong>` as emphasized runs inside `12.5px;line-height:1.55;color:var(--tx2)` | `Text.rich` over four copy runs (`reminderRuleCardLeadIn` / `BeforeEmphasis` / `Emphasis` / `AfterEmphasis`); emphasized runs use `colorText` + `w700`, the paragraph uses `caption` + `colorTextMuted` + `height: 1.55` |

### 3.8 Firing overlay (dual swipe-to-dismiss affordance)

| # | Deviation (before) | Design source | After |
| --- | --- | --- | --- |
| F24 | Badge was a `gradientHot` circle with `glowShadow`, icon 48 `colorText` | line 1659 `96x96;border-radius:34px;background:rgba(255,201,126,.2)`; icon `52px;color:var(--butter)` | `_badgeSize` square, `_badgeRadius` rounded rect, `colorAmber@0.2` fill, icon 52 `colorButter` |
| F25 | Shake cycle 600ms, amplitude ±6 | line 32 `@keyframes shake` 1s cycle, ±5px | 500ms controller with `repeat(reverse: true)` (= 1s full cycle), amplitude ±5 |
| F26 | Body copy at `type.body` + `colorText`, unbounded measure | line 1661 `font-size:14px;color:rgba(255,255,255,.72);max-width:250px` | `type.caption` + `colorTextMuted`, wrapped in `ConstrainedBox(maxWidth: _bodyMaxWidth)` |
| F27 | Partner pair separated by a plain `CupidSpacing.xl` gap | line 1662 `gap:12px` plus the line 1664 `width:30px;height:1px;background:rgba(255,255,255,.2)` divider | `sm` + `Container(width: _partnerDividerWidth, height: 1, color: colorLine)` + `sm` |
| F28 | Partner status text at `type.body` | lines 1663 and 1665 `font-size:11px` | `type.caption` + `w600`, with a `CupidSpacing.xs` gap under the name |
| F29 | Dismiss CTA reused `CupidPrimaryButton` (flat pink, `tapTarget` height, no leading glyph) | line 1668 `max-width:300px;height:60px;border-radius:999px;background:var(--grad-hot);box-shadow:0 10px 30px rgba(255,127,182,.5)`; `swipe_right` 24px + `16.5px w800` | new `_DismissPill`: `gradientHot`, `glowShadow`, `radiusButton`, `_dismissPillHeight`, capped at `_dismissPillMaxWidth`, leading `CupidIcons.swipeRight` at 24. Rendered at 45% opacity once the viewer has already swiped, because the reminder only clears when both partners swipe (AC4) |

### 3.9 Round-2 fixes (from the rendered comparison and review findings)

| # | Deviation (before) | Design source | After |
| --- | --- | --- | --- |
| F30 | Overlay carried no clock readout at all — round 1 deferred it as D3 | line 1660 `font-family:Nunito;font-weight:900;font-size:52px;line-height:1;margin-top:26px;color:#fff` | `_clockFontSize` (52) `type.display` readout of `state.reminder.time` in local time, `height: 1`, `colorText`, `CupidSpacing.lg` (24) under the badge. Round 1's "this implies a system-alarm treatment" argument does not survive the render — see §5.1 |
| F31 | Scrim was a flat `colorBackground@0.94` fill; the amber radial wash was deferred as D3 | line 1658 `radial-gradient(circle at 50% 26%,rgba(255,201,126,.34),transparent 62%),rgba(23,17,41,.95)` | base opacity corrected 0.94 → 0.95, plus a `RadialGradient` at `_scrimGlowCenter` (0, -0.48) / `_scrimGlowRadius` 1.06 running `colorAmber@0.34` → `colorAmber@0` |
| F32 | Body→partner-row gap `CupidSpacing.lg` (24), a 6px miss against the design and outside the §2 ~4px tolerance | line 1662 `margin-top:30px` | `CupidSpacing.xl` (32), a 2px miss and inside tolerance |
| F33 | Stepper button painted at `platformTokens.tapTarget` (48 on material) rather than the design's 44 (review D-1) | lines 494 and 496 `width:44px;height:44px` | painted circle pinned to `_stepperDiameter` (44); the `IconButton` around it held at `platformTokens.tapTarget` by a `SizedBox`, so the hit area stays 48 on material. No longer a deviation and no longer a deferral |

### 3.10 Round-2 fixes found by the render, not by the static trace

These three were invisible to the per-property source trace in §3 and only
surfaced once the implementation was rendered side by side with the reference.

| # | Deviation (before) | Design source | After |
| --- | --- | --- | --- |
| F34 | Whole content column was vertically centred, pushing the hero card ~120dp down the viewport and leaving a large void under the app bar. F1-F29 all measured *within* the column, so none of them caught it | line 489 `padding:8px 16px 40px` — content flows from the top of the body | `Center` → `Align(alignment: Alignment.topCenter)` in `ReminderScheduleView`. Horizontal centring and the `_maxContentWidth` cap are unchanged, and the scroll behaviour on short viewports is unchanged |
| F35 | Confirm CTA was the shared `CupidPrimaryButton`: flat `colorAccentPink`, 20dp radius, elevation 2, no glow, no leading glyph. F18 only asserted its 54dp height, so the fill/radius/glyph were never checked | line 518 `border-radius:var(--r-btn);background:var(--grad-hot);box-shadow:var(--glow);gap:9px;font-size:16.5px;font-weight:800` plus a `how_to_reg` span at `font-size:21px` | new local `_ConfirmCta`: `gradientHot` fill, `radiusButton` pill, `glowShadow`, `CupidSpacing.sm` (8 vs 9) gap, 16.5px w800 label, and a leading `CupidIcons.check` at 21px standing in for `how_to_reg`. Still an `ElevatedButton` underneath, so ripple, disabled handling and the F18 height assertion are preserved. See §5 D8 |
| F36 | Selected weekday chips filled `colorMint` with `colorBackground` text; unselected filled `colorSurfaceAlt` with `colorText` | line 2237 `bg: i < 5 ? 'var(--grad-hot)' : 'var(--surf)'`, `color: i < 5 ? '#fff' : 'var(--tx2)'` | selected chips fill `gradientHot` with `colorText`; unselected fill `colorSurface` with `colorTextMuted`. The mint accent was never the design's selection colour |

## 4. AC verification

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC1 — dark + `vi` matches the design source for layout, spacing, colour, typography | MET (with §5 deferrals) | F1-F36; every value traced to a cited design-source line, and both AC-bearing states rendered side by side with the reference in §4.5 (`VISUAL_FIDELITY: PASS` each). Automated: `dark + vi at 360dp keeps the weekday row on one line`, `primary CTA renders at the design source 54dp height`, `stepper buttons paint at the design 44dp inside a 48dp hit area`, `renders the design source 52dp clock readout`, `dismiss pill matches the design source 60dp height and 300dp cap` |
| AC2 — deviations corrected in the rendered app, not just documented | MET | 750 insertions / 137 deletions across 5 `lib/` files and 2 test files (`git diff --stat bf80848`). No finding in §3 is documentation-only, and §4.5 shows the corrections in the rendered output rather than only in source |
| AC3 — all user-visible text and icon labels read "nhắc nhở đồng bộ" / "synced reminder"; never "báo thức", "alarm", "Synced Alarm" | MET | `reminder_copy_guard_test.dart` (`mobile/lib string literals never say "báo thức"/"Synced Alarm"/"Do Not Disturb"`) passes. Additionally hardened: the last three inline `viEn(...)` literals (screen title, "Bạn"/"You", "Đối tác"/"Partner") were moved into `reminder_strings.dart`, so `features/reminders/presentation/` now contains **zero** literal user-facing text outside that single file. Remaining `alarm` occurrences are code comments and wire-protocol identifiers (`setAlarm`, `confirmAlarm`, `stopAlarm`, `triggerAlarm`, `alarmStoppedByPartner`, `GET /alarms`), which `story_master.md` lines 45-47 explicitly allow |
| AC4 — dual swipe-to-dismiss interaction visual matches the design source, reframed as an in-app synced reminder, no full-screen system-alarm visual treatment | MET | F24-F32, and the rendered `alarmRinging` comparison in §4.5. The overlay stays an in-app `Material` scrim inside `SafeArea`; no alarm-clock glyph, no system full-screen intent, no DND language. The 5-minute timeout copy is preserved verbatim through `reminderRuleCardAfterEmphasis` and asserted by `rule card copy includes the 5-minute timeout caveat`. Both-partners semantics preserved: the pill dims (does not disappear) after the viewer swipes |
| AC5 — no new entry point | MET | No route, no navigation call, and no `AppShell` change in the diff; `reminder_entry_point_test.dart` (existing reachability test) still passes unchanged |

## 4.5 Rendered evidence (review F-1)

`Design-Screen: alarm`. Both AC-bearing states were rendered and compared.

| Artifact | What it is | Size |
| --- | --- | --- |
| `design-reference-alarm-android.png` | reference, `alarm` schedule state | 406x900 |
| `design-reference-alarm-ringing-android.png` | reference, `alarmRinging` overlay state | 406x900 |
| `implemented-alarm-schedule-412x915.png` | implementation, schedule state | 412x915 |
| `implemented-alarm-ringing-412x915.png` | implementation, overlay state | 412x915 |

### How each side was produced

References: `render-design-canvas.js --entry="Cupid App.dc.html" --screen=alarm
--platform=android --theme=dark --lang=vi`. The tool clicks only `[data-tog]`
and `[data-screen-btn]`, so it cannot reach `alarmRinging` (an internal state at
`Cupid Screens.dc.html:2413`). The ringing reference was produced by a
scratch driver that reuses the same serve/freeze/hide/downscale pipeline and
additionally clicks "Xác nhận giờ này" then "Reo thử ngay" to force the state.

Implementation: **not** an emulator capture. `main_preview.dart:235` resolves
the `alarm` preview id to the DI-backed `ReminderScheduleScreen`, which without
a live backend hydrates into the error state, and the firing overlay only mounts
when `ReminderFiringCubit` receives a server `triggerAlarm` event. Seeding
either state needs a preview fixture in `mobile/lib/main_preview.dart`, which is
outside this story's `WriteScope`; a scope extension was requested and not
granted. Both states were therefore rendered in-process instead, at the same
412x915 Android reference viewport, dark theme, `vi` locale,
`CupidPlatform.material`, with the four bundled variable fonts loaded from
`assets/fonts/` so glyphs and metrics are real:

```
flutter test test/features/reminders --dart-define=CAPTURE_VISUALS=true
```

Harness: `mobile/test/features/reminders/visual_capture_support.dart`
(`captureAtReferenceViewport`), driven by one skipped-by-default test in each of
the two reminder widget test files. This renders the same widget tree the app
mounts, so it is valid evidence for layout, spacing, colour, gradient and
typography. It is **not** evidence for anything that depends on the real device:
platform font fallback, actual touch behaviour, or system insets.

### VISUAL_FIDELITY per state

**`Design-Screen: alarm` (schedule) — VISUAL_FIDELITY: PASS**

Round-1 deltas found by this render and fixed in this pass: F34 (content was
vertically centred, ~120dp low), F35 (CTA flat pink, no gradient/glow/glyph),
F36 (selected chips mint instead of `grad-hot`). After those fixes the remaining
differences are all accounted for:

| Difference | Verdict |
| --- | --- |
| Title "Nhắc nhở đồng bộ" vs reference "Synced Alarm"; eyebrow "Nhắc nhở đồng bộ mỗi sáng" vs "Báo thức chung mỗi sáng" | intended — AC3 forbids "alarm"/"báo thức" |
| No partner avatar circles; "Bạn"/"Đối tác" instead of "Minh"/"Linh" | D1 — `SyncedReminder` carries no display name or avatar URL |
| Confirmed-side tick renders as a missing-glyph box after "Đã xác nhận" | capture-environment artifact: U+2713 is absent from Nunito and the test harness has no system font fallback, so it renders as tofu here but resolves on device. Position differs from the design's leading "✓ đã xác nhận" — see §5 D9 |
| Rule-card and CTA copy reworded | intended — AC3 |
| No bottom tab bar in the implementation capture | harness scope: the capture renders `ReminderScheduleView` alone, not inside `AppShell`. AC5 forbids a new entry point and none was added |
| Status bar, notch and home indicator only in the reference | canvas device chrome, not app content |
| Reference is 406x900 (900 max-edge downscale), implementation is 412x915 native | 1.6% scale; all deltas above are stated in logical dp measured from the widget tree, not from pixel diffing |

**`Design-Screen state: alarmRinging` (firing overlay) — VISUAL_FIDELITY: PASS**

The round-2 additions F30 (52dp clock readout), F31 (amber radial scrim) and F32
(body→partner gap 24→32) are all visible and correct in the render. Badge size
and radius, clock size and weight, body measure, partner row with its hairline
divider, and the gradient dismiss pill with its glow all line up with the
reference. Remaining differences:

| Difference | Verdict |
| --- | --- |
| Badge glyph is a bell (`notificationsActive`), reference shows an alarm clock | intended — D1/AC4, the one genuinely system-alarm element, deliberately substituted |
| No M/L partner avatar circles above the "còn ngủ" labels | D1, same cause as the schedule screen |
| Reference shows the schedule screen ghosted through the scrim; the implementation capture sits on flat `colorBackground` | harness artifact: the capture renders `ReminderFiringOverlay` standalone. In the app `ReminderOverlayHost` mounts it above the shell, and the scrim is `colorBackground` at 0.95 alpha, so the same show-through occurs |
| Amber wash reads stronger than the reference | same cause — with no content beneath, the wash composites against flat background. The token is exact: `colorAmber` (dark) is `#FFC97E`, identical to the design's `--amber` |

## 5. Deferred with rationale

| # | Item | Reason |
| --- | --- | --- |
| D1 | Partner avatar circles (42px on the schedule card, 46px on the overlay) | `SyncedReminder` carries only `requesterId`/`partnerId` — no display name or avatar URL. Rendering an avatar would require a profile lookup that is outside this story's scope |
| D2 | `how_to_reg` (confirm CTA) and `swipe_up` (rule card) glyphs | Neither codepoint exists in `CupidIcons`. That file is outside this story's `WriteScope`, and its dartdoc requires new codepoints be verified against the bundled font cmap via fontTools before being added. Substituted with the nearest verified glyphs already in the set; flagged for a design-system follow-up |
| D3 | ~~Overlay 52px clock readout and the amber radial scrim glow~~ | **RESOLVED in round 2 — no longer deferred.** Both are now implemented (F30, F31). See §5.1 |
| D4 | Distinct "already stopped" pill state on the overlay (design line 1671) | Requires a new copy string; the current implementation conveys the same state through the dimmed pill plus the per-partner status labels |
| D5 | Try-it-now CTA remains functionally inert | Styling only was in scope; its behaviour is unchanged from BaseHead |
| D6 | Light theme and `en` locale visual QA | Out of scope per `story_master.md` OQ5 |
| D7 | Weekday chip horizontal hit area is 34dp, below the 48dp Material minimum (review D-2) | Accepted a11y trade-off, recorded here rather than left implicit in a code comment. The design fixes the chip at `34x34` (line 500) with a `7px` gap (line 498); seven 48dp chips plus gaps need ~385dp of row and the narrowest supported width is 360dp, so honouring `tapTarget` horizontally wrapped the row onto two lines and broke the design. `reminder_weekday_chips.dart` therefore renders `SizedBox(width: _chipDiameter /* 34 */, height: platformTokens.tapTarget)`: the **vertical** hit area keeps the full 48dp, only the horizontal axis is reduced. Chips are laid out contiguously with an 8dp gap, so there is no dead zone between neighbours — the practical cost is a ~7dp-per-side reduction at the row's outer edges. Regression from BaseHead, where chips were 48×48 but the row wrapped. Escalate to UX if a 360dp-safe alternative is wanted (e.g. a two-row layout or a narrower gap) |
| D8 | The shared `CupidPrimaryButton` still paints a flat `colorAccentPink` at a 20dp radius | F35 fixed this screen only, with a local `_ConfirmCta`. The shared component is `lib/design_system/adaptive/cupid_primary_button.dart`, outside this story's `WriteScope`, and every other screen renders through it. There is a real contract conflict to resolve: `ux/uiux-spec.md` §6 specifies "Filled button, 20dp corner radius" app-wide, while the alarm screen's design source specifies a `grad-hot` pill with a glow. Escalate to UX/design-system to decide which wins; if the design source wins, the fix belongs in the shared component and `_ConfirmCta` should then be deleted |
| D9 | Confirm-state tick is trailing ("Đã xác nhận ✓") where the design source has it leading ("✓ đã xác nhận", line 2239) | Copy-ordering nit outside the round-2 brief, and the string is pinned by `reminder_copy_guard_test.dart` plus two widget assertions. Worth folding into whichever pass next touches `reminder_strings.dart`. Consider rendering it as `CupidIcons.check` rather than a literal U+2713 at the same time: the codepoint is absent from Nunito, so it currently depends on platform font fallback |

### 5.1 Why D3 was reversed

Round 1 dropped the overlay's 52px clock readout and the amber radial scrim on
the argument that both "push the overlay toward a full-screen system-alarm
visual treatment", which AC4 rules out. The rendered overlay reference
(`design-reference-alarm-ringing-android.png`) does not support that reading:

- The 52px `06:30` readout is the **single most prominent element** in the
  composition after the badge, and it is plain white type on the scrim — not
  system chrome. It is also the only place the overlay states *which* reminder
  is firing. Removing it left the overlay saying "swipe to wake" with no time
  anywhere on screen.
- What AC4 actually forbids is the OS alarm paradigm: a full-screen intent, the
  alarm-clock glyph, and snooze/dismiss system controls. None of those follow
  from a time readout. The one genuinely system-alarm-flavoured element in the
  design source — the `alarm` glyph at line 1659 — remains **correctly**
  substituted with `notificationsActive` (D1 in round 1, unchanged).
- The amber radial wash is a scrim gradient in the app's own `colorAmber`, the
  same token already used at 0.2 alpha for the badge fill it sits behind. It
  reads as warmth, not as system chrome.

Net effect: the AC4 rationale for D3 was over-broad. Both elements are now
implemented (F30, F31) and the overlay still stays an in-app `Material` scrim
inside `SafeArea` with no alarm-clock glyph and no full-screen intent.

## 6. Verification commands and results

All commands run from
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-021/mobile`
with `export PATH="/Users/alantravala/flutter/bin:$PATH"` (Flutter 3.44.1
stable / Dart 3.12.1; the SDK is not on the default PATH on this machine).

### Static analysis

```
flutter analyze --no-fatal-infos lib/features/reminders test/features/reminders
```

Result: **PASS** — `6 issues found. (ran in 2.4s)`, all info-level and all
pre-existing at BaseHead:

- `prefer_initializing_formals` ×4 — `reminder_firing_cubit.dart:53-56`
- `prefer_initializing_formals` ×1 — `reminder_overlay_host.dart:21`
- `deprecated_member_use` (`SemanticsService.announce`) — now
  `reminder_firing_overlay.dart:93` (shifted from :73 by the round-2 additions)

Zero issues originate from the files changed in this story. No errors, no
warnings.

Note: an earlier run reported 13 errors of the form
`Target of URI doesn't exist: 'package:cupid_mobile/l10n/generated/app_l10n.dart'`.
These were an artifact of the freshly created worktree lacking generated l10n
output; resolved by running `flutter gen-l10n` (which uses the checked-in
`l10n.yaml`). Not a code defect.

### Tests

```
flutter test test/features/reminders
```

Result: **PASS** — `+71 ~2: All other tests passed!` The two skipped tests are
the §4.5 capture tests, which are off unless `CAPTURE_VISUALS` is defined.

Re-running with captures enabled regenerates both implementation PNGs and keeps
the suite green:

```
flutter test test/features/reminders --dart-define=CAPTURE_VISUALS=true
```

Result: **PASS** — `+73: All tests passed!`

Copy guard confirmed independently:

```
flutter test test/features/reminders/reminder_copy_guard_test.dart
```

Result: **PASS** — `+2: All tests passed!`

### Tests added by this story

`mobile/test/features/reminders/reminder_schedule_screen_test.dart`, group
`ReminderScheduleView design fidelity (STORY-021)`:

1. `dark + vi at 360dp keeps the weekday row on one line` — pins the F11 fix.
   Asserts all seven `vi` chip labels share one `dy`, at a 360×800 viewport
   under dark theme and `Locale('vi')`.
2. `primary CTA renders at the design source 54dp height` — pins F18.
3. `rule card renders the emphasized "cả hai" run` — pins F23 by walking the
   `TextSpan` tree and asserting exactly `['Luật chơi:', 'cả hai']` render at
   `w700`.

`mobile/test/features/reminders/reminder_firing_overlay_test.dart`:

4. `dismiss pill matches the design source 60dp height and 300dp cap` — pins
   F29 at a 360dp viewport.

Added in round 2:

5. `stepper buttons paint at the design 44dp inside a 48dp hit area` — pins F33
   by asserting the circular `Container` is 44×44 while its `IconButton` stays
   48×48.
6. `renders the design source 52dp clock readout for the firing time` — pins
   F30. Computes the expected string from `reminder.time.toLocal()` rather than
   a literal, so it does not depend on the host timezone.
7. `captures the schedule state at the Android reference viewport` and
   `captures the alarmRinging state at the Android reference viewport` — the
   §4.5 evidence generators. Skipped unless `CAPTURE_VISUALS` is defined.

## 7. Files changed

Cumulative, `git diff --stat bf80848 -- mobile/`:

```
mobile/lib/features/reminders/presentation/reminder_strings.dart                 |  30 ++-
mobile/lib/features/reminders/presentation/screens/reminder_schedule_screen.dart | 264 +++++++++++++++++----
mobile/lib/features/reminders/presentation/widgets/reminder_firing_overlay.dart  | 260 +++++++++++++++-----
mobile/lib/features/reminders/presentation/widgets/reminder_time_stepper.dart    |  30 ++-
mobile/lib/features/reminders/presentation/widgets/reminder_weekday_chips.dart   |  54 +++--
mobile/test/features/reminders/reminder_firing_overlay_test.dart                 |  91 +++++++
mobile/test/features/reminders/reminder_schedule_screen_test.dart                | 158 +++++++++++-
7 files changed, 750 insertions(+), 137 deletions(-)
```

Plus one new untracked file, `mobile/test/features/reminders/visual_capture_support.dart`
(the §4.5 capture harness), and four PNGs in this directory.

Round 2 alone, `git diff --stat 6aa77cb -- mobile/`: 6 files changed,
341 insertions(+), 79 deletions(-).

## 8. Reviewer notes

- Diff baseline: `git -C <worktree> diff bf808483223580df81b1fb951b141a6597cb82dd`.
  Round-2 baseline: `6aa77cb8beff3de1caa9f88489651ba53585f3bd`.
- Round 1 claimed no rendered evidence was possible in this lane. That claim was
  wrong and is withdrawn. Both design references and both implementation states
  are now rendered and compared in §4.5, with a `VISUAL_FIDELITY` verdict each.
- Read the §4.5 "How each side was produced" note before assessing the
  implementation PNGs: they are in-process renders at the reference viewport
  with the real bundled fonts, not emulator screenshots. Two of the residual
  differences (scrim show-through, the tofu tick) are artifacts of that harness
  and are called out as such rather than counted as deviations.
- The emulator route was attempted and abandoned deliberately, not skipped:
  `main_preview.dart:235` maps the `alarm` preview id to the DI-backed
  `ReminderScheduleScreen`, which hydrates into the error state with no backend,
  and the overlay needs a server `triggerAlarm`. The fixture needed to seed
  either state belongs in `mobile/lib/main_preview.dart`, outside this story's
  `WriteScope`. A one-file scope extension was requested from Scrum Master and
  no decision came back, so that file was left untouched.
- Three findings in §3.10 (F34, F35, F36) were caught only by the render. F35
  additionally exposes a real spec conflict between `ux/uiux-spec.md` §6 and the
  screen-level design source — see §5 D8. That one wants a UX decision, not a
  mobile-dev decision.
- `story_master.md`: only the Implementation row was checked. The Review row is
  left for the Reviewer gate.

MOBILE_COMPLETE: YES
