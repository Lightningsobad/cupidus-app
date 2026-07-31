# UX Spec: STORY-012 Epic-4 — Timeline Kỷ Niệm (Love Timeline)

Scope: REQ-001 / STORY-012_timeline
Source of truth: `cupid-mobile-design/Cupid Screens.dc.html`, `isTimeline`
block (screen id `timeline`, dashboard entry point at the "Love Timeline"
card, `goTimeline`). Tokens/components reused from
`STORY-001_design_system/ux/uiux-spec.md` (design-system source of truth for
all color/spacing/typography tokens below — not restated in full here).

## 1. Screens / Flow

Single screen, reached from the dashboard "Love Timeline" card
(`isTimeline` screen id: `timeline`). No separate entry list/detail split —
timeline is one continuous scrollable feed.

1. **Dashboard entry card** (existing dashboard, not part of this story's
   build but confirms entry point): icon `timeline`, label "Love Timeline",
   chevron affordance, navigates to the Timeline screen.
2. **Timeline screen** (`isTimeline`):
   - Header (shared chrome per design system): back chevron (`canBack`),
     title "Love Timeline" (`t_timeline` string, vi/en pair already present
     in source), partner-status chip optional per shared header pattern.
   - **Milestone/progress banner** (top of scroll body): gradient card
     (`linear-gradient(140deg, rgba(255,127,182,.2), rgba(183,140,245,.18))`,
     `--line` border) showing "N days to go" + target date, plus a circular
     progress ring (`conic-gradient`) with percentage label. This banner is
     driven by whatever milestone/day-counter feature computes it — **out of
     scope for this story's data model** (see Open Item 2); treat as a
     read-only display slot fed by an existing/adjacent data source, not a
     field this story's create-entry form writes.
   - **Vertical timeline list**: left-aligned connector line
     (`linear-gradient(180deg, var(--pink), var(--purple), transparent)`,
     2px, positioned at 7px from the content's left edge) with per-entry dot
     markers (16px circle, 3px `var(--bg)` border, color = `t.dot`) sitting
     on the line. Each entry is a card (`var(--r-card)` radius, `var(--surf)`
     background, `var(--shadow)` elevation) containing:
     - Row: leading icon (`t.icon` + `t.iconColor`, 18px), title (14.5px,
       weight 800, flex-grow), trailing date in Roboto Mono 9.5px
       (`var(--tx2)`).
     - Body copy, 12.5px, `var(--tx2)`, 1.5 line-height.
     - Optional photo (`t.hasPhoto`): 112px-tall rounded image slot
       (`var(--r-sm)` radius) below the body text.
     - Optional "auto-added" pill (`t.auto`): small badge,
       `auto_awesome` icon + "auto-added" label, `var(--surf2)` background —
       **flagged in Open Item 2, this story's AC only covers user-created
       entries; do not build the auto-added badge/data path unless Tech Lead
       confirms auto-generated entries are in scope.**
   - **Add-a-memory affordance**: dashed-border pill button
     (1.5px `var(--line)` dash, `var(--r-btn)` radius, 52px tall) at the
     bottom of the list, `add_circle` icon + "Add a memory" label
     (`t.vi`/`t.en`: "Thêm kỷ niệm" / "Add a memory"). Opens the create-entry
     flow (AC1).
3. **Create-entry flow** (not directly in design source — no dedicated
   create screen/sheet is drawn for `isTimeline`; this story's UI must add
   one). Recommend a bottom sheet (`var(--r-sheet)` = 28px radius, per design
   system) rather than a full new screen, consistent with this app's other
   "add" actions being lightweight overlays:
   - Fields: title (required, short text), date (required, defaults to
     today, editable to backdate a memory), body/description (optional,
     multi-line), photo attachment (optional, single photo — reuse the
     `image-slot` picker component already used elsewhere in the design
     source, e.g. onboarding avatar picker).
   - Primary CTA: filled pill button using `--grad-hot` gradient (matches
     other primary CTAs in the source, e.g. gallery unlock button), label
     "Save" / "Lưu".
   - Cancel affordance: standard sheet dismiss (swipe-down / close icon),
     consistent with platform-adaptive bottom-sheet behavior from the design
     system (Section 6 of STORY-001 spec).
   - New entries prepend to the top of the vertical list (chronological,
     newest first, matching the mock data order in the source where the
     most recent date is listed first).

## 2. States

- **Empty state** (no timeline entries yet): not drawn in source. Recommend
  reusing the app's existing empty-state pattern (centered icon + heading +
  supporting copy, matching the structural pattern used for the gallery
  locked state, e.g. `timeline` icon at large size, heading "No memories
  yet" / "Chưa có kỷ niệm nào", body text encouraging the first add), with
  the same dashed "Add a memory" CTA still visible below/in place of the
  empty illustration.
- **Loading/placeholder state**: `sc-for` in source declares
  `hint-placeholder-count="5"` for the timeline list — build with 5 skeleton
  entry cards (shimmer/placeholder blocks matching the real card's
  dimensions) while the initial Drift-cache read or first sync resolves.
- **Offline-with-cache state** (AC3): timeline is readable from the local
  Drift cache after at least one successful sync. Show a small persistent
  "offline — showing saved memories" indicator (reuse the app's existing
  offline/sync-status affordance if one exists from an earlier story; if
  none exists yet, use a thin banner at the top of the scroll body, `--surf2`
  background, `wifi_off` icon, `--tx2` text) rather than silently showing
  stale data with no signal.
- **Offline-no-cache state**: if the Drift cache has never synced
  successfully, show a distinct "can't load your timeline yet — connect to
  the internet" empty/error state rather than reusing the true empty state
  (a user with zero connectivity should not be told "no memories yet" when
  the real answer is "we don't know yet").
- **Offline while attempting to create** (AC3 + ADR-007 no offline write
  queue): the create-entry sheet's Save CTA must be disabled (not silently
  queued) when offline, with inline copy explaining that adding a memory
  needs a connection ("Cần kết nối mạng để thêm kỷ niệm" / "Connect to the
  internet to add a memory"). Do not let the user submit and lose the entry
  — ADR-007 explicitly excludes an offline write/outbox queue for this
  story, so the UI must prevent the write attempt rather than fail silently
  after the fact.
- **Unpaired-user gate** (AC4): no existing shared "unpaired" gate pattern
  was found elsewhere in this requirement's UX artifacts yet (checked
  STORY-001, STORY-003; no STORY-005/pairing UX spec exists at the time of
  this spec). Define here as the reusable pattern: unpaired users must not
  reach the Timeline screen at all — the dashboard entry card itself should
  be hidden or disabled (not just gated after navigation) for an unpaired
  user, matching the principle that this is a couple-scoped feature, not a
  solo one. If STORY-005 (pairing) later defines a shared "requires pairing"
  gate component/copy, this story should adopt that shared pattern instead
  of a bespoke one — flagged for Tech Lead/mobile-dev to reconcile ordering
  if STORY-005 lands after this story's implementation.

## 3. Responsive Behavior

- Single-column vertical list at all supported widths (phone portrait is the
  primary target per design source's frame sizing); no multi-column
  timeline layout.
- Photo slots (112px height) and card padding scale using the design
  system's 8pt spacing scale (`spaceMd`/`spaceLg`), not fixed pixel values,
  so the layout adapts to larger phone widths/tablets without redesign.
- Connector line and dot markers are positioned relative to content padding
  (26px left inset in source), so this must scale proportionally with the
  platform's horizontal margin token rather than being hardcoded, to avoid
  the line drifting from the dots on different screen widths.
- Create-entry bottom sheet should follow the platform-adaptive sheet
  behavior already defined in the design system (Section 6, STORY-001
  spec) — full-width sheet on phone, respecting `radiusSheet` token on both
  platforms.

## 4. Accessibility

- Minimum tap target: the "Add a memory" button (52px tall) and all card
  rows meet the `tapTarget` token (44pt iOS / 48dp Material) from the design
  system.
- Icon-only affordances (back chevron, photo-add in the create sheet) need
  accessible labels ("Back", "Add photo") — the design source uses
  icon-only glyphs with no visible text for these, so labels must be
  supplied in the Flutter semantics layer, not visually.
- Timeline entry icon + dot colors (`t.iconColor`/`t.dot`) are decorative
  category indicators, not the sole means of conveying entry type — the
  entry title/body text must remain the primary information channel so the
  feature doesn't rely on color alone (WCAG 1.4.1).
- Per STORY-001 Section 5's contrast rule: do not use `colorAccentPink`/
  `colorAccentPurple` as small/body text color in light theme on
  `colorSurface`/`colorBackground` — the entry title (14.5px, weight 800)
  and body (12.5px) must use `colorText`/`colorTextMuted`, reserving the
  accent colors for icons/dots only, which this design source already does
  correctly (icon/dot colors use accent tokens, title/body text uses
  neutral text tokens).
- Date/timestamp text (Roboto Mono, 9.5px) is below the design system's
  13pt caption-size guidance (Section 4, STORY-001 spec) — flag this as a
  source deviation: recommend bumping to at least 11-12pt in the Flutter
  build for legibility/accessibility, since 9.5px is unusually small even
  for a secondary metadata label.
- The "auto-added" badge and offline/loading banners must expose their text
  content to screen readers as live-region or static text (not icon-only),
  since they convey state changes a screen-reader user needs (e.g. "showing
  saved memories, offline").

## 5. Open Items For Downstream Roles (from story_master.md + this pass)

1. **Tech Lead — local encryption spike (from story_master.md).**
   story_master.md's "Non-Functional / Risk Notes" (R3) asks Tech Lead to
   confirm whether timeline entries require local encryption (libsodium FFI
   spike) before this story's coding-plan is finalized. This UX spec does
   not resolve that decision — it is explicitly a Tech Lead item — but
   flags it forward unresolved: if encryption is required, the create-entry
   sheet and offline-cache read path above may need additional
   unlock/decrypt UX (comparable to the Gallery screen's `galleryLocked`
   pattern in the same design source), which is not currently designed here
   and would need a follow-up UX pass.
2. **Design-source gap — auto-added timeline entries are not in this
   story's scope.** The `isTimeline` mock data (`timeline` array in the
   design source) includes entries with `auto: true` (e.g. "200 days
   together", "Dream Jar hit 75%") that appear to be auto-generated by other
   features (day-counter milestones, Dream Jar progress), alongside
   manually-added entries (`auto: false`, e.g. "First fight, survived").
   story_master.md's "In Scope" only covers user-created entries via the
   `timeline` backend contract; auto-generated entries from other
   features are not mentioned in this story's scope or backend module.
   Flagging for Tech Lead/Product Owner: either (a) confirm auto-added
   entries are out of scope for STORY-012 and will be handled by a future
   cross-feature story, or (b) if in scope now, this UX spec's "auto-added"
   badge/card treatment above should be built. Until confirmed, mobile-dev
   should build only the manual-entry path (AC1-AC4) and treat the
   "auto-added" badge as optional/deferred UI.
3. **Design-source gap — no dedicated create-entry screen/sheet is drawn.**
   Section 1.3 above proposes a bottom-sheet pattern (reusing existing
   sheet/photo-picker conventions from elsewhere in the design source) since
   no create-entry mock exists for the Timeline screen specifically. Tech
   Lead/mobile-dev should confirm this sheet-based approach versus a
   full-screen create flow before implementation, since it's this spec's
   recommendation, not a traced design-source screen.
4. **Milestone/progress banner data source is undefined for this story.**
   The top-of-screen "days to go" / percentage-ring banner in the mock is
   visually part of the Timeline screen but its data (target milestone,
   percentage) is not part of story_master.md's "In Scope" (which only
   covers creating/viewing timeline entries). Flagging for Tech
   Lead/Product Owner to confirm whether this banner ships with STORY-012
   (and if so, where its data comes from) or is deferred to a later/separate
   story — this spec treats it as an optional display slot, not a build
   requirement, pending that confirmation.
5. **Unpaired-gate pattern has no existing shared precedent yet.** As noted
   in Section 2, no STORY-005/pairing UX spec exists yet in this
   requirement's artifacts to reuse. This spec defines a first-pass
   "hide/disable the entry point" pattern for AC4; if STORY-005 defines a
   shared component/copy later, reconcile the two rather than shipping two
   different unpaired-gate treatments across the app.

## Completion

`UX_COMPLETE: YES`

Screen structure, states, responsive behavior, and accessibility
requirements are specified from the `isTimeline` design source block and the
STORY-001 design-system tokens. Five open items are flagged explicitly above
for Tech Lead/Product Owner/mobile-dev follow-up (encryption spike scope,
auto-added-entry scope, create-sheet pattern confirmation, milestone-banner
scope, and unpaired-gate reconciliation with STORY-005); none of them block
starting implementation of the core AC1-AC4 manual create/view/offline-read/
unpaired-gate flow described above.
