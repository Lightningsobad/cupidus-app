# UX Spec: STORY-010 Epic-3 — Vibes / Cảm Xúc Hằng Ngày (Vibe Check)

Scope: REQ-001 / STORY-010_vibes
Source of truth: `cupid-mobile-design/Cupid Screens.dc.html`, screen id
`vibe` (`isVibe`), plus its entry-point card on the `home` dashboard screen
(`isHome`, `goVibe`/`Lịch sử` tap target) and the daily-reminder row on the
`notifs` screen (`notifEngage`, "Vibe Check · Daily at 9pm").
Tokens/components reused verbatim from STORY-001
(`data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-001_design_system/ux/uiux-spec.md`)
and system UX memory (`data/ux/system/ui_ux_system_memory.md`) — no new
tokens introduced. Data sensitivity: Vibe Check is **Level 2** (server +
end-to-end encrypted) per system UX memory §8 — no Level-1 lock affordance
required on this screen.

Backend contract read for accuracy (A1 frozen, no endpoint change in this
story): `backend/src/modules/vibes/` — `POST /vibes` (mood + optional
note), `GET /vibes/today`, `GET /vibes/history?days=`, `GET /vibes/partner?days=`.

## 1. Screen Inventory (existing design source, reused as-is)

| Screen id | Purpose | Chrome |
|---|---|---|
| `home` (partial) | Vibe Check summary card (today's mood, mine + partner's) — existing entry point, unchanged layout | tab bar |
| `vibe` | Mood picker + partner's current vibe + 7-day history strip | tab bar (reached from `home`, not a chromeless flow) |

No new screens are added. This story only specifies the *data behavior*
behind the two existing screen fragments above (the design source already
shows their full visual layout).

## 2. Flow Map

```
home dashboard
  -> Vibe Check card (today's mine/partner mood glyph + label) --tap anywhere on card, incl. "Lịch sử/History" label--> vibe

vibe screen
  -> mood grid (6 cells in source, see §3 for v1 cell-count resolution)
       - tap a mood cell -> immediate submit (§4), no separate confirm step
  -> partner vibe card (today's partner mood + contextual nudge suggestion, §5)
  -> "Last 7 days" strip (mine + partner's daily mood glyphs, §6)
  -> back -> home (existing chrome back/tab behavior, unchanged)

Daily reminder (notifs screen, existing "Vibe Check · Daily at 9pm" row)
  -> local/push notification tap -> deep-link directly to `vibe` (not `home`),
     consistent with other engagement notifications in the design source.
```

## 3. Mood Set — Design/Backend Mismatch (resolve before mobile-dev build)

The design source's `moodList` (6 cells: `happy`, `soft`, `sad`, `angry`,
`tired`, `spicy`) does **not** match the backend's frozen `Mood` enum (5
values: `HAPPY`, `SAD`, `ANGRY`, `HORNY`, `TIRED` —
`backend/src/modules/vibes/entities/vibe.entity.ts`). There is no `SOFT`
value on the backend, and A1 forbids adding one.

**Resolution specified for v1 (does not require a backend change):**

- Drop the `soft` (🥰 "Mềm lòng"/"Soft") cell entirely. It has no backend
  value to persist to and cannot be faked as another mood without lying
  about the user's input.
- Keep `spicy` (😳 "Hơi bậy"/"Spicy") and map it 1:1 to the backend's
  `HORNY` enum value — the existing design copy already reads as a
  playful, non-explicit "a bit naughty" framing, so no new copy is needed,
  only the underlying value mapping (`spicy` display id → `mood: horny` on
  submit).
- Final v1 mood grid is **5 cells**: `happy`, `sad`, `angry`, `spicy`
  (→ `horny`), `tired` — same visual cell component (icon/emoji + label,
  `popIn`/`bob` animation, pink-glow selected state) as the design source,
  laid out as **2 rows (3 + 2, centered)** instead of the source's 3×2 six-
  cell grid, since a 5-item grid does not divide evenly into 3 columns.
- **Flag for Product Owner/Tech Lead**: this is a scope decision (removing
  a visually-designed mood option), not a purely visual call — recommend
  Product Owner confirm dropping `soft` rather than UX unilaterally cutting
  a designed option. If Product Owner instead wants to keep 6 options,
  the only backend-safe alternative is a client-only "soft" cosmetic subset
  of `happy` (submits `mood: happy` but displays a different label locally)
  — not recommended, since it silently misrepresents what was persisted;
  flagging both options rather than picking silently.

## 4. Mood Check-In Interaction (AC1)

- The mood grid is simultaneously the **input control** and the **current-
  status display** — there is no separate "confirmed" static state. The
  currently-selected cell (from `GET /vibes/today`, if any) renders in the
  design source's "on" style (pink-glow border/gradient fill); all other
  cells render in the "off" style (existing behavior, unchanged).
- Tapping any cell **immediately submits** `POST /vibes` with that mood —
  there is no separate "Confirm"/"Save" button. This matches the D2 Cubit-
  for-CRUD-screens convention (`req_master.md` D2) — a single-tap, low-
  ceremony action appropriate for a daily mood ping.
- **Optimistic UI**: on tap, update the selected-cell highlight immediately
  (do not wait for the network round-trip before showing the tap
  registered) and disable re-tapping the grid until the request resolves,
  to prevent duplicate submissions from rapid double-taps.
- **Re-check-in same day**: the backend allows multiple check-ins per day
  (each `POST` creates a new record; `GET /vibes/today` returns the most
  recent). The UI must allow tapping a different cell later the same day
  to update the visible "today" state for both partners — this is
  intentional, not a bug to guard against with a "you already checked in"
  block.
- **On submit failure** (network/5xx): revert the optimistic highlight to
  the last confirmed state and show a single non-blocking inline error
  using the existing `--red` token — reuse the STORY-003 §6 error-mapping
  convention (e.g. a `NetworkUnavailableFailure` reads "Không có kết nối
  mạng" / "No internet connection"), not a full-screen error state. Do not
  leave the grid showing a mood that was not actually saved.
- **Optional note field** (`CreateVibeDto.note`, backend-supported): the
  design source's `vibe` screen has **no note/text-input UI** at all — only
  the tap-to-pick mood grid. Given this story's Complexity is S and AC1/AC2
  only require "set/share a vibe" and "view the shared vibe" (no mention of
  a note), **v1 scope is mood-only, no note input** — do not add a text
  field the design never showed. Flag for Product Owner: the backend field
  exists and is unused in v1; fine to leave unused (A1 doesn't require
  clients to exercise every optional field), no action needed unless
  Product Owner wants to scope it into a later story.

## 5. Partner's Vibe + Nudge Suggestion (AC2)

- Partner's current mood renders via the existing `partnerMoodId`/
  `partnerMoodLabel` card (Mood Face icon + name + label), reusing the
  design source's states verbatim:
  - No check-in yet today: label reads "Chưa nói gì" / "Waiting…" (existing
    copy, unchanged).
  - Checked in: label + `Mood Face` icon reflect their selected mood
    (mapped through §3's 5-value set, e.g. a `horny`/`spicy` value renders
    with the "spicy" label/icon, not a raw enum string).
- **Contextual nudge banner** (existing `suggestion`/`suggestionCta`
  pattern — butter/amber tinted card, `tips_and_updates` icon): copy varies
  by partner's mood (`sad` → hug suggestion, `angry` → tea suggestion,
  `tired` → let-them-rest copy, any other mood → generic positive
  acknowledgment, no check-in yet → nudge-them copy) — reuse the existing
  four copy variants as-is, remapped only for the dropped `soft` case (fold
  it into the generic "good vibes" branch, same as any positive mood not
  explicitly `sad`/`angry`/`tired`).
- **Open item — CTA has no backing action (flag for Product Owner/Tech
  Lead, not resolved here):** the design source renders `suggestionCta`
  ("Send hug" / "Order tea" / "Nudge") as a tappable-looking pill
  (`cursor:pointer`) but wires **no `onClick` handler** in the prototype,
  and there is no corresponding backend endpoint (vibes module only
  supports create/today/history/partner; A1 forbids adding a
  hug/nudge/gift endpoint for this story). Recommend one of:
  (a) render the pill as **decorative only** in v1 (no tap affordance,
  drop `cursor:pointer`, keep it as an affirming label) — cheapest, matches
  actual capability; or
  (b) wire "Nudge" specifically to an existing capability if one already
  exists elsewhere in scope (e.g. a lightweight push notification to the
  partner) — only if Tech Lead confirms such a mechanism exists without a
  new endpoint.
  This spec does not pick between them since it is a scope/backend-
  capability decision, not a visual one; (a) is the safe default if no
  decision is made before mobile-dev build, since it requires no new
  wiring and does not promise a capability that does not exist.

## 6. 7-Day History Strip + Copy Accuracy (AC2)

- Reuse the existing `moodHistory` strip verbatim: 7 columns (oldest→
  newest, day-of-week mono label), each showing both partners' `Mood Face`
  glyphs stacked with a connecting divider line. Mood ids render through
  §3's 5-value mapping; a day with no check-in for a side renders `none`
  (existing "none" `Mood Face` state — same as `myMoodId`/`partnerMoodId`
  fallback elsewhere in the design source).
- **Open item — copy/behavior mismatch (flag for Product Owner, not
  resolved here):** the strip's header reads "tự xoá sau 30 ngày" /
  "auto-deleted in 30d". The backend (`vibes.service.ts`) has **no deletion
  job** — `GET /vibes/history`/`GET /vibes/partner` simply default to a
  30-day query window (`days` query param, caller can request up to 365),
  records are never actually deleted. Shipping "auto-deleted" copy would
  overstate a data-retention guarantee the backend does not implement —
  the same category of copy-vs-behavior gap the system UX memory already
  flags for Synced Alarm/DND (§6/§7 there). Recommend Product Owner choose
  one of: (a) change the copy to something accurate and non-committal,
  e.g. "7 ngày gần nhất" / "last 7 days" (drop the deletion claim
  entirely — cheapest, matches what's actually shown), or (b) if an actual
  30-day retention/deletion policy is a real product requirement, that is
  a backend change and therefore out of this story's A1-frozen scope,
  needing its own backend story. This spec defaults to recommending (a)
  as the v1 ship copy given the S complexity and A1 constraint, but flags
  Product Owner as the decision-owner since it is a data-retention/privacy
  claim, not a pure visual one.

## 7. Unpaired Access (AC3)

- The `vibe` screen and its `home` dashboard entry card sit inside the
  main app's post-pairing tab-bar area (`isHome` group, system UX memory
  §4 "main app (post-pairing) uses the 5-tab bottom nav"). An unpaired
  user cannot reach `home`/`vibe` at all under the existing chrome/nav
  rules — the onboarding/pairing flow (`NO_CHROME`/`NO_TABS` group) is a
  separate route tree that does not expose the tab bar or `goVibe`.
- This spec relies on that existing app-level route gate rather than
  redesigning a new one — **do not build a second, screen-level "are you
  paired" check inside the `vibe` screen** as the primary guard; the
  primary guard is not reaching this route tree unpaired in the first
  place.
- **Defensive state (flag for Tech Lead, not a redesign):** if a
  previously-paired user's partner unpairs while the app is already open
  on `vibe` (session-state edge case, not the common path), the partner
  card should fall back to the existing "no check-in yet" visual (`Mood
  Face` none, label "Chưa nói gì"/"Waiting…") rather than crash or show a
  raw error — this reuses an existing design state, not a new one, so it
  is a Tech Lead/mobile-dev wiring note, not a new UX spec.

## 8. Accessibility Notes

- Mood grid cells must meet the existing `--tap` minimum (44pt iOS / 48dp
  Material, STORY-001 tokens) — the design source's ~68×~90px cells
  already clear this, no change needed after moving to a 5-cell 3+2
  layout (§3), but mobile-dev should re-verify the resized/recentered
  layout still meets `--tap` per cell.
- Each mood cell must expose its label as an accessible name (e.g.
  semantic label "Happy"/"Sad"/etc.), not rely on the emoji glyph alone —
  the `Mood Face` component's `mood` prop already carries the discrete
  value needed for this.
- Selected-state (the "on" pink-glow cell) must be exposed as a selected/
  toggled state to assistive tech (e.g. `selected`/`checked` semantics),
  not conveyed by border color alone.
- The optimistic-submit + revert-on-failure interaction (§4) must announce
  the failure via an accessible live-region/error text at the point of
  revert, not only via the visual highlight reverting silently.
- If §5's nudge CTA ships as decorative-only (recommended default), it
  must not remain a focusable/tappable-looking element for assistive tech
  either — remove any `button`/interactive semantics along with the visual
  `cursor:pointer`, so screen-reader users are not offered a control that
  does nothing.

## 9. Platform Adaptation

No new fork points. Existing adaptive rules apply unchanged: mood-grid
cells and cards use the existing `--r-card`/`--r-sm` radii and `--shadow`
(iOS soft blur / Material tonal elevation) tokens from STORY-001, already
platform-themed. No FAB/full-width-CTA fork is needed here since there is
no "add new" action distinct from tapping a mood cell.

## 10. Open Items For Downstream Roles

1. **Product Owner — confirm dropping the `soft` mood cell (§3).** Backend
   enum has no matching value; recommended resolution is a 5-cell grid
   (`happy`, `sad`, `angry`, `spicy`→`horny`, `tired`), not a client-side
   relabel. Blocks nothing else in this spec but should be confirmed
   before mobile-dev builds the grid, since it changes cell count/layout.
2. **Product Owner/Tech Lead — nudge CTA has no backing action (§5).**
   Recommend defaulting to decorative-only in v1 unless Tech Lead confirms
   an existing (non-new-endpoint) mechanism for "Nudge" specifically.
3. **Product Owner — "auto-deleted in 30d" copy overstates actual backend
   behavior (§6).** Recommend changing to non-committal "last 7 days" copy
   for v1 rather than promising a retention/deletion guarantee the backend
   does not implement; an actual retention policy would be a separate,
   out-of-A1-scope backend story.
4. **Tech Lead — confirm STORY-010 does not need STORY-004
   (`RealtimeCoordinator`)** per this story's own `story_master.md` "Open
   Items For Downstream Roles": this UX spec assumes pull/refresh-based
   delivery is sufficient (partner's mood updates when the user opens/
   refreshes `home`/`vibe`, not via a live socket push) since the design
   source shows no live-update affordance (no "typing"-style ghost/pulse
   indicator on this screen, unlike chat). If Tech Lead decides realtime
   push is required, this spec's screens do not need new visual states —
   only a background pull-to-fresh-value binding — so it does not block
   Tech Lead's ADR either way.
5. **Tech Lead — defensive partner-unpair edge case (§7)** is a wiring
   note only (reuse existing "no check-in yet" state), not a new UX state
   to design.

## Completion

UX_COMPLETE: YES

All three ACs have a corresponding UX specification: AC1 (§4, mood grid as
immediate-submit input reusing the existing design's mood cells, 5-value
set), AC2 (§5 partner vibe card + nudge banner, §6 7-day history strip),
AC3 (§7, relies on existing post-pairing route gate, no new screen-level
check needed). One scope decision (§3, dropping `soft`) and two copy/
capability gaps (§5 CTA, §6 "auto-deleted" copy) are flagged for Product
Owner/Tech Lead as open items — none block starting this spec's build; all
default to a safe, backend-accurate fallback if not resolved before
mobile-dev picks this story up.
