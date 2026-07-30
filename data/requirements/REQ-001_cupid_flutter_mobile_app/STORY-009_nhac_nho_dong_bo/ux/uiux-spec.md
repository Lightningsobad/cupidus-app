
# UX Spec — STORY-009: Nhắc Nhở Đồng Bộ (Synced Reminder)

Requirement: REQ-001_cupid_flutter_mobile_app · Epic-3 (daily engagement)
Design source: `cupid-mobile-design/Cupid Screens.dc.html` (raw screen id
`alarm`), cross-referenced with `data/ux/system/ui_ux_system_memory.md` §6/§7/§9
(prior findings on this exact wording/DND conflict — reused, not re-derived
here).

## 1. Scope Of This Spec

Two screens carry this feature's UI, plus one adjacent screen's copy that
must change as a side effect of D1:

1. **Synced Reminder — Schedule screen** (raw `isAlarm` state block).
2. **Synced Reminder — Firing overlay** (raw `alarmRinging` full-screen
   state, rendered on top of whatever screen is active when the reminder
   fires).
3. **Notifications settings screen** (raw `isNotifs` state) — only the
   banner copy and the "Synced Alarm" row need to change; the rest of that
   screen is out of this story's scope.

Backend/transport naming (`alarms` module, `TRIGGER_ALARM` event) is frozen
per A1/ADR-002 — nothing below asks for a transport rename.

## 2. Screen: Synced Reminder — Schedule

Layout (top to bottom, matches raw source structure 1:1 — only copy/icon
changes below):

- **Hero card** (gradient card, `--r-card` radius, floating radial glow):
  - Eyebrow label: raw "Báo thức chung mỗi sáng" / "Shared morning alarm" →
    **"Nhắc nhở đồng bộ mỗi sáng" / "Shared morning reminder"**.
  - Large time display (`{{ alarmStr }}`, Nunito 900 56px, gradient text
    fill) with +/- steppers either side. Unchanged — this is a time value,
    not "alarm" wording.
  - 7-day chip row (weekday toggle). Unchanged.
- **Confirmation row**: two cards side by side, one per partner, each with
  avatar-initial circle + name + confirmation-state text (`{{ confA }}` /
  `{{ confB }}`, color-coded via `confAColor`/`confBColor`). Unchanged
  structurally; if raw copy for the state strings contains "báo thức"/
  "alarm" wording it must be swapped for "nhắc nhở đồng bộ" phrasing (Tech
  Lead/Backend to confirm exact raw strings, none were sampled with that
  wording in the source excerpt reviewed).
- **Primary action, one of three mutually exclusive states** (`sc-if`
  ladder, unchanged trigger logic):
  - `needMyConfirm`: pill CTA "Xác nhận giờ này" / "Confirm this time" —
    unchanged, no alarm wording present.
  - `waitingPartnerAlarm`: waiting pill with hourglass icon and
    `{{ waitingAlarmCopy }}` — verify this bound string at implementation
    time; if it contains "báo thức" swap to "nhắc nhở đồng bộ" framing (e.g.
    "Đang đợi {{partner}} xác nhận nhắc nhở đồng bộ…").
  - `bothConfirmed`: secondary (outline, `--mint`) CTA — raw copy "Reo thử
    ngay (demo)" / "Ring now (demo)" → **"Thử nhắc ngay (demo)" / "Try it
    now (demo)"**. Rationale: "reo"/"ring" reads as alarm-bell language;
    "thử nhắc" ties directly to "nhắc nhở" and avoids reinforcing an
    alarm-clock mental model.
- **Rule card** (info card, swipe-up icon): raw copy "Luật chơi: báo thức
  chỉ tắt khi cả hai cùng vuốt. Một người dậy trước thì máy người kia vẫn
  reo — hoặc tự tắt sau 5 phút." / "The rule: the alarm stops only when
  both swipe. If one wakes first the other keeps ringing — or times out
  after 5 minutes." →
  **VI: "Luật chơi: nhắc nhở chỉ tắt khi cả hai cùng vuốt. Một người dậy
  trước thì máy người kia vẫn nhắc — hoặc tự tắt sau 5 phút."**
  **EN: "The rule: the reminder stops only when both swipe. If one wakes
  first the other keeps prompting — or times out after 5 minutes."**
  This card is the canonical, user-facing statement of the 5-minute timeout
  behavior backing AC4 — implementation must preserve the timeout, not just
  the copy.

Icon: raw source uses no dedicated screen-level icon here beyond the
steppers; no change needed on this screen.

## 3. Screen: Synced Reminder — Firing Overlay

Full-screen takeover (`z-index:85`, dark scrim + radial glow background),
rendered in-app only when the app is foregrounded and the scheduled time
fires (delivered via the frozen `alarms`/`TRIGGER_ALARM` transport per A1).
This is **not** a native/system alarm surface — it is a client-rendered
in-app view, consistent with AC4 (no native/system alarm integration).

Required changes from raw source:

- **Icon**: raw source uses the Material Symbol literally named `alarm`
  inside a shaking (`shake` keyframe) rounded-square badge. Replace with
  `notifications_active` (already used elsewhere in this design system for
  the "ring now" affordance and the Notifications screen's own icon set) to
  avoid an alarm-clock glyph reinforcing exactly the mental model D1 rules
  out. Keep the `shake` animation — it's a legitimate attention cue and not
  itself alarm-specific.
- **Body copy** (`{{ ringCopy }}`): raw "Chỉ tắt khi cả hai cùng vuốt nha." /
  "It stops only when both of you swipe." — no "báo thức"/"alarm" word
  present, copy is fine as-is. Confirm at implementation time that no
  sibling string elsewhere states a "keeps ringing indefinitely" claim
  without the 5-minute timeout caveat (the schedule screen's rule card is
  the source of truth for that caveat and must stay consistent with this
  overlay).
- **Per-partner state labels** (`{{ stopAText }}` / `{{ stopBText }}`, raw
  "đã dậy ✓"/"awake ✓" and "còn ngủ"/"still asleep"): unchanged — these are
  about wake state, not alarm wording, and fit the "reminder to be
  in-sync" framing fine.
- **Dismiss CTA**: raw "Vuốt để dậy" / "Swipe to wake" — unchanged, no
  alarm wording.
- **Waiting-on-partner state** (`{{ waitingCopy }}`): raw "Đang đợi {name}
  dậy…" / "Waiting for {name} to wake up…" — unchanged.

## 4. Screen: Notifications Settings (copy-only change, scoped to this story)

Only two elements on this screen change; everything else on `isNotifs` is
out of this story's scope and must not be touched.

- **Top banner card** (amber/pink gradient, bolt icon). Raw copy:
  - VI: "Tối đa **15 thông báo/ngày**. Chỉ Synced Alarm được phép phá Do Not
    Disturb."
  - EN: "Max **15 pushes/day**. Only Synced Alarm may break Do Not
    Disturb."
  - **Required rewrite (removes the DND-override claim entirely — resolves
    the D1/Critical-Alerts conflict, see §6):**
    - VI: "Tối đa **15 thông báo/ngày**."
    - EN: "Max **15 pushes/day**."
  - Do not replace the removed clause with any alternate DND-related claim
    (e.g. "high priority" wording that still implies bypass). If Product
    Owner later wants a v1.x Critical Alerts entitlement, that is a new,
    explicitly-scoped decision per system memory §7 — not something to
    imply here.
- **"Critical" section row** (`notifCritical` list, first item): raw
  `{ icon: 'alarm', title: 'Synced Alarm', sub: 'Reo trên cả hai máy' / 'Rings
  on both phones' }` →
  - `icon`: `alarm` → `notifications_active` (consistent with §3's overlay
    icon change — one icon identity for this feature across every screen).
  - `title`: "Synced Alarm" → **"Nhắc nhở đồng bộ"** (VI) / **"Synced
    Reminder"** (EN). Note this is a deliberate deviation from system
    memory §5's general "feature brand names stay in English" convention —
    D1's mandatory rewording rule for this specific epic-3 feature
    (story_master.md "In Scope": *"applies to every AC/screen in this
    story"*) takes precedence over the general branding convention for this
    one feature name. Product Owner should treat "Synced Reminder"/"Nhắc
    nhở đồng bộ" as this feature's confirmed display name going forward,
    superseding "Synced Alarm" everywhere, not just on this screen.
  - `sub`: "Reo trên cả hai máy" / "Rings on both phones" →
    **"Nhắc trên cả hai máy" / "Prompts on both phones"** (avoids "reo"/
    "rings" alarm-bell language, consistent with §2's CTA rename rationale).
  - The toggle control itself (pill switch, on/off) is unchanged.

## 5. Flow (text)

1. Either partner opens the Schedule screen and sets/adjusts the shared
   time (steppers + weekday chips).
2. Each partner independently confirms that time (`needMyConfirm` →
   confirmed state per partner).
3. Once both partners have confirmed (`bothConfirmed`), the schedule is
   active; either partner can preview it via "Try it now (demo)".
4. At the scheduled time, the backend `alarms` module fires
   `TRIGGER_ALARM` over the dual FCM/socket path (per STORY-004's
   RealtimeCoordinator, already DONE) to both devices.
5. Each device that is foregrounded renders the Firing Overlay; each device
   that is backgrounded receives a system push notification instead (push
   notification copy is out of this spec's sampled scope — Backend/Mobile
   Dev should reuse the same renamed strings from §3/§4 for that push,
   not the raw "alarm" wording, per AC2).
6. Each partner dismisses independently (swipe); the overlay clears for
   that partner but the other partner's device continues prompting (shake +
   CTA) until they also dismiss, or 5 minutes elapse and it auto-clears for
   both (per §2's rule card and AC4 — no indefinite/native-alarm-style
   ringing).

## 6. Responsive Behavior

- Schedule screen: single-column, no breakpoint-specific layout change
  needed — content (hero card, two-up confirmation row, CTA, rule card)
  already fits the one-thumb bottom-30%-CTA pattern at all supported device
  widths (design system §1). On tablet/larger widths, cap card content at
  the existing mobile max-width and center it rather than stretching the
  hero card's 56px time display full-width.
- Firing overlay: full-screen (`inset:0`) by definition; ensure the
  `padding: var(--safe-top) ... var(--safe-bot)` safe-area insets (already
  in raw source) are honored on notch/dynamic-island and gesture-nav
  devices so the CTA never sits under a system inset.
- Notifications screen: existing list-row layout, no responsive changes
  needed beyond what the screen already does elsewhere.

## 7. Accessibility Requirements

- **Icon-only meaning must not be color-only**: the per-partner
  confirmation state (`confAColor`/`stopAColor` etc.) is currently
  color-coded (mint = confirmed/awake vs. a muted/white state). Pair the
  color with the existing text label (`{{ confA }}`, `{{ stopAText }}`) as
  already designed — do not let color alone carry the state; this is
  already satisfied by the source's text+color pairing, preserve it in
  implementation.
- **Full-screen overlay focus/announcement**: when the Firing Overlay
  appears, it must be announced to screen readers (e.g. Flutter
  `SemanticsService.announce` / route-based focus move) as an alert-level
  interruption, since it can appear over any other screen the user is on.
  Focus must move to the primary "Swipe to wake" dismiss action.
- **Dismiss action must have a non-gesture equivalent**: "swipe to wake" is
  a gesture-only affordance in the raw source. For screen-reader and
  motor-accessibility users, provide an equivalent activatable button
  (double-tap-to-activate under VoiceOver/TalkBack) that triggers the same
  dismiss action as the swipe — do not make dismissal swipe-only.
  Reference this story's own icon-swap: the CTA icon (`swipe_right`) should
  carry an accessible label describing the action ("Dismiss reminder"/"Tắt
  nhắc nhở"), not just the icon glyph.
  This directly supports AC1 (both partners must be able to receive/act on
  the reminder) for users who cannot perform the swipe gesture.
  This is a new addition, not previously covered by system memory §11's
  auth-focused a11y notes.
- **Timeout must be perceivable, not silent**: when the overlay
  auto-clears after 5 minutes for a partner who never dismissed, that
  partner's next app open should surface a brief, non-blocking
  acknowledgment (e.g. a toast: "Nhắc nhở đã tự tắt" / "Reminder timed
  out") rather than silently vanishing — so the state change is
  discoverable, not just implied by the rule-card copy read earlier.
- **Notification banner rewrite (§4)**: after removing the DND-override
  claim, no accessibility label anywhere (icon `alt`/semantic label on the
  `notifications_active` icon, the toggle switch's accessible name) may
  still imply a DND-bypass capability that no longer exists in copy.

## 8. Design System Reuse

No new tokens/components needed — this story is copy/icon-identity changes
layered onto an already-designed interaction pattern (system memory §9
confirms the underlying dual-confirmation ritual is UX-legitimate and not
being redesigned):

- `--r-card`, `--r-btn`, `--grad-hot`, `--shadow` — reuse as-is from
  existing card/CTA/pill tokens (§2 of system memory).
- `notifications_active` icon — already used elsewhere in this same design
  source (Notifications screen's own engagement rows, permissions screen);
  reusing it here for the alarm-icon replacement keeps one consistent icon
  identity for this feature instead of introducing a new glyph.
- `shake` keyframe — reuse as-is (already in the documented animation
  vocabulary, system memory §2).
- Dual-confirmation avatar-pair pattern — reuse as-is; same visual
  structure already used for Fingerprint Vow per system memory §1.

## 9. Open Items For Downstream Roles — Resolution

1. **"UI/UX Designer: rewrite the raw Notifications screen copy to remove
   the DND-override claim per the resolved D1/Critical-Alerts conflict."**
   — **Resolved in §4 above.** The banner's DND-override clause is deleted
   outright (not reworded into a softer DND claim); the "Synced Alarm"
   critical-notification row is renamed to "Synced Reminder"/"Nhắc nhở đồng
   bộ" with a matching icon and non-"ring" sub-copy, consistent with AC2/AC3.

## 10. Adjacent Note (not this story's scope — flag only)

The onboarding **Permissions** screen (`isPermissions`, raw `permList`)
contains: *"Synced Alarm and Emoji Storm need this. Max 15 a day." /
"Synced Alarm và Emoji Storm cần cái này. Tối đa 15 cái/ngày."* This is
outside STORY-009's screen scope (onboarding/pairing flow belongs to an
earlier story) and this spec does not modify it. Flagging for Scrum
Master/Product Owner: once "Synced Alarm" → "Synced Reminder"/"Nhắc nhở
đồng bộ" is confirmed as this feature's display name (§4), that permissions
screen's copy will need the same rename in a follow-up scope (its own story
or a small cross-cutting copy pass) to stay consistent — do not let two
different names for the same feature coexist post-STORY-009.
