# UI/UX Spec: STORY-011 Epic-3 — Bun Pet Đồng Hành

Status: DRAFT for Tech Lead / Mobile Dev
Depends on (done, merged): STORY-001 (design tokens), STORY-002 (API client), STORY-003 (auth)
Design source: `cupid-mobile-design/Cupid Screens.dc.html` (`isPet` screen block, `id: 'pet'`
nav tab), `Bun Sprite.dc.html` (6-state sprite component), `Bun Pet Art.dc.html` (style guide).
Backend contract read: `backend/src/modules/pets/` (`pets.controller.ts`, `pets.service.ts`,
`entities/pet.entity.ts`, `dto/adopt-pet.dto.ts`).

## 1. Backend Contract Summary (ground truth for what follows)

`pets` module exposes exactly 4 endpoints, all behind `JwtAuthGuard`:

| Endpoint | Purpose | Key response/side-effect fields |
|---|---|---|
| `POST /pets/adopt` | Create the couple's pet. Requires: user has a `partnerId`, and `hoursSincePairing >= 24` (computed from `user.createdAt`, no `pairedAt` field exists). One pet per `coupleId` (409 if one already exists). | Body: `{ species: cat\|dog\|bunny, name: string (1-30 chars) }` |
| `GET /pets` | Current pet row, or `null` if unpaired/no pet yet. | `{ id, coupleId, species, name, happiness, level, totalInteractions, lastInteraction }` |
| `GET /pets/status` | Derived/dynamic view, also lazily persists decayed happiness. | `{ pet, mood, decayedHappiness, milestone, nextMilestone }` |
| `PATCH /pets/interact` | The **only** interaction endpoint. +5 happiness (capped 100), +1 `totalInteractions`, 5-second cooldown (429-equivalent `BadRequestException` if called again inside 5s), level = `floor(totalInteractions/50)+1`. Emits a `pet.milestone.reached` event at 50/100/500/1000 interactions, which `timeline.service.ts` consumes to auto-create a Love Timeline entry. | Updated pet row |

`mood` (from `getStatus`) is one of exactly 5 string values: `ecstatic`, `happy`, `content`,
`sad`, `sick`. Derived from `decayedHappiness` thresholds (≥80/≥60/≥40/≥20/<20) with an
override to `sick` if `lastInteraction` is more than 48h ago. Happiness itself decays -2/hour
after 12h idle (computed on read, not by a background job).

**There is no "feed" vs "play" distinction, no streak counter, no badge system, and no
incidental XP from chat/vibe/other modules** — confirmed by grepping the full backend module
tree for `streak`/`badge` (no matches) and for any other writer of `petRepository` besides
`pets.service.ts` (none; `timeline.service.ts` only *listens* to the milestone event, it never
writes back to `pets`).

## 2. Screens & Flows

### 2.1 Love Pet home tab (`pet`) — primary screen, reuse existing design almost as-is

Source: `Cupid Screens.dc.html` lines 624-673 (`isPet` block). Structure to keep:

1. Hero card (gradient `#7B4FBE → #B0518C → #5E7E96`, ambient breathing/drift decorations
   per system memory §1/§2) containing:
   - `Bun Sprite` component, 206×206, `state` bound per the mapping table in §3 below.
   - Pill badge: `Lv.{level} · {moodLabel}`.
   - Pet name (`pet.name` from `GET /pets`, **not** a hardcoded "Bún" — the design's literal
     "Bún" string is prototype flavor text; the real name is whatever the couple chose at
     adopt time, see §2.2).
   - Status line (`petLine` equivalent) — one short sentence keyed off `mood`, see §4 copy
     table.
2. XP card: progress bar toward next level. Compute client-side as
   `(totalInteractions % 50) / 50` for "progress within current level" — **do not** use the
   design mockup's `petXpPct` as a literal field, it doesn't exist in the contract; derive it
   from `totalInteractions` and `level` as shown.
3. Action row: **two buttons, "Feed" (`restaurant` icon) and "Play" (`sports_esports`
   icon), both calling the same `PATCH /pets/interact`.** This matches the source prototype
   itself (both buttons already wire to the same `doFeed` handler in the mockup) — keep both
   labels for personality/couple-choice flavor, but do not implement or imply any different
   backend effect between them. See §5 Open Item 1 for the interaction-cooldown UX this
   requires that the mockup doesn't show.
4. Stats row: **replace the mockup's 3-tile "interactions / day streak / badges" row with a
   2-tile row: "interactions" (`totalInteractions`) and "next milestone"
   (`nextMilestone` value, e.g. "100" with a progress-style caption "{totalInteractions}/{nextMilestone}").**
   Drop the "day streak" and "badges" tiles — no backend field supports either (see §5 Open
   Item 2).
5. "How Bun reacts" reference card: keep as designed (illustrative row of 3 sprite states +
   caption), but recaption to match the real mood thresholds — see §3 mapping. Use `sad` (24h+
   idle window, roughly) and `sick` (48h+ idle) as the two "if you ignore me" reference states
   instead of the mockup's "sulk / 24h" + "sick / 3 ngày" labels, whose thresholds don't match
   the backend's 12h-decay-start / 48h-sick-override timing. Caption copy: "Bơ một chút" (idle,
   decay started) and "Bơ lâu ghê" (48h+, sick), rather than literal hour/day counts, since the
   exact decay curve is continuous, not doorstep-stepped like the mockup implies.

Home-dashboard preview card (`Cupid Screens.dc.html` lines 280-287, the small card that
navigates to the `pet` tab) stays as designed: sprite thumbnail + name + level chip + one-line
status + XP bar, using the same data mapping as the full screen.

### 2.2 Adopt flow — new, not present in the original design set (Open Item 3)

The design source has **no adopt/species-selection screen** — every existing `isPet` mockup
assumes a pet already exists (it even seeds sample data with a `petXp` value straight into the
dashboard). But `POST /pets/adopt` is a hard precondition (species + name, 1-per-couple,
24h-post-pairing gate). This flow must be designed net-new using existing system-memory
patterns rather than inventing new visual language:

1. **Entry point**: pet tab, when `GET /pets` returns `null` and the couple has been paired
   ≥24h. Show an empty-state card (reuse the "locked" empty-state visual pattern already used
   for Private Gallery in the source — centered icon in a soft gradient circle, headline, one
   CTA) with headline "Nhận nuôi một Bún cho cả hai" / "Adopt a Bun together", CTA button "Nhận
   nuôi" / "Adopt".
2. **Adopt sheet** (bottom sheet, `--r-sheet` token, standard modal chrome per system memory
   §2/§3): species picker (3 options: cat/dog/bunny — simple 3-card horizontal chooser, each
   showing a static labelled icon since only the bunny has real sprite art today, see Open Item
   4) + name text field (1-30 chars, inline validation matching `AdoptPetDto`) + primary CTA
   "Nhận nuôi" / "Adopt", disabled until both fields valid.
3. **Submit states**:
   - Success → sheet dismisses, hero card animates in with the new pet (reuse `popIn`
     keyframe already in the animation vocabulary).
   - 409 (couple already has a pet) → sheet shows inline error "Bạn đã có Bún rồi, đón chào
     {existingName}!" and offers a "Xong" / "Done" button that dismisses and refreshes the
     main pet screen — this is a real race-condition path per the backend's own transaction
     comment, not a hypothetical.
   - 400 (<24h since pairing) → this state should be **prevented at the entry point**, not
     surfaced as a raw error: if paired <24h, show a waiting-state card instead of the adopt
     CTA — "Chờ thêm {X} giờ nữa để nhận nuôi Bún" / "Wait {X} more hours to adopt a Bun",
     computed client-side from the same 24h/`user.createdAt` rule the backend enforces (Tech
     Lead should confirm the client has access to a pairing timestamp equivalent — see Open
     Item 5).

### 2.3 Unpaired guard (AC3)

If the current user has no partner (`user.partnerId` absent, or `GET /pets` context otherwise
indicates unpaired), the entire `pet` tab renders the same "locked" empty-state pattern as
Private Gallery (per system memory §5/§8: any feature gated on pairing reuses this pattern) —
lock icon, headline "Ghép đôi để nuôi Bún cùng nhau" / "Pair up to adopt a Bun together", no
adopt CTA, no navigation into adopt sheet or the interact buttons. This is a hard gate, not
just a disabled-looking button — do not let the sheet be reachable via deep link either.

## 3. Mood → Sprite State Mapping (resolves the story's core open item)

The story's "Open Items For Downstream Roles" note asked to reconcile the design's pet art
against the real `pets` contract. Resolved as a clean 1:1 mapping — the backend's 5 `mood`
values map directly onto 5 of the `Bun Sprite` component's 6 declared states:

| Backend `mood` | Bun Sprite `state` | Design label (VI / EN) |
|---|---|---|
| `ecstatic` | `inlove` | Mềm lòng / Delighted |
| `happy` | `happy` | Vui phơi phới / Happy |
| `content` | `neutral` | Tạm ổn / Content |
| `sad` | `sulk` | Đang dỗi / Sulking |
| `sick` | `sick` | Ốm rồi / Sick |

**The sprite's 6th state, `sleep`, has no backend equivalent and is explicitly not wired into
any data-bound screen in the source itself** (the live `isPet` screen's own `petState`
computation only ever produces `inlove`/`happy`/`neutral`/`sulk`/`sick` — `sleep` only appears
in the sprite component's own preview enum). **Do not implement a client-side time-of-day
sleep state** — it would be exactly the kind of invented, contract-unbacked mechanic the story
explicitly says to flag instead of fake. If a "nighttime Bun" moment is wanted later, it needs
a real product decision (e.g. a quiet-hours flag from the couple's profile), not a silent
client-side clock check.

## 4. Status-line copy (per mood)

Reuse the pattern already in the source (one short first-person-pet sentence per state), keyed
to the 5 real moods instead of the mockup's 3 XP-banded ones:

| mood | VI | EN |
|---|---|---|
| ecstatic | "Bún hôm nay phổng phao ✨" | "Bun is glowing today ✨" |
| happy | "Bún đang vui vẻ lắm" | "Bun is having a great day" |
| content | "Bún đòi được để ý một chút" | "Bun wants a little attention" |
| sad | "Bún đang dỗi. Nhắn nhau nhiều lên." | "Bun is sulking. Chat more." |
| sick | "Bún không khoẻ. Ghé thăm Bún đi." | "Bun isn't feeling well. Go check on Bun." |

## 5. Open Items For Downstream Roles — resolved/flagged (numbered)

1. **Feed vs Play button parity (resolved, not a gap)**: confirmed intentional — both buttons
   call the same `PATCH /pets/interact`. Tech Lead/Mobile Dev must implement a single
   client-side action handler bound to both buttons, and **must surface the 5-second cooldown**
   client-side (disable both buttons for ~5s after a tap, or optimistically show a brief
   "cooldown" micro-state) so the user doesn't get a raw 400 error from double-tapping — the
   mockup has no cooldown UI at all since it's a static prototype.
2. **Stats row mismatch (flag, resolved by omission)**: the design's "day streak" and "badges"
   stat tiles are not backed by any field in the `pets` module or elsewhere in the backend
   (confirmed by repo-wide grep for `streak`/`badge` — no matches). Recommendation: drop both
   tiles for v1, replace with "interactions" + "next milestone" as specified in §2.1 item 4. If
   Product Owner wants a real streak/badge system, that's new backend scope outside this
   story's A1-frozen `pets` contract, not a client-side UI decision.
3. **No adopt screen exists in the design source (flag, resolved by new spec)**: §2.2 above is
   net-new UX, not present in `cupid-mobile-design/`. Flagging explicitly since this story's
   "In Scope" line only mentions "displaying state" and "interactions," but `POST /pets/adopt`
   is a hard precondition with no existing screen — Tech Lead/PO should confirm this net-new
   flow is acceptable scope for this story rather than a separate story.
4. **Species art gap (flag)**: `AdoptPetDto`/`PetSpecies` enum supports `cat`, `dog`, `bunny`,
   but the only real sprite art (`Bun Sprite` component, `Bun Pet Art.dc.html` style guide) is
   for the bunny. The adopt-flow species picker in §2.2 uses simple labelled icons (Material
   Symbols `pets`-family icons, not custom art) for cat/dog since no cat/dog sprite exists yet.
   Once a pet is adopted, **all main-screen sprite rendering should still use `Bun Sprite`
   regardless of chosen species** for v1 (i.e., species is stored/displayed as text/icon at
   adopt time and in stats, but the animated hero sprite is the one universal bunny-styled
   character) — this avoids inventing cat/dog art client-side. Flag to PO: if distinct
   per-species art is expected, that's new asset scope, not a v1 gap to silently paper over.
5. **Client-side 24h-pairing-gate computation (flag for Tech Lead)**: the backend computes the
   24h gate from `user.createdAt` as an explicit proxy comment ("no pairedAt field") — this is
   backend-internal logic, not exposed via any GET endpoint as a countdown value. The client
   cannot independently compute "hours remaining" without either (a) the API client's `/users`
   or `/pets` response exposing an equivalent timestamp, or (b) calling `POST /pets/adopt`
   speculatively and handling the 400 response. Recommend (b) for v1 simplicity — attempt-based
   rather than countdown-based UX: the adopt CTA is always shown once paired, and a 400 response
   is caught and shown as a friendly "not yet" message (see §2.2 state list) rather than trying
   to pre-compute a live countdown the client has no clean data source for.

## 6. Responsive Behavior

- Single-column, portrait-first (matches rest of the app; no tablet/landscape variant
  designed anywhere in the source, so none is required here either).
- Hero sprite area is a fixed 206×206 box on the main screen, 74×74 on the dashboard preview
  card, 46×46 in the "How Bun reacts" reference row — three fixed sizes, not fluid scaling,
  matching the `Bun Sprite` component's own `hint-size` props in the source.
- Adopt sheet (§2.2) follows standard bottom-sheet sizing: content-height sheet with safe-area
  bottom padding, not a fixed viewport-height sheet — species picker row scrolls horizontally
  if needed on narrow devices rather than wrapping.
- Action buttons (Feed/Play) stay a fixed 2-up row (`flex:1` each) down to the smallest
  supported device width; do not stack vertically at any breakpoint (matches `--tap` 44/48pt
  minimum target already satisfied at 46px height).

## 7. Accessibility

- Sprite is decorative/mood-communicating, not the sole channel: mood must also be conveyed
  via the text pill (`Lv.{level} · {moodLabel}`) and the status line (§4) — screen readers
  should announce the mood label and status line, with the sprite itself marked as a
  decorative image (no meaningful alt text needed beyond "Bun the pet").
  Correct Vietnamese ordinal: keep the "Lv." pill in the roman-mono style already used for
  streak-style badges elsewhere in the source, translated by screen reader as plain text.
- Feed/Play buttons: standard 44/48pt tap targets (already satisfied at 46px in the mockup),
  each must have an accessible label distinguishing "Feed" from "Play" even though they share
  one backend action (e.g. `Semantics(label: "Feed Bun")` / `Semantics(label: "Play with
  Bun")`) so screen-reader couples don't lose the flavor distinction the buttons were designed
  to preserve.
- Cooldown state (Open Item 1): when buttons are disabled during the 5s cooldown, expose this
  via `Semantics(enabled: false)` plus a live-region announcement (e.g. "Please wait a moment")
  rather than a silent no-op tap — a silent disabled button with no feedback is a common a11y
  failure mode.
- Adopt sheet: standard modal focus-trap + return-focus-on-dismiss (same pattern already
  codified in system memory §11 for destructive/confirm dialogs) — species picker must be
  keyboard/switch-navigable as a radio-group semantic (single-select), not a set of unlabelled
  tappable cards.
- Locked/empty states (unpaired guard, §2.3; waiting-for-24h state, §2.2): must announce their
  headline as the screen's accessible page title so a screen-reader user landing on the `pet`
  tab immediately understands why no pet content is shown, rather than encountering silence.

## 8. Design System Reuse

- Locked/empty-state visual pattern: reuse the Private Gallery lock-icon-in-gradient-circle
  pattern (system memory §5/§8) verbatim for both the unpaired guard (§2.3) and (styled as a
  waiting/clock variant, not a lock) the <24h-since-pairing state (§2.2).
- Bottom sheet chrome: reuse `--r-sheet` (28px) token and standard sheet chrome, no new sheet
  variant needed.
- Buttons/pills: reuse `--r-btn` (999px pill), `--grad-hot` gradient for the primary "Feed"
  action, `--surf2` flat surface for the secondary "Play" action — matches the existing mockup
  exactly, no new button style needed.
- Animation vocabulary: `popIn` (adopt success), `breathe`/`drift` (ambient hero card
  decoration, already in the mockup), `bob` (sprite idle motion, already inside `Bun Sprite`
  itself) — no new keyframes required for this story.
- Iconography: Material Symbols Rounded for all functional icons (`restaurant`, `sports_esports`,
  `lock`, `pets`, `celebration`) per system memory §2 icon rule; emoji reserved for
  sticker/mood use only (none needed beyond what's already inside the sprite art itself).

## 9. Out of Scope (confirmed, do not implement)

- Any change to `pets` endpoints, request/response shapes, or business rules (A1 frozen).
- Lottie/animated-illustration pet art — vector-only is the confirmed v1 state per system
  memory §10 ("Chưa làm" list); this story consumes the existing `Bun Sprite` vector component
  as-is.
- Streak counters, badge systems, or any per-species distinct sprite art (Open Items 2 and 4)
  — flagged for PO, not silently built client-side.
- Time-of-day/"sleep" pet state (§3) — not backed by any signal in the `pets` contract.
