# UX Spec: STORY-001 Zodiac Red Flag Screen — Conflict Index And Daily Tip

Design source: `cupid-app-design-system/Cupid Screens.dc.html` lines 601-635
(`isZodiac` block), plus captured token/structure mapping from
`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-023_zodiac_red_flag_design_fidelity/visual-fidelity/visual-fidelity-report.md`
("Design Spec Captured For Whoever Builds It" section — reused verbatim below,
this story is the first to build against it).

Theme / locale: dark theme + `vi` locale only (Out of Scope: light/`en` visual
QA, per requirement precedent).

Icon component: `mobile/lib/design_system/icons/cupid_zodiac_icon.dart` —
`CupidZodiacIcon(sign: CupidZodiacSign, size: double, color: Color?, flat:
bool?)`. `CupidZodiacSign.tryParse(String?)` parses the backend's
`zodiacSign` string (e.g. `"Aries"`). Never substitute a Unicode glyph for
this widget.

## 1. Screen Purpose

A direct-route screen (no Home entry point yet — STORY-002 adds it) that
shows the paired couple's real-sign-pair conflict-index reading and one
deterministic-per-day tip. Content is computed server-side from each
partner's `zodiacSign` profile field; the client renders what the endpoint
returns and does not invent or locally compute pairing content.

## 2. States

### 2a. Loaded state (both partners have `zodiacSign` set) — AC1, AC2, AC4

Root container: padding `8px` top, `16px` sides, `40px` bottom; vertical
stack, `13px` gap between the three cards below.

**Card 1 — Red-flag header card**
- Background: `155deg` gradient, `rgba(183,140,245,.34)` to
  `rgba(255,127,182,.16)` (existing purple/pink gradient tokens — Tech Lead
  maps to nearest existing gradient/token pair, do not hardcode new raw
  rgba if an equivalent gradient token already exists in the design system).
- Border: `1px solid rgba(183,140,245,.4)`.
- Corner radius: `radiusCard` (`24px`).
- Decorative background icon: `auto_awesome`, `110px`, `20%` opacity,
  offset top-right (`-10px,-10px`) — purely decorative, `excludeSemantics`.
- Row: `warning` icon (`18px`, `colorButter`) + eyebrow label, mono font,
  `10px`, `.16em` letter-spacing, uppercase, `colorButter`. Eyebrow text is
  **"Red flag"** plus the content date — do not use the design's literal
  fixture date (`29/07`); render the actual current date the content applies
  to, formatted per existing app date-formatting convention.
- Headline: Nunito 900, `23px`, line-height `1.3`, `margin-top:12px` — the
  conflict-index blurb's headline text as returned by the endpoint (per-pair
  curated content, not a fixture string).
- Body text: `13px`, line-height `1.6`, `colorTextMuted`, `margin-top:9px` —
  the conflict-index blurb's supporting sentence, also endpoint-supplied.

**Card 2 — Conflict-index card**
- Background: `colorSurface`, `elevationShadow`, `18px` padding,
  `radiusCard`.
- Top row (`space-between`, bottom-aligned, `14px` margin-bottom):
  - Left: label "Conflict index today" (`12px`, `colorTextMuted`), score
    below it — Nunito 900, `34px`, `colorPeach`, with `/10` suffix at `17px`
    `colorTextMuted`. Score is the endpoint's numeric conflict-index value
    for the couple's real sign pair, `0`-`10` integer scale (confirm exact
    scale with Tech Lead's content-model decision; render whatever unit the
    API defines, do not assume `/10` is hardcoded if the schema differs).
  - Right: two `46px` `CupidZodiacIcon` discs, one per partner, each with
    the partner's first name/label below it at `10px` `colorTextMuted`, and
    a `bolt` icon (`17px`, `colorTextMuted`) between them. Each
    `CupidZodiacIcon.sign` is `CupidZodiacSign.tryParse(partner.zodiacSign)`
    — real value, not the design's fixture `cancer`/`pisces`.
  - Name label under each icon is the partner's existing display name
    field (not a fixture "Minh"/"Linh") — confirm exact field with Tech
    Lead; if no compact display-name field exists, fall back to first name
    or an initial, but never a placeholder string.
- Gradient bar: `10px` height, `6px` radius, track `colorSurfaceAlt`, fill
  `linear-gradient(90deg, colorMint, colorButter 55%, colorPeach)`, fill
  width proportional to the score fraction (e.g. score/10 × 100%, or the
  correct denominator per the API's actual scale) — not a hardcoded `70%`.
- Bar caption row: `space-between`, `7px` margin-top, `10px` mono font,
  `colorTextMuted` — left "êm" (calm), right "drama", both static localized
  labels (not content-driven).

**Card 3 — Daily-tip list (3 rows)**
- Background: `colorSurface`, `elevationShadow`, `radiusCard`,
  `6px 17px` padding.
- Each row: `14px 0` vertical padding, `13px` gap, horizontally: a
  `36×36px`, `12px`-radius tinted icon tile (icon + tile background per the
  tip's own icon token — the design's 3 example tips use `videocam`/mint,
  `block`/pink, `local_cafe`/amber tile combinations; the actual icon +
  tint per row comes from the endpoint's selected tip entries, not a fixed
  3-icon sequence) + tip text (`13.5px`, line-height `1.45`, may contain
  inline `<strong>` emphasis spans if the API marks them).
- `1px` `colorLine` divider between rows, no divider after the last row.
- Exactly 3 rows for this MVP (per requirement OQ1 — deterministic-per-day
  selection from a fixed tip pool). If the endpoint ever returns fewer than
  3 (e.g. a degraded partial state), render only the rows returned rather
  than fabricating placeholder rows — flag this edge case to Tech Lead since
  the story's content model assumes a full pool is always available.

**Disclaimer footer**
- `11px`, `colorTextMuted`, centered, `0 20px` horizontal padding,
  line-height `1.5`. Static localized string, not content-driven (matches
  design's "for fun, not responsible" framing) — Product Owner /
  localization to finalize exact `vi` copy; do not invent legal-sounding
  claims beyond the design's tone.

### 2b. Deterministic-per-day framing (AC2)

The screen has no client-side "regenerate" or "shuffle" affordance. Content
is whatever the endpoint returns for "today" — same couple, same calendar
day, same content on every open (including app restarts). No loading
skeleton should visually suggest randomness (e.g. no shuffle spinner
animation); a plain content skeleton/shimmer on the three card shapes is
fine while the request is in flight.

### 2c. Degraded / incomplete-profile state (AC3)

Trigger: the endpoint's response signals a partner's `zodiacSign` is unset
(exact signal — null field, status flag, or error code — is a Tech Lead
contract decision; this spec covers the resulting UI, not the wire format).

Replace the loaded three-card layout with a single centered state card,
same `colorSurface` / `elevationShadow` / `radiusCard` container as the
other cards, vertically centered in the available content area below the
app bar:
- Icon: reuse an existing neutral/info glyph from the design system's icon
  set (do not introduce a new custom icon for this story) at roughly `48px`,
  `colorTextMuted`.
- Headline (`vi`): "Chưa đủ thông tin cung hoàng đạo" (incomplete zodiac
  info) — Product Owner/localization to confirm final copy; the point is an
  honest, non-alarming incomplete-state message, not an error message.
- Body: one sentence explaining that this feature needs both partners'
  zodiac sign set on their profile, without blaming either partner by name
  (avoid "your partner hasn't..." phrasing that could feel accusatory in a
  couple's app — prefer neutral "cả hai người cần..." framing).
- No CTA button is required by this story's scope (profile-editing entry
  points already exist elsewhere in the app; this story does not add a
  deep link to profile edit — flag to Tech Lead as a nice-to-have, not a
  blocker).
- This state must never render fabricated icons, scores, or tip rows — no
  partial rendering of Card 1/2/3 with placeholder/zero values.

### 2d. Loading and error states

- Loading: skeleton/shimmer placeholders matching the three-card shapes
  (header card, conflict-index card, tip-list card), consistent with this
  app's existing skeleton pattern elsewhere (reuse existing shimmer
  component, do not build a new one).
- Network/unexpected-error state: reuse the app's existing generic error/
  retry pattern (consistent with other screens' error handling) — this
  story does not need a bespoke error illustration.

## 3. Route / Reachability (AC5)

This story ships a direct in-app route only — no Home quick-grid tile
(STORY-002 adds that). Tech Lead/mobile-dev to register a real
`PreviewScreenEntry` for the `zodiac` canvas id in `main_preview.dart`
(currently listed in `_notImplementedCanvasIds`, per STORY-023's finding)
and a normal app route reachable outside preview mode for production
verification. No UX-specific requirement beyond "reachable and renders the
states above" — this is a routing/navigation implementation detail, not a
visual design decision.

## 4. Accessibility Notes

- Score text ("7/10" style) must be exposed as a single semantic label
  (e.g. "Conflict index today: 7 out of 10"), not read as two disjoint text
  nodes.
- Each `CupidZodiacIcon` disc needs a semantic label combining the sign
  name and the partner's name/label (e.g. "Minh's sign: Cancer"), since the
  icon itself conveys no text.
- The decorative `auto_awesome` background icon and the bar's "êm"/"drama"
  caption row are decorative/contextual, not primary content — the bar
  fill itself should carry the real semantic value via the score label
  above it, not solely via the visual bar width.
- Tip row icon tiles are decorative; the tip text carries the full meaning
  and must remain the row's accessible label.
- Maintain existing dark-theme contrast tokens; no new contrast pairs are
  introduced beyond values already used elsewhere in the design system per
  the token table in Section 5.

## 5. Design Token Mapping (carried from STORY-023's report, reused as-is)

| Design var | Existing token |
| --- | --- |
| `--surf` / `--surf2` / `--line` | `colorSurface` / `colorSurfaceAlt` / `colorLine` |
| `--tx` / `--tx2` | `colorText` / `colorTextMuted` |
| `--pink` / `--purple` / `--mint` / `--butter` / `--peach` / `--amber` | `colorAccentPink` / `colorAccentPurple` / `colorMint` / `colorButter` / `colorPeach` / `colorAmber` |
| `--r-card: 24px` | `radiusCard` |
| `--shadow` | `elevationShadow` |
| Nunito 900 34px | `display` |
| `'Roboto Mono'` label | `labelMono` |

No new design tokens are required for this story. `CupidZodiacIcon` element
ink/disc colors are already implemented (fire `#FF9576`, earth `#5FD3BC`,
air `#B78CF5`, water `#FF7FB6`) — do not redefine them.

## 6. Explicitly Not Designed Here

- The Home quick-grid tile that links to this screen — STORY-002.
- Light theme / `en` locale layouts — out of scope per requirement.
- Any content-authoring UI for the 78 conflict-index entries or the tip
  pool — no admin/CMS surface exists or is planned for this MVP.
- Exact wire-format signal for the degraded state, exact score scale/
  denominator, and exact partner display-name field — these are Tech Lead
  content-model/contract decisions; this spec describes the UI response to
  whatever contract Tech Lead defines, and flags the assumptions above that
  need confirming during architecture.

## 7. Open Items For Tech Lead

- Confirm conflict-index score scale/denominator (design fixture shows
  `/10`; confirm this is the real API contract, not just fixture styling).
- Confirm exact field used for the small name label under each partner's
  zodiac icon.
- Confirm the exact signal shape for "partner zodiacSign missing" so
  mobile can branch to the 2c degraded state deterministically.
- Confirm whether tip rows can ever number fewer than 3 in a valid response
  (Section 2, Card 3 note).
