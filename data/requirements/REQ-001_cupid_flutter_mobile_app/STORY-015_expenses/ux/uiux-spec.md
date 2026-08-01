# UX Spec: STORY-015 Epic-5 — Chi Tiêu Chung (Shared Expenses)

Design reference: `cupid-mobile-design/Cupid Screens.dc.html`, screen id
`expense` (full history/detail screen, lines ~819-863) reached from the
`jar` screen's "Chi tiêu chung / Shared expenses" summary card
(`goExpense`, lines ~809-813). Both screens sit under the shared **Money**
bottom-tab (`money`, icon `savings`), which per the design source's own
`NO_TABS`/chrome rules only exists in the post-pairing 5-tab main-app shell.

## 1. Screen Inventory (existing design source, reused as-is)

- **Money tab home = `jar` screen** (Dream Jar, out of this story's scope
  except as the entry point). It carries a "Chi tiêu chung / Shared
  expenses" summary card: category icon, this-month total + item count,
  chevron affordance. Tapping it (`goExpense`) drills into `expense`.
- **`expense` screen** (this story): monthly total header + vs-last-month
  delta, 7-bar mini chart, category filter chips (`Tất cả/All` selected by
  default, plus category chips e.g. Food/Date/Travel), itemized list
  (icon, title, `who · date`, amount in `Roboto Mono`), "See all N items"
  footer, and a platform-adaptive add action (§3 of system UX memory:
  Material FAB bottom-right vs. iOS full-width primary CTA "Ghi một
  khoản / Log an expense").
- **New (not in design source): Add-Expense bottom sheet.** No add-expense
  form screen exists in `Cupid Screens.dc.html` — only the entry-point
  button/FAB is designed. This spec defines the sheet in §3 below,
  reusing existing tokens only (`--r-sheet`, `--surf`, `popIn` animation,
  drag-handle affordance already used for the design tool's own screen
  picker) rather than inventing new visual language.

## 2. Flow Map

```
Money tab (jar, post-pairing only)
  -> tap "Chi tiêu chung" card -> expense (history screen)
       -> tap category chip -> filtered list (client-side filter, no
          new query; same Drift-backed dataset)
       -> tap "See all N items" -> full paginated history (see §4, paging
          note per system architecture memory line 76: "must be paged
          from Drift, not held whole in bloc state")
       -> tap add action (FAB / full-width CTA) -> Add-Expense sheet (§3)
            -> Save (online) -> sheet closes, list refreshes at top
            -> Save (offline) -> fail-fast inline error + Retry, sheet
               stays open (§5)
  -> direct/deep-link access while unpaired -> Pairing-Required gate,
     not the expense screen (§6)
```

## 3. Add Expense Flow (AC1)

- Entry point unchanged from design source: Android renders a FAB
  (bottom-right, `expense` screen), iOS renders the existing full-width
  "Ghi một khoản / Log an expense" pill CTA. Same widget instance backing
  both per system UX memory §3's FAB-vs-full-width-CTA precedent — do not
  add a second, separately-styled entry point.
- Tapping the action opens an **Add-Expense bottom sheet** (`--r-sheet`
  top corners, drag handle, `popIn .3s ease-out`, dismiss via drag-down,
  backdrop tap, or explicit close `X` — same interaction shape as the
  design source's own bottom-sheet chrome).
- Sheet fields (minimal, matches what the existing list item already
  displays — title, amount, who, date, category icon — no field not
  already represented in the design source's expense list item):
  - **Amount** — numeric input, VND, `Roboto Mono` per existing amount
    styling; required.
  - **Title/description** — short free-text label; required.
  - **Category** — chip picker, reusing the exact filter-chip visual
    style from `expense` screen (icon + label, pill, `--grad-hot` when
    selected). The concrete category enum/icon mapping is a backend
    contract question — see §7 Open Items; this spec does not invent new
    categories beyond what the contract exposes.
  - **Paid by** — attribution-only toggle between the two partners
    (mirrors the existing list item's `who` field, e.g. "Minh"/"Linh").
    **This is a record-keeping label, not a split/settlement
    calculator** — no balance, no "who owes whom" copy, no percentage
    split UI. Do not reuse Dream Jar's competitive-comparison copy
    pattern ("Minh is 460k ahead...") here; that pattern is specific to
    Dream Jar's contribution-race framing and is out of scope for
    expenses per this story's explicit guardrail (no new
    settlement/financial capability invented client-side).
  - **Date** — defaults to today, editable via existing date-picker
    convention; cannot be a future date.
- **Save button state**: enabled once amount + title + category are
  filled. Behavior differs online vs. offline — see §5 (this is the
  single most important interaction rule in this story; do not treat
  Save as a simple form submit without reading §5).
- On successful save: sheet dismisses, new entry appears at the top of
  the history list (list re-fetches/re-renders from the now-updated
  Drift cache), monthly total and chart update to match.

## 4. Shared Expense History View (AC2)

- The `expense` screen list is **shared, not per-user** — both partners
  see the identical dataset (server-authoritative, Drift is a
  read-through cache per ADR-007). There is no "my expenses" vs.
  "partner's expenses" filter; category chips filter by category only,
  never by which partner logged the entry.
- List items keep the design source's existing shape: category icon,
  title, `who · date` caption, amount. `who` is the same attribution
  label set in §3's "Paid by" field, always visible on every row so
  either partner can see who logged what.
- Pagination: per system architecture memory (line 76), long history
  must be paged from Drift, not held whole in bloc/widget state. The
  existing "See all N items" footer is the entry point into the paged
  full list; the summary card's own 5-item preview (as in the design
  source) stays a fixed-size preview, not a live paged view.

## 5. Offline Read / Connectivity States (AC3)

Per ADR-007 (system architecture memory §"ADR-007"): Drift is a
**read-through, server-authoritative cache** for expenses, and there is
**no offline write/outbox queue in v1** — "offline writes fail fast with
an explicit retry affordance," not queued. The UI must make both halves
of this bound visible and must not imply a queuing capability that does
not exist.

- **Reading history offline (works, per AC3):**
  - The `expense` screen renders normally from the Drift cache with no
    special empty/error state, provided at least one successful sync has
    happened previously (this is the same bar STORY-007 chat's history
    view will need — see Open Items §7 for the shared pattern
    recommendation).
  - Add a small, secondary-style **freshness caption** under the monthly
    summary header (e.g. "Cập nhật lần cuối 2 phút trước" / "Last updated
    2 min ago"), visible whenever the device is currently offline, so the
    couple knows they're looking at a cached snapshot rather than a live
    total. This caption is hidden when online and freshly synced; it is
    not an error state, just a quiet provenance signal.
  - **Never-synced empty state** (device has no cached data yet, e.g.
    first app install used offline before any sync completes): show a
    distinct placeholder — "Kết nối mạng để tải chi tiêu chung lần đầu" /
    "Connect to load shared expenses for the first time" — instead of the
    ordinary "no expenses yet" empty state. These two empty states must
    not share copy: one says "you have no data cached," the other would
    say "you have zero expenses," and conflating them misleads a couple
    who actually has history waiting to sync.
- **Writing (adding an expense) offline (AC1 still requires connectivity
  to write):**
  - The Add-Expense sheet itself is **not disabled** when offline —
    connectivity can change while the user is mid-form, and blocking
    entry preemptively would discard typed input on a false negative. If
    the device is currently offline when the sheet opens, show a
    non-blocking inline banner at the top of the sheet: "Cần kết nối mạng
    để lưu khoản chi này" / "Saving requires a connection" — informational,
    not a hard stop.
  - On tapping Save while offline (or if connectivity drops mid-submit):
    fail fast — do not spin indefinitely, do not optimistically insert
    the row into the list, do not silently hold it for "later sync."
    Show an inline error state in the sheet ("Không có kết nối — thử lại"
    / "No connection — try again") with an explicit **Retry** button that
    re-attempts the same submission; the sheet stays open with the
    user's entered data intact so nothing is lost, but nothing is queued
    behind the scenes either.
  - Do not use "queued"/"will sync later" wording anywhere in this flow —
    that would imply an outbox this story explicitly does not have (out
    of scope per story_master.md / ADR-007).

## 6. Unpaired Access Denial (AC4)

- Structural default: per system UX memory §4, the 5-tab bottom nav
  (including the `money` tab that fronts Dream Jar + Shared Expenses)
  only exists in the post-pairing main-app shell; unpaired users are
  still in the chromeless onboarding/pairing flow (`welcome` through
  `contract`/`vow`) and have no tab bar to reach it from in the first
  place. This covers the common case with no new screen needed.
- Defensive gate for edge cases (deep link, stale nav state after an
  unpair event, restored session mid-pairing-flow): if the app ever
  attempts to render the `expense` (or `jar`) screen for a user whose
  pairing state is not active, show a dedicated **Pairing-Required**
  gate screen instead of the feature — not a generic error/404 and not a
  silently-empty list. Content: short explanatory copy ("Tính năng này
  chỉ dành cho các cặp đã ghép đôi" / "This feature is only available to
  paired couples") plus a single primary action routing into the
  existing pairing flow (`invite`/`joincode`, matching whichever entry
  the user's account already has in progress). This mirrors the
  splash-as-auth-check-gate precedent (system UX memory §11) but keys off
  pairing state instead of auth state — same shape, different guard
  condition. See §7 for the recommendation to promote this as a shared
  pattern rather than a one-off for this story.

## 7. Accessibility Notes

- Add-Expense sheet must trap focus while open and return focus to the
  triggering FAB/CTA on dismiss (same standing rule as system UX memory
  §11's destructive-confirm-dialog accessibility note — this sheet isn't
  destructive, but the focus-trap/return-focus mechanics are the same
  general modal requirement).
- Category chips and the "Paid by" toggle must expose selected state to
  assistive tech (not color-only — the design source's selected-chip
  style already uses a filled `--grad-hot` background + implied weight
  change, which is fine, but ensure the semantic "selected" state is
  also exposed, e.g. via a toggle/radio role).
- The offline freshness caption and the never-synced empty-state message
  must not be conveyed by icon/color alone (e.g. a gray dot) — always
  pair with the text copy specified in §5 so screen readers get the same
  signal sighted users do.
- Amount field must use a numeric keyboard input type and announce the
  currency unit (₫/VND) as part of the accessible label, not only as
  trailing visual text.

## 8. Platform Adaptation

- Add action: Material FAB (bottom-right) vs. iOS full-width primary CTA
  — existing design-source precedent, reused as-is (system UX memory §3).
- Add-Expense sheet: standard platform bottom-sheet chrome (`--r-sheet`
  radius both platforms per token table; iOS uses its blur/soft-shadow
  depth convention, Android uses tonal elevation, per system UX memory §2
  structural tokens).
- Tap targets: category chips and the Retry button must meet the
  existing 44pt(iOS)/48dp(Android) minimum per system UX memory §2.

## 9. Open Items For Downstream Roles

- **Tech Lead — `expenses` contract fields (blocks coding-plan
  precision, does not block this UX spec):** confirm the exact category
  enum/icon set and whether "paid by" is a first-class contract field or
  a client-side-only label, per story_master.md's own open item. This
  spec's §3 category chips and "Paid by" toggle are designed to be
  data-driven from whatever the contract actually returns, not a fixed
  list invented here.
- **Tech Lead — never-synced vs. empty-list state detection:** confirm
  the client can distinguish "Drift has zero rows because nothing has
  ever synced" from "Drift has zero rows because the couple truly has no
  expenses yet" (e.g. via a last-sync timestamp/flag), since §5 requires
  different copy for each. If no such signal exists, flag back to this
  story rather than silently collapsing the two states.
- **System UX memory update recommended, out of this story's write
  scope:** this story's `WriteScope` covers only
  `STORY-015_expenses/ux/**`, so `data/ux/system/ui_ux_system_memory.md`
  is intentionally left untouched here (same precedent as STORY-003's
  spec). Two patterns introduced in this spec are reusable beyond
  expenses and worth promoting into a new system-memory section once
  this story clears review:
  1. **Drift read-through / offline-write-fail-fast pattern** (§5): the
     freshness-caption + never-synced-empty-state + fail-fast-with-retry
     (never "queued") vocabulary applies verbatim to any other
     Drift-backed, no-outbox domain — concretely STORY-007 chat (which
     has the identical "no local queued/offline message send" constraint
     per its story_master.md AC4) and any future Love Timeline UX.
  2. **Pairing-Required gate pattern** (§6): the same
     defensive-gate-keyed-on-pairing-state shape (mirroring the
     auth-check-gate precedent in §11) applies to any paired-only
     feature reached via deep link or stale nav state — chat, Dream Jar,
     and Love Timeline all share this exact gating need.

## Completion

UX_COMPLETE: YES

All four acceptance criteria have a corresponding UX specification: AC1
(§3, Add Expense Flow), AC2 (§4, Shared Expense History View), AC3 (§5,
Offline Read / Connectivity States — explicitly bounded to match ADR-007's
no-outbox constraint), AC4 (§6, Unpaired Access Denial). No new `expenses`
endpoint or settlement/split capability is implied anywhere in this spec.
