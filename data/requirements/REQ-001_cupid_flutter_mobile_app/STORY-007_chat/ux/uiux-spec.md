# UX Spec: STORY-007 Epic-2 — Chat (2-way typing-ghost, realtime)

Scope: REQ-001 / STORY-007_chat
Source of truth: `cupid-mobile-design/Cupid Screens.dc.html` (screen ids
`chat`, `ghostset` — the tabbed main-app group, per system UX memory §4).
Tokens/components reused verbatim from STORY-001
(`data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-001_design_system/ux/uiux-spec.md`)
— no new tokens introduced. Auth/session gating conventions reused from
STORY-003 (system UX memory §11) where applicable; pairing gate reused from
STORY-005 (see §7 below).

This spec covers the two screens the design source already draws in full
(`chat`, `ghostset`) plus the states/behaviors the backend
`messages`/`uploads` contract and the STORY-004 `RealtimeCoordinator`
introduce that the static design source cannot show (delivery/read state,
history-cache loading, offline-send blocking, pairing gate).

## 1. Screen Inventory (existing design source, reused as-is)

| Screen id | Purpose | Chrome |
|---|---|---|
| `chat` | 1:1 message thread with the paired partner, 2-way Typing Ghost inline in the composer | Header (back + partner name/status chip) + bottom tab bar (`showTabs`, `canBack` both true per design source's own `NO_TABS`/back-target logic — chat is a tabbed screen, not a chromeless flow screen) |
| `ghostset` | Typing Ghost explainer + mutual on/off toggle + live consent state for both partners | Header + bottom tab bar (same as `chat`) |

No new screens are added for AC1-AC4. AC5 (pairing gate) is handled by
routing, not a new screen — see §7.

## 2. Flow Map

```
Home (5-tab shell, post-pairing only)
  -> tap "chat" tab -> chat (thread view)
       - tap partner-name/status chip in header -> (out of scope: no partner
         profile screen defined here; Tech Lead/PO to confirm target if any)
       - tap Typing Ghost icon in composer -> toggles/requests Typing Ghost
         inline (no navigation, §4)
Home -> "Typing Ghost" tile (existing goGhostSet tap target in design
  source's home dashboard) -> ghostset (explainer/settings)
  -> back -> Home
```

`ghostset` is reached from the Home dashboard tile in the existing design
source (`goGhostSet`), not from inside `chat` itself — the composer's ghost
icon is a direct in-place toggle, not a navigation trigger to `ghostset`.
Reuse this split as-is; do not add a second entry point from inside `chat`
unless Tech Lead/PO explicitly asks for one.

## 3. Chat Screen (`isChat`)

### 3a. Header

Reuse the shared header component (STORY-001 §6 "Header" adaptive category)
exactly as the design source wires it for this screen:
- `canBack`: true — back navigates to Home.
- `title`: partner's display name (design source shows the placeholder pair
  label "Minh ↔ Linh"; real implementation shows the current session's
  partner display name only, not both names — the design source's combined
  label is a prototype placeholder for "whose chat this is," not a literal
  two-name heading pattern to keep).
- Partner status chip (`showPartnerChip`): avatar-initial bubble with a
  green online dot + status text ("online" / "đang online"). Model this off
  whatever presence signal STORY-004's RealtimeCoordinator exposes
  (foreground-socket-connected partner = online; otherwise show last-seen
  or omit the chip rather than showing a stale "online"). Exact presence
  semantics (online/offline only, vs. last-seen timestamp) are a Tech Lead
  input — flagged in §9.

Bottom tab bar stays visible on this screen (design source's own
`showTabs`/`NO_TABS` table does not include `chat`) — this is a tabbed
top-level destination, not a modal/chromeless flow screen.

### 3b. Message Thread

- Privacy chip at the top of the scroll region: lock icon + "Level 1 · chỉ
  nằm trên máy hai người" / "Level 1 · on your devices only" — reuse
  verbatim per system UX memory §5/§8 (chat is Level-1 device-only data,
  same as Typing Ghost content and Private Gallery). This is a standing
  affordance, not a dismissible banner.
- Bubbles: mine = `--grad-hot` fill, white text, 22/22/7/22 corner radius,
  right-aligned, max-width 78%. Theirs = `--surf` fill, `--tx` text,
  22/22/22/7 corner radius, left-aligned, max-width 78%. Both per the
  existing design source markup — no changes.
- Timestamp: caption-size (13pt token), `--tx2`, below each bubble.
- **Read-receipt tick (mine messages only)**: two states in the design
  source's own data shape — `done` (single check, sent/delivered) and
  `done_all` (double check, read by partner). Reuse this 2-state model
  (sent vs. read) as the default; if the realtime layer can distinguish a
  separate "delivered but not yet read" state, that would need a third
  visual (not currently drawn) — flagged as a Tech Lead input in §9, not
  assumed here. Theirs messages never show a tick (matches design source).
- No message-edit or message-delete affordance is drawn in the design
  source and none is specified here — out of scope, do not add one.

### 3c. Message History Load (AC3 — Drift read-through cache)

Not shown in the static design source (it only draws a populated thread).
Specify the loading behavior needed for a server-authoritative,
Drift-backed read-through cache:
- **Cold open**: render whatever is already in the local Drift cache
  immediately (no spinner, no empty-state flash) — this is the point of a
  read-through cache: the user should see their last-known thread the
  instant the screen mounts. Reconcile with the server in the background;
  if new/changed messages arrive, append/update in place without a jarring
  re-layout or scroll-position jump (keep the user's current scroll offset
  unless they are already pinned to the bottom, in which case auto-scroll
  to reveal the new message, matching common chat-app expectation).
- **First-ever open (empty cache, no history yet)**: show a small
  couple-first empty state ("Say hi 👋" / "Chào Bae đi 👋" — placeholder
  copy, PO to confirm final string) rather than a blank scroll area, using
  the existing empty-state visual language (soft nebula background already
  present, no extra illustration needed — keep this lightweight).
- **Older-message pagination (scroll up)**: a small inline spinner at the
  top of the scroll region while older pages load from Drift/server; no
  full-screen loading state. If the local Drift cache already has the
  requested older page, this should resolve instantly with no visible
  spinner (only show it when actually waiting on network).
- Exact page size / prefetch distance is a Mobile Developer implementation
  detail, not a UX decision — not specified further here.

### 3d. Typing Ghost (2-way, in-composer)

Reuse the design source's chat-screen Typing Ghost states verbatim — this
is the primary AC2 surface:
- **Ghost toggle button** (composer, left of the text field): three visual
  states — off (`--surf` bg, `--tx2` icon/label "OFF"), pending
  (`···` label, mid-request while waiting for partner's consent), on
  (`rgba(183,140,245,.24)` bg, `--purple` icon/label "ON"). Tapping while
  pending calls the accept action instead of re-toggling (matches existing
  `toggleGhost: () => (a.ghostPending ? a.acceptGhost() : a.toggleGhost())`
  logic) — i.e. the same button doubles as "accept the pending request"
  when the current user is the one who still needs to consent.
- **Composer placeholder swap**: when Ghost is on, the text field
  placeholder changes to "They see every keystroke…" / "Đối phương thấy
  từng chữ…" as a standing reminder while composing — reuse verbatim.
- **"You are being watched" warning row**: appears above the composer only
  while Ghost is on AND the current user has draft text — "Linh/Minh is
  watching you type" / "…đang xem bạn gõ" — reuse verbatim, partner name
  interpolated.
- **Partner ghost bubble**: a dashed-border bubble (distinct from normal
  message bubbles — dashed `rgba(183,140,245,.6)` border,
  `rgba(183,140,245,.12)` fill) shows the partner's live draft with a
  blinking-cursor character, and any deleted-but-typed runs rendered
  struck-through in `--ghost` color with the `ghostFade` fade-to-45%-opacity
  animation over 1.3s. This is the core "see what they deleted" mechanic —
  reuse the exact visual treatment; do not simplify it to a plain "…is
  typing" indicator, since the struck-through-deleted-text behavior is the
  differentiating feature, not decoration.
- **Latency window (AC2)**: the design source's own `ghostset` explainer
  copy claims "under 200ms" for keystroke arrival — treat that as existing
  product copy, not a verified engineering SLA. Tech Lead must still set
  the actual acceptable latency threshold for AC2's "reasonable latency
  window" (flagged in story_master.md and reiterated in §9); if the real
  achievable latency differs meaningfully from 200ms, PO should revisit
  that copy line in `ghostset`, not silently keep an inaccurate claim.
- Typing Ghost content is explicitly ephemeral (never persisted, never
  part of chat history) — do not let it interact with the Drift
  read-through cache in §3c; ghost drafts must never be written to local
  storage, consistent with `ghostset`'s own "100% ephemeral" copy (§3e).

### 3e. Composer — Send + Attachment Affordance

- Standard text input, 46px-tall pill-in-pill treatment per the existing
  design source markup, min-height matching `--tap`.
- Send button: circular, `--grad-hot` fill, up-arrow icon, only meaningfully
  actionable when the draft is non-empty (disabled/dimmed state on empty
  draft is implied by standard composer UX, not separately drawn in source
  — apply the existing disabled-button convention from STORY-001 tokens).
- **Attachment icon**: the design source draws exactly one outlined
  `image` icon in the composer, with no dedicated attachment-picker screen
  or multi-select gallery grid anywhere in the source. This spec reuses
  that minimal affordance as-is (tap opens the platform's native
  single-image picker, not an in-app custom picker) **pending Tech Lead's
  confirmation of what the `messages`/`uploads` contract actually
  supports** (story_master.md's own open item — not resolved by this
  spec). Two explicit outcomes, either is acceptable UX-wise:
  - If the contract supports image attachments in chat: reuse the same
    bubble corner-radius/max-width family as text bubbles (§3b) for an
    image message — image fills the bubble, optional caption text below
    the image inside the same bubble in the standard body-text style; tap
    the image to open a simple full-screen tap-to-dismiss viewer
    (pinch-zoom optional, not required for v1). This full-screen viewer
    pattern is **new** (not present in the design source) since no
    existing screen shows one yet (Private Gallery, epic-4, is a later
    story) — flagged as a new, small, low-risk addition, not a re-use.
  - If the contract does not support attachments in chat: remove the
    `image` icon from the composer entirely rather than leaving a
    non-functional affordance visible. Do not ship a disabled/dead icon.
- No voice-message, sticker-picker, or reaction affordance is drawn in the
  design source and none is specified here.

## 4. Typing Ghost Settings Screen (`isGhostSet`)

Reuse the design source's three-card layout verbatim:
1. **Explainer hero card**: gradient card, blur_on icon, headline "They see
   what you deleted" / "Đối phương thấy cả phần bạn đã xoá", body copy
   claiming sub-200ms delivery and no persistence (see §3d latency caveat —
   same caveat applies here).
2. **Toggle card**: title "Typing Ghost", live state line (off / pending —
   "waiting for both to agree" / on — "on · both agreed"), a pill switch
   (same `toggleGhost` action as the in-chat button — tapping while pending
   accepts), and a two-column consent-status readout per partner ("agreed"
   in `--mint` vs. "off" in `--tx2`). Footer line: "Both must agree. Either
   one turning it off stops it for both." — reuse verbatim; this is the
   mutual-consent contract stated in system UX memory §9.
3. **Example/legend card**: static "what it looks like" preview of a
   live-typing run plus a struck-through deleted run, with a 2-item color
   legend (deleted vs. live).
4. **Ephemeral-guarantee footer card**: mint-tinted reassurance card,
   shield icon, "100% ephemeral. Keystrokes pass through the socket only —
   never written to a database or your chat history." — reuse verbatim;
   this is the copy that backs the "no offline queue for Ghost content"
   guarantee and pairs with AC4's stance on chat sends.

This screen keeps the header + bottom tab bar visible per the design
source's own chrome rules (not in `NO_TABS`) — do not hide tabs here even
though it reads like a settings subpage; that is the existing authored
behavior, not an oversight to "fix."

## 5. No Offline Send (AC4)

Per ADR-007/OQ4 resolution, chat has no local outbox/queue. UX
implications not shown in the static design source:
- If the send action is attempted with no connectivity (or the realtime
  layer reports itself disconnected), the send button visibly fails fast:
  do not silently swallow the tap or show an optimistic bubble that later
  disappears. Show the draft text remaining in the composer (not cleared,
  not added to the thread as a pending bubble) plus a single inline
  non-blocking indicator — reuse the same short-error convention as
  STORY-003 §6 (e.g. a small inline line under the composer or a
  non-blocking snackbar reading "Không có kết nối mạng" / "No internet
  connection" — reuse the exact `NetworkUnavailableFailure` copy already
  established in STORY-003 §6 rather than inventing new wording for the
  same underlying error).
- Do not add a "queued, will send when back online" affordance anywhere —
  that would misrepresent the explicit no-outbox decision. If connectivity
  returns, the user must re-tap send themselves; this is a deliberate
  product constraint (ADR-007), not a gap to soften with clever UX.
- The optimistic-bubble question: while a send is in-flight (connected,
  awaiting server ack), it is acceptable to show the bubble immediately
  with a "sending" micro-state (e.g. slightly dimmed until the `done` tick
  appears) — this is different from the "no connectivity" case above and
  does not conflict with the no-outbox rule, since it is not persisted
  across app restarts. Mobile Developer/Tech Lead to confirm feasibility;
  not a hard AC requirement, a polish recommendation only.

## 6. Presence / Partner Status Chip

The header's partner-status chip (§3a) needs a defined state set beyond
the design source's single hardcoded "online" example:
- **Online**: green dot + "online"/"đang online" (existing design).
- **Offline / no recent presence signal**: omit the green dot (or show a
  neutral-colored dot, `--tx2`) and either omit the status line or show a
  last-seen-style line if STORY-004's coordinator can supply one — exact
  choice is a Tech Lead input (§9), not resolved here, since it depends on
  what presence data the socket/FCM reconciliation actually exposes.
- Do not block chat usage based on presence state — presence is
  informational only, never a gate on sending/reading messages (that gate
  is pairing status, §7, and connectivity, §5 — two different things).

## 7. Chat Gated to Paired Users (AC5)

No dedicated "unpaired" empty-state screen is designed here. Per system UX
memory §4, the entire 5-tab main-app shell (home/chat/pet/money/me) is a
post-pairing surface — an unpaired user is structurally kept inside the
chromeless onboarding/pairing screen group (`invite`/`joincode`/`waiting`)
per STORY-005's own AC4 ("gates access to paired-only features... built in
later stories"). This spec relies on that existing gate rather than
re-specifying pairing UX:
- `chat`'s route/tab should only ever be reachable once STORY-005's paired
  state is true; this spec does not add a second, redundant gate/empty
  state inside `chat` itself.
- **Defensive edge case** (not designed in STORY-005, worth flagging here
  since it is this screen's blast radius): if a partner unpairs while the
  other user already has `chat` open, do not leave a stale, now-orphaned
  thread interactable. On receiving an unpair signal, navigate out of
  `chat` back to Home (or to the pairing flow if Home itself is also
  gated) rather than letting the user keep typing into a chat that no
  longer has a valid partner on the other end. Whether the backend/contract
  can even signal "partner unpaired" in real time is itself flagged as
  open in STORY-005 (unpair/leave flow support is an open item there) — if
  STORY-005 confirms no unpair flow exists at all, this edge case is moot
  and should be dropped, not implemented speculatively.

## 8. Accessibility Notes

- All interactive elements (ghost toggle, send button, attachment icon,
  composer field, header back button, partner-status chip if tappable)
  must meet the existing `--tap` minimum (44pt iOS / 48dp Material) per
  STORY-001 tokens — no new exemption.
- The partner's live Typing Ghost draft (§3d) updates very frequently
  (per-keystroke). This must be exposed to screen readers as a
  **polite**, not assertive, live region — an assertive/interrupting
  announcement on every keystroke would be unusable. Announce only
  meaningful transitions (ghost turned on/off, a full message arriving) at
  assertive priority; per-keystroke draft deltas should not each trigger a
  distinct screen-reader interruption.
- The mutual-consent toggle (§4) must announce its three states (off /
  pending / on) as accessible labels, not rely on color or the `···`
  glyph alone — e.g. semantic label "Typing Ghost: waiting for both to
  agree" for the pending state.
- Message bubbles: each bubble must be one accessible node combining
  sender context (mine/theirs — do not rely on left/right alignment alone
  for screen-reader users), message text, timestamp, and read-state (for
  mine messages) rather than exposing timestamp/tick as separate
  unlabeled nodes.
- Image messages (if shipped per §3e): must carry an accessible label at
  minimum indicating "photo message" plus timestamp/sender context; full
  alt-text generation is out of scope (no captioning requirement beyond
  the optional user-authored caption).
- Reuse STORY-003 §7's existing rule: inline errors (§5's
  no-connectivity indicator) must be associated via accessible
  description, not color alone.

## 9. Platform Adaptation

No new fork points beyond the existing 4 adaptive categories (STORY-001
§6): header (large-title/chevron-back iOS vs. top-app-bar/arrow-back
Material) and tab bar apply unchanged to `chat`/`ghostset`. The composer,
message bubbles, and Typing Ghost visuals are token-driven only (no
platform forking) per the existing design source, which draws them
identically for both platforms.

## 10. Open Items For Downstream Roles

1. **Tech Lead — attachment contract scope (story_master.md's own open
   item, still unresolved by this spec):** confirm whether
   `messages`/`uploads` actually supports image (or other) attachments in
   chat before Mobile Developer builds either the image-bubble +
   full-screen-viewer pattern (§3e) or removes the composer's attachment
   icon entirely. This spec describes both outcomes; it does not choose
   between them.
2. **Tech Lead — AC2 exact latency threshold:** story_master.md leaves the
   "reasonable latency window" undefined; the design source's own "under
   200ms" copy (§3d, §4) is product copy, not a confirmed engineering SLA
   — Tech Lead's ADR should set the real number, and PO should revisit the
   `ghostset` copy if the achievable number differs materially.
3. **Tech Lead — read-receipt state model:** confirm whether the realtime
   layer can distinguish "delivered" from "read," or whether the existing
   2-state (`done`/`done_all`, i.e. sent vs. read) design-source model is
   final. This spec defaults to the existing 2-state model.
4. **Tech Lead — presence semantics for the header status chip (§6):**
   online/offline binary vs. last-seen timestamp, driven by what
   STORY-004's RealtimeCoordinator can actually expose.
5. **Tech Lead/Backend — partner-unpaired-while-chatting edge case
   (§7):** depends entirely on STORY-005's still-open question of whether
   an unpair/leave flow exists at all; if it does not, drop the defensive
   navigation-out behavior described in §7 rather than building for an
   event that can never fire.
6. **Product Owner — empty-state copy (§3c):** placeholder "Say hi 👋" /
   "Chào Bae đi 👋" first-open copy needs PO sign-off as final user-facing
   string (not sourced from the design source, since the source only ever
   shows a populated thread).
7. **System UX memory update recommended, out of this story's write
   scope:** this story's WriteScope only covers `STORY-007_chat/ux/**`, so
   `data/ux/system/ui_ux_system_memory.md` is not edited here — recommend
   Scrum Master fold this spec's read-through-cache loading pattern (§3c),
   the 2-state read-receipt model (§3d/§10.3), and the "ephemeral content
   never touches Drift" rule (§3d) into system UX memory as a reusable
   "realtime-feature UX patterns" section once this story is reviewed,
   since STORY-008 (anti-ghosting) and STORY-009 (synced reminders) are
   later realtime-adjacent stories that may want the same conventions.

**Note on anti-ghosting UI in the design source**: the raw `chat` screen
markup in `Cupid Screens.dc.html` also draws a "seen N minutes, no reply"
row and an "Emoji Storm" trigger button directly inside the chat scroll
region (`showSeenRow`, `stormReady`, `doStorm`). Per story_master.md, that
functionality belongs to STORY-008 (Anti-Ghosting), not this story —
STORY-007's In Scope section does not mention it, and STORY-008 is listed
as a separate later story. This spec deliberately does not include that
row in §3b/§3c; STORY-008's own UX pass should add it back into the
`chat` screen as its own addition on top of this spec, rather than this
story building a placeholder/hardcoded-threshold version of it.

## Completion

UX_COMPLETE: YES

All five ACs have a corresponding UX specification: AC1 (§3b message
thread + §3c history-load behavior), AC2 (§3d Typing Ghost states +
§10.2 latency flag), AC3 (§3c Drift read-through cache loading pattern),
AC4 (§5 no-offline-send behavior), AC5 (§7 reliance on STORY-005's pairing
gate + defensive edge case). No blocker found; the attachment scope
question from story_master.md's own open items remains open by design
(this spec describes both outcomes rather than guessing at the frozen
contract) and is restated in §10.1.
