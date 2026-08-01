# UX Spec: STORY-014 Dream Jar / Hũ Ước Mơ Chung

Scope: REQ-001 / STORY-014_dream_jar

Sources of truth used:
- `cupid-mobile-design/Cupid Screens.dc.html` — `isJar` screen block (lines
  ~738-816), home dashboard "Dream Jar" entry card, Notifications screen
  ("Dream Jar milestone" entry), Privacy/"My data" screen (3-tier model),
  Love Timeline auto-entry example ("Dream Jar hit 75%").
- `backend/src/modules/dream-jar/` — `DreamJar` entity, `Contribution`
  entity, `CreateDreamJarDto` / `UpdateDreamJarDto` / `AddContributionDto`,
  `DreamJarController` (frozen contract, A1).
- `data/ux/system/ui_ux_system_memory.md` §1-§3, §8, §9, §11 (design
  principles, tokens, data-sensitivity model, Dream Jar interaction pattern,
  reusable confirm-dialog pattern).

## 0. Open Items — Resolved / Flagged

### 0.1 Story framing does not match the confirmed feature (flag for Product Owner)

`story_master.md`'s User Story and AC describe Dream Jar as a **text-based
wish/dream list** ("drop in wishes/dreams", "add a dream/wish entry", "view
the jar's contents"). This does not match the confirmed feature in every
other source: the design prototype's Dream Jar screen is a **shared
monetary savings-goal jar** (target amount, current amount, % progress,
preset money contributions, per-partner contribution leaderboard), and the
backend contract (`dream-jar.entity.ts`, `contribution.entity.ts`,
`AddContributionDto`) only models `name` / `targetAmount` / `currentAmount`
/ `deadline` / `currency` and numeric `Contribution.amount` (+ optional free
`note`) — there is no free-text "wish" field anywhere in the schema.

**This UX spec is written against the confirmed monetary-savings-jar
feature**, not the story's "wish list" narrative, because the backend
contract is frozen (A1) and cannot be redesigned to fit the story's wording.
Product Owner should update `story_master.md`'s User Story/AC wording to
describe a shared savings goal (e.g. "add a monetary contribution toward a
shared savings goal", "view the jar's progress and contribution history"),
not a wish/dream text list. AC1-AC3's *intent* (a paired user can add to the
jar; both partners can view it; unpaired users cannot access it) is
preserved and mapped onto the real feature below — only the "dream/wish
entry" wording is wrong, the underlying feature is otherwise buildable.

Secondary, lower-priority note: `req_master.md`'s User Stories table and
`story_master.md` file both to place Dream Jar under epic-4
(intimacy/memories), but the design source's own screen `INDEX` and the
backend's own `@ApiTags('Epic 5 - Dream Jar')` both place it under epic-5
(finance), next to Shared Expenses. `ui_ux_system_memory.md` §4/§9 already
records it under epic-5. Product Owner should reconcile the epic tag; this
does not change any UX decision in this spec.

### 0.2 R3 (libsodium FFI / local encryption) — confirmed relevant, still unresolved (flag for Tech Lead)

`ui_ux_system_memory.md` §8 (Data Sensitivity Model, sourced from the
design's own "Privacy / My data" screen) places **Dream Jar in Level 2 —
"server, end-to-end encrypted"**, alongside Love Timeline and Vibe Check.
`system_architecture_memory.md` still lists "libsodium FFI (R3) — Dual-platform
build unproven — Spike before epic-4" as an open risk with no recorded
resolution. So R3 is confirmed in-scope for this story's data, not a false
alarm — but there is a **contract gap** Tech Lead must resolve before
coding-plan: the frozen backend entities store `DreamJar.name`,
`targetAmount`, `currentAmount` and `Contribution.amount`, `note` as plain
typed columns (decimal/string), with no ciphertext/blob field. Given A1
(backend frozen, no client-driven backend changes), true field-level
end-to-end encryption of jar name/amounts is not actually possible without
a backend change. Tech Lead must decide one of:
- (a) treat the Level-2 privacy-screen claim as not literally implemented
  for Dream Jar in v1 (jar name/amounts travel as plaintext over TLS 1.3,
  i.e. de facto Level 3), and correct the Privacy screen's copy/grouping
  accordingly, or
- (b) scope a client-side encryption layer that only encrypts the `name`
  and optional `note` fields into an opaque string before it round-trips
  through the existing plain `string` columns (no backend schema change,
  ciphertext stored as if it were a name/note string) — note this does not
  cover `targetAmount`/`currentAmount`/`amount`, which are strongly-typed
  `decimal` columns the backend itself reads via `computeProgress()`, so
  those numeric fields cannot be opaque ciphertext without breaking
  server-side progress calculation.
This UX spec does not block on this decision (the on-screen fields and
flows are unaffected either way), but the Privacy screen copy and any
"encrypted" lock-affordance UI for Dream Jar must not ship until Tech Lead
confirms (a) or (b).

### 0.3 Realtime sync expectation (note for Tech Lead, soft dependency)

Both partners must see a new jar, a new contribution, and updated
progress without a manual app restart — this matches the "couple-first"
principle (§1) and the Love Timeline auto-entry example
("Dream Jar hit 75%" appears automatically). STORY-014 does not formally
depend on STORY-004 (RealtimeCoordinator spike), but its detail screen
needs *some* freshness mechanism. Recommendation: use whatever
STORY-004 delivers if it lands first; otherwise implement pull-to-refresh
plus refresh-on-screen-focus as the v1 fallback so this story is not
blocked on the spike. Tech Lead should confirm which in the coding-plan.

## 1. Screens & Flows

Entry point (already implemented, no change needed): home dashboard "Money"
group card — icon `savings`, title "Dream Jar", subtitle `{{ jarPct }}% ·
{{ tripLabel }}` — taps through to the Dream Jar detail screen. Bottom-nav
tab: **money** (existing 5-tab bar, no new tab).

### 1.1 Dream Jar detail (hero) — confirmed from mockup, `isJar` block

This is the primary screen and is fully specified by the existing
prototype; keep as-is:
- Gradient hero card (purple→teal, `popIn` entrance), floating sparkle
  decorations (`drift`), animated SVG jar with a liquid fill whose height
  is driven by `liquidY = 154 - 108 * min(1, current/target)` (bounded so
  a jar can never overflow visually past 100%, and never render a negative
  fill if `current` is 0).
- Jar label chip (goal name + representative icon, e.g. "✈ Du lịch Đà
  Lạt"/"Trip to Da Lat") — maps to `DreamJar.name`.
- Big amount line: `{{ jarAmount }}` (current, formatted) / "of"
  `{{ jarTargetAmount }}` · `{{ jarPct }}%` — maps to `currentAmount`,
  `targetAmount`, `progress`.
- Encouragement pill: `{{ jarRemainCopy }}` — "Only X to go" below 100%,
  "Full! Book the tickets already" at/above 100% (maps to
  `DreamJarStatus.COMPLETED` once `progress >= 100`; keep this copy branch
  tied to status, not just the raw percentage, so a manually-archived jar
  doesn't show "Full!" if it was archived below target).
- Quick-add row: 3 preset amount tiles (+100k / +200k / +500k VND, last
  tile visually emphasized with the hot gradient) → `POST
  /dream-jar/:id/contributions` with `{ amount }`. **Addition beyond the
  literal mockup**: add a 4th "Khác"/"Other" tile (dashed outline, `edit`
  icon) opening the custom-amount sheet in §1.4, since the backend accepts
  any amount from 1 to ~999,999,999,999 and restricting input to exactly 3
  fixed presets is an arbitrary product limitation the backend contract
  does not require. Flag to Product Owner: confirm the 4th "custom amount"
  tile is in scope for v1, or if the mockup's 3-preset-only design is a
  deliberate simplicity constraint to keep.
- "Who loves the jar more" comparison: two avatar+bar columns, one per
  partner, each showing that partner's cumulative contribution total
  (mono-font amount above a proportional-height bar, avatar initial below)
  plus a plain-language delta line ("Minh is 460k ahead. Linh, are you
  going to let that slide? 👀"). This is a **read-only aggregate view**
  (sum of that partner's `Contribution.amount` rows for this jar), not a
  ranking that affects gameplay/pet XP — keep it purely cosmetic/social,
  matching the design's playful tone.
- Cross-link card to Shared Expenses (`goExpense`) — unchanged, existing
  navigation.
- "Tạo Dream Jar mới" / "New Dream Jar" dashed CTA at the bottom → opens
  the create-jar flow (§1.3).

### 1.2 Jar list (extrapolated — required, not in the literal mockup)

The mockup only shows one jar in detail (a representative single-jar
case), but the backend is full CRUD over a collection
(`GET /dream-jar`, multiple `DreamJar` rows per couple) and the hero
screen's own "New Dream Jar" CTA implies more than one jar is expected
over a relationship's lifetime (e.g. one completed "Đà Lạt" jar, then a new
one started). Required screen, reusing existing list/card visual language
(same card shape/shadow as the Money-tab entry card and Love Timeline
entries):

- If the couple has exactly one non-archived jar: skip the list and go
  straight to §1.1 (current behavior, matches the mockup).
- If the couple has zero jars: show an empty state (see §1.5) instead of
  the list.
- If the couple has 2+ jars (including completed/archived ones): show a
  vertical list of jar cards above the hero, or as the Money-tab landing
  screen with the hero reserved for the single active/most-recent
  in-progress jar. Each card: jar name, small progress ring or bar,
  `{{ jarAmount }} / {{ jarTargetAmount }}`, status badge for
  `completed`/`archived` jars (mint check for completed, muted `ghost`
  tone for archived). Tapping a card opens that jar's hero/detail (§1.1).
  "New Dream Jar" CTA stays pinned at the bottom of the list.
- Recommend Tech Lead/Product Owner confirm whether archived jars are
  hidden by default behind a "show archived" toggle, to avoid an
  ever-growing list cluttering the primary Money tab — not a UX blocker,
  a scope call.

### 1.3 Create Dream Jar (extrapolated — required)

Triggered by any "New Dream Jar" / "Tạo Dream Jar mới" CTA. Use the
existing bottom-sheet chrome (`--r-sheet` 28px radius, per design tokens),
consistent with other creation flows in the app:
- Name field (required, maps to `CreateDreamJarDto.name`, text input,
  placeholder example "Trip to Đà Lạt").
- Target amount field (required, numeric keyboard, VND grouping as-you-type,
  min validation 1 as text, e.g. "Nhập số tiền lớn hơn 0" on invalid submit;
  no arbitrary max copy needed in v1 — backend max is effectively
  unreachable in practice).
- Optional deadline/date field (maps to `deadline`, standard date picker,
  platform-adaptive per §3 of `ui_ux_system_memory.md`).
- Currency: fixed to VND for v1, no selector shown (matches every other
  monetary surface in the design source, which is VND-only; DTO allows an
  optional override but nothing else in the app exposes multi-currency).
  Flag to Product Owner if multi-currency is actually wanted for v1 — if
  not, this is the default no-UI path.
- Primary CTA: platform-adaptive full-width button (iOS) / filled button
  (Material), per the existing adaptive-button pattern (§3 of the UX
  memory, same pattern already used for "add expense").
- On success, the new jar becomes the active hero (or is added to the jar
  list per §1.2) and should appear on the partner's device without a
  manual refresh — see Open Item 0.3.

### 1.4 Custom contribution amount (extrapolated, only if 0.1's 4th tile is approved)

Small bottom sheet or inline expand from the quick-add row: single numeric
VND input (thousand-grouped as-you-type), optional short note field (maps
to `AddContributionDto.note`, e.g. "Từ tiền thưởng" / "From my bonus"),
confirm button. Reuses the same numeric-input pattern as §1.3's target
amount field.

### 1.5 Empty state — no jars yet (extrapolated, required for AC1's first-run case)

Before a couple has created any jar, the Money-tab "Dream Jar" entry must
lead somewhere other than an empty hero. Simple centered empty state
matching the app's existing empty-state visual language (e.g. Private
Gallery's locked-state layout as a structural reference, not its lock
iconography): jar/`savings` icon in a soft tinted circle, short
encouraging copy ("Bắt đầu để dành cho một điều gì đó cùng nhau" / "Start
saving toward something together"), single prominent "Tạo Dream Jar mới"
CTA leading to §1.3.

### 1.6 Contribution history (extrapolated — required for AC2's "view jar's contents")

The backend exposes a dedicated, paginated `GET /:id/contributions`
endpoint distinct from the jar's aggregate totals — AC2 ("view the jar's
contents") is best satisfied by exposing this, not only the two-partner
aggregate bars. Add a "See all contributions" affordance under the
partner-comparison card in §1.1 opening a simple reverse-chronological
list: per-row contributor avatar/initial, amount, optional note, relative
timestamp. Paginate/lazy-load using the existing `limit`/`offset` query
params (matches the endpoint's own pagination contract). No new visual
component needed — reuse the existing list-row pattern already used for
Love Timeline entries (icon/avatar + title + meta line).

### 1.7 Edit / Archive / Delete jar (extrapolated — required, backend supports all three)

Overflow (`more_vert`) affordance on the jar hero (§1.1) and on each jar
list card (§1.2), opening a simple action sheet:
- **Edit**: reopens §1.3's form pre-filled (`PATCH`, `UpdateDreamJarDto`)
  for name/target/deadline; status changes (e.g. manually marking
  `completed`) are a separate explicit action, not bundled into the edit
  form, to avoid accidental status changes.
- **Archive**: single lightweight confirm ("Archive this jar? It'll move
  out of your active list but nothing is deleted."), non-destructive,
  reversible — no dual-confirmation needed.
- **Delete**: this destroys the shared contribution history contributed by
  *both* partners, which is a more consequential shared/couple action than
  a personal setting change. Recommend **diverging from the simple
  single-confirm sign-out pattern** (`ui_ux_system_memory.md` §11) for
  delete specifically: the confirm dialog must explicitly state that the
  partner's contributions will also be permanently lost (plain-language
  warning, per the same principle §11 already applies to Level-1 data
  loss), styled with the destructive `--red` action button and a text
  cancel button. Flag to Product Owner/Tech Lead: decide whether deletion
  additionally needs partner notification (e.g. reuse the existing "Dream
  Jar milestone" Notifications-screen category/tag to add a "jar deleted/
  archived" info-tier entry) — this app already has real-time
  partner-visible events for jar milestones, so a delete/archive event
  fits the same existing notification taxonomy rather than needing new
  UI. Not a hard blocker for the story, but should not ship silently
  without at least this decision being made explicitly.

### 1.8 Unpaired-user access (AC3)

No bespoke per-screen check needed. Per the design source's own chrome
rules (`ui_ux_system_memory.md` §4), the 5-tab main app shell — including
the **money** tab that hosts Dream Jar — only renders post-pairing; the
entire pre-pairing flow is the chromeless onboarding stack
(splash→...→paired). Dream Jar should rely on this existing global
pairing gate rather than adding its own "are you paired?" check or empty
state; an unpaired user simply never reaches a screen with a Dream Jar
entry point. Tech Lead should confirm the app-shell/router-level guard
(likely resolved alongside STORY-005 Pairing) is what actually enforces
this, not a per-feature check duplicated across every epic-2+ screen.

## 2. Responsive Behavior

- All screens in this spec follow the existing single-column, one-thumb
  layout already used throughout the prototype (primary actions live in
  the bottom ~30% of the viewport per `ui_ux_system_memory.md` §1);
  nothing here introduces a new layout pattern.
- Jar list (§1.2) is a simple vertical list on all supported phone widths;
  no grid/multi-column variant is needed at phone breakpoints already in
  scope for this requirement (no tablet breakpoint is in scope per
  `req_master.md`).
- The hero SVG jar illustration (§1.1) has a fixed intrinsic aspect ratio
  (`148x207` in the source) — scale it proportionally within the hero
  card's available width rather than stretching; keep the card's
  horizontal padding constant across supported device widths so the jar
  stays centered.
- Quick-add row (3 or 4 tiles) uses equal-flex tiles (`flex:1` per tile in
  the source) so it reflows correctly on narrower phones without
  introducing horizontal scroll; if the 4th "custom" tile (§1.4) is
  approved, re-check tile label legibility at the smallest supported
  phone width (this is the one net-new layout risk in this spec — 4 equal
  tiles is tighter than the mockup's 3).
- Platform adaptation (iOS vs Material) for all interactive controls in
  this story (primary CTAs, sheet chrome, date picker) reuses the existing
  4-named-adaptive-widget pattern from STORY-001/System UX memory §3 — no
  new adaptive widget is introduced by this story.

## 3. Accessibility Requirements

- The animated SVG jar fill is decorative/redundant with the text stack
  above/below it (`jarAmount`/`jarTargetAmount`/`jarPct` are already
  rendered as real text) — mark the SVG as decorative to assistive
  technology (exclude from the accessibility tree) rather than exposing
  its raw path/gradient nodes; all jar-progress information must be
  available via the text, not only visually via fill height.
- Quick-add tiles must expose full accessible labels, not the abbreviated
  visual label — e.g. "Add 100,000 VND to the jar", not "+100k" read
  literally by a screen reader.
- The partner-comparison bar chart (§1.1) already has a full plain-language
  text line ("Minh is 460k ahead...") in the mockup — keep this mandatory
  as the accessible equivalent of the bar-height comparison, not optional
  decorative copy; each individual bar/avatar column also needs an
  accessible label combining the partner's name and their amount (the
  visual layout already separates these into a mono amount + name label,
  so this is mostly ensuring they're grouped as one accessible node per
  partner, not left as two disconnected text fragments).
- All interactive controls (quick-add tiles, New/Edit/Archive/Delete
  actions, list-card rows) must meet the existing minimum tap target
  tokens (44pt iOS / 48dp Material per `ui_ux_system_memory.md` §2)
  already established for this app — no exception for the smaller
  quick-add tiles.
- Text-on-gradient contrast: the hero card's white text sits on a
  multi-stop purple→teal gradient background. Verify contrast against the
  gradient's lightest sampled region meets WCAG AA (4.5:1 for body-size
  text, 3:1 for the large 32pt amount display) — the existing
  `text-shadow` is a helpful visual aid but must not be relied on as the
  sole contrast mechanism; if any gradient region fails, add a subtle
  dark scrim behind the text block rather than changing the gradient
  itself.
- Respect the OS "reduce motion" accessibility setting for this screen's
  ambient decorative animations (`breathe`, `drift`, `bob`, `popIn`) —
  disable or substantially simplify them when reduce-motion is enabled,
  while keeping the informational content (amount, percentage, progress)
  fully intact. This is a new standing recommendation not yet captured
  elsewhere in the UX system memory; worth adding there once confirmed by
  Tech Lead as a general cross-story pattern, since the same ambient
  animation vocabulary (`ui_ux_system_memory.md` §2) recurs on many
  screens.
- Delete-jar confirm dialog (§1.7) must trap focus while open and return
  focus to the triggering control on cancel, matching the existing
  destructive-dialog a11y standard already set in
  `ui_ux_system_memory.md` §11.
- Numeric input fields (target amount, custom contribution amount) must
  use a numeric-only keyboard type and announce the currency unit (VND)
  as part of the field's accessible label, not only as adjacent visual
  text.

## 4. Reused Components / Design-System Elements

- Design tokens: full platform×theme token set from STORY-001 (`--r-card`,
  `--r-sheet`, `--r-btn`, `--shadow`, `--grad-hot`, `--mint`/`--pink`
  accent roles) — no new tokens needed.
- Adaptive primary-action button pattern (full-width pill iOS / filled+FAB
  Material) from the existing Shared Expenses precedent
  (`ui_ux_system_memory.md` §3) — reused for the create-jar CTA and
  quick-add custom-amount confirm.
- List-row pattern from Love Timeline entries — reused for contribution
  history (§1.6) and jar list cards (§1.2).
- Destructive single-confirm dialog pattern from STORY-003 auth sign-out
  (`ui_ux_system_memory.md` §11) — reused (with the additional
  partner-data-loss warning copy noted in §1.7) for jar deletion.
- Notification taxonomy: existing "Dream Jar milestone" Info-tier
  notification entry (Notifications screen) — reused/extended, not
  reinvented, if Product Owner approves a delete/archive notification per
  §1.7.
- Bottom-sheet chrome (`--r-sheet`) — reused for create/edit-jar forms and
  the optional custom-amount sheet.

## 5. Summary of Flags for Downstream Roles

1. **Product Owner**: rewrite `story_master.md`'s User Story/AC wording
   from "dream/wish text entries" to "monetary contributions toward a
   shared savings goal" (§0.1) — the underlying feature this spec designs
   for is a savings jar, not a wish list, and the AC wording currently
   describes a feature this backend module does not implement.
2. **Product Owner**: confirm/deny the epic-4 vs epic-5 categorization
   mismatch (§0.1, low priority, no UX impact).
3. **Product Owner**: confirm whether a 4th custom-amount quick-add tile
   (§1.1/§1.4) is in scope for v1, or whether the 3-preset-only design is
   a deliberate constraint.
4. **Product Owner**: confirm default-VND-only, no currency selector, for
   v1 (§1.3).
5. **Product Owner + Tech Lead**: decide whether jar delete/archive should
   trigger a partner-visible notification via the existing notification
   taxonomy (§1.7).
6. **Tech Lead**: resolve R3/Level-2-encryption contract gap for Dream Jar
   before coding-plan — decide between treating it as de facto Level 3 or
   scoping a partial client-side encryption layer limited to
   name/note fields only (§0.2). This is the same escalation the story's
   own "Open Items For Downstream Roles" section already asked for; this
   spec adds the concrete contract-gap detail needed to actually resolve
   it.
7. **Tech Lead**: confirm the realtime/refresh mechanism for jar and
   contribution updates to appear on the partner's device (§0.3) — use
   STORY-004's output if ready, else pull-to-refresh/refresh-on-focus
   fallback.
8. **Tech Lead**: confirm the app-shell pairing gate (likely from
   STORY-005) is what enforces AC3, rather than a per-feature check
   (§1.8).
