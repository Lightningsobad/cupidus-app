# UX Spec: STORY-021 — Privacy screen editable control (AC2)

Scope: exactly one UX decision — placement/shape of the editable control for
`User.isGhostModeEnabled` on `privacy_screen.dart`. Does not touch AC3
(notification settings) or `notification_settings_screen.dart`, per Handoff
Control scoping. Does not redesign the three existing tier cards; their
content and layout stay pixel-for-pixel unchanged.

## 1. Context found in code (why this shape, not another)

- The privacy screen (`privacy_screen.dart`) is currently a plain
  `StatelessWidget`, `ListView` of `l10n.privacy_intro` + three `_TierCard`s.
  No Cubit/Bloc wraps it today.
- `AccountCubit` (`presentation/account_cubit.dart`) already fetches
  `CupidProfile` (which already carries `isGhostModeEnabled`, see
  `domain/cupid_profile.dart:43`) via `AccountRepository.fetchProfile()`, and
  already exposes `AccountLoading` / `AccountLoaded(profile)` /
  `AccountFailed(failure)` states plus an `applyUpdated(profile)` method built
  exactly for "reflect a successful PATCH response without a refetch." This is
  the natural state source for both reading and writing the new toggle — no
  new fetch path is needed.
- **Important existing-code finding, not a blocker but must inform the
  label:** `isGhostModeEnabled` already has a second, fully built editable UI
  elsewhere in the app — `GhostSettingsScreen`
  (`features/chat/presentation/screens/ghost_settings_screen.dart`, reached
  from the Home dashboard tile, unrelated to this story's screen). That
  screen calls the same field the same way (`GhostConsentStore.optIn()` /
  `optOut()` → `PATCH /users/me {isGhostModeEnabled}`,
  `ghost_consent_store.dart:32-49`) and labels its toggle **"Typing Ghost"**
  (`chat_strings.dart:133-134`), with its own two-sided "You / Partner"
  consent framing and an `on/off/pending` three-state model
  (`ghost_cubit.dart:148-153` — note: that "pending" is a *mutual-consent*
  state, "have I received a ghost-typing event this session," not a
  network-in-flight state; do not reuse that vocabulary here, it means
  something different).
  This story's control is a plain global on/off wired straight to the PATCH
  call, with no consent/partner framing — a materially simpler affordance
  for the same underlying flag. Reusing the exact label "Typing Ghost" here
  would read as a second, competing entry point for the same setting and
  could confuse a user who sees different immediate-vs-pending state between
  the two screens. **Decision: label this control distinctly and point the
  user at the other screen for the fuller mutual-consent view** (§3).
- Existing toggle-pill visual language: `notification_settings_screen.dart`'s
  `_TogglePill` (custom pill, not Material `Switch`, per that screen's own
  `ux/uiux-spec.md` §5 note to match the design source verbatim). This
  story's control has **no** corresponding design-source mock (it is a
  net-new hardening addition), so "match the design source verbatim" does not
  apply — but reusing the same pill component/visual language keeps the app's
  toggle affordance consistent across screens. **Decision: reuse the
  `_TogglePill` shape** (same track/thumb sizing, `colors.gradientHot` when
  on, `colors.colorSurfaceAlt` when off), not a Material `Switch`.
- A11y precedent already established for a toggle on the exact same field:
  `ghost_settings_screen.dart`'s `_ToggleCard` wraps its tappable control in
  `Semantics(button: true, label: <state-aware string>)` inside a
  `ConstrainedBox(minWidth/minHeight: platformTokens.tapTarget)`. Reuse this
  pattern verbatim for the new control.
- Error-state color token: `colors.colorRed` (`cupid_color_tokens.dart`) is
  this design system's error token; no separate "danger"/"warning" token
  exists. `SnackBar` via `ScaffoldMessenger.of(context).showSnackBar(...)` is
  this app's established transient-error pattern (used in
  `gallery_screen.dart`, auth screens, pairing screens); the account feature
  has no existing SnackBar precedent to follow instead, so this introduces
  the pattern to `features/account/` for the first time, consistent with the
  rest of the app.

## 2. Placement decision

Insert one new small section **between the Level 1 and Level 2 tier cards**
in the same `ListView`, not merged into any existing `_TierCard`:

```
l10n.privacy_intro
[SizedBox lg]
_TierCard (Level 1 — unchanged)
[SizedBox md]
--- NEW: _PrivacyControlsSection ---
[SizedBox md]
_TierCard (Level 2 — unchanged)
[SizedBox md]
_TierCard (Level 3 — unchanged)
```

Rationale:
- **Not embedded inside the Level 1 card.** The Level 1 card's `tags` Wrap
  (`typing_ghost` / `private_gallery` / `messages`) is informational content
  describing three different device-only features, only one of which
  (`isGhostModeEnabled`) is backend-writable. A toggle placed inside that
  card would visually imply it controls the whole card (Private Gallery,
  Messages too), which is false, and it would also violate the story's own
  instruction to keep the three cards' content/layout unchanged.
  Out-of-scope explicitly forbids adding a toggle "to" the tier cards as a
  trailing control (`privacy_screen.dart:97-99`'s existing doc comment: "no
  trailing control of any kind" on `_TierCard` — that invariant stays true;
  the new control is a sibling widget, not a `_TierCard` addition).
- **Not a bare top-level "Controls" heading at the very top or bottom of the
  list**, because that would sever it from the one tier concept it actually
  relates to (Level 1 / device-only / Typing Ghost). Placing it immediately
  after Level 1 keeps the reading order coherent: "here is the device-only
  tier and what it covers" → "here is the one control this tier exposes"
  → "here are the other two tiers."
- A distinct card (own surface, own padding) rather than a plain inline
  row keeps visual consistency with the rest of the screen, where every
  block of content is a `Container` card.

## 3. `_PrivacyControlsSection` spec

Single card, same shell as `_TierCard`'s non-highlighted variant
(`color: colors.colorSurface`, `borderRadius: platformTokens.radiusCard`,
`boxShadow: platformTokens.elevationShadow`, `padding: CupidSpacing.md`) so it
reads as a peer of the tier cards, not a decoratively different type of
content.

**Section label** (above the card, not inside it): reuse the same
`type.labelMono` mono-caps style the tier cards use for `levelLabel`
(`letterSpacing: 1.2`), colored `colors.colorTextMuted` (not one of the
per-tier accent colors, since this section is not itself a privacy tier) —
visually related to the tier labels but clearly a different kind of heading.
New l10n key: `privacy_controls_section_label`.
- vi: "TÙY CHỈNH"
- en: "CONTROLS"

**Row content** (single row, one control — no icon container needed at
40x40 like the tier cards since there is only one row, not a heading; a
20px leading icon inline is enough, matching the density of
`notification_settings_screen.dart`'s `_NotifRow`):
- Icon: `Icons.visibility_off` (distinct from the tier cards' icons —
  `smartphone`/`enhanced_encryption`/`cloud` — and distinct from
  `ghost_settings_screen.dart`'s `Icons.blur_on`, so this row is not visually
  mistaken for a shortcut into that screen).
- Title (new l10n key `privacy_controls_ghost_mode_title`):
  - vi: "Ẩn hoạt động gõ theo mặc định"
  - en: "Hide typing activity by default"
  - Deliberately **not** "Typing Ghost" — disambiguates from
    `ghost_settings_screen.dart`'s identically-named control per §1.
- Subtitle (new l10n key `privacy_controls_ghost_mode_subtitle`), states the
  on/off semantics in plain language and points at the fuller screen instead
  of duplicating its mutual-consent UI:
  - vi: "Bật để ẩn theo mặc định trên mọi thiết bị. Quản lý theo từng cuộc trò chuyện tại Trò chuyện → Typing Ghost."
  - en: "On hides it by default across your devices. Manage it per
    conversation from Chat → Typing Ghost."
- Trailing control: `_TogglePill`-shaped toggle (§1), reused visually from
  `notification_settings_screen.dart`'s private widget — since that widget is
  file-private (`_TogglePill` in `notification_settings_screen.dart`), Mobile
  Dev either promotes it to a shared design-system widget or duplicates the
  ~35-line widget; either is an implementation choice, not a UX one, as long
  as the rendered shape/animation/colors match exactly what's specified here.

**On/off semantics (AC2 confirmation):** `true` = ghost mode enabled = toggle
in the **on** (right-aligned, `colors.gradientHot` filled) position. This
matches the field name, the existing read-only usage in
`ghost_cubit.dart:109` (`_serverFlagEnabled = _partnerStore.isGhostModeEnabled
?? false`), and `cupid_profile.dart:28`'s default-`true` fallback when the
field is absent from a payload.

## 4. States

**Screen load (before `AccountCubit` first emits `AccountLoaded`):** the
toggle row renders in a disabled/inert visual state — pill drawn in the
"off" track color (`colors.colorSurfaceAlt`) with no animation, thumb
static, `Semantics(enabled: false)`, tap ignored. Do not show a spinner in
place of the whole card; the three tier cards render immediately regardless
(they carry no network dependency), so only the one row that needs profile
data waits. This matches this screen's existing pattern of never blocking
the whole screen behind a spinner (unlike `notification_settings_screen.dart`,
whose entire body is one `BlocBuilder` — this screen's static content must
stay visible immediately, so the loading state must be local to the new row,
not screen-wide).

**`AccountLoaded`:** row shows the pill in the position matching
`profile.isGhostModeEnabled`, tap-enabled.

**`AccountFailed` (initial load fails):** row shows the same disabled/inert
pill as the loading state (fail-safe: never show a toggle a user can flip if
its true state is unknown), plus a one-line inline note under the subtitle
in `type.caption` colored `colors.colorRed`:
  - New l10n key `privacy_controls_load_error`.
  - vi: "Không tải được cài đặt này ngay bây giờ."
  - en: "Couldn't load this setting right now."
  - No retry button in this row — the screen's existing back-navigation and
    re-entry is the retry path, consistent with the story's narrow scope.

**Tap → in-flight PATCH:** optimistic update. On tap, immediately flip the
pill to the new position (matches this app's existing instant-feedback
toggle convention in `notification_settings_screen.dart`) and disable
further taps on the row (ignore taps, do not queue) until the `PATCH
/users/me` call resolves. Do not introduce a new "pending" visual (no
spinner overlay, no dimming) — the flip itself is the feedback, and the round
trip is expected to be fast; keeping this row visually silent during the
call avoids inventing a third state vocabulary alongside `ghost_cubit.dart`'s
already-distinct `pending` meaning (§1).

**PATCH success:** no additional feedback beyond the already-flipped pill —
consistent with this app's existing silent-success convention for simple
toggles (`notification_settings_screen.dart` shows no success confirmation
either). Call `AccountCubit.applyUpdated(profile)` with the PATCH response so
the rest of the screen/app (e.g. `ghost_cubit.dart`'s own read of this same
flag elsewhere) stays consistent with the new value without an extra GET.

**PATCH failure:** roll the pill back to its pre-tap position and show
`ScaffoldMessenger.of(context).showSnackBar(...)` with:
  - New l10n key `privacy_controls_update_error`.
  - vi: "Không thể cập nhật cài đặt. Vui lòng thử lại."
  - en: "Couldn't update this setting. Please try again."
  - Re-enable the row for another tap immediately after rollback; no retry
    countdown or backoff — a bare hardening fix for one boolean field does
    not need one.

## 5. Accessibility

- Wrap the tappable region in `Semantics(button: true, label: <state-aware
  string>)` exactly as `ghost_settings_screen.dart`'s `_ToggleCard` already
  does for the same field, inside a `ConstrainedBox(minWidth: minHeight:
  platformTokens.tapTarget)` so the tap target meets this app's existing
  minimum regardless of the pill's own visual 50x30 size.
- Semantic label must state current state, not just presence, e.g. (new
  l10n keys `privacy_controls_ghost_mode_semantic_on` /
  `..._semantic_off` / `..._semantic_loading`):
  - on (vi/en): "Ẩn hoạt động gõ theo mặc định, đang bật. Nhấn để tắt." /
    "Hide typing activity by default, on. Double tap to turn off."
  - off (vi/en): "Ẩn hoạt động gõ theo mặc định, đang tắt. Nhấn để bật." /
    "Hide typing activity by default, off. Double tap to turn on."
  - loading/disabled (vi/en): "Ẩn hoạt động gõ theo mặc định, đang tải." /
    "Hide typing activity by default, loading."
- Text contrast: title in `type.body` on `colors.colorText` (already
  AA-checked baseline used by every other row/title on this screen), subtitle
  in `type.caption` on `colors.colorTextMuted` (same as tier card
  descriptions — already the screen's established secondary-text contrast
  pair, so no new contrast pairing is introduced).
- Error text (`colors.colorRed` on `colors.colorSurface`) reuses the same
  token pair the design system already defines as its error color, not a new
  ad hoc red.

## 6. Explicit non-goals (regression guard, AC3/AC4)

- No change to `notification_settings_screen.dart` or any of its 7
  rows/3 groups — out of this handoff's scope entirely.
- No change to the three `_TierCard` instances' props, content, order, or
  styling.
- No "Export all my data" button or any admin/data-export affordance added
  anywhere on this screen (STORY-016 AC4 regression guard, unaffected by this
  spec).

## Completion

Spec covers placement, label/copy (new l10n keys listed inline in §3–5),
on/off semantics, loading/success/error states for the `PATCH /users/me`
round trip, and accessibility. No blockers.
