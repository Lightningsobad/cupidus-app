# UX Spec: STORY-061 Dream Jar List (`jarlist`) Design Fidelity Hardening

## 0. Design-reference confirmation (AC9 discipline)

`jarlist` was re-confirmed visually before writing this spec, reusing
STORY-059's already-produced evidence pair rather than re-deriving from
scratch (same render, same discipline):

- `design-reference-jarlist-android.png` — draws the jar collection, the
  "+ Tạo hũ mới" CTA, and the 5-tab bottom bar with "Ví chung" active. This is
  the Dream Jar list, confirmed by content, not by id match alone.
- `implemented-jarlist-ready-emulator-5560.png` — the on-device populated
  state (`DreamJarListReady`, 3 jars), the surface AC1-AC8 target.

Both images inspected directly for this spec (paths under
`STORY-059_cupid_header_action_slot_sizing_hardening/visual-fidelity/`). Every
measurement/copy string below is read off the design-reference image, not
inferred from `visual-fidelity-report.md`'s prose alone — the report's table
is used for out-of-scope-row cross-checking only (row 8, confirmed correctly
excluded).

Current code inspected: `dream_jar_list_screen.dart`, `dream_jar_list_cubit.dart`,
`dream_jar.dart`, `dream_jar_hero_card.dart`, `dream_jar_illustration.dart`,
`app_shell.dart`, `cupid_tab_bar.dart`, `cupid_header.dart`,
`cupid_primary_button.dart`, `cupid_color_tokens.dart`, `dream_jar_palette.dart`,
`cupid_icons.dart`, `app_vi.arb`/`app_en.arb`.

## 1. Screen composition, top to bottom (ready state)

1. `CupidHeader` — title only, no back affordance (AC10, unchanged).
2. Summary pill (AC1) — new.
3. Jar card list (AC2/AC3/AC4) — restructured cards, active-status jars only.
4. "+ Tạo hũ mới" CTA (AC7).
5. Completed-jars row (AC5) — new, only when completed jars exist.
6. Shell tab bar (AC8) — 5 tabs, "Ví chung" active. Shared/shell-level; see §7.

## 2. AC1 — Summary pill

Full-width pill directly under the header, above the jar cards.

- **Copy**: `"Tổng cả nhà đang để dành {amount} trong {count} cái hũ"` where
  `amount = DreamJarAmountFormat.vnd(totalSaved)` and `count` = number of jars
  rendered as cards (§4 — active-status, non-archived, i.e. the same jars
  AC5's split leaves in the main list).
  - `totalSaved` = sum of `currentAmount` over those same active-status jars
    only. Do **not** include completed jars' `currentAmount` — the copy reads
    "đang để dành" (currently saving toward), and completed jars move out of
    the ongoing-saving list into the AC5 summary row. Checked against the
    design's own numbers: 3.900.000 + 2.400.000 + 850.000 = 7.150.000, which
    is exactly the pill's example total for its 3 (all-active) example jars —
    confirms the active-only sum is the right source, not a repository-wide
    sum.
  - New l10n key needed, e.g. `dream_jar_list_summary_pill`, ARB shape
    matching the existing `dream_jar_remaining`/`dream_jar_quick_add_semantic_label`
    parameterized-placeholder precedent (`amount: String`, `count: int`).
  - The design renders the amount substring in a heavier weight than the
    surrounding sentence. Recommended approach: keep the ARB message as one
    atomic translatable sentence (do not split the sentence into
    pre/post-amount ARB fragments — that breaks for languages where the
    number isn't mid-sentence), and if bold emphasis is wanted, build it via
    `Text.rich` splitting the *already-localized* rendered string on the
    known `amount` substring (safe: it's a formatted currency figure, always
    a unique substring). If that's judged too fragile for this hardening
    story, a single-weight `Text` (no split) is an acceptable fallback — AC1
    requires the format/content to match, not the inline bold treatment.
- **Layout**: leading circular badge (~32-36dp) containing `CupidIcons.savings`
  (already used for the Home "Money" entry card — same glyph, same semantic
  role: savings/piggy-bank), tinted with `colors.colorMint` at reduced alpha
  (mirrors the `_StatusBadge` `withValues(alpha: 0.16)` convention already in
  this file), 8-12dp gap, then the sentence in `type.caption` or `type.body`
  (pick whichever fits the pill's height without wrapping past 2 lines; design
  reads as `caption`-scale). Text color `colors.colorText`, with the bold
  span (if implemented) unchanged color, just heavier weight.
- **Container**: full width minus the screen's `CupidSpacing.lg` side
  padding, rounded pill/large-radius container (matches `radiusButton` pill
  shape or `radiusCard`, whichever the design's corner curvature reads closer
  to — visually a very rounded rectangle, not a hard corner). Background is a
  low-alpha pink/magenta tint over the surface, not a flat new hex — do not
  introduce a raw color literal (D3/ADR-004, enforced by
  `test/design_system/no_fork_guard_test.dart`); compose from an existing
  token, e.g. `colors.colorAccentPinkDark.withValues(alpha: ~0.12-0.16)`
  layered over `colors.colorSurfaceAlt`, tuned to visual match against the
  reference on-device.
- **Data availability**: confirmed sourced from `DreamJarListReady.jars`
  already in state — no new fetch needed (AC1 says as much).

## 3. AC2 — Jar illustration thumbnail + per-jar leading glyph

Two distinct elements per card, both currently absent.

### 3a. Jar illustration thumbnail (leading avatar)

- A colored rounded-rectangle avatar, taller than wide (roughly 52w x
  ~64-68h in the reference, proportioned like a small bottle), placed at the
  **leading edge of the whole card**, vertically spanning the card's content
  block (title through progress bar) — this means `_JarCard`'s current pure
  `Column` layout needs an outer `Row`: `[avatar]` + `[Expanded(Column(title
  row, progress bar, percent/date row, optional badge row))]`.
- Background tint rotates through 3 colors, one per jar, in the reference:
  mint/teal, lilac/purple, deep maroon/plum. `DreamJar` carries no
  category/type field (confirmed — `dream_jar.dart` has none), so the tint
  cannot be data-driven by content; it must be a deterministic 3-slot
  rotation. Recommend keying off `jar.id.hashCode.abs() % 3` (stable per jar
  across list-order changes and refreshes) rather than list index (which
  would reshuffle colors whenever a jar completes and drops out of this
  list). Use 3 existing tokens, no new raw hex: `colors.colorMint`,
  `colors.colorAccentLilac`, and `colors.colorAccentPinkDark` (closest
  existing token to the reference's deep maroon/plum third slot — an exact
  hue match isn't available in the current token set and none should be
  invented for this).
- Illustration content inside the avatar: a small jar/bottle silhouette
  (lid + collar + glass body), not the full animated
  `DreamJarIllustration`/`DreamJarIllustrationPainter` used on the detail
  hero card — that widget is a large (148x207), continuously-animated
  glass-and-liquid painting with two looping heart floaters; reusing it
  unscaled-down-in-behavior for every list-card thumbnail would run N
  simultaneous animation controllers for a decorative list glyph. Tech Lead
  call on build approach, two reasonable options:
  - **(a)** a new lightweight *static* (non-animated) jar-silhouette
    painter/shape, reusing `DreamJarPalette`'s lid/collar/glass geometry
    constants at small scale with no liquid fill/hearts — closer visual
    fidelity to the reference, matches this story's whole purpose.
    Recommended if build cost is acceptable.
  - **(b)** fall back to `CupidIcons.savings` (or another existing generic
    glyph) centered in the tinted avatar if a new painter is judged
    out-of-budget for this hardening pass — coarser match, but avoids new
    asset work. Flagging as an explicit fidelity trade-off, not silently
    approving it.
  - Do not reuse the full `DreamJarIllustration` widget at a shrunk
    `SizedBox` — cropping/scaling its `168` viewBox into a `~64` box distorts
    proportions and keeps the animation cost.
- `ExcludeSemantics` (matches the existing decorative-illustration precedent
  in `_JarCard`'s progress bar and `_EmptyJarsView`'s jar emoji).

### 3b. Per-jar leading glyph (next to the jar name)

- A small glyph immediately before the jar name text, inside the title row
  (not the avatar). The reference uses content-specific emoji per example jar
  (plane for "Du lịch Đà Lạt", rings for "Nhẫn đôi", house for "Dọn về ở
  chung") — these are placeholder glyphs tied to the mockup's 3 sample jar
  names, not data the app has (no category field, confirmed §3a). Do not
  attempt name-text sniffing/keyword-matching to fake category detection.
- Recommendation: use one consistent generic glyph for this slot across all
  cards — `CupidIcons.savings` (same semantic role as the summary pill icon)
  or, if visually too repetitive next to the avatar's own jar shape,
  `CupidIcons.favorite` (already used as the detail hero's "remaining" pill
  icon, reads as "something you're saving for/toward"). Either is an
  acceptable, honest simplification for AC2's "a per-jar leading glyph next
  to the jar name" — it satisfies the element-presence requirement without
  fabricating semantics the data doesn't support.
- Sizing: small, inline with the title text baseline, `~16-18dp`, `sm` gap
  before the name text, tint `colors.colorTextMuted` or `colors.colorText`
  (reference reads closer to full-text-color than muted).

## 4. AC3 — Deadline row

- Renders in the same row as the percent text, right-aligned (percent stays
  left-aligned, matching current `progressPercent%` position — this row
  becomes `Row(children: [percentText, Spacer(), deadlineText])`).
- Format: `dd/MM/yyyy`, zero-padded (reference shows `30/09/2026`,
  `14/02/2027`, `01/06/2027` — the latter two prove zero-padding, since day
  values 14/01 need it to read correctly). **Do not** use
  `DateFormat.yMd(locale)` (the pattern `create_dream_jar_sheet.dart` already
  uses elsewhere) — that's a locale-sensitive skeleton and `vi_VN`'s `yMd`
  does not zero-pad, so it would render `1/6/2027` instead of `01/06/2027`.
  Use an explicit literal pattern instead: `DateFormat('dd/MM/yyyy')` (locale
  argument omitted/irrelevant since the pattern is fully literal).
- `jar.deadline` is nullable (`DateTime?`). When null, omit the deadline row
  entirely for that card (render just the percent, no trailing text/spacer) —
  graceful degradation, not a placeholder dash, consistent with this
  screen's existing "only render what has data" pattern (e.g. the archived
  badge branch).
- Typography: `type.caption`, `colors.colorTextMuted` — matches the existing
  percent/amount caption row style already in `_JarCard`.

## 5. AC4 — "Đang xem" ("currently viewing") badge

Applies to exactly one card in the reference — the first one (`Du lịch Đà
Lạt`) — and is visually two things together:

1. **Card-level treatment**: a ~2px `colors.colorAccentPink` border ring
   around the whole card (the other cards have no border / same border as
   today), plus a very subtle differentiation in fill versus the other cards
   (reference reads as the same `colors.colorSurface` base, the border is the
   primary signal — do not invent a second background token for this).
2. **Badge chip**: its own row below the percent/deadline row (not
   top-right where the old completed/archived `_StatusBadge` used to sit —
   this design has no top-right badge at all now), left-aligned:
   `CupidIcons.checkCircle` glyph + `"Đang xem"` text, inside a pill chip with
   `colors.colorAccentPink` border and `colors.colorAccentPink.withValues(alpha:
   0.16)` fill (same alpha convention as the existing `_StatusBadge`), text/
   icon colored `colors.colorAccentPink`.

**Which jar is "currently viewing"?** No app state for this exists today —
searched the repository, cubit, and detail screen; there is no persisted
"current"/"selected"/"last-viewed" jar id anywhere in this codebase. The
badge cannot be wired to real navigation history without adding new state
this story doesn't otherwise need. Recommended, explicit scope decision:
treat the **first jar in `DreamJarListReady.jars` order** (i.e. as returned
by `fetchJars()`, same order the cards already render in) as "currently
viewing" and apply the badge/border to that single card only. This is
positional, not behavior-tracked — matches what's visually checkable against
the reference (card 1 has it, cards 2-3 don't) without inventing new
cross-screen state. Tech Lead should confirm this reading before coding-plan
lock-in; flagging it here rather than leaving it ambiguous because AC4's
literal text ("the active/currently-viewed jar card") could otherwise be
mis-read as requiring new selection-tracking infrastructure, which is out of
this hardening story's remediation scope.

New l10n key needed: `dream_jar_list_currently_viewing_badge` = `"Đang xem"`.

## 6. AC5 — Completed-jars row

New row/section below the "+ Tạo hũ mới" CTA, only rendered when at least
one completed jar exists (no zero-count variant in the reference — omit the
row entirely rather than showing "0 cái").

- **Behavior change this AC requires in the cubit**: today
  `DreamJarListCubit._fetch()` keeps `active` AND `completed` status jars in
  the *same* `DreamJarListReady.jars` list (only `archived` is filtered),
  which is why completed jars currently render inline as cards with the
  `Hoàn thành` `_StatusBadge`. AC5 needs these split: cards list = active
  jars only (feeds §2's `count`/`totalSaved` too), completed jars go into
  this row instead. Cubit/state shape change, flagging for Tech Lead's
  coding-plan, not just a widget-level change.
- **Content**: leading icon (reference reads as a clock/history glyph — no
  exact match exists in `cupid_icons.dart` today; closest existing option is
  `CupidIcons.schedule`, a plain clock, not the "history" rotate-arrow
  variant the reference draws. Same sourcing constraint as this screen's
  existing empty-state jar emoji precedent — either accept `schedule` as the
  close-enough existing glyph, or Tech Lead sources a new icon codepoint from
  the bundled Material Symbols font following the `_galleryTabIcon`
  precedent in `app_shell.dart`, §7). Title `"Hũ đã hoàn thành"` (new l10n
  key `dream_jar_list_completed_row_title`), subtitle
  `"{count} cái · {names}"` where `names` is the completed jars' names joined
  `", "` (new l10n key `dream_jar_list_completed_row_subtitle`, params
  `count: int`, `names: String`; subtitle `maxLines: 1` with ellipsis
  overflow for when many completed jars exist — the reference's compact
  one-line treatment doesn't have room to always list every name). Trailing
  `CupidIcons.chevronRight`.
- **Container**: same `radiusCard`/`colorSurface` card treatment as a jar
  card, shorter (single row height, no progress bar).
- **Tap target / destination — open question for Tech Lead**: the reference
  draws a chevron implying further navigation, but no completed-jars list or
  detail destination exists in this codebase today. AC5's literal text only
  requires the row to render, matching the reference — it does not require a
  working destination. Recommend keeping this hardening story's scope to the
  row's presence/copy/layout; if Tech Lead judges a destination in-scope
  without new-screen cost (e.g., opening `DreamJarDetailScreen` for the first
  completed jar as a minimal placeholder target), that's acceptable, but
  building a new dedicated completed-jars list screen should be treated as
  its own story, not folded into this one silently.

## 7. AC8 — Shell tab-bar shape (shared/shell-level — blast radius)

**This is shell-level, not `jarlist`-scoped, and changing it will visibly
affect every other tab, not just Dream Jar list.** Confirmed by direct
inspection of `app_shell.dart`:

- `AppShell` currently renders exactly 3 `CupidTabBarItem`s (Home / Chat*
  [only when unlocked] / Gallery) via `CupidTabBar`, plus a separate
  `FloatingActionButton` (pink circle, person icon) for account-hub entry —
  this FAB is the thing STORY-059's report footnoted as "easy to misread on
  this exact screen" (it's not a `CupidHeader` action). This 3-tab-plus-FAB
  shape is the literal thing the design's 5-tab bar replaces.
- Design's 5 destinations, in order: **Nhà** (home), **Trò chuyện** (chat),
  **Pet**, **Ví chung** (this jar-list screen's tab, active/pink-pill in the
  Material variant per `cupid_tab_bar.dart`'s existing active-state styling),
  **Tôi** (account/me — currently the separate FAB's destination, `MeScreen`
  via `_openAccountHub`).
- Consequence: to satisfy AC8, `AppShell`'s tab list construction and the
  `Scaffold.floatingActionButton` need to change together — `MeScreen` moves
  from FAB-triggered push to a 5th tab body (`safeIndex`-selected, same
  pattern already used for Home/Chat/Gallery), and a **Pet** tab needs a
  body. `AppShell`'s own dartdoc already flags this precisely: "`CupidTabBar`
  exists but stays otherwise unconsumed for the account/pet/money
  destinations — a separate Scrum Master routing item" (STORY-016 DEC-4).
  Whether a Pet screen/feature exists yet to serve as that tab's body is a
  Tech Lead build-scope question, not a UX one — flagging it here because it
  gates whether AC8 is fully buildable in this story or needs its own
  shell-tab-body placeholder decision.
- Chat's existing conditional slot (`isUnlocked` gating, which shifts every
  later tab's index) must be preserved under the new 5-tab set — the
  `chatIndex`/`safeIndex` logic in `_AppShellState.build` needs to account
  for 5 possible slots instead of 3, keeping Ví chung and Tôi correctly
  addressable whether or not Chat currently occupies a slot.
- This tab bar is also what every *other* screen mounted under `AppShell`
  sees (Home, Chat, Gallery, and whatever Pet/Ví chung become) — a change
  here is not isolable to `dream_jar_list_screen.dart`'s write scope the way
  AC1-AC7 are. **Recommend Tech Lead treat AC8 as its own coding-plan
  section scoped to `app_shell.dart` (and `cupid_tab_bar.dart` only if the
  5-item bar needs new capability beyond what it already supports — current
  read is it doesn't; `CupidTabBar` already takes an arbitrary `items` list),
  explicitly confirming regression coverage for Home/Chat/Gallery's existing
  behavior, not just Dream Jar list's tab highlight.**
- No new l10n keys strictly required for tab labels if `context.viEn(...)`
  inline literals (the existing pattern for the other 3 tab labels in
  `app_shell.dart`) are reused for Pet/Ví chung/Tôi — Tech Lead may prefer
  promoting all 5 to proper ARB keys while touching this file; not an AC8
  requirement either way.

## 8. AC6 / AC7 — Copy fixes (no layout change)

- **AC6**: `app_vi.arb` / `app_en.arb` key `dream_jar_list_title` value
  changes from `"Hũ Ước Mơ"` to `"Các hũ ước mơ"`. No other change — title
  stays in `CupidHeader.title`, same `onBack: null` (AC10).
- **AC7**: `dream_jar_new_jar_cta` value changes from `"Tạo Dream Jar mới"` to
  `"Tạo hũ mới"` (drop the literal `"+"` from the string — see below) plus a
  code change at both call sites
  (`_EmptyJarsView`'s and `_JarListBody`'s `CupidPrimaryButton`) to pass
  `leadingIcon: CupidIcons.add`. `CupidPrimaryButton` already has a
  `leadingIcon` parameter built exactly for this (`cupid_primary_button.dart`
  §"Optional glyph drawn before `label`") — use it rather than baking a `"+"`
  character into the label string, which would double up against the icon if
  someone later also adds `leadingIcon`, and doesn't get the icon's
  proper glyph rendering/sizing (`21px`, `8px` gap, already tuned to this
  exact "+ label" composition per the button's own dartdoc citing the design
  source's CTA block). Visually the rendered result is still "+ Tạo hũ mới",
  matching AC7's literal text — the "+" is an icon, not a character.
  `CupidIcons.add` already exists (`cupid_icons.dart:24`).

## 9. Data notes summary for Tech Lead

- AC1's `totalSaved`/`count` and AC5's completed-jars split both depend on
  the cubit's `_fetch()` no longer merging `active` + `completed` into one
  list (§6). This is the one state-shape change every other AC's numbers
  (AC1's total, AC1's count, the main card list, AC5's row) all read from —
  recommend Tech Lead sequence it first in the coding plan.
- `DreamJar` has no category/type/icon field (§3a/§3b) — AC2's per-jar color
  and glyph are both necessarily presentation-layer rotations/constants, not
  data-driven. Documented above so Tech Lead doesn't go looking for a field
  that isn't there.
- No jar-detail navigation change is implied by anything in this spec —
  tapping a card still opens `DreamJarDetailScreen` exactly as today.

## 10. Out of scope (do not implement)

- Report row 8 (progress amount/percent format+layout — `"X / Y"` +
  percent-on-own-row vs. current `"X trên Y · Z%"`): explicitly excluded by
  `requirements/requirements.md`'s reconciliation note; no PO-owned scope
  decision extends it into this story. Leave `_JarCard`'s existing amount
  line and `dream_jar_of` string untouched.
- Report row 2 (back chevron): AC10, documentation-only, no code change —
  `CupidHeader`'s `onBack: null` for this screen stays as-is.
- Progress-bar fill color per jar: not itemized in any AC; leave
  `_JarCard`'s existing `colors.colorAccentLilac` fill logic untouched unless
  Tech Lead finds it's already accidentally varying (worth a quick sanity
  check against current code during implementation, but not an AC5/AC2
  requirement either way).
