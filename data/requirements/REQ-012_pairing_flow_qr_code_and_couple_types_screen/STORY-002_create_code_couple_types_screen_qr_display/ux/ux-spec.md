# UX Spec: STORY-002 Create-Code (Couple Types) Screen QR Display

Screen identity: existing Couple Types / create-code screen (REQ-009), updated
in place. No new screen or route is created. Design source of truth: `cupid-app-design-system/Cupid Screens.dc.html`, `isInvite` block, lines
170-224.

## Screen Structure (top to bottom, unchanged order)

1. Code/QR card (updated — QR added)
2. Waiting-for-partner status pill (unchanged)
3. Text pairing code (unchanged)
4. Expiry/help caption (unchanged)
5. Share invite + copy actions (unchanged)
6. Simulate-join affordance (unchanged, dev/test-only — flag for Tech Lead to confirm it is excluded from production builds; not a UX decision)
7. "Tụi mình thuộc kiểu nào?" section header + subcopy (unchanged)
8. Couple-type 4-card grid picker (unchanged, position locked per REQ-009)
9. Continue CTA (unchanged position/styling — copy updated, see AC4 section)

## 1. Code/QR Card

Container: `background: var(--surf)`, `border-radius: var(--r-card)`, padding
`24px 20px 22px`, center-aligned text, `box-shadow: var(--shadow)`,
`overflow: hidden`, `position: relative`.

Ambient glow: an absolute, centered radial-gradient blob behind the QR
(`rgba(255,107,168,.34)` → `rgba(183,140,245,.14)` at 55% → transparent at
72%), 290×290px, `filter: blur(6px)`, `animation: breathe 4.5s ease-in-out
infinite`. Purely decorative, sits behind the QR frame.

### QR frame (new — this is the added element)
- White card: `186×186px`, centered, `padding: 16px`, `border-radius: 28px`,
  `background: #FFFDFE`, `box-shadow: 0 12px 34px rgba(255,107,168,.26)`.
- Inner live QR art fills the padded area (154×154px), encoding the **exact
  same pairing code value** already rendered as text below it (e.g.
  `CPD-8F2K`) — one code, two representations, never two different values
  (AC2).
- QR error-correction level must be **High (H)** so the center overlay badge
  does not break scannability — the badge sits in the QR's visual center and
  will occlude modules underneath it.
- Center overlay badge: `40×40px`, `border-radius: 14px`,
  `background: var(--grad-hot)`, centered heart icon (`favorite`, 21px,
  white), with a 5px `#FFFDFE` ring cutout around it
  (`box-shadow: 0 0 0 5px #FFFDFE, 0 4px 12px rgba(255,107,168,.4)`) so the
  badge reads as sitting on top of, not blended into, the QR.
- Scan-line accent: a thin gradient band (26px tall) spanning the frame width,
  `background: linear-gradient(180deg, rgba(255,107,168,0), rgba(255,107,168,.16))`,
  `border-bottom: 1.5px solid rgba(255,107,168,.75)`,
  `animation: qrScan 3.4s cubic-bezier(.45,0,.55,1) infinite` — sweeps down
  and loops to signal the QR is live/active, not a static image. Decorative
  only; must not obscure QR modules enough to break scanning at any point in
  the animation (keep opacity low, as specified).
- Accessible label (screen reader): "Mã QR chứa mã ghép đôi {code}" /
  "QR code containing pairing code {code}" — the visible text code below
  remains the primary fallback for anyone who can't scan.

### Waiting-for-partner pill (unchanged)
Inline pill, `background: var(--surf2)`, `border-radius: 999px`, padding
`9px 15px 9px 13px`. Three 5px dots with staggered `dotWave` animation
(0s / .2s / .4s delay). Label: "Đang đợi {partner} quét…" /
"Waiting for {partner} to scan…" — 12.5px, 700 weight.

### Text code (unchanged)
`Roboto Mono`, 500 weight, 30px, `letter-spacing: .16em`, gradient text fill
(`var(--pink)` → `var(--purple)`), e.g. `CPD-8F2K`. This is the same code
value the QR encodes.

### Expiry caption (unchanged)
11.5px, `color: var(--tx2)`: "Đọc mã này cho Bae, hoặc để họ quét QR · hết
hạn sau" / "Read it to Bae, or let them scan the QR · expires in", with the
countdown (`Roboto Mono`, `var(--pink)`) inline.

### Actions row (unchanged)
- Primary "Share invite" pill: `flex:1`, 48px tall, `background:
  var(--grad-hot)`, white text + `ios_share` icon, 15px/700, `box-shadow:
  var(--glow)`.
- Secondary copy button: 48×48px square, `border: 1.5px solid var(--line)`,
  `content_copy` icon.
- Simulate-join dashed link below the row: 44px tall, `border: 1.5px dashed
  var(--line)`, `bolt` icon + "Giả lập: {partner} vừa vào" / "Simulate:
  {partner} joined".

## 2. Couple-Type Picker (unchanged, position locked)

Header: "Tụi mình thuộc kiểu nào?" / "What kind of couple are we?" (16px,
700) + subcopy (12.5px, `var(--tx2)`): "Cupid sẽ bật/tắt tính năng phù hợp
cho kiểu của bạn." / "Cupid tunes default features to your type."

2×2 grid, `gap: 10px`. Selected card: gradient background
(`rgba(255,127,182,.22)` → `rgba(183,140,245,.22)`), `border: 1.5px solid
var(--pink)`, `box-shadow: var(--glow)`, gradient icon badge. Unselected
card: `background: var(--surf)`, `border: 1.5px solid transparent`, muted
icon badge (`var(--surf2)`). Card content: icon, label (14.5px), hint
(11.5px, `var(--tx2)`). This grid's position (after the code/QR block) is
locked per REQ-009 (AC3) and must not move.

## 3. Continue CTA (styling unchanged, destination and copy updated — AC4)

Visual treatment stays as designed: full-width, 52px tall,
`background: linear-gradient(95deg, var(--pink), var(--purple))`, white text,
16.5px/700, `box-shadow: var(--glow)`.

**Copy change required.** The design source's literal label — "Tiếp tục →
Fingerprint Vow" / "Continue → Fingerprint Vow" — is stale and must not ship:
its destination (`goVow`) was superseded by REQ-009, which locked this CTA to
navigate to Waiting-for-partner instead. Specify the label as simply
**"Tiếp tục" / "Continue"** (drop the "→ {destination}" suffix pattern
entirely) rather than inventing a new destination-name suffix — this avoids
UX asserting a specific screen name that isn't this story's decision to make,
while guaranteeing "Fingerprint Vow" never appears (AC4). Tech Lead/PO may
confirm a more specific label in a later pass if desired; that is not
blocking for this story.

## Responsive Behavior

Single-column mobile screen, no breakpoint variants. At narrow widths (~320dp)
the 186px QR frame plus 20px side padding still fits (320 − 40 = 280px
available); no scaling rule needed below the app's supported minimum width.
The ambient glow blob and scan-line are decorative and may clip at
`overflow: hidden` on the card without layout impact.

## Accessibility

- QR image carries an accessible label naming it as the pairing code (see
  above); the plain-text code remains the non-visual/non-scan fallback and is
  never removed or hidden.
- Decorative animations (`breathe`, `qrScan`, `dotWave`) are non-essential;
  if the platform exposes a reduce-motion preference, prefer pausing or
  simplifying them rather than blocking on it for this story.
- Color contrast: QR modules render dark-on-`#FFFDFE` inside the white frame
  regardless of the app's dark theme, preserving scan contrast; all
  surrounding text/icon tokens are the same tokens already used and approved
  elsewhere on this screen.

## Dark Theme + `vi` Locale Match (AC5)

All colors, radii, spacing, and typography above are taken directly from the
design source's existing tokens (`--surf`, `--surf2`, `--pink`, `--purple`,
`--tx2`, `--line`, `--grad-hot`, `--glow`, `--shadow`, `--r-card`, `--r-btn`)
— no new tokens are introduced for the QR addition. `vi` strings are quoted
verbatim from the design source above; `en` strings are the paired
`data-en` values.

## Acceptance Criteria Coverage

- AC1 (QR renders above text code, matching design): QR frame section above.
- AC2 (QR and text code represent one identical value): stated explicitly in
  QR frame section; implementation must not generate a second code.
- AC3 (picker stays after code/QR, unchanged position): picker section above,
  explicitly locked.
- AC4 (CTA still navigates to Waiting-for-partner, never Fingerprint Vow):
  CTA section above — styling preserved, copy changed to remove the stale
  "Fingerprint Vow" reference, destination is REQ-009's existing wiring
  (Tech Lead/dev scope, not re-specified here).
- AC5 (dark theme + `vi` visual match): Dark Theme + `vi` Locale Match section
  above — all values sourced from existing design tokens.
