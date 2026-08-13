# STORY-021 Visual Fidelity Report — Synced Reminder

- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Story: STORY-021 (Synced Reminder design fidelity)
- Lane: mobile-dev
- Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-021`
- BaseHead: `bf808483223580df81b1fb951b141a6597cb82dd`
- Audit conditions: dark theme enabled, `vi` locale, `CupidPlatform.material`
- Design source (locked): `cupid-app-design-system/project/Cupid Screens.dc.html`

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
| F1 | Scroll padding `EdgeInsets.all(CupidSpacing.lg)` = 24 all round | line 488 `padding:8px 16px 40px` | `EdgeInsets.fromLTRB(md, sm, md, xl+sm)` = 16/8/16/40 |
| F2 | Section gaps `CupidSpacing.lg` (24) ×4 | line 496/501/511/526 `margin-top:14px` | `CupidSpacing.md` (16) ×4 |
| F3 | AppBar title used an inline `viEn(...)` literal | — | `context.reminderScreenTitle` (moved into `reminder_strings.dart`) |

### 3.2 Hero card

| # | Deviation (before) | Design source | After |
| --- | --- | --- | --- |
| F4 | `boxShadow: colors.glowShadow` present | line 490: hero card declares `border` only, no `box-shadow` | shadow removed; `border: Border.all(colors.colorLine)` kept |
| F5 | Flat/vertical gradient | line 490 `linear-gradient(160deg, rgba(255,201,126,.22), rgba(183,140,245,.2))` | `LinearGradient` with `_heroGradientBegin/_heroGradientEnd` computed from the repo's CSS-angle convention `begin=(-sinθ,cosθ)`, `end=(sinθ,-cosθ)` at θ=160°; stops `colorAmber@0.22` → `colorAccentPurple@0.20` |
| F6 | Padding 24/24 | line 490 `padding:26px 20px 22px` | `EdgeInsets.symmetric(horizontal: md+xs = 20, vertical: lg = 24)` |
| F7 | Eyebrow styled `colorBackground` + `w600` | line 494 `font-size:12px;color:var(--tx2)` | `type.caption.copyWith(color: colors.colorTextMuted)` |
| F8 | Eyebrow→stepper gap `sm` (8) | line 496 `margin-top:14px` | `CupidSpacing.md` (16) |

### 3.3 Time stepper

| # | Deviation (before) | Design source | After |
| --- | --- | --- | --- |
| F9 | Stepper buttons were bare `IconButton`s tinted `colorAccentPink`, no surface | line 497 `44x44;border-radius:50%;background:var(--surf);box-shadow:var(--shadow)`; icon `22px;color:var(--tx2)` | circular `Container` at `platformTokens.tapTarget` with `colorSurface` + `platformTokens.elevationShadow`; icon 22 `colorTextMuted` |
| F10 | Clock had default line-height and no tracking | line 499 `font-size:56px;line-height:1;letter-spacing:-.03em` | `height: 1`, `letterSpacing: -0.03 * 56` added to the existing 56/Nunito-900/`gradientDream` ShaderMask |

### 3.4 Weekday chips

| # | Deviation (before) | Design source | After |
| --- | --- | --- | --- |
| F11 | Chip diameter followed `tapTarget` (48 on material), which wrapped the 7-chip row at 360dp | line 500 `34x34;border-radius:50%` | 34dp visible circle centered inside a `34 × tapTarget` hit box — the design diameter is honoured without dropping below the platform tap target vertically |
| F12 | `Wrap` spacing `CupidSpacing.xs` (4) | line 500 `gap:7px` | `CupidSpacing.sm` (8) |
| F13 | Chip label `w600` | line 500 `font-weight:800` | `FontWeight.w800` |

### 3.5 Confirmation cards (shared-time confirmation UI)

| # | Deviation (before) | Design source | After |
| --- | --- | --- | --- |
| F14 | `radiusSmall` (16) corners, 1px border, no shadow | line 503 `border-radius:var(--r-card);box-shadow:var(--shadow)` | `platformTokens.radiusCard`; border replaced by `platformTokens.elevationShadow` |
| F15 | Left-aligned content | line 503 `text-align:center` | `crossAxisAlignment` default (center) + `textAlign: TextAlign.center` on both texts |
| F16 | Name row muted-weight | line 505 `12.5px;font-weight:700` | `type.caption.copyWith(color: colors.colorText, fontWeight: FontWeight.w700)` |
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
| F21 | Card lacked `colorSurface`/`radiusCard`/shadow | line 527 `padding:16px;border-radius:var(--r-card);background:var(--surf);box-shadow:var(--shadow)` | all three applied |
| F22 | Icon tinted with the accent colour | line 528 `swipe_up` 20px `var(--peach)` | `colors.colorPeach`, size 20 (glyph substitution — see Deferred D2) |
| F23 | Body was a single flat muted paragraph | line 529 renders `<strong style="color:var(--tx)">Luật chơi:</strong>` and `<strong>cả hai</strong>` as emphasized runs inside `12.5px;line-height:1.55;color:var(--tx2)` | `Text.rich` over four copy runs (`reminderRuleCardLeadIn` / `BeforeEmphasis` / `Emphasis` / `AfterEmphasis`); emphasized runs use `colorText` + `w700`, the paragraph uses `caption` + `colorTextMuted` + `height: 1.55` |

### 3.8 Firing overlay (dual swipe-to-dismiss affordance)

| # | Deviation (before) | Design source | After |
| --- | --- | --- | --- |
| F24 | Badge was a `gradientHot` circle with `glowShadow`, icon 48 `colorText` | line 1659 `96x96;border-radius:34px;background:rgba(255,201,126,.2)`; icon `52px;color:var(--butter)` | `_badgeSize` square, `_badgeRadius` rounded rect, `colorAmber@0.2` fill, icon 52 `colorButter` |
| F25 | Shake cycle 600ms, amplitude ±6 | line 32 `@keyframes shake` 1s cycle, ±5px | 500ms controller with `repeat(reverse: true)` (= 1s full cycle), amplitude ±5 |
| F26 | Body copy at `type.body` + `colorText`, unbounded measure | line 1661 `font-size:14px;color:rgba(255,255,255,.72);max-width:250px` | `type.caption` + `colorTextMuted`, wrapped in `ConstrainedBox(maxWidth: _bodyMaxWidth)` |
| F27 | Partner pair separated by a plain `CupidSpacing.xl` gap | line 1664 `gap:12px` with a `30px × 1px rgba(255,255,255,.2)` divider | `sm` + `Container(width: _partnerDividerWidth, height: 1, color: colorLine)` + `sm` |
| F28 | Partner status text at `type.body` | line 1665 `font-size:11px` | `type.caption` + `w600`, with a `CupidSpacing.xs` gap under the name |
| F29 | Dismiss CTA reused `CupidPrimaryButton` (flat pink, `tapTarget` height, no leading glyph) | line 1668 `max-width:300px;height:60px;border-radius:999px;background:var(--grad-hot);box-shadow:0 10px 30px rgba(255,127,182,.5)`; `swipe_right` 24px + `16.5px w800` | new `_DismissPill`: `gradientHot`, `glowShadow`, `radiusButton`, `_dismissPillHeight`, capped at `_dismissPillMaxWidth`, leading `CupidIcons.swipeRight` at 24. Rendered at 45% opacity once the viewer has already swiped, because the reminder only clears when both partners swipe (AC4) |

## 4. AC verification

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC1 — dark + `vi` matches the design source for layout, spacing, colour, typography | MET (with §5 deferrals) | F1-F29 above; every value traced to a cited design-source line. Automated: `dark + vi at 360dp keeps the weekday row on one line`, `primary CTA renders at the design source 54dp height`, `dismiss pill matches the design source 60dp height and 300dp cap` |
| AC2 — deviations corrected in the rendered app, not just documented | MET | 442 insertions / 91 deletions across 5 `lib/` files (`git diff --stat bf80848`). No finding in §3 is documentation-only |
| AC3 — all user-visible text and icon labels read "nhắc nhở đồng bộ" / "synced reminder"; never "báo thức", "alarm", "Synced Alarm" | MET | `reminder_copy_guard_test.dart` (`mobile/lib string literals never say "báo thức"/"Synced Alarm"/"Do Not Disturb"`) passes. Additionally hardened: the last three inline `viEn(...)` literals (screen title, "Bạn"/"You", "Đối tác"/"Partner") were moved into `reminder_strings.dart`, so `features/reminders/presentation/` now contains **zero** literal user-facing text outside that single file. Remaining `alarm` occurrences are code comments and wire-protocol identifiers (`setAlarm`, `confirmAlarm`, `stopAlarm`, `triggerAlarm`, `alarmStoppedByPartner`, `GET /alarms`), which `story_master.md` lines 45-47 explicitly allow |
| AC4 — dual swipe-to-dismiss interaction visual matches the design source, reframed as an in-app synced reminder, no full-screen system-alarm visual treatment | MET | F24-F29. The overlay stays an in-app `Material` scrim inside `SafeArea`; no alarm-clock glyph, no system full-screen intent, no DND language. The 5-minute timeout copy is preserved verbatim through `reminderRuleCardAfterEmphasis` and asserted by `rule card copy includes the 5-minute timeout caveat`. Both-partners semantics preserved: the pill dims (does not disappear) after the viewer swipes |
| AC5 — no new entry point | MET | No route, no navigation call, and no `AppShell` change in the diff; `reminder_entry_point_test.dart` (existing reachability test) still passes unchanged |

## 5. Deferred with rationale

| # | Item | Reason |
| --- | --- | --- |
| D1 | Partner avatar circles (42px on the schedule card, 46px on the overlay) | `SyncedReminder` carries only `requesterId`/`partnerId` — no display name or avatar URL. Rendering an avatar would require a profile lookup that is outside this story's scope |
| D2 | `how_to_reg` (confirm CTA) and `swipe_up` (rule card) glyphs | Neither codepoint exists in `CupidIcons`. That file is outside this story's `WriteScope`, and its dartdoc requires new codepoints be verified against the bundled font cmap via fontTools before being added. Substituted with the nearest verified glyphs already in the set; flagged for a design-system follow-up |
| D3 | Overlay 52px clock readout and the amber radial scrim glow | Both push the overlay toward a full-screen system-alarm visual treatment, which AC4 explicitly rules out. Held pending a UX call |
| D4 | Distinct "already stopped" pill state on the overlay (design line 1672) | Requires a new copy string; the current implementation conveys the same state through the dimmed pill plus the per-partner status labels |
| D5 | Try-it-now CTA remains functionally inert | Styling only was in scope; its behaviour is unchanged from BaseHead |
| D6 | Light theme and `en` locale visual QA | Out of scope per `story_master.md` OQ5 |

## 6. Verification commands and results

All commands run from
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-021/mobile`
with `export PATH="/Users/alantravala/flutter/bin:$PATH"` (Flutter 3.44.1
stable / Dart 3.12.1; the SDK is not on the default PATH on this machine).

### Static analysis

```
flutter analyze --no-fatal-infos lib/features/reminders test/features/reminders
```

Result: **PASS** — `6 issues found. (ran in 11.7s)`, all info-level and all
pre-existing at BaseHead:

- `prefer_initializing_formals` ×4 — `reminder_firing_cubit.dart:53-56`
- `prefer_initializing_formals` ×1 — `reminder_overlay_host.dart:21`
- `deprecated_member_use` (`SemanticsService.announce`) — `reminder_firing_overlay.dart:73`

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

Result: **PASS** — `+69: All tests passed!` (69 tests across 8 files).

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

## 7. Files changed

```
mobile/lib/features/reminders/presentation/reminder_strings.dart                 |  30 +++-
mobile/lib/features/reminders/presentation/screens/reminder_schedule_screen.dart | 185 +++++++++++++----
mobile/lib/features/reminders/presentation/widgets/reminder_firing_overlay.dart  | 134 ++++++++++---
mobile/lib/features/reminders/presentation/widgets/reminder_time_stepper.dart    |  17 +-
mobile/lib/features/reminders/presentation/widgets/reminder_weekday_chips.dart   |  50 +++--
mobile/test/features/reminders/reminder_firing_overlay_test.dart                 |  32 +++
mobile/test/features/reminders/reminder_schedule_screen_test.dart                |  85 +++++++++
7 files changed, 442 insertions(+), 91 deletions(-)
```

## 8. Reviewer notes

- Diff baseline: `git -C <worktree> diff bf808483223580df81b1fb951b141a6597cb82dd`.
- No runtime/device screenshots were captured: this lane has no provisioned
  emulator or simulator, and provisioning one is outside mobile-dev's
  authority. Evidence is the per-property design-source trace in §3 plus the
  four geometry/typography assertions in §6.
- `story_master.md`: only the Implementation row was checked. The Review row is
  left for the Reviewer gate.

MOBILE_COMPLETE: YES
