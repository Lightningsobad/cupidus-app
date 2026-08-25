# UX Spec: STORY-001 Pairing-Method Choice Screen Redesign

Screen id (design source): `isPairStart`
Design reference: `cupid-app-design-system/Cupid Screens.dc.html` lines
1571-1615.
Design-Surface: cupid-app
Theme: dark (only supported theme in the design source).
Locale: `vi` primary / `en` secondary (`data-vi` / `data-en` spans in source).

## 1. Purpose

Replace the current two-option "how do you want to pair" screen with the
three-option layout from the design source: create code, enter code manually,
scan QR. No new destinations — the third option routes to the existing
join-code screen (manual entry today; STORY-003 later adds camera capture on
that same screen).

## 2. Screen Structure (top to bottom)

1. **Header block** (centered, `flex-direction:column;align-items:center`)
   - Icon badge: 92x92px circle-ish container (`border-radius:34px`),
     gradient background `linear-gradient(140deg, rgba(255,127,182,.26),
     rgba(183,140,245,.22))`, centered icon `join_left` at 42px, color
     `var(--pink)`. Pop-in entrance (`animation:popIn .5s ease-out`).
   - Title: `Ghép đôi kiểu nào?` / `How do you want to pair?` — Nunito,
     weight 900, 25px, line-height 1.25, margin-top 18px from icon.
   - Subtitle: `Chỉ một người cần tạo mã — người còn lại nhập vào là xong.` /
     `Only one of you creates a code — the other just enters it.` — 13px,
     line-height 1.6, color `var(--tx2)`, max-width 290px, margin-top 8px.

2. **Option row 1 — Create code** (highlighted/primary option)
   - Tap target: `goInvite` → existing create-code (Couple Types) screen.
   - Container: full-width row, `padding:18px`, `border-radius:var(--r-card)`,
     background `var(--surf)`, border `1.5px solid rgba(255,127,182,.45)`
     (pink-tinted, distinguishes it as the recommended/first option),
     `box-shadow:var(--glow)`. margin-top 26px from header block.
   - Leading icon tile: 50x50px, `border-radius:18px`, background
     `var(--grad-hot)` (gradient fill, not a tint), icon `qr_code_2` at 25px,
     color `#fff`.
   - Title: `Tôi tạo mã mời` / `I'll create the code` — 16px, weight 800.
   - Body: `Nhận mã 8 ký tự + QR, gửi cho người ấy` / `Get an 8-char code + QR
     to send them` — 12.5px, color `var(--tx2)`, margin-top 3px.
   - Trailing: `chevron_right` icon, 20px, color `var(--pink)` (matches the
     row's accent, distinct from the other two rows' neutral chevron).

3. **Option row 2 — Enter code manually**
   - Tap target: `goJoinCode` → existing join-code screen.
   - Container: same row shape as row 1 but neutral: border `1.5px solid
     var(--line)`, no glow shadow. margin-top 12px from row 1.
   - Leading icon tile: 50x50px, `border-radius:18px`, background
     `rgba(183,140,245,.2)` (purple tint), icon `dialpad` at 25px, color
     `var(--purple)`.
   - Title: `Người ấy đã có mã` / `They already have a code` — 16px, weight
     800.
   - Body: `Nhập tay hoặc dán từ tin nhắn` / `Type it in or paste from a
     message` — 12.5px, color `var(--tx2)`.
   - Trailing: `chevron_right` icon, 20px, color `var(--tx2)` (neutral, not
     accented).

4. **Option row 3 — Scan QR** (new option added by this story)
   - Tap target: `goJoinCode` → **same** existing join-code screen as row 2
     (not a new destination; camera capability on that screen is STORY-003's
     scope, out of scope here).
   - Container: same neutral row shape as row 2, border `1.5px solid
     var(--line)`, no glow. margin-top 12px from row 2.
   - Leading icon tile: 50x50px, `border-radius:18px`, background
     `rgba(126,231,201,.16)` (mint tint), icon `qr_code_scanner` at 25px,
     color `var(--mint)`.
   - Title: `Quét QR trên máy họ` / `Scan the QR on their phone` — 16px,
     weight 800.
   - Body: `Nhanh nhất khi hai người ngồi cạnh nhau` / `Fastest when you're
     sitting together` — 12.5px, color `var(--tx2)`.
   - Trailing: `chevron_right` icon, 20px, color `var(--tx2)`.

5. **Privacy note** (preserve exactly, unchanged by this story)
   - Container: `padding:13px 15px`, `border-radius:16px`, background
     `rgba(248,240,247,.05)`, row layout with icon + text, margin-top 22px.
   - Icon: `lock`, soft variant, 17px, color `var(--mint)`.
   - Text: `Một tài khoản Cupid chỉ ghép được với một người. Muốn đổi thì phải
     huỷ ghép trước.` / `One Cupid account pairs with one person only. To
     change, unpair first.` — 11.5px, line-height 1.55, color `var(--tx2)`,
     right padding 46px (keeps text clear of the icon column on wrap).

6. **"Later" escape link — OUT OF SCOPE, do not implement** (product
   decision, `story_master.md` "## Scope Decisions" D-1). The design source
   places this element here, but its `goHome` tap target has no reachable
   destination for an unpaired user, and wiring one would require a new
   pair-gate-bypass capability outside this story. Dropped from this story's
   design scope; not a preserve-exactly element.
   - Reference only (not to be built): Text `Để sau, xem trước app đã` /
     `Later, let me look around first` — 13px, weight 700, color
     `var(--tx2)`, centered, margin-top 16px, margin-bottom 34px.

Outer screen padding: `14px 20px 40px`.

## 3. Iconography Summary

| Element | Icon | Color |
|---|---|---|
| Header badge | `join_left` | `var(--pink)` |
| Row 1 tile | `qr_code_2` | `#fff` (on gradient fill) |
| Row 2 tile | `dialpad` | `var(--purple)` |
| Row 3 tile | `qr_code_scanner` | `var(--mint)` |
| Row 1 chevron | `chevron_right` | `var(--pink)` |
| Row 2/3 chevron | `chevron_right` | `var(--tx2)` |
| Privacy note | `lock` (soft) | `var(--mint)` |

## 4. Navigation / Interaction Mapping (AC2, AC3)

| Row | Handler | Destination | Notes |
|---|---|---|---|
| Create code | `goInvite` | Existing create-code (Couple Types) screen | Unchanged destination and behavior (AC2). |
| Enter code manually | `goJoinCode` | Existing join-code screen | Unchanged destination (AC3). |
| Scan QR | `goJoinCode` | Same existing join-code screen | New entry point wired to an existing destination; no new screen (AC3). Actual camera scan capability is STORY-003. |
| Later link | `goHome` | Existing home/look-around flow | Unchanged. |

Back navigation target is unchanged by this story (preserve existing back
behavior into the pairing entry point).

## 5. States

This is a static choice screen with no server data, loading, or error states
in scope:
- **Default (only state)**: all three rows always visible, always tappable.
  No empty/loading/error variants apply — options are static content, not
  fetched.
- **Pressed/tap feedback**: rows use `cursor:pointer` in source; implementer
  should apply the app's standard pressed-state treatment (opacity or scale
  feedback) consistent with other tappable cards in the app — no bespoke
  feedback defined by the design source for this screen.

## 6. Responsive Behavior

- Design source has no explicit breakpoint variants for this screen; it is a
  single-column mobile layout by construction (rows fill container width).
- Row content uses `flex:1` on the text column so title/body wrap naturally
  on narrower devices without breaking the fixed-width icon tile (50px) or
  chevron.
- Header subtitle constrains to `max-width:290px` and centers, so it wraps
  onto 2-3 lines on narrow screens without special handling.
- No tablet/landscape-specific spec exists in the source; carry the same
  single-column layout to larger viewports (matches sibling screens' pattern
  in this design system).

## 7. Accessibility Notes

- **Tap target size**: each option row is full-width with `padding:18px`
  vertical, comfortably exceeding the 44px minimum touch target height.
- **Grouping/semantics**: the three rows should be exposed as a list of
  selectable actions (e.g., button/list-item semantics), not plain divs, so
  screen readers announce them as tappable options in order.
- **Accessible labels**: each row's accessible name should combine the title
  + body text (e.g., "I'll create the code, Get an 8-char code + QR to send
  them") so the supporting copy isn't lost to assistive tech users who only
  hear the title.
- **Color contrast**: `var(--tx2)` body/secondary text and the privacy note
  text are the smallest text on screen (11.5-13px) — implementer must confirm
  these meet WCAG AA contrast against the dark `var(--surf)`/background,
  consistent with the rest of the design system's existing token usage (no
  new tokens introduced by this story).
- **Icon-only elements**: the `chevron_right` and `lock` icons are decorative
  reinforcement of already-labeled rows/text; they should be marked
  decorative (not separately announced) to avoid duplicate announcements.
- **Focus order**: header → row 1 (create) → row 2 (enter code) → row 3 (scan
  QR) → privacy note (if focusable) → later link, matching visual top-to-
  bottom order.

## 8. Visual QA Checklist (AC1, AC4)

- [ ] Exactly three option rows render (no leftover two-option layout).
- [ ] Row order matches source: create code, enter code manually, scan QR.
- [ ] Row 1 uses the pink-tinted border + glow shadow + gradient icon tile +
      white icon + pink chevron; rows 2-3 use neutral border, tinted icon
      tiles (purple / mint respectively), neutral chevron.
- [ ] Header icon badge, title, and subtitle copy match source exactly in
      both `vi` and `en`.
- [ ] Privacy note and "later" link are visually and textually unchanged from
      current implementation.
- [ ] Dark theme token usage (`var(--surf)`, `var(--tx2)`, `var(--line)`,
      `var(--pink)`, `var(--purple)`, `var(--mint)`, `var(--grad-hot)`,
      `var(--glow)`, `var(--r-card)`) matches the design source — no ad hoc
      colors/spacing introduced.
- [ ] Spacing rhythm matches source: 26px header→row1, 12px between rows,
      22px rows→privacy note, 16px privacy note→later link.

## 9. Out of Scope Reminders (do not implement here)

- No changes to the create-code screen content (STORY-002).
- No changes to the join-code screen's own content or actual QR camera
  capture (STORY-003).
- No changes to back-navigation target or post-pairing navigation (locked by
  REQ-009 / OQ2).
