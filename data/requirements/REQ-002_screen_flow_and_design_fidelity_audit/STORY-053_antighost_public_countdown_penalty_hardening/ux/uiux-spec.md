# STORY-053 UX Spec — Anti-Ghosting public-countdown penalty row

## Design source

`cupid-app-design-system/project/Cupid Screens.dc.html`, the `isAnti` penalty
card, lines 562-579. That card container (`padding:6px 17px`, line 562) holds
three independent toggle rows separated by `height:1px;background:var(--line)`
dividers (lines 568, 574): row 1 `Đếm ngược công khai`/`Public countdown`
(lines 563-567, this story), row 2 `Emoji Storm` (lines 569-573, existing,
untouched), row 3 `Phát âm thanh`/`Sound override` (lines 575-579, existing,
untouched except the RWB-019 `vi` string fix). All three rows share one CSS
rule shape: `padding:14px 0`, a `40px` leading tile, and a `52x31` pill switch
at the trailing edge — the mock treats them as visually uniform siblings, not
a "new row plus two old rows."

## 1. Placement inside the Penalty card

**Finding: the mock's penalty-card block has no title/heading of its own.**
Unlike the Ghost-timeout card above it (`Ngưỡng "bơ"`/`Ghost timeout`, its own
heading text at line 553), the penalty-card block (lines 562-579) goes
straight into its three rows — no heading div anywhere in that block. The
app's own `Text(l10n.anti_ghost_penalty_label)` heading
(`anti_ghost_screen.dart:732-735`) sitting directly above `_PenaltyRadioGroup`
is an app-only addition that labels the radio group specifically, not the
card as a whole.

**Placement decision:** the new toggle row is the literal first child inside
the Penalty `_SettingsCard`'s `Column`, **before** the existing `"Penalty"`/
`"Hình phạt"` heading text, separated from it by a `1px` divider
(`colors.colorLine`) — the same divider treatment the design source itself
already uses between its own row 1 and row 2 (line 568). The existing
`"Penalty"` heading and `_PenaltyRadioGroup` stay exactly where they are today,
directly below that divider, with zero code changes to either. This:

- Satisfies AC2 ("new row... FIRST row... above `_PenaltyRadioGroup`")
  literally.
- Satisfies AC5 ("`_PenaltyRadioGroup`... functionally and visually
  unchanged") by construction — nothing in that block is touched or
  repositioned relative to its own heading.
- Removes the ordering ambiguity the row's a toggle (not a `RadioListTile`) —
  visually could be read as a floating fourth option above the radio group.

Do not rename, move, or add a new heading above the toggle row itself — its
own title/subtitle (§2) are self-descriptive, matching the mock's own
"no card-level heading" treatment for this block.

`_SettingsCard`'s existing padding override for this card
(`EdgeInsets.fromLTRB(md, md, md, sm)`, `anti_ghost_screen.dart:723-728`)
needs no change — it already matches the card-level padding rhythm the mock
uses for all three rows.

## 2. Component spec — the new row

An independent toggle row, **not** a `RadioListTile` and **not** a member of
`Penalty.values`/`_PenaltyRadioGroup` (AC5) — its own small stateless row
widget bound to `publicCountdown: bool`.

- **Leading tile**: reuse the existing `_penaltyTileSize` (40) /
  `_penaltyGlyphSize` (21) constants and `context.cupidPlatform.radiusSmall`
  radius token (same recipe `_PenaltyIconTile` already uses, matching the
  mock's `40x40 rounded-14`). Background `colors.colorAmber.withValues(alpha:
  0.2)`, glyph `CupidIcon(CupidIcons.timer, ...)` in `colors.colorAmber` —
  `CupidIcons.timer` and `colors.colorAmber` are both already established
  anti-ghosting tokens (`ghost_state_row.dart:124`,
  `anti_ghost_entry_card.dart:174` use the same icon+color pairing for this
  feature's other timer/pending visuals). No new token needed.
- **Title/subtitle column**: `Expanded`, gap from tile via `CupidSpacing.md`
  (matches `_ActiveSummaryBody`'s existing tile-to-text gap,
  `anti_ghost_screen.dart:342`). Title: `type.body.copyWith(fontWeight:
  FontWeight.w700, color: colors.colorText)` — same role/weight
  `_PenaltyRadioGroup`'s row titles use. Subtitle:
  `type.caption.copyWith(color: colors.colorTextMuted)` — same caption/muted
  role used elsewhere on this screen for subtitle-tier text.
- **Trailing switch**: model on the existing `_ConsentSwitch`
  (`mobile/lib/features/chat/presentation/screens/ghost_settings_screen.dart:375-`),
  which already implements the mock's exact `52x31`(ish) `--grad-hot`/`--line`
  pill-with-white-knob pattern for a different screen in this same app. Reuse
  that visual recipe rather than a native Material `Switch` (keeps the
  gradient-track look established for this design system) and reuse its
  `SizedBox(width: 54, height: context.cupidPlatform.tapTarget)` wrapper so
  the tappable hit area meets the platform tap-target minimum (44/48dp) even
  though the visual pill is only ~31dp tall. Whether this becomes a shared
  design-system widget or a local duplicate in the anti-ghosting feature is a
  Tech Lead/Mobile Dev implementation call, not a UX decision.
- **Row height parity**: the mock gives all three rows the same `padding:14px
  0` rhythm, so the new row should read as the same height as the
  `RadioListTile` rows below it — no visible seam at the divider. Flag this
  for Mobile Dev/QA visual comparison against the design source at
  implementation time rather than mandating an exact padding value here,
  since `RadioListTile`'s computed row height depends on Flutter's default
  `ListTile` metrics, not enumerated in this spec.
- **Interaction surface**: only the switch itself is tappable — the mock puts
  `cursor:pointer` only on the switch div (line 566), not the row container
  (line 563). Do not make the whole row tappable; that would be a new
  interaction beyond the locked design source (`story_master.md` Out of
  Scope).

## 3. States

- **State A — editable (`_ProposeForm`)**: fully interactive. Seed the
  switch's initial value from `widget.prefill?.publicCountdown ?? true`,
  mirroring the existing `_penalty = widget.prefill?.penalty ??
  Penalty.emojiStorm` seeding in the same `initState` — so re-opening
  "Change" pre-fills the last known/active value rather than always
  resetting to ON.
- **State B — my own pending proposal (`_PendingMineBody`)**: reuse the
  existing pattern verbatim, no new wrapper/badge. The row sits inside the
  same outer `Semantics(label: l10n.anti_ghost_pending_mine_disabled_reason,
  container: true, explicitChildNodes: true)` that already covers the
  Ghost-timeout and Penalty cards together (`anti_ghost_screen.dart:431-437`)
  — one combined "disabled, waiting for partner" announcement, not a new
  per-row one. Visual treatment on disable:
  - Tile mutes to `colors.colorSurfaceAlt` / `colors.colorTextMuted`,
    mirroring `_PenaltyIconTile`'s existing `enabled` param convention.
  - Title mutes to `colors.colorTextMuted`.
  - Switch becomes non-interactive (`onTap`/`onChanged` → `null`), but its
    track **keeps its true gradient/line fill** showing the actual proposed
    on/off value — do not also grey out the track. This mirrors
    `_TimeoutSegment`'s existing precedent (a segment's `selected` gradient
    fill is independent of the control's own `enabled` flag,
    `anti_ghost_screen.dart:962`) and is deliberate: State B's whole purpose
    is letting the user see exactly what they proposed while it's locked;
    muting the one signal that answers "what did I propose" would defeat
    that.
- **State C — reviewing partner's proposal (`_PendingPartnerBody`)**: this
  state does not render the row-list Penalty card at all today — it renders
  one condensed summary card (icon tile + one-line text) plus Accept/Decline
  buttons whose accessible labels already embed the actual values
  (`anti_ghost_accept_semantic_label(minutes, penalty)`). Recommend leaving
  this condensed summary and its semantic-label strings **unchanged** for
  this story. `story_master.md` In Scope item 3 ties the new row specifically
  to "the existing Penalty card" (the row-list layout), which this state
  doesn't use; extending the condensed summary to also state
  `publicCountdown` would need new l10n keys/parameters not in PO's In Scope
  list (items 1-7). Flagging this explicitly as a deliberate scope boundary
  so it isn't silently reintroduced mid-implementation — if Tech Lead
  disagrees, that's a scope call to take back to Product Owner, not something
  to resolve ad hoc in code.
- **State D — active/committed (`_ActiveSummaryBody`)**: same reasoning as
  State C — its condensed `anti_ghost_active_summary(minutes, penalty)`
  two-value string stays unchanged. `publicCountdown`'s only user-visible
  surface in this story is the Penalty card row in States A/B.
- **In-flight submit**: no per-row loading/spinner state exists today for any
  field (not `timeoutMinutes`, not `penalty`) — submission in flight is
  communicated once, at the whole-form level, via
  `_ProposeFormState.isSubmitting` disabling the `CupidPrimaryButton` CTA
  (`anti_ghost_screen.dart:754-760`). Reuse that; do not add a new per-row
  loading indicator for the toggle.

## 4. Two locale renderings — overflow check

- **vi/dark**: title `Đếm ngược công khai` (19 chars), subtitle `Hiện trên
  dashboard cả hai` (26 chars).
- **en**: title `Public countdown` (17 chars), subtitle `Shown on both
  dashboards` (25 chars).
- No overflow risk in either locale: the same row layout (same `Expanded`
  text column between the same 40px tile and same-width switch) already
  renders longer strings today without incident — row 2's vi subtitle `Bắn
  emoji tràn màn hình đối phương` (35 chars) and row 3's vi subtitle `Tắt mặc
  định — dễ gây khó chịu thật` (36 chars) are both longer than this row's vi
  subtitle and already ship at this exact width. No `maxLines`/`overflow`
  handling exists on the radio rows' titles today; don't add any to the new
  row either — parity with the existing rows, and the new copy is shorter
  regardless.

## 5. Accessibility

- Wrap the switch in `Semantics(toggled: <value>, enabled: <enabled>, label:
  '<title>. <subtitle>')` around the tappable pill (mirroring
  `_ConsentSwitch`'s existing `Semantics(button: true, label: ...)` wrapper,
  but adding `toggled` since this is a genuine on/off switch, not a bare
  button). `toggled` lets TalkBack/VoiceOver announce on/off state natively —
  no separate "on"/"off" l10n string is needed.
  - Title + subtitle text feed the label directly; do not rely on the
    screen reader separately discovering the row's plain `Text` widgets and
    the switch as disconnected nodes — one coherent announcement covering
    title, subtitle, and state.
- Touch target: switch tappable area ≥ `context.cupidPlatform.tapTarget`
  (44/48dp), via the same `SizedBox` wrapper `_ConsentSwitch` already uses —
  the visual 31dp pill alone is under the platform minimum.
- Disabled state (State B): no new accessibility string needed — the row
  inherits the existing combined `anti_ghost_pending_mine_disabled_reason`
  semantics label already wrapping the whole card stack.

## 6. l10n keys

Confirm PO's suggested naming:
`anti_ghost_public_countdown_title` / `anti_ghost_public_countdown_subtitle`
in both `mobile/lib/l10n/arb/app_vi.arb` and `app_en.arb`. This matches the
existing `anti_ghost_<field>_title`/`anti_ghost_pending_mine_title`-style
naming already in both files, and correctly avoids `anti_ghost_penalty_*`
since `publicCountdown` is not a `Penalty` enum member (per
`story_master.md`'s own note). No other new keys needed — on/off state is
conveyed via `Semantics(toggled:)`, not a string (§5).

## Out of scope (unchanged from `story_master.md`)

- No live/ticking public-countdown display anywhere (home dashboard or
  elsewhere) — this story delivers the settings row only.
- No change to `_PenaltyRadioGroup`'s code, styling, or the `Penalty`
  enum/wire contract.
- No change to `_PendingPartnerBody`'s or `_ActiveSummaryBody`'s condensed
  summary cards or semantic-label strings (§3, States C/D).
- No interaction surface beyond the switch itself (no whole-row tap-to-toggle).
- Light theme / `en`-locale visual QA remains infra-only, consistent with
  every prior REQ-002 hardening story on this screen.
