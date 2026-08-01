# UX Spec: STORY-008 Epic-2 — Anti-Ghosting Configuration

Source design reference: `cupid-mobile-design/Cupid Screens.dc.html` — home
dashboard "Anti-Ghosting" quick-access card (`goAnti`/`antighost` screen,
`isAnti`), chat screen's `showSeenRow`/`stormReady` inline indicator, and home
dashboard's `ghostAlert` banner. Design tokens/principles per
`data/ux/system/ui_ux_system_memory.md` (§1-§3, §9 "Anti-Ghosting" entry,
§11 confirm dialog / focus-trap patterns). Backend contract: `backend/src/
modules/ghost-config/` (`GhostConfigController`, `GhostConfig` entity,
`CreateGhostConfigDto`) — **A1 frozen, read directly for this spec, not
assumed from the design mockup**.

## 0. Contract Reality Check (read this before the screens below)

The raw design mockup's Anti-Ghosting settings screen shows **four**
independent controls (ghost timeout picker, "Public countdown" toggle,
"Emoji Storm" toggle, "Sound override" toggle) plus a **custom storm-emoji
picker** grid, and shows no partner-approval step at all. The actual frozen
backend contract (`CreateGhostConfigDto`, `GhostConfig` entity) exposes only:

- `timeoutMinutes: int (1-120)`
- `penalty: enum('emoji_storm' | 'noise' | 'none')` — **one** mutually
  exclusive choice, not independent toggles.
- A **mandatory propose → partner-approve/reject** lifecycle
  (`POST /ghost-config` creates `PENDING_APPROVAL`; only the *other* partner
  may `PATCH /:id/approve` or `/reject`; the proposer cannot self-approve).
  Only one config is ever `ACTIVE` per couple; approving supersedes the prior
  active config.
- No custom emoji set, no "public countdown" flag, no "sound override" flag
  — none of these exist server-side to persist.
- No realtime push for config proposals: `GhostConfigService.create()` only
  emits a `logger.log` stub, not a real notification (matches STORY-004's R9
  finding — no server-side FCM dispatch exists yet). **Any partner-facing
  "new proposal" or "your proposal was approved/rejected" awareness must be
  a pull-model (checked on screen entry/foreground), not push-driven.**

This spec designs against the real contract, not the raw mockup's decorative
surface. See §6 Open Items for the exact descope/flag list Product Owner and
Tech Lead need to rule on.

## 1. Access Guard

Anti-Ghosting (both the settings screen and any chat surfacing) is
pairing-gated, consistent with every other post-pairing screen in the design
source (`NO_CHROME`/`NO_TABS` boundary in system memory §4): an unpaired
user has no bottom-tab entry point to it at all, and the settings screen
itself must treat "no `user.partnerId`" as a hard redirect/empty-state (not
just hide the entry point), matching the backend's own
`BadRequestException('You must be paired with a partner...')` defense in
depth for the edge case of a partner unlinking while the screen is open.
This satisfies AC3.

## 2. Screens & Entry Points

### 2.1 Home Dashboard — "Anti-Ghosting" quick-access card (existing pattern, reused)

Reuse the mockup's `goAnti` card as-is: icon `blur_on` on `--purple` tint
tile, title "Anti-Ghosting" (brand term, stays English in both `vi`/`en` per
system memory §5), subtitle line reflecting **current state**, one of:

- No active config yet (first-run): *"Not set up yet"* / *"Chưa thiết lập"*.
- Active config: `{timeoutMinutes} min · {penalty label}` (e.g. "10 min ·
  Emoji Storm on"), mirroring the mockup's `thresholdLine` format but driven
  by the real `penalty` enum, not a hidden "Storm on" flag.
- **New pending-state variant (not in the raw mockup, required by the real
  approval lifecycle):** if `GET /ghost-config/pending` returns an item
  *proposed by the current user*, subtitle reads *"Waiting for {partner} to
  confirm"* and the card shows a small amber dot badge (reuse `--amber`
  token, same visual language as the Synced Alarm card's pending state
  already established for that screen).
- If `GET /ghost-config/pending` returns an item *proposed by the partner*
  (i.e. current user is the approver), subtitle reads *"{partner} suggested
  new rules — review"* with the same amber dot badge, and tapping the card
  routes straight to the review state (§2.3) instead of the normal edit
  state.

### 2.2 Home Dashboard — "ghost alert" banner (existing pattern, reused)

Reuse the mockup's `ghostAlert` banner (amber-tinted, `sentiment_dissatisfied`
icon with `wiggle` animation, tap → chat) verbatim for its layout/tokens, but
retarget its trigger and copy to the real per-couple state:

- Trigger: `GET /ghost-config/storm-status/:partnerId` (or the equivalent
  read the chat screen already uses per §2.4) reports the current user has
  an active, unresolved "seen, no reply" message from their side — i.e. the
  *partner* is the one going quiet on *the current user's* message. This is
  the "you're being left on read" case, matching the mockup's own copy
  intent.
- Title/body: keep the mockup's tone (*"Seen {n} minutes ago"* /
  *"Reply or a Storm is coming your way"*) but only render the Storm-specific
  wording when the active config's `penalty === 'emoji_storm'`; branch copy
  for `noise` (e.g. *"...or things are about to get loud"*) and suppress the
  penalty threat line entirely for `none` or "no active config yet" (still
  show a neutral "seen, no reply" nudge with no threat copy in that case).

This banner is a supplementary *notification-style* entry into chat; it is
not the AC2 gate (§2.4 is).

### 2.3 Anti-Ghosting Settings Screen (`antighost`)

Reskinned from the mockup's `isAnti` screen, replacing the four-toggle block
with a single contract-accurate control set. Four distinct view-states,
selected by the config lifecycle read (`GET /ghost-config` for active +
`GET /ghost-config/pending` for pending):

**State A — No active config, no pending proposal (first run)**
- Keep the mockup's intro card verbatim ("Leaving me on read has a price 🎀"
  / "You two set the rules. Cupid just referees...").
- Ghost-timeout picker: keep the mockup's 3-chip quick-pick pattern (5/10/15
  min) as presets, **plus** a "Custom" chip that opens a stepper/slider
  bounded to the real `1-120` range (the raw mockup only offers 3 fixed
  values; the backend allows any 1-120 int, so a custom option is required
  to not silently under-expose the real contract range).
- Penalty selector: **one 3-option segmented control** (replaces the
  mockup's 3 independent toggles) — "Emoji Storm" (`cyclone` icon),
  "Noise" (`volume_up` icon), "None" (muted/neutral icon) — single-select,
  radio semantics, not independent switches.
- Primary CTA (bottom ~30%, platform-adaptive per system memory §3: full-
  width pill on iOS, filled button on Material): "Propose to {partner}" /
  "Đề xuất cho {partner}" — explicitly names that this requires the
  partner's confirmation (sets expectation before submit, not after).
- Submitting calls `POST /ghost-config` and transitions to State B.

**State B — Proposed by me, awaiting partner (`PENDING_APPROVAL`,
`proposedBy === me`)**
- Not in the raw mockup; new state required by the real lifecycle.
- Read-only summary card showing the proposed `timeoutMinutes` + penalty,
  with a waiting indicator (reuse the Typing-Ghost consent screen's "Waiting
  for both to agree" visual language from system memory §11's sibling
  pattern in the same screen family — pill badge, `--purple` tint, no
  spinner since this is not a live/real-time wait).
- Controls are disabled (dimmed, not hidden) while pending, so the user
  understands *why* they can't edit rather than wondering where the form
  went.
- No cancel/withdraw action exists server-side (no `DELETE`/cancel endpoint
  on the frozen contract) — do not design one; if the user wants different
  terms, they wait for the partner's decision (see State D) or the partner
  rejects it.

**State C — Partner proposed, awaiting my review (`PENDING_APPROVAL`,
`proposedBy === partner`)**
- Not in the raw mockup; new state required by the real lifecycle.
- Review card: proposed `timeoutMinutes` + penalty shown clearly, with two
  actions — "Accept" (primary, `--mint`/trust token per system memory's
  positive-action convention) and "Decline" (secondary/text button).
- This is a simple single-tap confirm, **not** the dual-confirmation/hold-
  gesture vocabulary reserved for partner rituals (Love Contract, Fingerprint
  Vow) per system memory §1/§11 — accepting new anti-ghosting rules is
  low-stakes/reversible (a new proposal can always supersede it later), so a
  standard confirm affordance is the right weight, not an escalated one.
- Accept → `PATCH /:id/approve`, transitions to State D. Decline → `PATCH
  /:id/reject`, transitions back to State A (or State D if a prior config
  was already active — rejection does not clear the existing active
  config).

**State D — Active config exists, no pending proposal**
- Summary card: current `timeoutMinutes` + penalty, "last updated" framed
  as *who* set it if useful, plus a "Change" action that re-opens the
  State-A form (pre-filled with current values) and creates a new proposal
  on submit — editing an active config always goes through the same
  propose/approve cycle, there is no direct-edit path on the frozen
  contract.

Drop from the raw mockup entirely (no backend support, see §0/§6): "Public
countdown" toggle, "Sound override" toggle, custom storm-emoji picker grid.

### 2.4 Chat Screen — inline state surfacing (AC2 gate)

This is the concrete answer to story_master.md's open item ("confirm exact
screen/placement for the anti-ghosting signal relative to STORY-007's chat
screens"): reuse the mockup's existing `showSeenRow`/`stormReady` inline row
verbatim as the AC2 surfacing point — it already lives inside the chat
screen the story asks for, requires no new chat-screen real estate, and is
visually distinct from the Typing-Ghost bubble (STORY-007 scope) it sits
below in the mockup.

- Row appears once the current user's sent message has been marked "seen"
  by the partner with no reply yet: *"Seen {n} min ago, no reply"* (amber
  `--amber` text, per mockup).
- The storm CTA pill (`cyclone` icon, "Fire Emoji Storm") appears only when
  `GET /ghost-config/storm-status/:partnerId` returns `eligible: true` *and*
  `penalty === 'emoji_storm'`. Branch the pill for `penalty === 'noise'`
  (different icon/copy, e.g. `volume_up` "Send Noise") and suppress the CTA
  entirely for `penalty === 'none'` or no active config (the seen/no-reply
  line still shows on its own — that's a neutral signal, not a penalty
  offer).
- No config-access entry point is added inside the chat screen itself —
  configuration lives on the Home dashboard card (§2.1), consistent with the
  mockup's own navigation graph and avoiding an invented chat-header control
  the design source never specified.
- Since eligibility has no push channel, the client must re-check
  storm-status on chat-screen focus/foreground and on a reasonable interval
  while the seen-row is showing (exact polling cadence is a Tech
  Lead/Mobile Dev decision, not a UX one — flagged in §6).

## 3. Responsive / Platform Behavior

- Follows system memory §3's adaptive table throughout: primary CTAs
  (Propose/Accept/Change) are full-width pills on iOS vs. filled
  Material buttons w/ ripple on Android; headers use the platform's
  large-title vs. top-app-bar convention already established for every other
  post-pairing screen.
- Threshold chips, penalty segmented control, and Accept/Decline buttons all
  meet the `--tap` minimum (44pt iOS / 48dp Android) per system memory §2.
- One-thumb principle: primary action (Propose/Accept/Change) sits in the
  bottom ~30% of the screen, matching every other screen in this design
  system.
- No new breakpoint/layout needs beyond the existing single-column mobile
  layout already used by every other settings-style screen in the source.

## 4. Accessibility

- Penalty segmented control uses radio-group semantics (single selection,
  arrow-key/swipe navigation between options, each option's selected state
  announced) — not three independent switch/toggle semantics, matching the
  real one-of-three contract shape.
- Amber "seen, no reply" text and the pending-proposal amber dot badge must
  not rely on color alone: pair with the existing icon (`timer`/dot badge)
  and text label already present in the mockup's pattern — already satisfied
  by reusing those exact elements, call out explicitly so implementation
  doesn't strip the icon/text and leave color-only signaling.
- Storm CTA appearing/disappearing in chat is a live-region-worthy state
  change for screen reader users (announce "Storm available" once when it
  newly appears, not on every rebuild/poll tick).
- Accept/Decline in State C: standard focus order (Accept then Decline,
  matching primary-then-secondary reading order), each with a full
  accessible label naming the actual values being decided on (e.g. "Accept
  10 minute Emoji Storm rules from {partner}"), not just "Accept" — the
  decision content must be in the accessible name for a screen-reader user
  jumping straight to the action.
- Disabled controls in State B must expose their disabled reason via
  accessible description (e.g. "Disabled — waiting for {partner} to
  respond"), not just a visually dimmed state.

## 5. Copy / i18n

- "Anti-Ghosting" and "Emoji Storm" remain brand/proper-noun terms in the
  `vi` locale (English), consistent with system memory §5's rule for named
  features (Typing Ghost, Synced Alarm, etc.) — do not translate these two
  title strings.
- All other body copy needs both `vi`/`en` variants per the existing
  `data-vi`/`data-en` pattern; the new State B/C/D strings introduced here
  (not in the raw mockup) still need Product Owner/localization sign-off on
  final wording — this spec gives functional copy intent, not final
  approved strings.

## 6. Open Items For Downstream Roles

1. **Contract-vs-mockup descope decision (Product Owner + Tech Lead):**
   confirm the drop of "Public countdown" toggle, "Sound override" toggle,
   and the custom storm-emoji picker grid from v1 (§0/§2.3), since none have
   backend persistence on the frozen `ghost-config` contract. If any of
   these is wanted as a *client-only, non-persisted* preference, that is a
   distinct, smaller-scope product decision this spec does not make
   unilaterally.
2. **Threshold input shape (Product Owner):** confirm whether the 3-chip
   preset (5/10/15 min) plus a "Custom" 1-120 stepper (§2.3 State A) is the
   right shape, versus exposing the full 1-120 range as a single slider with
   no presets, or presets only (dropping custom entirely and under-exposing
   the contract range).
3. **Storm-status polling cadence (Tech Lead/Mobile Dev):** §2.4 requires a
   pull-based recheck of `GET /ghost-config/storm-status/:partnerId` and
   `GET /ghost-config/pending` since there is no push channel (STORY-004 R9)
   — exact interval/trigger (foreground-only vs. timer-based) is an
   implementation decision, not resolved here.
4. **Epic label inconsistency (flag only, no action needed from this spec):**
   `story_master.md` classifies this story as epic-2 (communication) and the
   backend controller tags it `Epic 2/3`, while the raw design source's own
   screen `INDEX` groups the "Anti-Ghosting" screen under its epic-3 grouping
   (`data/ux/system/ui_ux_system_memory.md` §4/§9). This spec does not
   relocate the screen in navigation on that basis — flagging only in case
   Product Owner wants the requirement/backlog epic label reconciled with
   the design source's own grouping.
5. **Reject-notice UX (Product Owner):** confirm whether a rejected
   proposer needs any explicit "your partner declined" surfacing beyond the
   settings screen reverting to State A/D silently on next visit (§2.3 State
   C), given there is no push channel to notify them proactively.
