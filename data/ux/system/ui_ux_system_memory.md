# System UX Memory — Cupid Mobile (REQ-001)

Synthesized from the read-only design source `cupid-mobile-design/` (`Cupid
Screens.dc.html`, `Cupid App.dc.html`, plus generic tooling scaffolds
`android-frame.jsx`/`ios-frame.jsx`/`support.js`/`image-slot.js`, which contain
no bespoke Cupid content and are excluded from this memory). This codifies
what is already decided in the design source and confirmed bootstrap
decisions (D0-D5, req_master.md). It does not invent new product direction.

Scope: MVP is 29 screens (design source's own count), 16 features, iOS +
Android, per `Cupid App.dc.html`'s own header tagline.

## 1. Design Principles (from design source, verbatim intent)

- **Couple-first**: every screen carries some signal of the partner's
  presence/state (not just the current user).
- **One-thumb**: primary action sits in the bottom ~30% of the screen.
- **Dual-confirmation**: consequential actions require both partners to act
  (e.g. Fingerprint Vow: hold 1.5s to sign, then both partners touch
  fingerprint; Synced Alarm: both must swipe to dismiss).
- **Cute & dreamy**: nebula background with twinkling stars, soft rounded
  corners, pink-purple glow, small stickers — "even sulking should be cute."
- Accent colors are used as 12-20% opacity fills, not solid blocks
  ("dreamy pastel," lower chroma / higher lightness than a typical neon
  palette).

## 2. Design Tokens (platform x theme — 4 combinations)

Confirmed already implemented in the design source's CSS as
`[data-plat="ios"|"md"]` x `body[data-theme="dark"|"light"]`. This is the
literal shape of D3 (`ThemeExtension` keyed by platform x theme) — Tech
Lead's 4 named adaptive widgets and token classes should map 1:1 onto this
existing structure, targeting `mobile/lib/design_system/` per ADR-009.

### Brand colors (dark theme default values; light theme overrides some)

| Token | Dark | Light | Role |
|---|---|---|---|
| `--pink` / `--pink-d` | #FF7FB6 / #F0609E | #E8558F / #D2417B | Primary — "Cupid Pink" |
| `--purple` / `--purple-d` | #B78CF5 / #8E5FD6 | #9A63E8 / (same) | Secondary — "Dreamy Lilac" family |
| `--lilac` | #D9C2FF | #B78CF5 | Air-element zodiac, accents |
| `--mint` / `--green` | #79E2CD | #22B398 | Trust/positive — "Mint Trust" |
| `--butter` / `--amber` | #FFD79E / #FFC97E | #DE9A31 | Warning |
| `--peach` | #FFAB93 | #EF7F5F | Fire-element zodiac, secondary accent |
| `--red` | #FF6F91 | #EA5578 | Error/destructive |
| `--ghost` | #B4A6CE | #A793B4 | Typing Ghost / muted state |

Neutrals: dark bg `#171129` ("Night Plum"), dark surface `#241B42`/`#2E2456`,
light bg `#FFF6FB` ("Cotton"), light surface `#FFFFFF`/`#FFEEF7`.

Gradients (platform-independent, theme-dependent tint):
- `--grad` "Dream Gradient" — `linear-gradient(120deg, #FF9CC4, #C79BF0 52%, #8FE6D3)` — used for hero, days-counter, CTA.
- `--grad-hot` — `linear-gradient(120deg, #FF7FB6, #B78CF5)`.
- `--sky` "Nebula Sky" — layered radial gradients + twinkling stars (`@keyframes twinkle`), used as the background on every screen, theme-tinted (dark = saturated purple/pink glow on near-black; light = soft pastel wash on cotton white).

### Structural / platform tokens

| Token | iOS | Material |
|---|---|---|
| `--safe-top` / `--safe-bot` | 54px / 24px | 6px / 6px |
| `--r-card` | 26px | 24px |
| `--r-btn` | 999px (pill) | 999px (pill) |
| `--r-sheet` | 28px | 28px |
| `--r-sm` | 16px | 16px |
| `--fs-ui` (body font) | -apple-system / SF Pro Text | Roboto |
| `--tap` (min tap target) | 44px | 48px |
| `--shadow` | soft blur, `rgba(80,30,110,.18)` | tonal elevation, `rgba(80,30,110,.16)` |

### Type scale

- Display: Nunito 900, 34pt — days counter, contract title.
- Card title: 22pt / weight 600.
- Body: 17pt — SF Pro Text (iOS) / Roboto (Android).
- Caption: 13pt — timestamps, metadata.
- Mono (Roboto Mono): small mono labels — contract clause ids, chart axis labels, screen-picker chips.

### Spacing

Base 8pt grid: xs 4 / sm 8 / md 16 / lg 24 / xl 32 / xxl 48.

### Iconography

- **Material Symbols Rounded**, filled, weight 300-400, is the icon system
  for *all* functional/navigation icons on **both** platforms (SF Symbols
  substitution is only for a real native-iOS build, not required by D0's
  Flutter decision). Three style variants exist via `[data-icon]`: default
  (filled), `"line"` (outlined), `"soft"` (thin, desaturated).
- Emoji are reserved strictly for *sticker/mood* use (mood indicators, Love
  Pet, Emoji Storm) — **never** used as navigation or functional icons.
- Zodiac icons are a fully custom-drawn 12-sign set (not Unicode glyphs),
  rendered via `dc-import name="Zodiac Icon" sign="..."`, color-coded by
  element: Fire = peach/orange, Earth = mint, Air = lilac, Water = pink.

### Animation vocabulary (CSS keyframes present in source)

`fall` (confetti), `pulseRing`, `ghostFade` (typing-ghost fade-out), `bob`,
`shake`, `boom`, `sweep`, `float`, `twinkle` (background stars), `wiggle`,
plus (seen in the screens file) `drift`, `riseHeart`, `shimmer`, `popIn`,
`breathe`. Signals a consistently playful, highly-animated interaction
language — implementation should budget for equivalent Flutter
animation/motion primitives (implicit animations / custom painters for
things like the confetti fall and jar-fill), not treat these as decorative
extras to cut.

## 3. Platform Adaptation Pattern (input for Tech Lead's 4 named adaptive widgets)

Explicit table from the design source's own style-guide page — this is the
authoritative shape for D3's adaptive widget set, not something to
re-derive:

| Element | iOS 17 / HIG | Android / M3 |
|---|---|---|
| Tab bar | Translucent, icon 26 + label 10 | Pill active indicator |
| Header | Large title, back = chevron + label | Top app bar, back = arrow |
| Primary CTA | Full-width pill, infinite radius | Filled button, 20dp radius + ripple |
| "Add new" action | `+` button in nav bar | FAB, bottom-right |
| Depth | Blur + soft shadow | Tonal surface elevation |
| Tap target | 44pt | 48dp |

Concrete precedent already in the live prototype (Shared Expenses screen):
`sc-if value="{{ isMD }}"` renders a Material FAB, `sc-if value="{{ isIOS }}"`
renders a full-width primary CTA button, for the *same* "add expense" action.
This is a real, working example of the "one widget tree, platform-adapted
rendering" pattern D3 asks for — treat it as the reference case when Tech
Lead names the 4 adaptive widgets (plausible candidates based on the table
above: adaptive header/app-bar, adaptive primary-action button/FAB, adaptive
tab bar, adaptive bottom-sheet/dialog chrome).

## 4. Screen & Navigation Inventory

29 screens grouped into 6 epic-aligned categories (source's own `INDEX`
grouping in `Cupid Screens.dc.html`; each category has VI/EN labels and a
brand accent color). Bottom nav is a 5-tab bar: **home, chat, pet, money,
me**.

- **Epic 1 — Core connection / onboarding**: splash, welcome, login,
  register, otp, forgot, permissions, profile, invite (tạo mã), joincode
  (nhập mã), waiting (đợi ghép), paired (ghép xong), contract (Love
  Contract), vow (Fingerprint Vow).
- **Epic 2 — Communication**: home dashboard, chat + Typing Ghost,
  Typing Ghost consent/settings screen.
- **Epic 3 — Daily engagement ("nhắc nhở đồng bộ" — see wording rule below)**:
  Vibe Check, Synced Alarm/Reminder screen, Anti-Ghosting (threshold picker +
  Emoji Storm settings), Zodiac Red Flag.
- **Epic 4 — Intimacy / memories**: Love Pet ("Bún"), Love Timeline, Private
  Gallery.
- **Epic 5 — Finance**: Dream Jar, Shared Expenses.
- **Epic 6 — Admin / privacy (mobile-visible portion)**: Me (profile),
  Privacy / "My data" (3-tier sensitivity model), Notifications.

Chrome rules baked into the source:
- `NO_CHROME` (no header): the entire onboarding/auth/pairing flow
  (splash → welcome → login → register → otp → forgot → permissions →
  profile → invite → joincode → waiting → paired → contract → vow) is
  chromeless.
- `NO_TABS`: same onboarding/pairing flow screens also hide the bottom tab
  bar.
- Main app (post-pairing) uses the 5-tab bottom nav listed above.

## 5. i18n Scope (OQ5 — open, PO to confirm; not resolved here)

- Default locale `vi`; secondary `en`. Design source implements both via
  parallel `data-vi`/`data-en` spans toggled by `body[data-lang]`.
- Both dark+light and vi+en are fully designed and token-complete in the
  source. Per `conflicts_open_questions.md` OQ5: working assumption is to
  build full 4-combination infrastructure now, but only *enable* dark + `vi`
  at v1 launch. **UX-relevant addition found in `Cupid App.dc.html`'s own
  assumptions**: feature *names* (Typing Ghost, Synced Alarm, Emoji Storm,
  Fingerprint Vow, Dream Jar, Love Pet, etc.) are intended to stay in English
  in the Vietnamese locale, treated as brand/proper-noun terms rather than
  translated strings. Product Owner should confirm this as an explicit i18n
  rule (not just translate-everything) when writing the `design_system`
  story's ARB/localization acceptance criteria.
- Privacy indicator convention: any Level-1 (device-only) data surface
  (chat, Typing Ghost, Private Gallery) must visibly show a lock affordance
  in the UI at all times — this is stated as a standing assumption in the
  design source, not a per-screen one-off.

## 6. Mandatory Epic-3 Wording Rule — Compliance Flag

Business/requirement docs mandate: epic-3 UX content must use **"nhắc nhở
đồng bộ"** (synced reminder), never **"báo thức"** (alarm), consistent with
D1 (v1 ships sync reminders only, not real system alarms/Critical Alerts).

**Finding**: the raw design source still literally uses "báo thức" /
"Synced Alarm" / "alarm" wording throughout the epic-3 screen (screen id
`alarm`, icon labeled `alarm`, copy such as "Xác nhận giờ ở cả hai máy →
'Reo thử' → chỉ tắt khi cả hai vuốt" / "confirm time on both devices → 'test
ring' → only turns off when both swipe"). This is a **copy-only** rename
target for Product Owner at story-breakdown time — the underlying
interaction pattern (both partners confirm a time; a synchronized in-app
prompt fires on both devices; both partners must acknowledge/dismiss it
together) is UX-legitimate and does not need to be redesigned, only
relabeled and reframed as an in-app synced reminder rather than a real
device alarm (no full-screen system alarm UI, no bypass-silent-mode
behavior, no "keeps ringing indefinitely" implication). Tech Lead's system
architecture memory independently flags the matching backend-side naming
trap (ADR-002 note: backend module/gateway is literally named `alarms`,
`TRIGGER_ALARM` event — that transport name may stay, only UI copy must not
leak "alarm"/"báo thức" wording). PO should treat these as the same rename
scope, UI-only.

## 7. New Finding — Do Not Disturb / Critical Alerts Conflict (flag for PO/Tech Lead)

The Notifications screen's raw copy states: **"Chỉ Synced Alarm được phép
phá Do Not Disturb"** ("Only Synced Alarm may break Do Not Disturb"). This
implies the epic-3 reminder is expected to bypass system Do Not Disturb —
which requires a Critical Alerts-class entitlement/native alarm capability.
This directly conflicts with D1 ("no Critical Alerts entitlement request; no
native alarm module" for v1) and was **not previously captured** in
`conflicts_open_questions.md`. Recommend Product Owner either (a) scope this
copy out of v1 (standard notification priority only, no DND bypass) or (b)
explicitly escalate a v1.x Critical Alerts entitlement decision — do not
silently implement DND-bypass behavior, since the client cannot obtain that
capability without a scoped, user-visible decision (mirrors how R8's
Socket.IO auth gap was escalated rather than silently implemented).

## 8. Data Sensitivity Model (input for Tech Lead OQ4 / persistence decisions)

The "Privacy / My data" screen designs an explicit 3-tier model, already
reflected in ADR-007's Drift resolution:

- **Level 1 — device-only** (AES-256, Secure Enclave/equivalent): Typing
  Ghost content, Private Gallery, Messages. Never leaves device; UI must
  show a lock affordance per §5.
- **Level 2 — server + end-to-end encrypted**: Dream Jar, Love Timeline,
  Vibe Check.
- **Level 3 — standard server / TLS 1.3**: Profile, Love Pet stats, "Alarm
  settings" (rename per §6).

Includes a data-export flow with PDPA Vietnam compliance copy — relevant to
epic-6 mobile-visible scope, not the out-of-scope admin/data-export backend
modules.

## 9. Representative Interaction Patterns (per epic, as designed — reference only)

- **Typing Ghost** (epic-2): mutual-consent toggle (pending state until both
  accept); when active, deleted-but-typed text appears struck-through /
  fading on the partner's screen (`ghostFade` keyframe) rather than
  disappearing silently; explicitly no persistence (ephemeral, Level-1 data).
- **Vibe Check** (epic-3): mood-state input per partner.
- **Synced Alarm/Reminder** (epic-3, rename per §6): both partners confirm a
  shared time; synchronized in-app prompt; both must dismiss (swipe) to
  clear — a dual-confirmation ritual, not a real alarm.
- **Anti-Ghosting** (epic-3): configurable inactivity threshold; triggers
  "Emoji Storm" (chat screen fills with emoji) as a lighthearted
  penalty/nudge; both threshold and penalty type (storm vs. count) are
  user-configurable.
- **Zodiac Red Flag** (epic-3): compatibility read using the custom 12-sign
  element-coded icon set (§2 iconography).
- **Love Pet "Bún"** (epic-4): XP/level progression driven by engagement
  (feeding/playing plus incidental XP from chat sends and mood-setting);
  mood state derived from engagement recency, not a separate input; current
  art is vector placeholder (Lottie 4-state art explicitly deferred per the
  design source's own "Chưa làm"/not-done list — do not treat as a v1 gap to
  fix).
- **Love Timeline** (epic-4): countdown + progress ring toward a milestone,
  timeline entries with photo slots (`<image-slot>` generic upload/crop
  widget).
- **Private Gallery** (epic-4): Level-1 device-only photo storage.
- **Dream Jar** (epic-5): animated SVG fill toward a shared savings target;
  quick-add preset amounts; competitive/comparative contribution display
  between partners.
- **Shared Expenses** (epic-5): platform-adaptive add-expense action — see
  §3 FAB-vs-full-width-button precedent.
- **Me / Privacy / Notifications** (epic-6): profile, 3-tier privacy
  controls (§8), notification preferences (see §7 flag on DND copy).

## 10. Explicitly Out of Scope / Not Yet Designed (confirmed by the design source itself)

Matches `business_context.md`'s out-of-scope list, with source-side
corroboration from `Cupid App.dc.html`'s own "Chưa làm" (not done) section:
Digital Divorce flow + Admin panel (Phase 1.5), Lottie art for Love Pet
(currently vector-only), and real couple photos (placeholders only, with
annotation). Treat these as confirmed-out-of-scope, not gaps to fill during
v1 UX work.

## 11. Sources

- `cupid-mobile-design/Cupid Screens.dc.html` — primary interactive
  prototype: full design-token CSS, screen `INDEX`, chrome/nav rules, and
  per-screen interaction detail (sampled representatively across all 6
  epics, not read exhaustively).
- `cupid-mobile-design/Cupid App.dc.html` — design-system/style-guide page
  and prototype shell: principles, token swatches, type/spacing scale,
  iconography rules, zodiac set, platform-adaptation table, screen picker
  nav, and the "try it" dual-device interaction demos (Typing Ghost, Synced
  Alarm, Emoji Storm, Fingerprint Vow).
- `data/intake/bootstrap/business_context.md`, `technical_context.md`,
  `conflicts_open_questions.md`, `source_register.md`,
  `data/requirements/REQ-001_cupid_flutter_mobile_app/req_master.md` — D0-D5
  decisions, in/out-of-scope, wording rule, OQ4/OQ5.
- `data/architecture/system/system_architecture_memory.md` (ADR-001..009) —
  cross-checked for the matching backend "alarms" naming trap (§6) and the
  confirmed mobile scaffold target (`mobile/lib/design_system/`) that should
  host these tokens.
- Excluded as non-content: `android-frame.jsx`, `ios-frame.jsx`,
  `support.js`, `image-slot.js` (generic dc-runtime/device-frame tooling,
  marked `@ds-adherence-ignore` or confirmed generic infrastructure — no
  Cupid-specific design content).
